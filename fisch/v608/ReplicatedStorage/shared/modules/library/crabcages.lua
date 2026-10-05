local byName = {
	["Crab Cage"] = {
		Id = 0,
		Color = Color3.fromRGB(119, 108, 181),
		Luck = 0,
		Lure = 0,
		Strength = 100,
		Durability = 0
	},
	["Reinforced Crab Cage"] = {
		Id = 1,
		Color = Color3.fromRGB(221, 231, 255),
		Luck = 10,
		Lure = -100,
		Strength = 1e999,
		Durability = 200,
		FishCountMin = 2,
		FishCountMax = 4
	},
	["Coral Crab Cage"] = {
		Id = 2,
		Color = Color3.fromRGB(225, 172, 255),
		Luck = 5,
		Lure = 50,
		Strength = 50,
		Durability = 0
	},
	["Relic Crab Cage"] = {
		Id = 3,
		Color = Color3.fromRGB(90, 255, 206),
		Luck = 25,
		Lure = -25,
		Strength = 100000,
		Durability = 200
	},
	["Golden Crab Cage"] = {
		Id = 4,
		Color = Color3.fromRGB(255, 202, 111),
		Luck = 50,
		Lure = 70,
		Strength = 25000,
		Durability = 0,
		FishCountMin = 1,
		FishCountMax = 2
	}
}
local byId = {}

for k, v3 in byName do
	v3.Name = k
	byId[v3.Id] = v3
end

return {
	byName = byName,
	byId = byId
}