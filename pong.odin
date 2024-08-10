package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

Game_State :: struct {
	window_size:  rl.Vector2,
	paddle:       rl.Rectangle,
	ai_paddle:    rl.Rectangle,
	paddle_speed: f32,
	ball:         rl.Rectangle,
	ball_dir:     rl.Vector2,
	ball_speed:   f32,
}

ball_dir_calculate :: proc(ball: rl.Rectangle, paddle: rl.Rectangle) -> (rl.Vector2, bool) {
	if rl.CheckCollisionRecs(ball, paddle) {
		ball_center := rl.Vector2{ball.x + ball.width / 2, ball.y + ball.height / 2}
		paddle_center := rl.Vector2{paddle.x + paddle.width / 2, paddle.y + paddle.height / 2}
		return linalg.normalize0(ball_center - paddle_center), true
	}
	return {}, false
}

main :: proc() {
	WIDTH :: 640
	HEIGHT :: 480

	gs := Game_State {
		window_size = {640, 480},
		paddle = {width = 30, height = 80},
		ai_paddle = {width = 30, height = 80},
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
		diff := ai_paddle.y + ai_paddle.height / 2 - ball.y + ball.height / 2
		if diff < 0 {
			ai_paddle.y += paddle_speed * 0.5
		}
		if diff > 0 {
			ai_paddle.y -= paddle_speed * 0.5
		}
		ai_paddle.y = linalg.clamp(ai_paddle.y, 0, window_size.y - ai_paddle.height)

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

		ball_dir = ball_dir_calculate(next_ball_rec, paddle) or_else ball_dir
		ball_dir = ball_dir_calculate(next_ball_rec, ai_paddle) or_else ball_dir

		ball.y += ball_speed * ball_dir.y
		ball.x += ball_speed * ball_dir.x

		rl.BeginDrawing()
		rl.DrawRectangleRec(paddle, rl.WHITE)
		rl.DrawRectangleRec(ai_paddle, rl.WHITE)
		rl.DrawRectangleRec(ball, rl.RED)
		rl.ClearBackground(rl.BLACK)
		rl.EndDrawing()
	}
}

reset :: proc(gs: ^Game_State) {
	angle := rand.float32_range(-45, 46) // (] inc, exclusive
	if rand.int_max(100) % 2 == 0 do angle += 180
	r := math.to_radians(angle)

	gs.ball_dir.x = math.cos(r)
	gs.ball_dir.y = math.sin(r)

	gs.ball.x = gs.window_size.x / 2 - gs.ball.width / 2
	gs.ball.y = gs.window_size.y / 2 - gs.ball.height / 2

	paddle_margin: f32 = 50
	gs.paddle.x = gs.window_size.x - (gs.paddle.width + paddle_margin)
	gs.paddle.y = gs.window_size.y / 2 - gs.paddle.height / 2

	gs.ai_paddle.x = paddle_margin
	gs.ai_paddle.y = gs.window_size.y / 2 - gs.ai_paddle.height / 2
}
