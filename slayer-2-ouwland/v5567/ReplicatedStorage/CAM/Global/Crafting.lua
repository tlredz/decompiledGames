local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Series = require(ReplicatedStorage.CAM.Global.Series)
local SettingsLive = require(ReplicatedStorage.CAM.Global.SettingsLive)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
require(ReplicatedStorage.CAM.Global.Types.CraftingTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Crafting = {
	Definitions = require(script.DefaultConfigs)
}

for k, definition in Crafting.Definitions do
	local count = #definition.required

	if count < 1 or count > 3 then
		warn((`Crafting: "{k}" has {count} required items, needs {1} to {3}`))
	end
end

Crafting.Live = SettingsLive.new("CraftingRecipes", Crafting.Definitions, Crafting.Definitions)
Crafting.StationNpcs = {
	Ouwigahara = { "Blacksmith Togane" },
	Ouwland = { "Blacksmith Togane" },
	["Hidden Mist"] = { "Yagane" }
}

function Crafting.Get(p: string)
	return Crafting.Definitions[p]
end

function Crafting.Spendable(instance, p: string)
	return instance.Name == p and instance:FindFirstChild("NoSave") == nil and instance:FindFirstChild("QuestGrant") == nil
end

function Crafting.Held(instance, p: string, p2: number?)
	local total = 0

	if instance == nil then
		return total
	end

	for _, child in instance:GetChildren() do
		if not (Crafting.Spendable(child, p) and (p2 == nil or Series.TierOf(child) == p2)) then
			continue
		end

		local amount = child:FindFirstChild("Amount")
		total += amount == nil and 1 or amount.Value or 1
	end

	return total
end

function Crafting.PricedLine(p, p2, p3: string, p4: number)
	if p2.fullPrice == true then
		return p4
	end

	return Shop.PricedFor(p, p3, p4, 1)
end

function Crafting.RequiredTier(p, p2: string)
	if p.requiredTier == nil or p2 ~= p.required[1].name then
		return nil
	end

	return p.requiredTier
end

function Crafting.SpentCopy(p, p2: string, p3: number?)
	local itemBag = Utility.ItemBag(Utility.GetData(p), p2)

	if itemBag == nil then
		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fits(p4)
		return Crafting.Spendable(p4, p2) and (p3 == nil or Series.TierOf(p4) == p3)
	end

	if Refinement.IsRefinable(p2) then
		local get_equipped_tool = Character_info_provider.Get_equipped_tool(p)

		if typeof(get_equipped_tool) == "Instance" and get_equipped_tool.Parent == itemBag and Crafting.Spendable(
			get_equipped_tool,
			p2
		) and (p3 == nil or Series.TierOf(get_equipped_tool) == p3) then
			return get_equipped_tool
		end

		local v = 1e999
		local v2 = nil

		for _, child in itemBag:GetChildren() do
			if not fits(child) then
				continue
			end

			local refineLevel = child:FindFirstChild("RefineLevel")
			local v3 = refineLevel == nil and 0 or refineLevel.Value

			if not (v3 < v) then
				continue
			end

			v2 = child
			v = v3
		end

		return v2
	else
		for _, child in itemBag:GetChildren() do
			if fits(child) then
				return child
			end
		end

		return nil
	end
end

Crafting.TierTransferShare = 0.25

function Crafting.TierUp(p: string, p2: number)
	for _, definition in Crafting.Definitions do
		if definition.result == p and definition.tier == p2 and definition.requiredTier == p2 - 1 then
			return definition
		end
	end

	return nil
end

local function tierBill(p: string, p2: number, p3: number, flag: boolean)
	local result = {}

	for i = p2 + 1, p3 do
		local tierUp = Crafting.TierUp(p, i)

		if tierUp == nil then
			return nil
		end

		for k, v in tierUp.price do
			result[k] = (result[k] or 0) + v
		end

		for _, additionalMaterial in tierUp.additionalMaterials do
			local item = Items[additionalMaterial.name]
			local v = flag and item ~= nil and item.SetMaterial ~= nil and "\0Set" or additionalMaterial.name
			result[v] = (result[v] or 0) + additionalMaterial.amount
		end
	end

	return result
end

function Crafting.TierTransferFee(p: string, p2: string, p3: number, p4: number)
	if p4 <= p3 then
		return nil
	end

	local v = tierBill(p, p3, p4, true)
	local v2 = tierBill(p2, p3, p4, true)

	if v == nil or v2 == nil then
		return nil
	end

	for k, v3 in v do
		if v2[k] ~= v3 then
			return nil
		end
	end

	for k, v3 in v2 do
		if v[k] ~= v3 then
			return nil
		end
	end

	local result = {}

	for k, v3 in tierBill(p2, p3, p4, false), nil, nil do
		result[k] = math.ceil(v3 * Crafting.TierTransferShare)
	end

	return result
end

function Crafting.ForStation(p: string?)
	local definitions = {}

	for k, definition in Crafting.Definitions do
		if p == nil or definition.station == p then
			definitions[k] = definition
		end
	end

	return definitions
end

return Crafting