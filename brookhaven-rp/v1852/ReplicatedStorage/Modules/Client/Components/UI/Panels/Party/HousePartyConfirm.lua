local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HousePartyConfirm"
})
local v2 = nil

function v.SetData(callback)
	v2 = callback
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance:WaitForChild("InteractButtons"):WaitForChild("Yes").Activated:Connect(function()
		PanelController.Close("MainGUIHandler", "HousePartyConfirm")

		if v2 ~= nil then
			v2()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v