local import = _G.import("global")
local import2 = _G.import("class")
local import3 = _G.import("aura")
local import4 = _G.import("rewardData")
local import5 = _G.import("configuration")
game:GetService("MarketplaceService")
local PET = import5.PET
local v = import2.new()

function v.award(p, p2)
	local playerByUserId = game.Players:GetPlayerByUserId(p.UserId)
	local playerSave = import.get("playerSave", playerByUserId)
	local v2 = import4[p2]

	if v2.Type == "Stat" then
		local statistics = playerSave.Statistics
		local currency = v2.Currency
		statistics[currency] += v2.Amount
	elseif v2.Type == "Chair" then
		playerSave:add("Inventory", "Chair", p2)
	end

	if v2.Award then
		v2.Award(playerByUserId, playerSave, p)
	end
end

function v.awardSet(p, p2, ...)
	local playerByUserId = game.Players:GetPlayerByUserId(p.UserId)
	local playerSave = import.get("playerSave", playerByUserId)
	local result = {}

	for _, v2 in ipairs({ ... }) do
		if playerSave:has("Inventory", p2, v2) then
			if p2 == "Pet" then
				local id = playerSave:findId("Inventory", "Pet", v2)
				local mult = import3.getEffectValue(playerByUserId, "XpMult").Mult
				id.Config.XP = math.clamp((id.Config.XP or 0) + PET.PET_XP_PER_ROLL * mult, 0, PET.PET_MAX_XP)
			end

			local v3 = result[v2]
			result[v2] = v3 and v3 + 1 or 1
		else
			playerSave:add("Inventory", p2, v2, nil, p2 == "Pet" and ({
				XP = 0
			} or nil) or nil)
		end
	end

	return result
end

return v