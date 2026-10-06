local v = 300
local v2 = 10
local v3 = 5
local v4 = 40
local v5 = 630
local v6 = 120
local v7 = 5
local v8 = 120
local v9 = 120
local v10 = 1000
local thread = nil

local function AcquireRunnerThreadAndCallEventHandler(callback, ...)
	local v11 = thread
	thread = nil
	callback(...)
	thread = v11
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class:Disconnect()
	if self.is_connected == false then
		return
	end

	local signal = self.signal
	self.is_connected = false
	signal.listener_count -= 1

	if signal.head == self then
		signal.head = self.next
		return
	end

	local head = signal.head

	while head ~= nil and head.next ~= self do
		head = head.next
	end

	if head ~= nil then
		head.next = self.next
	end
end

function class2.New()
	local v11 = {
		head = nil,
		listener_count = 0
	}
	setmetatable(v11, class2)
	return v11
end

function class2:Connect(listener)
	if type(listener) ~= "function" then
		error((`[{script.Name}]: "listener" must be a function; Received {typeof(listener)}`))
	end

	local head = {
		listener = listener,
		signal = self,
		next = self.head,
		is_connected = true
	}
	setmetatable(head, class)
	self.head = head
	self.listener_count += 1
	return head
end

function class2.GetListenerCount(p)
	return p.listener_count
end

function class2:Fire(...)
	local head = self.head

	while head ~= nil do
		if head.is_connected == true then
			if not thread then
				thread = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(thread, head.listener, ...)
		end

		head = head.next
	end
end

function class2:Wait()
	local thread2 = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread2, ...)
	end)
	return coroutine.yield()
end

local frozen = table.freeze({
	New = class2.New
})
local activeSessionCheck = {}
local autoSaveList = {}
local nows = {}
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local placeId = game.PlaceId
local jobId = game.JobId
local v13 = 1
local now = os.clock()
local count = 0
local activeProfileLoadJobs = 0
local activeProfileSaveJobs = 0
local now2 = 0
local isStudio = RunService:IsStudio()
local v16 = "NotReady"
local mockStore = {}
local userMockStore = {}
local v19 = false
local onError = frozen.New()
local onOverwrite = frozen.New()
local updateQueue = {}

local function WaitInUpdateQueue(p)
	local v23

	if updateQueue[p] == nil then
		updateQueue[p] = {}
		v23 = true
	else
		v23 = false
	end

	local threads = updateQueue[p]

	if v23 == false then
		table.insert(threads, coroutine.running())
		coroutine.yield()
	end

	return function()
		local v24 = table.remove(threads, 1)

		if v24 == nil then
			updateQueue[p] = nil
		else
			coroutine.resume(v24)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SessionToken(name, value, p)
	return (p == true and "U_" or v16 ~= "Access" and "M_" or "L_") .. name .. "\0" .. value
end

local DeepCopyTable

DeepCopyTable = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			result[k] = DeepCopyTable(item)
		else
			result[k] = item
		end
	end

	return result
end

local ReconcileTable

ReconcileTable = function(p, items)
	for k, item in pairs(items) do
		if type(k) ~= "string" then
			continue
		end

		if p[k] == nil then
			if type(item) == "table" then
				p[k] = DeepCopyTable(item)
			else
				p[k] = item
			end
		elseif type(p[k]) == "table" and type(item) == "table" then
			ReconcileTable(p[k], item)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RegisterError(p, name, p2)
	warn((`[{script.Name}]: DataStore API error (STORE:{name}; KEY:{p2}) - {tostring(p)}`))
	table.insert(nows, os.clock())
	onError:Fire(tostring(p), name, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RegisterOverwrite(name, p)
	warn((`[{script.Name}]: Invalid profile was overwritten (STORE:{name}; KEY:{p})`))
	onOverwrite:Fire(name, p)
end

local function NewMockDataStoreKeyInfo(data)
	local versionId = tostring(data.VersionId or 0)
	local metaData = data.MetaData or {}
	local userIds = data.UserIds or {}
	return {
		CreatedTime = data.CreatedTime,
		UpdatedTime = data.UpdatedTime,
		Version = string.rep("0", 16) .. "." .. string.rep("0", 10 - string.len(versionId)) .. versionId .. "." .. string.rep(
			"0",
			16
		) .. ".01",
		GetMetadata = function()
			return (DeepCopyTable(metaData))
		end,
		GetUserIds = function()
			return (DeepCopyTable(userIds))
		end
	}
end

local function MockUpdateAsync(p, name, p2, fn, p3)
	local v23 = p[name]

	if v23 == nil then
		v23 = {}
		p[name] = v23
	end

	local v24 = math.floor(os.time() * 1000)
	local v25 = v23[p2]
	local v26

	if v25 == nil then
		v26 = true

		if p3 ~= true then
			v25 = {
				Data = nil,
				CreatedTime = v24,
				UpdatedTime = v24,
				VersionId = 0,
				UserIds = {},
				MetaData = {}
			}
			v23[p2] = v25
		end
	else
		v26 = false
	end

	local v27

	if v26 == false then
		v27 = NewMockDataStoreKeyInfo(v25) or nil
	end

	local v28, v29, v30 = fn(v25 and v25.Data, v27)

	if v28 == nil then
		return nil
	end

	if v25 ~= nil and p3 ~= true then
		v25.Data = DeepCopyTable(v28)
		v25.UserIds = DeepCopyTable(v29 or {})
		v25.MetaData = DeepCopyTable(v30 or {})
		v25.VersionId += 1
		v25.UpdatedTime = v24
	end

	local deepCopyTable = DeepCopyTable(v28)
	local v32

	if v25 ~= nil then
		v32 = NewMockDataStoreKeyInfo(v25) or nil
	end

	return deepCopyTable, v32
end

local function UpdateAsync(p, p2, data, p3, p4, p5)
	local async = nil
	local v23 = nil
	local waitInUpdateQueue = WaitInUpdateQueue(SessionToken(p.Name, p2, p3))
	local success, result = pcall(function()
		local function fn(async2)
			local v26 = false
			local v27 = false
			local globalUpdates = {
				0,
				{}
			}

			if async2 == nil then
				v26 = true
			elseif type(async2) == "table" then
				if type(async2.Data) == "table" and type(async2.MetaData) == "table" and type(async2.GlobalUpdates) == "table" then
					async2.WasOverwritten = false
					globalUpdates = async2.GlobalUpdates

					if data.ExistingProfileHandle ~= nil then
						data.ExistingProfileHandle(async2)
					end
				elseif async2.Data == nil and async2.MetaData == nil and type(async2.GlobalUpdates) == "table" then
					async2.WasOverwritten = false
					globalUpdates = async2.GlobalUpdates or globalUpdates
					v26 = true
				else
					v26 = true
					v27 = true
				end
			else
				v26 = true
				v27 = true
			end

			if v26 == true then
				async2 = {
					GlobalUpdates = globalUpdates
				}

				if data.MissingProfileHandle ~= nil then
					data.MissingProfileHandle(async2)
				end
			end

			if data.EditProfile ~= nil then
				data.EditProfile(async2)
			end

			if v27 == true then
				async2.WasOverwritten = true
			end

			return async2, async2.UserIds, async2.RobloxMetaData
		end

		if p3 == true then
			async, v23 = MockUpdateAsync(userMockStore, p.Name, p2, fn, p4)
			task.wait()
		elseif v16 == "Access" then
			if p4 == true then
				if p5 == nil then
					async, v23 = p.data_store:GetAsync(p2)
				else
					local success2, result2 = pcall(function()
						async, v23 = p.data_store:GetVersionAsync(p2, p5)
					end)

					if success2 == false and type(result2) == "string" and string.find(result2, "not valid") ~= nil then
						warn(`[{script.Name}]: Passed version argument is not valid; Traceback:\n` .. debug.traceback())
					end
				end

				async = fn(async)
			else
				async, v23 = p.data_store:UpdateAsync(p2, fn)
			end
		else
			async, v23 = MockUpdateAsync(mockStore, p.Name, p2, fn, p4)
			task.wait()
		end
	end)
	waitInUpdateQueue()

	if success == true and type(async) == "table" then
		if async.WasOverwritten == true and p4 ~= true then
			RegisterOverwrite(p.Name, p2) -- equivalent call inferred; original call site unknown
		end

		return async, v23
	else
		RegisterError(result or "Undefined error", p.Name, p2) -- equivalent call inferred; original call site unknown
		return nil
	end
end

local function IsThisSession(list)
	return list[1] == placeId and list[2] == jobId
end

local function ReadMockFlag()
	local v23 = v19
	v19 = false
	return v23
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WaitForStoreReady(p)
	while p.is_ready == false do
		task.wait()
	end
end

local function AddProfileToAutoSave(p)
	activeSessionCheck[p.session_token] = p
	table.insert(autoSaveList, v13, p)

	if #autoSaveList > 1 then
		v13 += 1
	elseif #autoSaveList == 1 then
		now = os.clock()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveProfileFromAutoSave(object)
	activeSessionCheck[object.session_token] = nil
	local index = table.find(autoSaveList, object)

	if index ~= nil then
		table.remove(autoSaveList, index)

		if index < v13 then
			v13 -= 1
		end

		if autoSaveList[v13] == nil then
			v13 = 1
		end
	end
end

local SaveProfileAsync

SaveProfileAsync = function(object, p, p2, value)
	if type(object.Data) ~= "table" then
		error((`[{script.Name}]: Developer code likely set "Profile.Data" to a non-table value! (STORE:{object.ProfileStore.Name}; KEY:{object.Key})`))
	end

	object.OnSave:Fire()

	if p == true then
		object.OnLastSave:Fire(value or "Manual")
	end

	if p == true and p2 ~= true then
		if object.roblox_message_subscription ~= nil then
			object.roblox_message_subscription:Disconnect()
		end

		RemoveProfileFromAutoSave(object) -- equivalent call inferred; original call site unknown
		object.OnSessionEnd:Fire()
	end

	activeProfileSaveJobs += 1
	local v23 = true
	local v24 = 1

	while v23 == true do
		if p ~= true then
			v23 = false
		end

		local v25, keyInfo = UpdateAsync(object.ProfileStore, object.Key, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = nil,
			EditProfile = function(state)
				local v27 = false

				if p2 == true then
					v27 = true
				else
					local activeSession = state.MetaData.ActiveSession
					local sessionLoadCount = state.MetaData.SessionLoadCount

					if type(activeSession) == "table" then
						v27 = activeSession[1] == placeId and activeSession[2] == jobId and sessionLoadCount == object.load_index
					end
				end

				if v27 == true then
					local locked_global_updates = object.locked_global_updates
					local globalUpdate = state.GlobalUpdates[2]

					if next(locked_global_updates) ~= nil then
						local v28 = 1

						while v28 <= #globalUpdate do
							if locked_global_updates[globalUpdate[v28][1]] == true then
								table.remove(globalUpdate, v28)
							else
								v28 += 1
							end
						end
					end

					state.Data = object.Data
					state.RobloxMetaData = object.RobloxMetaData
					state.UserIds = object.UserIds

					if p2 == true then
						state.MetaData.ActiveSession = nil
						state.MetaData.ForceLoadSession = nil
					else
						state.MetaData.LastUpdate = os.time()

						if p == true then
							state.MetaData.ActiveSession = nil
						end
					end
				end
			end
		}, object.is_mock)

		if v25 == nil or keyInfo == nil then
			if v23 == true then
				task.wait(v24)
				v24 = math.min(value == "Shutdown" and 8 or 20, v24 * 2)
			end
		else
			if p2 == true then
				break
			end

			v23 = false
			local activeSession = v25.MetaData.ActiveSession
			local sessionLoadCount = v25.MetaData.SessionLoadCount
			local v27

			if type(activeSession) == "table" then
				v27 = activeSession[1] == placeId and activeSession[2] == jobId and sessionLoadCount == object.load_index
			else
				v27 = false
			end

			local forceLoadSession = v25.MetaData.ForceLoadSession
			local v28

			if type(forceLoadSession) == "table" then
				v28 = forceLoadSession[1] ~= placeId or forceLoadSession[2] ~= jobId
			else
				v28 = false
			end

			local isActive = object:IsActive()

			if v28 == true and v27 == true then
				if isActive ~= true then
					break
				end

				SaveProfileAsync(object, true, false, "External")
				break
			else
				local locked_global_updates = object.locked_global_updates
				local received_global_updates = object.received_global_updates
				local globalUpdate = v25.GlobalUpdates[2]
				local v29 = {}
				local v30 = {}

				for _, v31 in ipairs(globalUpdate) do
					if locked_global_updates[v31[1]] == true then
						v30[v31[1]] = true
					elseif received_global_updates[v31[1]] ~= true then
						received_global_updates[v31[1]] = true
						table.insert(v29, v31)
					end
				end

				for k in pairs(locked_global_updates) do
					if v30[k] ~= true then
						locked_global_updates[k] = nil
					end
				end

				object.KeyInfo = keyInfo
				object.LastSavedData = v25.Data
				object.global_updates = v25.GlobalUpdates and v25.GlobalUpdates[2] or {}

				if v27 == true then
					if isActive == true and p ~= true then
						for _, v31 in ipairs(v29) do
							local v32 = v31[1]
							local v33 = v31[#v31]

							for _, callback in ipairs(object.message_handlers) do
								local v35 = false
								local locked_global_updates2 = locked_global_updates
								local v37 = v32

								local function fn()
									v35 = true
									locked_global_updates2[v37] = true
								end

								local deepCopyTable = DeepCopyTable(v33)
								task.spawn(callback, deepCopyTable, fn)

								if v35 == true then
									break
								end
							end
						end
					end
				else
					if object.roblox_message_subscription ~= nil then
						object.roblox_message_subscription:Disconnect()
					end

					if isActive == true then
						RemoveProfileFromAutoSave(object) -- equivalent call inferred; original call site unknown
						object.OnSessionEnd:Fire()
					end
				end

				object.OnAfterSave:Fire(object.LastSavedData)
			end
		end
	end

	activeProfileSaveJobs -= 1
end

local class3 = {}
class3.__index = class3

function class3.New(data, keyInfo, profileStore, p3, is_mock, value)
	local data2 = data.Data or {}
	local activeSession

	if data.MetaData then
		activeSession = data.MetaData.ActiveSession or nil
	end

	local global_updates = not data.GlobalUpdates and {} or data.GlobalUpdates[2] or {}
	local received_global_updates = {}

	for _, v25 in ipairs(global_updates) do
		received_global_updates[v25[1]] = true
	end

	local v25 = {
		Data = data2,
		LastSavedData = DeepCopyTable(data2),
		FirstSessionTime = not data.MetaData and 0 or data.MetaData.ProfileCreateTime or 0,
		SessionLoadCount = not data.MetaData and 0 or data.MetaData.SessionLoadCount or 0,
		Session = activeSession and {
			PlaceId = activeSession[1],
			JobId = activeSession[2]
		},
		RobloxMetaData = data.RobloxMetaData or {},
		UserIds = data.UserIds or {},
		KeyInfo = keyInfo,
		OnAfterSave = frozen.New(),
		OnSave = frozen.New(),
		OnLastSave = frozen.New(),
		OnSessionEnd = frozen.New(),
		ProfileStore = profileStore,
		Key = p3,
		load_timestamp = os.clock(),
		is_mock = is_mock,
		session_token = value or "",
		load_index = data.MetaData and data.MetaData.SessionLoadCount or 0,
		locked_global_updates = {},
		received_global_updates = received_global_updates,
		message_handlers = {},
		global_updates = global_updates
	}
	setmetatable(v25, class3)
	return v25
end

function class3:IsActive()
	return activeSessionCheck[self.session_token] == self
end

function class3.Reconcile(p)
	ReconcileTable(p.Data, p.ProfileStore.template)
end

function class3:EndSession()
	if self:IsActive() == true then
		task.spawn(SaveProfileAsync, self, true, nil, "Manual")
	end
end

function class3.AddUserId(p, value)
	if type(value) ~= "number" or value % 1 ~= 0 then
		warn(`[{script.Name}]: Invalid UserId argument for :AddUserId() ({tostring(value)}); Traceback:\n` .. debug.traceback())
		return
	end

	if value < 0 and p.is_mock ~= true and v16 == "Access" then
		return
	end

	if table.find(p.UserIds, value) == nil then
		table.insert(p.UserIds, value)
	end
end

function class3.RemoveUserId(p, value)
	if type(value) ~= "number" or value % 1 ~= 0 then
		warn(`[{script.Name}]: Invalid UserId argument for :RemoveUserId() ({tostring(value)}); Traceback:\n` .. debug.traceback())
		return
	end

	local index = table.find(p.UserIds, value)

	if index ~= nil then
		table.remove(p.UserIds, index)
	end
end

function class3:SetAsync()
	if self.view_mode ~= true then
		error((`[{script.Name}]: :SetAsync() can only be used in view mode`))
	end

	SaveProfileAsync(self, nil, true)
end

function class3:MessageHandler(callback)
	if type(callback) ~= "function" then
		error((`[{script.Name}]: fn argument is not a function`))
	end

	if self.view_mode ~= true and self:IsActive() ~= true then
		return
	end

	local locked_global_updates = self.locked_global_updates
	table.insert(self.message_handlers, callback)

	for _, global_update in ipairs(self.global_updates) do
		local v23 = global_update[1]
		local v24 = global_update[#global_update]

		if locked_global_updates[v23] == true then
			continue
		end

		local deepCopyTable = DeepCopyTable(v24)
		local v26 = v23
		task.spawn(callback, deepCopyTable, function()
			locked_global_updates[v26] = true
		end)
	end
end

function class3:Save()
	if self.view_mode == true then
		error((`[{script.Name}]: Can't save profile in view mode; Should you be calling :SetAsync() instead?`))
	end

	if self:IsActive() == false then
		warn(`[{script.Name}]: Attempted saving an inactive profile (STORE:{self.ProfileStore.Name}; KEY:{self.Key});` .. " Traceback:\n" .. debug.traceback())
		return
	end

	RemoveProfileFromAutoSave(self) -- equivalent call inferred; original call site unknown
	activeSessionCheck[self.session_token] = self
	table.insert(autoSaveList, v13, self)

	if #autoSaveList > 1 then
		v13 += 1
	elseif #autoSaveList == 1 then
		now = os.clock()
	end

	task.spawn(SaveProfileAsync, self)
end

local Profilestore = {
	IsClosing = false,
	IsCriticalState = false,
	OnError = onError,
	OnOverwrite = onOverwrite,
	OnCriticalToggle = frozen.New(),
	DataStoreState = "NotReady"
}
Profilestore.__index = Profilestore

function Profilestore.SetConstant(p, value)
	if type(value) ~= "number" then
		error((`[{script.Name}]: Invalid value type`))
	end

	if p == "AUTO_SAVE_PERIOD" then
		v = value
	elseif p == "LOAD_REPEAT_PERIOD" then
		v2 = value
	elseif p == "FIRST_LOAD_REPEAT" then
		v3 = value
	elseif p == "SESSION_STEAL" then
		v4 = value
	elseif p == "ASSUME_DEAD" then
		v5 = value
	elseif p == "START_SESSION_TIMEOUT" then
		v6 = value
	elseif p == "CRITICAL_STATE_ERROR_COUNT" then
		v7 = value
	elseif p == "CRITICAL_STATE_ERROR_EXPIRE" then
		v8 = value
	elseif p == "CRITICAL_STATE_EXPIRE" then
		v9 = value
	elseif p == "MAX_MESSAGE_QUEUE" then
		v10 = value
	else
		error((`[{script.Name}]: Invalid constant name was provided`))
	end
end

function Profilestore.Test()
	return {
		ActiveSessionCheck = activeSessionCheck,
		AutoSaveList = autoSaveList,
		ActiveProfileLoadJobs = activeProfileLoadJobs,
		ActiveProfileSaveJobs = activeProfileSaveJobs,
		MockStore = mockStore,
		UserMockStore = userMockStore,
		UpdateQueue = updateQueue
	}
end

function Profilestore.New(name, options)
	local template = options or {}

	if type(name) == "string" then
		if string.len(name) == 0 then
			error((`[{script.Name}]: store_name cannot be an empty string`))
		elseif string.len(name) > 50 then
			error((`[{script.Name}]: store_name is too long`))
		end
	else
		error((`[{script.Name}]: Invalid or missing "store_name"`))
	end

	if type(template) ~= "table" then
		error((`[{script.Name}]: Invalid template argument`))
	end

	local v24 = nil
	v24 = {
		Mock = {
			Name = name,
			StartSessionAsync = function(self, p)
				v19 = true
				return v24:StartSessionAsync(p)
			end,
			MessageAsync = function(self, p, p2)
				v19 = true
				return v24:MessageAsync(p, p2)
			end,
			GetAsync = function(self, p, p2)
				v19 = true
				return v24:GetAsync(p, p2)
			end,
			VersionQuery = function(self, p, p2, p3, p4)
				v19 = true
				return v24:VersionQuery(p, p2, p3, p4)
			end,
			RemoveAsync = function(self, p)
				v19 = true
				return v24:RemoveAsync(p)
			end
		},
		Name = name,
		template = template,
		data_store = nil,
		load_jobs = {},
		mock_load_jobs = {},
		is_ready = true
	}
	setmetatable(v24, Profilestore)
	local dataStoreOptions = Instance.new("DataStoreOptions")
	dataStoreOptions:SetExperimentalFeatures({
		v2 = true
	})

	if v16 == "NotReady" then
		v24.is_ready = false
		task.spawn(function()
			repeat
				task.wait()
			until v16 ~= "NotReady"

			if v16 == "Access" then
				v24.data_store = DataStoreService:GetDataStore(name, nil, dataStoreOptions)
			end

			v24.is_ready = true
		end)
	elseif v16 == "Access" then
		v24.data_store = DataStoreService:GetDataStore(name, nil, dataStoreOptions)
	end

	return v24
end

local function RobloxMessageSubscription(object, p)
	local now3 = 0
	local connection = MessagingService:SubscribeAsync("PS_" .. p, function(p2)
		if type(p2.Data) == "table" and p2.Data.LoadCount == object.SessionLoadCount and os.clock() - now3 > 6 then
			now3 = os.clock()

			if object:IsActive() == true then
				if p2.Data.EndSession == true then
					SaveProfileAsync(object, true, false, "External")
				else
					object:Save()
				end
			end
		end
	end)

	if object:IsActive() == true then
		object.roblox_message_subscription = connection
	else
		connection:Disconnect()
	end
end

function Profilestore:StartSessionAsync(value, options)
	local v23 = v19
	v19 = false

	if type(value) == "string" then
		if string.len(value) == 0 then
			error((`[{script.Name}]: Invalid profile_key`))
		elseif string.len(value) > 50 then
			error((`[{script.Name}]: profile_key is too long`))
		end
	else
		error((`[{script.Name}]: profile_key must be a string`))
	end

	if options ~= nil and type(options) ~= "table" then
		error((`[{script.Name}]: Invalid params`))
	end

	if Profilestore.IsClosing == true then
		return nil
	end

	local v24 = options or {}
	WaitForStoreReady(self) -- equivalent call inferred; original call site unknown
	local sessionToken = SessionToken(self.Name, value, v23) -- equivalent call inferred; original call site unknown

	if activeSessionCheck[sessionToken] ~= nil then
		error((`[{script.Name}]: Profile (STORE:{self.Name}; KEY:{value}) is already loaded in this session`))
	end

	activeProfileLoadJobs += 1
	local v26 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancel_condition()
		if v26 ~= false then
			return true
		end

		if v24.Cancel ~= nil then
			v26 = v24.Cancel() == true
		end

		return v26
	end

	local steal = v24.Steal == true
	local lastTime = os.clock()
	local v27 = false
	local v28 = true
	local v29 = 1
	local count2 = 0

	while Profilestore.IsClosing == false do
		local v30 = cancel_condition() -- equivalent call inferred; original call site unknown

		if v30 ~= false then
			break
		end

		count += 1
		local v31 = count
		local mock_load_jobs = v23 == true and self.mock_load_jobs or self.load_jobs
		local mock_load_job = mock_load_jobs[value]
		local GUID = HttpService:GenerateGUID(false)
		local v32, v33

		if mock_load_job == nil then
			local v34 = { v31, nil }
			mock_load_jobs[value] = v34
			local v35 = GUID
			local v36 = GUID
			v34[2] = table.pack(UpdateAsync(self, value, {
				ExistingProfileHandle = function(p)
					if Profilestore.IsClosing ~= true then
						local v37 = cancel_condition() -- equivalent call inferred; original call site unknown

						if v37 ~= true then
							local activeSession = p.MetaData.ActiveSession
							local forceLoadSession = p.MetaData.ForceLoadSession

							if activeSession == nil then
								p.MetaData.ActiveSession = { placeId, jobId, v35 }
								p.MetaData.ForceLoadSession = nil
							elseif type(activeSession) == "table" then
								local v38

								if activeSession[1] == placeId then
									v38 = activeSession[2] == jobId
								else
									v38 = false
								end

								if v38 == false then
									local lastUpdate = p.MetaData.LastUpdate

									if lastUpdate ~= nil then
										local v39 = os.time() - lastUpdate

										if v5 < v39 then
											p.MetaData.ActiveSession = { placeId, jobId, v35 }
											p.MetaData.ForceLoadSession = nil
											return
										end
									end

									if v27 == true or steal == true then
										local v39

										if forceLoadSession == nil then
											v39 = true
										else
											v39 = forceLoadSession[1] ~= placeId or forceLoadSession[2] ~= jobId
										end

										if v39 == false or steal == true then
											p.MetaData.ActiveSession = { placeId, jobId, v35 }
											p.MetaData.ForceLoadSession = nil
										end
									elseif v28 == true then
										p.MetaData.ForceLoadSession = { placeId, jobId }
									end
								else
									p.MetaData.ForceLoadSession = nil
								end
							end
						end
					end
				end,
				MissingProfileHandle = function(p)
					local v37

					if Profilestore.IsClosing == true then
						v37 = true
					else
						local v38 = cancel_condition() -- equivalent call inferred; original call site unknown
						v37 = v38 == true
					end

					p.Data = DeepCopyTable(self.template)
					p.MetaData = {
						ProfileCreateTime = os.time(),
						SessionLoadCount = 0,
						ActiveSession = v37 == false and { placeId, jobId, v36 } or nil,
						ForceLoadSession = nil,
						MetaTags = {}
					}
				end,
				EditProfile = function(p)
					if Profilestore.IsClosing ~= true then
						local v37 = cancel_condition() -- equivalent call inferred; original call site unknown

						if v37 ~= true then
							local activeSession = p.MetaData.ActiveSession

							if activeSession ~= nil then
								local v38

								if activeSession[1] == placeId then
									v38 = activeSession[2] == jobId
								else
									v38 = false
								end

								if v38 == true then
									p.MetaData.SessionLoadCount = p.MetaData.SessionLoadCount + 1
									p.MetaData.LastUpdate = os.time()
								end
							end
						end
					end
				end
			}, v23))

			if v34[1] == v31 then
				v32, v33 = table.unpack(v34[2])
				mock_load_jobs[value] = nil
			else
				activeProfileLoadJobs -= 1
				return nil
			end
		else
			mock_load_job[1] = v31

			while mock_load_job[2] == nil do
				task.wait()
			end

			if mock_load_job[1] == v31 then
				v32, v33 = table.unpack(mock_load_job[2])
				mock_load_jobs[value] = nil
			else
				activeProfileLoadJobs -= 1
				return nil
			end
		end

		if v32 == nil or v33 == nil then
			local v34

			if v24.Cancel == nil then
				local v35 = os.clock() - lastTime
				v34 = v6 <= v35
			else
				v34 = false
			end

			if v34 ~= true and Profilestore.IsClosing ~= true then
				local v35 = cancel_condition() -- equivalent call inferred; original call site unknown

				if v35 ~= true then
					task.wait(v29)
					v29 = math.min(20, v29 * 2)
					continue
				end
			end

			activeProfileLoadJobs -= 1
			return nil
		else
			local activeSession = v32.MetaData.ActiveSession

			if type(activeSession) ~= "table" then
				activeProfileLoadJobs -= 1
				return nil
			end

			local v34

			if activeSession[1] == placeId then
				v34 = activeSession[2] == jobId
			else
				v34 = false
			end

			if v34 == true then
				local v35 = class3.New(v32, v33, self, value, v23, sessionToken)
				activeSessionCheck[v35.session_token] = v35
				table.insert(autoSaveList, v13, v35)

				if #autoSaveList > 1 then
					v13 += 1
				elseif #autoSaveList == 1 then
					now = os.clock()
				end

				if v23 ~= true and v16 == "Access" then
					task.spawn(RobloxMessageSubscription, v35, GUID)
				end

				if Profilestore.IsClosing == true then
					SaveProfileAsync(v35, true)
					v35 = nil
				else
					local v36 = cancel_condition() -- equivalent call inferred; original call site unknown

					if v36 == true then
						SaveProfileAsync(v35, true)
						v35 = nil
					end
				end

				activeProfileLoadJobs -= 1
				return v35
			else
				if Profilestore.IsClosing ~= true then
					local v35 = cancel_condition() -- equivalent call inferred; original call site unknown

					if v35 ~= true then
						local forceLoadSession = v32.MetaData.ForceLoadSession
						local v36

						if forceLoadSession == nil then
							v36 = true
						else
							v36 = forceLoadSession[1] ~= placeId or forceLoadSession[2] ~= jobId
						end

						if v36 ~= false then
							activeProfileLoadJobs -= 1
							return nil
						end

						if v28 == false then
							count2 += 1

							if math.ceil(v4 / v2) <= count2 then
								v27 = true
							end
						end

						if type(activeSession[3]) == "string" then
							local sessionLoadCount = v32.MetaData.SessionLoadCount or 0
							task.spawn(MessagingService.PublishAsync, MessagingService, "PS_" .. activeSession[3], {
								LoadCount = sessionLoadCount,
								EndSession = true
							})
						end

						local now3 = os.clock()
						local v37

						if v28 == true then
							v37 = v3
						else
							v37 = v2
						end

						local v38 = now3 + v37

						repeat
							task.wait()
						until v38 <= os.clock() or Profilestore.IsClosing == true

						v28 = false
						continue
					end
				end

				activeProfileLoadJobs -= 1
				return nil
			end
		end
	end

	activeProfileLoadJobs -= 1
	return nil
end

function Profilestore:MessageAsync(value, p2)
	local v23 = v19
	v19 = false

	if type(value) == "string" then
		if string.len(value) == 0 then
			error((`[{script.Name}]: Invalid profile_key`))
		elseif string.len(value) > 50 then
			error((`[{script.Name}]: profile_key is too long`))
		end
	else
		error((`[{script.Name}]: profile_key must be a string`))
	end

	if type(p2) ~= "table" then
		error((`[{script.Name}]: message must be a table`))
	end

	if Profilestore.IsClosing == true then
		return false
	end

	WaitForStoreReady(self) -- equivalent call inferred; original call site unknown
	local v24 = 1

	while Profilestore.IsClosing == false do
		local updateAsync = UpdateAsync(self, value, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = nil,
			EditProfile = function(p3)
				local globalUpdates = p3.GlobalUpdates
				local globalUpdate = globalUpdates[2]
				globalUpdates[1] += 1
				table.insert(globalUpdate, { globalUpdates[1], p2 })

				while true do
					local v26 = #globalUpdate

					if not (v10 < v26) then
						break
					end

					table.remove(globalUpdate, 1)
				end
			end
		}, v23)

		if updateAsync == nil then
			task.wait(v24)
			v24 = math.min(20, v24 * 2)
		else
			local sessionToken = SessionToken(self.Name, value, v23) -- equivalent call inferred; original call site unknown
			local v27 = activeSessionCheck[sessionToken]

			if v27 == nil then
				local metaData = updateAsync.MetaData or {}
				local activeSession = metaData.ActiveSession
				local sessionLoadCount = metaData.SessionLoadCount or 0

				if type(activeSession) == "table" and type(activeSession[3]) == "string" then
					task.spawn(MessagingService.PublishAsync, MessagingService, "PS_" .. activeSession[3], {
						LoadCount = sessionLoadCount
					})
				end
			else
				v27:Save()
			end

			return true
		end
	end

	return false
end

function Profilestore:GetAsync(value, p2)
	local v23 = v19
	v19 = false

	if type(value) == "string" then
		if string.len(value) == 0 then
			error((`[{script.Name}]: Invalid profile_key`))
		elseif string.len(value) > 50 then
			error((`[{script.Name}]: profile_key is too long`))
		end
	else
		error((`[{script.Name}]: profile_key must be a string`))
	end

	if Profilestore.IsClosing == true then
		return nil
	end

	WaitForStoreReady(self) -- equivalent call inferred; original call site unknown

	if p2 ~= nil and (v23 or v16 ~= "Access") then
		return nil
	end

	local v24 = 1

	while Profilestore.IsClosing == false do
		local v25, v26 = UpdateAsync(self, value, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = function(p3)
				p3.Data = DeepCopyTable(self.template)
				p3.MetaData = {
					ProfileCreateTime = os.time(),
					SessionLoadCount = 0,
					ActiveSession = nil,
					ForceLoadSession = nil,
					MetaTags = {}
				}
			end,
			EditProfile = nil
		}, v23, true, p2)

		if v25 == nil then
			task.wait(v24)
			v24 = math.min(20, v24 * 2)
		else
			if v26 == nil then
				return nil
			end

			local result = class3.New(v25, v26, self, value, v23)
			result.view_mode = true
			return result
		end
	end

	return nil
end

function Profilestore:RemoveAsync(value)
	local v23 = v19
	v19 = false

	if type(value) ~= "string" or string.len(value) == 0 then
		error((`[{script.Name}]: Invalid profile_key`))
	end

	if Profilestore.IsClosing == true then
		return false
	end

	WaitForStoreReady(self) -- equivalent call inferred; original call site unknown
	local waitInUpdateQueue = WaitInUpdateQueue(SessionToken(self.Name, value, v23))
	local v26

	if v23 == true then
		local v27 = userMockStore[self.Name]

		if v27 ~= nil then
			v27[value] = nil

			if next(v27) == nil then
				userMockStore[self.Name] = nil
			end
		end

		task.wait()
		v26 = true
	elseif v16 == "Access" then
		v26 = pcall(function()
			self.data_store:RemoveAsync(value)
		end)
	else
		local v27 = mockStore[self.Name]

		if v27 ~= nil then
			v27[value] = nil

			if next(v27) == nil then
				mockStore[self.Name] = nil
			end
		end

		task.wait()
		v26 = true
	end

	waitInUpdateQueue()
	return v26
end

local class4 = {}
class4.__index = class4

function class4.New(profile_store, profile_key, sort_direction, min_date, max_date, is_mock)
	local v23 = {
		profile_store = profile_store,
		profile_key = profile_key,
		sort_direction = sort_direction,
		min_date = min_date,
		max_date = max_date,
		query_pages = nil,
		query_index = 0,
		query_failure = false,
		is_query_yielded = false,
		query_queue = {},
		is_mock = is_mock
	}
	setmetatable(v23, class4)
	return v23
end

function MoveVersionQueryQueue(p)
	while #p.query_queue > 0 do
		local v23 = table.remove(p.query_queue, 1)
		task.spawn(v23)

		if p.is_query_yielded == true then
			break
		end
	end
end

local v23 = false
local v24 = false

function class4:NextAsync()
	local v25 = v23 == true
	v23 = false
	WaitForStoreReady(self.profile_store) -- equivalent call inferred; original call site unknown

	if Profilestore.IsClosing == true then
		return nil
	end

	if self.is_mock == true or v16 ~= "Access" then
		if isStudio == true and v24 == false then
			v24 = true
			warn((`[{script.Name}]: :VersionQuery() is not supported in mock mode!`))
		end

		return nil
	else
		local async = nil
		local v26 = false

		local function query_job()
			if self.query_failure == true then
				v26 = true
			elseif self.query_pages == nil then
				self.is_query_yielded = true
				task.spawn(function()
					v23 = true
					async = self:NextAsync()
					v26 = true
				end)
				local success, result = pcall(function()
					self.query_pages = self.profile_store.data_store:ListVersionsAsync(
						self.profile_key,
						self.sort_direction,
						self.min_date,
						self.max_date
					)
					self.query_index = 0
				end)

				if success == false or self.query_pages == nil then
					warn((`[{script.Name}]: Version query fail - {tostring(result)}`))
					self.query_failure = true
				end

				self.is_query_yielded = false
				MoveVersionQueryQueue(self)
			else
				local v27 = self.query_pages:GetCurrentPage()[self.query_index + 1]

				if self.query_pages.IsFinished == true and v27 == nil then
					v26 = true
				elseif v27 == nil then
					self.is_query_yielded = true
					task.spawn(function()
						v23 = true
						async = self:NextAsync()
						v26 = true
					end)
					local success, _ = pcall(function()
						self.query_pages:AdvanceToNextPageAsync()
						self.query_index = 0
					end)

					if success == false or #self.query_pages:GetCurrentPage() == 0 then
						self.query_failure = true
					end

					self.is_query_yielded = false
					MoveVersionQueryQueue(self)
				else
					self.query_index += 1
					async = self.profile_store:GetAsync(self.profile_key, v27.Version)
					v26 = true
				end
			end
		end

		if self.is_query_yielded == false then
			query_job()
		elseif v25 == true then
			table.insert(self.query_queue, 1, query_job)
		else
			table.insert(self.query_queue, query_job)
		end

		while v26 == false do
			task.wait()
		end

		return async
	end
end

function Profilestore:VersionQuery(value, p2, unixTimestampMillis, unixTimestampMillis2)
	local v25 = v19
	v19 = false

	if type(value) ~= "string" or string.len(value) == 0 then
		error((`[{script.Name}]: Invalid profile_key`))
	end

	if p2 ~= nil and (typeof(p2) ~= "EnumItem" or p2.EnumType ~= Enum.SortDirection) then
		error((`[{script.Name}]: Invalid sort_direction ({tostring(p2)})`))
	end

	if unixTimestampMillis ~= nil and typeof(unixTimestampMillis) ~= "DateTime" and typeof(unixTimestampMillis) ~= "number" then
		error((`[{script.Name}]: Invalid min_date ({tostring(unixTimestampMillis)})`))
	end

	if unixTimestampMillis2 ~= nil and typeof(unixTimestampMillis2) ~= "DateTime" and typeof(unixTimestampMillis2) ~= "number" then
		error((`[{script.Name}]: Invalid max_date ({tostring(unixTimestampMillis2)})`))
	end

	if typeof(unixTimestampMillis) == "DateTime" then
		unixTimestampMillis = unixTimestampMillis.UnixTimestampMillis or unixTimestampMillis
	end

	if typeof(unixTimestampMillis2) == "DateTime" then
		unixTimestampMillis2 = unixTimestampMillis2.UnixTimestampMillis or unixTimestampMillis2
	end

	return class4.New(self, value, p2, unixTimestampMillis, unixTimestampMillis2, v25)
end

if isStudio == true then
	task.spawn(function()
		local success, result = pcall(function()
			DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
		end)
		local v25

		if success == false then
			v25 = string.find(result, "ConnectFail", 1, true) ~= nil
		else
			v25 = false
		end

		if v25 == true then
			warn((`[{script.Name}]: No internet access - check your network connection`))
		end

		local dataStoreState

		if success == false and (string.find(result, "403", 1, true) ~= nil or string.find(
			result,
			"must publish",
			1,
			true
		) ~= nil or v25 == true) then
			dataStoreState = v25 == true and "NoInternet" or "NoAccess"
			print((`[{script.Name}]: Roblox API services unavailable - data will not be saved`))
		else
			print((`[{script.Name}]: Roblox API services available - data will be saved`))
			dataStoreState = "Access"
		end

		v16 = dataStoreState
		Profilestore.DataStoreState = dataStoreState
	end)
else
	v16 = "Access"
	Profilestore.DataStoreState = "Access"
end

RunService.Heartbeat:Connect(function()
	local count2 = #autoSaveList

	if count2 > 0 then
		local v25 = v / count2
		local now3 = os.clock()

		while v25 < now3 - now do
			now += v25
			local v26 = autoSaveList[v13]

			if now3 - v26.load_timestamp < v / 2 then
				v26 = nil

				for _ = 1, count2 - 1 do
					v13 += 1

					if count2 < v13 then
						v13 = 1
					end

					v26 = autoSaveList[v13]
					local v27 = now3 - v26.load_timestamp

					if v / 2 <= v27 then
						break
					else
						v26 = nil
					end
				end
			end

			v13 += 1

			if count2 < v13 then
				v13 = 1
			end

			if v26 ~= nil then
				task.spawn(SaveProfileAsync, v26)
			end
		end
	end

	if Profilestore.IsCriticalState == false then
		local v25 = #nows

		if v7 <= v25 then
			Profilestore.IsCriticalState = true
			Profilestore.OnCriticalToggle:Fire(true)
			now2 = os.clock()
			warn((`[{script.Name}]: Entered critical state`))
		end
	else
		local v25 = #nows

		if v7 <= v25 then
			now2 = os.clock()
		else
			local v26 = os.clock() - now2

			if v9 < v26 then
				Profilestore.IsCriticalState = false
				Profilestore.OnCriticalToggle:Fire(false)
				warn((`[{script.Name}]: Critical state ended`))
			end
		end
	end

	while true do
		local v25 = nows[1]

		if v25 == nil then
			break
		end

		local v26 = os.clock() - v25

		if v8 < v26 then
			table.remove(nows, 1)
		else
			break
		end
	end
end)
task.spawn(function()
	while v16 == "NotReady" do
		task.wait()
	end

	if v16 == "Access" then
		game:BindToClose(function()
			Profilestore.IsClosing = true
			local v25 = {}
			local v26 = 0

			for i, v27 in ipairs(autoSaveList) do
				v25[i] = v27
			end

			for _, v27 in ipairs(v25) do
				if v27:IsActive() ~= true then
					continue
				end

				v26 += 1
				local v28 = v27
				task.spawn(function()
					SaveProfileAsync(v28, true, nil, "Shutdown")
					v26 -= 1
				end)
			end

			while v26 > 0 or activeProfileLoadJobs > 0 or activeProfileSaveJobs > 0 do
				task.wait()
			end
		end)
	else
		game:BindToClose(function()
			Profilestore.IsClosing = true
			task.wait()
		end)
	end
end)
return Profilestore