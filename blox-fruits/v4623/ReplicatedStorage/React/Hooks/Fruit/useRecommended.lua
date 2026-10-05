local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local useOwned = require(script.Parent.useOwned)
local v = {
	"Common",
	"Uncommon",
	"Rare",
	"Legendary",
	"Mythical"
}
local v2 = {
	Common = {
		"Rocket-Rocket",
		"Blade-Blade",
		"Spin-Spin",
		"Smoke-Smoke",
		"Bomb-Bomb",
		"Spring-Spring",
		"Spike-Spike"
	},
	Uncommon = {
		"Ice-Ice",
		"Flame-Flame",
		"Dark-Dark",
		"Eagle-Eagle",
		"Diamond-Diamond",
		"Sand-Sand"
	},
	Rare = {
		"Light-Light",
		"Magma-Magma",
		"Rubber-Rubber",
		"Ghost-Ghost"
	},
	Legendary = {
		"Buddha-Buddha",
		"Portal-Portal",
		"Lightning-Lightning",
		"Pain-Pain",
		"Creation-Creation",
		"Phoenix-Phoenix",
		"Quake-Quake",
		"Love-Love",
		"Blizzard-Blizzard",
		"Sound-Sound",
		"Spider-Spider"
	},
	Mythical = {
		"Dragon-Dragon",
		"Kitsune-Kitsune",
		"Gas-Gas",
		"Dough-Dough",
		"T-Rex-T-Rex",
		"Yeti-Yeti",
		"Control-Control",
		"Venom-Venom",
		"Gravity-Gravity",
		"Spirit-Spirit",
		"Mammoth-Mammoth",
		"Shadow-Shadow"
	}
}
return function()
	local v3 = useOwned() or {}
	local result = {}

	for _, v4 in v do
		local v5 = nil
		local v6 = nil

		for _, v8 in v2[v4] do
			local nullable = ItemConfig.match(v8, "PhysicalMoveset"):asNullable()

			if nullable then
				local itemId = nullable.Index.ItemId

				if v5 == nil then
					v5 = itemId
				end

				if not v3[`Permanent {v8}`] then
					v6 = itemId
					break
				end
			else
				warn((`Missing ItemConfig data: {v4} {v8}`))
			end
		end

		table.insert(result, v6 or v5 or v6)
	end

	return result
end