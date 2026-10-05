local _ = {
	RequestDataRepeat = 10,
	SetterError = "[ReplicaController]: Replica setters can only be called inside write functions"
}
local RunService = game:GetService("RunService")

local function WaitForDescendant(instance, childName, p)
	local child = instance:FindFirstChild(childName, true)

	if child ~= nil then
		return child
	end

	local lastTime = os.clock()
	local descendantAddedConnection = instance.DescendantAdded:Connect(function(descendant)
		if descendant.Name == childName then
			child = descendant
		end
	end)

	while child == nil do
		if lastTime ~= nil and os.clock() - lastTime > 1 and (RunService:IsServer() == true or game:IsLoaded() == true) then
			warn("[" .. script.Name .. "]: Missing " .. p .. " \"" .. childName .. "\" in " .. instance:GetFullName() .. "; Please check setup documentation")
			lastTime = nil
		end

		task.wait()
	end

	descendantAddedConnection:Disconnect()
	return child
end

local parent2

if RunService:IsServer() == true then
	parent2 = Instance.new("Folder")
	parent2.Name = "ReplicaRemoteEvents"
	parent2.Parent = game:GetService("ReplicatedStorage")
else
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	parent2 = WaitForDescendant(ReplicatedStorage, "ReplicaRemoteEvents", "folder")
end

local v2 = {
	GetShared = function(_, p)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		return (WaitForDescendant(ReplicatedStorage, p, "module"))
	end,
	GetModule = function(_, p)
		local ServerScriptService = game:GetService("ServerScriptService")
		return (WaitForDescendant(ServerScriptService, p, "module"))
	end,
	SetupRemoteEvent = function(name)
		if RunService:IsServer() ~= true then
			return (WaitForDescendant(parent2, name, "remote event"))
		end

		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = name
		remoteEvent.Parent = parent2
		return remoteEvent
	end,
	Shared = {}
}
local module = require(v2.GetShared("Madwork", "MadworkScriptSignal"))
v2.NewScriptSignal = module.NewScriptSignal
v2.NewArrayScriptConnection = module.NewArrayScriptConnection
local ReplicaController = {
	NewReplicaSignal = v2.NewScriptSignal(),
	InitialDataReceivedSignal = v2.NewScriptSignal(),
	InitialDataReceived = false,
	_replicas = {},
	_class_listeners = {},
	_child_listeners = {}
}
local module2 = require(v2.GetShared("Madwork", "MadworkMaid"))
local class = nil
local _replicas = ReplicaController._replicas
local newReplicaSignal = ReplicaController.NewReplicaSignal
local _class_listeners = ReplicaController._class_listeners
local _child_listeners = ReplicaController._child_listeners
local v3 = v2.SetupRemoteEvent("Replica_ReplicaRequestData")
local v4 = v2.SetupRemoteEvent("Replica_ReplicaSetValue")
local v5 = v2.SetupRemoteEvent("Replica_ReplicaSetValues")
local v6 = v2.SetupRemoteEvent("Replica_ReplicaArrayInsert")
local v7 = v2.SetupRemoteEvent("Replica_ReplicaArraySet")
local v8 = v2.SetupRemoteEvent("Replica_ReplicaArrayRemove")
local v9 = v2.SetupRemoteEvent("Replica_ReplicaWrite")
local v10 = v2.SetupRemoteEvent("Replica_ReplicaSignal")
local v11 = v2.SetupRemoteEvent("Replica_ReplicaSetParent")
local v12 = v2.SetupRemoteEvent("Replica_ReplicaCreate")
local v13 = v2.SetupRemoteEvent("Replica_ReplicaDestroy")
local v14 = false
local v15 = {}
local v16 = false
local GetWriteLibFunctionsRecursive

GetWriteLibFunctionsRecursive = function(list, items, p)
	for k, item in pairs(items) do
		if type(item) == "table" then
			GetWriteLibFunctionsRecursive(list, item, p .. k .. ".")
		elseif type(item) == "function" then
			table.insert(list, { p .. k, item })
		else
			error("[ReplicaController]: Invalid write function value \"" .. tostring(item) .. "\" (" .. typeof(item) .. "); name_stack = \"" .. p .. "\"")
		end
	end
end

local function LoadWriteLib(moduleScript)
	local v17 = v15[moduleScript]

	if v17 ~= nil then
		return v17
	end

	local module3 = require(moduleScript)
	local v18 = {}
	GetWriteLibFunctionsRecursive(v18, module3, "")
	table.sort(v18, function(a, b)
		return a[1] < b[1]
	end)
	local v19 = {}
	local v20 = {}

	for i, v21 in ipairs(v18) do
		v19[i] = v21[2]
		v20[v21[1]] = i
	end

	local v21 = { v19, v20 }
	v15[moduleScript] = v21
	return v21
end

local function StringPathToArray(value)
	local result = {}

	if value ~= "" then
		for k in string.gmatch(value, "[^%.]+") do
			table.insert(result, k)
		end
	end

	return result
end

local DestroyReplicaAndDescendantsRecursive

DestroyReplicaAndDescendantsRecursive = function(data, p)
	for _, v17 in ipairs(data.Children) do
		DestroyReplicaAndDescendantsRecursive(v17, true)
	end

	local id = data.Id
	_replicas[id] = nil
	data._maid:Cleanup()

	if p ~= true and data.Parent ~= nil then
		local children = data.Parent.Children
		table.remove(children, table.find(children, data))
	end

	_child_listeners[id] = nil
end

local function CreateTableListenerPathIndex(p, value, p2)
	local _table_listeners = p._table_listeners

	for i = 1, #value do
		local v17 = _table_listeners[1][value[i]]

		if v17 == nil then
			v17 = {
				{}
			}
			_table_listeners[1][value[i]] = v17
		end

		_table_listeners = v17
	end

	local _table_listener = _table_listeners[p2]

	if _table_listener == nil then
		_table_listener = {}
		_table_listeners[p2] = _table_listener
	end

	return _table_listener
end

local function CleanTableListenerTable(list)
	local v17 = list[1]
	local v18 = list[2]
	local v19 = { v17 }

	for i = 1, #v18 do
		v17 = v17[1][v18[i]]
		table.insert(v19, v17)
	end

	for i = #v19, 2, -1 do
		local v20 = v19[i]

		if next(v20[1]) ~= nil then
			break
		end

		for i2 = 2, 6 do
			if v20[i2] ~= nil and #v20[i2] > 0 then
				return
			end
		end

		v19[i - 1][1][v18[i - 1]] = nil
	end
end

local function CreateReplicaBranch(items, options)
	local v17 = {}

	for k, item in pairs(items) do
		item[6] = tonumber(k)
		table.insert(v17, item)
	end

	table.sort(v17, function(a, b)
		return a[6] < b[6]
	end)
	local v18 = {}
	local result = options or {}

	for _, v19 in ipairs(v17) do
		local id = v19[6]
		local v21 = v19[4]
		local v22 = false
		local parent

		if v21 ~= 0 then
			parent = _replicas[v21]

			if parent == nil then
				v22 = true
			end
		end

		local write_lib, write_lib_dictionary

		if v19[5] ~= nil then
			local loadWriteLib = LoadWriteLib(v19[5])
			write_lib = loadWriteLib[1]
			write_lib_dictionary = loadWriteLib[2]
		end

		local parent3 = {
			Data = v19[3],
			Id = id,
			Class = v19[1],
			Tags = v19[2],
			Parent = parent,
			Children = {},
			_write_lib = write_lib,
			_write_lib_dictionary = write_lib_dictionary,
			_table_listeners = {
				{}
			},
			_function_listeners = {},
			_raw_listeners = {},
			_signal_listeners = {},
			_maid = module2.NewMaid()
		}
		setmetatable(parent3, class)

		if parent == nil then
			if v22 == true then
				local v27 = v18[v21]

				if v27 == nil then
					v27 = {}
					v18[v21] = v27
				end

				table.insert(v27, parent3)
			end
		else
			table.insert(parent.Children, parent3)
		end

		_replicas[id] = parent3
		table.insert(result, parent3)
		local v27 = v18[id]

		if v27 == nil then
			continue
		end

		v18[id] = nil

		for _, v28 in ipairs(v27) do
			v28.Parent = parent3
			table.insert(parent3.Children, v28)
		end
	end

	if next(v18) == nil then
		return result
	end

	local v19 = "[ReplicaService]: BRANCH REPLICATION ERROR - Missing parents: "

	for k, list in pairs(v18) do
		local v20 = v19 .. "[" .. tostring(k) .. "]: {"

		for i, v21 in ipairs(list) do
			v20 ..= (i == 1 and "" or ", ") .. v21:Identify()
		end

		v19 = v20 .. "}; "
	end

	error(v19)
	return result
end

local function ReplicaSetValue(id, value, p)
	local _replica = _replicas[id]
	local data = _replica.Data
	local _table_listeners = _replica._table_listeners

	for i = 1, #value - 1 do
		data = data[value[i]]

		if _table_listeners ~= nil then
			_table_listeners = _table_listeners[1][value[i]]
		end
	end

	local v17 = value[#value]
	local v18 = data[v17]
	data[v17] = p

	if v18 ~= p and _table_listeners ~= nil then
		if v18 == nil and _table_listeners[3] ~= nil then
			for _, v19 in ipairs(_table_listeners[3]) do
				v19(p, v17)
			end
		end

		local v19 = _table_listeners[1][value[#value]]

		if v19 ~= nil and v19[2] ~= nil then
			for _, v20 in ipairs(v19[2]) do
				v20(p, v18)
			end
		end
	end

	for _, _raw_listener in ipairs(_replica._raw_listeners) do
		_raw_listener("SetValue", value, p)
	end
end

local function ReplicaSetValues(id, value, items)
	local _replica = _replicas[id]
	local data = _replica.Data
	local _table_listeners = _replica._table_listeners

	for i = 1, #value do
		data = data[value[i]]

		if _table_listeners ~= nil then
			_table_listeners = _table_listeners[1][value[i]]
		end
	end

	for k, item in pairs(items) do
		local v17 = data[k]
		data[k] = item

		if not (v17 ~= item and _table_listeners ~= nil) then
			continue
		end

		if v17 == nil and _table_listeners[3] ~= nil then
			for _, v18 in ipairs(_table_listeners[3]) do
				v18(item, k)
			end
		end

		local v18 = _table_listeners[1][k]

		if not (v18 ~= nil and v18[2] ~= nil) then
			continue
		end

		for _, v19 in ipairs(v18[2]) do
			v19(item, v17)
		end
	end

	for _, _raw_listener in ipairs(_replica._raw_listeners) do
		_raw_listener("SetValues", value, items)
	end
end

local function ReplicaArrayInsert(id, value, p)
	local _replica = _replicas[id]
	local data = _replica.Data
	local _table_listeners = _replica._table_listeners

	for i = 1, #value do
		data = data[value[i]]

		if _table_listeners ~= nil then
			_table_listeners = _table_listeners[1][value[i]]
		end
	end

	table.insert(data, p)
	local count = #data

	if _table_listeners ~= nil and _table_listeners[4] ~= nil then
		for _, v17 in ipairs(_table_listeners[4]) do
			v17(count, p)
		end
	end

	for _, _raw_listener in ipairs(_replica._raw_listeners) do
		_raw_listener("ArrayInsert", value, p, count)
	end

	return count
end

local function ReplicaArraySet(id, value, p, p2)
	local _replica = _replicas[id]
	local data = _replica.Data
	local _table_listeners = _replica._table_listeners

	for i = 1, #value do
		data = data[value[i]]

		if _table_listeners ~= nil then
			_table_listeners = _table_listeners[1][value[i]]
		end
	end

	data[p] = p2

	if _table_listeners ~= nil and _table_listeners[5] ~= nil then
		for _, v17 in ipairs(_table_listeners[5]) do
			v17(p, p2)
		end
	end

	for _, _raw_listener in ipairs(_replica._raw_listeners) do
		_raw_listener("ArraySet", value, p, p2)
	end
end

local function ReplicaArrayRemove(id, value, p)
	local _replica = _replicas[id]
	local data = _replica.Data
	local _table_listeners = _replica._table_listeners

	for i = 1, #value do
		data = data[value[i]]

		if _table_listeners ~= nil then
			_table_listeners = _table_listeners[1][value[i]]
		end
	end

	local v17 = table.remove(data, p)

	if _table_listeners ~= nil and _table_listeners[6] ~= nil then
		for _, v18 in ipairs(_table_listeners[6]) do
			v18(p, v17)
		end
	end

	for _, _raw_listener in ipairs(_replica._raw_listeners) do
		_raw_listener("ArrayRemove", value, p, v17)
	end

	return v17
end

class = {}
class.__index = class

function class:ListenToChange(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToChange()")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	if #value < 1 then
		error("[ReplicaController]: Passed empty path - a value key must be specified")
	end

	local callbacks = CreateTableListenerPathIndex(self, value, 2)
	table.insert(callbacks, callback)
	return v2.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToNewKey(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToNewKey()")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	local callbacks = CreateTableListenerPathIndex(self, value, 3)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v2.NewArrayScriptConnection(callbacks, callback)
	end

	return v2.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToArrayInsert(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToArrayInsert()")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	local callbacks = CreateTableListenerPathIndex(self, value, 4)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v2.NewArrayScriptConnection(callbacks, callback)
	end

	return v2.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToArraySet(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToArraySet()")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	local callbacks = CreateTableListenerPathIndex(self, value, 5)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v2.NewArrayScriptConnection(callbacks, callback)
	end

	return v2.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToArrayRemove(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToArrayRemove()")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	local callbacks = CreateTableListenerPathIndex(self, value, 6)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v2.NewArrayScriptConnection(callbacks, callback)
	end

	return v2.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToWrite(p, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToWrite()")
	end

	if self._write_lib == nil then
		error("[ReplicaController]: _write_lib was not declared for this replica")
	end

	local v17 = self._write_lib_dictionary[p]

	if v17 == nil then
		error("[ReplicaController]: Write function \"" .. p .. "\" not declared inside _write_lib of this replica")
	end

	local _function_listener = self._function_listeners[v17]

	if _function_listener == nil then
		_function_listener = {}
		self._function_listeners[v17] = _function_listener
	end

	table.insert(_function_listener, callback)
	return v2.NewArrayScriptConnection(_function_listener, callback)
end

function class:ListenToRaw(p2)
	local _raw_listeners = self._raw_listeners
	table.insert(_raw_listeners, p2)
	return v2.NewArrayScriptConnection(_raw_listeners, p2)
end

function class:ConnectOnClientEvent(callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only functions can be passed to Replica:ConnectOnClientEvent()")
	end

	table.insert(self._signal_listeners, callback)
	return v2.NewArrayScriptConnection(self._signal_listeners, callback)
end

function class:FireServer(...)
	v10:FireServer(self.Id, ...)
end

function class.ListenToChildAdded(p, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener")
	end

	if _replicas[p.Id] == nil then
		return
	end

	local _child_listener = _child_listeners[p.Id]

	if _child_listener == nil then
		_child_listener = {}
		_child_listeners[p.Id] = _child_listener
	end

	table.insert(_child_listener, callback)
	return v2.NewArrayScriptConnection(_child_listener, callback)
end

function class.FindFirstChildOfClass(p, p2)
	for _, v17 in ipairs(p.Children) do
		if v17.Class == p2 then
			return v17
		end
	end

	return nil
end

function class:Identify()
	local v17 = ""

	for k, tag in pairs(self.Tags) do
		v17 ..= "" .. tostring(k) .. "=" .. tostring(tag)
	end

	return "[Id:" .. tostring(self.Id) .. ";Class:" .. self.Class .. ";Tags:{" .. v17 .. "}]"
end

function class.IsActive(p)
	return _replicas[p.Id] ~= nil
end

function class:AddCleanupTask(p2)
	return self._maid:AddCleanupTask(p2)
end

function class:RemoveCleanupTask(p2)
	self._maid:RemoveCleanupTask(p2)
end

function class.SetValue(p, value, p2)
	if v16 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	ReplicaSetValue(p.Id, value, p2)
end

function class.SetValues(p, value, p2)
	if v16 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	ReplicaSetValues(p.Id, value, p2)
end

function class.ArrayInsert(p, value, p2)
	if v16 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	return (ReplicaArrayInsert(p.Id, value, p2))
end

function class.ArraySet(p, value, p2, p3)
	if v16 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	ReplicaArraySet(p.Id, value, p2, p3)
end

function class.ArrayRemove(p, value, p2)
	if v16 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	if type(value) == "string" then
		value = StringPathToArray(value) or value
	end

	return (ReplicaArrayRemove(p.Id, value, p2))
end

function class:Write(p, ...)
	if v16 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	local v17 = self._write_lib_dictionary[p]
	local v18 = table.pack(self._write_lib[v17](self, ...))
	local _function_listener = self._function_listeners[v17]

	if _function_listener ~= nil then
		for _, v19 in ipairs(_function_listener) do
			v19(...)
		end
	end

	return table.unpack(v18)
end

function ReplicaController.RequestData()
	if v14 == true then
		return
	end

	v14 = true
	task.spawn(function()
		while game:IsLoaded() == false do
			task.wait()
		end

		v3:FireServer()

		while task.wait(10) and ReplicaController.InitialDataReceived ~= true do
			v3:FireServer()
		end
	end)
end

function ReplicaController.ReplicaOfClassCreated(value, callback)
	if type(value) ~= "string" then
		error("[ReplicaController]: replica_class must be a string")
	end

	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in ReplicaController.ReplicaOfClassCreated()")
	end

	local _class_listener = _class_listeners[value]

	if _class_listener == nil then
		_class_listener = v2.NewScriptSignal()
		_class_listeners[value] = _class_listener
	end

	return _class_listener:Connect(callback, function()
		if _class_listener:GetListenerCount() == 0 and _class_listeners[value] == _class_listener then
			_class_listeners[value] = nil
		end
	end)
end

function ReplicaController.GetReplicaById(p)
	return _replicas[p]
end

v3.OnClientEvent:Connect(function()
	ReplicaController.InitialDataReceived = true
	print("[ReplicaController]: Initial data received")
	ReplicaController.InitialDataReceivedSignal:Fire()
end)
v4.OnClientEvent:Connect(ReplicaSetValue)
v5.OnClientEvent:Connect(ReplicaSetValues)
v6.OnClientEvent:Connect(ReplicaArrayInsert)
v7.OnClientEvent:Connect(ReplicaArraySet)
v8.OnClientEvent:Connect(ReplicaArrayRemove)
v9.OnClientEvent:Connect(function(p, p2, ...)
	local _replica = _replicas[p]
	v16 = true
	_replica._write_lib[p2](_replica, ...)
	v16 = false
	local _function_listener = _replica._function_listeners[p2]

	if _function_listener ~= nil then
		for _, v17 in ipairs(_function_listener) do
			v17(...)
		end
	end
end)
v10.OnClientEvent:Connect(function(p, ...)
	local _signal_listeners = _replicas[p]._signal_listeners

	for _, _signal_listener in ipairs(_signal_listeners) do
		_signal_listener(...)
	end
end)
v11.OnClientEvent:Connect(function(p, p2)
	local _replica = _replicas[p]
	local children = _replica.Parent.Children
	local _replica2 = _replicas[p2]
	table.remove(children, table.find(children, _replica))
	table.insert(_replica2.Children, _replica)
	_replica.Parent = _replica2
	local _child_listener = _child_listeners[p2]

	if _child_listener ~= nil then
		for i = 1, #_child_listener do
			_child_listener[i](_replica)
		end
	end
end)
v12.OnClientEvent:Connect(function(list, list2)
	local v17 = {}

	if type(list) == "table" then
		table.sort(list, function(a, b)
			return a[1] < b[1]
		end)

		for _, v18 in ipairs(list) do
			CreateReplicaBranch(v18[2], v17)
		end
	elseif list2[1] == nil then
		CreateReplicaBranch(list2, v17)
	else
		CreateReplicaBranch({
			[tostring(list)] = list2
		}, v17)
	end

	table.sort(v17, function(a, b)
		return a.Id < b.Id
	end)

	for _, v18 in ipairs(v17) do
		local parent = v18.Parent

		if parent == nil then
			continue
		end

		local _child_listener = _child_listeners[parent.Id]

		if _child_listener == nil then
			continue
		end

		for i = 1, #_child_listener do
			_child_listener[i](v18)
		end
	end

	for _, v18 in ipairs(v17) do
		newReplicaSignal:Fire(v18)
		local _class_listener = _class_listeners[v18.Class]

		if _class_listener ~= nil then
			_class_listener:Fire(v18)
		end
	end
end)
v13.OnClientEvent:Connect(function(p)
	DestroyReplicaAndDescendantsRecursive(_replicas[p])
end)
return ReplicaController