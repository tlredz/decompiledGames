local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "BabyYesButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if not self.Instance:IsA("GuiButton") then
		return
	end

	self._Janitor:Add(self.Instance.Activated:Connect(function()
		LegacyGame8Settings.PlayersHouse:FireServer("BabyOptionYes")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v