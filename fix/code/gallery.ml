open Hashtbl
open Crypt_util

exception Integrity_error ;;

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

type person_idx =
  {
    p_name : string;
    p_gender : person_gender;
  }
;;

type person =
  {
    name : string;
    gender : person_gender;
    state : state_t;
    history : (int*int*int) list;
    enter_time : int;
    leave_time : int;
  }
;;

let list_empl = ref [];;
let list_guest = ref [];;
let list_room = ref [];;

type log_t =
  {
    timestamp : int;
    filename : string;
    hash : (person_idx, person)t
  }

let find_log log n g app =
  try
    let fp = {p_name = n; p_gender = g} in
    Hashtbl.find log fp 
  with
  | Not_found ->
    if(app) then
      {name = n;
       gender = g;
       state = Unknown;
       history = [];
       enter_time = -1;
       leave_time = -1;
      }
    else
      failwith("Unknown person.");
  | e -> raise e;
;;

let create_p p1 next_st t =
  { name = p1.name;
    gender = p1.gender;
    state = next_st;
    enter_time =
      if(p1.state = Unknown && next_st = Gallery) then
	t
      else
	p1.enter_time;
    leave_time =
      if(p1.state = Gallery && next_st = Unknown) then
	t
      else
	p1.leave_time;
    history =
      match next_st with
      | Room(i) -> (i,t,-1)::p1.history
      | Gallery ->
	begin
	  if(p1.state <> Unknown) then
	    begin
	      match p1.history with
	      | (i,ta,_)::q ->
		(i,ta,t)::q
	      | _ -> failwith("Erreur de sequence history")
	    end
	  else
	    p1.history;
	end
      | _ -> p1.history;
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
  | (i, _, _)::[] -> print_string ((string_of_int i)^"\n")
  | (i,_,_)::q -> print_string ((string_of_int i)^","); print_hist q
;;

let print_person (idx:person_idx) (pers:person) =
  print_string ("Idx : \n"^idx.p_name^"  : "^(print_gender idx.p_gender));
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

let analyse_person _ p1 =
  match p1.gender with
  | Employee ->
    begin
      match p1.state with
      | Room(_) ->
	begin
	  list_empl := p1.name::!list_empl;
	  match p1.history with
	  | [] -> ()
	  | (i,_,_)::q ->
	    list_room := gen_list_room i p1.name !list_room
	end
      | Gallery ->
	begin
	  list_empl := p1.name::!list_empl;
	end
      | _ ->
	()
    end
  | Guest ->
    begin
      match p1.state with
      | Room(_) ->
	begin
	  list_guest := p1.name::!list_guest;
	  match p1.history with
	  | [] -> ()
	  | (i,_,_)::q ->
	    list_room := gen_list_room i p1.name !list_room;
	end
      | Gallery ->
	begin
	  list_guest := p1.name::!list_guest;
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

let rec print_rooms_i l =
  match l with
  | [] -> ()
  | t::[] -> print_string((string_of_int t)^"\n")    
  | t1::t2::q ->
    if(t1 <> t2) then
      begin
	print_string ((string_of_int t1)^",");
      end;
    print_rooms_i (t2::q)
;;

let print_result_s log =
  Hashtbl.iter analyse_person log;
  if(!list_empl <> []) then
    print_names (List.fast_sort sort !list_empl);
  if(!list_guest <> []) then
    print_names (List.fast_sort sort !list_guest);
  print_rooms (List.fast_sort sort_pair !list_room);
;;

(* Load the log file into memory or create a new hashtable if log file not existing for logappend primitive. 
If file is not existing for logread primitive abort *)
let load_file name token iv timestamp app =
  try
    if( Sys.file_exists name ) then
      let log = Crypt_util.load_authen_file token iv name in
(*      if(log.filename <> name) then
	raise Integrity_error
      else
*)
	log
    else if(app) then
      begin
	(* create a new memory struture *)
	{
	  timestamp = timestamp-1;
	  hash = Hashtbl.create 1889;
	  filename = name;
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


let load_log_file log_info token timestamp app =
  if(not(check_integrity log_info log_info.filename token app)) then
    begin
      raise Integrity_error
    end
  else
    begin
      load_file log_info.filename token log_info.iv timestamp app
    end
;;


let check_name s =
  let good_string c =
    if((c >= 'a' && c <= 'z') || (c>='A' && c<='Z')) then
      ()
    else
      raise (Arg.Bad "Illegal name")
  in
  String.iter good_string s
;;

let check_token s =
  let good_string c =
    if((c >= 'a' && c <= 'z') || (c>='A' && c<='Z') || (c>='0' && c<= '9')) then
      ()
    else
      raise (Arg.Bad "Illegal token")
  in
  String.iter good_string s
;;

let check_filename s =
  let good_string c =
    if((c >= 'a' && c <= 'z') || (c>='A' && c<='Z') || (c>='0' && c<= '9')
	  || (c = '.') || (c = '/') || (c = '_') ) then
      ()
    else
      raise (Arg.Bad "Illegal file name")
  in
  String.iter good_string s
;;



