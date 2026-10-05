local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Clans = require(ReplicatedStorage.CAM.Clans)
local SkillTreeholder = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder)
local Discord = require(ServerStorage.SAM.Services.Reporting.Discord)
return function(player, instance, _: string, _: number, p2)
	local clan

	if p2 ~= nil then
		clan = p2.Clan or nil
	end

	if clan == nil or Clans.GetClan(clan) == nil or Clans.TestClans[clan] ~= nil then
		return false, (`"{tostring(clan)}" is not a purchasable clan`)
	end

	local clan2

	if instance ~= nil then
		clan2 = instance:FindFirstChild("Clan") or nil
	end

	if clan2 == nil then
		return false, "no Clan value on the slot"
	end

	local previous = clan2.Value
	SkillTreeholder.TransferBranch(player, previous, clan)
	clan2.Value = clan
	local tier = Clans.TierOf(clan)
	Discord.Send("clans", tier.name .. "Roll", {
		player = player,
		data = {
			clan = clan,
			rarity = tier.name,
			source = "Shop",
			previous = previous
		}
	})
	return true
end