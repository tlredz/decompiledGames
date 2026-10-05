local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local handler

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	handler = require(ServerScriptService.server.player.data.handler)
else
	handler = nil
end

local module = require("../library/fish")
local module2 = require("./mutations")
local module3 = require("../Bestiary")
require("@self/Types")
require("../../utils/GeneralUtils")
require("../library/rarities")
local FishInstance = {}

function index(p, p2)
	if p2 == "Mutation" then
		local v = rawget(p, "_MutationRoll")

		for _, v2 in rawget(p, "_MutationPool") or {} do
			if v < v2[2] then
				return v2[1]
			else
				v -= v2[2]
			end
		end

		return (rawget(p, "_FrozenMutation"))
	else
		if p2 == "Name" then
			return (rawget(p, "_Name"))
		end

		if p2 == "Weight" then
			local v = rawget(p, "_BaseWeight")
			local v2 = rawget(p, "_WeightMult") or 1

			if not v then
				return nil
			end

			local v3 = rawget(p, "_MaxWeightMult")

			if v3 ~= nil then
				v2 = math.min(v2, v3)
			end

			return math.round(v * v2 * 10) / 10
		else
			if p2 == "Shiny" or p2 == "Sparkling" then
				return rawget(p, (`_{p2}Chance`)) > rawget(p, (`_{p2}Roll`))
			end

			if p2 == "CurrentWeightMultiplier" then
				return rawget(p, "_WeightMult") or 1
			end

			return rawget(p, p2) or rawget(FishInstance, p2)
		end
	end
end

function newindex(object, p, p2)
	if p == "Mutation" then
		local v = module[rawget(object, "_Name")]

		if v and v.RemoveMutations or p2 == nil then
			rawset(object, "_MutationPool", {})
		else
			object:AddMutationChance(p2, 100)
		end
	elseif p == "Name" then
		local v = rawget(object, "_Name")
		local v2 = module[p2]

		if v2 then
			rawset(object, "_Name", p2)
			rawset(object, "_BaseWeight", math.random(v2.WeightPool[1], v2.WeightPool[2]) / 10)
		else
			warn((`Attempt to set name to unknown fish "{p2}"`))
			print(debug.traceback())

			if not v then
				rawset(object, "_Name", p2)
			end
		end
	elseif p == "Weight" then
		local v = rawget(object, "_BaseWeight")

		if v then
			rawset(object, "_WeightMult", p2 / v)
			return
		end

		rawset(object, "_BaseWeight", p2)
		rawset(object, "_WeightMult", 1)
	elseif p ~= "Shiny" and p ~= "Sparkling" then
		rawset(object, p, p2)
	elseif p2 then
		rawset(object, `_{p}Chance`, 100)
	else
		rawset(object, `_{p}Chance`, 0)
	end
end

local frozen = table.freeze({
	__index = index,
	__newindex = newindex
})

function FishInstance.new(items)
	local self = setmetatable({
		IsNullified = false,
		_ShinyChance = 0,
		_SparklingChance = 0,
		_FrozenMutation = nil,
		_FrozenMutationChance = 0,
		_ClearPoolOnNextMutation = nil,
		_MutationPool = {},
		_ShinyRoll = math.random() * 100,
		_SparklingRoll = math.random() * 100,
		_MutationRoll = math.random() * 100
	}, frozen)

	if typeof(items) == "table" then
		for k, item in items do
			self[k] = item
		end
	end

	return self
end

function FishInstance.WeightBoost(p, p2: number)
	rawset(p, "_WeightMult", (rawget(p, "_WeightMult") or 1) * p2)
	return p
end

function FishInstance.SetMaxWeightBoost(p, p2: number)
	rawset(p, "_MaxWeightMult", p2)
	return p
end

function FishInstance.AddShinyChance(p, p2: number)
	local v = module[rawget(p, "_Name")]

	if v and v.RemoveShiny then
		rawset(p, "_ShinyChance", 0)
		return p
	end

	rawset(p, "_ShinyChance", (math.clamp((rawget(p, "_ShinyChance") or 0) + p2, 0, 100)))
	return p
end

function FishInstance.ClearShinyChance(p)
	rawset(p, "_ShinyChance", 0)
	return p
end

function FishInstance.AddSparklingChance(p, p2: number)
	local v = module[rawget(p, "_Name")]

	if v and v.RemoveSparkling then
		rawset(p, "_SparklingChance", 0)
		return p
	end

	rawset(p, "_SparklingChance", (math.clamp((rawget(p, "_SparklingChance") or 0) + p2, 0, 100)))
	return p
end

function FishInstance.ClearSparklingChance(p)
	rawset(p, "_SparklingChance", 0)
	return p
end

function FishInstance:AddMutationChance(p2: string, p3: number)
	if p2 == nil or p2 == "None" then
		return self
	end

	local mutation = module2.Mutations[p2]

	if mutation then
		local v = module[rawget(self, "_Name")]

		if v and v.RemoveMutations then
			rawset(self, "_MutationPool", {})
			return self
		end

		local v2 = rawget(self, "_FrozenMutation") and module2.Mutations[rawget(self, "_FrozenMutation")]

		if v2 then
			local priority = v2.Priority or 0
			local priority2 = mutation.Priority or 0

			if priority2 < priority or priority == priority2 and v2.PriceMultiply > mutation.PriceMultiply then
				return self
			end
		end

		local v3 = rawget(self, "_Meta")

		if v3 and v3.BiteStats and v3.BiteStats.MutationChanceBoost then
			p3 *= (v3.BiteStats.MutationChanceBoost + 100) / 100
		end

		local v4 = rawget(self, "_MutationPool")

		if not v4 or rawget(self, "_ClearPoolOnNextMutation") then
			v4 = {}
			rawset(self, "_MutationPool", v4)
			rawset(self, "_ClearPoolOnNextMutation", nil)
			rawset(self, "_MutationRoll", math.random() * 100)
		end

		local priceMultiply = mutation.PriceMultiply
		local priority = mutation.Priority or 0
		local v5 = {
			p2,
			p3,
			priority,
			priceMultiply,
			p3
		}
		local v6 = 0
		local v7 = 0
		local lists = {}
		local total = 0
		local v8 = 100

		local function flushClash()
			if v8 > 0 then
				if v8 < total then
					for _, v9 in lists do
						local v10 = v9[5] / total
						v9[2] = v8 * v10
					end

					v8 = 0
				else
					for _, v9 in lists do
						v9[2] = v9[5]
						v8 -= v9[2]
					end
				end
			else
				for _, v9 in lists do
					v9[2] = 0
				end
			end

			table.clear(lists)
			total = 0
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleEntry(list)
			if list[3] ~= v6 or list[4] ~= v7 then
				flushClash()
			end

			table.insert(lists, list)
			total += list[5]
			v6 = list[3]
			v7 = list[4]
		end

		local v9 = false

		for k, v10 in table.clone(v4), nil, nil do
			if v10[1] == p2 then
				v10[5] += p3
				v9 = true
			elseif not v9 and (v10[3] < priority or v10[3] == priority and v10[4] < priceMultiply) then
				table.insert(v4, k, v5)
				v9 = true
				handleEntry(v5) -- equivalent call inferred; original call site unknown
			end

			handleEntry(v10) -- equivalent call inferred; original call site unknown
		end

		if not v9 and v8 > 0 then
			table.insert(v4, v5)
			handleEntry(v5) -- equivalent call inferred; original call site unknown
		end

		if #lists > 0 then
			flushClash()
		end

		return self
	else
		warn((`Attempt to apply unknown mutation "{p2}" to fish`))
		print(debug.traceback())
		return self
	end
end

function FishInstance:_FreezeCurrentMutation()
	local mutation = self.Mutation

	if mutation then
		local v = 0

		if rawget(self, "_FrozenMutation") == mutation then
			v = rawget(self, "_FrozenMutationChance")
		else
			rawset(self, "_FrozenMutation", mutation)
		end

		if not rawget(self, "_ClearPoolOnNextMutation") then
			for _, v3 in rawget(self, "_MutationPool") or {} do
				if v3[1] ~= mutation then
					continue
				end

				v += v3[2]
				break
			end
		end

		rawset(self, "_FrozenMutationChance", (math.clamp(v, 0, 100)))
	end

	rawset(self, "_ClearPoolOnNextMutation", true)
	return mutation
end

function FishInstance:AddMutationPool(items)
	for k, item in items do
		self:AddMutationChance(k, item)
	end

	return self
end

function FishInstance.RemoveMutationFromPool(p, p2: string)
	local v = rawget(p, "_MutationPool")

	if not v then
		return p
	end

	for _, v2 in table.clone(v) do
		if v2[1] == p2 then
			table.remove(v, table.find(v, v2))
		end
	end

	if rawget(p, "_FrozenMutation") == p2 then
		rawset(p, "_FrozenMutation", nil)
		rawset(p, "_FrozenMutationChance", nil)
	end

	return p
end

function FishInstance.ClearAllMutations(p)
	rawset(p, "_MutationPool", {})
	rawset(p, "_FrozenMutation", nil)
	rawset(p, "_FrozenMutationChance", nil)
	rawset(p, "_ClearPoolOnNextMutation", nil)
	return p
end

function FishInstance.SetMeta(p, p2)
	rawset(p, "_Meta", p2)
	return p
end

function FishInstance.Clone(p)
	local clone = table.clone(p)
	clone:_FreezeCurrentMutation()
	return clone
end

function FishInstance:CloneRaw()
	local object = setmetatable(table.clone(self), nil)
	object.Mutation = self.Mutation
	object.Shiny = self.Shiny or nil
	object.Sparkling = self.Sparkling or nil
	object.Name = self.Name
	object.Weight = math.round(self.Weight * 10) / 10
	object._Mutation = nil
	object._BaseWeight = nil
	object.IsNullified = nil
	object._WeightMult = nil
	object._MaxWeightMult = nil
	object._Name = nil
	object._Meta = nil
	object._ShinyChance = nil
	object._SparklingChance = nil
	object._MutationPool = nil
	object._ShinyRoll = nil
	object._SparklingRoll = nil
	object._MutationRoll = nil
	object._AutoFavorited = nil
	object._FrozenMutation = nil
	object._FrozenMutationChance = nil
	object._ClearPoolOnNextMutation = nil
	object._GivenItems = nil
	return object
end

function FishInstance:Nullify()
	self.IsNullified = true
	return self
end

function FishInstance:RawSub()
	local raw = self:CloneRaw()
	raw.Name = nil
	return raw
end

function FishInstance.AutoFavorite(p)
	rawset(p, "_AutoFavorited", true)
	local v = rawget(p, "_GivenItems")

	if typeof(v) == "table" then
		for _, v2 in v do
			v2.sub.Favourited = true
		end

		if p.CaughtBy then
			local playerByUserId = game.Players:GetPlayerByUserId(p.CaughtBy)

			if playerByUserId and handler then
				handler:Replicate(playerByUserId)
			end
		end
	end

	rawset(p, "_GivenItems", nil)
	return p
end

function FishInstance:GetTotalChance()
	local v = rawget(self, "_Meta")

	if v and typeof(v.Chance) == "number" and v.Chance > 0 and v.Chance < 100 and math.isfinite(v.Chance) then
		return v.Chance
	end

	local v2

	if not (v and v.SourceType ~= "duplicate" and v.FishPool) then
		return v2
	end

	local total = 0

	for _, v3 in v.FishPool do
		total += v3
	end

	v2 = (v.FishPool[self.Name] or 0) / total * 100

	if self.Shiny then
		v2 *= (rawget(self, "_ShinyChance") or 0) / 100
	end

	if self.Sparkling then
		v2 *= (rawget(self, "_SparklingChance") or 0) / 100
	end

	local mutation = self.Mutation

	if mutation then
		local total2 = 0

		if rawget(self, "_FrozenMutation") == mutation then
			total2 += rawget(self, "_FrozenMutationChance") / 100
		end

		if not rawget(self, "_ClearPoolOnNextMutation") then
			for _, v4 in rawget(self, "_MutationPool") or {} do
				if v4[1] ~= self.Mutation then
					continue
				end

				total2 += v4[2] / 100
				break
			end
		end

		if total2 > 0 then
			v2 *= math.clamp(total2, 0, 1)
		end
	end

	if not v2 or v2 <= 0 or v2 > 100 or not math.isfinite(v2) then
		return nil
	end

	return v2
end

function FishInstance:CatchNotify(player, flag: boolean?, creditTo: string?, flag2: boolean?)
	if rawget(self, "IsNullified") then
		return
	end

	if handler and handler:CheckFull(player) then
		self:Nullify()
		return
	end

	local raw = self:CloneRaw()

	if flag then
		raw.NotCaught = true
	end

	local v = rawget(self, "_Meta")

	if v then
		if v.SourceType == "duplicate" then
			raw.Duplicate = true
		elseif v.SourceType == "entity" then
			raw.Extra = true
		end
	end

	if creditTo then
		raw.CreditTo = creditTo
	end

	if flag2 then
		raw.Fast = true
	end

	local totalChance = self:GetTotalChance()

	if RunService:IsClient() then
		ReplicatedStorage.events.debug_catch:Fire(raw, totalChance)
	else
		ReplicatedStorage.events.anno_catch:FireClient(player, raw, totalChance)
	end
end

function FishInstance:GiveItem(p, value: number?)
	if not RunService:IsServer() or rawget(self, "IsNullified") or not handler then
		return
	end

	local rawSub = self:RawSub()

	if rawget(self, "_AutoFavorited") then
		rawSub.Favourited = true
	end

	if handler:CheckFull(p) and not rawSub.Favourited then
		self:Nullify()
		return
	end

	local v, v2, v3, v4, v5 = handler:GiveItem(p, self.Name, rawSub, value or 1)
	rawset(self, "_GivenItems", v5)
	task.delay(1, rawset, self, "_GivenItems", nil)
	return v, v2, v3, v4, v5
end

function FishInstance.BestiaryDiscover(p, p2, p3)
	if not RunService:IsServer() or rawget(p, "IsNullified") then
		return false
	end

	local v = rawget(p, "_Meta")

	if v and v.ZoneName == "Shimmer" then
		return false
	end

	return module3:DiscoverFish(p2, p, p3)
end

return FishInstance