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
