local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleAbPanelHandler"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
require(GameSdkShared.Modules.ABTest)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local mainButtons = instance:FindFirstChild("MainButtons")
	local bottomButtons = instance:FindFirstChild("BottomButtons")
	local topButtons = instance:FindFirstChild("TopButtons")
	local noMotorVehicleCustomizationOptions = instance:FindFirstChild("NoMotorVehicleCustomizationOptions")
	local noMotorVehicleSpeedControls = instance:FindFirstChild("NoMotorVehicleSpeedControls")
	mainButtons.Visible = false
	bottomButtons.Visible = true
	topButtons.Visible = true
	noMotorVehicleCustomizationOptions.Position = UDim2.new(0.198, 0, -0.075, 0)
	noMotorVehicleSpeedControls.Position = UDim2.new(0.37, 0, 0.12, 0)
	local Players = game:GetService("Players")
	local musicSettingsFrame = Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("MainGUIHandler"):FindFirstChild("MusicSettingsFrame")

	if musicSettingsFrame then
		musicSettingsFrame.Visible = false
		self._Janitor:Add(musicSettingsFrame:GetPropertyChangedSignal("Visible"):Connect(function()
			if not self.Instance.Visible then
				return
			end

			musicSettingsFrame.Visible = false
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v