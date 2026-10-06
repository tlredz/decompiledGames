local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsClient() then
	return require(script.Parent.Client)
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
local v6 = {}
local ID = 1
local DataContainer = {}
local DeepCopy

DeepCopy = function(items, options)
	local v8 = options or {}

	if v8[items] then
		return v8[items]
	end

	local result = {}
	v8[items] = result

	for k, item in pairs(items) do
		if type(item) == "table" then
			result[k] = DeepCopy(item, v8)
		else
			result[k] = item
		end
	end

	local metatable = getmetatable(items)

	if metatable then
		setmetatable(result, metatable)
	end

	return result
end

local function CreateLazyState(k)
	local data = k.Data
	local v8 = {}
	local v9 = {}
	setmetatable(v9, {
		__index = function(p, p2)
			if p ~= v9 then
				error("[DATA CONTAINER]: LazyCopy state was cloned - this isn't allowed", 0)
			end

			if v8[p2] then
				return nil
			end

			local selected = data[p2]

			if selected == nil then
				return nil
			end

			if typeof(selected) == "table" then
				selected = DeepCopy(selected)
			end

			v8[p2] = true
			rawset(v9, p2, selected)
			return selected
		end,
		__newindex = function(p, p2, p3)
			if p ~= v9 then
				error("[DATA CONTAINER]: LazyCopy state was cloned - this isn't allowed", 0)
			end

			v8[p2] = true
			rawset(v9, p2, p3)
		end,
		__iter = function()
			error("[DATA CONTAINER]: Transaction TransformFunction iterated a LazyCopy state - this isn't allowed", 0)
		end
	})
	return v9, v8
end

local function IsMergeable(items, items2)
	if rawlen(items) > 0 or rawlen(items2) > 0 then
		return true
	end

	local count = 0

	for _, item in items2 do
		count += 1

		if count > 8 or typeof(item) == "table" then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EncodeValue(p)
	if p == nil then
		return "nil"
	elseif p == true then
		return "true"
	elseif p == false then
		return "false"
	end

	return p
end

local function TrimPath(common, list)
	local v8 = math.min(#common, #list)

	for i = 1, v8 do
		if common[i] == list[i] then
			continue
		end

		v8 = i - 1
		break
	end

	for i = #common, v8 + 1, -1 do
		common[i] = nil
	end
end

local function AddChange(state, list, items)
	if state.Common then
		TrimPath(state.Common, list)
	else
		state.Common = table.clone(list)
	end

	if #state.Changes >= 64 then
		state.Overflow = true
	else
		table.insert(state.Changes, { table.clone(list), EncodeValue(items) })
	end
end

local CollectChanges

CollectChanges = function(items, items2, list, p)
	if items == items2 then
		return
	end

	if typeof(items) ~= "table" or typeof(items2) ~= "table" then
		AddChange(p, list, items2)
		return
	end

	local count = #p.Changes
	local v8 = #list + 1

	for k, item in items2 do
		list[v8] = k
		CollectChanges(items[k], item, list, p)
	end

	for k, item in items do
		if items2[k] ~= nil then
			continue
		end

		list[v8] = k
		CollectChanges(item, nil, list, p)
	end

	list[v8] = nil

	if p.Overflow or #p.Changes - count < 2 or not IsMergeable(items, items2) then
		return
	end

	for i = #p.Changes, count + 1, -1 do
		p.Changes[i] = nil
	end

	AddChange(p, list, items2)
end

local function GetChild(p, list)
	for i = 2, #list do
		if typeof(p) ~= "table" then
			return nil
		end

		p = p[list[i]]
	end

	return p
end

local function FormatPath(list)
	local v8 = table.create(#list)

	for i = 1, #list do
		v8[i] = tostring(list[i])
	end

	return table.concat(v8, ".")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SerializeArguments(values)
	for i = 1, values.n do
		values[i] = Serializer.Serialize(values[i])
	end
end

local function NoYieldResultHandler(thread: thread, flag: boolean, ...)
	if not flag then
		error(..., 0)
	end

	if coroutine.status(thread) ~= "dead" then
		error("[DATA CONTAINER]: Transaction TransformFunction attempted to yield - this isn't allowed", 0)
	end

	return ...
end

local function CallWithNoYield(callback, ...)
	local thread = coroutine.create(callback)
	return NoYieldResultHandler(thread, coroutine.resume(thread, ...))
end

function DataContainer.New(data)
	if not data or typeof(data) ~= "table" then
		warn("[DATA CONTAINER]: ContainerSettings is nil or not a table")
		return
	end

	if not data.Name or typeof(data.Name) ~= "string" then
		warn("[DATA CONTAINER]: Name is nil or not a string")
		return
	end

	if not data.Data or typeof(data.Data) ~= "table" then
		warn("[DATA CONTAINER]: Data is nil or not a table")
		return
	end

	local v8 = {
		ID = ID,
		Global = data.Global == true,
		LastUpdateTime = 0,
		PendingUpdates = {},
		CancelSerialization = data.CancelSerialization == true,
		DeferUpdates = data.DeferUpdates == true,
		UpdateCooldown = 0,
		Name = 0,
		Data = 0,
		Tags = 0,
		Listeners = 0,
		ResyncTimes = 0
	}
	local updateCooldown

	if not (data.DeferUpdates == true or typeof(data.UpdateCooldown) ~= "number") then
		updateCooldown = data.UpdateCooldown
	end

	v8.UpdateCooldown = updateCooldown
	v8.Name = data.Name
	v8.Data = data.Data
	v8.Tags = {}
	v8.Listeners = {}
	v8.ResyncTimes = {}
	local object = setmetatable(v8, {
		__index = v4
	})

	if data.Tags and typeof(data.Tags) == "table" then
		for _, tag in data.Tags do
			if tag and typeof(tag) == "string" then
				object.Tags[tag] = true
			end
		end
	end

	if object.UpdateCooldown then
		object.ChangeConnection = RunService.Heartbeat:Connect(function()
			if not (object.Data and #object.PendingUpdates ~= 0) then
				return
			end

			local now = tick()

			if now - object.LastUpdateTime < object.UpdateCooldown then
				return
			end

			object.LastUpdateTime = now
			DataContainer.FlushAll()
			object:Flush()
		end)
	end

	v3[ID] = object
	ID += 1
	return object
end

function DataContainer.GetAvailableContainersForPlayer(player)
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[DATA CONTAINER]: Player is nil or not an instance of Player")
		return
	end

	local result = {}

	for _, v8 in v3 do
		if v8.Global or v8.Listeners[tostring(player.UserId)] then
			table.insert(result, v8)
		end
	end

	return result
end

function DataContainer.GetByTag(value: string, flag: boolean?)
	if not value or typeof(value) ~= "string" then
		warn("[DATA CONTAINER]: Tag is nil or not a string")
		return
	end

	for _, v8 in v3 do
		if v8.Tags[value] then
			return v8
		end
	end

	if not flag then
		return nil
	end

	local v8 = nil

	while true do
		for _, v10 in v3 do
			if not v10.Tags[value] then
				continue
			end

			v8 = v10
			break
		end

		task.wait()

		if v8 ~= nil then
			return v8
		end
	end
end

function DataContainer.Transaction(list, callback, flag: boolean?)
	if typeof(list) ~= "table" or #list == 0 then
		return "Failed", "Containers must be a non-empty array"
	end

	if typeof(callback) ~= "function" then
		return "Failed", "TransformFunction must be a function"
	end

	local v8 = {}

	for _, v9 in list do
		if typeof(v9) ~= "table" or v3[v9.ID] ~= v9 then
			return "Failed", "Invalid Container in Transaction call"
		end

		if v8[v9] then
			return "Failed", "Duplicate Container in Transaction call"
		end

		if table.isfrozen(v9.Data) then
			return "Failed", "Container data is frozen"
		end

		if v9._TransactionLocked then
			return "Failed", "Container is already locked by another Transaction"
		else
			v8[v9] = true
		end
	end

	for k in v8 do
		k._TransactionLocked = true
	end

	local success, result = pcall(function()
		local data = {}
		local v9 = {}
		local v10 = {}

		for k in v8 do
			data[k] = k.Data

			if flag then
				local v11, v12 = CreateLazyState(k)
				v9[k] = v11
				v10[k] = v12
			else
				v9[k] = DeepCopy(k.Data)
			end
		end

		local callWithNoYield = CallWithNoYield(callback, v9)

		if typeof(callWithNoYield) ~= "boolean" then
			error("[DATA CONTAINER]: Transaction TransformFunction must return a boolean", 0)
		end

		if callWithNoYield == false then
			return false
		end

		for k, v12 in v9 do
			local v13 = data[k]

			for k2 in v10[k] or v13 do
				if v13[k2] ~= nil and rawget(v12, k2) == nil then
					error(
						`[DATA CONTAINER]: Transaction TransformFunction removed key "{tostring(k2)}" - this isn't allowed`,
						0
					)
				end
			end

			for k2 in next, v12, nil do
				if v13[k2] == nil then
					error(
						`[DATA CONTAINER]: Transaction TransformFunction added key "{tostring(k2)}" - this isn't allowed`,
						0
					)
				end
			end
		end

		local v12 = {}

		for k, v13 in v9 do
			local v14 = data[k]
			local values = {}
			local updates = {}

			for k2, v17 in next, v13, nil do
				local v18 = {
					Changes = {},
					Overflow = false
				}
				CollectChanges(v14[k2], v17, { k2 }, v18)

				if not v18.Common then
					continue
				end

				values[k2] = v17

				if v18.Overflow then
					local common = v18.Common
					local common2 = v18.Common
					local v19 = {}

					for i = 2, #common2 do
						if typeof(v17) == "table" then
							v17 = v17[common2[i]]
						else
							v17 = nil
							break
						end
					end

					v19[1], v19[2] = common, EncodeValue(v17)
					table.insert(updates, v19)
				else
					table.move(v18.Changes, 1, #v18.Changes, #updates + 1, updates)
				end
			end

			v12[k] = {
				Values = values,
				Updates = updates
			}
		end

		for k, v13 in v12 do
			for k2, value in v13.Values do
				k.Data[k2] = value
			end
		end

		for k, v13 in v12 do
			if #v13.Updates == 0 then
				continue
			end

			local success2, result2 = pcall(k._ReplicateChanges, k, v13.Updates)

			if success2 then
				continue
			end

			warn((`[DATA CONTAINER]: Committed data replication failed: {result2}`))
			local v14 = k
			local v15 = v13
			task.defer(function()
				for i = 1, 3 do
					if v3[v14.ID] ~= v14 then
						break
					end

					local flag2 = true

					for k2 in v15.Values do
						if pcall(v14.SetValue, v14, { k2 }, v14.Data[k2], true) then
							continue
						end

						flag2 = false
					end

					if flag2 then
						break
					else
						task.wait(i)
					end
				end
			end)
		end

		return true
	end)

	for k in v8 do
		k._TransactionLocked = nil
	end

	if not success then
		return "Failed", (tostring(result))
	end

	if result == false then
		return "Aborted"
	end

	return "Success"
end

function DataContainer.FlushAll()
	for k in v6 do
		k:Flush()
	end
end

function DataContainer.FlushPlayer(player)
	if not next(v6) then
		return
	end

	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[DATA CONTAINER]: Player is nil or not an instance of Player")
		return
	end

	local userId = tostring(player.UserId)

	for k in v6 do
		if k.Global or k.Listeners[userId] then
			k:Flush()
		end
	end
end

function v4:_Send(...)
	self.SerializedData = nil
	local v8 = table.pack(...)
	local v9

	if self.CancelSerialization then
		v9 = v2
	else
		v9 = v
	end

	local cancelSerialization = self.CancelSerialization

	if self.Global then
		for _, v10 in v5 do
			if not cancelSerialization then
				SerializeArguments(v8) -- equivalent call inferred; original call site unknown
				cancelSerialization = true
			end

			v9:Fire(v10, table.unpack(v8, 1, v8.n))
		end
	else
		for k, _ in self.Listeners do
			local playerByUserId = Players:GetPlayerByUserId((tonumber(k)))

			if playerByUserId then
				if not cancelSerialization then
					SerializeArguments(v8) -- equivalent call inferred; original call site unknown
					cancelSerialization = true
				end

				v9:Fire(playerByUserId, table.unpack(v8, 1, v8.n))
			else
				self.Listeners[k] = nil
			end
		end
	end
end

function v4:_Replicate(...)
	DataContainer.FlushAll()
	self:_Send(...)
end

function v4:_AddPendingUpdate(list, p, flag: boolean?)
	self.SerializedData = nil

	if self.Destroyed then
		return
	end

	if typeof(p) == "table" then
		p = DeepCopy(p)
	end

	if self.UpdateCooldown and not flag then
		for i = #self.PendingUpdates, 1, -1 do
			local v8 = self.PendingUpdates[i][1]
			local v9 = #v8 >= #list

			for i2 = 1, #list do
				if v8[i2] == list[i2] then
					continue
				end

				v9 = false
				break
			end

			if v9 then
				table.remove(self.PendingUpdates, i)
			end
		end
	end

	table.insert(self.PendingUpdates, { table.clone(list), p, flag and true or nil })

	if self.DeferUpdates and not self.FlushScheduled then
		self.FlushScheduled = true
		v6[self] = true
		task.defer(self.Flush, self)
	end
end

function v4:_ReplicateChanges(items)
	if not self.UpdateCooldown then
		self:_Replicate("Commit", self.Name, items)
		return
	end

	for _, item in items do
		self:_AddPendingUpdate(item[1], item[2])
	end
end

function v4:_SendKey(p, p2: string)
	if v3[self.ID] ~= self or not self.Listeners[tostring(p.UserId)] then
		return
	end

	local v8 = self.Data[p2]

	if v8 == nil then
		return
	end

	DataContainer.FlushAll()
	local v9

	if self.CancelSerialization then
		v9 = v2
	else
		v9 = v
	end

	v9:Fire(p, "SetValue", self.Name, { p2 }, EncodeValue(v8))
end

function v4:_Resync(p, p2: string)
	local userId = tostring(p.UserId)
	local now = os.clock()
	local resyncTime = self.ResyncTimes[userId]

	if not resyncTime then
		resyncTime = {}
		self.ResyncTimes[userId] = resyncTime
	end

	local v8 = resyncTime[p2]

	if v8 and not (now - v8 >= 5) then
		if now < v8 then
			return
		end

		local v9 = v8 + 5
		resyncTime[p2] = v9
		task.delay(v9 - now, function()
			if self.ResyncTimes[userId] ~= resyncTime then
				return
			end

			self:_SendKey(p, p2)
		end)
	else
		resyncTime[p2] = now
		self:_SendKey(p, p2)
	end
end

function v4:Flush()
	v6[self] = nil
	self.FlushScheduled = nil

	if #self.PendingUpdates == 0 then
		return
	end

	local pendingUpdates = self.PendingUpdates
	self.PendingUpdates = {}

	if self.Destroyed or pcall(self._Send, self, "BulkUpdate", self.Name, pendingUpdates) then
		return
	end

	for _, pendingUpdate in pendingUpdates do
		local success, result = pcall(self._Send, self, "BulkUpdate", self.Name, { pendingUpdate })

		if not success then
			warn((`[DATA CONTAINER]: Update replication failed for {self.Name} at {FormatPath(pendingUpdate[1])}: {result}`))
		end
	end
end

function v4:AddListener(player)
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[DATA CONTAINER]: Player is nil or not an instance of Player")
		return
	end

	self:Flush()
	self.Listeners[tostring(player.UserId)] = true
	v:Fire(player, "SendData", self.ID, self.Name, self.Data)
end

function v4:RemoveListener(player)
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[DATA CONTAINER]: Player is nil or not an instance of Player")
		return
	end

	self:Flush()
	local userId = tostring(player.UserId)
	self.Listeners[userId] = nil
	self.ResyncTimes[userId] = nil
	v:Fire(player, "DestroyContainer", self.Name)
end

function v4.GetValue(p, list)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return
	end

	local data = p.Data

	for i = 1, #list - 1 do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if data then
		return data[list[#list]]
	end
end

function v4:SetValue(list, p, flag: boolean?)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	local data = self.Data

	for i = 1, #list - 1 do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

	local v8 = list[#list]

	if not flag and typeof(p) ~= "table" and data[v8] == p then
		return true
	end

	data[v8] = p
	local encodeValue = EncodeValue(p) -- equivalent call inferred; original call site unknown

	if self.UpdateCooldown or self.DeferUpdates and not flag then
		self:_AddPendingUpdate(list, encodeValue)
	else
		self:_Replicate("SetValue", self.Name, list, encodeValue)
	end

	return true
end

function v4:InsertValue(list, p)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	if p == nil then
		warn("[DATA CONTAINER]: You can't insert a nil value into an array!")
		return false
	end

	local data = self.Data

	for i = 1, #list do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

	if next(data) and #data == 0 then
		warn("[DATA CONTAINER]: Pointer isn't an array!")
		return false
	end

	local v8 = nil

	for i = 1, #data + 1 do
		if data[i] then
			continue
		end

		v8 = i
		break
	end

	if not v8 then
		return false
	end

	data[v8] = p
	list[#list + 1] = v8
	local v9 = p == true and "true" or p == false and "false" or p

	if self.UpdateCooldown or self.DeferUpdates then
		self:_AddPendingUpdate(list, v9)
	else
		self:_Replicate("SetValue", self.Name, list, v9)
	end

	return true
end

function v4:RemoveValue(list, p)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	if p == nil then
		warn("[DATA CONTAINER]: You can't insert a nil value into an array!")
		return false
	end

	local data = self.Data

	for i = 1, #list do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

	if next(data) and #data == 0 then
		warn("[DATA CONTAINER]: Pointer isn't an array!")
		return false
	end

	local index = table.find(data, p)

	if not index then
		return false
	end

	table.remove(data, index)

	if self.UpdateCooldown or self.DeferUpdates then
		self:_AddPendingUpdate(list, data)
	else
		self:_Replicate("SetValue", self.Name, list, data)
	end

	return true
end

function v4:RemoveIndex(list, value: number)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	if typeof(value) ~= "number" then
		warn("[DATA CONTAINER]: Index is not a number")
		return false
	end

	local data = self.Data

	for i = 1, #list do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

	if next(data) and #data == 0 then
		warn("[DATA CONTAINER]: Pointer isn't an array!")
		return false
	end

	table.remove(data, value)

	if self.UpdateCooldown or self.DeferUpdates then
		self:_AddPendingUpdate(list, data)
	else
		self:_Replicate("SetValue", self.Name, list, data)
	end

	return true
end

function v4:ClearValue(list)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	local data = self.Data

	for i = 1, #list do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

	table.clear(data)

	if self.UpdateCooldown or self.DeferUpdates then
		self:_AddPendingUpdate(list, data)
	else
		self:_Replicate("SetValue", self.Name, list, data)
	end

	return true
end

function v4:SetValues(list, items)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	local data = self.Data

	for i = 1, #list do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

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

	if self.UpdateCooldown or self.DeferUpdates then
		self:_AddPendingUpdate(list, items, true)
	else
		self:_Replicate("SetValues", self.Name, list, items)
	end

	return true
end

function v4:IncrementValue(list, total: number)
	if not list or typeof(list) ~= "table" then
		warn("[DATA CONTAINER]: Path is nil or not a table")
		return false
	end

	local data = self.Data

	for i = 1, #list - 1 do
		if not data then
			break
		end

		local v8 = list[i]

		if not v8 then
			break
		end

		if typeof(data) == "table" then
			data = data[v8]
		else
			data = nil
			break
		end
	end

	if not data then
		return false
	end

	if data[list[#list]] ~= nil then
		if typeof(data[list[#list]]) ~= "number" then
			return false
		end

		total = data[list[#list]] + total
	end

	if total == data[list[#list]] then
		return true
	end

	data[list[#list]] = total

	if self.UpdateCooldown or self.DeferUpdates then
		self:_AddPendingUpdate(list, total)
	else
		self:_Replicate("SetValue", self.Name, list, total)
	end

	return true
end

function v4:Destroy()
	if self.Destroyed then
		return
	end

	self:Flush()
	self.Destroyed = true
	self.SerializedData = nil
	v6[self] = nil

	if self.ChangeConnection then
		self.ChangeConnection:Disconnect()
		self.ChangeConnection = nil
	end

	self:_Replicate("DestroyContainer", self.Name)
	v3[self.ID] = nil
end

local function RemoteInterpreter(p, p2: string, ...)
	local v8 = { ... }

	if p2 == "RequestData" then
		local v9 = v8[1]

		if not v9 or typeof(v9) ~= "string" then
			return
		end

		local availableContainersForPlayer = DataContainer.GetAvailableContainersForPlayer(p)

		if not availableContainersForPlayer then
			return
		end

		local v10 = nil

		for _, v11 in availableContainersForPlayer do
			if v11.Name ~= v9 then
				continue
			end

			if v10 then
				warn((`[DATA CONTAINER]: Multiple containers with the same name found for player: {p.Name} - {p.UserId}`))
				return
			else
				v10 = v11
			end
		end

		if not v10 then
			return
		end

		v5[tostring(p.UserId)] = p

		if v10.DeferUpdates then
			v10:Flush()
		end

		if v10.CancelSerialization then
			v2:Fire(p, "SendData", v10.ID, v10.Name, v10.Data)
			return
		end

		if not v10.Global then
			v:Fire(p, "SendData", v10.ID, v10.Name, v10.Data)
			return
		end

		v10.SerializedData = v10.SerializedData or Serializer.Serialize(v10.Data)
		v:Fire(p, "SendData", v10.ID, v10.Name, v10.SerializedData)
	elseif p2 == "Resync" then
		local v9 = v8[1]
		local v10 = v8[2]

		if not v9 or typeof(v9) ~= "string" or (not v10 or typeof(v10) ~= "string") then
			return
		end

		local userId = tostring(p.UserId)
		local v11 = nil

		for _, v12 in v3 do
			if v12.Global or v12.Name ~= v9 or not v12.Listeners[userId] then
				continue
			end

			if v11 then
				warn((`[DATA CONTAINER]: Multiple containers with the same name found for player: {p.Name} - {p.UserId}`))
				return
			else
				v11 = v12
			end
		end

		if not v11 then
			return
		end

		if v11.Data[v10] == nil then
			return
		else
			v11:_Resync(p, v10)
		end
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
Players.PlayerRemoving:Connect(function(player)
	local userId = tostring(player.UserId)

	for _, v8 in v3 do
		v8.Listeners[userId] = nil
		v8.ResyncTimes[userId] = nil
	end

	v5[userId] = nil
end)
return DataContainer