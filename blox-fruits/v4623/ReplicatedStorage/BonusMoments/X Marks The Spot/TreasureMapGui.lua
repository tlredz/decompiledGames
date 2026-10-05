local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Sound = require(ReplicatedStorage.Util.Sound)
local Config = require(script.Parent.Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function playUi(p: string)
	pcall(function()
		Sound:Play(p)
	end)
end

local v = {}
local TreasureMapGui = {}
TreasureMapGui.__index = TreasureMapGui

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveMapPosition(MAP_POSITION: UDim2, point: Vector2)
	return Vector2.new(
		MAP_POSITION.X.Scale * point.X + MAP_POSITION.X.Offset,
		MAP_POSITION.Y.Scale * point.Y + MAP_POSITION.Y.Offset
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRoutePoint(data, p: number)
	local v2 = 3.141592653589793 * data.curveCount * p
	local v3 = math.sin(3.141592653589793 * p)
	return data.start:Lerp(data.finish, p) + data.perpendicular * math.sin(v2) * v3 * data.curveHeight
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRouteTangent(geometry, segmentProgress: number)
	local v2 = 3.141592653589793 * geometry.curveCount * segmentProgress
	local v3 = 3.141592653589793 * segmentProgress
	local v4 = 3.141592653589793 * (geometry.curveCount * math.cos(v2) * math.sin(v3) + math.sin(v2) * math.cos(v3))
	return geometry.finish - geometry.start + geometry.perpendicular * v4 * geometry.curveHeight
end

local function getRouteLength(data)
	local start = data.start
	local total = 0

	for i = 1, Config.ROUTE_LENGTH_SAMPLES do
		local routePoint = getRoutePoint(data, i / Config.ROUTE_LENGTH_SAMPLES) -- equivalent call inferred; original call site unknown
		total += (routePoint - start).Magnitude
		start = routePoint
	end

	return total
end

local function getRouteProgress(data, p: number)
	local v2 = data.routeLength * p
	local start = data.start
	local total = 0

	for i = 1, Config.ROUTE_LENGTH_SAMPLES do
		local routePoint = getRoutePoint(data, i / Config.ROUTE_LENGTH_SAMPLES) -- equivalent call inferred; original call site unknown
		local magnitude = (routePoint - start).Magnitude

		if v2 <= total + magnitude then
			local v4 = not (magnitude > 0) and 0 or (v2 - total) / magnitude
			return (i - 1 + v4) / Config.ROUTE_LENGTH_SAMPLES
		else
			total += magnitude
			start = routePoint
		end
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRouteDrawDuration(p: number)
	return Config.ROUTE_DRAW_INTERVAL * math.max(p - 1, 0)
end

local function getRouteGeometry(p: number, point: Vector2, p2: number, p3: number)
	if point.X <= 0 or point.Y <= 0 then
		return nil
	end

	local mapPosition = resolveMapPosition(Config.CHECKPOINTS[p].MAP_POSITION, point) -- equivalent call inferred; original call site unknown
	local mapPosition2 = resolveMapPosition(Config.CHECKPOINTS[p + 1].MAP_POSITION, point) -- equivalent call inferred; original call site unknown
	local v2 = mapPosition2 - mapPosition
	local v3 = Config.ROUTE_SEGMENT_SPACING_SCALE * point.X

	if v3 <= 0 or v2.Magnitude < v3 * 2 then
		return nil
	end

	local unit = v2.Unit
	local v4 = {
		start = mapPosition,
		finish = mapPosition2,
		perpendicular = Vector2.new(-unit.Y, unit.X),
		curveHeight = v2.Magnitude * Config.ROUTE_CURVE_AMOUNT * p2 * p3,
		curveCount = Config.ROUTE_CURVE_COUNT,
		routeLength = 0,
		segmentCount = 1,
		segmentProgresses = {}
	}
	v4.routeLength = getRouteLength(v4)
	v4.segmentCount = math.max(math.floor(v4.routeLength / v3) - 1, 1)

	for i = 1, v4.segmentCount do
		table.insert(v4.segmentProgresses, (getRouteProgress(v4, i / (v4.segmentCount + 1))))
	end

	return v4
end

function v.getClearance(p: number, data, items)
	local v2 = 1e999

	for k, item in items do
		for k2, segmentProgress in data.segmentProgresses do
			local routePoint = getRoutePoint(data, segmentProgress) -- equivalent call inferred; original call site unknown

			for k3, segmentProgress2 in item.segmentProgresses do
				if k ~= p - 1 or not (k2 <= Config.ROUTE_SHARED_ENDPOINT_IGNORE_SEGMENTS and #item.segmentProgresses - Config.ROUTE_SHARED_ENDPOINT_IGNORE_SEGMENTS < k3) then
					v2 = math.min(v2, (routePoint - getRoutePoint(item, segmentProgress2)).Magnitude)
				end
			end
		end
	end

	return v2
end

function v:removeOverlaps(items, p: number)
	local segmentProgresses = {}

	for _, segmentProgress in self.segmentProgresses do
		local routePoint = getRoutePoint(self, segmentProgress) -- equivalent call inferred; original call site unknown
		local flag = false

		for _, item in items do
			for _, segmentProgress2 in item.segmentProgresses do
				if not ((routePoint - getRoutePoint(item, segmentProgress2)).Magnitude < p) then
					continue
				end

				flag = true
				break
			end

			if flag then
				break
			end
		end

		if not flag then
			table.insert(segmentProgresses, segmentProgress)
		end
	end

	self.segmentProgresses = segmentProgresses
	self.segmentCount = #segmentProgresses
end

function v.chooseGeometry(p: number, point: Vector2, p2)
	local v2 = Vector2.new(
		Config.ROUTE_SEGMENT_SIZE.X.Scale * point.X + Config.ROUTE_SEGMENT_SIZE.X.Offset,
		Config.ROUTE_SEGMENT_SIZE.Y.Scale * point.Y + Config.ROUTE_SEGMENT_SIZE.Y.Offset
	).Magnitude + Config.ROUTE_INTER_ROUTE_PADDING_SCALE * point.X
	local v3 = p % 2 == 0 and -1 or 1
	local v4 = -1e999
	local v5 = nil

	for _, v6 in Config.ROUTE_CURVE_SCALES do
		local v7 = -1e999
		local v8 = nil

		for _, v9 in { v3, -v3 } do
			local routeGeometry = getRouteGeometry(p, point, v9, v6)

			if not routeGeometry then
				continue
			end

			local clearance = v.getClearance(p, routeGeometry, p2)

			if not (v7 < clearance) then
				continue
			end

			v8 = routeGeometry
			v7 = clearance
		end

		if v8 and v4 < v7 then
			v5 = v8
			v4 = v7
		end

		if not (v8 and v2 <= v7) then
			continue
		end

		v.removeOverlaps(v8, p2, v2)
		return v8
	end

	if v5 then
		v.removeOverlaps(v5, p2, v2)
	end

	return v5
end

local function routeSegment(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	React.useEffect(function()
		local current = ref.current
		local current2 = ref2.current

		if not (current and current2) then
			return
		end

		current.BackgroundColor3 = Config.ROUTE_COLOR
		current2.Color = Config.ROUTE_OUTLINE_COLOR

		if props.mode == "static" then
			current.Visible = true
			current.BackgroundTransparency = 0
			current2.Transparency = 0
		else
			current.Visible = props.mode == "shine"
			current.BackgroundTransparency = 0
			current2.Transparency = 0

			if props.mode == "animate" then
				local thread = task.delay(props.delay, function()
					current.Visible = true
				end)
				return function()
					pcall(task.cancel, thread)
				end
			end

			local v2 = nil
			local v3 = nil
			local thread = task.spawn(function()
				task.wait(props.delay)

				while true do
					current.BackgroundColor3 = Config.ROUTE_SHINE_COLOR
					current2.Color = Config.ROUTE_SHINE_COLOR
					local tweenInfo = TweenInfo.new(
						Config.ROUTE_SHINE_DURATION,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					)
					local tween = TweenService:Create(current, tweenInfo, {
						BackgroundColor3 = Config.ROUTE_COLOR
					})
					local tween2 = TweenService:Create(current2, tweenInfo, {
						Color = Config.ROUTE_OUTLINE_COLOR
					})
					v2 = tween
					v3 = tween2
					tween:Play()
					tween2:Play()
					task.wait(Config.ROUTE_SHINE_REPEAT_INTERVAL)
				end
			end)
			return function()
				pcall(task.cancel, thread)

				if v2 then
					v2:Cancel()
				end

				if v3 then
					v3:Cancel()
				end
			end
		end
	end, { props.animationGeneration, props.delay, props.mode })
	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Config.ROUTE_COLOR,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = props.position,
		Rotation = props.rotation,
		Size = Config.ROUTE_SEGMENT_SIZE,
		Visible = props.mode ~= "animate",
		ZIndex = 2
	}, {
		outline = React.createElement("UIStroke", {
			ref = ref2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Config.ROUTE_OUTLINE_COLOR,
			Thickness = Config.ROUTE_OUTLINE_THICKNESS,
			Transparency = 0
		})
	})
end

local function mapMarker(props)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local current = ref.current

		if not current then
			return
		end

		if props.mode ~= "active" then
			current.Scale = props.mode == "static" and 1 or 0
			return
		end

		current.Scale = Config.MARKER_POP_START_SCALE
		local v2 = nil

		local function playTween(tweenInfo, scale: number)
			local tween = TweenService:Create(current, tweenInfo, {
				Scale = scale
			})
			v2 = tween
			tween:Play()
			return tween.Completed:Wait() == Enum.PlaybackState.Completed
		end

		local thread = task.delay(props.delay, function()
			playUi(Config.MARKER_POP_SOUND) -- equivalent call inferred; original call site unknown

			if not playTween(
				TweenInfo.new(Config.MARKER_POP_GROW_DURATION, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				Config.MARKER_POP_PEAK_SCALE
			) then
				return
			end

			if not playTween(
				TweenInfo.new(Config.MARKER_POP_SETTLE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				1
			) then
				return
			end

			local tweenInfo = TweenInfo.new(
				Config.MARKER_BOUNCE_DURATION,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			)

			while true do
				task.wait(Config.MARKER_BOUNCE_COOLDOWN)

				if not (playTween(tweenInfo, Config.MARKER_BOUNCE_MAX_SCALE) and playTween(
					tweenInfo,
					Config.MARKER_BOUNCE_MIN_SCALE
				)) then
					break
				end
			end
		end)
		return function()
			pcall(task.cancel, thread)

			if v2 then
				v2:Cancel()
			end
		end
	end, { props.animationGeneration, props.delay, props.mode })
	return React.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = props.image,
		Position = props.position,
		ScaleType = Enum.ScaleType.Fit,
		Size = props.size,
		Visible = props.mode ~= "hidden",
		ZIndex = 3
	}, {
		uIScale = React.createElement("UIScale", {
			ref = ref,
			Scale = props.mode == "static" and 1 or props.mode ~= "active" and 0 or Config.MARKER_POP_START_SCALE
		})
	})
end

local function routeLine(props)
	local geometry = props.geometry
	React.useEffect(function()
		if props.mode ~= "animate" then
			return
		end

		local thread = task.delay(getRouteDrawDuration(geometry.segmentCount), function()
			props.onAnimated(props.routeIndex)
		end)
		return function()
			pcall(task.cancel, thread)
		end
	end, {
		props.animationGeneration,
		props.mode,
		props.routeIndex,
		geometry.segmentCount
	})
	local children = {}

	for k, segmentProgress in geometry.segmentProgresses do
		local routePoint = getRoutePoint(geometry, segmentProgress) -- equivalent call inferred; original call site unknown
		local routeTangent = getRouteTangent(geometry, segmentProgress) -- equivalent call inferred; original call site unknown
		local delay

		if props.mode == "shine" then
			delay = Config.ROUTE_SHINE_INTERVAL * (k - 1)
		else
			delay = Config.ROUTE_DRAW_INTERVAL * (k - 1)
		end

		children[`Segment{k}`] = React.createElement(routeSegment, {
			animationGeneration = props.animationGeneration,
			delay = delay,
			mode = props.mode,
			position = UDim2.fromScale(routePoint.X / props.mapSize.X, routePoint.Y / props.mapSize.Y),
			rotation = math.deg((math.atan2(routeTangent.Y, routeTangent.X)))
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

local function treasureMap(props)
	local ref = React.useRef(nil)
	local state, setState = React.useState(Vector2.zero)
	local state2, setState2 = React.useState(-1)
	local count = #Config.CHECKPOINTS
	local v2 = math.clamp(math.floor(props.progress), 0, count)
	local v3 = math.min(v2 + 1, count)
	local v4 = math.min(v2, count - 1)
	local v5 = props.open and state2 == props.openGeneration
	React.useEffect(function()
		local current = ref.current

		if not current then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateMapSize()
			setState(current.AbsoluteSize)
		end

		updateMapSize() -- equivalent call inferred; original call site unknown
		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateMapSize)
		return function()
			absoluteSizeChangedConnection:Disconnect()
		end
	end, {})
	React.useEffect(function()
		if not props.open then
			return
		end

		local current = ref.current

		if not current then
			return
		end

		local v6 = false
		local openGeneration = props.openGeneration
		local thread = task.spawn(function()
			local v7 = false

			if pcall(ContentProvider.PreloadAsync, ContentProvider, { current }, function(_: string, p)
				v7 = p == Enum.AssetFetchStatus.Success
			end) and v7 then
				RunService.RenderStepped:Wait()

				if not v6 then
					setState2(openGeneration)
				end
			end
		end)
		return function()
			v6 = true
			pcall(task.cancel, thread)
		end
	end, { props.open, props.openGeneration })
	local children = {}

	if v5 and state.X > 0 and state.Y > 0 then
		local geometries = {}

		for i = 1, v4 do
			local geometry = v.chooseGeometry(i, state, geometries)

			if not geometry then
				continue
			end

			geometries[i] = geometry
			local v6 = i == v4
			local mode

			if not (props.open and v6) then
				mode = "static"
			elseif v2 < count and not props.playedRoutes[i] then
				mode = "animate"
			elseif props.playedRoutes[i] then
				mode = "shine"
			else
				mode = "static"
			end

			children[`Route{i}`] = React.createElement(routeLine, {
				animationGeneration = props.openGeneration,
				geometry = geometry,
				mapSize = state,
				mode = mode,
				onAnimated = props.onRouteAnimated,
				routeIndex = i
			})
		end

		local v6 = geometries[v4]
		local delay

		if v6 then
			delay = getRouteDrawDuration(v6.segmentCount) + Config.MARKER_POP_DELAY
		else
			delay = 0
		end

		for k, v8 in Config.CHECKPOINTS do
			local v9

			if k == v3 then
				v9 = v2 < count
			else
				v9 = false
			end

			local mode = v3 < k and "hidden" or v9 and "active" or "static"
			children[`Map{k}`] = React.createElement(mapMarker, {
				animationGeneration = props.openGeneration,
				delay = delay,
				image = v8.IMAGE,
				mode = mode,
				name = `Map{k}`,
				position = v8.MAP_POSITION,
				size = v8.MAP_SIZE
			})
		end
	end

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = Config.MAP_FRAME_SIZE
	}, {
		MapBg = React.createElement("ImageLabel", {
			ref = ref,
			BackgroundTransparency = 1,
			Image = Config.MAP_BACKGROUND_IMAGE,
			ScaleType = Enum.ScaleType.Stretch,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1
		}, children),
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = Config.MAP_ASPECT_RATIO,
			DominantAxis = Enum.DominantAxis.Width
		}),
		uISizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Config.MAP_MAX_SIZE
		})
	})
end

function TreasureMapGui.new()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TreasureMapGui"
	screenGui.DisplayOrder = 25
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	local self = setmetatable({
		_screenGui = screenGui,
		_root = ReactRoblox.createRoot(screenGui),
		_progress = 0,
		_open = false,
		_openGeneration = 0,
		_playedRoutes = {},
		_destroyed = false
	}, TreasureMapGui)
	self:_render()
	return self
end

function TreasureMapGui:_render()
	self._root:render(React.createElement(treasureMap, {
		progress = self._progress,
		open = self._open,
		openGeneration = self._openGeneration,
		playedRoutes = self._playedRoutes,
		onRouteAnimated = function(p: number)
			if self._destroyed or self._playedRoutes[p] then
				return
			end

			self._playedRoutes[p] = true
			playUi(Config.ROUTE_DRAW_SOUND) -- equivalent call inferred; original call site unknown

			if self._open then
				self:_render()
			end
		end
	}))
end

function TreasureMapGui:setProgress(p: number)
	local progress = math.clamp(math.floor(p), 0, #Config.CHECKPOINTS)

	if progress == self._progress then
		return
	end

	if progress < self._progress then
		table.clear(self._playedRoutes)
	else
		for i = math.max(self._progress, 1), progress - 1 do
			self._playedRoutes[i] = true
		end
	end

	self._progress = progress

	if self._open then
		self:_render()
	end
end

function TreasureMapGui:open()
	if self._destroyed or self._open then
		return
	end

	self._openGeneration += 1
	self._open = true
	self._screenGui.Enabled = true
	playUi(Config.MAP_OPEN_SOUND) -- equivalent call inferred; original call site unknown
	self:_render()
end

function TreasureMapGui:close()
	if self._destroyed or not self._open then
		return
	end

	self._open = false
	self:_render()
	self._screenGui.Enabled = false
	playUi(Config.MAP_CLOSE_SOUND) -- equivalent call inferred; original call site unknown
end

function TreasureMapGui:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self._root:unmount()
	self._screenGui:Destroy()
end

return TreasureMapGui