open Hashtbl
open Crypt_util

type person_gender =
| Employee
| Guest
;;

type state_t =
| Unknown
| Gallery
| Room of int
| Error
;;

type action_t =
| ArrivalG
| LeaveG
| ArrivalR of int
| LeaveR of int
;;

type person =
  {
    name : string;
    gender : person_gender;
    state : state_t;
    history : int list;
    enter_time : int;
  }

let list_empl = ref [];;
let list_guest = ref [];;
let list_room = ref [];;

type log_t =
  {
    timestamp : int;
    hash : (string, person)t
  }

let find_log log n g app =
  try
    let p = Hashtbl.find log n in
    if(p.gender <> g) then
      failwith("Gender error")
    else
      p
  with
  | Not_found ->
    if(app) then
      {name = n;
       gender = g;
       state = Unknown;
       history = [];
       enter_time = -1;
      }
    else
      failwith("Unknown person.");
  | e -> raise e;
;;

let create_p p next_st t =
  { name = p.name;
    gender = p.gender;
    state = next_st;
    enter_time =
      if(p.state = Unknown && next_st = Gallery) then
	t
      else
	p.enter_time;
    history =
      match next_st with
      | Room(i) -> i::p.history
      | _ -> p.history;
  }
;;
  
let next_state st act =
  let new_s =
    match st with
    | Unknown ->
      begin
	match act with
	| ArrivalG -> Gallery
	| _-> Error
      end
    | Gallery ->
      begin
	match act with
	| LeaveG -> Unknown
	| ArrivalR(i) -> Room(i)
	| _ -> Error
      end
    | Room(i) ->
      begin
	match act with
	| LeaveR(j) ->
	  if(i = j) then
	    Gallery
	  else
	    Error
	| _ -> Error
      end
    | Error -> Error
  in
  if(new_s = Error) then
    failwith("Wrong sequence.")
  else
    new_s
;;

(* Transcode the action from the parameter *)
let action arrival leave room =
  if( arrival ) then
    if( room = -1) then
      (* Arrival in the gallery *)
      ArrivalG
    else
      (* Arrival in a room *)
      ArrivalR(room)
  else if(leave) then
    if(room = -1) then
      (* Leave the Gallery *)
      LeaveG
    else
      (* Leave a room *)
      LeaveR(room)
  else
    failwith("Wrong action")
;;

(***********************************************************)
(*                    Print functions                      *) 
(***********************************************************)
let print_gender g =
  match g with
  | Employee -> "Employee"
  | Guest -> "Guest"
;;

let print_state st =
  match st with
  | Unknown -> "Unknown"
  | Gallery -> "Gallery"
  | Room(i) -> "Room("^(string_of_int i)^")" 
  | Error -> "Error"
;;

let print_action act =
  match act with
  | ArrivalG -> "Arrival G"
  | LeaveG -> "LeaveG"
  | ArrivalR(r) -> "Arrival("^(string_of_int r)^")"
  | LeaveR(r) -> "Leave("^(string_of_int r)^")"
;;

let rec print_hist l =
  match l with
  | [] -> ()
  | t::[] -> print_string ((string_of_int t)^"\n")
  | t::q -> print_string ((string_of_int t)^","); print_hist q
;;

let print_person (idx:string) (pers:person) =
  print_string ("Idx : \n"^idx);
  print_string ("Name :"^pers.name^"/");
  print_string ((print_gender pers.gender)^"\n");
  print_string ((print_state pers.state)^"\n");
  print_hist (List.rev pers.history);
  print_string "\n";
  print_string ((string_of_int pers.enter_time)^"\n");
;;

let print_log log =
  Hashtbl.iter print_person log
;;

(***************************************************************)
(*                  Output function                            *)
(***************************************************************)
let rec gen_list_room r n lr =
  match lr with
  | [] -> [(r, n::[])]
  | (t,l)::q ->
    if( r = t) then
      (r, n::l)::q
    else
      (t,l)::(gen_list_room r n q)
;;

let analyse_person _ p =
  match p.gender with
  | Employee ->
    begin
      match p.state with
      | Room(_) ->
	begin
	  list_empl := p.name::!list_empl;
	  match p.history with
	  | [] -> ()
	  | t::q ->
	    list_room := gen_list_room t p.name !list_room
	end
      | Gallery ->
	begin
	  list_empl := p.name::!list_empl;
	end
      | _ ->
	()
    end
  | Guest ->
    begin
      match p.state with
      | Room(_) ->
	begin
	  list_guest := p.name::!list_guest;
	  match p.history with
	  | [] -> ()
	  | t::q ->
	    list_room := gen_list_room t p.name !list_room;
	end
      | Gallery ->
	begin
	  list_guest := p.name::!list_guest;
	end
      | _ ->
	()
    end
;;

let sort a b =
  if( a < b ) then -1
  else if (a = b) then 0
  else 1
;;

let sort_pair (a,_) (b,_) =
  if( a < b ) then -1
  else if (a = b) then 0
  else 1
;;
  
let rec print_names l =
  match l with
  | [] -> print_string("\n")
  | t::[] -> print_string(t^"\n")
  | t::q -> print_string(t^","); print_names q
;;

let rec print_rooms l =
  match l with
  | [] -> ()
  | (r, lp)::q ->
    print_string ((string_of_int r)^": ");
    print_names (List.fast_sort sort lp); print_rooms q
;;

let print_result_s log =
  Hashtbl.iter analyse_person log;
  print_names (List.fast_sort sort !list_empl);
  print_names (List.fast_sort sort !list_guest);
  print_rooms (List.fast_sort sort_pair !list_room);
;;

(* Load the log file into memory or create a new hashtable if log file not existing for logappend primitive. 
If file is not existing for logread primitive abort *)
let load_file name token iv app =
  try
    if( Sys.file_exists name ) then
      let log = Crypt_util.load_authen_file token iv name in
      log
    else if(app) then
      begin
	(* create a new memory struture *)
	{
	  timestamp = -1;
	  hash = Hashtbl.create 97
	}
      end
    else
      (* for logread, log file must exist *)
      failwith("Unknown file : "^name)
  with
  | e -> raise e
;;

(* Write the log structure into the log  file on disk *)
let write_file name token iv log =
  try
    Crypt_util.write_authen_file name token iv log
  with
  | e -> raise e
;;

let check_name s =
  let good_string c =
    if((c >= 'a' && c <= 'z') || (c>='A' && c<='Z')) then
      ()
    else
      failwith("Illegal name")
  in
  String.iter good_string s
;;

let check_token s =
  let good_string c =
    if((c >= 'a' && c <= 'z') || (c>='A' && c<='Z') || (c>='0' && c<= '9')) then
      ()
    else
      failwith("Illegal token")
  in
  String.iter good_string s
;;

let check_filename s =
  let good_string c =
    if((c >= 'a' && c <= 'z') || (c>='A' && c<='Z') || (c>='0' && c<= '9')
	  || (c = '.') || (c = '/') || (c = '_') ) then
      ()
    else
      failwith("Illegal filename")
  in
  String.iter good_string s
;;
