/// <reference path="../@types/pico8.d.ts">

/**
 * Configuration.
 */

// 1 meter === 6 world space units.
const meter: number = 6

// 1 second === 60 frames, since we're using `_update60`.
const second: number = 60

// Required score to reach a win state.
// TODO: Remove upon fleshing out scoring.
const win_score = 1

// Zero vector. Use it for z-sorting!
const zero_vec = { x: 0, y: 0, z: 0 }

/**
 * Color.
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

/**
 * Palette.
 */

enum palette {
  draw,
  screen,
}

/**
 * Button.
 */

enum button {
  left,
  right,
  up,
  down,
  z,
  x,
}

/**
 * Actor.
 */

interface Actor {
  update: (o: any) => void
  draw: (o: any) => void
}

/**
 * State.
 */

enum state {
  pre_serve, // "drop ball" to transition to "serving"
  serving, // "swing" to transition to "rally"
  rally,
  post_rally,
}

/**
 * Vec3.
 */

interface Vec3 {
  x: number
  y: number
  z: number
}

function vec3(x?: number, y?: number, z?: number): Vec3 {
  return {
    x: x || 0,
    y: y || 0,
    z: z || 0,
  }
}

function vec3_add(out: Vec3, a: Vec3, b: Vec3): void {
  const ax = a.x
  const ay = a.y
  const az = a.z

  const bx = b.x
  const by = b.y
  const bz = b.z

  out.x = ax + bx
  out.y = ay + by
  out.z = az + bz
}

function vec3_sub(out: Vec3, a: Vec3, b: Vec3): void {
  const ax = a.x
  const ay = a.y
  const az = a.z

  const bx = b.x
  const by = b.y
  const bz = b.z

  out.x = ax - bx
  out.y = ay - by
  out.z = az - bz
}

function vec3_mul(out: Vec3, a: Vec3, b: Vec3): void {
  out.x = a.x * b.x
  out.y = a.y * b.y
  out.z = a.z * b.z
}

function vec3_print(v: Vec3): void {
  print(v.x + ', ' + v.y + ', ' + v.z)
}

function vec3_printh(v: Vec3): void {
  printh(v.x + ', ' + v.y + ', ' + v.z, 'test.log')
}

function vec3_dot(a: Vec3, b: Vec3): number {
  return a.x * b.x + a.y * b.y + a.z * b.z
}

function vec3_cross(out: Vec3, a: Vec3, b: Vec3): void {
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

function vec3_scale(v: Vec3, c: number): void {
  v.x *= c
  v.y *= c
  v.z *= c
}

function vec3_magnitude(v: Vec3): number {
  if (v.x > 104 || v.y > 104 || v.z > 104) {
    const m = max(max(v.x, v.y), v.z)
    const x = v.x / m,
      y = v.y / m,
      z = v.z / m
    return sqrt(x ** 2 + y ** 2 + z ** 2) * m
  }

  return sqrt(v.x ** 2 + v.y ** 2 + v.z ** 2)
}

declare var vec3_dist: (a: Vec3, b: Vec3) => number
{
  const spare = vec3()
  vec3_dist = (a: Vec3, b: Vec3): number => {
    vec3_sub(spare, a, b)
    return vec3_magnitude(spare)
  }
}

function vec3_normalize(v: Vec3): void {
  const m = vec3_magnitude(v)
  if (m === 0) return
  v.x /= m
  v.y /= m
  v.z /= m
}

function vec3_lerp(out: Vec3, a: Vec3, b: Vec3, t: number): void {
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

let vec3_mul_mat3: (out: Vec3, v: Vec3, m: Mat3) => void
{
  const spare = vec3()
  vec3_mul_mat3 = function (out: Vec3, v: Vec3, m: Mat3): void {
    spare.x = v.x
    spare.y = v.y
    spare.z = v.z
    out.x = vec3_dot(spare, m[0])
    out.y = vec3_dot(spare, m[1])
    out.z = vec3_dot(spare, m[2])
  }
}

function assert_vec3_equal(a: Vec3, b: Vec3): void {
  assert(a.x === b.x)
  assert(a.y === b.y)
  assert(a.z === b.z)
}

function vec3_zero(v: Vec3): void {
  v.x = 0
  v.y = 0
  v.z = 0
}

function vec3_assign(a: Vec3, b: Vec3): void {
  a.x = b.x
  a.y = b.y
  a.z = b.z
}

/**
 * Mat3.
 */

type Mat3 = [Vec3, Vec3, Vec3]

function mat3(): Mat3 {
  return [vec3(), vec3(), vec3()]
}

// set matrix `m` to be a counterclockwise rotation of `a` around the x-axis.
// assume right-handed coordinates.
function mat3_rotate_x(m: Mat3, a: number): void {
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

// set matrix `m` to be a counterclockwise rotation of `a`
// around the y-axis. assume right-handed coordinates.
function mat3_rotate_y(m: Mat3, a: number): void {
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

/**
 * Math utils.
 */

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
function clockwise(points: Array<Vec3>): boolean {
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

/**
 * Readers.
 */

let read_num: () => number
{
  const map_addr = 0x2000
  let offset = 0
  read_num = function (): number {
    const n = peek4(map_addr + offset)
    offset += 4
    return n
  }
}

function read_vec3(): Vec3 {
  return vec3(read_num(), read_num(), read_num())
}

/**
 * Z-sorting.
 */

type OrderArray = Array<[Vec3, Actor]>

function insert_into(order: OrderArray, pos: Vec3, a: Actor): void {
  for (let i = 0; i < order.length; i++) {
    const current = order[i]
    if (pos.z < current[0].z) {
      // Move everything 1 over.
      for (let j = order.length - 1; j >= i; j--) {
        order[j + 1] = order[j]
      }

      // Insert.
      order[i] = [pos, a]
      return
    }
  }

  add(order, [pos, a])
}

type OrderFuncArray = Array<[Vec3, Function]>

function insert_into2(order: OrderFuncArray, pos: Vec3, a: Function): void {
  for (let i = 0; i < order.length; i++) {
    const current = order[i]
    if (pos.z < current[0].z) {
      // Move everything 1 over.
      for (let j = order.length - 1; j >= i; j--) {
        order[j + 1] = order[j]
      }

      // Insert.
      order[i] = [pos, a]
      return
    }
  }

  add(order, [pos, a])
}

/**
 * Reach.
 */

const reach_spare = vec3()
const reach_spare2 = vec3()

function reach(
  head: Vec3,
  tail: Vec3,
  target: Vec3,
  head_tail_len: number,
  constrain?: boolean // if true, head_tail_len is treated as a max
): void {
  // get stretched length
  vec3_sub(reach_spare, tail, target)
  const stretched_len = vec3_magnitude(reach_spare)

  // avoid division by zero
  if (stretched_len === 0) {
    return
  }

  // constrain head tail length if necessary
  if (constrain) {
    const len = vec3_dist(head, tail)
    head_tail_len = min(head_tail_len, len)
    head_tail_len = max(head_tail_len, 0.1 * meter)
  }

  // compute scale
  const scale = head_tail_len / stretched_len

  // set new head
  vec3_assign(head, target)

  // set new tail
  vec3_assign(tail, target)
  vec3_scale(reach_spare, scale)
  vec3_add(tail, tail, reach_spare)
}

/*
function reach2(
  head: Vec3,
  tail: Vec3,
  head_target: Vec3,
  tail_target: Vec3
): void {
  // Get stretched length.
  vec3_sub(reach_spare, tail_target, head_target)
  const stretched_len = vec3_magnitude(reach_spare)

  // Avoid division by zero.
  if (stretched_len === 0) {
    return
  }

  // Get `head_tail_len`.
  vec3_sub(reach_spare2, tail, head)
  const head_tail_len = vec3_magnitude(reach_spare2)

  // Compute scale.
  const scale = head_tail_len / stretched_len

  // Set new head.
  vec3_assign(head, head_target)

  // Set new tail.
  vec3_assign(tail, head_target)
  vec3_scale(reach_spare, scale)
  vec3_add(tail, tail, reach_spare)
}
*/

/**
 * Game loop.
 *
 * States:
 * - Menu (todo)
 * - Game
 */

let actors: Array<Actor>
let actors_obj: { [key: string]: Actor }

function _init(): void {
  /**
   * Read map data.
   */

  const court_lines = read_lines()
  const net_lines = read_lines()

  /**
   * Construct camera.
   */

  const c = cam()
  c.dist = 12 * meter
  c.fov = 34 * meter
  c.x_angle = -0.05
  c.pos.y = -0.5 * meter

  /**
   * Construct net.
   */

  const n = net(net_lines, c)

  /**
   * Construct court.
   */

  const crt = court(court_lines, c)

  /**
   * Construct ball.
   */

  const b = ball(c, n)

  b.pos.x = 1.5 * meter
  b.pos.y = 3.0 * meter
  b.pos.z = 3 * meter

  b.vel.y = 5 * meter

  /**
   * Construct game.
   */

  const g = game(crt, b)

  /**
   * Construct player.
   */

  const player_user = player(
    c,
    -0.5 * meter,
    0,
    5 * meter,
    player_keyboard_input,
    -1,
    g,
    true,
    player_side.left
  )

  /**
   * Initialize actors.
   */

  // Ball should come after Players to avoid lag.
  // Game should come first, because it holds
  // current game state.
  actors = [g, c, n, crt, player_user, b]

  actors_obj = {
    camera: c,
    net: n,
    court: crt,
    game: g,
    player: player_user,
    ball: b,
  }
}

function _update60(): void {
  for (let i = 0; i < actors.length; i++) {
    const a = actors[i]
    a.update(a)
  }
}

function _draw(): void {
  /**
   * Clear screen.
   */

  cls(col.dark_purple)

  /**
   * Do z-sorting.
   */

  const order: OrderArray = []
  insert_into(order, zero_vec, actors_obj.net)
  insert_into(order, (actors_obj.player as Player).pos, actors_obj.player)
  insert_into(order, (actors_obj.ball as Ball).pos, actors_obj.ball)

  /**
   * Draw.
   */

  // Draw court first.
  const court = actors_obj.court
  court.draw(court)

  // Draw z-sorted actors.
  for (let i = 0; i < order.length; i++) {
    const a = order[i][1]
    a.draw(a)
  }

  // Draw game last.
  const game = actors_obj.game
  game.draw(game)

  // print cpu
  // print(stat(1), 0, 0)
}

/**
 * Line.
 */

interface line {
  start_vec: Vec3
  end_vec: Vec3
  col: col
  start_screen: Vec3
  end_screen: Vec3
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

function line_draw(l: line, c: Camera): void {
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

/**
 * Polygon.
 */

interface polygon {
  points_world: Array<Vec3>
  points_screen: Array<Vec3>
  col: col
  cam: Camera
}

function polygon(col: col, cam: Camera, points: Array<Vec3>): polygon {
  const points_screen: Array<Vec3> = []
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
  v1: Vec3,
  v2: Vec3,
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

  // For each scanline in range, compute left or right side.
  // We must use floored y, since we are computing sides for
  // integer y-offsets.
  const ys = max(fy1, 0)
  const ye = min(fy2, 127)
  const m = (x2 - x1) / (fy2 - fy1)
  for (let y = ys; y <= ye; y++) {
    t[y] = m * (y - fy1) + x1
  }

  return [ys, ye]
}

// Note: polygon must be convex. Concave polygons draw artifacts.
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

/**
 * Camera.
 */

interface Camera extends Actor {
  pos: Vec3
  x_angle: number
  mx: Mat3
  y_angle: number
  my: Mat3
  dist: number
  fov: number
}

function cam(): Camera {
  return {
    pos: vec3(),
    x_angle: 0,
    mx: mat3(),
    y_angle: 0,
    my: mat3(),
    dist: 7 * 10,
    fov: 150,
    update: cam_update,
    draw: cam_draw,
  }
}

function cam_update(_c: Camera): void { }

function cam_draw(_c: Camera): void { }

function cam_project(c: Camera, out: Vec3, v: Vec3): void {
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
 * Game.
 */

interface Game extends Actor {
  court: Court
  ball: Ball

  post_rally_timer: number
  left_side_score: number
  right_side_score: number

  state: state
  next_state: state
  server?: Player

  mouse_x: number
  mouse_y: number
}

function game(c: Court, b: Ball): Game {
  return {
    update: game_update,
    draw: game_draw,
    court: c,
    ball: b,
    post_rally_timer: 0,
    left_side_score: 0,
    right_side_score: 1,
    state: state.pre_serve,
    next_state: state.pre_serve,
    mouse_x: 0,
    mouse_y: 0,
  }
}

function game_update(g: Game): void {
  // Update state. This should come first.
  g.state = g.next_state

  // Update mouse input. This is temporary.
  g.mouse_x = stat(32)
  g.mouse_y = stat(33)
}

function game_draw(g: Game): void {
  /**
   * Draw score.
   */

  const str = g.left_side_score + ' - ' + g.right_side_score
  print(str, 64 - str.length * 2, 3, col.white)
}

/**
 * Player side.
 *
 * (The sides are kinda arbitrary.)
 */

enum player_side {
  left,
  right,
}

/**
 * Player stance.
 *
 * Assume that all players are righties.
 */

enum player_stance {
  forehand,
  backhand,
}

/**
 * Swing state.
 */

enum swing_state {
  idle,
  winding,
  swing,
}

/**
 * Player.
 */

interface Player extends Actor {
  // Dependencies.
  cam: Camera
  game: Game

  // Position.
  pos: Vec3
  screen_pos: Vec3

  // Velocity.
  vel: Vec3
  vel60: Vec3

  // Acceleration.
  acc: Vec3
  desired_speed: number
  desired_speed_lerp_factor: number
  input_method: (p: Player) => void

  // Player side.
  //
  // The sides are kinda arbitrary, but are still named
  // "left" and "right".
  //
  // For 1 player, the player is on the "left" side.
  player_side: player_side

  // Is the player facing the -z, or z direction?
  player_dir: -1 | 1

  // Forehand or backhand?
  player_stance: player_stance

  // Swing-related properties.
  swing_state: swing_state
  swing_frames: number // This is kind of like power.
  swing_power: number // Snapshot of swing_frames when transitioning into swing state.

  // Arm.
  arm_points: [Vec3, Vec3, Vec3, Vec3]
  arm_screen_points: [Vec3, Vec3, Vec3, Vec3]

  // Temporary target.
  target: Vec3

  // Temporary.
  ball_hit: boolean
}

function player(
  c: Camera,
  x: number,
  y: number,
  z: number,
  input_method: (p: Player) => void,
  player_dir: -1 | 1,
  game: Game,
  is_initial_server: boolean,
  player_side: player_side,
): Player {
  const points: [Vec3, Vec3, Vec3, Vec3] = [vec3(), vec3(), vec3(), vec3()]
  const more_points: [Vec3, Vec3, Vec3, Vec3] = [vec3(), vec3(), vec3(), vec3()]

  const p: Player = {
    pos: vec3(x, y, z),
    vel: vec3(),
    vel60: vec3(),
    acc: vec3(),
    desired_speed: 6.5 * meter,
    desired_speed_lerp_factor: 0.5,
    screen_pos: vec3(),
    cam: c,
    input_method: input_method,
    player_dir: player_dir,
    game: game,
    update: player_update,
    draw: player_draw,
    player_side: player_side,
    player_stance: player_stance.forehand,
    swing_state: swing_state.idle,
    arm_points: points,
    arm_screen_points: more_points,
    target: vec3(),
    swing_frames: 0,
    ball_hit: false,
    swing_power: 0,
  }

  if (is_initial_server) {
    game.server = p
  }

  return p
}

function player_move(p: Player): void {
  // Compute acceleration.

  vec3_zero(p.acc)
  p.input_method(p)

  // Compute player stance.

  if (p.acc.x > 0) {
    p.player_stance = player_stance.forehand
  }

  if (p.acc.x < 0) {
    p.player_stance = player_stance.backhand
  }

  // Normalize & scale acceleration.

  vec3_normalize(p.acc)
  vec3_scale(p.acc, p.desired_speed)

  // Update velocity.

  vec3_lerp(p.vel, p.vel, p.acc, p.desired_speed_lerp_factor)

  // Update position.

  vec3_assign(p.vel60, p.vel)
  vec3_scale(p.vel60, 1 / 60)
  vec3_add(p.pos, p.pos, p.vel60)

  // Bounds checking.

  if (p.game.state === state.pre_serve) {
    const [player_score, opponent_score] = get_player_score(p)
    if (p.game.server === p) {
      if (player_score % 2 === 0) {
        player_bounds_check(p, p.game.court.singles_even_bounds)
      } else {
        player_bounds_check(p, p.game.court.singles_odd_bounds)
      }
    } else {
      if (opponent_score % 2 === 0) {
        player_bounds_check(p, p.game.court.singles_odd_bounds)
      } else {
        player_bounds_check(p, p.game.court.singles_even_bounds)
      }
    }
  }

  // Update screen position.

  cam_project(p.cam, p.screen_pos, p.pos)
}

// Spare vectors.
const chest_spare = vec3()
const target_spare = vec3()
const arm_points_spare = vec3()

// Offsets relative to `p.pos`.
const arm_socket_offset = vec3(0.1722 * meter, 0.9227 * meter, -0.1627 * meter)
const wrist_offset = vec3(0.5525 * meter, 0.7729 * meter, -0.4026 * meter)
const racket_head_offset = vec3(0.25 * meter, 0.75 * meter, -1 * meter)
const chest_offset = vec3(0, 1 * meter, 0)
const idle_target_offset = vec3(1.15 * meter, 1 * meter, 0)

function player_move_arm(p: Player): void {
  // References.
  const ball = p.game.ball.pos
  const chest = p.arm_points[0]
  const arm_socket = p.arm_points[1]
  const wrist = p.arm_points[2]
  const racket_head = p.arm_points[3]

  // Lengths.
  const chest_to_arm_socket = 0.25 * meter
  const arm_socket_to_wrist = 0.75 * meter
  const wrist_to_racket_head = 0.67 * meter

  // Compute distance between chest and ball.
  vec3_add(chest_spare, p.pos, chest_offset)
  const dist_to_ball = vec3_dist(ball, chest_spare) / meter
  const near_ball = dist_to_ball < 0.5 * meter

  // Constants.
  const min_swing_frames = -50
  const max_swing_frames = 40
  const idle_speed = 5
  const winding_speed = 5
  const swing_speed = -20
  const dist_per_frame = .06 * meter
  const swing_power_max = 80

  // State transitions.
  if (p.swing_state === swing_state.idle && btn(button.x)) {
    p.swing_state = swing_state.winding
  }
  if (p.swing_state === swing_state.winding && !btn(button.x)) {
    p.swing_state = swing_state.swing
  }
  if (p.swing_state === swing_state.swing && p.swing_frames === min_swing_frames) {
    p.swing_state = swing_state.idle
  }

  // Update swing frames.
  if (p.swing_state === swing_state.idle) {
    p.swing_frames = min(p.swing_frames + idle_speed, 0)
    p.swing_power = 0
  }
  if (p.swing_state === swing_state.winding) {
    p.swing_frames = min(p.swing_frames + winding_speed, max_swing_frames)
    p.swing_power = min(p.swing_power + 2, swing_power_max)
  }
  if (p.swing_state === swing_state.swing) {
    p.swing_frames = max(p.swing_frames + swing_speed, min_swing_frames)
  }

  if (near_ball || (p.swing_state !== swing_state.idle || p.swing_frames !== 0)) {
    // Then reach for the ball, keeping in mind the offset for swing frames.

    // Remember to not alter `ball` vector.
    if (near_ball) {
      // Target is ball.
      vec3_assign(target_spare, ball)

      // Convert target to local space.
      vec3_sub(target_spare, target_spare, p.pos)
    } else {
      // Target is "idle target offset", which is already in local space.
      vec3_assign(target_spare, idle_target_offset)
    }

    // Offset target.
    target_spare.z += -p.player_dir * dist_per_frame * p.swing_frames

    // Lerp from racket_head to target.
    vec3_lerp(target_spare, racket_head, target_spare, 0.2)

    // Reach for target.
    reach(racket_head, wrist, target_spare, wrist_to_racket_head)
    reach(wrist, arm_socket, wrist, arm_socket_to_wrist, true)
    reach(arm_socket, chest, arm_socket, chest_to_arm_socket)

    // Reverse reach for chest anchor.
    reach(chest, arm_socket, chest_offset, chest_to_arm_socket)
    reach(arm_socket, wrist, arm_socket, arm_socket_to_wrist, true)
    reach(wrist, racket_head, wrist, wrist_to_racket_head)

    // If we hit the ball (roughly speaking), affect the ball state.
    vec3_add(chest_spare, p.pos, racket_head)
    const ball_hit = vec3_dist(chest_spare, ball) < 0.5 * meter
    if (ball_hit && p.swing_state === swing_state.swing) {
      p.game.ball.vel.z = p.player_dir * abs(p.swing_power) * meter
    }
  } else {
    // Then lerp towards idle configuration, keeping in mind the offset for swing frames.

    // Move arm_socket.
    vec3_lerp(arm_socket, arm_socket, arm_socket_offset, 0.2)

    // Move wrist.
    vec3_lerp(wrist, wrist, wrist_offset, 0.2)

    // Move racket_head.
    vec3_lerp(racket_head, racket_head, racket_head_offset, 0.2)

    // The dist between wrist and racket_head
    // isn't necessarily constant here, but it's
    // fine for the purposes of this animation.
  }

  // Update screen coordinates.
  // Remember to convert arm_points into world space first!
  const len = p.arm_points.length
  for (let i = 0; i < len; i++) {
    vec3_add(arm_points_spare, p.pos, p.arm_points[i])
    cam_project(p.cam, p.arm_screen_points[i], arm_points_spare)
  }
}

function player_keyboard_input(p: Player): void {
  if (btn(button.left)) p.acc.x -= p.desired_speed
  if (btn(button.right)) p.acc.x += p.desired_speed
  if (btn(button.up)) p.acc.z -= p.desired_speed
  if (btn(button.down)) p.acc.z += p.desired_speed
}

// Return [player score, opponent score].
/** !TupleReturn */
function get_player_score(p: Player): [number, number] {
  const side = p.player_side
  let player_score: number
  let opponent_score: number
  if (side === player_side.left) {
    player_score = p.game.left_side_score
    opponent_score = p.game.right_side_score
  } else {
    player_score = p.game.right_side_score
    opponent_score = p.game.left_side_score
  }
  return [player_score, opponent_score]
}

function player_ai(p: Player): void {
  // Move in direction of ball.
  vec3_zero(p.acc)

  // Compute `player_to_ball` vector.

  // If ball is in range, swing.
}

function player_bounds_check(p: Player, bounds: [Vec3, Vec3]): void {
  const upper_left_bound = bounds[0]
  const lower_right_bound = bounds[1]

  if (p.pos.x < upper_left_bound.x) {
    p.pos.x = upper_left_bound.x
  }

  if (p.pos.x > lower_right_bound.x) {
    p.pos.x = lower_right_bound.x
  }

  if (p.player_dir === -1 && p.pos.z < upper_left_bound.z) {
    p.pos.z = upper_left_bound.z
  }

  if (p.player_dir === -1 && p.pos.z > lower_right_bound.z) {
    p.pos.z = lower_right_bound.z
  }

  if (p.player_dir === 1 && p.pos.z > -upper_left_bound.z) {
    p.pos.z = -upper_left_bound.z
  }

  if (p.player_dir === 1 && p.pos.z < -lower_right_bound.z) {
    p.pos.z = -lower_right_bound.z
  }
}

function player_move_ball(p: Player): void {
  // Make ball kinematic.
  p.game.ball.is_kinematic = true

  // Update ball's position.
  vec3_assign(p.game.ball.pos, p.pos)
  p.game.ball.pos.y += 1 * meter

  /**
   * Place ball on player's forehand or backhand side.
   */

  if (p.player_stance === player_stance.forehand) {
    p.game.ball.pos.x += 0.5 * meter
  }

  if (p.player_stance === player_stance.backhand) {
    p.game.ball.pos.x -= 0.5 * meter
  }

  p.game.ball.pos.z += p.player_dir * 0.1 * meter
}

function player_pre_serve(p: Player): void {
  /*
  if (btn(button.left)) {
    p.target.x -= 0.3
  }
  if (btn(button.right)) {
    p.target.x += 0.3
  }
  if (btn(button.up)) {
    p.target.y += 0.3
  }
  if (btn(button.down)) {
    p.target.y -= 0.3
  }
  if (btn(button.z)) {
    p.target.z -= 0.3
  }
  if (btn(button.x)) {
    p.target.z += 0.3
  }
  */

  // Move player.
  player_move(p)

  // Move the arm.
  player_move_arm(p)
}

function player_update(p: Player): void {
  if (p.game.state === state.pre_serve) {
    player_pre_serve(p)
    return
  }

  if (p.game.state === state.serving) {
    return
  }

  if (p.game.state === state.rally) {
    return
  }

  if (p.game.state === state.post_rally) {
    return
  }

  return
}

function player_draw(p: Player): void {

  /**
   * Constants.
   */

  const width = 10
  const height = 25

  /**
   * Unsorted.
   */

  // Declare some spare vectors.
  const screen = vec3()
  const target = vec3()

  /**
   * Sorted.
   */

  // Declare vars for arm joints.
  const chest = p.arm_screen_points[0]
  const socket = p.arm_screen_points[1]
  const hand = p.arm_screen_points[2]
  const racket_head = p.arm_screen_points[3]

  // Do z-sorting.
  const orderArray: OrderFuncArray = []

  // Chest insert.
  insert_into2(orderArray, chest, function (): void {
    // Draw shadow.
    circfill(round(p.screen_pos.x), round(p.screen_pos.y), 3, col.dark_blue)

    // Draw player.
    rectfill(
      round(p.screen_pos.x - width / 2),
      round(p.screen_pos.y - height),
      round(p.screen_pos.x + width / 2),
      round(p.screen_pos.y),
      col.orange
    )
  })

  // Socket insert.
  insert_into2(orderArray, socket, function (): void {
    // circfill(socket.x, socket.y, 1, col.peach)
    line(socket.x, socket.y, hand.x, hand.y, col.peach)
  })

  // Hand insert.
  insert_into2(orderArray, hand, function (): void {
    circfill(hand.x, hand.y, 1, col.peach)
    line(hand.x, hand.y, racket_head.x, racket_head.y, col.red)
  })

  // Racket head insert.
  insert_into2(orderArray, racket_head, function (): void {
    // Find shadow position in world space.
    vec3_add(target, p.pos, chest_offset)
    vec3_add(target, target, p.arm_points[3])
    target.y = 0

    // Find screen space coordinates.
    cam_project(p.cam, screen, target)

    // Draw shadow.
    circfill(screen.x, screen.y, 2, col.dark_blue)

    // Draw racket head.
    circfill(racket_head.x, racket_head.y, 3, col.white)
  })

  // Draw ordered player body parts.
  for (let i = 0; i < orderArray.length; i++) {
    orderArray[i][1]()
  }

  // Debug.
  // print(p.swing_power)
  // print(p.swing_state)
}

/**
 * Ball.
 */

interface Ball extends Actor {
  // Position.
  pos: Vec3
  shadow_pos: Vec3
  screen_pos: Vec3
  screen_shadow_pos: Vec3

  // Velocity.
  vel: Vec3

  // Acceleration.
  acc: Vec3
  // Drag.
  drag: Vec3

  // Dependencies.
  cam: Camera
  net: Net

  // State.
  is_kinematic: boolean

  // Spare vec3's for computation.
  spare: Vec3
  next_pos: Vec3
  spare2: Vec3
}

function ball(c: Camera, n: Net): Ball {
  return {
    pos: vec3(0, 3 * meter, 5 * meter),
    shadow_pos: vec3(),
    vel: vec3(0, 1 * meter, 0),
    acc: vec3(0, -10 * meter, 0),
    drag: vec3(0, 0, 0),
    screen_pos: vec3(),
    screen_shadow_pos: vec3(),
    cam: c,
    is_kinematic: false,
    net: n,
    update: ball_update,
    draw: ball_draw,
    spare: vec3(),
    spare2: vec3(),
    next_pos: vec3(),
  }
}

function ball_update(b: Ball): void {
  if (!b.is_kinematic && b.pos.y > 0) {
    // Store velocity in spare. Normalize.
    vec3_assign(b.spare2, b.vel)
    vec3_normalize(b.spare2)

    // Compute drag force for this frame. Note that we don't divide by 60, rather we use a constant.
    // TODO: This might overflow.
    let speed = vec3_magnitude(b.vel)
    const c = 0.01
    speed = c * speed * speed
    vec3_scale(b.spare2, -speed)

    // Combine forces.
    // Compute change in velocity for this frame.
    vec3_add(b.spare, b.acc, b.spare2)
    // vec3_assign(b.spare, b.acc)
    vec3_scale(b.spare, 1 / 60)

    // Apply change in velocity.
    vec3_add(b.vel, b.vel, b.spare)

    // Compute change in position for this frame.
    vec3_assign(b.spare, b.vel)
    vec3_scale(b.spare, 1 / 60)

    // Compute next position.
    vec3_zero(b.next_pos)
    vec3_add(b.next_pos, b.pos, b.spare)

    // Check if there is an intersection.
    const [intersects, intersection] = net_collides_with(
      b.net,
      b.pos,
      b.next_pos
    )

    if (intersects && intersection) {
      // Set ball's position to intersection point.
      b.pos.x = intersection.x
      b.pos.y = intersection.y

      if (b.pos.z > 0) {
        // Set position to slightly in front of net.
        b.pos.z = 1
      } else if (b.pos.z < 0) {
        // Set position to slightly behind net.
        b.pos.z = -1
      } else {
        // Throw exception, this should mostly never happen.
        assert(false)
      }

      // Reverse z-component of velocity, scaled down a little.
      b.vel.z = -b.vel.z
      vec3_scale(b.vel, 0.1)
    } else {
      // Apply change in position.
      vec3_add(b.pos, b.pos, b.spare)
    }
  }

  // Bounds check.
  if (b.pos.y < 0) {
    b.pos.y = 0
  }

  // Compute new screen position.
  cam_project(b.cam, b.screen_pos, b.pos)

  // Compute new screen position for shadow.
  vec3_assign(b.shadow_pos, b.pos)
  b.shadow_pos.y = 0
  cam_project(b.cam, b.screen_shadow_pos, b.shadow_pos)
}

function ball_draw(b: Ball): void {
  // draw ball shadow
  circfill(
    round(b.screen_shadow_pos.x),
    round(b.screen_shadow_pos.y),
    1,
    col.dark_blue
  )

  // draw ball
  circfill(round(b.screen_pos.x), round(b.screen_pos.y), 2, col.green)

  // vec3_print(b.vel)
}

/**
 * Net.
 */

interface Net extends Actor {
  lines: Array<line>
  net_top: number
  net_bottom: number
  left_pole: number
  right_pole: number
  cam: Camera
}

function net(lines: Array<line>, cam: Camera): Net {
  return {
    lines: lines,
    net_top: 1.5 * meter,
    net_bottom: 0.9 * meter,
    left_pole: -2.95 * meter,
    right_pole: 2.95 * meter,
    cam: cam,
    update: net_update,
    draw: net_draw,
  }
}

function net_update(_n: Net): void { }

function net_draw(n: Net): void {
  for (let i = 0; i < n.lines.length; i++) {
    const l = n.lines[i]
    line_draw(l, n.cam)
  }
}

/** !TupleReturn */
function net_collides_with(
  n: Net,
  prev_pos: Vec3,
  next_pos: Vec3
): [true, Vec3] | [false, null] {
  if (
    !((prev_pos.z > 0 && next_pos.z < 0) || (prev_pos.z < 0 && next_pos.z > 0))
  ) {
    return [false, null]
  }

  // z = mx + z0, set z to 0 and solve for x
  const z0 = prev_pos.z
  let x_at_net: number
  if (next_pos.x - prev_pos.x < 0.1) {
    x_at_net = prev_pos.x
  } else {
    const m = (next_pos.z - prev_pos.z) / (next_pos.x - prev_pos.x)
    const diff = -z0 / m
    x_at_net = prev_pos.x + diff
  }
  const x_in_range = n.left_pole <= x_at_net && x_at_net <= n.right_pole
  if (!x_in_range) {
    return [false, null]
  }

  // z = m2*y + z0, set z to 0 and solve for y
  const m2 = (next_pos.z - prev_pos.z) / (next_pos.y - prev_pos.y)
  const y = -z0 / m2
  const y_at_net = prev_pos.y + y
  const y_in_range = n.net_bottom <= y_at_net && y_at_net < n.net_top
  if (!y_in_range) {
    return [false, null]
  }

  return [true, vec3(x_at_net, y_at_net, 0)]
}

/**
 * Court.
 */

interface Court extends Actor {
  cam: Camera
  court_lines: Array<line>
  poly: polygon
  singles_even_bounds: [Vec3, Vec3]
  singles_odd_bounds: [Vec3, Vec3]
}

function court(court_lines: Array<line>, cam: Camera): Court {
  const p = polygon(col.dark_green, cam, [
    vec3(-3.8 * meter, 0, -7.7 * meter),
    vec3(-3.8 * meter, 0, 7.7 * meter),
    vec3(3.8 * meter, 0, 7.7 * meter),
    vec3(3.8 * meter, 0, -7.7 * meter),
  ])

  const singles_even_bounds: [Vec3, Vec3] = [
    vec3(0, 0, 1.98 * meter),
    vec3(2.59 * meter, 0, 6.7 * meter),
  ]

  const singles_odd_bounds: [Vec3, Vec3] = [
    vec3(-2.59 * meter, 0, 1.98 * meter),
    vec3(0, 0, 6.7 * meter),
  ]

  return {
    court_lines: court_lines,
    cam: cam,
    update: court_update,
    draw: court_draw,
    poly: p,
    singles_even_bounds: singles_even_bounds,
    singles_odd_bounds: singles_odd_bounds,
  }
}

function court_update(c: Court): void {
  polygon_update(c.poly)
}

function court_draw(c: Court): void {
  polygon_draw(c.poly)

  for (let i = 0; i < c.court_lines.length; i++) {
    const l = c.court_lines[i]
    line_draw(l, c.cam)
  }
}
