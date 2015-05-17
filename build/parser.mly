%{
  open Parserlist ;;

  let token = ref "";;
  let log_file_name = ref "";;
  let employee = ref "";;
  let guest = ref "";;
  let time_stamp = ref (-1);;
  let room = ref (-1);;
  let arrival = ref false;;
  let leave = ref false;;

  let lst = ref [];;
    
  let const_elem () =
    let elem = 
      {
	log_file_name = !log_file_name;
	token = !token;
	time_stamp = !time_stamp;
	employee = !employee;
	guest = !guest;
	room = !room;
	arrival = !arrival;
	leave = !leave;
      }
    in
    lst := elem :: !lst;
    token := "";
    log_file_name := "";
    employee := "";
    guest := "";
    time_stamp := -1;
    room := -1;
    arrival := false;
    leave := false;
  ;;
%}

%token <string> IDENT
%token <int> INT
%token OPT_K
%token OPT_T
%token OPT_A
%token OPT_L
%token OPT_G
%token OPT_E
%token OPT_R
%token EOL
%token EOF

%start toplevel
%type <Parserlist.elem list> toplevel
%%

toplevel:
 | lines EOF                                     { !lst }
;
  
lines:
 | lines line                          { const_elem()}
 | line                                { const_elem()}    
;

line:
   opts IDENT EOL                      { log_file_name := $2}
;

opts:
 | opt opts                                     { }
 | opt                                          { }
;

opt:
 | OPT_K IDENT                                  { print_string (" -K "^$2); token := $2 }
 | OPT_T INT                                    { print_string (" -T "^(string_of_int $2));time_stamp := $2}
 | OPT_A                                        { print_string (" -A"); arrival := true }
 | OPT_L                                        { print_string (" -L"); leave := true }
 | OPT_E IDENT                                  { print_string (" -E "^$2);employee := $2 }
 | OPT_G IDENT                                  { print_string (" -G "^$2);guest := $2 }
 | OPT_R INT                                    { print_string (" -R "^(string_of_int $2));room := $2 }
;

