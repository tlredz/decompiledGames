local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "OpenAvatarEditor"
})
local v2 = {
	Horse = function(instance)
		return instance:FindFirstChild(Players.LocalPlayer.Name .. "Horse")
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

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local component = self:GetComponent(InteractionPrompt)
	self._Janitor:Add(component.Interacted:Connect(function()
		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid or humanoid.Sit or workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
			return
		end

		for _, v3 in v2 do
			if v3(character) then
				return
			end
		end

		if humanoid.WalkSpeed == 0 or (humanoid.Jump or humanoid:GetState() == Enum.HumanoidStateType.Jumping) or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			return
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
			return
		end

		local position = character:GetPivot().Position
		character:PivotTo(self.Instance:GetPivot().Rotation + position)
		PanelController.ToggleGroup("MainView", false)
		PanelController.Open("NoResetGUIHandler", "AvatarEditorMenu")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v