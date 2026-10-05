local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CONSTANTS = require(script:WaitForChild("CONSTANTS"))
local Maid = require(script.Parent.Maid)
local TAU = CONSTANTS.TAU
local EX_OFFSET = CONSTANTS.EX_OFFSET
local v = {
	[Enum.KeyCode.ButtonA] = true
}
local v2 = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.Touch] = true
}
local v3 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}
local CreateRadial = require(script:WaitForChild("CreateRadial"))
local Radial = {}
Radial.__index = Radial
Radial.__type = "RadialMenu"

function Radial.__tostring(_)
	return Radial.__type
end

function Radial.new(subN, p, rotation)
	local self = setmetatable({}, Radial)
	self._Maid = Maid.new()
	self._ClickedBind = Instance.new("BindableEvent")
	self._HoverBind = Instance.new("BindableEvent")
	self._LastHoverIndex = nil
	self.Frame = CreateRadial(subN, p, rotation)
	self.Rotation = rotation
	self.SubN = subN
	self.Enabled = true
	self.DeadZoneIn = 0.5
	self.DeadZoneOut = 1e999
	self.Clicked = self._ClickedBind.Event
	self.Hover = self._HoverBind.Event
	init(self)
	self:SetDialProps({
		ImageColor3 = Color3.new(0, 0, 0)
	})
	self:SetRadialProps({
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.7
	})
	return self
end

local function shortestDist(p, p2)
	local v4 = (p2 - p) % TAU
	local v5 = math.abs(math.abs(v4) - 3.141592653589793)
	local v6 = 3.141592653589793 - v5

	if (v4 + TAU) % TAU < 3.141592653589793 then
		return v6
	end

	return -v6
end

function init(object)
	local _ = object.SubN
	local radialDial = object.Frame.RadialDial
	local mouseMovement = Enum.UserInputType.MouseMovement
	object._Maid:Mark(object._ClickedBind)
	object._Maid:Mark(object._HoverBind)
	object._Maid:Mark(UserInputService.LastInputTypeChanged:Connect(function(p)
		if v2[p] or v3[p] then
			mouseMovement = p
		end
	end))
	local v4 = 0
	object._Maid:Mark(UserInputService.InputBegan:Connect(function(input)
		if not object.Enabled then
			return
		end

		if v3[input.UserInputType] then
			if not v[input.KeyCode] then
				return
			end

			object._ClickedBind:Fire(object:PickIndex(v4))
		end

		local theta = object:GetTheta(input.UserInputType)

		if theta then
			object._ClickedBind:Fire(object:PickIndex(theta))
		end
	end))
	object._Maid:Mark(RunService.RenderStepped:Connect(function(_)
		if not object.Enabled then
			return
		end

		local theta = object:GetTheta(mouseMovement)

		if object:IsVisible() then
			if theta then
				v4 = theta
				local rotation = math.rad(object.Frame.Rotation)
				local v5 = math.deg(theta - object.Rotation + rotation + EX_OFFSET + 2 * TAU) % 360 / (360 / object.SubN) + 0.5
				radialDial.Visible = true
				radialDial.Rotation = math.deg((object:GetRotation(v5)))
				local index = object:PickIndex(theta)

				if index ~= object._LastHoverIndex then
					object._HoverBind:Fire(object._LastHoverIndex, index)
					object._LastHoverIndex = index
				end
			else
				radialDial.Visible = false

				if object._LastHoverIndex then
					object._HoverBind:Fire(object._LastHoverIndex, nil)
					object._LastHoverIndex = nil
				end
			end
		end
	end))
end

function Radial:SetRadialProps(items)
	for _, child in self.Frame.Radial:GetChildren() do
		for k, item in items do
			child[k] = item
		end
	end
end

function Radial:SetDialProps(items)
	local radialDial = self.Frame.RadialDial

	for k, item in items do
		radialDial[k] = item
	end
end

function Radial:GetTheta(p)
	local v4 = nil

	if v2[p] then
		local frame = self.Frame
		local v5 = frame.AbsoluteSize.y / 2
		local v6 = frame.AbsolutePosition + frame.AbsoluteSize / 2
		v4 = (UserInputService:GetMouseLocation() + Vector2.new(0, -36) - v6) / v5
	elseif v3[p] then
		local gamepadState = UserInputService:GetGamepadState(p)

		for _, v5 in gamepadState do
			gamepadState[v5.KeyCode] = v5
		end

		v4 = gamepadState[Enum.KeyCode.Thumbstick2].Position * createVector(1, -1, 1)
	end

	if v4 then
		local magnitude = v4.Magnitude

		if self.DeadZoneIn <= magnitude and magnitude <= self.DeadZoneOut then
			return (math.atan2(v4.y, -v4.x))
		end
	end
end

function Radial:PickIndex(p)
	local rotation = math.rad(self.Frame.Rotation)
	return math.floor(math.deg(p - self.Rotation + rotation + EX_OFFSET + 2 * TAU) % 360 / (360 / self.SubN)) + 1
end

function Radial:GetRotation(p2)
	return -TAU * ((p2 - 1) / self.SubN)
end

function Radial.GetRadial(p, p2)
	return p.Frame.Radial[p2]
end

function Radial.GetAttachment(p, p2)
	return p.Frame.Attach[p2]
end

function Radial:IsVisible()
	local frame = self.Frame

	while frame and frame:IsA("GuiObject") and frame.Visible do
		frame = frame.Parent

		if frame and frame:IsA("ScreenGui") and frame.Enabled then
			return true
		end
	end

	return false
end

function Radial:Destroy()
	self._Maid:Sweep()
	self.Frame:Destroy()
	self.Clicked = nil
	self.Hover = nil
	self.Frame = nil
end

return Radial