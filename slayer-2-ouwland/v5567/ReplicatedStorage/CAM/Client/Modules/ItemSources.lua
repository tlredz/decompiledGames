local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Crafting = require(ReplicatedStorage.CAM.Global.Crafting)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local v = {
	"OuwFish",
	"Sea Horse",
	"Coral",
	"OuwFwesh",
	"Metal Scraps",
	"Silk Thread",
	"Golden Fish",
	"Clown Fish",
	"Zebra Fish",
	"Refinement Ore",
	"Crustadon",
	"Krathulon",
	"Squid Beanie",
	"Lost Lantern",
	"Lost Cape",
	"Lost Mask",
	"Lost Outfit",
	"Mythic Refinement Ore",
	"Shotgun Schematic",
	"Refinement Guard",
	"Lost Shotgun",
	"Ore"
}
local v2 = {}
local v3 = {}

local function add(p: string, where: string, chance: number?)
	if Items[p] == nil then
		return
	end

	local v4 = v3[p]

	if v4 == nil then
		v4 = {}
		v3[p] = v4
	end

	for _, v5 in v4 do
		if v5.Where ~= where then
			continue
		end

		if v5.Chance ~= nil and (chance == nil or v5.Chance < chance) then
			v5.Chance = chance
		end

		return
	end

	table.insert(v4, {
		Where = where,
		Chance = chance
	})
end

local function rewards(rewards2, where: string)
	if typeof(rewards2) ~= "table" then
		return
	end

	for k, item in rewards2 do
		if type(item) == "number" then
			add(k, where, item)
		elseif typeof(item) == "table" then
			local v5

			if type(item.Chance) == "number" then
				v5 = item.Chance
			end

			add(k, where, v5)
		end
	end
end

local function stock(items, formatted: string)
	if typeof(items) ~= "table" then
		return
	end

	for _, name in items do
		if type(name) ~= "string" then
			name = name.Name
		end

		if type(name) == "string" then
			add(name, formatted)
		end
	end
end

local function build()
	v3 = {}
	local npcDataTable = LiveConfig.get("NpcDataTable")

	if typeof(npcDataTable) == "table" then
		for k, v4 in npcDataTable do
			if typeof(v4) == "table" then
				rewards(v4.Rewards, v4.Name or k)
			end
		end
	end

	local chestsLootTable = LiveConfig.get("ChestsLootTable")

	if typeof(chestsLootTable) == "table" then
		for k, v4 in chestsLootTable do
			if typeof(v4) ~= "table" then
				continue
			end

			for _, v5 in v4.loot or {} do
				add(v5.itemId, k, v5.chance or 1)
			end

			for _, v5 in v4.guaranteed or {} do
				add(v5.itemId, k)
			end
		end
	end

	for _, v4 in v do
		add(v4, "Fished up")
	end

	local Regions = require(ReplicatedStorage.Regions)

	for _, region in Regions.Regions do
		for _, v4 in region.Npcs or {} do
			if type(v4.Name) ~= "string" then
				continue
			end

			local formatted = `Sold by {v4.Name}`

			for k in v4.Shop or {} do
				add(k, formatted)
			end

			stock(v4.RotatingShop and v4.RotatingShop.Pool, formatted)
			stock(v4.TimedVendor and v4.TimedVendor.Stock, formatted)
			stock(v4.TimedVendor and v4.TimedVendor.Always, formatted)
		end
	end

	for _, v4 in Quests.Holder do
		local questInstance = v4.QuestInstance

		if typeof(questInstance) == "Instance" then
			rewards(v4.Rewards, `Quest: {questInstance.Name}`)
		end
	end

	for _, definition in Crafting.Definitions do
		if definition.station ~= nil then
			add(definition.result, (`Crafted at {definition.station}`))
		end
	end

	for _, list in v3 do
		table.sort(list, function(a, b)
			local chance = a.Chance or -1
			local chance2 = b.Chance or -1

			if chance == chance2 then
				return a.Where < b.Where
			end

			return chance2 < chance
		end)
	end

	v2 = v3
end

local ItemSources = {
	Get = function(p: string)
		return v2[p] or {}
	end
}
task.spawn(build)
LiveConfig.listen("NpcDataTable", build)
LiveConfig.listen("ChestsLootTable", build)
return ItemSources