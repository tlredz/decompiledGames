local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.Parent.Server)
end

local shared = script.Parent.Shared
local Remote = require(shared.Remote)
local Serializer = require(shared.Serializer)
local v = Remote.New({
	Name = "Serialized"
})
local v2 = Remote.New({
	Name = "Unserialized"
})
local v3 = {}
local v4 = {}
local v5 = {}
local DataContainer = {}
local DeepCopy

DeepCopy = function(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = DeepCopy(item)
	end

	return result
end

local function CompactConnections(state)
	if not state.PendingCleanup then
		return
	end

	state.PendingCleanup = nil
	local connections = {}

	for _, connection in state.Connections do
		if connection.IsConnected then
			table.insert(connections, connection)
		else
			connection.Removed = true
		end
	end

	state.Connections = connections
end

local function IsPathMatch(path, list)
	for i = 1, #path do
		local v6 = path[i]

		if not v6 then
			break
		end

		local v7 = list[i]

		if not (v7 and v6 == v7) then
			return false
		end
	end

	return true
end

local function GetContinuedPath(path, list)
	local result = {}

	if #list > #path then
		for i = #path + 1, #list do
			table.insert(result, list[i])
		end
	end

	return result
end

local function TrimPath(common, list)
	local v6 = math.min(#common, #list)

	for i = 1, v6 do
		if common[i] == list[i] then
			continue
		end

		v6 = i - 1
		break
	end

	for i = #common, v6 + 1, -1 do
		common[i] = nil
	end
end

local function FormatPath(list)
	local v6 = table.create(#list)

	for i = 1, #list do
		v6[i] = tostring(list[i])
	end

	return table.concat(v6, ".")
end

local function RegisterPathChange(p, p2, p3, p4)
	CompactConnections(p)

	for _, connection in p.Connections do
		if connection.IsConnected and IsPathMatch(connection.Path, p2) then
			connection.Callback(p3, p4, (GetContinuedPath(connection.Path, p2)))
		end
	end
end

local function RegisterPathChanges(object, items)
	CompactConnections(object)

	for _, connection in object.Connections do
		if not connection.IsConnected then
			continue
		end

		local v6 = {}
		local v7 = {}

		for _, item in items do
			local v8 = item[1]

			if not IsPathMatch(connection.Path, v8) then
				continue
			end

			local v9 = v6[v8[1]]

			if v9 then
				v9.Count += 1
				TrimPath(v9.Common, v8)
			else
				local v10 = {
					Change = item,
					Common = table.clone(v8),
					Count = 1
				}
				v6[v8[1]] = v10
				table.insert(v7, v10)
			end
		end

		for _, v9 in v7 do
			if not connection.IsConnected then
				break
			end

			if v9.Count == 1 then
				local change = v9.Change
				task.spawn(connection.Callback, change[2], change[3], (GetContinuedPath(connection.Path, change[1])))
			else
				task.spawn(
					connection.Callback,
					object:GetValue(v9.Common),
					nil,
					(GetContinuedPath(connection.Path, v9.Common))
				)
			end
		end
	end
end

local function ApplyContainerValue(p, list, p2)
	local data = p.Data

	for i = 1, #list - 1 do
		if not data then
			break
		end

		local v6 = list[i]

		if not v6 then
			break
		end

		if typeof(data) == "table" then
			data = data[v6]
		else
			data = nil
			break
		end
	end

	if typeof(data) ~= "table" then
		return false
	end

	local v6 = data[list[#list]]

	if p2 == "nil" then
		p2 = nil
	elseif p2 == "true" then
		p2 = true
	elseif p2 == "false" then
		p2 = false
	end

	data[list[#list]] = p2
	return true, p2, v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateContainerValue(p, p2, p3)
	local v6, v7, v8 = ApplyContainerValue(p, p2, p3)

	if not v6 then
		return
	end

	RegisterPathChange(p, p2, v7, v8)
end

local function UpdateContainerValues(p, list, items)
	local data = p.Data

	for i = 1, #list do
		if not data then
			break
		end

		local v6 = list[i]

		if not v6 then
			break
		end

		if typeof(data) == "table" then
			data = data[v6]
		else
			data = nil
			break
		end
	end

	if not data then
		return
	end

	local deepCopy = DeepCopy(data)

	for k, item in items do
		if item == "nil" then
			item = nil
		elseif item == "true" then
			item = true
		elseif item == "false" then
			item = false
		end

		data[k] = item
	end

	RegisterPathChange(p, list, data, deepCopy)
end

local function RegisterContainerReady(p)
	for _, pendingUpdate in p.PendingUpdates do
		if pendingUpdate.Values then
			UpdateContainerValues(p, pendingUpdate.Path, pendingUpdate.Values)
		else
			UpdateContainerValue(p, pendingUpdate.Path, pendingUpdate.Value) -- equivalent call inferred; original call site unknown
		end
	end

	for _, readyConnection in p.ReadyConnections do
		readyConnection()
	end

	table.clear(p.PendingUpdates)
end

local function RemoteInterpreter(p: string, ...)
	local v6 = { ... }

	if p == "SendData" then
		local ID = v6[1]
		local v8 = v6[2]
		local v9 = v6[3]

		if not ID or typeof(ID) ~= "number" or (not v8 or typeof(v8) ~= "string") then
			return
		end

		if not v9 or typeof(v9) ~= "table" then
			return
		end

		local v10 = v3[v8]

		if not v10 or v10.Ready == true then
			return
		end

		v10.ID = ID
		v10.Data = v9
		v10.Ready = true
		RegisterContainerReady(v10)
	elseif p == "SetValue" then
		local v7 = v6[1]
		local path = v6[2]
		local v9 = v6[3]

		if not v7 or typeof(v7) ~= "string" or (not path or typeof(path) ~= "table") then
			return
		end

		if v9 == nil then
			return
		end

		local v10 = v3[v7]

		if not v10 then
			return
		end

		if v10.Data == nil then
			table.insert(v10.PendingUpdates, {
				Path = path,
				Value = v9
			})
			return
		end

		UpdateContainerValue(v10, path, v9) -- equivalent call inferred; original call site unknown
	elseif p == "SetValues" then
		local v7 = v6[1]
		local path = v6[2]
		local values = v6[3]

		if not v7 or typeof(v7) ~= "string" or (not path or typeof(path) ~= "table") then
			return
		end

		if values == nil or typeof(values) ~= "table" then
			return
		end

		local v10 = v3[v7]

		if not v10 then
			return
		end

		if v10.Data == nil then
			table.insert(v10.PendingUpdates, {
				Path = path,
				Values = values
			})
		else
			UpdateContainerValues(v10, path, values)
		end
	elseif p == "BulkUpdate" then
		local v7 = v6[1]
		local v8 = v6[2]

		if not v7 or typeof(v7) ~= "string" or (not v8 or typeof(v8) ~= "table") then
			return
		end

		local v9 = v3[v7]

		if not v9 then
			return
		end

		for _, v10 in v8 do
			if typeof(v10) ~= "table" then
				continue
			end

			local path = v10[1]
			local values = v10[2]
			local v13 = v10[3] == true

			if not (path and typeof(path) == "table" and values ~= nil and (not v13 or typeof(values) == "table")) then
				continue
			end

			if v9.Data == nil then
				if v13 then
					table.insert(v9.PendingUpdates, {
						Path = path,
						Values = values
					})
				else
					table.insert(v9.PendingUpdates, {
						Path = path,
						Value = values
					})
				end
			elseif v13 then
				task.spawn(UpdateContainerValues, v9, path, values)
			else
				task.spawn(UpdateContainerValue, v9, path, values)
			end
		end
	elseif p == "Commit" then
		local v7 = v6[1]
		local v8 = v6[2]

		if not v7 or typeof(v7) ~= "string" or (not v8 or typeof(v8) ~= "table") then
			return
		end

		local v9 = v3[v7]

		if not v9 then
			return
		end

		local v10 = {}
		local v11 = {}

		for _, v12 in v8 do
			if typeof(v12) ~= "table" then
				continue
			end

			local path = v12[1]
			local v14 = v12[2]

			if not (path and typeof(path) == "table" and #path ~= 0 and v14 ~= nil) then
				continue
			end

			if v9.Data == nil then
				table.insert(v9.PendingUpdates, {
					Path = path,
					Value = v14
				})
			else
				local v15, v16, v17 = ApplyContainerValue(v9, path, v14)

				if v15 then
					table.insert(v10, { path, v16, v17 })
				else
					warn((`[DATA CONTAINER]: Commit entry could not be applied for {v7} at {FormatPath(path)}`))
					v11[path[1]] = true
				end
			end
		end

		if #v10 > 0 then
			RegisterPathChanges(v9, v10)
		end

		for k in v11 do
			v:Fire("Resync", v7, k)
		end
	elseif p == "DestroyContainer" then
		local v7 = v6[1]

		if not v7 or typeof(v7) ~= "string" then
			return
		end

		local v8 = v3[v7]

		if not v8 then
			return
		end

		v8.Ready = false
	end
end

function DataContainer.New(name: string)
	if not name or typeof(name) ~= "string" then
		warn("[DATA CONTAINER]: Name is nil or not a string")
		return
	end

	if v3[name] then
		return v3[name]
	end

	local self = setmetatable({
		Name = name,
		Ready = false,
		Connections = {},
		PendingUpdates = {},
		ReadyConnections = {}
	}, {
		__index = v4
	})
	v:Fire("RequestData", name)
	v3[name] = self
	return self
end

function DataContainer.GetByName(value: string)
	if value and typeof(value) == "string" then
		return v3[value]
	end

	warn("[DATA CONTAINER]: Name is nil or not a string")
end

function DataContainer.GetByID(value: number)
	if not value or typeof(value) ~= "number" then
		warn("[DATA CONTAINER]: ID is nil or not a number")
		return
	end

	for _, v6 in v3 do
		if v6.ID == value then
			return v6
		end
	end

	return nil
end

function v5.New(callback)
	return (setmetatable({
		IsConnected = true,
		Callback = callback
	}, {
		__index = v5
	}))
end

function v5:Disconnect()
	if not self.IsConnected then
		return
	end

	self.IsConnected = false

	if self.Container then
		self.Container.PendingCleanup = true
	end
end

function v5:Reconnect()
	if self.IsConnected then
		return
	end

	self.IsConnected = true

	if self.Removed and self.Container then
		self.Removed = nil
		table.insert(self.Container.Connections, self)
	end
end

function v4:GetValue(list)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return
	end

	local data = self.Data

	for i = 1, #list - 1 do
		if not data then
			break
		end

		local v6 = list[i]

		if not v6 then
			break
		end

		if typeof(data) == "table" then
			data = data[v6]
		else
			data = nil
			break
		end
	end

	if data then
		return data[list[#list]]
	end
end

function v4.OnChange(container, path, callback)
	if not path or typeof(path) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return
	end

	if not callback or typeof(callback) ~= "function" then
		warn("[DATA CONTAINER]: Callback is nil or not a function")
		return
	end

	CompactConnections(container)
	local v6 = v5.New(callback)
	v6.Path = path
	v6.Container = container
	table.insert(container.Connections, v6)
	return v6
end

function v4.WaitToBeReady(p)
	repeat
		task.wait()
	until p.Ready
end

function v4.OnReady(p, callback)
	if not callback or typeof(callback) ~= "function" then
		warn("[DATA CONTAINER]: Callback is nil or not a function")
		return
	end

	table.insert(p.ReadyConnections, callback)

	if p.Ready then
		callback()
	end
end

v:RegisterPreFire(function(items)
	local result = {}

	for k, item in items do
		result[k] = Serializer.Serialize(item)
	end

	return result
end)
v:RegisterPreCall(function(items)
	local result = {}

	for k, item in items do
		result[k] = Serializer.Deserialize(item)
	end

	return result
end)
v:Connect(RemoteInterpreter)
v2:Connect(RemoteInterpreter)
return DataContainer