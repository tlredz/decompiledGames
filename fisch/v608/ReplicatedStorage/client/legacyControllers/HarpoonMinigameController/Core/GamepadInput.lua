local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
require(ReplicatedStorage.packages.Trove)
require("../Types")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local GamepadInput = {}

function GamepadInput.new(current)
	local object = setmetatable({}, {
		__index = GamepadInput
	})
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	object.ThumbstickDirection = Vector2.zero
	return object
end

function GamepadInput:Start()
	self.trove:Add(UserInputService.InputChanged:Connect(function(input, _)
		if self.Disabled then
			return
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			local vector = Vector2.new(input.Position.X, -input.Position.Y)

			if vector.Magnitude <= SettingsController:GetSettingValue("consoleDeadzoneLeft") then
				self.ThumbstickDirection = Vector2.zero
			else
				self.ThumbstickDirection = vector.Unit
			end
		end
	end))
	self.trove:Add(UserInputService.InputBegan:Connect(function(input, _)
		if self.Disabled or self.ThumbstickDirection == Vector2.zero then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonA then
			self:OnClick()
		end
	end))
	self.current.ui_thumbstick.Visible = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	self.trove:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self.current.ui_thumbstick.Visible = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	end))
	self.trove:Connect(GuiService:GetPropertyChangedSignal("SelectedObject"), function()
		self:DisableNavigation()
	end)
	self.trove:Connect(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"), function()
		self:DisableNavigation()
	end)
	self:DisableNavigation()
end

function GamepadInput:Disable()
	self.Disabled = true
end

function GamepadInput.Stop(p)
	p.trove:Clean()
end

function GamepadInput:DisableNavigation()
	if GamepadService.GamepadCursorEnabled then
		GamepadService:DisableGamepadCursor()
	end

	if GuiService.SelectedObject then
		GuiService.SelectedObject = nil
	end
end

function GamepadInput:UpdateHovered()
	debug.profilebegin("GamepadInput::UpdateHovered")
	local thumbstickDirection = self.ThumbstickDirection
	local result = nil

	for _, activeButton in self.current.activeButtons do
		if result and result.buttonType == "pull" or activeButton.removing then
			activeButton.isHovered = false
		elseif result == nil or activeButton.buttonType == "pull" then
			local v = (activeButton.currentPos - Vector2.new(0.5, 0.5)) * Vector2.new(1.35, 1)

			if v.Magnitude - activeButton.size / 2 < 0.05 then
				activeButton.isHovered = true

				if result then
					result.isHovered = false
				end

				result = activeButton
			else
				local dot = thumbstickDirection.Unit:Dot(v)

				if dot <= 0 then
					activeButton.isHovered = false
				else
					local isHovered = (v - thumbstickDirection * dot).Magnitude - activeButton.size / 2 < 0.05 + dot / 4
					activeButton.isHovered = isHovered

					if isHovered then
						if result then
							result.isHovered = false
						end

						result = activeButton
					end
				end
			end
		else
			activeButton.isHovered = false
		end
	end

	debug.profileend()
	return result
end

local function directionToAngle(point: Vector2)
	return (math.deg((Vector2.new(1, 0):Angle(point, true))))
end

function GamepadInput:TickLogic(_: number)
	if self.Disabled then
		return
	end

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		self:UpdateHovered()
	end
end

function GamepadInput.TickRender(data, _: number)
	if data.Disabled then
		return
	end

	local visible = data.ThumbstickDirection.Magnitude > 0

	if visible then
		local cone = data.current.ui_thumbstick.cone
		local thumbstickDirection = data.ThumbstickDirection
		cone.Rotation = math.deg((Vector2.new(1, 0):Angle(thumbstickDirection, true)))
	end

	data.current.ui_thumbstick.cone.Visible = visible
end

function GamepadInput:OnClick()
	if self.ThumbstickDirection == Vector2.zero then
		return
	end

	local v = self:UpdateHovered()
	local clone = self.current.ui_thumbstick.cone:Clone()
	clone.Visible = true
	clone.coneImage.inactiveGradient.Enabled = false
	clone.coneImage.clickGradient.Enabled = v ~= nil
	clone.coneImage.missGradient.Enabled = v == nil
	clone.coneImage.ImageTransparency = 0
	local thumbstickDirection = self.ThumbstickDirection
	clone.Rotation = math.deg((Vector2.new(1, 0):Angle(thumbstickDirection, true)))
	clone.Parent = self.current.ui_thumbstick.clickCones
	local tween = TweenService:Create(clone.coneImage, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		ImageTransparency = 1,
		Size = UDim2.fromScale(20, 12)
	})
	tween.Completed:Once(function()
		if clone.Parent then
			clone:Destroy()
		end

		tween:Destroy()
	end)
	tween:Play()

	if v then
		v:Click("player", "gamepad")
		return
	end

	for _, activeButton in self.current.activeButtons do
		if activeButton.removing then
			continue
		end

		activeButton:Remove(false)
		break
	end
end

return GamepadInput