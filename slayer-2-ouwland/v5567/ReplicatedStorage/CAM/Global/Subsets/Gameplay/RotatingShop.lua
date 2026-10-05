local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local TimedEvents = require(script.Parent.TimedEvents)
local RotatingShop = {
	GRACE = 30
}
local v = {}

function RotatingShop.GetEvery(p)
	local timedEvent = TimedEvents[p.TimedEvent]
	assert(timedEvent ~= nil, (`RotatingShop: no TimedEvents entry named "{p.TimedEvent}" (shop {p.Name})`))
	return timedEvent.Every
end

function RotatingShop.GetCycleIndex(p)
	if p.CycleAttribute == nil then
		return (math.floor(workspace:GetServerTimeNow() / RotatingShop.GetEvery(p)))
	end

	return tonumber(workspace:GetAttribute(p.CycleAttribute)) or 0
end

function RotatingShop.GetPool(p)
	local poolWhen = p.PoolWhen

	if poolWhen == nil or workspace:GetAttribute(poolWhen.Attribute) ~= true then
		return p.Pool
	end

	return poolWhen.Pool
end

function RotatingShop.GetRotation(data, p: number)
	local pool = RotatingShop.GetPool(data)
	local random = Random.new(p * 8191 + data.Seed)
	local v2

	if typeof(data.SlotCount) == "table" then
		v2 = random:NextInteger(data.SlotCount.Min, data.SlotCount.Max)
	else
		v2 = data.SlotCount
	end

	local v3 = math.min(v2, #pool)
	local result = {}

	if data.Always ~= nil then
		for _, alway in data.Always do
			table.insert(result, typeof(alway) == "string" and {
				Name = alway
			} or alway)
		end
	end

	local v4 = table.create(#pool)

	for i = 1, #pool do
		v4[i] = i
	end

	for i = 1, v3 do
		local integer = random:NextInteger(i, #v4)
		local v5 = v4[integer]
		local v6 = v4[i]
		v4[i] = v5
		v4[integer] = v6
		local name = pool[v4[i]]
		table.insert(result, typeof(name) == "string" and {
			Name = name
		} or name)
	end

	return result
end

function RotatingShop.RegisterStock(p: string, list, requiresQuestDone: string?)
	local names = {}

	for _, v2 in ipairs(list) do
		if Shop.itemsforsale[v2.Name] == nil or v[v2.Name] then
			local v3 = {
				Type = Menum.ShopItemType.IngameItem,
				Price = v2.Price,
				NoSave = v2.NoSave,
				RequiresQuestDone = requiresQuestDone
			}

			if Shop.RegisterItem(v2.Name, v3) then
				v[v2.Name] = v3
				table.insert(names, v2.Name)
			end
		else
			warn((`RotatingShop: "{v2.Name}" already has a permanent listing, {p} sells it through that entry`))
		end
	end

	return names
end

function RotatingShop.UnregisterStock(list, p)
	for _, v2 in ipairs(list) do
		if not ((p == nil or not p[v2]) and v[v2] ~= nil) then
			continue
		end

		if Shop.itemsforsale[v2] == v[v2] then
			Shop.itemsforsale[v2] = nil
		end

		v[v2] = nil
	end
end

local v2 = {}
local flag = false

local function UpdateCountdown(state, p, callback)
	local disappearDistance = state.Data.DisappearDistance
	local v3

	if p == nil then
		v3 = false
	else
		v3 = disappearDistance == nil or (p.Position - state.At).Magnitude <= disappearDistance + (state.Cleanup == nil and 0 or 8)
	end

	if v3 and state.Cleanup == nil then
		local part = Instance.new("Part")
		part.Name = state.Name .. "RestockCountdown"
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CFrame = CFrame.new(state.At)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "RestockCountdown"
		billboardGui.Size = UDim2.fromScale(14, 6)
		billboardGui.MaxDistance = disappearDistance == nil and 150 or disappearDistance + 30 or 150
		billboardGui.LightInfluence = 0
		billboardGui.Parent = part
		part.Parent = workspace.Debree
		state.Anchor = part
		state.Cleanup = callback(billboardGui, state.Data)
	elseif not v3 and state.Cleanup ~= nil then
		state.Cleanup()
		state.Cleanup = nil
		local anchor = state.Anchor
		state.Anchor = nil

		if anchor ~= nil then
			task.delay(1, anchor.Destroy, anchor)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartCountdownWatcher()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local UITimedEvent = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.UITimedEvent)

		while true do
			local character = Players.LocalPlayer.Character
			local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart") or nil

			for _, v3 in ipairs(v2) do
				local success, result = pcall(UpdateCountdown, v3, humanoidRootPart, UITimedEvent)

				if not success then
					warn((`RotatingShop: countdown update failed for {v3.Name}: {result}`))
				end
			end

			task.wait(1)
		end
	end)
end

function RotatingShop.BindClient(data)
	if not RunService:IsClient() then
		return
	end

	if data.CountdownAt ~= nil then
		local timedEvent = TimedEvents[data.TimedEvent]

		if timedEvent == nil then
			warn((`RotatingShop: no TimedEvents entry named "{data.TimedEvent}" (shop {data.Name}), countdown skipped`))
		else
			table.insert(v2, {
				Name = data.Name,
				At = data.CountdownAt,
				Data = timedEvent
			})
			StartCountdownWatcher() -- equivalent call inferred; original call site unknown
		end
	end

	local cycleIndex = RotatingShop.GetCycleIndex(data)
	local pool = RotatingShop.GetPool(data)
	local stock = RotatingShop.RegisterStock(
		data.Name,
		RotatingShop.GetRotation(data, cycleIndex),
		data.RequiresQuestDone
	)
	task.spawn(function()
		while true do
			task.wait(5)
			local cycleIndex2 = RotatingShop.GetCycleIndex(data)
			local pool2 = RotatingShop.GetPool(data)

			if not (cycleIndex2 ~= cycleIndex or pool2 ~= pool) then
				continue
			end

			cycleIndex = cycleIndex2
			pool = pool2
			local v3 = stock
			stock = RotatingShop.RegisterStock(
				data.Name,
				RotatingShop.GetRotation(data, cycleIndex2),
				data.RequiresQuestDone
			)
			task.delay(RotatingShop.GRACE, function()
				local v5 = {}

				for i, v6 in ipairs(stock) do
					v5[v6] = true
				end

				RotatingShop.UnregisterStock(v3, v5)
			end)
		end
	end)
end

return RotatingShop