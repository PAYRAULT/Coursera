type token =
  | IDENT of (string)
  | INT of (int)
  | OPT_K
  | OPT_T
  | OPT_A
  | OPT_L
  | OPT_G
  | OPT_E
  | OPT_R
  | EOL
  | EOF

val toplevel :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parserlist.elem list
