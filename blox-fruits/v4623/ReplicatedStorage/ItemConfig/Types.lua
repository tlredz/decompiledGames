local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Shared)
local Display = require(script.Display)
local Inventory = require(script.Inventory)
local Quality = require(script.Quality)
local Economy = require(script.Economy)
local State = require(script.State)
local Skin = require(script.Skin)
local Moveset = require(script.Moveset)
local Mutation = require(script.Mutation)
local Gacha = require(script.Gacha)
local Variant = require(script.Variant)
local Equipment = require(script.Equipment)
local Index = require(script.Index)
local modules = {
	Index = require(script.Parent.Data.Index),
	Display = require(script.Parent.Data.Display),
	Inventory = require(script.Parent.Data.Inventory),
	Skin = require(script.Parent.Data.Skin),
	Variant = require(script.Parent.Data.Variant),
	Moveset = require(script.Parent.Data.Moveset),
	Economy = require(script.Parent.Data.Economy),
	Equipment = require(script.Parent.Data.Equipment),
	Quality = require(script.Parent.Data.Quality),
	State = require(script.Parent.Data.State),
	Mutation = require(script.Parent.Data.Mutation),
	Gacha = require(script.Parent.Data.Gacha)
}

local function unpackConfig(p: string, p2: string, value: number, callback, callback2)
	local v2 = modules[p][value]

	if not v2 then
		return {
			Ok = false,
			Message = `No "{p}" data for "{p2}"`
		}
	end

	local v3 = callback(v2)

	if v3.Ok == false then
		return {
			Ok = false,
			Message = `{p} parsing for "{p2}" failed: {v3.Message}`
		}
	end

	if callback2 and callback2(v3.Value) then
		return {
			Ok = true,
			Value = nil
		}
	end

	return {
		Ok = true,
		Value = v3.Value
	}
end

local function parseItemConfig(p)
	local itemId = Parse.ItemId(p)

	if itemId.Ok == false then
		return itemId
	end

	local value = itemId.Value
	local v2 = modules.Index[value]

	if not v2 then
		return {
			Ok = false,
			Message = `No index data for item id {value}`
		}
	end

	if v2["Do Not Use"] ~= "FALSE" then
		return {
			Ok = false,
			Message = `ItemConfig constructing skipped for retired Id "{v2.Label}"`
		}
	end

	local v3 = unpackConfig("Index", `#{value}`, value, Index)

	if v3.Ok == false then
		return v3
	end

	local value2 = v3.Value
	local debugLabel = value2.DebugLabel
	local v4 = unpackConfig("Display", debugLabel, value, Display)

	if v4.Ok == false then
		return v4
	end

	local v5 = unpackConfig("Quality", debugLabel, value, Quality)

	if v5.Ok == false then
		return v5
	end

	local v6 = unpackConfig("Economy", debugLabel, value, Economy, function(data)
		return data.PurchaseWith == nil and data.ProductId == nil and data.TradeReducer == nil
	end)

	if v6.Ok == false then
		return v6
	end

	local value3 = v6.Value

	if value2.IdType ~= "Redeemable" and value3 and (value3.RobuxPrice or value3.ProductId or value3.GamepassId) then
		return {
			Ok = false,
			Message = `"{debugLabel}" is of type "{value2.IdType}" and cannot have a product - only Redeemable items can have products.`
		}
	end

	local v7 = unpackConfig("Skin", debugLabel, value, Skin, function(p2)
		return p2.Type == nil
	end)

	if v7.Ok == false then
		return v7
	end

	local v8 = unpackConfig("Variant", debugLabel, value, Variant)

	if v8.Ok == false then
		return v8
	end

	local v9 = unpackConfig("Moveset", debugLabel, value, Moveset, function(p2)
		return p2.Type == nil
	end)

	if v9.Ok == false then
		return v9
	end

	local v10 = unpackConfig("State", debugLabel, value, State)

	if v10.Ok == false then
		return v10
	end

	local v11 = unpackConfig("Equipment", debugLabel, value, Equipment, function(p2)
		return p2.Adornee == nil
	end)

	if v11.Ok == false then
		return v11
	end

	local v12 = unpackConfig("Inventory", debugLabel, value, Inventory)

	if v12.Ok == false then
		return v12
	end

	local v13 = unpackConfig("Mutation", debugLabel, value, Mutation)

	if v13.Ok == false then
		return v13
	end

	local v14 = unpackConfig("Gacha", debugLabel, value, Gacha, function(p2)
		return p2.BaseWeight == nil
	end)

	if v14.Ok == false then
		return v14
	end

	return {
		Ok = true,
		Value = {
			Index = value2,
			Display = v4.Value,
			Quality = v5.Value,
			Inventory = v12.Value,
			Skin = v7.Value,
			Variant = v8.Value,
			Moveset = v9.Value,
			Equipment = v11.Value,
			Mutation = v13.Value,
			Economy = v6.Value,
			State = v10.Value,
			Gacha = v14.Value
		}
	}
end

local Types = {
	finalize = function(p)
		local debugLabel = p.Index.DebugLabel
		setmetatable(p, {
			__tostring = function(...)
				return (`ItemConfig({debugLabel})`)
			end
		})
		TableUtil.deepFreeze(p)
		return p
	end
}

function Types.from(p: number)
	local v2 = parseItemConfig(p)

	if v2.Ok == false then
		return nil, v2.Message
	end

	return Types.finalize(v2.Value)
end

return Types