local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local PALETTE = CONSTANTS.COLOR.PALETTE
local badgeStar = SpriteMap.UI["Badge Star"]
local color = Color3.fromRGB(255, 173, 30)
local vector = Vector2.new(0.5, 0.5)
local v = { "Wave" }
local v2 = {
	Wave = 1.6,
	Infinity = 5,
	Ring = 8
}
local v3 = {
	{
		Key = "Wave",
		Formation = "Wave",
		IsMirror = false,
		IsClosed = false
	}
}
local createElement = React.createElement

-- equivalent calls inferred from this helper; original call sites unknown
local function ease(value: number, p, p2)
	return TweenService:GetValue(math.clamp(value, 0, 1), p, p2 or Enum.EasingDirection.Out)
end

local function formationPoint(p: string, p2: number, flag: boolean)
	local v4 = flag and -1 or 1
	local v5 = p2 * 6.283185307179586

	if p == "Wave" then
		if flag then
			p2 = 1 - p2
		end

		return Vector2.new(p2 * 0.9 + 0.05, v4 * 0.09 * math.sin(v5 * 3) + 0.5)
	elseif p == "Infinity" then
		return Vector2.new(math.sin(v5) * 0.315 + 0.5, v4 * 0.26 * math.sin(v5) * math.cos(v5) + 0.5)
	else
		return Vector2.new(math.cos(v4 * v5) * 0.33 + 0.5, math.sin(v4 * v5) * 0.30000000000000004 + 0.5)
	end
end

local function buildControlPoints(data)
	local v4 = table.create(48)

	for i = 1, 48 do
		local v5

		if data.IsClosed then
			v5 = (i - 1) / 48
		else
			v5 = (i - 1) / 47
		end

		v4[i] = formationPoint(data.Formation, v5, data.IsMirror)
	end

	local result = table.create(49)

	for k, v5 in v4 do
		local v6

		if k == 1 then
			v6 = data.IsClosed and 48 or 1
		else
			v6 = k - 1
		end

		local point = v4[v6]
		local v7

		if k == 48 then
			v7 = data.IsClosed and 1 or 48
		else
			v7 = k + 1
		end

		local v8 = (v4[v7] - point) / 6
		result[k] = Path2DControlPoint.new(
			UDim2.fromScale(v5.X, v5.Y),
			UDim2.fromScale(-v8.X, -v8.Y),
			UDim2.fromScale(v8.X, v8.Y)
		)
	end

	if data.IsClosed then
		result[49] = result[1]
	end

	return result
end

local function getBeat(p: number)
	local v4 = math.floor(p / 4)
	local sinceSwitch = p - v4 * 4
	local v6 = {
		Current = v[v4 % #v + 1],
		Previous = v[(v4 - 1) % #v + 1],
		Blend = 0,
		Index = 0,
		SinceSwitch = 0
	}
	local v7 = sinceSwitch / 0.75
	local quad = Enum.EasingStyle.Quad
	local inOut = Enum.EasingDirection.InOut
	v6.Blend = TweenService:GetValue(math.clamp(v7, 0, 1), quad, inOut or Enum.EasingDirection.Out)
	v6.Index = v4
	v6.SinceSwitch = sinceSwitch
	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function samplePath(object, value: number)
	local positionOnCurveArcLength = object:GetPositionOnCurveArcLength((math.clamp(value, 0, 1)))
	return Vector2.new(positionOnCurveArcLength.X.Scale, positionOnCurveArcLength.Y.Scale)
end

local function sampleFormation(p, p2: string, value: number, flag: boolean)
	if p2 == "Wave" then
		local v4 = p[flag and "WaveMirror" or "Wave"]

		if not v4 then
			return nil
		end

		local positionOnCurveArcLength = v4:GetPositionOnCurveArcLength((math.clamp(value, 0, 1)))
		return (Vector2.new(positionOnCurveArcLength.X.Scale, positionOnCurveArcLength.Y.Scale))
	else
		local v4 = p[p2]

		if not v4 then
			return nil
		end

		if p2 == "Ring" then
			if flag then
				value = (1 - value) % 1
			end

			return samplePath(v4, value)
		else
			local point = samplePath(v4, value) -- equivalent call inferred; original call site unknown

			if flag then
				return (Vector2.new(point.X, 1 - point.Y))
			end

			return point
		end
	end
end

local function evaluate(p, p2: string, p3: number, p4: number, flag: boolean)
	local v4 = (p3 / v2[p2] + p4) % 1
	local v5 = p2 ~= "Wave" and 1 or math.clamp(math.min(v4, 1 - v4) / 0.08, 0, 1)
	return sampleFormation(p, p2, v4, flag) or formationPoint(p2, v4, flag), v5
end

local function getHeading(paths, current: string, p: number, p2: number, flag: boolean, p3: number)
	local v4 = (p / v2[current] + p2) % 1
	local v5 = current ~= "Wave" and 0.004 or math.min(0.004, 1 - v4)
	local v6 = sampleFormation(paths, current, v4, flag) or formationPoint(current, v4, flag)
	local v7 = sampleFormation(paths, current, (v4 + v5) % 1, flag) or formationPoint(current, v4 + v5, flag)
	return (math.deg((math.atan2(v7.Y - v6.Y, (v7.X - v6.X) * p3))))
end

local function stepDancers(data, p: number, beat)
	local v4 = data.Root.AbsoluteSize.X / math.max(data.Root.AbsoluteSize.Y, 1)

	for i = 1, data.IslandCount + 8 do
		local dancer = data.Dancers[i]

		if not dancer then
			continue
		end

		local v5 = data.IslandCount < i
		local v6

		if v5 then
			v6 = (i - data.IslandCount - 0.5) / 8
		else
			v6 = (i - 1) / math.max(data.IslandCount, 1)
		end

		local v8 = ease((p - (i - 1) * 0.045) / 0.4, Enum.EasingStyle.Back) -- equivalent call inferred; original call site unknown
		local paths = data.Paths
		local current = beat.Current
		local v9 = (p / v2[current] + v6) % 1
		local v10 = current ~= "Wave" and 1 or math.clamp(math.min(v9, 1 - v9) / 0.08, 0, 1)
		local v11 = sampleFormation(paths, current, v9, v5) or formationPoint(current, v9, v5)
		local v12

		if beat.Index == 0 then
			v12 = vector:Lerp(v11, beat.Blend)
		else
			local paths2 = data.Paths
			local previous = beat.Previous
			local v13 = (p / v2[previous] + v6) % 1
			local v14 = previous ~= "Wave" and 1 or math.clamp(math.min(v13, 1 - v13) / 0.08, 0, 1)
			v12 = (sampleFormation(paths2, previous, v13, v5) or formationPoint(previous, v13, v5)):Lerp(
				v11,
				beat.Blend
			)
			v10 = v14 + (v10 - v14) * beat.Blend
		end

		local heading = getHeading(data.Paths, beat.Current, p, v6, v5, v4)
		local v13 = (v5 and 0.05 or 0.085) * v8 * (data.Pulse * 0.15 + 1)
		dancer.Position = UDim2.fromScale(v12.X, v12.Y)
		dancer.Size = UDim2.fromScale(v13, v13)
		local rotation

		if v5 then
			rotation = p * 120 + i * 40
		else
			rotation = math.clamp(heading * 0.35, -30, 30)
		end

		dancer.Rotation = rotation
		dancer.ImageTransparency = 1 - math.clamp(v8, 0, 1) * v10
	end
end

local function stepRail(data, p, p2: number)
	local path = data.Paths[p.Key]
	local rail = data.Rails[p.Key]

	if not (path and rail) then
		return
	end

	local absoluteSize = data.Root.AbsoluteSize
	local backgroundTransparency = 1 - p2 * 0.65 * (data.Pulse * 0.2 + 0.8)
	local v5 = (data.Pulse * 0.5 + 1) * 3

	for i = 1, 40 do
		local v6 = rail[i]

		if not v6 then
			continue
		end

		if p2 <= 0 then
			v6.BackgroundTransparency = 1
		else
			local point = samplePath(path, (i - 1) / 40) -- equivalent call inferred; original call site unknown
			local v7

			if p.IsClosed then
				v7 = i % 40 / 40
			else
				v7 = i / 40
			end

			local point2 = samplePath(path, v7) -- equivalent call inferred; original call site unknown
			local v8 = (point2 - point) * absoluteSize
			local midpoint = (point + point2) / 2
			v6.Position = UDim2.fromScale(midpoint.X, midpoint.Y)
			v6.Size = UDim2.fromOffset(v8.Magnitude + 2, v5)
			v6.Rotation = math.deg((math.atan2(v8.Y, v8.X)))
			v6.BackgroundTransparency = backgroundTransparency
		end
	end
end

local function stepRails(p, p2: number, beat)
	local v5 = ease(p2 / 0.4, Enum.EasingStyle.Quad) -- equivalent call inferred; original call site unknown

	for _, v6 in v3 do
		local v7

		if v6.Formation == beat.Current then
			v7 = beat.Blend
		else
			v7 = (v6.Formation ~= beat.Previous or not (beat.Index > 0)) and 0 or 1 - beat.Blend
		end

		stepRail(p, v6, v7 * v5)
	end
end

local function stepRings(data, p: number, beat)
	for k, ring in data.Rings do
		local uIStroke = ring:FindFirstChildOfClass("UIStroke")
		local v4 = (p / 0.8 + (k - 1) / 0) % 1
		local quad = Enum.EasingStyle.Quad
		local v5 = TweenService:GetValue(math.clamp(v4, 0, 1), quad, Enum.EasingDirection.Out) * 0.55 * (data.Pulse * 0.2 + 1)
		ring.Size = UDim2.fromScale(v5 * 2, v5 * 2)

		if not uIStroke then
			continue
		end

		uIStroke.Transparency = v4 * 0.7 + 0.3
		uIStroke.Thickness = (1 - v4 * 0.8) * 5 * (data.Pulse + 1)
	end

	local shock = data.Shock
	local uIStroke

	if shock then
		uIStroke = shock:FindFirstChildOfClass("UIStroke")
	end

	if shock and uIStroke then
		local v4 = math.clamp(beat.SinceSwitch / 0.9, 0, 1)
		local quart = Enum.EasingStyle.Quart
		local v5 = TweenService:GetValue(math.clamp(v4, 0, 1), quart, Enum.EasingDirection.Out) * 0.8
		shock.Size = UDim2.fromScale(v5 * 2, v5 * 2)
		uIStroke.Transparency = v4 >= 1 and 1 or v4 ^ 0.5
		uIStroke.Thickness = (1 - v4) * 12
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function step(p, p2: number)
	local v4 = p2 - 0.6

	if v4 < 0 then
		return
	end

	local beat = getBeat(v4)
	stepDancers(p, v4, beat)
	stepRails(p, v4, beat)
	stepRings(p, v4, beat)
end

return function(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef({})
	local ref3 = React.useRef({})
	local ref4 = React.useRef({})
	local ref5 = React.useRef({})
	local ref6 = React.useRef(nil)
	local ref7 = React.useRef(props.Pulse)
	ref7.current = props.Pulse
	local islands = props.Islands
	local isPlaying = props.IsPlaying
	React.useEffect(function()
		for _, v4 in v3 do
			local v5 = ref3.current[v4.Key]

			if v5 then
				v5:SetControlPoints((buildControlPoints(v4)))
			end
		end
	end, {})
	React.useEffect(function()
		local current = ref.current

		if isPlaying and current then
			local lastTime = os.clock()
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				step({
					Root = current,
					Dancers = ref2.current,
					Paths = ref3.current,
					Rails = ref4.current,
					Rings = ref5.current,
					Shock = ref6.current,
					IslandCount = #islands,
					Pulse = ref7.current
				}, os.clock() - lastTime) -- equivalent call inferred; original call site unknown
			end)
			return function()
				renderSteppedConnection:Disconnect()
			end
		else
			return function() end
		end
	end, { isPlaying, islands })
	local children = {}

	for _, v4 in v3 do
		local v5 = v4
		children[`Path{v4.Key}`] = createElement("Path2D", {
			Visible = false,
			ref = function(p)
				ref3.current[v5.Key] = p
			end
		})
	end

	for i = 1, #islands do
		local island = islands[i]
		local icon

		if island then
			icon = island.Display.Icon
		else
			icon = badgeStar
		end

		local formatted = `Dancer{i}`
		local v6 = i
		local v7 = {
			ref = function(p)
				ref2.current[v6] = p
			end,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(vector.X, vector.Y),
			Size = UDim2.fromScale(0, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Image = icon.Image,
			ImageRectOffset = icon.ImageRectOffset,
			ImageRectSize = icon.ImageRectSize,
			ImageColor3 = PALETTE.WHITE,
			ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Active = false,
			ZIndex = 0
		}
		local zIndex

		if island then
			zIndex = CONSTANTS.LAYER.RAISED_HIGH
		else
			zIndex = CONSTANTS.LAYER.RAISED
		end

		v7.ZIndex = zIndex
		local v9 = {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			}),
			Glow = 0
		}
		local color2

		if island then
			color2 = PALETTE.WHITE
		else
			color2 = color
		end

		v9.Glow = createElement("UIShadow", {
			Color = color2,
			BlurRadius = UDim.new(0.5, 0),
			Spread = UDim2.fromScale(0.15, 0.15),
			Transparency = 0.35
		})
		children[formatted] = createElement("ImageLabel", v7, v9)
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		ref = ref,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false
	}, props), children)
end