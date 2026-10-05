local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = {
	"Bounty",
	"Quasar",
	"Tact",
	"Serpent Shadow Clone",
	"Displace",
	"Encrypted Clone"
}
local v5 = { "Serpent Shadow Clone", "Encrypted Clone" }
return {
	Normal = {
		v2.createEmoteReward("I'm Busy"),
		function(instance)
			local replionFor = nil

			if RunService:IsServer() then
				replionFor = v.Server:GetReplionFor(instance, "Data")
			elseif RunService:IsClient() then
				replionFor = v.Client:WaitReplion("Data")
			end

			if not replionFor then
				return v2.createAbilityReward(v4[#v4])
			end

			local abilityReward = v2.createAbilityReward(v4[#v4])
			local v6 = nil
			local v7 = nil

			for _, v9 in ipairs(v4) do
				v7 = v2.createAbilityReward(v9)

				if v3.RewardInfo.playerOwnsItem(instance, v7) then
					v6 = v7
				else
					if RunService:IsClient() and v6 and replionFor:Find("BattlepassSelectionCrate.Selected.Normal", 2) ~= nil then
						v7 = v6
					end

					break
				end
			end

			if v7.Value ~= abilityReward.Value or not v3.RewardInfo.playerOwnsItem(instance, abilityReward) then
				return v7
			end

			for _, childName in v5 do
				local abilityReward2 = v2.createAbilityReward(childName)

				if not v3.RewardInfo.playerOwnsItem(instance, abilityReward2) then
					continue
				end

				local upgrades = instance:FindFirstChild("Upgrades")
				local child = upgrades and upgrades:FindFirstChild(childName)

				if child and child.Value < 1 then
					return v2.createAbilityUpgradeReward(childName, 1)
				end
			end

			return v7
		end,
		v2.createExplosionReward("Floral Nova"),
		(v2.createSwordReward("Kira Kira"))
	},
	Premium = {
		v2.createSwordReward("Diamond Dream"),
		v2.createExplosionReward("Valentine Love"),
		v2.createSwordReward("Bluebell Blastblade"),
		(v2.createSwordReward("Fuchsia Shuriken"))
	}
}