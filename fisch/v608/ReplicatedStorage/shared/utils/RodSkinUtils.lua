local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local RodSkinUtils = {
	getRodForSkin = function(value: string)
		if value:find("^Default/") then
			return value:gsub("^Default/", "")
		end

		return RodSkins.Skins[value].TargetRod
	end,
	getAllSkinsForRod = function(p: string)
		local clone = RodSkins.RodsSkins[p] and table.clone(RodSkins.RodsSkins[p]) or {}

		for k, v in RodSkins.RodsSkins.All do
			if not clone[k] then
				clone[k] = v
			end
		end

		return clone
	end
}

function RodSkinUtils.getUnlockedSkinsForRod(p, p2: string)
	local result = {}

	for k in RodSkinUtils.getAllSkinsForRod(p2) do
		if p[k] and p[k].stack > 0 then
			result[k] = true
		end
	end

	return result
end

return RodSkinUtils