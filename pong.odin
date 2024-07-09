package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

Game_State :: struct {
	window_size:  rl.Vector2,
	paddle:       rl.Rectangle,
	paddle_speed: f32,
	ball:         rl.Rectangle,
	ball_dir:     rl.Vector2,
	ball_speed:   f32,
}

main :: proc() {
	WIDTH :: 640
	HEIGHT :: 480

	gs := Game_State {
		window_size = {640, 480},
		paddle = {width = 30, height = 80},
		paddle_speed = 10,
		ball = {width = 30, height = 30},
		ball_dir = {0, -1},
		ball_speed = 10,
	}

	reset(&gs)

	using gs
	rl.InitWindow(i32(window_size.x), i32(window_size.y), "Pong")
	rl.SetTargetFPS(60)


	for !rl.WindowShouldClose() {

		if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
			paddle.y -= paddle_speed
		}
		if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
			paddle.y += paddle_speed
		}

		paddle.y = linalg.clamp(paddle.y, 0, window_size.y - paddle.height)

		next_ball_rec := ball

		next_ball_rec.y += ball_speed * ball_dir.y
		next_ball_rec.x += ball_speed * ball_dir.x

		if next_ball_rec.y >= window_size.y - ball.height || next_ball_rec.y <= 0 {
			ball_dir.y *= -1
		}

		if next_ball_rec.x >= window_size.x - ball.width {
			// ball_dir.x *= -1
			reset(&gs)
		}

		if next_ball_rec.x <= 0 {
			// ball_dir.x *= -1
			reset(&gs)
		}

		if rl.CheckCollisionRecs(next_ball_rec, paddle) {
			ball_center := rl.Vector2 {
				next_ball_rec.x + ball.width / 2,
				next_ball_rec.y + ball.height / 2,
			}
			paddle_center := rl.Vector2{paddle.x + paddle.width / 2, paddle.y + paddle.height / 2}
			ball_dir = linalg.normalize0(ball_center - paddle_center)
		}

		ball.y += ball_speed * ball_dir.y
		ball.x += ball_speed * ball_dir.x

		rl.BeginDrawing()
		rl.DrawRectangleRec(paddle, rl.WHITE)
		rl.DrawRectangleRec(ball, rl.RED)
		rl.ClearBackground(rl.BLACK)
		rl.EndDrawing()
	}
}

reset :: proc(gs: ^Game_State) {
	angle := rand.float32_range(-45, 46) // (] inc, exclusive
	r := math.to_radians(angle)

	gs.ball_dir.x = math.cos(r)
	gs.ball_dir.y = math.sin(r)

	gs.ball.x = gs.window_size.x / 2 - gs.ball.width / 2
	gs.ball.y = gs.window_size.y / 2 - gs.ball.height / 2

	gs.paddle.x = gs.window_size.x - 80
	gs.paddle.y = gs.window_size.y / 2 - gs.paddle.height / 2
}
