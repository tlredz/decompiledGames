local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
require(script.Types.Interface)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	1,
	3,
	10,
	50
}
local v2 = {
	DisplayName = "Luminous Egg",
	RerollName = "Luminous Re-roll",
	EndsAt = Constants.UPDATE_LIVE_AT,
	BalanceKey = "Game.Balance.LimitedEgg",
	ProductName = "Limited Egg",
	MechaPrefix = "Depths ",
	BaseOdds = table.freeze({
		table.freeze({
			AssetId = "Spike",
			Weight = 39
		}),
		table.freeze({
			AssetId = "Manta Ray",
			Weight = 24
		}),
		table.freeze({
			AssetId = "Megalodon",
			Weight = 18
		}),
		table.freeze({
			AssetId = "Electric Eel",
			Weight = 11
		}),
		table.freeze({
			AssetId = "Terra Snapper",
			Weight = 6.5
		}),
		table.freeze({
			AssetId = "Cthulhu",
			Weight = 0.5
		})
	})
}
local v3 = {
	DisplayName = "Extinction Egg",
	RerollName = "Skeletal Re-roll",
	EndsAt = 1791644400,
	BalanceKey = "Game.Balance.ExtinctionEgg",
	ProductName = "Extinction Egg",
	MechaPrefix = "Skeletal ",
	BaseOdds = table.freeze({
		table.freeze({
			AssetId = "Glyptodon",
			Weight = 39
		}),
		table.freeze({
			AssetId = "Terrorbird",
			Weight = 24
		}),
		table.freeze({
			AssetId = "Megatherium",
			Weight = 18
		}),
		table.freeze({
			AssetId = "Dunkleosteus",
			Weight = 11
		}),
		table.freeze({
			AssetId = "Gigantopithecus",
			Weight = 6.5
		}),
		table.freeze({
			AssetId = "Sabertooth",
			Weight = 0.5
		})
	})
}

local function weightedRow(list)
	if type(list) == "table" and type(list[1]) == "string" and type(list[2]) == "number" and not (list[2] <= 0) then
		return true
	end

	return false, "expected { assetName, positiveWeight }"
end

local array = t.array(weightedRow)
local intersection = t.intersection(t.numberPositive, t.numberMax(1))
local interface = t.interface({
	DropTable = array,
	MechaReroll = t.interface({
		Chance = t.numberMax(1),
		DisplayChance = t.numberMax(1),
		DropTable = array
	}),
	Offers = t.array(t.interface({
		Amount = t.intersection(t.integer, t.numberMin(1))
	}))
})

local function toRows(list)
	local values = table.create(#list)

	for k, v4 in list do
		values[k] = table.freeze({ v4.AssetId, v4.Weight })
	end

	return table.freeze(values)
end

local function toEntries(dropTable)
	local values = table.create(#dropTable)

	for k, v4 in dropTable do
		local v5, v6

		if type(v4) == "table" and type(v4[1]) == "string" and type(v4[2]) == "number" and not (v4[2] <= 0) then
			v5 = true
		else
			v5 = false
			v6 = "expected { assetName, positiveWeight }"
		end

		if not v5 then
			error((`limited egg drop row {k}: {v6}`))
		end

		values[k] = table.freeze({
			AssetId = v4[1],
			Weight = v4[2]
		})
	end

	return table.freeze(values)
end

local function prefixed(baseOdds, mechaPrefix: string)
	local values = table.create(#baseOdds)

	for k, v4 in baseOdds do
		values[k] = table.freeze({
			AssetId = mechaPrefix .. v4.AssetId,
			Weight = v4.Weight
		})
	end

	return table.freeze(values)
end

local function offersFor(list, productName: string)
	local v4 = table.create(#list)

	for k, amount in list do
		local productName2

		if amount == 1 then
			productName2 = productName
		else
			productName2 = `{productName} x{amount}`
		end

		v4[k] = table.freeze({
			Amount = amount,
			ProductName = productName2
		})
	end

	return table.freeze(v4)
end

local chance = RunService:IsStudio() and 0.5 or 0.01
assert(intersection(chance))
assert(intersection(0.01))

local function bind(data)
	local entries = prefixed(data.BaseOdds, data.MechaPrefix)
	assert(#data.BaseOdds == 6, (`the limited egg shop expects {6} drop rows`))
	local frozen = table.freeze({
		DisplayName = data.DisplayName,
		RerollName = data.RerollName,
		InfoText = "Pets can have different <font color=\"#55FF77\"><b>sizes</b></font>, <font color=\"#55FF77\"><b>colors</b></font> and <font color=\"#55FF77\"><b>mutations</b></font>. Huge pets and pets with rare mutations earn <font color=\"#1AFF00\"><b>way more money</b></font>!",
		EndsAt = data.EndsAt,
		Offers = offersFor(v, data.ProductName),
		DropTable = toRows(data.BaseOdds),
		Entries = data.BaseOdds,
		MechaReroll = table.freeze({
			Chance = chance,
			DisplayChance = 0.01,
			DropTable = toRows(entries),
			Entries = entries
		})
	})

	local function checkOverrides(p)
		local v6, v7 = interface(p)

		if not v6 then
			error((`{data.BalanceKey} override rejected: {v7}`))
		end
	end

	local v6 = BalanceConfig.Bind(data.BalanceKey, frozen, {
		DropTable = true,
		MechaReroll = {
			Chance = true,
			DisplayChance = true,
			DropTable = true
		},
		Offers = true
	}, false, checkOverrides)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rebuildEntries()
		v6.Entries = toEntries(v6.DropTable)
		local mechaReroll = v6.MechaReroll

		if mechaReroll ~= nil then
			mechaReroll.Entries = toEntries(mechaReroll.DropTable)
		end
	end

	rebuildEntries() -- equivalent call inferred; original call site unknown
	BalanceConfig.Changed:Connect(rebuildEntries)
	return v6
end

local luminous = bind(v2)
local extinction = bind(v3)

-- equivalent calls inferred from this helper; original call sites unknown
local function onSale()
	if Workspace:GetServerTimeNow() >= Constants.UPDATE_LIVE_AT then
		return extinction
	end

	return luminous
end

return (setmetatable({
	SwitchesAt = Constants.UPDATE_LIVE_AT,
	Luminous = luminous,
	Extinction = extinction
}, {
	__index = function(_, p: string)
		local v7 = onSale() -- equivalent call inferred; original call site unknown
		return v7[p]
	end
}))