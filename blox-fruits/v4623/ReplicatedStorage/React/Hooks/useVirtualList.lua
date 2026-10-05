local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.Spring)
require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useSpringEffect = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringEffect)
return function(flag: boolean, point: Vector2, value: number?, p, udim: UDim2, udim2: UDim2, udim3: UDim2, rect: Rect, point2: Vector2, p2, p3, point3: Vector2?, p4, p5, callback, callback2)
	local v = p3 or Enum.ScrollingDirection.XY
	assert(v, "ScrollingDirection must be set")
	local v2 = value or 0
	assert(v2, "PreRenderDistance must be set")
	local vector = Vector2.new(math.round(rect.Width), (math.round(rect.Height)))
	local vector2 = Vector2.new(math.round(rect.Min.X), (math.round(rect.Min.Y)))
	local borderPaddingPx = React.useMemo(function()
		local offset = math.round(udim3.X.Offset)
		local X = vector.X
		local v4

		if p == Enum.SizeConstraint.RelativeYY then
			v4 = udim3.Y.Scale
		else
			v4 = udim3.X.Scale
		end

		local v5 = offset + math.round(X * v4)
		local offset2 = math.round(udim3.Y.Offset)
		local Y = vector.Y
		local v6

		if p == Enum.SizeConstraint.RelativeXX then
			v6 = udim3.X.Scale
		else
			v6 = udim3.Y.Scale
		end

		return Vector2.new(v5, offset2 + math.round(Y * v6))
	end, {
		udim3,
		math.round(vector.X),
		math.round(vector.Y),
		p
	})
	local v4 = React.useMemo(function()
		return vector - borderPaddingPx * 2
	end, {
		math.round(vector.X),
		math.round(vector.Y),
		math.round(borderPaddingPx.X),
		(math.round(borderPaddingPx.Y))
	})
	local paddingPx = React.useMemo(function()
		local offset = math.round(udim2.X.Offset)
		local X = v4.X
		local v6

		if p == Enum.SizeConstraint.RelativeYY then
			v6 = udim2.Y.Scale
		else
			v6 = udim2.X.Scale
		end

		local v7 = offset + math.round(X * v6)
		local offset2 = math.round(udim2.Y.Offset)
		local Y = v4.Y
		local v8

		if p == Enum.SizeConstraint.RelativeXX then
			v8 = udim2.X.Scale
		else
			v8 = udim2.Y.Scale
		end

		return Vector2.new(v7, offset2 + math.round(Y * v8))
	end, {
		udim2,
		math.round(v4.X),
		math.round(v4.Y),
		p
	})
	local sizePx = React.useMemo(function()
		local vector3 = point

		if v == Enum.ScrollingDirection.XY or v == Enum.ScrollingDirection.X then
			local v8 = math.max(1, math.round(udim.X.Offset) + math.round(udim.X.Scale * v4.X))
			vector3 = Vector2.new(v4.X / v8, point.Y)
		end

		if v == Enum.ScrollingDirection.XY or v == Enum.ScrollingDirection.Y then
			local v8 = math.max(1, math.round(udim.Y.Offset) + math.round(udim.Y.Scale * v4.Y))
			vector3 = Vector2.new(point.X, v4.Y / v8)
		end

		local v8 = v4 - paddingPx * (vector3 - Vector2.new(1, 1))

		if p == Enum.SizeConstraint.RelativeYY then
			return Vector2.new(
				math.max(1, math.round(udim.X.Offset) + math.round(udim.X.Scale * v8.Y)),
				(math.max(1, math.round(udim.Y.Offset) + math.round(udim.Y.Scale * v8.Y)))
			)
		end

		if p == Enum.SizeConstraint.RelativeXX then
			return Vector2.new(
				math.max(1, math.round(udim.X.Offset) + math.round(udim.X.Scale * v8.X)),
				(math.max(1, math.round(udim.Y.Offset) + math.round(udim.Y.Scale * v8.X)))
			)
		end

		return Vector2.new(
			math.max(1, math.round(udim.X.Offset) + math.round(udim.X.Scale * v8.X)),
			(math.max(1, math.round(udim.Y.Offset) + math.round(udim.Y.Scale * v8.Y)))
		)
	end, {
		udim,
		math.round(v4.X),
		math.round(v4.Y),
		math.round(point.X),
		math.round(point.Y),
		p,
		math.round(borderPaddingPx.X),
		math.round(borderPaddingPx.Y),
		math.round(paddingPx.X),
		math.round(paddingPx.Y),
		v
	})
	local v7 = React.useMemo(function()
		return Vector2.new(sizePx.X + paddingPx.X, sizePx.Y + paddingPx.Y) * v2
	end, {
		sizePx.X,
		sizePx.Y,
		v2,
		paddingPx.X,
		paddingPx.Y
	})
	local v8 = React.useMemo(function()
		local v9 = math.max(1, point.X)
		local v10 = math.max(1, point.Y)
		return Vector2.new(
			math.round(v9 * sizePx.X + (v9 - 1) * paddingPx.X + borderPaddingPx.X * 2),
			(math.round(v10 * sizePx.Y + (v10 - 1) * paddingPx.Y + borderPaddingPx.Y * 2))
		)
	end, {
		sizePx,
		paddingPx,
		borderPaddingPx,
		point
	})
	local useMemo = React.useMemo

	local function fn()
		if not point3 then
			return point2
		end

		local v9 = math.max(1, (math.min(point.X, point3.X)))
		local v10 = math.max(1, (math.min(point.Y, point3.Y)))
		local v11 = (v9 - 1) * (sizePx.X + paddingPx.X) + borderPaddingPx.X
		local v12 = (v10 - 1) * (sizePx.Y + paddingPx.Y) + borderPaddingPx.Y
		return Vector2.new(
			math.max(0, (math.min(v8.X - vector.X, v11 - vector.X / 2 + sizePx.X / 2))),
			(math.max(0, (math.min(v8.Y - vector.Y, v12 - vector.Y / 2 + sizePx.Y / 2))))
		)
	end

	local X

	if point3 then
		X = math.round(point3.X)
	end

	local v10

	if point3 then
		v10 = math.round(point3.Y)
	end

	local zero = useMemo(fn, {
		X,
		v10,
		math.round(sizePx.X),
		math.round(sizePx.Y),
		math.round(paddingPx.X),
		math.round(paddingPx.Y),
		math.round(borderPaddingPx.X),
		math.round(borderPaddingPx.Y),
		math.round(point.X),
		math.round(point.Y),
		math.round(vector.X),
		math.round(vector.Y),
		math.round(point2.X),
		math.round(point2.Y),
		math.round(v8.X),
		(math.round(v8.Y))
	})
	local v11 = React.useMemo(function()
		return Rect.new(zero.X, zero.Y, zero.X + vector.X, zero.Y + vector.Y)
	end, {
		math.round(vector.X),
		math.round(vector.Y),
		math.round(zero.X),
		(math.round(zero.Y))
	})
	local v12 = React.useMemo(function()
		local v13 = math.max(
			borderPaddingPx.X,
			v11.Min.Y - v11.Min.Y % (sizePx.Y + paddingPx.Y) + borderPaddingPx.Y - v7.Y
		)
		local result = table.create((math.max(
			0,
			(math.ceil((v11.Max.Y - v13 - borderPaddingPx.Y + paddingPx.Y) / (sizePx.Y + paddingPx.Y)))
		)))
		local v14 = 1

		repeat
			result[v14] = v13
			v13 += sizePx.Y + paddingPx.Y
			v14 += 1
		until v11.Max.Y - borderPaddingPx.Y + v7.Y < v13 or point.Y < v14

		table.freeze(result)
		return result
	end, {
		math.round(v11.Min.Y),
		math.round(v11.Max.Y),
		math.round(sizePx.Y),
		math.round(paddingPx.Y),
		math.round(borderPaddingPx.Y),
		math.round(point.Y),
		(math.round(v7.Y))
	})
	local v13 = React.useMemo(function()
		local v14 = math.max(
			borderPaddingPx.X,
			v11.Min.X - v11.Min.X % (sizePx.X + paddingPx.X) + borderPaddingPx.X - v7.X
		)
		local result = table.create((math.max(
			0,
			(math.ceil((v11.Max.X - v14 - borderPaddingPx.X + paddingPx.X) / (sizePx.X + paddingPx.X)))
		)))
		local v15 = 1

		repeat
			result[v15] = v14
			v14 += sizePx.X + paddingPx.X
			v15 += 1
		until v11.Max.X - borderPaddingPx.X + v7.X < v14 or point.X < v15

		table.freeze(result)
		return result
	end, {
		math.round(v11.Min.X),
		math.round(v11.Max.X),
		math.round(sizePx.X),
		math.round(paddingPx.X),
		math.round(borderPaddingPx.X),
		math.round(point.X),
		(math.round(v7.X))
	})
	local v14 = React.useMemo(function()
		local vectors = table.create(#v13 * #v12)
		local count = 0

		for _, v15 in ipairs(v13) do
			for _, v16 in ipairs(v12) do
				count += 1
				vectors[count] = Vector2.new(v15, v16)
			end
		end

		table.freeze(vectors)
		return vectors
	end, { v12, v13 })
	local useMemo2 = React.useMemo

	local function fn2()
		if point3 then
			return nil
		end

		return v11.Min + Vector2.new(v11.Width, v11.Height) / 2
	end

	local X2 = math.ceil(v11.Min.X)
	local Y = math.ceil(v11.Min.Y)
	local width = math.ceil(v11.Width)
	local height = math.ceil(v11.Height)
	local X3

	if point3 then
		X3 = math.ceil(point3.X)
	end

	local v16

	if point3 then
		v16 = math.ceil(point3.Y)
	end

	local point4 = useMemo2(fn2, {
		X2,
		Y,
		width,
		height,
		X3,
		v16
	})
	local useMemo3 = React.useMemo

	local function fn3()
		local result = {}

		for _, positionPx in ipairs(v14) do
			local v18 = math.floor((positionPx.X - borderPaddingPx.X) / (sizePx.X + paddingPx.X)) + 1
			local v19 = math.floor((positionPx.Y - borderPaddingPx.Y) / (sizePx.Y + paddingPx.Y)) + 1
			local formatted = `card[{v18},{v19}]`
			local isFocused

			if point4 then
				if positionPx.X <= point4.X and point4.X <= positionPx.X + sizePx.X and positionPx.Y <= point4.Y then
					isFocused = point4.Y <= positionPx.Y + sizePx.Y
				else
					isFocused = false
				end
			elseif point3 and v18 == point3.X then
				isFocused = v19 == point3.Y
			else
				isFocused = false
			end

			result[formatted] = table.freeze({
				IsFocused = isFocused,
				AbsolutePositionPx = vector2 + positionPx - v11.Min,
				Index = Vector2.new(v18, v19),
				SizePx = sizePx,
				PositionPx = positionPx,
				CanvasSizePx = v8,
				PaddingPx = paddingPx
			})
		end

		table.freeze(result)
		return result
	end

	local X4

	if point3 then
		X4 = math.round(point3.X)
	end

	local Y2

	if point3 then
		Y2 = math.round(point3.Y)
	end

	local X5

	if point4 then
		X5 = math.round(point4.X)
	end

	local v18

	if point4 then
		v18 = math.round(point4.Y)
	end

	local cards = useMemo3(fn3, {
		v14,
		X4,
		Y2,
		X5,
		v18,
		math.round(v8.X),
		math.round(v8.Y),
		math.round(sizePx.X),
		math.round(sizePx.Y),
		math.round(paddingPx.X),
		math.round(paddingPx.Y),
		math.round(borderPaddingPx.X),
		math.round(borderPaddingPx.Y),
		math.round(vector2.X),
		(math.round(vector2.Y))
	})
	local current = p2.current

	if current then
		current.ScrollingEnabled = point3 == nil

		if point3 and p5 == nil and p4 == nil then
			current.CanvasPosition = zero
		end
	else
		zero = Vector2.zero
	end

	local ref = React.useRef(v8)
	ref.current = v8

	if p5 then
		local v21 = zero.X / v8.X
		local v22 = flag and point3 ~= nil

		local function fn4(p6: number, _: number)
			local current2 = p2.current

			if current2 and current2:IsA("ScrollingFrame") then
				current2.CanvasPosition = Vector2.new(
					math.clamp(p6 * ref.current.X, 0, ref.current.X),
					current2.CanvasPosition.Y
				)
			end
		end

		local v24

		if p2.current and p2.current:IsA("ScrollingFrame") then
			v24 = p2.current.CanvasPosition.X / ref.current.X or nil
		end

		useSpringEffect(v21, p5, v22, fn4, nil, callback2, v24)
	end

	if p4 then
		useSpringEffect(zero.Y / v8.Y, p4, flag and point3 ~= nil, function(p6: number, _: number)
			local current2 = p2.current

			if current2 and current2:IsA("ScrollingFrame") then
				current2.CanvasPosition = Vector2.new(
					current2.CanvasPosition.Y,
					(math.clamp(p6 * ref.current.Y, 0, ref.current.Y))
				)
			end
		end, nil, callback, p2.current and p2.current:IsA("ScrollingFrame") and p2.current.CanvasPosition.Y / ref.current.Y or nil)
	end

	local canvasAreaPx = React.useMemo(function()
		return Rect.new(zero.X, zero.Y, zero.X + v8.X, zero.Y + v8.Y)
	end, {
		math.round(zero.X),
		math.round(zero.Y),
		math.round(v8.X),
		(math.round(v8.Y))
	})
	local useMemo4 = React.useMemo

	local function fn4()
		local v21 = {
			Cards = cards,
			CanvasAreaPx = canvasAreaPx,
			BorderPaddingPx = borderPaddingPx,
			FocusCenteredCanvasPosition = 0
		}
		local focusCenteredCanvasPosition

		if point3 then
			focusCenteredCanvasPosition = zero
		end

		v21.FocusCenteredCanvasPosition = focusCenteredCanvasPosition
		table.freeze(v21)
		return v21
	end

	local X6 = math.round(borderPaddingPx.X)
	local Y3 = math.round(borderPaddingPx.Y)
	local X7

	if point3 then
		X7 = math.round(zero.X)
	end

	local v22

	if point3 then
		v22 = math.round(zero.Y)
	end

	return useMemo4(fn4, {
		cards,
		X6,
		Y3,
		canvasAreaPx,
		X7,
		v22
	})
end