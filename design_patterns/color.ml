open Core

type basic_color =
  [`Black | `Blue | `Cyan | `Green | `Magenta | `Red | `White | `Yellow]

type color =
  [`Basic of basic_color * [ `Bold | `Regular]
  | `Gray of int
  | `RGB of int * int * int]

type extended_color =
  [ color
  | `RGBA of int * int * int * int]

let basic_color_to_int = function
  | `Black -> 0 | `Red -> 1 | `Green -> 2 | `Yellow -> 3
  | `Blue -> 4 | `Magenta -> 5 | `Cyan -> 6 | `White -> 7


let color_to_int = function
  | `Basic (basic_color, weight) ->
     let base = match weight with `Bold -> 8 | `Regular -> 0 in
     base + basic_color_to_int basic_color
  | `RGB (r,g,b) -> 16 + b + g * 6 + r * 36
  | `Gray i -> 232 + i

let extended_color_to_int : extended_color -> int = function
  | `RGBA (r,g,b,a) -> 256 + a + b * 6 + g * 36 + r * 216
  | #color as color -> color_to_int color

let color_by_number number text =
  sprintf "\027[38;5;%dm%s\027[0m" number text

let blue = color_by_number (basic_color_to_int `Blue) "Blue";;

printf "color : Hello %s World!\n" blue;;

let my_grba = `RGBA (219,77,197,6);;

let rgba = color_by_number (extended_color_to_int my_grba) "rgba";;

printf "extended_color: Hello %s World!\n" rgba;;

(*corebuild color.native*)
