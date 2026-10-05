local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = require(ReplicatedStorage.Datas.Animals)
require(ReplicatedStorage.Shared.BrainrotAssets)
local v = {
	["Eggdin Egg Egg Dun Egg"] = 0.6
}
return table.freeze({
	BaselineSize = 7.8,
	MinScale = 0.6,
	MaxScale = 2.5,
	GetHatchBrainrot = function(p: string)
		local animal = Animals[p]
		local egg = animal and (animal.Egg or animal.LuckyBlock)

		if not egg then
			return nil
		end

		local v2 = -1
		local name = nil

		for _, animal2 in egg.Animals do
			if type(animal2) == "string" then
				if not name then
					name = animal2
				end
			else
				local chance = animal2.Chance or 0

				if v2 < chance then
					name = animal2.Name
					v2 = chance
				end
			end
		end

		return name
	end,
	GetEggScale = function(p: string)
		local v2 = v[p]
		return v2 or 1
	end
})