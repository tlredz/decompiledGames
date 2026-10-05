local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseOpenMailbox"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

function v:Construct()
	self._Janitor = Janitor.new()
	self._debounce = false
end

function v:Start()
	local game8Settings = ReplicatedStorage:WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local maxy = module.Maxy
	local tempMailHouseNumber = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("TempMailHouseNumber")
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if not self._debounce then
			self._debounce = true
			PanelController.OpenPanelByContext("NoResetGUIHandler", "MailboxUI")
			maxy:FireServer("LetterUIMailCheck", tempMailHouseNumber.Value)
			task.wait(0.5)
			self._debounce = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v