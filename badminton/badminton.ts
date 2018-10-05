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
  out.x = a.x + b.x
  out.y = a.y + b.y
  out.z = a.z + b.z
}

function vec3_sub(out: Vec3, a: Vec3, b: Vec3): void {
  out.x = a.x - b.x
  out.y = a.y - b.y
  out.z = a.z - b.z
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

/**
 * Reach.
 */

const reach_spare = vec3()
/** !TupleReturn */
function reach(
  head: Vec3,
  tail: Vec3,
  target: Vec3,
  head_tail_len: number
): [Vec3, Vec3] {
  // stretched vec
  const tail_to_target = vec3_sub(reach_spare, tail, target)
  const stretched_len = vec3_magnitude(reach_spare)

  // compute scale
  const scale = head_tail_len / stretched_len

  return [
    { x: target.x, y: target.y, z: target.z },
    {
      x: target.x + reach_spare.x * scale,
      y: target.y + reach_spare.y * scale,
      z: target.z + reach_spare.z * scale,
    },
  ]
}

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

  /**
   * Construct game.
   */

  const g = game(crt, b)

  /**
   * Construct player.
   */

  const player_user = player(
    c,
    b,
    -0.5 * meter,
    0,
    5 * meter,
    player_keyboard_input,
    vec3(-2.59 * meter, 0, 0.5 * meter),
    vec3(2.59 * meter, 0, 6.7 * meter),
    -1,
    g,
    true,
    player_side.left,
    player_human_swing,
    player_human_wind_up
  )

  /**
   * Construct opponent.
   */

  const opponent = player(
    c,
    b,
    -0.5 * meter,
    0,
    -5 * meter,
    player_ai,
    vec3(-2.59 * meter, 0, -6.7 * meter),
    vec3(2.59 * meter, 0, -0.5 * meter),
    1,
    g,
    false,
    player_side.right,
    player_cpu_swing,
    player_cpu_wind_up
  )

  /**
   * Initialize actors.
   */

  // Ball should come after Players to avoid lag.
  // Game should come first, because it holds
  // current game state.
  actors = [g, c, n, crt, player_user, opponent, b]

  actors_obj = {
    camera: c,
    net: n,
    court: crt,
    ball: b,
    game: g,
    player: player_user,
    opponent: opponent,
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
  insert_into(order, (actors_obj.opponent as Player).pos, actors_obj.opponent)
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

function cam_update(c: Camera): void { }

function cam_draw(c: Camera): void { }

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

enum PlayerStance {
  Forehand,
  Backhand,
}

/**
 * Swing state.
 */

enum SwingState {
  Idle,
  Winding,
}

/**
 * Player.
 */

interface Player extends Actor {
  // Dependencies.
  cam: Camera
  ball: Ball // Deprecated.
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
  input_method: (p: Player) => void

  // Player side.
  //
  // The sides are kinda arbitrary, but are still named
  // "left" and "right".
  player_side: player_side

  // Is the player facing the -z, or z direction?
  player_dir: -1 | 1

  // Forehand or backhand?
  player_stance: PlayerStance

  // Swing-related properties.
  swing_state: SwingState
  wind_up_condition: (p: Player) => boolean
  swing2_condition: (p: Player) => boolean
  swing_power: number

  // Exploratory.
  arm_points: [Vec3, Vec3, Vec3]
  arm_screen_points: [Vec3, Vec3, Vec3]

  // Spare vectors.
  spare: Vec3
  up: Vec3
  player_to_ball: Vec3
}

function player(
  c: Camera,
  b: Ball,
  x: number,
  y: number,
  z: number,
  input_method: (p: Player) => void,
  upper_left_bound: Vec3,
  lower_right_bound: Vec3,
  player_dir: -1 | 1,
  game: Game,
  is_initial_server: boolean,
  player_side: player_side,
  swing_condition: (p: Player) => boolean,
  wind_up_condition: (p: Player) => boolean
): Player {
  const points: [Vec3, Vec3, Vec3] = [vec3(), vec3(), vec3()]
  const more_points: [Vec3, Vec3, Vec3] = [vec3(), vec3(), vec3()]

  const p = {
    pos: vec3(x, y, z),
    vel: vec3(),
    vel60: vec3(),
    acc: vec3(),
    desired_speed: 10 * meter,
    screen_pos: vec3(),
    cam: c,
    ball: b,
    spare: vec3(),
    up: vec3(0, 1, 0),
    player_to_ball: vec3(),
    swing_time: 0,
    input_method: input_method,
    player_dir: player_dir,
    swing_condition: swing_condition,
    game: game,
    update: player_update,
    draw: player_draw,
    player_side: player_side,
    player_stance: PlayerStance.Forehand,
    swing_state: SwingState.Idle,
    swing2_condition: swing_condition,
    wind_up_condition: wind_up_condition,
    arm_points: points,
    arm_screen_points: more_points,
    swing_power: 0,
  }

  if (is_initial_server) {
    game.server = p
  }

  return p
}

function player_human_wind_up(p: Player): boolean {
  return false
}

function player_human_swing(p: Player): boolean {
  return false
}

function player_cpu_wind_up(p: Player): boolean {
  return false
}

function player_cpu_swing(p: Player): boolean {
  return false
}

function player_keyboard_input(p: Player): void {
  if (btn(button.left)) p.acc.x -= p.desired_speed
  if (btn(button.right)) p.acc.x += p.desired_speed
  if (btn(button.up)) p.acc.z -= p.desired_speed
  if (btn(button.down)) p.acc.z += p.desired_speed
}

function player_ai(p: Player): void {
  /**
   * Move in direction of ball.
   */

  vec3_zero(p.acc)

  /**
   * Compute `player_to_ball` vector.
   */

  /**
   * If ball is in range, swing.
   */
}

function player_swing(p: Player): void {
  // TODO.
}

function player_move(p: Player): void {
  /**
   * Compute acceleration.
   *
   * Acceleration here is like "desired velocity".
   */

  vec3_zero(p.acc)
  // p.input_method(p)

  /**
   * Compute player stance.
   */

  if (p.acc.x > 0) {
    p.player_stance = PlayerStance.Forehand
  }

  if (p.acc.x < 0) {
    p.player_stance = PlayerStance.Backhand
  }

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
   * Bounds checking.
   */

  if (p.game.state === state.pre_serve) {
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

  /**
   * Update screen position.
   */

  cam_project(p.cam, p.screen_pos, p.pos)
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

  if (p.player_stance === PlayerStance.Forehand) {
    p.game.ball.pos.x += 0.5 * meter
  }

  if (p.player_stance === PlayerStance.Backhand) {
    p.game.ball.pos.x -= 0.5 * meter
  }

  p.game.ball.pos.z += p.player_dir * 0.1 * meter
}

function player_update(p: Player): void {
  /**
   * Prior to serve.
   */

  if (p.game.state === state.pre_serve) {
    // TODO: temporary, move ball around using arrow keys and z and x
    if (p.game.server === p) {
      const racket_head = p.arm_points[2]
      if (btn(button.up)) {
        racket_head.y += 0.05 * meter
      }
      if (btn(button.down)) {
        racket_head.y -= 0.05 * meter
      }
      if (btn(button.left)) {
        racket_head.x -= 0.05 * meter
      }
      if (btn(button.right)) {
        racket_head.x += 0.05 * meter
      }
      if (btn(button.z)) {
        racket_head.z -= 0.05 * meter
      }
      if (btn(button.x)) {
        racket_head.z += 0.05 * meter
      }
      cam_project(p.cam, p.arm_screen_points[2], racket_head)

      const socket = p.arm_screen_points[0]
      const wrist = p.arm_screen_points[1]
      // const racket_head = p.arm_screen_points[2]

      let target = racket_head
      const spare = vec3()

      vec3_sub(spare, racket_head, socket)
      let [new_head, new_tail] = reach(racket_head, wrist, target, 0.5 * meter)
      p.arm_points[0] = new_head
      target = new_tail

      vec3_sub(spare, wrist, socket)
      let [new_head2, new_tail2] = reach(wrist, socket, wrist, 0.5 * meter)
      p.arm_points[1] = new_head2
      target = new_tail2

      p.arm_points[2] = socket

      // update screen points.
      for (let i = 0; i < 3; i++) {
        cam_project(p.cam, p.arm_screen_points[i], p.arm_points[i])
      }

      //print('processed input')
      //stop()
      return
    }

    return

    if (btn(button.x)) {
      // Make ball be affected by gravity again.
      p.game.ball.is_kinematic = false

      // Set next state.
      p.game.next_state = state.serving
    }

    if (btn(button.z) && p.player_stance === PlayerStance.Backhand) {
      // Make ball be affected by gravity again.
      p.game.ball.is_kinematic = false

      // Set next state.
      p.game.next_state = state.serving

      // Set swing state.
      p.swing_state = SwingState.Winding
    }

    player_move(p)
    if (p.game.server === p) {
      player_move_ball(p)
    }
    // Move arm afterward, since it depends
    // on ball's location.
    player_move_arm(p)

    return
  }

  /**
   * Serve.
   */

  if (p.game.state === state.serving) {
    // If we are in a winding state,
    // increase swing power.
    // Remember to reset serve power later!
    if (p.swing_state === SwingState.Winding && btn(button.z)) {
      p.swing_power += 1 * (1 / 60)
      return
    }

    if (p.swing_state === SwingState.Winding && !btn(button.z)) {
      p.swing_state = SwingState.Idle
      return
      // TODO: Swing.
    }

    return
  }

  /**
   * Rally.
   */

  if (p.game.state === state.rally) {
    return
  }

  /**
   * Post-rally.
   */

  if (p.game.state === state.post_rally) {
    return
  }

  return
}

function player_move_arm(p: Player): void {
  // Update socket point.
  const socket = p.arm_points[0]
  socket.x = p.pos.x + 0.3 * meter * -p.player_dir
  socket.y = p.pos.y + 1 * meter
  socket.z = p.pos.z

  // Update racket head point.
  const racket_head = p.arm_points[2]
  racket_head.x = p.ball.pos.x
  racket_head.y = p.ball.pos.y
  racket_head.z = p.ball.pos.z

  // Update screen points.
  cam_project(p.cam, p.arm_screen_points[0], socket)
  cam_project(p.cam, p.arm_screen_points[2], racket_head)
}

function player_draw(p: Player): void {
  const width = 10
  const height = 25
  const arm_height = 15

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

  //
  // Draw player arm.
  //

  // Socket.
  const socket = p.arm_screen_points[0]
  circfill(socket.x, socket.y, 1, col.orange)

  // Wrist.
  const wrist = p.arm_screen_points[1]
  circfill(wrist.x, wrist.y, 1, col.peach)

  // Racket head.
  const racket_head = p.arm_screen_points[2]
  circfill(racket_head.x, racket_head.y, 1, col.pink)
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
  vel60: Vec3

  // Acceleration.
  acc: Vec3

  // Dependencies.
  cam: Camera
  net: Net

  // State.
  is_kinematic: boolean

  // Spare vec3's for computation.
  spare: Vec3
  next_pos: Vec3
}

function ball(c: Camera, n: Net): Ball {
  return {
    pos: vec3(0, 3 * meter, 5 * meter),
    shadow_pos: vec3(),
    vel: vec3(0, 1 * meter, 0),
    vel60: vec3(),
    acc: vec3(0, -10 * meter, 0),
    screen_pos: vec3(),
    screen_shadow_pos: vec3(),
    cam: c,
    is_kinematic: false,
    net: n,
    update: ball_update,
    draw: ball_draw,
    spare: vec3(),
    next_pos: vec3(),
  }
}

function ball_update(b: Ball): void {
  if (!b.is_kinematic && b.pos.y > 0) {
    // Compute change in velocity for this frame.
    vec3_assign(b.spare, b.acc)
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
  circfill(round(b.screen_pos.x), round(b.screen_pos.y), 1, col.yellow)
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

function net_update(n: Net): void { }

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
