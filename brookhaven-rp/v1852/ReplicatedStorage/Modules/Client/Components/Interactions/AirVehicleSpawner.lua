local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AirVehiclesMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AirVehiclesMenu)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local v = Component.new({
	Tag = "AirVehicleSpawner"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local button = self.Instance:WaitForChild("Button")
	self.singleVehicleSpawn = self.Instance:GetAttribute("SingleVehicleSpawn")
	self._Janitor:Add(button.ClickDetector.MouseClick:connect(function(p)
		if not self.singleVehicleSpawn or self.singleVehicleSpawn == "" then
			self:ButtonClicked(p)
		elseif UnlockableController.IsFeatureUnlocked(self.singleVehicleSpawn, Gamepasses.VIP) then
			self:SpawnVehicle(self.singleVehicleSpawn)
		else
			GamepassController.Show(Gamepasses.VIP, nil, "AirVehicleSpawner", nil, {
				id = self.singleVehicleSpawn
			}, nil, "Air Vehicle Spawner", self.singleVehicleSpawn, function()
				if self.Instance.Parent == nil then
					return
				end

				self:SpawnVehicle(self.singleVehicleSpawn)
			end)
		end
	end))
end

function v:ButtonClicked()
	AirVehiclesMenu:Open(self)
end

function v:SpawnVehicle(p2: string)
	local v2, v3 = Remotes.invokeServerComponent(self.Instance, "SpawnVehicle", p2)

	if not v2 then
		NotificationController.Notify(v3)
	end

	return v2
end

function v:Stop()
	self._Janitor:Destroy()
end

return v