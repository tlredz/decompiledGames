local CombatUtility = {}
Random.new()
game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Server = RunService:IsServer() and require(game.ServerScriptService.Server)

function CombatUtility.GetExplosiveDamage(p, p2, p3)
	if p3 < p2 then
		return 0
	end

	local v = p3 * 0.35

	if p2 < v then
		return p
	end

	return p * math.clamp(1 - (p2 - v) / (p3 - v), 0.2, 1)
end

function CombatUtility.ApplyArmourToDamage(p, value)
	return p * (1 - math.clamp(value, 0, 100) / 100 * 0.8)
end

function CombatUtility.GetTotalArmour(instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if RunService:IsServer() then
		if playerFromCharacter then
			local wearing = Server.InventoryHandler.PlayerEquipped[playerFromCharacter] and Server.InventoryHandler.PlayerEquipped[playerFromCharacter].Wearing

			if wearing then
				local total = 0

				for _, v in pairs(wearing) do
					if not (v and v:GetAttribute("Owner") == playerFromCharacter.UserId and (v:GetAttribute("Durability") or 100) > 0) then
						continue
					end

					total += Server.Databases.Items[v.Name].Armour or 0
				end

				return total
			end
		elseif instance:FindFirstChild("Enemy") and instance.Enemy:IsA("Humanoid") then
			return instance:GetAttribute("Armour") or 0
		end
	else
		if playerFromCharacter and playerFromCharacter:FindFirstChild("Stats") then
			return (playerFromCharacter.Stats:GetAttribute("Armour"))
		end

		if instance:GetAttribute("Armour") then
			return instance:GetAttribute("Armour")
		end
	end

	return 0
end

return CombatUtility