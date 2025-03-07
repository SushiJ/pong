package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

Game_State :: struct {
	window_size:       rl.Vector2,
	paddle:            rl.Rectangle,
	ai_paddle:         rl.Rectangle,
	ai_target_y:       f32,
	ai_reaction_delay: f32,
	ai_reaction_timer: f32,
	paddle_speed:      f32,
	ball:              rl.Rectangle,
	ball_dir:          rl.Vector2,
	ball_speed:        f32,
	score_player:      int,
	score_ai:          int,
	boost_timer:       f32,
}

ball_dir_calculate :: proc(ball: rl.Rectangle, paddle: rl.Rectangle) -> (rl.Vector2, bool) {
	if rl.CheckCollisionRecs(ball, paddle) {
		ball_center := rl.Vector2{ball.x + ball.width / 2, ball.y + ball.height / 2}
		paddle_center := rl.Vector2{paddle.x + paddle.width / 2, paddle.y + paddle.height / 2}
		normalized := linalg.normalize0(ball_center - paddle_center)
		return normalized, true
	}
	return {}, false
}

main :: proc() {
	WIDTH :: 640
	HEIGHT :: 480

	gs := Game_State {
		window_size = {WIDTH, HEIGHT},
		paddle = {width = 30, height = 80},
		ai_paddle = {width = 30, height = 80},
		ai_reaction_delay = 0.1,
		paddle_speed = 10,
		ball = {width = 30, height = 30},
		ball_dir = {0, -1},
		ball_speed = 10,
		score_player = 0,
		score_ai = 0,
		boost_timer = 0.00,
	}

	reset(&gs)

	using gs
	rl.InitWindow(i32(window_size.x), i32(window_size.y), "Pong")
	rl.SetTargetFPS(60)
	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	sfx_hit := rl.LoadSound("assets/hit.wav")
	sfx_lose := rl.LoadSound("assets/lose.wav")
	sfx_win := rl.LoadSound("assets/win.wav")

	ai_reaction_timer += rl.GetFrameTime()

	if ai_reaction_timer >= ai_reaction_delay {
		ai_reaction_timer = 0
		ball_mid := ball.y + ball.height / 2
		if ball_dir.x < 0 {
			ai_target_y = ball_mid - ai_paddle.height / 2

			// add or subtract 0-20 to add inaccuracy
			ai_target_y += rand.float32_range(-20, 20)
		} else {
			ai_target_y = window_size.y / 2 - ai_paddle.height / 2
		}
	}

	target_diff := ai_target_y - ai_paddle.y
	ai_paddle.y += linalg.clamp(target_diff, -paddle_speed, paddle_speed) * 0.65
	ai_paddle.y = linalg.clamp(ai_paddle.y, 0, window_size.y - ai_paddle.height)

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()
		boost_timer -= delta

		ai_reaction_timer += delta

		if rl.IsKeyDown(.SPACE) {
			if boost_timer < 0 {
				boost_timer = 0.2
			}
		}

		if rl.IsKeyDown(.UP) || rl.IsKeyDown(.K) {
			paddle.y -= paddle_speed
		}
		if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.J) {
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
			score_ai += 1
			rl.PlaySound(sfx_lose)
			reset(&gs)
		}

		if next_ball_rec.x <= 0 {
			score_player += 1
			rl.PlaySound(sfx_win)
			reset(&gs)
		}

		last_ball_dir := ball_dir

		new_dir, did_hit := ball_dir_calculate(next_ball_rec, paddle)
		if did_hit {
			if boost_timer > 0 {
				d := 1 + boost_timer / 0.2
				new_dir *= d
			}
			ball_dir = new_dir
		}

		if last_ball_dir != ball_dir {
			rl.PlaySound(sfx_hit)
		}

		ball_dir = ball_dir_calculate(next_ball_rec, ai_paddle) or_else ball_dir

		if last_ball_dir != ball_dir {
			rl.PlaySound(sfx_hit)
		}

		ball.y += ball_speed * ball_dir.y
		ball.x += ball_speed * ball_dir.x

		rl.BeginDrawing()


		if boost_timer > 0 {
			rl.DrawRectangleRec(paddle, {u8(255 * (0.2 / boost_timer)), 255, 255, 255})
		} else {
			rl.DrawRectangleRec(paddle, rl.WHITE)
		}

		rl.DrawRectangleRec(ai_paddle, rl.WHITE)
		rl.DrawRectangleRec(ball, {255, u8(255 - 255 / linalg.length(ball_dir)), 0, 255})
		rl.ClearBackground(rl.BLACK)

		rl.DrawText(fmt.ctprintf("{}", score_ai), 12, 12, 32, rl.WHITE)
		rl.DrawText(fmt.ctprintf("{}", score_player), i32(window_size.x) - 28, 12, 32, rl.WHITE)

		rl.EndDrawing()
		// Free cstring temp memory
		free_all(context.temp_allocator)
	}
}

reset :: proc(gs: ^Game_State) {
	angle := rand.float32_range(-45, 46) // [) inc, exclusive
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
