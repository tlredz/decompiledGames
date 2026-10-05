local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replica = ReplicatedStorage.Modules.Shared.Replica
local Remote = require(replica.Remote)
local Signal = require(replica.Signal)
local Maid = require(replica.Maid)
local v = {}
local CollectionService = game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
game:GetService("Players")
local v2 = false
local tokenReplicas = {}
local replicas = {}
local bindReplicas = {}
local bindInstances = {}
local v7 = {}
local v8 = Remote.New("ReplicaRequestData")
local v9 = Remote.New("ReplicaSet")
local v10 = Remote.New("ReplicaSetValues")
local v11 = Remote.New("ReplicaTableInsert")
local v12 = Remote.New("ReplicaTableRemove")
local v13 = Remote.New("ReplicaWrite")
local v14 = Remote.New("ReplicaSignal")
local v15 = Remote.New("ReplicaParent")
local v16 = Remote.New("ReplicaCreate")
local v17 = Remote.New("ReplicaBind")
local v18 = Remote.New("ReplicaDestroy")
local v19 = Remote.New("ReplicaSignalUnreliable", true)
local v20 = {}
local v21 = false

local function LoadWriteLib(moduleScript)
	local v22 = v20[moduleScript]

	if v22 ~= nil then
		return v22
	end

	local module = require(moduleScript)
	local v23 = {}

	for k, v24 in pairs(module) do
		table.insert(v23, { k, v24 })
	end

	table.sort(v23, function(a, b)
		return a[1] < b[1]
	end)
	local result = {}

	for i, v24 in ipairs(v23) do
		local v25 = {
			Name = v24[1],
			Id = i,
			fn = v24[2]
		}
		result[v24[1]] = v25
		result[i] = v25
	end

	v20[moduleScript] = result
	return result
end

local class = {}
class.__index = class
local thread = nil

local function AcquireRunnerThreadAndCallEventHandler(callback, ...)
	local v22 = thread
	thread = nil
	callback(...)
	thread = v22
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

function ConnectionNew(p, fn)
	local self = setmetatable({
		t = p,
		fn = fn
	}, class)
	p[self] = true
	return self
end

function ConnectionFire(p, ...)
	if not thread then
		thread = coroutine.create(RunEventHandlerInFreeThread)
	end

	task.spawn(thread, p.fn, ...)
end

function class.Disconnect(p)
	p.t[p] = nil
end

local ReplicaClient = {
	IsReady = false,
	OnLocalReady = Signal.New()
}
ReplicaClient.__index = ReplicaClient

local function ReplicaNew(id: number, self_creation)
	local write_lib

	if self_creation[5] ~= nil then
		write_lib = LoadWriteLib(self_creation[5])
	end

	local token = self_creation[1]
	local parent = bindReplicas[self_creation[4]] or replicas[self_creation[4]]
	local self = setmetatable({
		Tags = self_creation[2],
		Data = self_creation[3],
		Id = id,
		Token = token,
		Parent = parent,
		Children = {},
		BoundInstance = nil,
		OnClientEvent = Signal.New(),
		Maid = Maid.New(v),
		self_creation = self_creation,
		write_lib = write_lib,
		set_listeners = {},
		write_listeners = {},
		changed_listeners = {}
	}, ReplicaClient)

	if parent ~= nil then
		parent.Children[self] = true
	end

	return self
end

function ReplicaClient.RequestData()
	if v2 == true then
		return
	end

	v2 = true
	task.spawn(function()
		v8:FireServer()

		while task.wait(2) and ReplicaClient.IsReady ~= true do
			v8:FireServer()
		end
	end)
end

function ReplicaClient.OnNew(value: string, callback)
	if type(value) ~= "string" then
		error((`[{script.Name}]: "token" must be a string`))
	end

	local v22 = v7[value]

	if v22 == nil then
		v22 = {}
		v7[value] = v22
	end

	local v23 = tokenReplicas[value]
	local v24 = ConnectionNew(v22, callback)

	if v23 ~= nil then
		for k in pairs(v23) do
			ConnectionFire(v24, k)
		end
	end

	return v24
end

function ReplicaClient.FromId(p: number)
	return replicas[p]
end

function ReplicaClient.Test()
	return {
		TokenReplicas = tokenReplicas,
		Replicas = replicas,
		BindReplicas = bindReplicas,
		BindInstances = bindInstances
	}
end

function ReplicaClient.OnSet(p, list, callback)
	local joined = table.concat(list, ".")
	local set_listener = p.set_listeners[joined]

	if set_listener == nil then
		set_listener = {}
		p.set_listeners[joined] = set_listener
	end

	return ConnectionNew(set_listener, callback)
end

function ReplicaClient.OnWrite(p, p2: string, callback)
	local write_listener = p.write_listeners[p2]

	if write_listener == nil then
		write_listener = {}
		p.write_listeners[p2] = write_listener
	end

	return ConnectionNew(write_listener, callback)
end

function ReplicaClient.OnChange(p, callback)
	return ConnectionNew(p.changed_listeners, callback)
end

function ReplicaClient.GetChild(p, value: string)
	if type(value) ~= "string" then
		error((`[{script.Name}]: "token" must be a string`))
	end

	for k in pairs(p.Children) do
		if k.Token == value then
			return k
		end
	end

	return nil
end

function ReplicaClient:FireServer(...)
	v14:FireServer(self.Id, ...)
end

function ReplicaClient.UFireServer(p, ...)
	v19:FireServer(p.Id, ...)
end

function ReplicaClient:Identify()
	local v22 = ""
	local v23 = true

	for k, tag in pairs(self.Tags) do
		v22 ..= `{v23 == true and "" or ";"}{tostring(k)}={tostring(tag)}`
		v23 = false
	end

	return (`[Id:{self.Id};Token:{self.Token};Tags:\{{v22}}]`)
end

function ReplicaClient:IsActive()
	return self.Maid:IsActive()
end

function ReplicaClient.Set(data, list, p)
	if v21 ~= true then
		error((`[{script.Name}]: "Set()" can't be called outside of WriteLibs client-side`))
	end

	local data2 = data.Data

	for i = 1, #list - 1 do
		data2 = data2[list[i]]
	end

	local v22 = list[#list]
	local v23 = data2[v22]
	data2[v22] = p

	if next(data.set_listeners) ~= nil then
		local set_listener = data.set_listeners[table.concat(list, ".")]

		if set_listener ~= nil then
			for k in pairs(set_listener) do
				ConnectionFire(k, p, v23)
			end
		end
	end

	for k in pairs(data.changed_listeners) do
		ConnectionFire(k, "Set", list, p, v23)
	end
end

function ReplicaClient.SetValues(p, list, items)
	if v21 ~= true then
		error((`[{script.Name}]: "SetValues()" can't be called outside of WriteLibs client-side`))
	end

	local data = p.Data

	for _, v22 in ipairs(list) do
		data = data[v22]
	end

	for k, item in pairs(items) do
		data[k] = item
	end

	for k in pairs(p.changed_listeners) do
		ConnectionFire(k, "SetValues", list, items)
	end
end

function ReplicaClient.TableInsert(p, list, p2, p3: number?)
	if v21 ~= true then
		error((`[{script.Name}]: "TableInsert()" can't be called outside of WriteLibs client-side`))
	end

	local data = p.Data

	for _, v22 in ipairs(list) do
		data = data[v22]
	end

	if p3 == nil then
		table.insert(data, p2)
		p3 = #data
	else
		table.insert(data, p3, p2)
	end

	for k in pairs(p.changed_listeners) do
		ConnectionFire(k, "TableInsert", list, p2, p3)
	end

	return p3
end

function ReplicaClient.TableRemove(p, list, p2: number)
	if v21 ~= true then
		error((`[{script.Name}]: "TableRemove()" can't be called outside of WriteLibs client-side`))
	end

	local data = p.Data

	for _, v22 in ipairs(list) do
		data = data[v22]
	end

	local v22 = table.remove(data, p2)

	for k in pairs(p.changed_listeners) do
		ConnectionFire(k, "TableRemove", list, v22, p2)
	end

	return v22
end

function ReplicaClient.Write(p, p2: string, ...)
	if v21 ~= true then
		error((`[{script.Name}]: "Write()" can't be called outside of WriteLibs client-side`))
	end

	local v22 = p.write_lib[p2]
	local v23 = table.pack(v22.fn(p, ...))
	local write_listener = p.write_listeners[p2]

	if write_listener ~= nil then
		for k in pairs(write_listener) do
			ConnectionFire(k, ...)
		end
	end

	return table.unpack(v23)
end

local DestroyReplica

DestroyReplica = function(state, p)
	for _, v22 in ipairs(state.Children) do
		DestroyReplica(v22, true)
	end

	if p ~= true and state.Parent ~= nil then
		state.Parent.Children[state] = nil
	end

	local id = state.Id
	local v22 = tokenReplicas[state.Token]

	if v22 ~= nil then
		v22[state] = nil
	end

	if replicas[id] == state then
		replicas[id] = nil
	end

	if bindReplicas[id] == state then
		bindReplicas[id] = nil
	end

	state.Maid:Unlock(v)
	state.Maid:Cleanup()
	state.BoundInstance = nil
end

local ReplicaToBindBuffer

ReplicaToBindBuffer = function(data, p)
	local replica2 = ReplicaNew(data.Id, data.self_creation)
	bindReplicas[data.Id] = replica2

	for k in pairs(data.Children) do
		ReplicaToBindBuffer(k, true)
	end

	if p ~= true then
		DestroyReplica(data)
	end

	return replica2
end

local ReplicaFromBindBuffer

ReplicaFromBindBuffer = function(data, list)
	local v22

	if list == nil then
		list = {}
		v22 = true
	else
		v22 = false
	end

	bindReplicas[data.Id] = nil
	local token = data.Token
	local v23 = tokenReplicas[token]

	if v23 == nil then
		v23 = {}
		tokenReplicas[token] = v23
	end

	v23[data] = true
	replicas[data.Id] = data
	table.insert(list, data)

	for k in pairs(data.Children) do
		ReplicaFromBindBuffer(k, list)
	end

	if v22 == true then
		for _, v24 in ipairs(list) do
			local v25 = v7[v24.Token]

			if v25 == nil then
				continue
			end

			for k in pairs(v25) do
				ConnectionFire(k, v24)
			end
		end
	end
end

local CreationScan

CreationScan = function(p, callback, id)
	local v22 = p[id]

	if v22 ~= nil then
		table.sort(v22, function(a, b)
			return a.Id < b.Id
		end)

		for _, v23 in ipairs(v22) do
			callback(v23.Id, v23.SelfCreation)
			CreationScan(p, callback, v23.Id)
		end
	end
end

local function BreadthCreationSort(list, p: number?, fn)
	local v22 = {}
	local v23 = {}
	local v24 = {}

	if type(list[1]) == "table" then
		for _, v25 in ipairs(list) do
			for k, selfCreation in pairs(v25) do
				local v27 = {
					Id = tonumber(k),
					SelfCreation = selfCreation
				}
				local v28 = selfCreation[4]

				if v28 == 0 or v27.Id == p then
					table.insert(v22, v27)
				elseif v25[tostring(v28)] == nil then
					table.insert(v24, v27)
				else
					local v29 = v23[v28]

					if v29 == nil then
						v29 = {}
						v23[v28] = v29
					end

					table.insert(v29, v27)
				end
			end
		end
	else
		for k, selfCreation in pairs(list) do
			local v26 = {
				Id = tonumber(k),
				SelfCreation = selfCreation
			}
			local v27 = selfCreation[4]

			if v27 == 0 or v26.Id == p then
				table.insert(v22, v26)
			elseif list[tostring(v27)] == nil then
				table.insert(v24, v26)
			else
				local v28 = v23[v27]

				if v28 == nil then
					v28 = {}
					v23[v27] = v28
				end

				table.insert(v28, v26)
			end
		end
	end

	table.sort(v22, function(a, b)
		return a.Id < b.Id
	end)
	local v25 = {}

	for _, v26 in ipairs(v22) do
		fn(v26.Id, v26.SelfCreation)
		CreationScan(v23, fn, v26.Id)
	end

	if #v24 == 0 then
		return v25
	end

	local formatted = `[{script.Name}]: GROUP REPLICATION ERROR - Missing parents for:\n`

	for i = 1, math.min(#v24, 50) do
		local v26 = v24[i]
		local selfCreation = v26.SelfCreation
		local v27 = ""
		local v28 = true

		for k, v29 in pairs(selfCreation[2]) do
			v27 ..= `{v28 == true and "" or ";"}{tostring(k)}={tostring(v29)}`
			v28 = false
		end

		formatted ..= `[Id:{v26.Id};ParentId:{selfCreation[4]};Token:{selfCreation[1]};Tags:\{{v27}}]\n`
	end

	if #v24 > 50 then
		formatted ..= `(hiding {50 - #v24} more)\n`
	end

	local v26 = formatted .. "Traceback:\n" .. debug.traceback()
	warn(v26)
	return v25
end

local function GetInternalReplica(p)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	return v22
end

v8.OnClientEvent:Connect(function()
	if ReplicaClient.IsReady == true then
		return
	end

	ReplicaClient.IsReady = true
	ReplicaClient.OnLocalReady:Fire()
end)
v9.OnClientEvent:Connect(function(p: number, p2, p3)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	v21 = true
	local success, result = pcall(v22.Set, v22, p2, p3)
	v21 = false

	if success ~= true then
		error(`[{script.Name}]: Error while updating replica:\n{v22:Identify()}\n` .. result)
	end
end)
v10.OnClientEvent:Connect(function(p: number, p2, p3)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	v21 = true
	local success, result = pcall(v22.SetValues, v22, p2, p3)
	v21 = false

	if success ~= true then
		error(`[{script.Name}]: Error while updating replica:\n{v22:Identify()}\n` .. result)
	end
end)
v11.OnClientEvent:Connect(function(p: number, p2, p3, p4: number?)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	v21 = true
	local success, result = pcall(v22.TableInsert, v22, p2, p3, p4)
	v21 = false

	if success ~= true then
		error(`[{script.Name}]: Error while updating replica:\n{v22:Identify()}\n` .. result)
	end
end)
v12.OnClientEvent:Connect(function(p: number, p2, p3: number)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	v21 = true
	local success, result = pcall(v22.TableRemove, v22, p2, p3)
	v21 = false

	if success ~= true then
		error(`[{script.Name}]: Error while updating replica:\n{v22:Identify()}\n` .. result)
	end
end)
v13.OnClientEvent:Connect(function(p: number, p2: number, ...)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	local name = v22.write_lib[p2].Name
	v21 = true
	local success, result = pcall(v22.Write, v22, name, ...)
	v21 = false

	if success ~= true then
		error(`[{script.Name}]: Error while updating replica:\n{v22:Identify()}\n` .. result)
	end
end)

local function RemoteSignalHandle(p: number, ...)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	v22.OnClientEvent:Fire(...)
end

v14.OnClientEvent:Connect(RemoteSignalHandle)
v19.OnClientEvent:Connect(RemoteSignalHandle)
v15.OnClientEvent:Connect(function(p: number, p2: number)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	local parent = v22.Parent
	local parent2 = replicas[p2] or bindReplicas[p2]

	if parent2 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p2}]`))
	end

	parent.Children[v22] = nil
	parent2.Children[v22] = true
	v22.Parent = parent2
	v22.self_creation[4] = p2

	if bindReplicas[parent.Id] ~= nil and replicas[p2] ~= nil then
		ReplicaFromBindBuffer(v22)
	elseif replicas[parent.Id] ~= nil and bindReplicas[p2] ~= nil then
		ReplicaToBindBuffer(v22)
	end
end)
v16.OnClientEvent:Connect(function(p, p2: number?)
	local v22 = {}
	BreadthCreationSort(p, p2, function(id: number, self_creation)
		local v23 = self_creation[4]
		local replica2 = ReplicaNew(id, self_creation)
		local v25 = false

		if v23 == 0 then
			if replica2.Tags.Bind == true then
				local boundInstance = bindInstances[id]
				replica2.BoundInstance = boundInstance
				v25 = boundInstance == nil or false
			end
		else
			v25 = bindReplicas[v23] ~= nil or false
		end

		if v25 == true then
			bindReplicas[id] = replica2
			return
		end

		local token = replica2.Token
		local v26 = tokenReplicas[token]

		if v26 == nil then
			v26 = {}
			tokenReplicas[token] = v26
		end

		v26[replica2] = true
		replicas[id] = replica2
		table.insert(v22, replica2)
	end)

	for _, v23 in ipairs(v22) do
		local v24 = v7[v23.Token]

		if v24 == nil then
			continue
		end

		for k in pairs(v24) do
			ConnectionFire(k, v23)
		end
	end
end)
v17.OnClientEvent:Connect(function(p: number)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	v22.Tags.Bind = true
	local boundInstance = bindInstances[p]
	v22.BoundInstance = boundInstance

	if boundInstance == nil then
		ReplicaToBindBuffer(v22)
	end
end)
v18.OnClientEvent:Connect(function(p: number)
	local v22 = replicas[p] or bindReplicas[p]

	if v22 == nil then
		error((`[{script.Name}]: Received update for missing replica [Id:{p}]`))
	end

	DestroyReplica(v22)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function OnBindInstanceAdded(numberValue)
	local value = numberValue.Value
	local parent = numberValue.Parent
	bindInstances[value] = parent
	local v22 = bindReplicas[value]

	if v22 ~= nil then
		v22.BoundInstance = parent
		ReplicaFromBindBuffer(v22)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnBindInstanceRemoved(numberValue)
	local value = numberValue.Value
	bindInstances[value] = nil
	local v22 = replicas[value]

	if v22 ~= nil then
		ReplicaToBindBuffer(v22)
	end
end

CollectionService:GetInstanceAddedSignal("REPLICA"):Connect(function(numberValue)
	if numberValue:IsA("NumberValue") == true then
		OnBindInstanceAdded(numberValue) -- equivalent call inferred; original call site unknown
	end
end)
CollectionService:GetInstanceRemovedSignal("REPLICA"):Connect(function(numberValue)
	if numberValue:IsA("NumberValue") == true then
		OnBindInstanceRemoved(numberValue) -- equivalent call inferred; original call site unknown
	end
end)

for _, numberValue in pairs(CollectionService:GetTagged("REPLICA")) do
	if numberValue:IsA("NumberValue") ~= true then
		continue
	end

	OnBindInstanceAdded(numberValue) -- equivalent call inferred; original call site unknown
end

return ReplicaClient