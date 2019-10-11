exception BadResult of string

type exp =
  [ `Int of int | `Negate of exp | `Add of exp * exp]

let rec eval e =
  match e with
  | `Int _ -> e
  | `Negate e1 -> (match eval e1 with
                   | `Int i -> `Int (-i))
  | `Add(e1, e2) -> (match (eval e1, eval e2) with
                     | (`Int i, `Int j) -> `Int (i + j))

let rec toString = function
  | `Int i -> string_of_int i
  | `Negate e -> "-(" ^ (toString e) ^ ")"
  | `Add(e1, e2)  -> "(" ^ (toString e1) ^ "+" ^ (toString e2) ^ ")"

type new_exp = [ exp | `Sub of new_exp * new_exp]


let rec new_eval e =
  match e with
  | #exp as exp -> eval exp
  | `Sub(e1, e2) -> (match (new_eval e1, new_eval e2) with
                     | (`Int i, `Int j) -> `Int (i - j))

let rec new_toString : new_exp -> string = function
  | `Sub(e1, e2) -> "(" ^ (new_toString e1) ^ "-" ^ (new_toString e2) ^ ")"
  | #exp as exp -> toString exp

;;

let a = `Int 7
let b = `Int 6
let c = `Sub(a, b)
let d = new_eval c;;

let res = toString d;;
print_endline (new_toString c);;
print_endline res;;
