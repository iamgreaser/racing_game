dofile("base/matrix.lua")

display = {}
local out_vertices = {}
local out_indices = {}

-- Prepare geometry
local CAR_LX = 0.5
local CAR_LY = 0.2
local CAR_LZ = 1.0
local car_vertices = {
	{-CAR_LX, 0.0, -CAR_LZ, 1.0},
	{ CAR_LX, 0.0, -CAR_LZ, 1.0},
	{-CAR_LX, CAR_LY*2.0, -CAR_LZ, 1.0},
	{ CAR_LX, CAR_LY*2.0, -CAR_LZ, 1.0},
	{-CAR_LX, 0.0,  CAR_LZ, 1.0},
	{ CAR_LX, 0.0,  CAR_LZ, 1.0},
	{-CAR_LX, CAR_LY*2.0,  CAR_LZ, 1.0},
	{ CAR_LX, CAR_LY*2.0,  CAR_LZ, 1.0},
}

local car_indices = {
	-- Z
	{1, 2, 4, 3, mode="fill", color={170,  85,  85}},
	{5, 7, 8, 6, mode="fill", color={ 85, 170,  85}},
	-- Y
	{1, 5, 6, 2, mode="fill", color={ 85,  85, 170}},
	{3, 4, 8, 7, mode="fill", color={ 85, 170, 170}},
	-- X
	{1, 3, 7, 5, mode="fill", color={170,  85, 170}},
	{2, 6, 8, 4, mode="fill", color={170, 170,  85}},
}

local WHEEL_LX = 0.1
local WHEEL_LY = 0.2
local WHEEL_LZ = 0.2
local wheel_vertices = {
	{-WHEEL_LX, -WHEEL_LY, -WHEEL_LZ, 1.0},
	{ WHEEL_LX, -WHEEL_LY, -WHEEL_LZ, 1.0},
	{-WHEEL_LX,  WHEEL_LY, -WHEEL_LZ, 1.0},
	{ WHEEL_LX,  WHEEL_LY, -WHEEL_LZ, 1.0},
	{-WHEEL_LX, -WHEEL_LY,  WHEEL_LZ, 1.0},
	{ WHEEL_LX, -WHEEL_LY,  WHEEL_LZ, 1.0},
	{-WHEEL_LX,  WHEEL_LY,  WHEEL_LZ, 1.0},
	{ WHEEL_LX,  WHEEL_LY,  WHEEL_LZ, 1.0},
}

local wheel_indices = {
	-- Z
	{1, 2, 4, 3, mode="fill", color={170,  85,  85}},
	{5, 7, 8, 6, mode="fill", color={ 85, 170,  85}},
	-- Y
	{1, 5, 6, 2, mode="fill", color={ 85,  85, 170}},
	{3, 4, 8, 7, mode="fill", color={ 85, 170, 170}},
	-- X
	{1, 3, 7, 5, mode="fill", color={170,  85, 170}},
	{2, 6, 8, 4, mode="fill", color={170, 170,  85}},
}

local ground_vertices = {}
local ground_indices = {}

local CELL_SIZE = 10.0
local CELL_RADIUS = 12
local CELL_OFFS = -CELL_RADIUS

do
	local x, z

	local function gen_index(x, z)
		return (CELL_RADIUS*2+1)*z+x+1
	end
	local function gen_polygon(x, z)
		local x0 = (x + 0)
		local z0 = (z + 0)
		local x1 = (x + 1)
		local z1 = (z + 1)
		
		--local i = x+z
		local i = (x*z) % 2

		return {
			gen_index(x0, z0)*2-1+0,
			gen_index(x1, z0)*2-1+0,
			gen_index(x1, z1)*2-1+0,
			gen_index(x0, z1)*2-1+0,
			color = ((i%2) == 0 and {50,50,50}) or {40,40,40},
			mode = "fill",
		}
	end

	for z=0,CELL_RADIUS*2 do
	for x=0,CELL_RADIUS*2 do
		local wx = (x + CELL_OFFS) * CELL_SIZE
		local wz = (z + CELL_OFFS) * CELL_SIZE
		table.insert(ground_vertices, {wx+0.0, 0.0, wz+0.0, 1.0})
		table.insert(ground_vertices, {wx+CELL_SIZE/2.0, CELL_SIZE/2.0, wz+CELL_SIZE/2.0, 1.0})
	end
	end

	for z=0,CELL_RADIUS*2-1 do
	for x=0,CELL_RADIUS*2-1 do
		local i = (x*z) % 2
		if (i%2) == 0 then
			table.insert(ground_indices, gen_polygon(x, z))
		end
	end
	end

	for z=0,CELL_RADIUS*2-1 do
	for x=0,CELL_RADIUS*2-1 do
		local i = (x*z) % 2
		if (i%2) ~= 0 then
			local x0 = (x + 0)
			local z0 = (z + 0)
			local x1 = (x + 1)
			local z1 = (z + 1)
			
			--local i = x+z
			local i = (x*z) % 2

			table.insert(ground_indices, {
				gen_index(x0, z0)*2-1+0,
				gen_index(x1, z0)*2-1+0,
				gen_index(x0, z0)*2-1+1,
				color = {40,40,40},
				mode = "fill",
			})

			table.insert(ground_indices, {
				gen_index(x1, z0)*2-1+0,
				gen_index(x1, z1)*2-1+0,
				gen_index(x0, z0)*2-1+1,
				color = {60,60,60},
				mode = "fill",
			})

			table.insert(ground_indices, {
				gen_index(x1, z1)*2-1+0,
				gen_index(x0, z1)*2-1+0,
				gen_index(x0, z0)*2-1+1,
				color = {80,80,80},
				mode = "fill",
			})

			table.insert(ground_indices, {
				gen_index(x0, z1)*2-1+0,
				gen_index(x0, z0)*2-1+0,
				gen_index(x0, z0)*2-1+1,
				color = {60,60,60},
				mode = "fill",
			})
		end
	end
	end
end

function display.clear()
	out_vertices = {}
	out_indices = {}
end

function display.add_geometry(Mcam, Mmodel, in_vertices, in_indices, settings)
	local M = (Mmodel and matrix.mul_mat_mat(Mcam, Mmodel)) or Mcam
	local index_offs = #out_vertices
	local i, j
	for i=1,#in_vertices do
		table.insert(out_vertices, matrix.mul_mat_vec(M, in_vertices[i]))
	end
	for i=1,#in_indices do
		local t = {
			color = in_indices[i].color or {255, 255, 255},
			mode = in_indices[i].mode or error("expected mode for polygon"),
			prio = settings.prio or 0,
			--{255*(i%2), 255*(i%2), 255*(1-(i%2))},
		}
		for j=1,#in_indices[i] do
			t[j] = in_indices[i][j] + index_offs
		end
		table.insert(out_indices, t)
	end
end

local function clip_against_z(v0, v1, clip_z)
	local t = (clip_z - v0[3]) / (v1[3] - v0[3])
	return {
		v0[1] + (v1[1]-v0[1])*t,
		v0[2] + (v1[2]-v0[2])*t,
		v0[3] + (v1[3]-v0[3])*t,
	}
end

function love.draw()
	-- Get dimensions
	local W, H = love.graphics.getDimensions()
	local P = player.player_list[player.current_idx]

	-- Set modelview matrix
	local Mcam = matrix.new()
	Mcam = matrix.translate(Mcam, 0.0,-0.2, 1.0)
	--Mcam = matrix.rotate(Mcam, -math.pi/5.0, 1.0, 0.0, 0.0)
	--Mcam = matrix.rotate(Mcam, -math.sin(sec_current), 1.0, 0.0, 0.0)
	Mcam = matrix.rotate(Mcam, -math.pi/5.0, 1.0, 0.0, 0.0)
	Mcam = matrix.translate(Mcam, 0.0,-3.0, 2.0)
	--Mcam = matrix.rotate(Mcam, -math.sin(sec_current*math.pi*2.0/2.0)*0.4, 0.0, 1.0, 0.0)

	local d = math.sqrt(P.vel[1]*P.vel[1] + P.vel[3]*P.vel[3])
	--Mcam = matrix.rotate(Mcam, -P.bearing+P.bearing_vel*d*0.5, 0.0, 1.0, 0.0)
	local xbearing = math.atan2(P.vel[1], P.vel[3])
	local xbear_clamp = math.min(1.0, d/2.0)
	--xbear_clamp = 0.5 + math.max(0.0, xbear_clamp) * 0.5
	local xbearing_diff = (P.bearing - xbearing)
	xbearing_diff = math.fmod(xbearing_diff + math.pi, math.pi*2.0) - math.pi
	xbearing = xbearing + xbearing_diff * (1.0 - xbear_clamp)
	--xbearing = P.bearing - xbearing_diff * xbear_clamp * 0.4
	Mcam = matrix.rotate(Mcam, -xbearing, 0.0, 1.0, 0.0)

	Mcam = matrix.translate(Mcam, -P.pos[1], -P.pos[2], -P.pos[3])

	display.clear()

	-- Transform vertices
	do
		local Mmodel = matrix.new()
		local adjx = math.floor(P.pos[1]/(CELL_SIZE*2))*CELL_SIZE*2
		local adjz = math.floor(P.pos[3]/(CELL_SIZE*2))*CELL_SIZE*2
		Mmodel = matrix.translate(Mmodel, adjx, 0.0, adjz)
		display.add_geometry(Mcam, Mmodel, ground_vertices, ground_indices, {
			prio = 1,
		})
	end
	do
		local i, W
		for i, W in ipairs(P.wheels) do
			local Mmodel = matrix.new()
			Mmodel = matrix.translate(Mmodel, P.pos[1], P.pos[2], P.pos[3])
			Mmodel = matrix.rotate(Mmodel, P.bearing, 0.0, 1.0, 0.0)
			Mmodel = matrix.translate(Mmodel, unpack(W.rel_pos))
			Mmodel = matrix.rotate(Mmodel, W.bearing, 0.0, 1.0, 0.0)
			Mmodel = matrix.rotate(Mmodel, W.rot_pos, 1.0, 0.0, 0.0)
			display.add_geometry(Mcam, Mmodel, wheel_vertices, wheel_indices, {})
		end
	end
	do
		local Mmodel = matrix.new()
		Mmodel = matrix.translate(Mmodel, P.pos[1], P.pos[2], P.pos[3])
		Mmodel = matrix.rotate(Mmodel, P.bearing, 0.0, 1.0, 0.0)
		display.add_geometry(Mcam, Mmodel, car_vertices, car_indices, {})
	end

	-- Assemble polygons
	local ZNEAR = 0.05
	local polygons = {}
	for i=1,#out_indices do
		local p = {
			color = out_indices[i].color,
			mode = out_indices[i].mode,
			prio = out_indices[i].prio,
		}

		-- Assemble base polygon
		local vlist = {}
		for j=1,#out_indices[i] do
			local k = out_indices[i][j]
			local x = out_vertices[k][1]
			local y = out_vertices[k][2]
			local z = out_vertices[k][3]
			table.insert(vlist, {x, y, z})
		end

		-- Apply near-plane clipping
		local old_vlist = vlist
		vlist = {}
		p.z = nil
		for j=1,#old_vlist do
			local v0 = old_vlist[(j+0) % #old_vlist + 1]
			local v1 = old_vlist[(j+1) % #old_vlist + 1]
			local v2 = old_vlist[(j+2) % #old_vlist + 1]

			if v1[3] >= ZNEAR then
				p.z = (p.z and math.max(p.z, v1[3])) or v1[3]
				table.insert(vlist, v1)
			else
				if v0[3] >= ZNEAR then
					table.insert(vlist, clip_against_z(v0, v1, ZNEAR))
				end
				if v2[3] >= ZNEAR then
					table.insert(vlist, clip_against_z(v1, v2, ZNEAR))
				end
			end
		end

		-- Assemble screen-space polygons
		if #vlist >= 3 then
			for j=1,#vlist do
				local x = vlist[j][1]
				local y = vlist[j][2]
				local z = vlist[j][3]

				local sx =  (x*H)/(z*2.0) + W/2.0
				local sy = -(y*H)/(z*2.0) + H/2.0

				table.insert(p, sx)
				table.insert(p, sy)
			end
		end

		if #p >= 6 then
			-- Backface culling
			local dx1 = p[1]-p[3]
			local dy1 = p[2]-p[4]
			local dx2 = p[5]-p[3]
			local dy2 = p[6]-p[4]

			local bfcheck = dx1*dy2 - dy1*dx2
			if bfcheck > 0.0 then
				table.insert(polygons, p)
			end
		end
	end

	-- Sort polygons in suitable Z order
	table.sort(polygons, function (p1, p2)
		return p1.prio > p2.prio or (p1.prio == p2.prio and p1.z > p2.z)
	end)

	-- Draw polygons
	for i=1,#polygons do
		--love.graphics.setColor(255, 255, 255)
		love.graphics.setColor(unpack(polygons[i].color))
		love.graphics.polygon(polygons[i].mode, polygons[i])
	end
end
