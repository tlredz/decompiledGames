local GuiService = game:GetService("GuiService")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local connectionUtil = CommonUtils.get("ConnectionUtil")
local characterUtil = CommonUtils.get("CharacterUtil")
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsRefactor1")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsFixTouchJumpVisibility")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Combat_presets = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Mounted = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Mounted)

local function comboeing()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil or humanoidRootPart:FindFirstChild("air_combo_bp") == nil then
		return os.clock() - Combat_presets.Last_Punched_Jump <= Combat_presets.No_Jump_Duration
	end

	return true
end

local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v = { "rbxasset://textures/ui/Input/JumpButtonRegular.png", "rbxasset://textures/ui/Input/JumpButtonPressed.png" }
local _ = {
	HUMANOID_STATE_ENABLED_CHANGED = "HUMANOID_STATE_ENABLED_CHANGED",
	HUMANOID_JUMP_POWER = "HUMANOID_JUMP_POWER",
	HUMANOID_JUMP_HEIGHT = "HUMANOID_JUMP_HEIGHT",
	HUMANOID = "HUMANOID",
	MENU_OPENED = "MENU_OPENED",
	ACTIONS_RELOADED = "ACTIONS_RELOADED"
}
local ActionController = require(script.Parent:WaitForChild("ActionController"))
local object = setmetatable({}, ActionController)
object.__index = object

function object.new(p, playerData)
	local object2 = setmetatable(ActionController.new(), object)
	object2.playerData = playerData
	p.eventBus:subscribe("ACTIONS_RELOADED"):Connect(function()
		object2:Create()

		if userFlag4 and object2._active then
			object2._active = false
			object2:EnableButton(true)
		end
	end)
	object2.parentUIFrame = nil
	object2.jumpButton = nil
	object2.externallyEnabled = false
	object2._active = false
	object2._connectionUtil = connectionUtil.new()
	return object2
end

function object:_reset()
	InputHandler.VirtualRelease("Jump")

	if not userFlag3 and self.playerData.actions.JumpAction then
		self.playerData.actions.JumpAction:Fire(false)
	end

	if self.jumpButton then
		if userFlag or not AvatarAbilitiesInterface.isEnabled() then
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		else
			self.jumpButton.Image = v[1]
		end
	end
end

function object:EnableButton(active)
	if active == self._active then
		return
	end

	if active then
		if not self.jumpButton then
			self:Create()
		end

		self.jumpButton.Visible = true

		if not userFlag3 then
			self._connectionUtil:trackConnection("MENU_OPENED", GuiService.MenuOpened:Connect(function()
				self:_reset()
			end))
		end
	else
		if self.jumpButton then
			self.jumpButton.Visible = false
		end

		if not userFlag3 then
			self._connectionUtil:disconnect("MENU_OPENED")
		end
	end

	self:_reset()
	self._active = active
end

function object:UpdateEnabled()
	local child = characterUtil.getChild("Humanoid", "Humanoid")
	local v2

	if child == nil then
		v2 = false
	else
		v2 = child.UseJumpPower and child.JumpPower > 0 and true or not child.UseJumpPower and child.JumpHeight > 0
	end

	if child and self.externallyEnabled and (v2 or comboeing() or Mounted.Is()) and child:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
		self:EnableButton(true)
	else
		self:EnableButton(false)
	end
end

function object:_setupConfigurations()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:UpdateEnabled()
	end

	local v2 = characterUtil.onChild("Humanoid", "Humanoid", function(instance)
		update() -- equivalent call inferred; original call site unknown
		self:_reset()
		self._connectionUtil:trackConnection(
			"HUMANOID_JUMP_POWER",
			instance:GetPropertyChangedSignal("JumpPower"):Connect(update)
		)
		self._connectionUtil:trackConnection(
			"HUMANOID_JUMP_HEIGHT",
			instance:GetPropertyChangedSignal("JumpHeight"):Connect(update)
		)
		self._connectionUtil:trackConnection(
			"HUMANOID_STATE_ENABLED_CHANGED",
			instance.StateEnabledChanged:Connect(function(p, p2)
				if p == Enum.HumanoidStateType.Jumping and p2 ~= self._active then
					update() -- equivalent call inferred; original call site unknown
				end
			end)
		)
	end)
	self._connectionUtil:trackConnection("HUMANOID", v2)
end

function object:Enable(externallyEnabled, parentUIFrame)
	if parentUIFrame then
		self.parentUIFrame = parentUIFrame
	end

	if self.externallyEnabled == externallyEnabled then
		return
	end

	self.externallyEnabled = externallyEnabled
	ActionController.Enable(self, externallyEnabled)
	self:UpdateEnabled()

	if externallyEnabled then
		self:_setupConfigurations()
	else
		self._connectionUtil:disconnectAll()
	end
end

function object:Create()
	if not self.parentUIFrame then
		return
	end

	if self.jumpButton then
		self.jumpButton:Destroy()
		self.jumpButton = nil
	end

	if self.absoluteSizeChangedConn then
		self.absoluteSizeChangedConn:Disconnect()
		self.absoluteSizeChangedConn = nil
	end

	if not userFlag and self.avatarAbilitiesEnabledChangedConn then
		self.avatarAbilitiesEnabledChangedConn:Disconnect()
		self.avatarAbilitiesEnabledChangedConn = nil
	end

	self.jumpButton = Instance.new("ImageButton")
	self.jumpButton.Name = "JumpButton"
	self.jumpButton.Visible = false
	self.jumpButton.BackgroundTransparency = 1

	if userFlag2 then
		self.jumpButton.ZIndex = 10
	end

	if userFlag or not AvatarAbilitiesInterface.isEnabled() then
		self.jumpButton.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		self.jumpButton.ImageRectSize = Vector2.new(144, 144)
	else
		self.jumpButton.Image = v[1]
	end

	local function ResizeJumpButton()
		local v2 = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y) <= 500

		if userFlag or not AvatarAbilitiesInterface.isEnabled() then
			local v3 = v2 and 70 or 120
			self.jumpButton.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
			self.jumpButton.ImageRectSize = Vector2.new(144, 144)
			self.jumpButton.Size = UDim2.new(0, v3, 0, v3)
			self.jumpButton.Position = v2 and UDim2.new(1, -(v3 * 1.5 - 10), 1, -v3 - 20) or UDim2.new(
				1,
				-(v3 * 1.5 - 10),
				1,
				-v3 * 1.75
			)
		else
			local v3 = v2 and 72 or 120
			local v4 = -v3 - (v2 and 64 or 100)
			local v5 = -v3 - (v2 and 64 or 112)
			self.jumpButton.Image = v[1]
			self.jumpButton.ImageRectOffset = Vector2.new(0, 0)
			self.jumpButton.ImageRectSize = Vector2.new(0, 0)
			self.jumpButton.Size = UDim2.new(0, v3, 0, v3)
			self.jumpButton.Position = UDim2.new(1, v4, 1, v5)
		end
	end

	ResizeJumpButton()
	self.absoluteSizeChangedConn = self.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeJumpButton)

	if not userFlag then
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeJumpButton)
	end

	self.jumpButton.Parent = self.parentUIFrame
	local v2 = nil
	self.jumpButton.InputBegan:Connect(function(input)
		if v2 ~= nil or input.UserInputType ~= Enum.UserInputType.Touch or input.UserInputState ~= Enum.UserInputState.Begin or not self.jumpButton.Visible then
			return
		end

		v2 = input
		InputHandler.VirtualPress("Jump")
	end)
	self.jumpButton.InputEnded:Connect(function(input)
		if input ~= v2 then
			return
		end

		v2 = nil
		InputHandler.VirtualRelease("Jump")
	end)

	if not self.playerData.actions.JumpAction then
		return
	end

	local touchBinding = self.playerData.actions.JumpAction:WaitForChild("TouchBinding")
	touchBinding.UIButton = self.jumpButton
	self.playerData.actions.JumpAction.Pressed:Connect(function()
		if not self.jumpButton then
			return
		end

		if userFlag or not AvatarAbilitiesInterface.isEnabled() then
			self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
		else
			self.jumpButton.Image = v[2]
		end
	end)
	self.playerData.actions.JumpAction.Released:Connect(function()
		if not self.jumpButton then
			return
		end

		if userFlag or not AvatarAbilitiesInterface.isEnabled() then
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		else
			self.jumpButton.Image = v[1]
		end
	end)
end

return object