{
  open Parser ;;

  exception LexError of string ;;
}

rule token = parse
   [' ']	               { token lexbuf }
 | ['0'-'9']+		       { INT (int_of_string (Lexing.lexeme lexbuf)) }
 | "-K"                        { OPT_K }
 | "-T"                        { OPT_T }
 | "-A"                        { OPT_A }
 | "-L"                        { OPT_L }
 | "-E"                        { OPT_E }
 | "-G"                        { OPT_G }
 | "-R"                        { OPT_R }
 | "\n" 	       	       { EOL }
 | ['a'-'z' 'A'-'Z' '0'-'9']+  { IDENT (Lexing.lexeme lexbuf) }
 | eof			       { EOF }
 | _			       { raise (LexError (Lexing.lexeme lexbuf)) }
