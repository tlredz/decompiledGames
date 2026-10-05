local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PromptGift"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local productName = self.Instance:GetAttribute("ProductName")
	local displayName = self.Instance:GetAttribute("DisplayName")
	local v2

	if self.Instance:GetAttribute("DevProduct") then
		v2 = DevProducts
	else
		v2 = Gamepasses
	end

	local v3 = v2.All[productName]
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		local waitForComponent = ComponentUtil.FindAndWaitForComponentByTag(
			Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient"),
			"GiftSelectRecipient",
			false
		)
		waitForComponent:SetGiftData(v2.GetGiftId(v3), displayName, "world")
		waitForComponent:WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("GiftSelectRecipient")):expect():SetPreviousPanel(nil)
		PanelController.OpenPanelByContext("MainGUIHandler", "GiftSelectRecipient")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v