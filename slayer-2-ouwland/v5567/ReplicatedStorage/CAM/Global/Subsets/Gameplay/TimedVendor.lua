local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local RotatingShop = require(script.Parent.RotatingShop)
local TimedEvents = require(script.Parent.TimedEvents)
local TimedVendor = {}
local v = {}
TimedVendor.SYNC_TICK = 5

function TimedVendor.GetStockNames(p: string)
	return v[p] or {}
end

function TimedVendor.GetEvery(p)
	local timedEvent = TimedEvents[p.TimedEvent]
	assert(timedEvent ~= nil, (`TimedVendor: no TimedEvents entry named "{p.TimedEvent}" (vendor {p.Name})`))
	return timedEvent.Every
end

function TimedVendor.GetSpotIndex(p, p2: number, p3: number)
	if p3 <= 1 then
		return 1
	end

	local v2 = math.floor(p2 / p3)
	local v3 = table.create(p3)

	for i = 1, p3 do
		v3[i] = i
	end

	local random = Random.new(v2 * 6151 + p.Seed)

	for i = 1, p3 - 1 do
		local integer = random:NextInteger(i, p3)
		local v4 = v3[integer]
		local v5 = v3[i]
		v3[i] = v4
		v3[integer] = v5
	end

	return v3[p2 - v2 * p3 + 1]
end

function TimedVendor.GetState(p)
	local activeFor = TimedVendor.GetEvery(p)
	local serverTimeNow = workspace:GetServerTimeNow()
	local cycle = math.floor(serverTimeNow / activeFor)
	local v3 = serverTimeNow - cycle * activeFor
	local active = v3 < p.ActiveFor

	if active then
		activeFor = p.ActiveFor or activeFor
	end

	return {
		Cycle = cycle,
		Active = active,
		NextEdgeIn = activeFor - v3
	}
end

function TimedVendor.GetStock(data, p: number)
	local random = Random.new(p * 8191 + data.Seed)
	local slotCount

	if typeof(data.SlotCount) == "table" then
		slotCount = random:NextInteger(data.SlotCount.Min, data.SlotCount.Max)
	else
		slotCount = data.SlotCount
	end

	local result = {}

	for _, name in data.Always or {} do
		table.insert(result, typeof(name) == "string" and {
			Name = name
		} or name)
	end

	local v2 = {}

	for _, name in data.Stock do
		local v4 = typeof(name) == "string" and {
			Name = name
		} or name
		local item = Items[v4.Name]

		if item == nil then
			warn((`TimedVendor: "{v4.Name}" is not in the item catalogue, {data.Name} can't stock it`))
		else
			local v5 = v2[item.Rarity]

			if v5 == nil then
				v5 = {}
				v2[item.Rarity] = v5
			end

			table.insert(v5, v4)
		end
	end

	local v3 = {}
	local v4 = 0

	for k, v5 in Rarities.Order do
		local odd = data.Odds[v5]

		if v2[k] == nil then
			continue
		end

		if odd == nil or odd <= 0 then
			warn((`TimedVendor: {data.Name} stocks {v5} items but Odds gives that rarity no weight`))
		else
			table.insert(v3, {
				Rarity = k,
				Weight = odd
			})
			v4 += odd
		end
	end

	if v4 <= 0 then
		warn((`TimedVendor: {data.Name} has no stocked rarity with a positive weight in Odds`))
		return result
	end

	for _ = 1, slotCount do
		if #v3 == 0 then
			break
		end

		local v5 = random:NextNumber() * v4
		local count = #v3

		for k, v7 in v3 do
			v5 -= v7.Weight

			if not (v5 <= 0) then
				continue
			end

			count = k
			break
		end

		local v7 = v2[v3[count].Rarity]
		table.insert(result, table.remove(v7, random:NextInteger(1, #v7)))

		if #v7 ~= 0 then
			continue
		end

		v4 -= v3[count].Weight
		table.remove(v3, count)
	end

	return result
end

function TimedVendor.ApplyStock(p, p2: number)
	local v2 = v[p.Name] or {}
	v[p.Name] = RotatingShop.RegisterStock(p.Name, TimedVendor.GetStock(p, p2), p.RequiresQuestDone)
	task.delay(RotatingShop.GRACE, function()
		local v3 = {}

		for _, v4 in v[p.Name] or {} do
			v3[v4] = true
		end

		RotatingShop.UnregisterStock(v2, v3)
	end)
end

function TimedVendor.ClearStock(p)
	local v2 = v[p.Name]

	if v2 == nil then
		return
	end

	v[p.Name] = nil
	task.delay(RotatingShop.GRACE, function()
		local v3 = {}

		for _, v4 in v[p.Name] or {} do
			v3[v4] = true
		end

		RotatingShop.UnregisterStock(v2, v3)
	end)
end

function TimedVendor.BindClient(p)
	if not RunService:IsClient() then
		return
	end

	local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
	task.spawn(function()
		local cycle = nil

		while true do
			local state = TimedVendor.GetState(p)

			if state.Active then
				if state.Cycle ~= cycle then
					cycle = state.Cycle
					TimedVendor.ApplyStock(p, state.Cycle)
				end
			elseif cycle ~= nil then
				cycle = nil
				TimedVendor.ClearStock(p)

				if Dialogue.CurrentDialogue.Current == p.Name then
					Dialogue.CurrentDialogue.Current = nil
					Dialogue.CurrentDialogue.Cancel:Fire()
				end
			end

			task.wait(TimedVendor.SYNC_TICK)
		end
	end)
end

return TimedVendor