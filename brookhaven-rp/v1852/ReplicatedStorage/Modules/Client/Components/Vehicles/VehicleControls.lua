local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VehicleBoostButton = require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.VehicleBoostButton)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local VehicleControlsTestController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleControlsTestController)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local TagsUtil = require(ReplicatedStorage.Modules.Shared.Utils.TagsUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleControls"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.scope = Fusion.scoped(Fusion)
	self._Janitor:Add(function()
		Fusion.doCleanup(self.scope)
	end)
end

function v:Start()
	local controls = self.Instance:WaitForChild("Controls")
	local buttons = controls:WaitForChild("Buttons")
	local pedals = controls:WaitForChild("Pedals")
	local steering = controls:WaitForChild("Steering")
	local isVisibleValue = VehicleControlsTestController.IsVisibleValue()
	local value = self.scope:Value(UserInputService.PreferredInput)
	self._Janitor:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		value:set(UserInputService.PreferredInput)
	end))
	local computed = self.scope:Computed(function(use)
		return use(isVisibleValue) and use(value) == Enum.PreferredInput.Touch
	end)
	self.scope:Observer(computed):onBind(function()
		if not Fusion.peek(computed) then
			return
		end

		local hasPedals = VehicleControlsTestController.HasPedals()
		buttons.Visible = not hasPedals
		pedals.Visible = hasPedals
		steering.Visible = VehicleControlsTestController.HasSteerButtons()
	end)
	local value2 = self.scope:Value(nil)
	local localPlayer = Players.LocalPlayer
	local maid = Janitor.new()
	self._Janitor:Add(maid)
	local jumpPower = nil

	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")

		local function checkSeat(_)
			local seatPart = humanoid.SeatPart

			if seatPart ~= nil and seatPart:IsA("VehicleSeat") and seatPart:HasTag("VehicleDriverSeatClient") then
				value2:set(TagsUtil.FindAncestorByTag(seatPart, "VehicleRoot"))
			elseif Fusion.peek(value2) ~= nil then
				value2:set(nil)
			end
		end

		maid:Cleanup()
		maid:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			checkSeat(character)
		end))
		checkSeat(character)
	end

	if localPlayer.Character ~= nil then
		onCharacterAdded(localPlayer.Character)
	end

	self._Janitor:Add(localPlayer.CharacterAdded:Connect(onCharacterAdded))
	self._Janitor:Add(localPlayer.CharacterRemoving:Connect(function()
		maid:Cleanup()
		value2:set(nil)
		jumpPower = nil
	end))
	local visible = self.scope:Computed(function(use)
		return use(value2) ~= nil and use(computed)
	end)
	self.scope:Hydrate(controls)({
		Visible = visible
	})
	self.scope:Observer(visible):onBind(function()
		if not IntroController.HasPassedIntro() then
			return
		end

		local currentVisible = Fusion.peek(visible)

		if VehicleControlsTestController.HasSteerButtons() then
			GuiService.TouchControlsEnabled = not currentVisible
			return
		end

		local character = Players.LocalPlayer.Character

		if character == nil then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid == nil then
			return
		end

		if currentVisible then
			if humanoid.JumpPower > 0 and jumpPower == nil then
				jumpPower = humanoid.JumpPower
			end

			humanoid.JumpPower = 0
		elseif jumpPower ~= nil then
			humanoid.JumpPower = jumpPower
			jumpPower = nil
		end
	end)
	self._Janitor:Add(function()
		GuiService.TouchControlsEnabled = true

		if jumpPower ~= nil then
			local character = Players.LocalPlayer.Character

			if character == nil then
				return
			end

			local humanoid = character:FindFirstChild("Humanoid")

			if humanoid == nil then
				return
			else
				humanoid.JumpPower = jumpPower
			end
		end
	end)
	local value3 = self.scope:Value(false)
	local value4 = self.scope:Value(false)
	local value5 = self.scope:Value(false)
	local value6 = self.scope:Value(false)

	local function connectDownUp(p, object2)
		self._Janitor:Add(p.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				object2:set(true)
			end
		end))
		self._Janitor:Add(p.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				object2:set(false)
			end
		end))
	end

	connectDownUp(buttons:WaitForChild("Accelerator"), value3)
	connectDownUp(buttons:WaitForChild("Brake"), value4)
	connectDownUp(pedals:WaitForChild("Accelerator"), value3)
	connectDownUp(pedals:WaitForChild("Brake"), value4)
	connectDownUp(steering:WaitForChild("Left"), value5)
	connectDownUp(steering:WaitForChild("Right"), value6)

	local function jump()
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid ~= nil then
			humanoid.Sit = false
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	self._Janitor:Add(buttons:WaitForChild("JumpButton").Activated:Connect(jump))
	self:_ListenThrottle(visible, value2, value3, value4)
	self:_ListenSteering(visible, value2, value5, value6)
	self:_WireExitButton(controls, visible, jump)
end

function v:_WireExitButton(instance, p2, onActivated)
	local exit = instance:WaitForChild("ExitFrame"):WaitForChild("Exit")
	self.scope:Hydrate(exit)({
		Visible = self.scope:Computed(function(use)
			return use(p2) and VehicleControlsTestController.HasSteerButtons()
		end)
	})
	local exit2 = instance:WaitForChild("Exit2")
	self.scope:Hydrate(exit2)({
		Visible = self.scope:Computed(function(use)
			return use(p2) and not VehicleControlsTestController.HasSteerButtons()
		end)
	})
	self._Janitor:Add(exit.Activated:Connect(onActivated))
	self._Janitor:Add(exit2.Activated:Connect(onActivated))
end

function v:_ListenThrottle(p2, state, p3, p4)
	local value = self.scope:Value(false)
	local computed = self.scope:Computed(function(use)
		if not use(p2) then
			return nil
		end

		if use(p3) then
			return 1
		end

		if use(p4) then
			return -1
		end

		if use(value) then
			return 1
		end

		return 0
	end)
	self.scope:Observer(computed):onBind(function()
		local v2 = Fusion.peek(state)

		if v2 == nil then
			return
		end

		v2:SetAttribute("ThrottleFloat", Fusion.peek(computed))
		VehicleController.SetThrottleFloat(Fusion.peek(computed))
	end)
	local v2 = {}

	local function listenVehicleBoost(p5)
		v2[p5] = p5.OnButtonDownChanged:Connect(function(p6)
			value:set(p6)
		end)
	end

	for _, v3 in VehicleBoostButton:GetAll() do
		v2[v3] = v3.OnButtonDownChanged:Connect(function(p5)
			value:set(p5)
		end)
	end

	self._Janitor:Add(VehicleBoostButton.Started:Connect(listenVehicleBoost))
	self._Janitor:Add(VehicleBoostButton.Stopped:Connect(function(p5)
		v2[p5] = nil
		value:set(false)
	end))
	self._Janitor:Add(function()
		for _, connection in v2 do
			connection:Disconnect()
		end
	end)
end

function v:_ListenSteering(p2, state, p3, p4)
	local computed = self.scope:Computed(function(use)
		if not (use(p2) and VehicleControlsTestController.HasSteerButtons()) then
			return nil
		end

		local v2 = use(p3)
		local v3 = use(p4)

		if v2 and not v3 then
			return -1
		end

		if v3 and not v2 then
			return 1
		end

		return 0
	end)
	self.scope:Observer(computed):onBind(function()
		local v2 = Fusion.peek(state)

		if v2 == nil then
			return
		end

		v2:SetAttribute("SteerFloat", Fusion.peek(computed))
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v