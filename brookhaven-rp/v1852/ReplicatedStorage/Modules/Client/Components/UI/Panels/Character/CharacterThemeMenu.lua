local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "CharacterThemeMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local reopenPrivateServer = instance:WaitForChild("Catalog"):WaitForChild("Header"):WaitForChild("CategoryTabs"):WaitForChild("005Close"):WaitForChild("ReopenPrivateServer")
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not (instance.Visible ~= true and reopenPrivateServer.Value == true) then
			return
		end

		reopenPrivateServer.Value = false
		PanelController.OpenPanelByContext("PrivateServerControlsGUI", "PrivateServerControlsPanel")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v