open Ast
open Cfg
open Llvm
open Util

exception ProcessingError of string

type llvm_data =
  { ctx  : llcontext;
    mdl  : llmodule;
    bldr : llbuilder;
    typemap : lltype symtab;
    prog : program
  }

let get_fcntype = function
  | FcnType (params, ret) -> params, ret
  | _ -> fatal_error "Internal error.  Function not of FcnType."

let builtin_types ctx =
  let typemap = make_symtab () in
  begin
    add_symbol typemap "i32" (i32_type ctx);
    typemap
  end

let deftype2llvmtype typemap =
  let rec convert = function
    | FcnType (args, ret) ->
       let llvmargs = List.map (fun (_, _, argtp) -> convert argtp) args in
       function_type (convert ret) (Array.of_list llvmargs)
    | VarType (pos, typename) ->
       begin match lookup_symbol typemap typename with
       | Some t -> t
       | None ->
          let errstr = "Unknown type \"" ^ typename ^ "\": "
            ^ (format_position pos) ^ "\n"
            ^ (show_source pos)
          in raise (ProcessingError errstr)
       end
  in convert

let process_atom data varmap = function
  | AtomInt (_, i) ->
     const_int (the (lookup_symbol data.typemap "i32")) i
  | AtomVar (_, v) ->
     let (_, _, llvar) = the (lookup_symbol varmap v) in llvar

let process_expr data varmap =
  let llvm_operator = function
    (* FIXME: Should specify a proper name for intermediate values. *)
    | OperMult _ -> (build_mul, "def_mult")
    | OperDiv _ -> (build_sdiv, "def_sdiv")
    | OperPlus _ -> (build_add, "def_add")
    | OperMinus _ -> (build_sub, "def_sub")
    | OperLT _ -> (build_icmp Icmp.Slt, "def_lt")
    | OperLTE _ -> (build_icmp Icmp.Sle, "def_le")
    | OperGT _ -> (build_icmp Icmp.Sgt, "def_gt")
    | OperGTE _ -> (build_icmp Icmp.Sge, "def_ge")
    | OperEquals _ -> (build_icmp Icmp.Eq, "def_eq")
    | _ -> failwith "llvm_operator not fully implemented"
  in
  let rec expr_gen = function
    | ExprAtom atom -> process_atom data varmap atom
    | ExprBinary (op, left, right) ->
       let e1 = expr_gen left
       and e2 = expr_gen right
       and (func, ident) = llvm_operator op in
       func e1 e2 ident data.bldr
    | _ -> failwith "expr_gen not fully implemented."
  in expr_gen

let rec process_body data llfcn varmap scope entry_bb =
  let process_bb bb = function
    | BB_Cond conditional ->
       failwith "FIXME: Not implemented, yet."
    | BB_Expr (_, expr) ->
       begin ignore (process_expr data varmap expr); bb end
    | BB_Scope scope -> process_body data llfcn varmap scope bb
    | BB_Return (_, expr) ->
       let ret = process_expr data varmap expr in
       let _ = build_ret ret data.bldr in
       bb
    | BB_ReturnVoid _ ->
       failwith "FIXME: Not implemented, yet."
  in
  List.fold_left process_bb entry_bb scope.bbs

let process_fcn data fcn =
  let profile = the (lookup_symbol data.prog.global_decls fcn.name) in
  let varmap = make_symtab () in
  let llfcn =
    declare_function fcn.name
      (deftype2llvmtype data.typemap profile.tp) data.mdl
  in
  let bb = append_block data.ctx "entry" llfcn in
  position_at_end bb data.bldr;
  let (args, _) = get_fcntype profile.tp in
  let llparams = params llfcn in
  List.iteri (fun i (pos, n, tp) ->
    add_symbol varmap n (pos, tp, llparams.(i))) args;
  ignore (process_body data llfcn varmap fcn.body bb);
  Llvm_analysis.assert_valid_function llfcn

let process_cfg outfile module_name program =
  let ctx  = global_context () in
  let mdl  = create_module ctx module_name in
  let bldr = builder ctx in
  let typemap = builtin_types ctx in
  let data = { ctx = ctx; mdl = mdl; bldr = bldr;
               typemap = typemap; prog = program } in
  List.iter (process_fcn data) program.fcnlist;
  print_module outfile mdl
