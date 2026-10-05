local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local BuyBaitController = require(ReplicatedStorage.client.legacyControllers.Shop.BuyBaitController)
local localPlayer = Players.LocalPlayer
Net:RemoteEvent("BuyBait/Show")
local v = Component.new({
	Tag = "BuyBait"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local prompt = p.Instance:WaitForChild("Prompt")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePolicy()
		prompt.Enabled = localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") ~= true
	end

	updatePolicy() -- equivalent call inferred; original call site unknown
	p.trove:Add(localPlayer:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Connect(updatePolicy))
	p.trove:Add(prompt.Triggered:Connect(function()
		BuyBaitController:Show()
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v