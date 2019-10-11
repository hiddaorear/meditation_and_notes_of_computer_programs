exception BadResult of string

type exp =
  | Int of int
  | Negate of exp
  | Add of exp * exp

let rec eval e =
  match e with
  | Int _ -> e
  | Negate e1 -> (match eval e1 with
                  | Int i -> Int(-i)
                  | _ -> raise (BadResult "non-int in negation"))
  | Add(e1, e2) -> (match (eval e1, eval e2) with
                    | (Int i, Int j) -> Int (i + j)
                    | _ -> raise (BadResult "non-ints in addition"))

let rec toString = function
  | Int i -> string_of_int i
  | Negate e -> "-(" ^ (toString e) ^ ")"
  | Add(e1, e2)  -> "(" ^ (toString e1) ^ "+" ^ (toString e2) ^ ")"
;;

let res = toString (eval (Add ((Negate (Int 5)), (Int 6))));;
print_endline res;;
