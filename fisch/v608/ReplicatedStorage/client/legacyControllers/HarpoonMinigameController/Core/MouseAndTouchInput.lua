local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
require(ReplicatedStorage.packages.Trove)
require("../Types")
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local MouseAndTouchInput = {}

function MouseAndTouchInput.new(current)
	local object = setmetatable({}, {
		__index = MouseAndTouchInput
	})
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	return object
end

function MouseAndTouchInput:Start()
	self.trove:Add(UserInputService.InputChanged:Connect(function(input, _)
		if self.Disabled then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:UpdateHovered(Vector2.new(input.Position.X, input.Position.Y))
		end
	end))
	self.trove:Add(UserInputService.InputBegan:Connect(function(input, _)
		if self.Disabled then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:OnClick(Vector2.new(input.Position.X, input.Position.Y))
		end
	end))
	self.current.ui_thumbstick.Visible = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	self.trove:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self.current.ui_thumbstick.Visible = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	end))
end

function MouseAndTouchInput:Disable()
	self.Disabled = true
end

function MouseAndTouchInput.Stop(p)
	p.trove:Clean()
end

function MouseAndTouchInput:UpdateHovered(point: Vector2, flag: boolean?)
	debug.profilebegin("MouseAndTouchInput::UpdateHovered")
	local v = (UserInputService.PreferredInput == Enum.PreferredInput.Touch or flag) and 50 or 0
	local v2 = nil

	for _, activeButton in self.current.activeButtons do
		if v2 or activeButton.removing then
			activeButton.isHovered = false
		else
			local isHovered = (activeButton.absoutePosition - point).Magnitude < activeButton.absoluteSize / 2 + v
			activeButton.isHovered = isHovered

			if isHovered then
				v2 = activeButton
			end
		end
	end

	debug.profileend()
	return v2
end

function MouseAndTouchInput:TickLogic(_: number)
	if self.Disabled then
		return
	end

	if UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
		self:UpdateHovered(UserInputService:GetMouseLocation() - GuiService:GetGuiInset())
	end
end

function MouseAndTouchInput.TickRender(p, _: number)
	if p.Disabled then
	end
end

function MouseAndTouchInput:OnClick(point: Vector2)
	local v = self:UpdateHovered(point, true)

	if v then
		v:Click("player", "pointer")
		return
	end

	local magnitude = 1e999
	local v2 = nil

	for _, activeButton in self.current.activeButtons do
		if activeButton.removing or not ((activeButton.absoutePosition - point).Magnitude < magnitude) then
			continue
		end

		magnitude = (activeButton.absoutePosition - point).Magnitude
		v2 = activeButton
	end

	if v2 then
		v2:Remove(false)
	end
end

return MouseAndTouchInput