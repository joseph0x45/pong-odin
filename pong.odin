package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "vendor:raylib"

GameState :: struct {
	window_size:    raylib.Vector2,
	paddle:         raylib.Rectangle,
	paddle_speed:   f32,
	ball:           raylib.Rectangle,
	ball_direction: raylib.Vector2,
	ball_speed:     f32,
}

speed: f32 = 5

reset :: proc(using gs: ^GameState) {
	angle := rand.float32_range(-45, 46)
	r := math.to_radians(angle)
	ball_direction.x = math.cos(r)
	ball_direction.y = math.sign(r)
	ball.x = window_size.x / 2 - ball.width / 2
	ball.y = window_size.y / 2 - ball.height / 2
	paddle.x = window_size.x - 80
	paddle.y = window_size.y / 2 - paddle.height / 2
}

main :: proc() {
	gs := GameState {
		window_size = {800, 800},
		paddle = {width = 30, height = 200},
		paddle_speed = 5,
		ball = {width = 30, height = 30},
		ball_speed = 10,
	}

	reset(&gs)

	using gs

	raylib.InitWindow(i32(window_size.x), i32(window_size.y), "Pong")
	raylib.SetTargetFPS(60)
	for (!raylib.WindowShouldClose()) {
		if raylib.IsKeyDown(.UP) {
			paddle.y -= speed
		}
		if raylib.IsKeyDown(.DOWN) {
			paddle.y += speed
		}
		paddle.y = linalg.clamp(paddle.y, 0, window_size.y - paddle.height)
		next_ball_rect := ball
		next_ball_rect.y += speed * ball_direction.y
		next_ball_rect.x += speed * ball_direction.x
		if next_ball_rect.x >= window_size.x - ball.width {
			reset(&gs)
		}
		if next_ball_rect.x < 0 {
			reset(&gs)
		}
		if next_ball_rect.y >= gs.window_size.y - ball.height || next_ball_rect.y <= 0 {
			ball_direction.y *= -1
		}
		if raylib.CheckCollisionRecs(next_ball_rect, paddle) {
			ball_direction.y *= -1
		}
		ball.y += speed * ball_direction.y
		ball.x += speed * ball_direction.x
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.BLACK)
		raylib.DrawRectangleRec(paddle, raylib.WHITE)
		raylib.DrawRectangleRec(ball, raylib.RED)
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
	return
}
