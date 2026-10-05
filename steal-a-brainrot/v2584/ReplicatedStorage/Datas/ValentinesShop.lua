local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local BaseSkins = require(ReplicatedStorage.Shared.BaseSkins)

local function hasEmptyBaseSpace(p)
	return function(p2)
		if not Synchronizer:Get(p2) then
			return false
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local PlotService = require(ServerScriptService.Services.PlotService)
		local GameService = require(ServerScriptService.Services.GameService)

		if PlotService:GetEmptyAnimalsPodiumAmount(p2) - GameService:GetTargetAtPlayerAmount(p2) < p then
			return false, "Your base is full"
		end

		return true
	end
end

local function giveBase(p)
	return function(p2)
		local v = Synchronizer:Get(p2)

		if not v then
			return false
		end

		if BaseSkins.Owns(v, p) then
			return "___GIVE_BACK"
		end

		if BaseSkins.IsInventoryManaged(p) then
			BaseSkins.Grant(v, p, "ValentinesShop")
		else
			v:InsertOnDictionary("UnlockedBaseSkins", p, true)
		end

		return true
	end
end

local function giveGamepass(p: string, p2: string?)
	return function(instance)
		local v = Synchronizer:Get(instance)

		if not v then
			return false
		end

		if v:Get({ "Gamepass", p }) then
			return "___GIVE_BACK"
		end

		v:InsertOnDictionary("Gamepass", p, true)
		instance:SetAttribute(p2 or p, true)
		return true
	end
end

local function giveItem(p)
	return function(p2)
		local v = Synchronizer:Get(p2)

		if not v then
			return false
		end

		if v:Get({ "Items", p }) then
			return "___GIVE_BACK"
		end

		v:InsertOnDictionary("Items", p, true)
		return true
	end
end

local function giveBrainrot(p, p2: number)
	return function(p3, mutation: string?)
		local ServerScriptService = game:GetService("ServerScriptService")
		local PlotService = require(ServerScriptService.Services.PlotService)
		local clone = p

		if mutation then
			clone = table.clone(p)
			clone.Mutation = mutation
		end

		if p2 == 1 then
			return (PlotService:AddAnimalOnPlotOrQueue(p3, table.clone(clone)))
		end

		for _ = 1, p2 do
			PlotService:AddAnimalOnPlotOrQueue(p3, table.clone(clone))
		end

		return true
	end
end

local v3 = 1
local v2 = {
	discountedProductId = 3536490026,
	isLuckyBlock = true,
	canGive = function(p)
		if not Synchronizer:Get(p) then
			return false
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local PlotService = require(ServerScriptService.Services.PlotService)
		local GameService = require(ServerScriptService.Services.GameService)

		if PlotService:GetEmptyAnimalsPodiumAmount(p) - GameService:GetTargetAtPlayerAmount(p) < v3 then
			return false, "Your base is full"
		end

		return true
	end,
	give = 0
}
local v4 = {
	Index = "Premium Heart Lucky Block",
	Timer = 0
}
local v5 = 1

function v2.give(p, mutation: string?)
	local ServerScriptService = game:GetService("ServerScriptService")
	local PlotService = require(ServerScriptService.Services.PlotService)
	local clone = v4

	if mutation then
		clone = table.clone(v4)
		clone.Mutation = mutation
	end

	if v5 == 1 then
		return (PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone)))
	end

	for _ = 1, v5 do
		PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone))
	end

	return true
end

local v7 = 3
local v6 = {
	discountedProductId = 3536490030,
	isLuckyBlock = true,
	canGive = function(p)
		if not Synchronizer:Get(p) then
			return false
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local PlotService = require(ServerScriptService.Services.PlotService)
		local GameService = require(ServerScriptService.Services.GameService)

		if PlotService:GetEmptyAnimalsPodiumAmount(p) - GameService:GetTargetAtPlayerAmount(p) < v7 then
			return false, "Your base is full"
		end

		return true
	end,
	give = 0
}
local v8 = {
	Index = "Premium Heart Lucky Block",
	Timer = 0
}
local v9 = 3

function v6.give(p, mutation: string?)
	local ServerScriptService = game:GetService("ServerScriptService")
	local PlotService = require(ServerScriptService.Services.PlotService)
	local clone = v8

	if mutation then
		clone = table.clone(v8)
		clone.Mutation = mutation
	end

	if v9 == 1 then
		return (PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone)))
	end

	for _ = 1, v9 do
		PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone))
	end

	return true
end

local v11 = 10
local v10 = {
	discountedProductId = 3536490034,
	isLuckyBlock = true,
	canGive = function(p)
		if not Synchronizer:Get(p) then
			return false
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local PlotService = require(ServerScriptService.Services.PlotService)
		local GameService = require(ServerScriptService.Services.GameService)

		if PlotService:GetEmptyAnimalsPodiumAmount(p) - GameService:GetTargetAtPlayerAmount(p) < v11 then
			return false, "Your base is full"
		end

		return true
	end,
	give = 0
}
local v12 = {
	Index = "Premium Heart Lucky Block",
	Timer = 0
}
local v13 = 10

function v10.give(p, mutation: string?)
	local ServerScriptService = game:GetService("ServerScriptService")
	local PlotService = require(ServerScriptService.Services.PlotService)
	local clone = v12

	if mutation then
		clone = table.clone(v12)
		clone.Mutation = mutation
	end

	if v13 == 1 then
		return (PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone)))
	end

	for _ = 1, v13 do
		PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone))
	end

	return true
end

local v15 = 1
local v14 = {
	discountedProductId = 3536490033,
	isLuckyBlock = true,
	canGive = function(p)
		if not Synchronizer:Get(p) then
			return false
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local PlotService = require(ServerScriptService.Services.PlotService)
		local GameService = require(ServerScriptService.Services.GameService)

		if PlotService:GetEmptyAnimalsPodiumAmount(p) - GameService:GetTargetAtPlayerAmount(p) < v15 then
			return false, "Your base is full"
		end

		return true
	end,
	give = 0
}
local v16 = {
	Index = "Secret Lucky Block",
	Timer = 0
}
local v17 = 1

function v14.give(p, mutation: string?)
	local ServerScriptService = game:GetService("ServerScriptService")
	local PlotService = require(ServerScriptService.Services.PlotService)
	local clone = v16

	if mutation then
		clone = table.clone(v16)
		clone.Mutation = mutation
	end

	if v17 == 1 then
		return (PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone)))
	end

	for _ = 1, v17 do
		PlotService:AddAnimalOnPlotOrQueue(p, table.clone(clone))
	end

	return true
end

local v19 = "Rose"
local v = {
	[3531057541] = v2,
	[3531057803] = v6,
	[3531057804] = v10,
	[3329528437] = v14,
	[3531055923] = {
		discountedProductId = 3536490051,
		item = "Rose Base",
		failedGiftKey = "RoseBase",
		give = function(p)
			local v20 = Synchronizer:Get(p)

			if not v20 then
				return false
			end

			if BaseSkins.Owns(v20, v19) then
				return "___GIVE_BACK"
			end

			if BaseSkins.IsInventoryManaged(v19) then
				BaseSkins.Grant(v20, v19, "ValentinesShop")
			else
				v20:InsertOnDictionary("UnlockedBaseSkins", v19, true)
			end

			return true
		end
	},
	[3531055926] = {
		discountedProductId = 3536490035,
		item = "Rose Base",
		failedGiftKey = "RoseBase",
		give = function(p)
			local v20 = "Rose"
			(function(p2)
				local v21 = Synchronizer:Get(p2)

				if not v21 then
					return false
				end

				if BaseSkins.Owns(v21, v20) then
					return "___GIVE_BACK"
				end

				if BaseSkins.IsInventoryManaged(v20) then
					BaseSkins.Grant(v21, v20, "ValentinesShop")
				else
					v21:InsertOnDictionary("UnlockedBaseSkins", v20, true)
				end

				return true
			end)(p)
			local v21 = {
				Index = "Premium Heart Lucky Block",
				Timer = 0
			}
			local v22 = 1
			(function(p2, mutation: string?)
				local ServerScriptService = game:GetService("ServerScriptService")
				local PlotService = require(ServerScriptService.Services.PlotService)
				local clone = v21

				if mutation then
					clone = table.clone(v21)
					clone.Mutation = mutation
				end

				if v22 == 1 then
					return (PlotService:AddAnimalOnPlotOrQueue(p2, table.clone(clone)))
				end

				for _ = 1, v22 do
					PlotService:AddAnimalOnPlotOrQueue(p2, table.clone(clone))
				end

				return true
			end)(p)
			return true
		end
	}
}
local v21 = "Cupid's Wings"
v[3536298171] = {
	discountedProductId = 3536490029,
	item = "Cupid's Wings",
	failedGiftKey = "CupidsWings",
	give = function(p)
		local v22 = Synchronizer:Get(p)

		if not v22 then
			return false
		end

		if v22:Get({ "Items", v21 }) then
			return "___GIVE_BACK"
		end

		v22:InsertOnDictionary("Items", v21, true)
		return true
	end
}
v[3536298173] = {
	discountedProductId = 3536490050,
	item = "Cupid's Wings",
	failedGiftKey = "CupidsWings",
	give = function(p)
		local v22 = "Cupid's Wings"
		(function(p2)
			local v23 = Synchronizer:Get(p2)

			if not v23 then
				return false
			end

			if v23:Get({ "Items", v22 }) then
				return "___GIVE_BACK"
			end

			v23:InsertOnDictionary("Items", v22, true)
			return true
		end)(p)
		local v23 = {
			Index = "Premium Heart Lucky Block",
			Timer = 0
		}
		local v24 = 2
		(function(p2, mutation: string?)
			local ServerScriptService = game:GetService("ServerScriptService")
			local PlotService = require(ServerScriptService.Services.PlotService)
			local clone = v23

			if mutation then
				clone = table.clone(v23)
				clone.Mutation = mutation
			end

			if v24 == 1 then
				return (PlotService:AddAnimalOnPlotOrQueue(p2, table.clone(clone)))
			end

			for _ = 1, v24 do
				PlotService:AddAnimalOnPlotOrQueue(p2, table.clone(clone))
			end

			return true
		end)(p)
		return true
	end
}
local v23 = "Flying Carpet"
v[3290152513] = {
	discountedProductId = 3536490028,
	item = "Flying Carpet",
	give = function(p)
		local v24 = Synchronizer:Get(p)

		if not v24 then
			return false
		end

		if v24:Get({ "Items", v23 }) then
			return "___GIVE_BACK"
		end

		v24:InsertOnDictionary("Items", v23, true)
		return true
	end
}
local v25 = "Laser Gun"
v[3290152552] = {
	discountedProductId = 3536490048,
	item = "Laser Gun",
	give = function(p)
		local v26 = Synchronizer:Get(p)

		if not v26 then
			return false
		end

		if v26:Get({ "Items", v25 }) then
			return "___GIVE_BACK"
		end

		v26:InsertOnDictionary("Items", v25, true)
		return true
	end
}
local v27 = "Ban Hammer"
v[3290152611] = {
	discountedProductId = 3536490052,
	item = "Ban Hammer",
	give = function(p)
		local v28 = Synchronizer:Get(p)

		if not v28 then
			return false
		end

		if v28:Get({ "Items", v27 }) then
			return "___GIVE_BACK"
		end

		v28:InsertOnDictionary("Items", v27, true)
		return true
	end
}
local v29 = "Blackhole Slap"
v[3290152459] = {
	discountedProductId = 3536490032,
	item = "Blackhole Slap",
	give = function(p)
		local v30 = Synchronizer:Get(p)

		if not v30 then
			return false
		end

		if v30:Get({ "Items", v29 }) then
			return "___GIVE_BACK"
		end

		v30:InsertOnDictionary("Items", v29, true)
		return true
	end
}
local v31 = "Admin Commands"
local v32 = "AdminCommands"
v[3296367604] = {
	discountedProductId = 3536944215,
	item = "Admin Commands",
	failedGiftKey = "AdminCommands",
	give = function(instance)
		local v33 = Synchronizer:Get(instance)

		if not v33 then
			return false
		end

		if v33:Get({ "Gamepass", v31 }) then
			return "___GIVE_BACK"
		end

		v33:InsertOnDictionary("Gamepass", v31, true)
		instance:SetAttribute(v32 or v31, true)
		return true
	end
}
local v34 = "2x Money"
local v35 = "2xMoney"
v[3296367825] = {
	discountedProductId = 3536944220,
	item = "2x Money",
	failedGiftKey = "2xMoney",
	give = function(instance)
		local v36 = Synchronizer:Get(instance)

		if not v36 then
			return false
		end

		if v36:Get({ "Gamepass", v34 }) then
			return "___GIVE_BACK"
		end

		v36:InsertOnDictionary("Gamepass", v34, true)
		instance:SetAttribute(v35 or v34, true)
		return true
	end
}
local v37 = "VIP"
local v38 = nil
v[3296367737] = {
	discountedProductId = 3536944219,
	item = "VIP",
	failedGiftKey = "VIP",
	give = function(instance)
		local v39 = Synchronizer:Get(instance)

		if not v39 then
			return false
		end

		if v39:Get({ "Gamepass", v37 }) then
			return "___GIVE_BACK"
		end

		v39:InsertOnDictionary("Gamepass", v37, true)
		instance:SetAttribute(v38 or v37, true)
		return true
	end
}
local frozen = table.freeze(v)
return table.freeze({
	Products = frozen
})