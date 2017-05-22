matrix = {}

function matrix.new()
	return {
		{1.0, 0.0, 0.0, 0.0},
		{0.0, 1.0, 0.0, 0.0},
		{0.0, 0.0, 1.0, 0.0},
		{0.0, 0.0, 0.0, 1.0},
	}
end

function matrix.mul_mat_mat(A, B)
	local R = {}
	local i,j,k

	--print(#A, #A[1], #A[2], #A[3], #A[4])
	--print(#B, #B[1], #B[2], #B[3], #B[4])
	for i=1,4 do
		R[i] = {}
		for j=1,4 do
			local s = 0.0
			for k=1,4 do
				--print(i, j, k, #R, #R[i], #A, #A[i], #B, #B[k])
				s = s + A[i][k] * B[k][j]
			end
			R[i][j] = s
		end
	end
	--print(#R, #R[1], #R[2], #R[3], #R[4])

	return R
end

function matrix.new_rotate(ang, x, y, z)
	local d = math.sqrt(x*x + y*y + z*z)
	d = math.max(d, 0.0001)
	x, y, z = x/d, y/d, z/d

	local c = math.cos(ang)
	local s = math.sin(ang)
	local B = {
		{ x*x*(1.0-c)+c  , x*y*(1.0-c)-z*s, x*z*(1.0-c)+y*s, 0.0 },
		{ y*x*(1.0-c)+z*s, y*y*(1.0-c)+c  , y*z*(1.0-c)-x*s, 0.0 },
		{ z*x*(1.0-c)-y*s, z*y*(1.0-c)+x*s, z*z*(1.0-c)+c  , 0.0 },
		{ 0.0, 0.0, 0.0, 1.0 },
	}
	return B
end

function matrix.rotate(A, ang, x, y, z)
	return matrix.mul_mat_mat(A, matrix.new_rotate(ang, x, y, z))
end

function matrix.new_translate(x, y, z)
	return {
		{1.0, 0.0, 0.0,  x },
		{0.0, 1.0, 0.0,  y },
		{0.0, 0.0, 1.0, z  },
		{0.0, 0.0, 0.0, 1.0},
	}
end

function matrix.translate(A, x, y, z)
	return matrix.mul_mat_mat(A, matrix.new_translate(x, y, z))
end

function matrix.mul_mat_vec(A, v)
	local r = {}
	local i,j

	for i=1,4 do
		r[i] = 0.0
		for j=1,4 do
			r[i] = r[i] + A[i][j] * v[j]
		end
	end

	return r
end

