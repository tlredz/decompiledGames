local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local BalloonPopConstants = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.BalloonPop.BalloonPopConstants)
local BackpackVisibilityController = require(ReplicatedStorage.Modules.Client.Player.BackpackVisibilityController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "BalloonPopSeat"
})
v.CurrentLocalSeat = nil
v.LocalSatInSeat = Signal.new()
v.LocalExitedSeat = Signal.new()
local localPlayer = Players.LocalPlayer

local function attachHand(instance, childName: string, childName2: string, target)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if not child then
		return nil
	end

	local child2 = instance:FindFirstChild(childName2)

	if not child2 then
		return nil
	end

	local iKControl = Instance.new("IKControl")
	iKControl.Type = Enum.IKControlType.Position
	iKControl.EndEffector = child
	iKControl.ChainRoot = child2
	iKControl.Target = target
	iKControl.Parent = humanoid
	return iKControl
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._sittingJanitor = self._Janitor:Add(Janitor.new())
	self.Shot = Signal.new()
	self._shootDebounce = false
	self._gun = self.Instance.Gun.Value
	assert(self._gun, (`BalloonPopSeat: Gun pointer is not set on seat {self.Instance:GetFullName()}`))
	self._triggerAttachment = self._gun.TriggerAttach
	self._gripAttachment = self._gun.GripAttach
end

function v:GetGun()
	return self._gun
end

function v:_attachHands(p)
	local v2 = attachHand(p, "RightHand", "UpperTorso", self._triggerAttachment)

	if v2 then
		self._sittingJanitor:Add(v2)
	end

	local v3 = attachHand(p, "LeftHand", "LeftUpperArm", self._gripAttachment)

	if v3 then
		self._sittingJanitor:Add(v3)
	end
end

function v:ForceExitSeat()
	local occupant = self.Instance.Occupant

	if not occupant then
		return
	end

	occupant.Sit = false
end

function v:_handleGunMechanics(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	humanoid.CameraOffset = createVector(1.8, 1, 0)
	self._sittingJanitor:Add(function()
		humanoid.CameraOffset = createVector(0, 0, 0)
	end)
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	self._sittingJanitor:Add(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)
	UserInputService.MouseIcon = "rbxassetid://9081437499"
	self._sittingJanitor:Add(function()
		UserInputService.MouseIcon = ""
	end)
	humanoid:UnequipTools()
	BackpackVisibilityController.SetVisibility(false, "BalloonPopSeat")
	self._sittingJanitor:Add(function()
		BackpackVisibilityController.SetVisibility(true, "BalloonPopSeat")
	end)
	local raycastParams = RaycastParams.new()
	raycastParams.ExcludeInstances = { self.Instance, instance }
	self._sittingJanitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2 then
			if self._shootDebounce then
				return
			end

			self._shootDebounce = true
			task.delay(BalloonPopConstants.SHOOT_COOLDOWN, function()
				self._shootDebounce = false
			end)
			local v2

			if input.KeyCode == Enum.KeyCode.ButtonR2 then
				local mouseLocation = UserInputService:GetMouseLocation()
				v2 = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			else
				local position = input.Position
				v2 = workspace.CurrentCamera:ScreenPointToRay(position.X, position.Y)
			end

			local raycastResult = workspace:Raycast(v2.Origin, v2.Direction * 200, raycastParams)
			local v3

			if raycastResult and raycastResult.Instance.Name == "Balloon" then
				v3 = raycastResult.Instance
			end

			self.Shot:Fire(v3)
		elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonX then
			self:ForceExitSeat()
		end
	end))
end

function v:Start()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		if not self.Instance.Occupant then
			self._sittingJanitor:Cleanup()
			return
		end

		local parent = self.Instance.Occupant.Parent
		self:_attachHands(parent)

		if parent == localPlayer.Character then
			v.CurrentLocalSeat = self
			v.LocalSatInSeat:Fire(self)
			task.spawn(NotificationController.SlideNotification, "Shoot balloons for tickets!", 1, nil, 4)
			task.spawn(function()
				PanelController.Open("MainGUIHandler", "BalloonPopInfo")
			end)
			PanelController.ToggleGroup("MainView", false)
			PanelController.ToggleGroup("HUD", false)
			PanelController.Close("MainGUIHandler", "StarterInstructions")
			self._sittingJanitor:Add(function()
				v.CurrentLocalSeat = nil
				v.LocalExitedSeat:Fire()
				PanelController.Close("MainGUIHandler", "BalloonPopInfo")
				PanelController.ToggleGroup("HUD", true)
			end)
			self:_handleGunMechanics(parent)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v