local parent = script.Parent
local Squash = require(parent.Squash)
local vlq = Squash.vlq()
local f32 = Squash.f32()
local i32 = Squash.i32()
local u32 = Squash.u32()
local v = Squash.u8()

local function createSerInterleaved(p: number, flag: boolean, callback)
	return function(p2, list)
		local count = #list
		local v2 = {}

		for i = 1, p do
			v2[i] = {}
		end

		for k, _ in list do
			callback(p2, list, k)

			for i = 1, p do
				v2[i][k] = v.des(p2)
			end
		end

		for i = p, 1, -1 do
			local v3 = v2[i]

			for i2 = count, 1, -1 do
				v.ser(p2, v3[i2])
			end
		end

		if flag then
			return
		end

		vlq.ser(p2, count)
	end
end

local function createDesInterleaved(p: number, callback)
	return function(p2)
		local des = vlq.des(p2)
		local v2 = {}

		for i = 1, p do
			v2[i] = {}
		end

		for i = 1, p do
			local v3 = v2[i]

			for i2 = 1, des do
				v3[i2] = v.des(p2)
			end
		end

		local result = {}

		for i = 1, des do
			for i2 = p, 1, -1 do
				local v3 = v2[i2]
				v.ser(p2, v3[i])
			end

			result[i] = callback(p2, result, i)
		end

		return result
	end
end

local function compressF32(p, list, k: number)
	local v2 = list[k]
	f32.ser(p, v2)
	local des = u32.des(p)
	local v3 = bit32.bor(bit32.lshift(des, 1), (bit32.rshift(des, 31)))
	u32.ser(p, v3)
end

local function decompressF32(p, _, _: number)
	local des = u32.des(p)
	local v2 = bit32.bor(bit32.rshift(des, 1), (bit32.lshift(bit32.band(des, 1), 31)))
	u32.ser(p, v2)
	return f32.des(p)
end

local v2 = 4

local function fn(p)
	local des = vlq.des(p)
	local v3 = {}

	for i = 1, v2 do
		v3[i] = {}
	end

	for i = 1, v2 do
		local v4 = v3[i]

		for i2 = 1, des do
			v4[i2] = v.des(p)
		end
	end

	local result = {}

	for i = 1, des do
		for i2 = v2, 1, -1 do
			local v4 = v3[i2]
			v.ser(p, v4[i])
		end

		result[i] = decompressF32(p, result, i)
	end

	return result
end

local v3 = 4
local flag = false

local function fn2(p, list)
	local count = #list
	local v4 = {}

	for i = 1, v3 do
		v4[i] = {}
	end

	for k, _ in list do
		compressF32(p, list, k)

		for i = 1, v3 do
			v4[i][k] = v.des(p)
		end
	end

	for i = v3, 1, -1 do
		local v5 = v4[i]

		for i2 = count, 1, -1 do
			v.ser(p, v5[i2])
		end
	end

	if flag then
		return
	end

	vlq.ser(p, count)
end

local v4 = 4
local flag2 = true

local function fn3(p, list)
	local count = #list
	local v5 = {}

	for i = 1, v4 do
		v5[i] = {}
	end

	for k, _ in list do
		compressF32(p, list, k)

		for i = 1, v4 do
			v5[i][k] = v.des(p)
		end
	end

	for i = v4, 1, -1 do
		local v6 = v5[i]

		for i2 = count, 1, -1 do
			v.ser(p, v6[i2])
		end
	end

	if flag2 then
		return
	end

	vlq.ser(p, count)
end

local function compressI32(p, list, k: number)
	local v5 = list[k]
	i32.ser(p, v5)
	local des = i32.des(p)
	local v6 = des < 0 and 1 or 0
	local v7 = bit32.lshift(math.abs(des), 1) + v6
	u32.ser(p, v7)
end

local function decompressI32(p, _, _: number)
	local des = u32.des(p)
	local v5 = des % 2 > 0 and -1 or 1
	return bit32.rshift(des, 1) * v5
end

local v5 = 4

local function fn4(p)
	local des = vlq.des(p)
	local v6 = {}

	for i = 1, v5 do
		v6[i] = {}
	end

	for i = 1, v5 do
		local v7 = v6[i]

		for i2 = 1, des do
			v7[i2] = v.des(p)
		end
	end

	local result = {}

	for i = 1, des do
		for i2 = v5, 1, -1 do
			local v7 = v6[i2]
			v.ser(p, v7[i])
		end

		result[i] = decompressI32(p, result, i)
	end

	return result
end

local v6 = 4
local flag3 = false

local function fn5(p, list)
	local count = #list
	local v7 = {}

	for i = 1, v6 do
		v7[i] = {}
	end

	for k, _ in list do
		compressI32(p, list, k)

		for i = 1, v6 do
			v7[i][k] = v.des(p)
		end
	end

	for i = v6, 1, -1 do
		local v8 = v7[i]

		for i2 = count, 1, -1 do
			v.ser(p, v8[i2])
		end
	end

	if flag3 then
		return
	end

	vlq.ser(p, count)
end

local v7 = 4
local flag4 = true

local function fn6(p, offsets)
	local count = #offsets
	local v8 = {}

	for i = 1, v7 do
		v8[i] = {}
	end

	for k, _ in offsets do
		compressI32(p, offsets, k)

		for i = 1, v7 do
			v8[i][k] = v.des(p)
		end
	end

	for i = v7, 1, -1 do
		local v9 = v8[i]

		for i2 = count, 1, -1 do
			v.ser(p, v9[i2])
		end
	end

	if flag4 then
		return
	end

	vlq.ser(p, count)
end

local function serInterleavedRaw_Vector2(p, list, flag5: boolean?)
	local Xs = {}
	local Ys = {}

	for k, v8 in list do
		Xs[k] = v8.X
		Ys[k] = v8.Y
	end

	fn3(p, Ys)
	fn3(p, Xs)

	if not flag5 then
		vlq.ser(p, #list)
	end
end

local function serInterleaved_Vector2(p, p2)
	serInterleavedRaw_Vector2(p, p2, false)
end

local function desInterleaved_Vector2(p)
	local des = vlq.des(p)
	vlq.ser(p, des)
	local v8 = { (fn(p)) }
	vlq.ser(p, des)
	v8[2] = fn(p)
	local v9, v10 = unpack(v8)
	local vectors = {}

	for i = 1, des do
		vectors[i] = Vector2.new(v9[i], v10[i])
	end

	return vectors
end

local function serInterleaved_Vector3(p, list)
	local Xs = {}
	local Ys = {}
	local Zs = {}

	for k, v8 in list do
		Xs[k] = v8.X
		Ys[k] = v8.Y
		Zs[k] = v8.Z
	end

	fn3(p, Zs)
	fn3(p, Ys)
	fn3(p, Xs)
	vlq.ser(p, #list)
end

local function serInterleavedRaw_UDim(p, list, flag5: boolean)
	local scales = {}
	local offsets = {}

	for k, v8 in list do
		scales[k] = v8.Scale
		offsets[k] = v8.Offset
	end

	fn6(p, offsets)
	fn3(p, scales)

	if not flag5 then
		vlq.ser(p, #list)
	end
end

local function fn7(p)
	local des = vlq.des(p)
	vlq.ser(p, des)
	local v8 = fn(p)
	vlq.ser(p, des)
	local v9 = fn4(p)
	local uDims = {}

	for i = 1, des do
		uDims[i] = UDim.new(v8[i], v9[i])
	end

	return uDims
end

local function serInterleaved_UDim2(p, list)
	local Xs = {}
	local Ys = {}

	for k, v8 in list do
		Xs[k] = v8.X
		Ys[k] = v8.Y
	end

	serInterleavedRaw_UDim(p, Ys, true)
	serInterleavedRaw_UDim(p, Xs, true)
	vlq.ser(p, #list)
end

local function desInterleaved_UDim2(p)
	local des = vlq.des(p)
	vlq.ser(p, des)
	local v8 = { (fn7(p)) }
	vlq.ser(p, des)
	v8[2] = fn7(p)
	local v9, v10 = unpack(v8)
	local uDims = {}

	for i = 1, des do
		uDims[i] = UDim2.new(v9[i], v10[i])
	end

	return uDims
end

local function serInterleaved_Rect(p, list)
	local mins = {}
	local maxes = {}

	for k, v8 in list do
		mins[k] = v8.Min
		maxes[k] = v8.Max
	end

	serInterleavedRaw_Vector2(p, maxes, true)
	serInterleavedRaw_Vector2(p, mins, true)
	vlq.ser(p, #list)
end

local function desInterleaved_Rect(p)
	local des = vlq.des(p)
	vlq.ser(p, des)
	local v8 = { (desInterleaved_Vector2(p)) }
	vlq.ser(p, des)
	v8[2] = desInterleaved_Vector2(p)
	local v9, v10 = unpack(v8)
	local rects = {}

	for i = 1, des do
		rects[i] = Rect.new(v9[i], v10[i])
	end

	return rects
end

local function createSerAccumulated(callback)
	return function(p, items)
		local v8 = 0
		local v9 = {}

		for k, item in items do
			v9[k] = item - v8
			v8 = item
		end

		callback(p, v9)
	end
end

local function createDesAccumulated(callback)
	return function(p)
		local v8 = callback(p)
		local total = 0
		local result = {}

		for k, v9 in v8 do
			total += v9
			result[k] = total
		end

		return result
	end
end

return table.freeze({
	Interleaved = table.freeze({
		F32 = table.freeze({
			ser = fn2,
			des = fn
		}),
		I32 = table.freeze({
			ser = fn5,
			des = fn4
		}),
		BrickColor = table.freeze({
			ser = function(p, items)
				local numbers = {}

				for k, item in items do
					numbers[k] = item.Number
				end

				fn5(p, numbers)
			end,
			des = function(p)
				local v8 = fn4(p)
				local brickColors = {}

				for k, v9 in v8 do
					brickColors[k] = BrickColor.new(v9)
				end

				return brickColors
			end
		}),
		Color3 = table.freeze({
			ser = function(p, list)
				local Rs = {}
				local Gs = {}
				local Bs = {}

				for k, v8 in list do
					Rs[k] = v8.R
					Gs[k] = v8.G
					Bs[k] = v8.B
				end

				fn3(p, Bs)
				fn3(p, Gs)
				fn3(p, Rs)
				vlq.ser(p, #list)
			end,
			des = function(p)
				local des = vlq.des(p)
				local v8 = {}

				for i = 1, 3 do
					vlq.ser(p, des)
					v8[i] = fn(p)
				end

				local v9, v10, v11 = unpack(v8)
				local colors = {}

				for i = 1, des do
					colors[i] = Color3.new(v9[i], v10[i], v11[i])
				end

				return colors
			end
		}),
		Rect = table.freeze({
			ser = serInterleaved_Rect,
			des = desInterleaved_Rect
		}),
		Vector2 = table.freeze({
			ser = serInterleaved_Vector2,
			des = desInterleaved_Vector2
		}),
		Vector3 = table.freeze({
			ser = serInterleaved_Vector3,
			des = function(p)
				local des = vlq.des(p)
				local v8 = {}

				for i = 1, 3 do
					vlq.ser(p, des)
					v8[i] = fn(p)
				end

				local v9, v10, v11 = unpack(v8)
				local vectors = {}

				for i = 1, des do
					vectors[i] = Vector3.new(v9[i], v10[i], v11[i])
				end

				return vectors
			end
		}),
		UDim = table.freeze({
			ser = function(p, p2)
				serInterleavedRaw_UDim(p, p2, false)
			end,
			des = fn7
		}),
		UDim2 = table.freeze({
			ser = serInterleaved_UDim2,
			des = desInterleaved_UDim2
		})
	}),
	Accumulated = table.freeze({
		F32 = table.freeze({
			ser = function(p, items)
				local v8 = 0
				local v9 = {}

				for k, item in items do
					v9[k] = item - v8
					v8 = item
				end

				fn2(p, v9)
			end,
			des = function(p)
				local v8 = fn(p)
				local total = 0
				local result = {}

				for k, v9 in v8 do
					total += v9
					result[k] = total
				end

				return result
			end
		}),
		I32 = table.freeze({
			ser = function(p, items)
				local v8 = 0
				local v9 = {}

				for k, item in items do
					v9[k] = item - v8
					v8 = item
				end

				fn5(p, v9)
			end,
			des = function(p)
				local v8 = fn4(p)
				local total = 0
				local result = {}

				for k, v9 in v8 do
					total += v9
					result[k] = total
				end

				return result
			end
		})
	})
})