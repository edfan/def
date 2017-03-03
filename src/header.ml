(* Copyright (C) 2017  DEFC Authors

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
   02110-1301, USA.
 *)

open Ast
open Types

let autogen =
  "THIS FILE WAS AUTOMATICALLY GENERATED.  DO NOT MODIFY IT OR YOUR\n"
  ^ " * CHANGES MAY GET CLOBBERED."

let begin_cpp_mode =
  "#ifdef __cplusplus\nextern \"C\" {\n#endif\n\n"

let end_cpp_mode =
  "#ifdef __cplusplus\n} // extern \"C\"\n#endif\n"

let rec cstring_of_type = function
  | VarType (_, nm) -> nm
  | FcnType _ -> Report.err_internal __FILE__ __LINE__
     "FcnType not implemented."
  | StructType _ -> Report.err_internal __FILE__ __LINE__
     "StructType not implemented."
  | PtrType (_, t) -> (cstring_of_type t) ^ "*"
  | Ellipsis _ -> "..."

let output_functions oc = function
  | DefFcn (_, VisExported _, name, FcnType (args, ret), _) ->
     begin
       output_string oc (cstring_of_type ret);
       output_string oc (" " ^ name ^ "(");
       let params =
         List.map (fun (_, name, tp) ->
           (cstring_of_type tp) ^ (if name <> "" then " " ^ name else ""))
           args
       in
       output_string oc (String.concat ", " params);
       output_string oc ");\n\n"
     end
  | _ -> ()

(** header_of outfile stmts: Output a C/C++ header file of "outfile" using
    a set of AST stmts. *)
let header_of outfile stmts =
  let oc = open_out outfile in
  output_string oc ("/* " ^ outfile ^ ": " ^ autogen ^ "\n */\n");
  output_string oc "#pragma once\n";
  output_string oc begin_cpp_mode;
  List.iter (output_functions oc) stmts;
  output_string oc end_cpp_mode;
  close_out oc
