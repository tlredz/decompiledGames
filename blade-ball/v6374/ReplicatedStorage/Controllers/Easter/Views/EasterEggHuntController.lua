local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v6 = require3(ReplicatedStorage2.Shared.Easter.EggHunt)
local v7 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
local remoteFunction = v2:RemoteFunction("ClaimUGCItem")
local remoteEvent = v2:RemoteEvent("UGCStockUpdated")
local remoteFunction2 = v2:RemoteFunction("ClaimEasterMilestone")
local overview = playerGui:WaitForChild("EasterEvent"):WaitForChild("Overview")
local currency = overview:WaitForChild("CurrencyFrame"):WaitForChild("Currency")
local eggHunt = overview:WaitForChild("Views"):WaitForChild("EggHunt")
local freeUGC = eggHunt:WaitForChild("Main"):WaitForChild("FreeUGC")
local clones = {}
local clones2 = {}
local eggTemplate = eggHunt.Main.List.EggTemplate
eggTemplate.Parent = nil
local milestoneTemplate = eggHunt.Bottom.List.MilestoneTemplate
milestoneTemplate.Parent = nil
local _ = {
	[true] = {
		Image = "rbxassetid://16887596465",
		Hover = "rbxassetid://16887926587"
	},
	[false] = {
		Image = "rbxassetid://16887565833",
		Hover = "rbxassetid://16887915582"
	}
}
local v8 = {
	[true] = {
		Image = "rbxassetid://16887624746",
		Hover = "rbxassetid://16887918666"
	},
	[false] = {
		Image = "rbxassetid://16887920362",
		Hover = "rbxassetid://16887669244"
	}
}
local EasterEggHuntController = {
	Init = function(_)
		v7:RegisterPage("EggHunt", eggHunt)
	end,
	Start = function(_)
		v = v3.Client:WaitReplion("Data")
		freeUGC.Activated:Connect(function()
			ClaimFreeUGC()
		end)
		freeUGC.Claim.Activated:Connect(function()
			ClaimFreeUGC()
		end)
		remoteEvent.OnClientEvent:Connect(function(p, p2)
			if p == "LimitedEgg2026" then
				local formatted = `{v5:AddCommas(p2.RemainingStock)}/{v5:ShrinkNumber(p2.Stock)}`
				freeUGC.Counter.TextLabel.Text = formatted
				overview.Views.HatchEgg.InfoFrame.Frame.Item2.TopRewardLabel.Text = `{formatted} Remaining`
			end
		end)
		v:OnChange("EasterEvent.BunnyCoins", UpdateAllEggs)
		v:OnChange("EasterEvent.CollectedEggs", UpdateAllEggs)
		UpdateAllEggs()
		v:OnChange("EasterEvent.BunnyCoins", UpdateCurrencyFrame)
		UpdateCurrencyFrame(v:Get("EasterEvent.BunnyCoins"))
	end
}

function ClaimFreeUGC()
	if not remoteFunction:InvokeServer("LimitedEgg2026") then
		v4:Close("EasterEvent")
	end
end

function UpdateCurrencyFrame(value: number?)
	currency.AmountList.Amount.Text = v5:AddCommas(value or 0)
end

function UpdateAllEggs()
	local v9 = v:Get("EasterEvent.CollectedEggs")

	if not v9 then
		return
	end

	local v10 = v:Get("EasterEvent.ClaimedMilestones") or table.create(#v6.Milestones, false)

	if not v10 then
		return
	end

	local total = 0

	for _, v11 in v9 do
		total += v11
	end

	UpdateMilestones(total, v10)
	UpdateEggs(total, v9)
end

function UpdateMilestones(p: number, p2)
	for i, milestone in ipairs(v6.Milestones) do
		local v9 = milestone.Value <= p or false
		local v10 = p2[i] and true or false
		local clone = clones2[i]

		if not clone then
			clone = milestoneTemplate:Clone()
			clone.Amount.Coin.Image = milestone.Reward.Icon or ""
			clone.EggCounter.Label.Text = `{milestone.Value}`
			clone.Amount.Label.Text = `{milestone.Reward.Value}`
			local v11 = i
			clone.Claim.MouseButton1Click:Connect(function()
				remoteFunction2:InvokeServer(v11)
			end)
			clone.Parent = eggHunt.Bottom.List
			clones2[i] = clone
		end

		if not clone then
			continue
		end

		clone.Claim.Visible = v9 and not v10
		local v11 = v8[v10]
		clone.Image = v11.Image
		clone.HoverImage = v11.Hover
	end

	local milestone = v6.Milestones[#v6.Milestones]
	eggHunt.Bottom.ProgressBar.Label.Text = `Progress: {p}/{milestone.Value}`
	local v9 = math.clamp(p / milestone.Value, 0, 1)
	eggHunt.Bottom.ProgressBar.Fill.Size = UDim2.fromScale(v9, 1)
	eggHunt.Bottom.ProgressBar.Fill.Visible = v9 > 0
	freeUGC.ProgressBar.Icon.Amount.Text = `{p}/{milestone.Value}`
	freeUGC.ProgressBar.Fill.Size = UDim2.fromScale(v9, 1)
	freeUGC.ProgressBar.Fill.Visible = v9 > 0
	freeUGC.ProgressBar.Visible = p < 100
	freeUGC.Claim.Visible = p >= 100
end

function UpdateEggs(_: number, p)
	for i, egg in ipairs(v6.Eggs) do
		local clone = clones[i]

		if not clone then
			clone = eggTemplate:Clone()
			clone.Label.Text = "0/0"
			clone.Vector.Image = egg.Icon
			clone.LayoutOrder = -egg.Available
			clone.Parent = eggHunt.Main.List
			table.insert(clones, clone)
		end

		local available = egg.Available
		local v9 = math.clamp(p[egg.DisplayName] or 0, 0, available)
		clone.Label.Text = `{v9}/{available}`
		clone.Check.Visible = v9 == available
	end
end

return EasterEggHuntController