local function MatClone(p)
	local clone = table.clone(p)

	for i = 1, #clone do
		clone[i] = table.clone(clone[i])
	end

	return clone
end

local function MatZero(p: number)
	local result = table.create(p)

	for i = 1, p do
		result[i] = table.create(p, 0)
	end

	return result
end

local function MatIdent(p: number)
	local matZero = MatZero(p)

	for i = 1, p do
		matZero[i][i] = 1
	end

	return matZero
end

local function MatMul(list, list2)
	local v = #list
	local v2 = #list[1]
	local count = #list2[1]
	local result = {}

	for i = 1, v do
		local v3 = table.create(count, 0)

		for i2 = 1, count do
			local v4 = 0

			for i3 = 1, v2 do
				v4 = bit32.bxor(v4, (bit32.band(list[i][i3], list2[i3][i2])))
			end

			v3[i2] = v4
		end

		result[i] = v3
	end

	return result
end

local function MatMulVec(list, list2)
	local count = #list
	local v = #list[1]
	local result = table.create(count, 0)

	for i = 1, count do
		local v2 = 0

		for i2 = 1, v do
			v2 = bit32.bxor(v2, (bit32.band(list[i][i2], list2[i2])))
		end

		result[i] = v2
	end

	return result
end

local function MatSum(list, list2)
	local count = #list
	local v = #list[1]
	local matZero = MatZero(count)

	for i = 1, count do
		for i2 = 1, v do
			matZero[i][i2] = bit32.bxor(list[i][i2], list2[i][i2])
		end
	end

	return matZero
end

local function MatInverse(list)
	local count = #list
	local matClone = MatClone(list)
	local result = MatZero(count)

	for i = 1, count do
		result[i][i] = 1
	end

	for i = 1, count do
		local v2 = nil

		for i2 = i, count do
			if matClone[i2][i] ~= 1 then
				continue
			end

			v2 = i2
			break
		end

		assert(v2, "not invertible")
		local v3 = matClone[v2]
		local v4 = matClone[i]
		matClone[i] = v3
		matClone[v2] = v4
		local v5 = result[v2]
		local v6 = result[i]
		result[i] = v5
		result[v2] = v6

		for i2 = 1, count do
			if not (i2 ~= i and matClone[i2][i] == 1) then
				continue
			end

			for i3 = 1, count do
				matClone[i2][i3] = bit32.bxor(matClone[i2][i3], matClone[i][i3])
				result[i2][i3] = bit32.bxor(result[i2][i3], result[i][i3])
			end
		end
	end

	return result
end

local function MatPow(list, p: number)
	local count = #list
	local matZero = MatZero(count)

	for i = 1, count do
		matZero[i][i] = 1
	end

	local v2

	if p < 0 then
		v2 = MatInverse(list)
	else
		v2 = MatClone(list)
	end

	local v3 = math.abs(p)

	while v3 > 0 do
		if math.fmod(v3, 2) >= 0.5 then
			matZero = MatMul(matZero, v2)
		end

		v2 = MatMul(v2, v2)
		v3 = math.floor(v3 / 2)
	end

	return matZero
end

local function L(p: number, p2: number)
	local matZero = MatZero(p2)

	for i = 1, p2 - p do
		matZero[i][i + p] = 1
	end

	return matZero
end

local function R(p: number, p2: number)
	local matZero = MatZero(p2)

	for i = p + 1, p2 do
		matZero[i][i - p] = 1
	end

	return matZero
end

local function Embed(list, p: number, p2: number, p3: number)
	local matZero = MatZero(p)

	for i = 1, #list do
		for i2 = 1, #list[1] do
			matZero[p2 + i][p3 + i2] = list[i][i2]
		end
	end

	return matZero
end

local function ToColumnVector128(p: number, p2: number, p3: number, p4: number)
	local result = table.create(128, 0)

	for i = 0, 31 do
		result[32 - i] = bit32.band(bit32.rshift(p, i), 1)
		result[64 - i] = bit32.band(bit32.rshift(p2, i), 1)
		result[96 - i] = bit32.band(bit32.rshift(p3, i), 1)
		result[128 - i] = bit32.band(bit32.rshift(p4, i), 1)
	end

	return result
end

local function FromColumnVector128(p)
	local v = 0
	local v2 = 0
	local v3 = 0
	local v4 = 0

	for i = 0, 31 do
		v = bit32.bor(v, (bit32.lshift(p[32 - i], i)))
		v2 = bit32.bor(v2, (bit32.lshift(p[64 - i], i)))
		v3 = bit32.bor(v3, (bit32.lshift(p[96 - i], i)))
		v4 = bit32.bor(v4, (bit32.lshift(p[128 - i], i)))
	end

	return v, v2, v3, v4
end

local function BuildMatTransform()
	local matIdent = MatIdent(32)
	local matIdent2 = MatIdent(128)
	local matMul = MatMul(MatSum(matIdent2, Embed(L(11, 32), 128, 0, 0)), matIdent2)
	local matMul2 = MatMul(MatSum(matIdent2, Embed(R(8, 32), 128, 0, 0)), matMul)
	local matMul3 = MatMul(MatSum(matIdent2, Embed(matIdent, 128, 0, 96)), matMul2)
	local matMul4 = MatMul(MatSum(matIdent2, Embed(R(19, 32), 128, 0, 96)), matMul3)
	return (MatMul(MatSum(L(32, 128), R(96, 128)), matMul4))
end

local matTransform = BuildMatTransform()
return table.freeze({
	ToColumnVector128 = ToColumnVector128,
	FromColumnVector128 = FromColumnVector128,
	MatTransform = function()
		return (MatClone(matTransform))
	end,
	Transform = function(p: number, p2: number, p3: number, p4: number, p5: number)
		local toColumnVector128 = ToColumnVector128(p, p2, p3, p4)
		return FromColumnVector128(MatMulVec(MatPow(MatClone(matTransform), p5), toColumnVector128))
	end
})