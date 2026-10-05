local Util = require(script.Util)
local Viewport = require(script.Viewport)
local ProgressCircle = {}

local function GetDots(p, fn)
	for _, child in pairs(p.Instance.Circle:GetChildren()) do
		if child.Name == "Dot" or child.Name == "CenterDot" then
			fn(child)
		end
	end
end

local function UpdateFill(state, p)
	local circle = state.Instance.Circle
	local rotation = state.Rotation

	if p then
		rotation = state.Progress * 3.6
	end

	local rotation2 = math.fmod(rotation, 360.1)
	local uIGradient = circle.RightClip.Circle.UIGradient
	local uIGradient2 = circle.LeftClip.Circle.UIGradient

	if rotation2 < 180 and rotation2 > -180 then
		circle.RightClip.HideCircle.Visible = true
		uIGradient.Rotation = rotation2
		uIGradient2.Rotation = 0
	else
		circle.RightClip.HideCircle.Visible = false
		uIGradient.Rotation = 180
		uIGradient2.Rotation = rotation2 - 180
	end

	if state.Rounded == true then
		local dot = circle:FindFirstChild("Dot")

		if not dot then
			dot = circle.CenterDot:Clone()
			dot.Name = "Dot"
			dot.Parent = circle
		end

		local v2

		if rotation2 <= 90 then
			v2 = 270 + rotation2
		else
			v2 = rotation2 - 90
		end

		local v3 = math.rad(v2)
		local v4 = { -1, 1 }
		local v5 = { 0, 1 }
		local shiftRange = Util.ShiftRange(v4, v5, (math.cos(v3)))
		local shiftRange2 = Util.ShiftRange(v4, v5, (math.sin(v3)))
		dot.AnchorPoint = Vector2.new(shiftRange, shiftRange2)
		dot.Position = UDim2.fromScale(shiftRange, shiftRange2)
		state.Progress = rotation2 / 3.6
		state.Rotation = rotation2
	end
end

local v = {
	Progress = function(p)
		UpdateFill(p, true)
	end,
	Rotation = function(p)
		UpdateFill(p)
	end,
	Position = function(p)
		p.Instance.Position = p.Position
	end,
	AnchorPoint = function(p)
		p.Instance.AnchorPoint = p.AnchorPoint
	end,
	Size = function(p)
		p.Instance.Size = UDim2.fromScale(p.Size, p.Size)
	end,
	Thickness = function(p)
		local v2 = 1 - p.Thickness
		p.Instance.Circle.HideCircle.Visible = true

		if p.Thickness == 1 then
			p.Instance.Circle.HideCircle.Visible = false
		end

		p.Instance.Circle.HideCircle.Size = UDim2.fromScale(v2, v2)

		for _, child in pairs(p.Instance.Circle:GetChildren()) do
			if child.Name == "Dot" or child.Name == "CenterDot" then
				child.Size = UDim2.fromScale(p.Thickness / 2, p.Thickness / 2)
			end
		end
	end,
	CircleSize = function(p)
		p.Instance.Circle.Size = UDim2.fromScale(p.CircleSize, p.CircleSize)
	end,
	Color = function(p)
		p.Instance.Circle.LeftClip.Circle.BackgroundColor3 = p.Color
		p.Instance.Circle.RightClip.Circle.BackgroundColor3 = p.Color
		GetDots(p, function(p2)
			p2.BackgroundColor3 = p.Color
		end)
	end,
	BGColor = function(p)
		p.Instance.BG.BackgroundColor3 = p.BGColor

		for _, descendant in pairs(p.Instance.Circle:GetDescendants()) do
			if descendant.Name == "HideCircle" then
				descendant.BackgroundColor3 = p.BGColor
			end
		end
	end,
	Transparency = function(_) end,
	BGRoundness = function(p)
		p.Instance.BG.UICorner.CornerRadius = UDim.new(p.BGRoundness)
	end,
	Rounded = function(p)
		GetDots(p, function(p2)
			p2.Visible = p.Rounded
		end)
	end,
	Parent = function(state)
		if state.Parent == nil and state._InitializeParent == true then
			state._ScreenGui = Instance.new("ScreenGui")
			state._ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
			state._ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			state._ScreenGui.Name = "CircularProgress"
			state.Instance.Parent = state._ScreenGui
			state.Parent = state._ScreenGui
			state._InitializeParent = false
		else
			if state.Instance.Parent == state._ScreenGui then
				state.Instance.Parent = nil
				state._ScreenGui:Destroy()
			end

			state.Instance.Parent = state.Parent
		end
	end
}

function ProgressCircle.new(items)
	local v2 = {
		Progress = 0,
		Rotation = 0,
		Position = UDim2.fromScale(0.04, 0.95),
		AnchorPoint = Vector2.new(0, 0),
		Size = 0.2,
		Thickness = 0.3,
		CircleSize = 0.7,
		Color = Color3.fromRGB(255, 255, 255),
		BGColor = Color3.fromRGB(30, 30, 30),
		Transparency = 0,
		BGRoundness = 0.2,
		Rounded = true
	}
	local clone = script.ProgressCircle:Clone()
	v2._InitializeParent = true
	v2.Parent = nil

	if items then
		for k, item in pairs(items) do
			v2[k] = item
		end
	end

	v2.Instance = clone

	for _, v3 in pairs(v) do
		v3(v2)
	end

	local self = setmetatable({}, {
		__index = function(_, p, _)
			if v2[p] ~= nil then
				return v2[p]
			end

			if ProgressCircle[p] == nil then
				return
			else
				return ProgressCircle[p]
			end
		end,
		__newindex = function(_, p, p2)
			if v[p] and v2[p] ~= p2 then
				v2[p] = p2
				v[p](v2)
			end
		end
	})
	v2._TweenService = Util.TweenService.new(self)
	return self
end

function ProgressCircle.fromViewport(p)
	return Viewport.new(p)
end

function ProgressCircle.fromWorldspace(p)
	return Viewport.fromWorldspace(p)
end

function ProgressCircle:Tween(p2, p3)
	self._TweenService:Tween(p2, p3)
end

function ProgressCircle:Animate(p2)
	local PresetAnimations = require(script.PresetAnimations)
	local v2 = PresetAnimations[p2](self)

	if v2 then
		self._TweenService:Add(v2)
	end
end

function ProgressCircle:Destroy()
	self.Instance:Destroy()
	self._TweenService:Destroy()
	setmetatable(self, nil)
end

return ProgressCircle