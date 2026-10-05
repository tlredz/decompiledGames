local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AlertBadge = require(ReplicatedStorage.Client.UI.AlertBadge)
local Hud = require(ReplicatedStorage.Client.Hud)
local Tabs = require(ReplicatedStorage.Client.Tabs)
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local v = AlertBadge.Attach(Hud.Find("ShopButton"))
		local v2 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateBadge()
			if not v2 and localPlayer:GetAttribute("ShopVersionChanged") == true then
				v:Show()
			end
		end

		Tabs.Activated:Connect(function(p: string)
			if p == "Shop" then
				v2 = true
				v:Dismiss()
			end
		end)
		localPlayer:GetAttributeChangedSignal("ShopVersionChanged"):Connect(updateBadge)
		updateBadge() -- equivalent call inferred; original call site unknown
	end
}