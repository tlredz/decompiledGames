local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local modules = script.Parent.Parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local extended = Roact.Component:extend("PacketCircleArcs")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function CircleArc(props)
	local endPercent = props.Data.EndPercent
	local startPercent = props.Data.StartPercent
	local visiblePercent = props.Data.VisiblePercent
	return Roact.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://3587367081",
		ImageColor3 = props.Highlighted:map(function(p)
			if startPercent <= p and p < endPercent then
				return props.Data.Color:Lerp(Color3.new(1, 1, 1), 0.5)
			end

			return props.Data.Color
		end),
		Size = UDim2.fromScale(2, 1),
		Position = UDim2.fromScale(props.Side == "Left" and 0 or -1, 0),
		ZIndex = props.ZIndex
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Rotation = props.AnimationAlpha:map(function(p)
				if props.Side == "Left" then
					local v2 = math.clamp(p * 2, 0, 1)
					return -3.6 * (0 + (visiblePercent - 0) * v2) + 180
				else
					local v = visiblePercent - 50
					local v2 = math.clamp(p * 2 - 1, 0, 1)
					return (0 + -180 * ((0 + (v - 0) * v2) / 100)) * 2
				end
			end),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(props.Side == "Left" and 0.498 or 0.5, 0),
				NumberSequenceKeypoint.new(props.Side == "Left" and 0.499 or 0.501, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
end

function extended:init()
	local binding, setAnimationAlpha = Roact.createBinding(0)
	self.AnimationAlpha = binding
	self.SetAnimationAlpha = setAnimationAlpha
	local binding2, setActualAlpha = Roact.createBinding(0)
	self.ActualAlpha = binding2
	self.SetActualAlpha = setActualAlpha
	local binding3, setMousePosition = Roact.createBinding(Vector2.zero)
	self.MousePosition = binding3
	self.SetMousePosition = setMousePosition
	local binding4, setHighlightedPercent = Roact.createBinding(-1)
	self.HighlightedPercent = binding4
	self.SetHighlightedPercent = setHighlightedPercent
	local binding5, setDebugMousePos = Roact.createBinding(UDim2.fromOffset(0, 0))
	self.DebugMousePos = binding5
	self.SetDebugMousePos = setDebugMousePos
	local binding6, setShowDebug = Roact.createBinding(false)
	self.ShowDebug = binding6
	self.SetShowDebug = setShowDebug
	local pluginMouse = Packages.IsPlugin and self.props.PluginMouse or Players.LocalPlayer:GetMouse()
	RunService.RenderStepped:Connect(function(dt)
		local vector = Vector2.new(pluginMouse.X, pluginMouse.Y)
		self.SetMousePosition(vector)
		local value = self.ActualAlpha:getValue()
		self.SetAnimationAlpha(TweenService:GetValue(value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		self.SetActualAlpha((math.clamp(value + dt * 2, 0, 1)))
	end)
end

function extended:render()
	self.SetActualAlpha(0)
	local v = #self.props.Arcs
	local total = 0
	local v2 = {}
	local v3 = {
		Left = {},
		Right = {}
	}

	for k, arc in self.props.Arcs do
		local zIndex = v - k + 2
		local v5 = math.min(total + arc.Percent, 100)

		if total > 100 then
			break
		end

		v2[k] = {
			StartPercent = total,
			EndPercent = v5,
			Color = arc.Color,
			Name = arc.Name
		}

		if v5 > 50 and total <= 50 then
			v3.Left[k] = CircleArc({
				ZIndex = zIndex,
				Data = {
					StartPercent = total,
					EndPercent = v5,
					VisiblePercent = 50,
					Color = arc.Color
				},
				Side = "Left",
				AnimationAlpha = self.AnimationAlpha,
				Highlighted = self.HighlightedPercent
			})
		end

		local side = v5 > 50 and "Right" or "Left"
		v3[side][k] = CircleArc({
			ZIndex = zIndex,
			Data = {
				StartPercent = total,
				EndPercent = v5,
				VisiblePercent = v5,
				Color = arc.Color
			},
			Side = side,
			AnimationAlpha = self.AnimationAlpha,
			Highlighted = self.HighlightedPercent
		})
		total += arc.Percent
	end

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		[Roact.Event.MouseEnter] = function(_, _, _)
			self.MouseOver = true
			self.SetShowDebug(true)
		end,
		[Roact.Event.MouseLeave] = function()
			self.MouseOver = false
			self.SetHighlightedPercent(-1)
			self.SetShowDebug(false)
		end,
		[Roact.Event.MouseMoved] = function(p, p2, p3)
			if self.MouseOver then
				local vector = Vector2.new(p2, p3)
				local v5 = p.AbsolutePosition + p.AbsoluteSize / 2
				self.SetDebugMousePos(UDim2.fromOffset(p2 - 1, p3 - 1))
				local v6 = math.deg((math.atan2(vector.Y - v5.Y, -(vector.X - v5.X)))) + 90

				if v6 < 0 then
					v6 += 360
				end

				local v7 = v6 / 360 * 100
				self.SetHighlightedPercent(v7)
			end
		end,
		[Roact.Event.InputEnded] = function(_, p)
			if p.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local value = self.HighlightedPercent:getValue()

			if value == -1 then
				return
			end

			for _, v5 in v2 do
				if not (v5.StartPercent <= value and value < v5.EndPercent) then
					continue
				end

				if not self.props.OnArcClicked then
					break
				end

				self.props.OnArcClicked(v5.Name)
				break
			end

			self.SetHighlightedPercent(-1)
		end
	}, {
		Left = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.fromScale(0.5, 1)
		}, {
			Arcs = Roact.createFragment(v3.Left)
		}),
		Right = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.5, 1)
		}, {
			Arcs = Roact.createFragment(v3.Right)
		})
	})
end

return extended