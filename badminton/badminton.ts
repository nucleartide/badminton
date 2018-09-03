///<reference path="../@types/pico8.d.ts">

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

enum palette {
  draw,
  screen,
}

enum button {
  left,
  right,
  up,
  down,
  z,
  x,
}

/**
 * --> 0. game loop.
 */

enum game_state {
  serve,
  playing,
  post_rally,
}

let current_game_state: game_state
let next_game_state: game_state
let g: game

_init = function(): void {
  current_game_state = game_state.serve
  next_game_state = game_state.serve
  g = game()
}

_update60 = function(): void {
  current_game_state = next_game_state

  if (
    current_game_state === game_state.playing ||
    current_game_state === game_state.serve ||
    current_game_state === game_state.post_rally
  ) {
    game_update(g)
  }
}

_draw = function(): void {
  cls(col.blue)

  if (
    current_game_state === game_state.playing ||
    current_game_state === game_state.serve ||
    current_game_state === game_state.post_rally
  ) {
    game_draw(g)
  }
}

/*
// This is a camera & polygon test.
{
  let c: cam, p: polygon

  const init = function(): void {
    const s = 6

    c = cam()
    c.dist = 12 * s
    c.fov = 34 * s

    // pentagon.
    p = polygon(col.peach, c, [
      vec3(30, -30, 0),
      vec3(30, 30, 0),
      vec3(-30, 30, 0),
      vec3(-50, 0, 0),
      vec3(-30, -30, 0),
    ])

    // court.
    p = polygon(col.dark_green, c, [
      // 6.1 x 13.4
      vec3((3.05 + 1) * s, 0, (6.7 + 1) * s),
      vec3((3.05 + 1) * s, 0, (-6.7 - 1) * s),
      vec3((-3.05 - 1) * s, 0, (-6.7 - 1) * s),
      vec3((-3.05 - 1) * s, 0, (6.7 + 1) * s),
    ])
  }

  const update = function(): void {
    if (btn(button.down)) c.x_angle += 0.01
    if (btn(button.up)) c.x_angle -= 0.01
    if (btn(button.left)) c.y_angle += 0.01
    if (btn(button.right)) c.y_angle -= 0.01
    polygon_update(p)
  }

  const draw = function(): void {
    cls(col.dark_blue)
    polygon_draw(p)
  }

  _init = init
  _update60 = update
  _draw = draw
}
*/

/**
 * --> 1. math.
 */

interface vec3 {
  x: number
  y: number
  z: number
}

type mat3 = [vec3, vec3, vec3]

function round(n: number): number {
  return flr(n + 0.5)
}

function lerp(a: number, b: number, t: number): number {
  return (1 - t) * a + t * b
}

// clockwise() implements the shoelace formula for checking
// the clock direction of a collection of points.
//
// note: when the sum/area is zero, clockwise() arbitrarily
// chooses "clockwise" as a direction. the sum/area is zero
// when all points are on the same scanline, for instance.
//
// also note: y points down.
function clockwise(points: Array<vec3>): boolean {
  let sum = 0
  for (let i = 0; i < points.length; i++) {
    const point = points[i]
    const next_point = points[(i + 1) % points.length]
    // to debug wrong clockwise values,
    // print the return value of this function
    // while rotating a polygon continuously.
    // we divide by 10 to account for overflow.
    sum += (((next_point.x - point.x) / 10) * (next_point.y + point.y)) / 10
  }
  return sum <= 0
}

/*
{
  const points = [
    {x:-50,y:50,z:0},
    {x: 50,y:50,z:0},
    {x: 50,y:-50,z:0},
    {x:-50,y:-50,z:0},
  ]

  const points2 = [
    {x:-50,y:-50,z:0},
    {x: 50,y:-50,z:0},
    {x: 50,y:50,z:0},
    {x:-50,y:50,z:0},
  ]

  assert(!clockwise(points))
  assert(clockwise(points2))
  stop()
}
*/

function vec3(x?: number, y?: number, z?: number): vec3 {
  return {
    x: x || 0,
    y: y || 0,
    z: z || 0,
  }
}

function vec3_add(out: vec3, a: vec3, b: vec3): void {
  out.x = a.x + b.x
  out.y = a.y + b.y
  out.z = a.z + b.z
}

function vec3_sub(out: vec3, a: vec3, b: vec3): void {
  out.x = a.x - b.x
  out.y = a.y - b.y
  out.z = a.z - b.z
}

function vec3_mul(out: vec3, a: vec3, b: vec3): void {
  out.x = a.x * b.x
  out.y = a.y * b.y
  out.z = a.z * b.z
}

function vec3_print(v: vec3): void {
  print(v.x + ', ' + v.y + ', ' + v.z)
}

function vec3_printh(v: vec3): void {
  printh(v.x + ', ' + v.y + ', ' + v.z, 'test.log')
}

function vec3_dot(a: vec3, b: vec3): number {
  return a.x * b.x + a.y * b.y + a.z * b.z
}

function vec3_cross(out: vec3, a: vec3, b: vec3): void {
  const ax = a.x
  const ay = a.y
  const az = a.z

  const bx = b.x
  const by = b.y
  const bz = b.z

  out.x = ay * bz - az * by
  out.y = az * bx - ax * bz
  out.z = ax * by - ay * bx
}

function vec3_scale(v: vec3, c: number): void {
  v.x *= c
  v.y *= c
  v.z *= c
}

function vec3_magnitude(v: vec3): number {
  if (v.x > 104 || v.y > 104 || v.z > 104) {
    const m = max(max(v.x, v.y), v.z)
    const x = v.x / m,
      y = v.y / m,
      z = v.z / m
    return sqrt(x ** 2 + y ** 2 + z ** 2) * m
  }

  return sqrt(v.x ** 2 + v.y ** 2 + v.z ** 2)
}

declare var vec3_dist: (a: vec3, b: vec3) => number
{
  const spare = vec3()
  vec3_dist = (a: vec3, b: vec3): number => {
    vec3_sub(spare, a, b)
    return vec3_magnitude(spare)
  }
}

/*
{
  print(vec3_magnitude(vec3(1, 1, 1)))
  print(vec3_magnitude(vec3(2, 2, 2)))
  print(vec3_magnitude(vec3(3, 3, 3)))
  print(vec3_magnitude(vec3(200, 200, 200)))
  stop()
}
*/

function vec3_normalize(v: vec3): void {
  const m = vec3_magnitude(v)
  if (m === 0) return
  v.x /= m
  v.y /= m
  v.z /= m
}

/*
{
  const v = vec3(200, 200, 200)
  vec3_normalize(v)
  print(vec3_magnitude(v))
  stop()
}
*/

function vec3_lerp(out: vec3, a: vec3, b: vec3, t: number): void {
  const ax = a.x,
    ay = a.y,
    az = a.z
  const bx = b.x,
    by = b.y,
    bz = b.z
  out.x = lerp(ax, bx, t)
  out.y = lerp(ay, by, t)
  out.z = lerp(az, bz, t)
}

let vec3_mul_mat3: (out: vec3, v: vec3, m: mat3) => void
{
  const spare = vec3()
  vec3_mul_mat3 = function(out: vec3, v: vec3, m: mat3): void {
    spare.x = v.x
    spare.y = v.y
    spare.z = v.z
    out.x = vec3_dot(spare, m[0])
    out.y = vec3_dot(spare, m[1])
    out.z = vec3_dot(spare, m[2])
  }
}

function assert_vec3_equal(a: vec3, b: vec3): void {
  assert(a.x === b.x)
  assert(a.y === b.y)
  assert(a.z === b.z)
}

/*
{
  const a = vec3(1, 0, 0)
  const b = vec3(0, 1, 0)
  const out = vec3()
  vec3_cross(out, a, b)
  assert_vec3_equal(out, vec3(0, 0, 1))
  stop()
}
*/

function vec3_zero(v: vec3): void {
  v.x = 0
  v.y = 0
  v.z = 0
}

function vec3_assign(a: vec3, b: vec3): void {
  a.x = b.x
  a.y = b.y
  a.z = b.z
}

function mat3(): mat3 {
  return [vec3(), vec3(), vec3()]
}

// set matrix `m` to be a counterclockwise rotation of `a` around the x-axis.
// assume right-handed coordinates.
function mat3_rotate_x(m: mat3, a: number): void {
  m[0].x = 1
  m[0].y = 0
  m[0].z = 0

  m[1].x = 0
  m[1].y = cos(a)
  m[1].z = sin(a)

  m[2].x = 0
  m[2].y = -sin(a)
  m[2].z = cos(a)
}

/*
{
  const out = vec3()
  const v = vec3(-46, 0, -64)
  const m = mat3()

  mat3_rotate_x(m, 0)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(-46, 0, -64))

  mat3_rotate_x(m, 0.25)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(-46, 64, 0))

  mat3_rotate_x(m, 0.5)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(-46, 0, 64))

  mat3_rotate_x(m, 0.75)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(-46, -64, 0))
  stop()
}
*/

// set matrix `m` to be a counterclockwise rotation of `a`
// around the y-axis. assume right-handed coordinates.
function mat3_rotate_y(m: mat3, a: number): void {
  m[0].x = cos(a)
  m[0].y = 0
  m[0].z = -sin(a)

  m[1].x = 0
  m[1].y = 1
  m[1].z = 0

  m[2].x = sin(a)
  m[2].y = 0
  m[2].z = cos(a)
}

/*
{
  const out = vec3()
  const v = vec3(-46, 0, -64)
  const m = mat3()

  mat3_rotate_y(m, 0)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(-46, 0, -64))

  mat3_rotate_y(m, 0.25)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(-64, 0, 46))

  mat3_rotate_y(m, 0.5)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(46, 0, 64))

  mat3_rotate_y(m, 0.75)
  vec3_mul_mat3(out, v, m)
  assert_vec3_equal(out, vec3(64, 0, -46))
}
*/

/*
{
  const out = vec3()
  const v = vec3(-46, 0, -64)
  const m = mat3()

  mat3_rotate_y(m, 0.5)
  vec3_mul_mat3(out, v, m)

  mat3_rotate_x(m, 0.25)
  vec3_mul_mat3(out, out, m)

  assert_vec3_equal(out, vec3(46, -64, 0))
}
*/

/**
 * --> 2. data readers & drawing.
 */

let read_num: () => number
{
  const map_addr = 0x2000
  let offset = 0
  read_num = function(): number {
    const n = peek4(map_addr + offset)
    offset += 4
    return n
  }
}

function read_vec3(): vec3 {
  return vec3(read_num(), read_num(), read_num())
}

interface line {
  start_vec: vec3
  end_vec: vec3
  col: col
  start_screen: vec3
  end_screen: vec3
}

function read_lines(): Array<line> {
  const count = read_num()
  const lines: Array<line> = []

  for (let i = 0; i < count; i++) {
    add<line>(lines, {
      start_vec: read_vec3(),
      end_vec: read_vec3(),
      col: read_num(),
      start_screen: vec3(),
      end_screen: vec3(),
    })
  }

  return lines
}

function line_draw(l: line, c: cam): void {
  cam_project(c, l.start_screen, l.start_vec)
  cam_project(c, l.end_screen, l.end_vec)
  line(
    round(l.start_screen.x),
    round(l.start_screen.y),
    round(l.end_screen.x),
    round(l.end_screen.y),
    l.col
  )
}

interface polygon {
  points_world: Array<vec3>
  points_screen: Array<vec3>
  col: col
  cam: cam
}

function polygon(col: col, cam: cam, points: Array<vec3>): polygon {
  const points_screen: Array<vec3> = []
  for (let i = 0; i < points.length; i++) {
    add(points_screen, vec3())
  }

  return {
    points_world: points,
    points_screen: points_screen,
    col: col,
    cam: cam,
  }
}

function polygon_update(p: polygon): void {
  for (let i = 0; i < p.points_world.length; i++) {
    cam_project(p.cam, p.points_screen[i], p.points_world[i])
  }
}

interface NumberMap {
  [key: number]: number
}

/** !TupleReturn */
function polygon_edge(
  v1: vec3,
  v2: vec3,
  xl: NumberMap,
  xr: NumberMap,
  is_clockwise: boolean
): [number, number] {
  let x1 = v1.x
  let x2 = v2.x

  let fy1 = flr(v1.y)
  let fy2 = flr(v2.y)

  let t = (is_clockwise && xr) || xl

  if (fy1 === fy2) {
    if (fy1 < 0) return [0, 0]
    if (fy1 > 127) return [127, 127]
    const xmin = max(min(x1, x2), 0)
    const xmax = min(max(x1, x2), 127)
    xl[fy1] = (!xl[fy1] && xmin) || min(xl[fy1], xmin)
    xr[fy1] = (!xr[fy1] && xmax) || max(xr[fy1], xmax)
    return [fy1, fy1]
  }

  // ensure fy1 < fy2.
  if (fy1 > fy2) {
    let _

    _ = x1
    x1 = x2
    x2 = _

    _ = fy1
    fy1 = fy2
    fy2 = _

    t = (t === xl && xr) || xl
  }

  // for each scanline in range, compute left or right side.
  // we must use floored y, since we are computing sides for
  // integer y-offsets.
  const ys = max(fy1, 0)
  const ye = min(fy2, 127)
  const m = (x2 - x1) / (fy2 - fy1)
  for (let y = ys; y <= ye; y++) {
    t[y] = m * (y - fy1) + x1
  }

  return [ys, ye]
}

// note: polygon must be convex. concave polygons draw artifacts.
function polygon_draw(p: polygon): void {
  const points = p.points_screen
  const xl: NumberMap = {},
    xr: NumberMap = {}
  let ymin = 32767,
    ymax = -32768
  const is_clockwise = clockwise(points)

  for (let i = 0; i < points.length; i++) {
    const point = points[i]
    const next_point = points[(i + 1) % points.length]
    const [ys, ye] = polygon_edge(point, next_point, xl, xr, is_clockwise)
    ymin = min(ys, ymin)
    ymax = max(ye, ymax)
  }

  for (let y = ymin; y <= ymax; y++) {
    if (xl[y] && xr[y]) {
      rectfill(round(xl[y]), y, round(xr[y]), y, p.col)
    } else {
      print(y, 0, 0, 7)
      assert(false)
    }
  }
}

//// copy data from screen to spritesheet.
//// note: offset should be even.
//// note: odd x1 values will copy an extra column of pixels on the left.
//// example: if x1==5, then you will copy pixel 4 and pixel 5.
//function copy_to_spritesheet(
//  x1: number,
//  y1: number,
//  x2: number,
//  y2: number,
//  offset: number
//): void {
//  const width = x2 - x1 + 1
//  for (let i = y1; i <= y2; i++) {
//    // copy row by row.
//    memcpy(
//      (i - y1) * 64 + offset / 2, // one row of pixels is 64 bytes.
//      0x6000 + i * 64 + x1 / 2,
//      ceil(width / 2) + 1 // copy pixels, +1 column for good measure.
//    )
//  }
//}
//
//// (x1,y1) is the top-left corner of the shadow.
//function shadow_draw(
//  spx: number,
//  spy: number,
//  spw: number,
//  sph: number,
//  x1: number,
//  y1: number
//): void {
//  // bottom-right corner. never extends beyond bottom-right point.
//  const x2 = min(x1 + spw, 128)
//  const y2 = min(y1 + sph, 128)
//
//  const on_screen = !(false || x2 < 0 || x1 > 127 || y2 < 0 || y1 > 127)
//
//  if (!on_screen) {
//    return
//  }
//
//  const x1_min = max(x1, 0)
//  const y1_min = max(y1, 0)
//
//  const draw_width = x2 - x1_min
//  const draw_height = y2 - y1_min
//
//  // copy original area to spritesheet.
//  copy_to_spritesheet(x1_min, y1_min, x2, y2, 0)
//
//  // draw mask to screen.
//  // shadow is transparent, black part is not
//  palt(col.black, false)
//  palt(col.dark_blue, true)
//  sspr(spx, spy, spw, sph, x1, y1, spw, sph)
//
//  // copy original area with black border to spritesheet.
//  copy_to_spritesheet(x1_min, y1_min, x2, y2, 14)
//
//  // draw copied area to screen
//  palt()
//  sspr(
//    x1_min % 2,
//    0,
//    draw_width,
//    draw_height,
//    x1_min,
//    y1_min,
//    draw_width,
//    draw_height
//  )
//
//  // perform some palette swaps
//  pal(3, 1)
//  pal(6, 5)
//  pal(13, 1)
//
//  // draw original region with mask
//  // remember, black is transparent
//  sspr(
//    14 + (x1_min % 2),
//    0,
//    draw_width,
//    draw_height,
//    x1_min,
//    y1_min,
//    draw_width,
//    draw_height
//  )
//
//  // reset palette state
//  pal()
//}
//
//let player_draw: (p: player) => void
//{
//  const spare = vec3()
//  player_draw = function(p: player): void {
//    cam_project(p.cam, spare, p.pos)
//    shadow_draw(0, 8, 12, 7, round(spare.x), round(spare.y))
//    // pset(round(spare.x), round(spare.y), colors_pink)
//  }
//}

/**
 * --> 3. camera.
 */

interface cam {
  pos: vec3
  x_angle: number
  mx: mat3
  y_angle: number
  my: mat3
  dist: number
  fov: number
}

function cam(): cam {
  return {
    pos: vec3(),
    x_angle: 0,
    mx: mat3(),
    y_angle: 0,
    my: mat3(),
    dist: 7 * 10,
    fov: 150,
  }
}

function cam_project(c: cam, out: vec3, v: vec3): void {
  // world to view.
  vec3_sub(out, v, c.pos)

  // rotate vector around y-axis.
  mat3_rotate_y(c.my, -c.y_angle)
  vec3_mul_mat3(out, out, c.my)

  // rotate vector around x-axis.
  mat3_rotate_x(c.mx, -c.x_angle)
  vec3_mul_mat3(out, out, c.mx)

  // add orthographic part of perspective divide.
  // in a sense, this is a "field of view".
  out.z = out.z + c.fov

  // perform perspective divide.
  const perspective = out.z / c.dist
  out.x = perspective * out.x
  out.y = perspective * out.y

  // ndc to screen.
  out.x = out.x + 64
  out.y = -out.y + 64
}

/**
 * -->8 4. game.
 */

interface game {
  court_lines: Array<line>
  net_lines: Array<line>
  cam: cam
  court: polygon
  player: Player
  ball: Ball
  zero_vec: vec3
  post_rally_timer: number
  player_score: number
  opponent_score: number
}

function game(): game {
  const court_lines = read_lines()
  const net_lines = read_lines()

  const s = 6
  const c = cam()
  c.dist = 12 * s
  c.fov = 34 * s
  c.x_angle = -0.08
  c.pos.y = -0.5 * s

  const p = polygon(col.peach, c, [
    vec3(-3.8 * s, 0, -7.7 * s),
    vec3(-3.8 * s, 0, 7.7 * s),
    vec3(3.8 * s, 0, 7.7 * s),
    vec3(3.8 * s, 0, -7.7 * s),
  ])

  const b = ball(c)

  const game_instance = {
    court_lines: court_lines,
    net_lines: net_lines,
    cam: c,
    court: p,
    player: player(c, b),
    ball: b,
    zero_vec: vec3(),
    post_rally_timer: 0,
    player_score: 0,
    opponent_score: 0,
  }

  return game_instance
}

function game_update(g: game): void {
  polygon_update(g.court)
  player_update(g.player)
  ball_update(g.ball)

  // update post rally timer
  if (g.post_rally_timer > 0) {
    g.post_rally_timer -= 1
    printh('not working:' + g.post_rally_timer, 'test.log')
    if (g.post_rally_timer === 0) {
      next_game_state = game_state.serve
    }
  } else {
    printh('wtf', 'test.log')
  }

  // set timer
  if (
    current_game_state === game_state.playing &&
    next_game_state === game_state.post_rally
  ) {
    g.post_rally_timer = 3 * 60
  }

  if (
    // about to transition to post rally state
    current_game_state === game_state.playing &&
    next_game_state === game_state.post_rally
  ) {
    // TODO: check if ball is in valid hit region.
    if (
      g.ball.pos.x > -3.05 * 6 &&
      g.ball.pos.x < 3.05 * 6 &&
      g.ball.pos.z < 0 * 6 &&
      g.ball.pos.z > -6.7 * 6
    ) {
      // then we're in a valid hit region.
      // add to player score
      g.player_score += 1
    } else {
      g.opponent_score += 1
    }

    // TODO: display score
  }
}

type DrawFunction = (g: game) => void
let order: Array<[vec3, DrawFunction]> = []
function game_draw(g: game): void {
  polygon_draw(g.court)

  for (let i = 0; i < g.court_lines.length; i++) {
    const l = g.court_lines[i]
    line_draw(l, g.cam)
  }

  clear_order()
  insert_into_order(g.zero_vec, game_draw_net)
  insert_into_order(g.player.pos, game_draw_player)
  insert_into_order(g.ball.pos, game_draw_ball)

  for (let i = 0; i < order.length; i++) {
    order[i][1](g)
  }

  //print(current_game_state)
  //print(g.post_rally_timer)
  const str = g.player_score + ' - ' + g.opponent_score
  print(str, 64 - str.length * 2, 3, col.white)
}

function game_draw_net(g: game): void {
  for (let i = 0; i < g.net_lines.length; i++) {
    const l = g.net_lines[i]
    line_draw(l, g.cam)
  }
}
function game_draw_player(g: game): void {
  player_draw(g.player)
}
function game_draw_ball(g: game): void {
  ball_draw(g.ball)
}

function clear_order(): void {
  order = []
}

function insert_into_order(pos: vec3, draw_fn: (g: game) => void): void {
  for (let i = 0; i < order.length; i++) {
    const current = order[i]
    if (pos.z < current[0].z) {
      // move everything 1 over
      for (let j = order.length - 1; j >= i; j--) {
        order[j + 1] = order[j]
      }

      // then insert
      // TODO: memory allocation, not super important though
      order[i] = [pos, draw_fn]
      return
    }
  }
  add(order, [pos, draw_fn])
}

/**
 * --> 5. player.
 */

interface Player {
  scale: number
  pos: vec3
  vel: vec3
  vel60: vec3
  acc: vec3
  desired_speed: number
  screen_pos: vec3
  cam: cam
  ball: Ball
  spare: vec3
  up: vec3
  hit: boolean
  player_to_ball: vec3
  swing_time: number
}

function player(c: cam, b: Ball): Player {
  const meter = 6

  return {
    scale: meter,
    pos: vec3(-0.5 * meter, 0, 5 * meter),
    vel: vec3(),
    vel60: vec3(),
    acc: vec3(),
    desired_speed: 10 * meter,
    screen_pos: vec3(),
    cam: c,
    ball: b,
    spare: vec3(),
    up: vec3(0, 1, 0),
    hit: false,
    player_to_ball: vec3(),
    swing_time: 0,
  }
}

const meter_unit: number = 6
function player_update(p: Player): void {
  // temporary hit variable
  p.hit = false

  /**
   * Compute acceleration.
   *
   * Acceleration here is like "desired velocity".
   */

  vec3_zero(p.acc)
  if (btn(button.left)) p.acc.x -= p.desired_speed
  if (btn(button.right)) p.acc.x += p.desired_speed
  if (btn(button.up)) p.acc.z -= p.desired_speed
  if (btn(button.down)) p.acc.z += p.desired_speed

  /**
   * Normalize & scale acceleration.
   */

  vec3_normalize(p.acc)
  vec3_scale(p.acc, p.desired_speed)

  /**
   * Update velocity.
   */

  const t = 0.5
  vec3_lerp(p.vel, p.vel, p.acc, t)

  /**
   * Update position.
   */

  vec3_assign(p.vel60, p.vel)
  vec3_scale(p.vel60, 1 / 60)
  vec3_add(p.pos, p.pos, p.vel60)

  /**
   * Update screen position.
   */

  cam_project(p.cam, p.screen_pos, p.pos)

  /**
   * units.
   */

  const second = 60

  /**
   * TODO: handle ball serve
   */

  p.ball.is_kinematic = current_game_state === game_state.serve
  if (current_game_state === game_state.serve) {
    p.ball.pos.x = p.pos.x + 0.4 * meter_unit
    p.ball.pos.y = p.pos.y + 1.0 * meter_unit
    p.ball.pos.z = p.pos.z

    if (btn(button.z)) {
      // release ball
      p.ball.is_kinematic = false

      // give ball upward velocity
      p.ball.vel.x = 0
      p.ball.vel.y = 5 * meter_unit
      p.ball.vel.z = 0

      // change state to playing
      next_game_state = game_state.playing

      // set swing time
      p.swing_time = 1 * second
    }

    return
  }

  /**
   * Update swing state.
   */

  p.swing_time = max(p.swing_time - 1, 0)

  /**
   * Swing at ball.
   */

  const meter = 6

  // player's chest is ~1m above the ground
  vec3_sub(p.player_to_ball, p.ball.pos, p.pos)
  p.player_to_ball.y += 1 * meter
  if (
    vec3_magnitude(p.player_to_ball) < 2.5 * meter && // ball in range
    p.ball.pos.y > 0 && // ball is still in air
    p.swing_time < 0.1 && // not currently swinging
    btn(button.z) // pressed the swing button
  ) {
    // enter a swing state
    p.hit = true
    p.swing_time = 1 * second

    // TODO: consider different hit regions

    // TODO: handle right side lob
    // condition: below 1m
    // condition: x > 0.2
    if (
      p.ball.pos.y < 1 * meter &&
      p.player_to_ball.x > 0 * meter &&
      p.player_to_ball.z <= 1
    ) {
      printh('right side lob', 'test.log')
      // execute right side lob:
      // slap up vector into player_to_ball vector
      vec3_cross(p.spare, p.up, p.player_to_ball)
      // depending on ball's dist from 1m, add to vertical velocity
      p.spare.z -= 50
      p.spare.y += (1 * meter - p.ball.pos.y) * 5 + 50
      // add velocity to ball velocity
      vec3_add(p.ball.vel, p.ball.vel, p.spare)
      vec3_printh(p.spare)
    }

    // TODO: handle left side lob
    if (
      p.ball.pos.y < 1 * meter &&
      p.player_to_ball.x < 0 * meter &&
      p.player_to_ball.z <= 1
    ) {
      printh('left side lob', 'test.log')
      // execute right side lob:
      // slap up vector into player_to_ball vector
      vec3_cross(p.spare, p.player_to_ball, p.up)
      // depending on ball's dist from 1m, add to vertical velocity
      p.spare.z -= 50
      p.spare.y += (1 * meter - p.ball.pos.y) * 5 + 50
      // add velocity to ball velocity
      vec3_add(p.ball.vel, p.ball.vel, p.spare)
      vec3_printh(p.spare)
    }

    // TODO: handle left overhead hit
    if (
      p.ball.pos.y >= 1 * meter &&
      p.player_to_ball.z <= 1 &&
      p.player_to_ball.x < 0 * meter
    ) {
      printh('left overhead hit', 'test.log')
      vec3_cross(p.spare, p.player_to_ball, p.up)
      p.spare.z -= 50 * 3
      p.spare.y += 10
      //p.spare.y -= 10
      vec3_add(p.ball.vel, p.ball.vel, p.spare)
    }

    // TODO: handle right overhead hit
    if (
      p.ball.pos.y >= 1 * meter &&
      p.player_to_ball.z <= 1 &&
      p.player_to_ball.x > 0 * meter
    ) {
      printh('right overhead hit', 'test.log')
      vec3_cross(p.spare, p.up, p.player_to_ball)
      p.spare.z -= 50 * 3
      p.spare.y += 10
      vec3_add(p.ball.vel, p.ball.vel, p.spare)
    }
  }
}

function player_draw(p: Player): void {
  const width = 10
  const height = 25

  // draw shadow
  circfill(round(p.screen_pos.x), round(p.screen_pos.y), 3, col.dark_blue)

  rectfill(
    round(p.screen_pos.x - width / 2),
    round(p.screen_pos.y - height),
    round(p.screen_pos.x + width / 2),
    round(p.screen_pos.y),
    col.orange
  )

  //print('hit:')
  //print(p.hit)
}

/**
 * --> 6. ball.
 */

interface Ball {
  pos: vec3
  shadow_pos: vec3
  vel: vec3
  vel60: vec3
  acc: vec3
  acc60: vec3
  screen_pos: vec3
  screen_shadow_pos: vec3
  cam: cam
  is_kinematic: boolean
}

function ball(c: cam): Ball {
  const meter = 6

  return {
    pos: vec3(0, 3 * meter, 5 * meter),
    shadow_pos: vec3(),
    vel: vec3(0, 1 * meter, 0),
    vel60: vec3(),
    acc: vec3(0, -10 * meter, 0),
    acc60: vec3(),
    screen_pos: vec3(),
    screen_shadow_pos: vec3(),
    cam: c,
    is_kinematic: false,
  }
}

declare var ball_update: (b: Ball) => void
{
  const spare = vec3()
  ball_update = (b: Ball): void => {
    if (!b.is_kinematic && b.pos.y > 0) {
      // compute change in velocity for this frame.
      vec3_assign(spare, b.acc)
      vec3_scale(spare, 1 / 60)

      // apply change in velocity.
      vec3_add(b.vel, b.vel, spare)

      // compute change in position for this frame.
      vec3_assign(spare, b.vel)
      vec3_scale(spare, 1 / 60)

      // apply change in position.
      vec3_add(b.pos, b.pos, spare)
    }

    // bounds check.
    if (b.pos.y < 0) {
      b.pos.y = 0
      next_game_state = game_state.post_rally
    }

    // compute new screen position.
    cam_project(b.cam, b.screen_pos, b.pos)

    // compute new screen position for shadow
    vec3_assign(b.shadow_pos, b.pos)
    b.shadow_pos.y = 0
    cam_project(b.cam, b.screen_shadow_pos, b.shadow_pos)
  }
}

function ball_draw(b: Ball): void {
  circfill(
    round(b.screen_shadow_pos.x),
    round(b.screen_shadow_pos.y),
    1,
    col.dark_blue
  )
  circfill(round(b.screen_pos.x), round(b.screen_pos.y), 2, col.yellow)
  //print(b.is_kinematic)
  //vec3_print(b.pos)
  //vec3_print(b.vel)
  //vec3_print(b.acc)
}
