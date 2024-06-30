package main

import rl "vendor:raylib"

main :: proc () {
  rl.InitWindow(640, 480, "Pong")
  rl.SetTargetFPS(60)

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()
    rl.DrawRectangle(100, 100, 100, 100, rl.WHITE)
    rl.EndDrawing()
  }
}
