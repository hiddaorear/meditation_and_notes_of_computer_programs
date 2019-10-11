exception BadResult of string

type exp =
  [ `Int of int | `Negate of exp | `Add of exp * exp]

let rec eval e =
  match e with
  | `Int _ -> e
  | `Negate e1 -> (match eval e1 with
                   | `Int i -> `Int (-i)
                   | _ -> raise (BadResult "non-int in negation"))
  | `Add(e1, e2) -> (match (eval e1, eval e2) with
                     | (`Int i, `Int j) -> `Int (i + j)
                     | _ -> raise (BadResult "non-ints in addition"))

let rec toString = function
  | `Int i -> string_of_int i
  | `Negate e -> "-(" ^ (toString e) ^ ")"
  | `Add(e1, e2)  -> "(" ^ (toString e1) ^ "+" ^ (toString e2) ^ ")"

type new_exp = [ exp | `Sub of new_exp * new_exp]


let rec new_eval e =
  match e with
  | #exp as exp -> eval exp
  | `Sub(e1, e2) -> (match (new_eval e1, new_eval e2) with
                     | (`Int i, `Int j) -> `Int (i - j)
                     | (`Int i, `Negate j) -> (new_eval (i, j))
                     | (`Negate i, `Negate j) -> new_eval i j
                     | (`Negate i, j) -> new_eval i j)

let rec new_toString  = function
  | `Sub(e1, e2) -> "(" ^ (new_toString e1) ^ "-" ^ (new_toString e2) ^ ")"
  | #exp as exp -> toString exp

;;

let a = `Int 7
let b = `Int 6
let c = `Sub(a, b)
let d = new_eval c

let res = new_toString d;;
print_endline res;;
