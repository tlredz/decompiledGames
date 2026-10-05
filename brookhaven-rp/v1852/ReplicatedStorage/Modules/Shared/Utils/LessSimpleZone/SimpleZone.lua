local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local isClient = RunService:IsClient()
local utility = script.Utility
local templates = script.Templates
local BVH = require(utility.BVH)
local SimpleSignal = require(utility.SimpleSignal)
require(script.Types)
local SearchFor = require(script.SearchFor)
local PlayerLookup = require(script.PlayerLookup)
local clientWorker = templates.ClientWorker
local serverWorker = templates.ServerWorker
local clientWorkerScript = templates.ClientWorkerScript
local serverWorkerScript = templates:FindFirstChild("ServerWorkerScript")
local zoneClass = {}
local folder = Instance.new("Folder")
folder.Name = "SIMPLEZONE_ZONE_ACTORS"

if isClient then
	ServerScriptService = Players.LocalPlayer.PlayerScripts or ServerScriptService
end

folder.Parent = ServerScriptService

if isClient then
	serverWorker = clientWorker or serverWorker
end

if isClient then
	serverWorkerScript = clientWorkerScript or serverWorkerScript
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queryop_new()
	return {
		FireMode = "Both",
		TrackItemEnabled = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOnEnterExit(object)
	local _queryOptions = object._queryOptions
	local _ = object._items
	local _ = _queryOptions.FireMode
	return
		(_queryOptions.FireMode == "OnEnter" or _queryOptions.FireMode == "Both") and _queryOptions.FireMode ~= "None",
		(_queryOptions.FireMode == "OnExit" or _queryOptions.FireMode == "Both") and _queryOptions.FireMode ~= "None"
end

local function getTracked(p, instance)
	if not p._queryOptions.TrackItemEnabled then
		return
	end

	for ancestor in p._tracked do
		if instance:IsDescendantOf(ancestor) then
			return ancestor
		end
	end
end

local function getItem(p, instance)
	local v2

	if not p._queryOptions.TrackItemEnabled then
		return v2 or PlayerLookup[instance] or instance
	end

	for ancestor in p._tracked do
		if not instance:IsDescendantOf(ancestor) then
			continue
		end

		v2 = ancestor
		break
	end

	return v2 or PlayerLookup[instance] or instance
end

function zoneClass:Update(p, flag: boolean?, flag2: boolean?)
	local query = self:Query(p)
	local v2 = {}

	for _, v3 in query do
		if v2[v3] then
			continue
		end

		local v4

		if self._queryOptions.TrackItemEnabled then
			for ancestor in self._tracked do
				if not v3:IsDescendantOf(ancestor) then
					continue
				end

				v4 = ancestor
				break
			end
		else
			local ancestor = nil
			v4 = ancestor
		end

		local v5 = v4 or PlayerLookup[v3] or v3

		if v2[v5] then
			continue
		end

		v2[v5] = true

		if self._items[v5] then
			continue
		end

		self._items[v5] = true

		if flag then
			self.ItemEntered:Fire(v5)
		end
	end

	for k in self._items do
		if v2[k] then
			continue
		end

		self._items[k] = nil

		if flag2 then
			self.ItemExited:Fire(k)
		end
	end
end

function zoneClass:UnbindFromHeartbeat()
	if self._update then
		self._update:Disconnect()
		self._items = {}
	end
end

function zoneClass:BindToHeartbeat(p, value: number?)
	self:UnbindFromHeartbeat()
	local v2 = value or 0
	local v3, v4 = getOnEnterExit(self) -- equivalent call inferred; original call site unknown
	local total = 0
	self._update = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < v2 then
			return
		end

		total = 0
		self:Update(p, v3, v4)
	end)
end

function zoneClass:TrackItem(p2)
	if self._queryOptions.TrackItemEnabled then
		self._tracked[p2] = true
	else
		warn("TrackItemEnabled is not enabled, cannot call Zone:TrackItem(...)")
	end
end

function zoneClass:UntrackItem(p2)
	self._tracked[p2] = nil
end

function zoneClass.SearchFor(object, p, p2: string)
	assert(p ~= nil, "Bad properties argument.")
	return SearchFor(object:Query(), p, p2)
end

function zoneClass.ListenTo(p, className: string, p2: string, callback)
	assert(p2 == "Entered" or p2 == "Exited", "Bad mode argument.")
	return p[`Item{p2}`]:Connect(function(instance)
		if not instance:IsA(className) then
			return
		end

		callback(instance)
	end)
end

function zoneClass:GetContainedItems()
	return self._items
end

function zoneClass:GetTracked()
	return self._tracked
end

function zoneClass:Destroy()
	self:UnbindFromHeartbeat()
	local _worker = self._worker

	if _worker then
		_worker:Destroy()
	end

	self.ItemEntered:Destroy()
	self.ItemExited:Destroy()
	setmetatable(self, nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assertQueryOp(p)
	if not p then
		return
	end

	local fireMode = p.FireMode
	assert(
		fireMode == "Both" or fireMode == "OnExit" or fireMode == "OnEnter" or fireMode == "None",
		"Bad QueryOptions argument."
	)
end

local function zone_new(p, query, p3)
	assertQueryOp(p) -- equivalent call inferred; original call site unknown
	return (setmetatable({
		_items = {},
		_tracked = {},
		_update = false,
		_queryOptions = p or queryop_new(),
		ItemEntered = SimpleSignal.new(),
		ItemExited = SimpleSignal.new(),
		Query = query
	}, {
		__index = p3 or zoneClass
	}))
end

local function zone_fromPart(p, p2)
	return (zone_new(p2, function(_, p3)
		return workspace:GetPartsInPart(p, p3)
	end))
end

local function zone_fromBox(cframe: CFrame, vector: Vector3, p)
	return (zone_new(p, function(_, p2)
		return workspace:GetPartBoundsInBox(cframe, vector, p2)
	end))
end

local function zone_fromBoxes(p, p2)
	local BVH2, _ = BVH.createBVH(p)
	return (zone_new(p2, function(_, p3)
		local result = {}
		local v2 = {}
		BVH.traverseBVH(BVH2, function(data)
			local partBoundsInBox = workspace:GetPartBoundsInBox(data.cframe, data.size, p3)

			if #partBoundsInBox == 0 then
				return false
			end

			if data.right or data.left then
				return true
			end

			for _, v3 in partBoundsInBox do
				if v2[v3] then
					continue
				end

				v2[v3] = true
				result[#result + 1] = v3
			end

			return false
		end)
		return result
	end))
end

local function zone_fromPartParallel(instance, p)
	local clone = serverWorker:Clone()
	local clone2 = serverWorkerScript:Clone()
	clone2.Enabled = true
	clone2.Parent = clone
	clone.Parent = folder
	local result = clone.Result
	local _ = instance.CFrame
	local _ = instance.Size
	local v2 = zone_new(p, function(_, p2)
		task.defer(function()
			clone:SendMessage("GetPartsInPart", p2, instance)
		end)
		return (result.Event:Wait())
	end)
	v2._worker = clone
	return v2
end

local function zone_fromPartParallelBounds(instance, p)
	local clone = serverWorker:Clone()
	local clone2 = serverWorkerScript:Clone()
	clone2.Enabled = true
	clone2.Parent = clone
	clone.Parent = folder
	local result = clone.Result
	local cFrame = instance.CFrame
	local size = instance.Size
	local v2 = zone_new(p, function(_, p2)
		clone:SendMessage("GetPartBoundsInBox", p2, size, cFrame)
		return (result.Event:Wait())
	end)
	v2._worker = clone
	return v2
end

local function zone_fromCustom(callback, p)
	assert(callback ~= nil, "Bad queryFn argument.")
	return (zone_new(p, callback))
end

return table.freeze({
	new = function(part, p, p2)
		if typeof(part) == "CFrame" and typeof(p) == "Vector3" then
			return (zone_new(p2, function(_, p3)
				return workspace:GetPartBoundsInBox(part, p, p3)
			end))
		end

		if typeof(part) == "Instance" and part:IsA("BasePart") then
			return (zone_new(p, function(_, p3)
				return workspace:GetPartsInPart(part, p3)
			end))
		end

		error("Unable to find an overload.")
	end,
	fromBox = zone_fromBox,
	fromPart = zone_fromPart,
	fromBoxes = zone_fromBoxes,
	fromCustom = zone_fromCustom,
	fromPartParallel = zone_fromPartParallel,
	fromPartParallelBounds = zone_fromPartParallelBounds,
	QueryOptions = {
		new = queryop_new
	},
	newInternal = zone_new,
	searchFor = SearchFor,
	BVH = BVH,
	ZoneClass = zoneClass
})