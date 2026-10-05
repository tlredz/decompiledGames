local TweenService = game:GetService("TweenService")
local v = {}
local v2 = {}
local SlideDock = {}
SlideDock.__index = SlideDock

-- equivalent calls inferred from this helper; original call sites unknown
local function slideSeconds(instance)
	local slideSeconds2 = instance:GetAttribute("SlideSeconds")

	if typeof(slideSeconds2) == "number" then
		return slideSeconds2
	end

	return 0.3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enterInfo(frame)
	return TweenInfo.new(slideSeconds(frame), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function exitInfo(frame)
	return TweenInfo.new(slideSeconds(frame) * 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop(p)
	if p.tween ~= nil then
		p.tween:Cancel()
		p.tween = nil
	end
end

local function offscreenDistance(p, p2: number)
	local layerCollector = p.frame:FindFirstAncestorWhichIsA("LayerCollector")
	assert(layerCollector ~= nil, (`{p.frame:GetFullName()} must live under a ScreenGui to slide`))
	local v3 = p.frame.Position.X.Offset - p.home.X.Offset
	local v4 = p.frame.AbsolutePosition.X - v3
	return math.max(layerCollector.AbsoluteSize.X - v4, 0) + p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function awayPosition(p, p2: number)
	return p.home + UDim2.fromOffset(offscreenDistance(p, p2), 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play(_panel, udim: UDim2, p)
	stop(_panel) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(_panel.frame, p, {
		Position = udim
	})
	_panel.tween = tween
	tween:Play()
	return tween
end

function SlideDock.EscortFramesOf(items)
	local parents = {}

	for _, item in items do
		local parent = item.Parent

		if not (parent ~= nil and parent:IsA("GuiObject") and table.find(parents, parent) == nil) then
			continue
		end

		table.insert(parents, parent)
	end

	return parents
end

function SlideDock.new(root, frame, items)
	local self = setmetatable({
		_root = root,
		_panel = {
			frame = frame,
			home = frame.Position,
			tween = nil
		},
		_escorts = {},
		_open = nil,
		_generation = 0
	}, SlideDock)

	for _, item in items do
		local v3 = v[item]

		if v3 == nil then
			v3 = {
				frame = item,
				home = item.Position,
				tween = nil
			}
			v[item] = v3
			v2[item] = 0
		end

		table.insert(self._escorts, v3)
	end

	return self
end

function SlideDock:IsOpen()
	return self._open == true
end

function SlideDock:SetOpen(open: boolean, flag: boolean?)
	if self._open == open then
		return
	end

	self._open = open
	self._generation += 1
	local _generation = self._generation
	local frame = self._panel.frame

	for _, _escort in self._escorts do
		local v3 = v2[_escort.frame]
		local v4

		if open then
			v4 = v3 + 1
		else
			v4 = math.max(v3 - 1, 0)
		end

		v2[_escort.frame] = v4
		local v5 = v4 > 0

		if flag then
			stop(_escort) -- equivalent call inferred; original call site unknown
			local frame2 = _escort.frame
			local position

			if v5 then
				position = awayPosition(_escort, 12)
			else
				position = _escort.home
			end

			frame2.Position = position
		elseif v5 then
			local position = awayPosition(_escort, 12) -- equivalent call inferred; original call site unknown
			local v7 = exitInfo(frame) -- equivalent call inferred; original call site unknown
			stop(_escort) -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(_escort.frame, v7, {
				Position = position
			})
			_escort.tween = tween
			tween:Play()
		else
			local home = _escort.home
			local v6 = enterInfo(frame) -- equivalent call inferred; original call site unknown
			stop(_escort) -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(_escort.frame, v6, {
				Position = home
			})
			_escort.tween = tween
			tween:Play()
		end
	end

	local _panel = self._panel
	local v3 = frame.AbsoluteSize.X * 0.3 + 12

	if open then
		local v4 = not self._root.Enabled
		self._root.Enabled = true

		if flag then
			stop(_panel) -- equivalent call inferred; original call site unknown
			_panel.frame.Position = _panel.home
		else
			if v4 then
				_panel.frame.Position = awayPosition(_panel, v3)
			end

			local home = _panel.home
			local v5 = enterInfo(frame) -- equivalent call inferred; original call site unknown
			play(_panel, home, v5) -- equivalent call inferred; original call site unknown
		end
	elseif flag then
		stop(_panel) -- equivalent call inferred; original call site unknown
		_panel.frame.Position = _panel.home
		self._root.Enabled = false
	else
		local position = awayPosition(_panel, v3) -- equivalent call inferred; original call site unknown
		local v5 = exitInfo(frame) -- equivalent call inferred; original call site unknown
		;(play(_panel, position, v5)).Completed:Once(function(p)
			if self._generation == _generation and p == Enum.PlaybackState.Completed then
				_panel.tween = nil
				self._root.Enabled = false
				_panel.frame.Position = _panel.home
			end
		end)
	end
end

return SlideDock