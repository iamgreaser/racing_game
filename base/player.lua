player = {}
local consts = {}
player.consts = consts

consts.CAR_LX = 0.5
consts.CAR_LY = 0.2
consts.CAR_LZ = 1.0
consts.WHEEL_PX = 0.6
consts.WHEEL_PY = 0.2
consts.WHEEL_PZ = 0.7

function player.init()
	player.empty_list()
	player.current_idx = nil
end

function player.empty_list()
	player.player_list = {}
end

function player.tick_all()
	local k, P

	for k, P in ipairs(player.player_list) do
		P.tick()
	end
end

function player.set_input(idx, frame_idx, input)
	local P = player.player_list[idx] or error("invalid player index")

	P.set_input(frame_idx, input)
end

local function new_wheel(settings)
	local W = {
		rx = settings.rx or error("expected rx"),
		rz = settings.rz or error("expected rz"),
		compression = 1.0,
		grip = 1.0,
		bearing = 0.0,
		rot_vel = 0.0,
		rot_pos = 0.0,
	}

	W.can_turn = (W.rz > 0)
	W.is_front = (W.rz > 0)
	W.is_rear = (W.rz < 0)

	W.rel_pos = {
		(W.rx < 0 and -consts.WHEEL_PX) or consts.WHEEL_PX,
		consts.WHEEL_PY,
		(W.rz < 0 and -consts.WHEEL_PZ) or consts.WHEEL_PZ,
		0.0,
	}

	W.vel = { 0.0, 0.0, 0.0, 0.0 }

	return W
end

function player.add(settings)
	local P = {
		index = settings.index or 1+#player.player_list,
		is_local = settings.is_local or error("expected is_local"),
		input = {
			gas = false,
			brake = false,
			left = false,
			right = false,
			boost = false,
		},
		wheels = {
			new_wheel { rx = -1, rz =  1, },
			new_wheel { rx =  1, rz =  1, },
			new_wheel { rx = -1, rz = -1, },
			new_wheel { rx =  1, rz = -1, },
		},
		boost_timeout = 0,
		boost_power = 0.0,
		bearing = 0.0,
		bearing_vel = 0.0,
	}

	do
		local pos = settings.pos or {0.0,0.0,0.0}
		local vel = settings.vel or {0.0,0.0,0.0}
		P.pos = {
			pos[1] or pos.x or 0.0,
			pos[2] or pos.y or 0.0,
			pos[3] or pos.z or 0.0,
			pos[4] or pos.w or 1.0,
		}
		P.vel = {
			vel[1] or vel.x or 0.0,
			vel[2] or vel.y or 0.0,
			vel[3] or vel.z or 0.0,
			vel[4] or vel.w or 1.0,
		}
	end

	function P.set_input(frame_idx, input)
		--P.input_list[frame_idx] = 
		P.input = {
			gas = input.gas,
			brake = input.brake,
			left = input.left,
			right = input.right,
			boost = input.boost,
		}
	end

	function P.tick(frame_idx)
		local dt = 1.0/game.tick_rate
		local in_new = P.input

		local bear_ideal = 0.0
		if in_new.left and not in_new.right then
			bear_ideal = bear_ideal - 1.0
		end
		if in_new.right and not in_new.left then
			bear_ideal = bear_ideal + 1.0
		end
		local amul = (in_new.gas and 0.5) or 0.0
		local bear_acc_base = 3.0
		local bear_frict_base = 1.0
		local frict = ((in_new.brake and 2.3) or 0.3)

		-- Turn the wheels
		local turn_target = 0.0
		if in_new.left  then turn_target = turn_target - 1.0 end
		if in_new.right then turn_target = turn_target + 1.0 end
		--turn_target = turn_target * math.pi/9.0 -- 20 degrees
		turn_target = turn_target * math.pi/6.0 -- 30 degrees
		local turn_speed = 1.0-math.exp(-5.0*dt)

		local accel_speed = ((in_new.gas and 5.0) or 0.0)*dt
		local accel_frict = math.exp(-((in_new.brake and 2.5) or 0.4)*dt)

		local i, W
		local velinc = {0.0, 0.0, 0.0, 0.0}
		local velinc_front = {0.0, 0.0, 0.0, 0.0}
		local velinc_rear = {0.0, 0.0, 0.0, 0.0}
		for i, W in ipairs(P.wheels) do
			-- Move front wheels towards intended angle
			-- TODO: toe-in/toe-out stuff
			if W.can_turn then
				W.bearing = W.bearing + (turn_target - W.bearing) * turn_speed
			end

			-- Apply speed
			-- TODO: not do a 4-wheel-drive
			if W.is_rear or W.is_front then
				W.rot_vel = W.rot_vel + accel_speed
			end
			W.rot_vel = W.rot_vel*accel_frict

			-- Turn wheels purely for looks
			W.rot_pos = W.rot_pos + W.rot_vel*dt/consts.WHEEL_PY

			velinc[1] = velinc[1] + W.rot_vel * math.sin(P.bearing + W.bearing)
			velinc[3] = velinc[3] + W.rot_vel * math.cos(P.bearing + W.bearing)

			if W.is_front then
				velinc_front[1] = velinc_front[1] + W.rot_vel * math.sin(W.bearing)
				velinc_front[3] = velinc_front[3] + W.rot_vel * math.cos(W.bearing)
			end

			if W.is_rear then
				velinc_rear[1] = velinc_rear[1] + W.rot_vel * math.sin(W.bearing)
				velinc_rear[3] = velinc_rear[3] + W.rot_vel * math.cos(W.bearing)
			end

			--print(i, W.rot_vel, W.bearing)
		end

		-- Sum velocity increase
		P.vel[1] = P.vel[1] + velinc[1]*dt
		P.vel[2] = P.vel[2] + velinc[2]*dt
		P.vel[3] = P.vel[3] + velinc[3]*dt

		-- Apply bearing changes
		--P.bearing = P.bearing + (velinc_front[1]-velinc_rear[1])*dt/math.pi
		P.bearing = P.bearing + (velinc_front[1]-velinc_rear[1])*dt/math.sqrt(velinc_front[3]+velinc_rear[3]+0.0001)

		if false then
			local dirx = math.sin(P.bearing)
			local dirz = math.cos(P.bearing)
			local vx = P.vel[1]
			local vz = P.vel[3]
			local vd = math.max(0.0001, math.sqrt(vx*vx + vz*vz))
			local nvx = vx/vd
			local nvz = vz/vd
			local grip_thres = dirx*nvx + dirz*nvz
			grip_thres = math.sqrt(1.0 - grip_thres*grip_thres)
			--print(grip_thres)
			--grip_thres = 1.0 - (grip_thres)
			grip_thres = grip_thres * math.min(1.0, vd)
			grip_thres = math.min(1.0, math.max(grip_thres, 0.0))
			--bear_acc_base = bear_acc_base + (0.2 - bear_acc_base) * grip_thres
			--bear_acc_base = bear_acc_base + (0.0 - bear_acc_base) * grip_thres
			bear_frict_base = bear_frict_base * (1.0-grip_thres*0.9)
			--frict = frict * (1.0-grip_thres*0.6)
			--amul = amul + (0.2 - amul) * grip_thres
			--amul = amul * (1.0-grip_thres*0.4)
		end

		if false then
			local bear_acc_mul = (1.0 - math.exp(-bear_acc_base*dt))
			local bear_frict = math.exp(-bear_frict_base*dt)
			bear_ideal = bear_ideal * math.pi/(2.0*game.tick_rate)*2.0
			--P.bearing_vel = P.bearing_vel + (bear_ideal - P.bearing_vel) * bear_acc_mul
			P.bearing_vel = P.bearing_vel * bear_frict + bear_ideal * bear_acc_mul
			P.bearing = P.bearing + P.bearing_vel
			P.bearing = math.fmod(P.bearing + math.pi, math.pi*2.0) - math.pi

			local ac = math.cos(P.bearing)
			local as = math.sin(P.bearing)

			local ax = as*amul
			local az = ac*amul

			if P.boost_timeout > 0 then
				if P.boost_timeout > 1 or not in_new.boost then
					P.boost_timeout = P.boost_timeout - 1
				end
			end
			if P.input.boost and P.boost_timeout <= 0 then
				P.boost_power = 1.0
				P.boost_timeout = math.floor((game.tick_rate*40)/60)
				--print("BOOST")
			end
			local bmul = 200.0*P.boost_power*dt
			P.boost_power = P.boost_power * math.exp(-3.0*dt)
			local bx = as*bmul
			local bz = ac*bmul
			P.vel[1] = P.vel[1] + bx
			P.vel[2] = P.vel[2]
			P.vel[3] = P.vel[3] + bz
		end

		frict = math.exp(-frict*dt)
		--P.vel[1] = P.vel[1]*frict + ax
		--P.vel[2] = P.vel[2]
		--P.vel[3] = P.vel[3]*frict + az
		P.vel[1] = P.vel[1]*frict
		P.vel[2] = P.vel[2]
		P.vel[3] = P.vel[3]*frict
		P.pos[1] = P.pos[1] + P.vel[1]*dt
		P.pos[2] = P.pos[2] + P.vel[2]*dt
		P.pos[3] = P.pos[3] + P.vel[3]*dt
	end

	
	if player.player_list[P.index] then
		error("attempting to add new player to an already existing index!")
	end
	player.player_list[P.index] = P
	return P.index
end

