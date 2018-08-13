declare function cls(c: col): void

/**
 * game loop.
 */

function _update() {}

function _draw() {
  cls(col.indigo)
}

/**
 * utils.
 */

enum col {
  black,
  dark_blue,
  dark_purple,
  dark_green,
  brown,
  dark_gray,
  light_gray,
  white,
  red,
  orange,
  yellow,
  green,
  blue,
  indigo,
  pink,
  peach,
}
