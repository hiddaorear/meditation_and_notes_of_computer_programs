(*
 * An OCaml implementation of final tagless, inspired from this article by Oleksandr Manzyuk:
 * https://oleksandrmanzyuk.wordpress.com/2014/06/18/from-object-algebras-to-finally-tagless-interpreters-2/
 *)

module FinalTagless = struct
  type eval = { eval : int }
  type view = { view : string }

  module type ExpT = sig
    type t
    val lit : int -> t
    val add : t -> t -> t
  end

  module ExpEval = struct
    type t = eval
    let lit n = { eval = n }
    let add x y = { eval = x.eval + y.eval }
  end

  module ExpView = struct
    type t = view
    let lit n = { view = string_of_int n }
    let add x y = let s = "(" ^ x.view ^ " + " ^ y.view ^ ")"
                  in { view = s }
  end

  module type MulT = sig
    include ExpT
    val mul : t -> t -> t
  end

  module MulEval = struct
    include ExpEval
    let mul x y = { eval = x.eval * y.eval }
  end

  module MulView = struct
    include ExpView
    let mul x y = let s = "(" ^ x.view ^ " * " ^ y.view ^ ")"
                  in { view = s }
  end

  let e1 (type s) (module M : ExpT with type t = s) =
    M.add (M.add (M.lit 10) (M.lit 12)) (M.lit 40)

  let v1 = e1 (module ExpEval)
  let s1 = e1 (module ExpView)

  let e2 (type s) (module M : MulT with type t = s) =
    M.mul (M.add (M.lit 10) (M.lit 12)) (M.lit 40)

  let v2 = e2 (module MulEval)
  let s2 = e2 (module MulView)

  let () =
    Printf.printf "%s = %d\n" s1.view v1.eval; (* ((10 + 12) + 40) = 62 *)
    Printf.printf "%s = %d\n" s2.view v2.eval  (* ((10 + 12) * 40) = 880 *)
