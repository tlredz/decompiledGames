local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.RewardInfo)
local v4 = require3(ReplicatedStorage2.Shared.SinglePass.SinglePassCrate)
local remoteEvent = v:RemoteEvent("OpenSinglePassCrate")
return {
	{
		Reward = v3.createExplosionReward("Crystal Burst"),
		ItemType = "Explosion",
		Cost = 500
	},
	{
		Reward = v3.createExplosionReward("Snowfall"),
		ItemType = "Explosion",
		Cost = 1000
	},
	{
		Reward = v3.createSwordReward("Frostbite Annihilator"),
		ItemType = "Sword",
		Cost = 100000,
		LimitedStockName = "Frostbite Annihilator",
		CanBePurchased = function(object)
			local v5

			if RunService:IsClient() then
				v5 = v2.Client:WaitReplion("LimitedStockItems")
			else
				v5 = v2.Server:WaitReplion("LimitedStockItems")
			end

			if not (v5 and v5:Get("Loaded")) then
				return false
			end

			local v6 = v5:Get({ "Stock", "Frostbite Annihilator" })

			if v6 and not (v6 <= 0) then
				return not object:Get("PurchasedFrostbiteAnnihilator")
			end

			return false
		end,
		ShouldGiveReward = function(p)
			if RunService:IsClient() then
				task.spawn(error, "This function is server side only!")
				return false
			end

			if p.Type == "Sword" and p.Value ~= "Frostbite Annihilator" then
				return false
			end

			local ServerScriptService = game:GetService("ServerScriptService")
			return (require3(ServerScriptService.Game.Services.LimitedStockService):DecreaseStock(
				"Frostbite Annihilator",
				1
			))
		end
	},
	{
		Reward = v3.createEmoteReward("Icy Breath"),
		ItemType = "Emote",
		Cost = 1250
	},
	{
		Reward = v3.createEmoteReward("Blizzard Aura"),
		ItemType = "Emote",
		Cost = 1500
	},
	{
		Reward = v3.createEmoteReward("Snowball Fight"),
		ItemType = "Emote",
		Cost = 2500
	},
	{
		CustomReward = true,
		Reward = function(player, _)
			local integer = Random.new():NextInteger(1, 1073741823)
			local _, v5 = v4.SpinTable(v4.Items, integer)

			if not v5 then
				return false
			end

			require3(game.ServerScriptService.Game.Server.AwardService):AwardFromRewardInfo(
				player,
				v5.Reward,
				nil,
				false
			)
			remoteEvent:FireClient(player, v5.Reward, integer)
			return true
		end,
		DisplayName = "Winter Sword Crate",
		Icon = "rbxassetid://18462883093",
		ItemType = "Crate",
		Cost = 750
	}
}