local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Signal = require(script.Parent.Parent.Signal)
local isServer = RunService:IsServer()
local requestData = script.Parent:WaitForChild("RequestData")
local Channel = {}
Channel.__index = Channel

local function ReadPath(value, table2)
	local v = typeof(value) == "table"

	if not v then
		value = string.split(value, ".")
	end

	local v2 = nil
	local selected = nil

	for i = 1, #value do
		selected = value[i]

		if not v then
			selected = tonumber(selected) or selected
		end

		local v4 = table2[selected]

		if v4 == nil then
			return nil, table2, selected
		end

		v2 = table2
		table2 = v4
	end

	return table2, v2, selected
end

local function FireAction(p, list)
	local joined = list[1]

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	local v = list[2]
	local v2 = joined ~= "" and p.Signals[v][joined]

	if v2 then
		v2:Fire(list[3], list[4], list[5])
	end
end

local function DispatchQueuedActions(object)
	if #object.Queue == 0 then
		return
	end

	for i = 1, #object.Queue do
		local v = object.Queue[i]
		local joined = v[1]

		if typeof(joined) == "table" then
			joined = table.concat(joined, ".")
		end

		local v2 = v[2]

		if joined == "" then
			continue
		end

		local v3 = object.Signals[v2][joined]

		if v3 then
			v3:Fire(v[3], v[4], v[5])
		end
	end

	if isServer then
		for _, player in object.Listeners do
			object.CommunicationRoute:FireClient(player, object.Queue)
		end
	end

	table.clear(object.Queue)
end

local function InsertOnQueue(object, list)
	local joined = list[1]
	local v = list[2]

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	if v ~= "ArrayInsert" and v ~= "ArrayRemoved" and v ~= "DictionaryInsert" and v ~= "DictionaryRemoved" then
		for i = #object.Queue, 1, -1 do
			if not (object.Queue[i][1] == joined and object.Queue[i][2] == v) then
				continue
			end

			table.remove(object.Queue, i)
			break
		end
	end

	table.insert(object.Queue, list)
end

function Channel.new(p, referenceTable, synchronizer)
	local object = setmetatable({}, Channel)
	object.Index = p
	object.Queue = {}
	object.Synchronizer = synchronizer
	object.Connections = {}
	object.SavedConnections = {}
	object.OnDestroyed = Signal.new()
	object.Listeners = {}
	object.Signals = {
		Changed = {},
		ArrayInsert = {},
		ArrayRemoved = {},
		DictionaryInsert = {},
		DictionaryRemoved = {}
	}

	if isServer then
		object.ReferenceTable = referenceTable
	end

	if isServer then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = tostring(p)
		remoteEvent.Parent = script
		object.CommunicationRoute = remoteEvent
	else
		object.CommunicationRoute = script:WaitForChild((tostring(p)))
	end

	if not isServer then
		local v = false
		local onClientEventConnection = object.CommunicationRoute.OnClientEvent:Connect(function(list)
			if not v then
				return
			end

			for i = 1, #list do
				local v2 = list[i]
				local v4, v5, v6 = ReadPath(v2[1], object:GetTable())

				if v2[2] == "Changed" then
					local v7 = v2[3]
					local _ = v2[4]
					v2[4] = v4
					v5[v6] = v7
				elseif v2[2] == "ArrayInsert" then
					table.insert(v4, v2[4], v2[3])
				elseif v2[2] == "ArrayRemoved" then
					table.remove(v4, v2[4])
				elseif v2[2] == "DictionaryInsert" then
					v4[v2[4]] = v2[3]
				elseif v2[2] == "DictionaryRemoved" then
					v4[v2[4]] = nil
				end

				local v7 = object
				local joined = v2[1]

				if typeof(joined) == "table" then
					joined = table.concat(joined, ".")
				end

				local v8 = v2[2]

				if joined == "" then
					continue
				end

				local v9 = v7.Signals[v8][joined]

				if v9 then
					v9:Fire(v2[3], v2[4], v2[5])
				end
			end
		end)
		object.CacheTable = requestData:InvokeServer(object:GetIndex())
		v = true
		table.insert(object.Connections, onClientEventConnection)
	end

	if isServer then
		table.insert(object.Connections, RunService.Stepped:Connect(function()
			debug.profilebegin("Synchronizer:DispatchQueuedActions")
			DispatchQueuedActions(object)
			debug.profileend()
		end))
	end

	return object
end

function Channel:InsertOnDictionary(value, p, p2)
	assert(value and (typeof(value) == "string" or typeof(value) == "table"), "Invalid path required!")
	assert(p2, "Value is nil!")
	assert(p, "Index is nil!")
	local v, _, _ = ReadPath(value, self:GetTable())

	if not v then
		return
	end

	v[p] = p2
	InsertOnQueue(self, {
		value,
		"DictionaryInsert",
		p2,
		p
	})
end

function Channel:RemoveFromDictionary(value, p)
	assert(value and (typeof(value) == "string" or typeof(value) == "table"), "Invalid path required!")
	assert(p, "Index is nil!")
	local v, _, _ = ReadPath(value, self:GetTable())

	if not v then
		return
	end

	local v2 = v[p]
	v[p] = nil
	InsertOnQueue(self, {
		value,
		"DictionaryRemoved",
		v2,
		p
	})
	return v2
end

function Channel:InsertOnArray(value, p, value2: number?)
	assert(value and (typeof(value) == "string" or typeof(value) == "table"), "Invalid path required!")
	assert(p, "Value is nil!")

	if value2 then
		assert(value2 and typeof(value2) == "number", "Invalid target index!")
	end

	local v, _, _ = ReadPath(value, self:GetTable())

	if not v then
		return
	end

	if value2 then
		table.insert(v, value2, p)
	else
		table.insert(v, p)
		value2 = #v
	end

	InsertOnQueue(self, {
		value,
		"ArrayInsert",
		p,
		value2
	})
	return value2
end

function Channel:RemoveFromArray(value, p: number)
	assert(value and (typeof(value) == "string" or typeof(value) == "table"), "Invalid path required!")
	assert(p, "Target index is invalid!")
	local v, _, _ = ReadPath(value, self:GetTable())

	if not v then
		return
	end

	local v2 = table.remove(v, p)
	InsertOnQueue(self, {
		value,
		"ArrayRemoved",
		v2,
		p
	})
	return v2
end

function Channel:Set(value, p)
	assert(value and (typeof(value) == "string" or typeof(value) == "table"), "Invalid path required!")
	local v, v2, v3 = ReadPath(value, self:GetTable())

	if not v2 then
		return self
	end

	v2[v3] = p
	InsertOnQueue(self, {
		value,
		"Changed",
		p,
		v
	})
	return self
end

function Channel:Increase(value, value2: number)
	assert(value and (typeof(value) == "string" or typeof(value) == "table"), "Invalid path required!")
	assert(value2 and typeof(value2) == "number", "Invalid value number required!")
	local v, v2, v3 = ReadPath(value, self:GetTable())

	if v2 and v3 then
		v2[v3] = v + value2
		InsertOnQueue(self, {
			value,
			"Changed",
			v + value2,
			v
		})
	end

	return self
end

function Channel:OnChanged(joined, callback, flag: boolean?)
	assert(joined and (typeof(joined) == "string" or typeof(joined) == "table"), "Invalid path required!")

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	local v = self.Signals.Changed[joined]

	if not v then
		v = Signal.new()
		self.Signals.Changed[joined] = v
	end

	if flag == true then
		callback(self:Get(joined), nil)
	end

	return (v:Connect(callback))
end

function Channel.OnDictionaryInserted(p, joined, callback)
	assert(joined and (typeof(joined) == "string" or typeof(joined) == "table"), "Invalid path required!")

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	local v = p.Signals.DictionaryInsert[joined]

	if not v then
		v = Signal.new()
		p.Signals.DictionaryInsert[joined] = v
	end

	return (v:Connect(callback))
end

function Channel.OnDictionaryRemoved(p, joined, callback)
	assert(joined and (typeof(joined) == "string" or typeof(joined) == "table"), "Invalid path required!")

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	local v = p.Signals.DictionaryRemoved[joined]

	if not v then
		v = Signal.new()
		p.Signals.DictionaryRemoved[joined] = v
	end

	return (v:Connect(callback))
end

function Channel.OnArrayInserted(p, joined, callback)
	assert(joined and (typeof(joined) == "string" or typeof(joined) == "table"), "Invalid path required!")

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	local v = p.Signals.ArrayInsert[joined]

	if not v then
		v = Signal.new()
		p.Signals.ArrayInsert[joined] = v
	end

	return (v:Connect(callback))
end

function Channel.OnArrayRemoved(p, joined, callback)
	assert(joined and (typeof(joined) == "string" or typeof(joined) == "table"), "Invalid path required!")

	if typeof(joined) == "table" then
		joined = table.concat(joined, ".")
	end

	local v = p.Signals.ArrayRemoved[joined]

	if not v then
		v = Signal.new()
		p.Signals.ArrayRemoved[joined] = v
	end

	return (v:Connect(callback))
end

function Channel.AddListener(p, p2)
	if table.find(p.Listeners, p2) then
		return p
	end

	table.insert(p.Listeners, p2)
	p.Synchronizer.OnChannelListenerAdded:Fire(p, p2)
	return p
end

function Channel:RemoveListener(p2)
	local index = table.find(self.Listeners, p2)

	if not index then
		return self
	end

	table.remove(self.Listeners, index)
	self.Synchronizer.OnChannelListenerRemoved:Fire(self, p2)
	return self
end

function Channel:Get(p)
	if p then
		return ReadPath(p, self:GetTable())
	end

	return self:GetTable()
end

function Channel:GetIndex()
	return self.Index
end

function Channel:GetTable()
	return isServer and self.ReferenceTable or self.CacheTable
end

function Channel:Destroy(flag: boolean?)
	if flag ~= true then
		return self.Synchronizer:Destroy(self:GetIndex())
	end

	if isServer then
		for _, listener in self.Listeners do
			self:RemoveListener(listener)
		end

		self.CommunicationRoute.Name = HttpService:GenerateGUID(false)
		Debris:AddItem(self.CommunicationRoute, 5)
	end

	self.OnDestroyed:Fire(self)
	self.OnDestroyed:DisconnectAll()

	for _, connection in self.Connections do
		connection:Disconnect()
	end

	for _, savedConnection in self.SavedConnections do
		savedConnection:Disconnect()
	end

	self.OnDestroyed:Destroy()

	for _, signal in self.Signals do
		for _, v in signal do
			v:DisconnectAll()
			v:Destroy()
		end
	end

	setmetatable(self, nil)
	return nil
end

return Channel