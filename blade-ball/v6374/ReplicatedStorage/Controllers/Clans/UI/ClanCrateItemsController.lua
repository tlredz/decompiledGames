local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.LootboxData)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Controllers.Clans.ClanPageController)
local crateItems = Players.LocalPlayer.PlayerGui:WaitForChild("Clans"):WaitForChild("CrateItems")
local frame = crateItems.Frame.List.UIListLayout.Frame

local function trashOGFormatToRewardInfo(item)
	local simpleReward = item.SimpleReward
	local result = {}

	if simpleReward.Abilities then
		for _, ability in simpleReward.Abilities do
			table.insert(result, v2.createAbilityReward(ability))
		end
	end

	if simpleReward.Emotes then
		for _, emote in simpleReward.Emotes do
			table.insert(result, v2.createEmoteReward(emote))
		end
	end

	if simpleReward.Explosions then
		for _, explosion in simpleReward.Explosions do
			table.insert(result, v2.createExplosionReward(explosion))
		end
	end

	if simpleReward.Swords then
		for _, sword in simpleReward.Swords do
			table.insert(result, v2.createSwordReward(sword))
		end
	end

	if simpleReward.Coins then
		for _, coin in simpleReward.Coins do
			table.insert(result, v2.createCoinsReward(tonumber(coin:match("^%d+")) or 0, "Med"))
		end
	end

	if simpleReward.Emote then
		table.insert(result, v2.createEmoteReward(simpleReward.Emote))
	end

	if simpleReward.Explosion then
		table.insert(result, v2.createExplosionReward(simpleReward.Explosion))
	end

	if simpleReward.Sword then
		table.insert(result, v2.createSwordReward(simpleReward.Sword))
	end

	return result
end

local maid = v3.new()
local ClanCrateItemsController = {}

function ClanCrateItemsController.RenderOdds(_, p: string)
	maid:Clean()
	local items = nil

	if p == "Clan Sword" then
		items = v.GachaEvents.ClanSwordCrate.Items
	elseif p == "Clan Magical" then
		items = v.GachaEvents.ClanMagicalCrate.Items
	end

	for _, item in items do
		local v4 = maid:Add(frame:Clone())
		local v5 = trashOGFormatToRewardInfo(item)[1]
		local frame2 = v4.Frame
		frame2.DisplayName.Text = v5.DisplayName
		frame2.Chance.Text = `{item.Chance}%`
		frame2.Reward.Vector.Image = v5.Icon or "rbxassetid://0"
		v4.LayoutOrder = item.Chance * 1000
		v4.Parent = crateItems.Frame.List
	end

	crateItems.Visible = true
end

function ClanCrateItemsController.Start(_)
	crateItems.Black.Activated:Connect(function()
		crateItems.Visible = false
	end)
	crateItems.Frame.Close.Activated:Connect(function()
		crateItems.Visible = false
	end)
end

return ClanCrateItemsController