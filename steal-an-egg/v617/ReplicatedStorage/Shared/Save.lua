local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local OnboardingTiming = require(ReplicatedStorage.Shared.Util.OnboardingTiming)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Save = {
	Loaded = Signal.new(),
	Changed = Signal.new(),
	PeerLoaded = Signal.new(),
	PeerChanged = Signal.new()
}
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}

local function presentPlayer(p)
	local selected = p or localPlayer

	if selected == nil or selected.Parent == nil then
		return nil
	end

	return selected
end

local function signalFor(p: string)
	local v4 = v3[p]

	if v4 == nil then
		v4 = Signal.new()
		v3[p] = v4
	end

	return v4
end

local seal

seal = function(list, p)
	if type(list) ~= "table" or p[list] then
		return
	end

	p[list] = true

	for k, v4 in list do
		seal(k, p)
		seal(v4, p)
	end

	if not table.isfrozen(list) then
		table.freeze(list)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function store(p, k: string, item)
	if k ~= "Inventory" then
		seal(item, {})
	end

	p[k] = item
end

local function isInventoryPatch(p: string, p2)
	return p == "Inventory" and type(p2) == "table" and p2.__patch == true
end

local function foldInventory(p, item)
	local inventory = p.Inventory or {}

	if type(item.Remove) == "table" then
		for k in item.Remove do
			inventory[k] = nil
		end
	end

	if type(item.Set) == "table" then
		for k, v4 in item.Set do
			inventory[k] = v4
		end
	end

	return inventory
end

local function publish(p, items)
	if p == localPlayer then
		for _, item in items do
			Save.Changed:Fire(item.field, item.value, item.previous)
			local v4 = v3[item.field]

			if v4 ~= nil then
				v4:Fire(item.value, item.previous)
			end
		end
	else
		for _, item in items do
			Save.PeerChanged:Fire(p, item.field)
		end
	end
end

local function applyDelta(localPlayer2, items, items2)
	local v4 = v[localPlayer2]

	if v4 == nil then
		return
	end

	local v5 = {}
	local v6 = {}

	if items2 ~= nil then
		for k in items2 do
			table.insert(v6, {
				field = k,
				value = nil,
				previous = v4[k]
			})
			v4[k] = nil
		end
	end

	for k, item in items do
		local v7

		if k == "Inventory" and type(item) == "table" then
			v7 = item.__patch == true
		else
			v7 = false
		end

		if v7 then
			item = foldInventory(v4, item)
		end

		table.insert(v5, {
			field = k,
			value = item,
			previous = v4[k]
		})
		store(v4, k, item) -- equivalent call inferred; original call site unknown
	end

	table.move(v6, 1, #v6, #v5 + 1, v5)
	publish(localPlayer2, v5)
end

local function requestProfile(p)
	if p == localPlayer then
		OnboardingTiming.Mark("OwnerProfileRequestSent")
	end

	local success, result = pcall(function()
		return Remotes.ProfileMirror.FetchProfile:InvokeServer(p)
	end)

	if not success then
		warn((`profile fetch for {p.Name} raised: {tostring(result)}`))
		return nil
	end

	if type(result) == "table" then
		return result
	end

	return nil
end

local function adopt(p, items)
	for k, item in items do
		if k ~= "Inventory" then
			seal(item, {})
		end
	end

	v[p] = items

	if p ~= localPlayer then
		Save.PeerLoaded:Fire(p)
		return
	end

	OnboardingTiming.Mark("OwnerProfileReceived")
	Save.Loaded:Fire(p)
end

local fetch

fetch = function(p, flag: boolean)
	local v4 = v[p]

	if v4 ~= nil then
		return v4
	end

	local v5 = v2[p]

	if v5 == nil then
		local v6 = Signal.new()
		v2[p] = v6
		local v7 = 0.6

		while p.Parent ~= nil and v[p] == nil do
			local v8 = requestProfile(p)

			if p.Parent == nil then
				break
			end

			if v8 == nil then
				if not flag then
					break
				end

				task.wait(v7)
				v7 = math.min(v7 * 1.5, 3)
			else
				if v[p] ~= nil then
					break
				end

				adopt(p, v8)
				break
			end
		end

		v2[p] = nil
		local v8 = v[p]
		v6:Fire(v8)
		v6:Destroy()
		return v8
	else
		local v6 = v5:Wait()

		if v6 == nil and flag and p.Parent ~= nil then
			return fetch(p, flag)
		end

		return v6
	end
end

function Save.Peek(p)
	local v4 = p or localPlayer

	if v4 == nil or v4.Parent == nil then
		v4 = nil
	end

	if v4 == nil then
		return nil
	end

	return v[v4]
end

function Save.Await(p)
	local v4 = p or localPlayer

	if v4 == nil or v4.Parent == nil then
		v4 = nil
	end

	if v4 == nil then
		return nil
	end

	return fetch(v4, v4 == localPlayer)
end

function Save.IsLoaded(p)
	return Save.Peek(p) ~= nil
end

function Save.Watch(p: string)
	local v4 = v3[p]

	if v4 == nil then
		v4 = Signal.new()
		v3[p] = v4
	end

	return v4
end

function Save.WatchFields(value, callback)
	local v4 = Trove.new()

	if type(value) == "string" then
		local v5 = v3[value]

		if v5 == nil then
			v5 = Signal.new()
			v3[value] = v5
		end

		v4:Connect(v5, callback)
		return v4
	else
		for _, v5 in value do
			local v6 = v3[v5]

			if v6 == nil then
				v6 = Signal.new()
				v3[v5] = v6
			end

			v4:Connect(v6, callback)
		end

		return v4
	end
end

function Save.Amend(p: string, callback)
	local v4 = Save.Peek()
	local clone

	if v4 ~= nil then
		clone = v4[p]
	end

	if type(clone) ~= "table" then
		return
	end

	if table.isfrozen(clone) then
		clone = table.clone(clone)
	end

	callback(clone)
	applyDelta(localPlayer, {
		[p] = clone
	})
end

Remotes.ProfileMirror.ProfileDelta.OnClientEvent:Connect(function(p, p2, player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		player = localPlayer
	end

	if player == nil or type(p) ~= "table" then
		return
	end

	if type(p2) ~= "table" then
		p2 = nil
	end

	applyDelta(player, p, p2)
end)
Players.PlayerRemoving:Connect(function(player)
	task.defer(function()
		v[player] = nil
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function track(p)
	task.spawn(fetch, p, true)
end

Players.PlayerAdded:Connect(track)

for _, v4 in Players:GetPlayers() do
	track(v4) -- equivalent call inferred; original call site unknown
end

return Save