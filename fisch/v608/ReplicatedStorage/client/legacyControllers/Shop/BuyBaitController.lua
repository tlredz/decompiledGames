local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Monetization = require(shared.Monetization)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local bait = require(modules.library.bait)
local maid = Trove.new()
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("hud")
local safezone = hud:WaitForChild("safezone")
local buyBait = safezone:WaitForChild("BuyBait")
local close = buyBait:WaitForChild("Close")
local info = buyBait:WaitForChild("Info")
local buyButtons = buyBait:WaitForChild("BuyButtons")
local buy5 = buyButtons:WaitForChild("Buy5")
local buy25 = buyButtons:WaitForChild("Buy25")
local baitName = buyBait:GetAttribute("BaitName")
Net:RemoteEvent("BuyBait/Show", -1)
local BuyBaitController = {
	Show = function(_)
		if localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") == true then
			return
		end

		buyBait.Visible = true
	end,
	Close = function(self)
		buyBait.Visible = false
	end
}

function BuyBaitController:SetupUi()
	maid:Clean()
	hud = playerGui:WaitForChild("hud")
	safezone = hud:WaitForChild("safezone")
	buyBait = safezone:WaitForChild("BuyBait")
	close = buyBait:WaitForChild("Close")
	info = buyBait:WaitForChild("Info")
	buyButtons = buyBait:WaitForChild("BuyButtons")
	buy5 = buyButtons:WaitForChild("Buy5")
	buy25 = buyButtons:WaitForChild("Buy25")
	local v = bait[baitName]

	if not v then
		return
	end

	buyBait.BaitName.Text = baitName
	info.Luck.Text = `Preferred Luck: {v.PreferredLuck}`
	info.GenerelLuck.Text = `Universal Luck: {v.Luck}`
	info.LureSpeed.Text = `Lure Speed: {v.Lure}`
	info.Resilience.Text = `Resilience: {v.Resilience}`

	for childName, bait2 in pairs(Monetization.products.Baits) do
		local child = buyButtons:WaitForChild(childName)
		local robuxPrice = Monetization:GetRobuxPrice(bait2.ProductId)

		if robuxPrice then
			child.Text = utf8.char(57346) .. tostring(robuxPrice)
		end

		local v2 = bait2
		maid:Add(child.Activated:Connect(function()
			local success, result = pcall(function()
				Monetization.BuyProduct:FireServer(v2.ProductId)
			end)
		end))
	end

	maid:Add(close.Activated:Connect(function()
		BuyBaitController:Close()
	end))
end

function BuyBaitController.Start(_)
	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	BuyBaitController:SetupUi()
	localPlayer.CharacterAdded:Connect(function()
		BuyBaitController:SetupUi()
	end)
end

return BuyBaitController