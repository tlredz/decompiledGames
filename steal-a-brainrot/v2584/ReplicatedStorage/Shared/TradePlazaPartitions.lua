local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = require(ReplicatedStorage.Datas.Animals)
local TradePlazaServerBrowserFlags = require(ReplicatedStorage.Shared.Flags.TradePlazaServerBrowserFlags)
local v = {
	Order = { "Normal", "Pro", "OG" },
	getProGenerationRequirement = function()
		return TradePlazaServerBrowserFlags.ProGenerationRequirement:Get()
	end,
	getOGGenerationRequirement = function()
		return TradePlazaServerBrowserFlags.OGGenerationRequirement:Get()
	end,
	podiumsHaveOGBrainrot = function(items)
		if type(items) ~= "table" then
			return false
		end

		for _, item in items do
			if type(item) ~= "table" then
				continue
			end

			local animal = Animals[item.Index]

			if animal and animal.Rarity == "OG" then
				return true
			end
		end

		return false
	end
}

function v.meetsRequirement(p: string, p2: number, flag: boolean)
	if p == "Pro" then
		return v.getProGenerationRequirement() <= p2
	end

	if p ~= "OG" then
		return true
	end

	if not (v.getOGGenerationRequirement() <= p2) then
		flag = false
	end

	return flag
end

return table.freeze(v)