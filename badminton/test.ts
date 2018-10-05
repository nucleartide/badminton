declare function add<T>(t: Array<T>, v: T): Array<T>

/**
 * Actor.
 */

interface Actor<T> {
  update: (t: T) => void
  draw: (t: T) => void
}

/**
 * Badminton actor.
 */

type BadmintonActor = Game | Player

/**
 * State.
 */

enum state {
  player_one_serve,
  player_two_serve,
  rally,
  post_rally,
  player_one_win,
  player_two_win,
}

/**
 * Game.
 */

interface Game extends Actor<Game> {
  state: state
}

function game(): Game {
  return {
    state: state.player_one_serve,
    update: game_update,
    draw: game_draw,
  }
}

function game_update(g: Game): void {}

function game_draw(g: Game): void {}

/**
 * Player.
 */

interface Player extends Actor<Player> {
  game: Game
}

function player(g: Game): Player {
  return {
    game: g,
    update: player_update,
    draw: player_draw,
  }
}

function player_update(p: Player): void {}

function player_draw(p: Player): void {}

/**
 * Game loop.
 */

let actors: Array<BadmintonActor>

function _init(): void {
  const g = game()
  const p1 = player(g)
  const p2 = player(g)

  actors = []
  add(actors, g)
  add(actors, p1)
  add(actors, p2)
}

function _update60(): void {}

function _draw(): void {}
