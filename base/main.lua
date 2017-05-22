dofile("base/game.lua")
dofile("base/display.lua")

sec_current = 0.0

function love.load()
	game.init()
end
 
function love.update(dt)
	sec_current = sec_current + dt
	game.update_dt(dt)
end

