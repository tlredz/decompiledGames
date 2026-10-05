local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "LoadTestHouseButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)

	if GameUtil.isHouseTestingPlace() then
		local localPlayer = game.Players.LocalPlayer
		local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
		local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
		local Remotes = require(ReplicatedStorage.Packages.Remotes)
		local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			Remotes.invokeServer("Lot:BuildProperty", tonumber(value), self.Instance.Name)
			task.wait(1)
			PanelController.Close("MainGUIHandler", "MainHouseMenu")
		end))
	else
		self.Instance:Destroy()
		warn("LoadTestHouseButton was loaded in a non-house testing place")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v