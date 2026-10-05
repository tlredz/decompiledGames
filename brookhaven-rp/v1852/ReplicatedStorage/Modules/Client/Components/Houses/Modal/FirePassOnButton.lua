local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "FirePassOnButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if not self.Instance:IsA("GuiButton") then
		return
	end

	local v2 = false
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if v2 == false then
			v2 = true
			local noResetGUIHandler = Players.LocalPlayer.PlayerGui:WaitForChild("NoResetGUIHandler")

			if noResetGUIHandler == nil or noResetGUIHandler:FindFirstChild("FireWait") then
				LegacyGame8Settings.PlayersHouse:FireServer("PlayerWantsFireOnFirePassNotShowingAnyone")
			else
				local stringValue = Instance.new("StringValue")
				stringValue.Name = "FireWait"
				game.Debris:AddItem(stringValue, 180)
				stringValue.Parent = noResetGUIHandler
				LegacyGame8Settings.PlayersHouse:FireServer("PlayerWantsFireOnFirePass")
			end

			wait(4)
			v2 = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v