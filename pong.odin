package main

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {

  BoxW :: 125
  BoxH :: 25
	posX: i32 = 100
	posY: i32 = 100

  BallW :: 30
  BallH :: 30
  BpoxX: i32 = 100
  BpoxY: i32 = 150


  WIDTH :: 640
  HEIGHT :: 480

	rl.InitWindow(WIDTH, HEIGHT, "Pong")
	rl.SetTargetFPS(60)


	for !rl.WindowShouldClose() {

    if rl.IsKeyDown(rl.KeyboardKey.A) {
     posX -= 10
    }
    if rl.IsKeyDown(rl.KeyboardKey.D) {
     posX += 10
    }
    if rl.IsKeyDown(rl.KeyboardKey.W) {
     posY -= 10
    }
    if rl.IsKeyDown(rl.KeyboardKey.S) {
     posY += 10
    }

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawRectangle(posX, posY, BoxW, BoxH, rl.WHITE)
		rl.DrawRectangle(BpoxX, BpoxY, BallW, BallH, rl.RED)
		rl.EndDrawing()
	}
}


// INFO: Works but you gotta press it again and again to register cuz of GetKeyPressed
//
//  #partial switch rl.GetKeyPressed() {
//  case rl.KeyboardKey.A:
// posX -= 10
//  case rl.KeyboardKey.D:
// posX += 10
//  case rl.KeyboardKey.W:
// posY -= 10
//  case rl.KeyboardKey.S:
// posY += 10
//  }

// TODO: for later

// if posX < 0 {
//   posX = WIDTH + posX
// }
// if posX + BoxX > WIDTH {
//   posX = posX - WIDTH
// }
// if posY < 0 {
//   posY = HEIGHT + posY
// }
// if posY > HEIGHT {
//   posY = posY - HEIGHT
// }

