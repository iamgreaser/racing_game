dofile("base/player.lua")

game = {}
local this = {}

function game.init()
	game.tick_rate = 60

	this.frame_accum = 0.5
	this.frame_idx = 0

	player.init()
	player.current_idx = player.add {
		pos = {5.0, 0.0, 5.0},
		vel = {0.0, 0.0, 0.0},
		is_local = true,
	}
end

function game.update_tick()
	local dt = 1.0/game.tick_rate

	local P = player.player_list[player.current_idx]

	local in_new = {
		left = love.keyboard.isScancodeDown("left"),
		right = love.keyboard.isScancodeDown("right"),
		gas = love.keyboard.isScancodeDown("z") or love.keyboard.isScancodeDown("y"),
		brake = love.keyboard.isScancodeDown("x"),
		boost = love.keyboard.isScancodeDown("c"),
	}
	P.set_input(this.frame_idx, in_new)
	P.tick(this.frame_idx)

end

function game.update_dt(dt)
	this.frame_accum = this.frame_accum + dt * game.tick_rate
	while this.frame_accum >= 1.0 do
		game.update_tick()
		this.frame_accum = this.frame_accum - 1.0
		this.frame_idx = this.frame_idx + 1
	end
end

