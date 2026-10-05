local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "TogglePanelButton"
})
local v2 = {
	Horse = function(instance)
		return instance:FindFirstChild(localPlayer.Name .. "Horse")
	end,
	Drone = function(p)
		return p.HumanoidRootPart:FindFirstChild("Drone")
	end,
	ClientToClient = function(instance)
		return instance:FindFirstChild("ClientToClient")
	end,
	NoMotorVehicle = function(instance)
		return instance:FindFirstChild("NoMotorVehicleModel")
	end
}

function v:IsPlayerAllowedToOpenPanel()
	local character = localPlayer.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid or humanoid.Sit or workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
		return false
	end

	for _, v3 in v2 do
		if v3(character, localPlayer) then
			return false
		end
	end

	if humanoid.WalkSpeed == 0 or (humanoid.Jump or humanoid:GetState() == Enum.HumanoidStateType.Jumping) or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		return false
	end

	return humanoid:GetState() ~= Enum.HumanoidStateType.Swimming
end

function v:Construct()
	self._Janitor = Janitor.new()
	local PanelController2 = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	PanelController = PanelController2
end

function v:IsInstanceClickable()
	return self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")
end

function v:Start()
	if not self:IsInstanceClickable() then
		return
	end

	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if not IntroController.HasPassedIntro() then
			NotificationController.Notify("Cannot open this right now")
			return
		end

		if self.Instance:GetAttribute("CannotOpenWhileSitting") and not self:IsPlayerAllowedToOpenPanel() then
			NotificationController.Notify("Cannot open this right now")
			return
		end

		local targetPanel = self.Instance:GetAttribute("TargetPanel")
		local targetContext = self.Instance:GetAttribute("TargetContext") or PanelController.GetPanelContextByInstance(self.Instance).Name

		if not targetPanel then
			warn("No target panel name found for button", self.Instance)
			return
		end

		if PanelController.IsOpen(targetContext, targetPanel) then
			PanelController.Close(targetContext, targetPanel)
			return
		end

		if self.Instance:GetAttribute("CloseGroup") then
			PanelController.ToggleGroup(self.Instance:GetAttribute("CloseGroup"), false)
		end

		PanelController.OpenPanelByContext(targetContext, targetPanel)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v