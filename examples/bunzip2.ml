(* Sample replacement for "bunzip2": showcase for CamlBZ2
 *
 * Copyright © 2009      Stefano Zacchiroli <zack@upsilon.cc>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License (with the
 * special exception on linking described in file COPYING) as published
 * by the Free Software Foundation; either version 2.1 of the License,
 * or (at your option) any later version.
 *)

(* Compile with: ocamlfind ocamlc -package bz2 -linkpkg -o bunzip2 bunzip2.ml *)

open Printf

let die_usage () =
  printf "Usage: bunzip2 FILE.bz2\n" ;
  exit 2

let (iname, ic) =
  try (Sys.argv.(1), open_in Sys.argv.(1))
  with Invalid_argument _ -> die_usage ()

let oc =
  if not (Filename.check_suffix iname ".bz2") then (
    eprintf "Error: unrecognized compressed file extension" ;
    die_usage ()) ;
  open_out (Filename.chop_suffix iname ".bz2")

let buflen = 8192

let buf = Bytes.create buflen

let bzic = Bz2.open_in ic

let _ =
  try
    while true do
      let bytes = Bz2.read bzic buf 0 buflen in
      output oc buf 0 bytes ;
      if bytes < buflen then raise End_of_file
    done
  with End_of_file ->
    () ;
    Bz2.close_in bzic ;
    close_in ic ;
    close_out oc
