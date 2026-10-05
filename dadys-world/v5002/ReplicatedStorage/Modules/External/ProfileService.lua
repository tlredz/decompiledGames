local v = {
	AutoSaveProfiles = 30,
	RobloxWriteCooldown = 7,
	ForceLoadMaxSteps = 8,
	AssumeDeadSessionLock = 1800,
	IssueCountForCriticalState = 5,
	IssueLast = 120,
	CriticalStateLast = 120,
	MetaTagsUpdatedValues = {
		ProfileCreateTime = true,
		SessionLoadCount = true,
		ActiveSession = true,
		ForceLoadSession = true,
		LastUpdate = true
	}
}
local v2 = {}
local thread = nil

local function AcquireRunnerThreadAndCallEventHandler(callback, ...)
	local v3 = thread
	thread = nil
	callback(...)
	thread = v3
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local class = {}
class.__index = class

function class:Disconnect()
	if self._is_connected == false then
		return
	end

	self._is_connected = false
	self._script_signal._listener_count -= 1

	if self._script_signal._head == self then
		self._script_signal._head = self._next
	else
		local _head = self._script_signal._head

		while _head ~= nil and _head._next ~= self do
			_head = _head._next
		end

		if _head ~= nil then
			_head._next = self._next
		end
	end

	if self._disconnect_listener ~= nil then
		if not thread then
			thread = coroutine.create(RunEventHandlerInFreeThread)
		end

		task.spawn(thread, self._disconnect_listener, self._disconnect_param)
		self._disconnect_listener = nil
	end
end

local class2 = {}
class2.__index = class2

function class2:Connect(listener, disconnect_listener, disconnect_param)
	local head = {
		_listener = listener,
		_script_signal = self,
		_disconnect_listener = disconnect_listener,
		_disconnect_param = disconnect_param,
		_next = self._head,
		_is_connected = true
	}
	setmetatable(head, class)
	self._head = head
	self._listener_count += 1
	return head
end

function class2:GetListenerCount()
	return self._listener_count
end

function class2:Fire(...)
	local _head = self._head

	while _head ~= nil do
		if _head._is_connected == true then
			if not thread then
				thread = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(thread, _head._listener, ...)
		end

		_head = _head._next
	end
end

function class2:FireUntil(callback, ...)
	local _head = self._head

	while _head ~= nil do
		if _head._is_connected == true then
			_head._listener(...)

			if callback() ~= true then
				break
			end
		end

		_head = _head._next
	end
end

function v2.NewScriptSignal()
	return {
		_head = nil,
		_listener_count = 0,
		Connect = class2.Connect,
		GetListenerCount = class2.GetListenerCount,
		Fire = class2.Fire,
		FireUntil = class2.FireUntil
	}
end

local v3 = {
	NewScriptSignal = v2.NewScriptSignal,
	ConnectToOnClose = function(p, p2)
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() == false or p2 == true then
			game:BindToClose(p)
		end
	end
}
local ProfileService = {
	ServiceLocked = false,
	IssueSignal = v3.NewScriptSignal(),
	CorruptionSignal = v3.NewScriptSignal(),
	CriticalState = false,
	CriticalStateSignal = v3.NewScriptSignal(),
	ServiceIssueCount = 0,
	_active_profile_stores = {},
	_auto_save_list = {},
	_issue_queue = {},
	_critical_state_start = 0,
	_mock_data_store = {},
	_user_mock_data_store = {},
	_use_mock_data_store = false
}
local _active_profile_stores = ProfileService._active_profile_stores
local _auto_save_list = ProfileService._auto_save_list
local _issue_queue = ProfileService._issue_queue
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local placeId = game.PlaceId
local jobId = game.JobId
local v4 = 1
local now = os.clock()
local v5 = 0
local v6 = 0
local v7 = 0
local now2 = 0
local isStudio = RunService:IsStudio()
local v8 = false
local v9 = false
local _mock_data_store = ProfileService._mock_data_store
local _user_mock_data_store = ProfileService._user_mock_data_store
local v10 = {}
local v11 = {}
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

local function IdentifyProfile(_profile_store_name, _profile_store_scope, _profile_key)
	return string.format(
		"[Store:\"%s\";%sKey:\"%s\"]",
		_profile_store_name,
		_profile_store_scope == nil and "" or string.format("Scope:\"%s\";", _profile_store_scope) or "",
		_profile_key
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CustomWriteQueueCleanup(p, p2)
	if v11[p] ~= nil then
		v11[p][p2] = nil

		if next(v11[p]) == nil then
			v11[p] = nil
		end
	end
end

local function CustomWriteQueueMarkForCleanup(_profile_store_lookup, p)
	if v11[_profile_store_lookup] ~= nil then
		if v11[_profile_store_lookup][p] == nil then
			if next(v11[_profile_store_lookup]) == nil then
				v11[_profile_store_lookup] = nil
			end
		else
			local v12 = v11[_profile_store_lookup][p]
			local queue = v12.Queue

			if v12.CleanupJob == nil then
				v12.CleanupJob = RunService.Heartbeat:Connect(function()
					if os.clock() - v12.LastWrite > v.RobloxWriteCooldown and #queue == 0 then
						v12.CleanupJob:Disconnect()
						CustomWriteQueueCleanup(_profile_store_lookup, p) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end
	end
end

local function CustomWriteQueueAsync(fn, _profile_store_lookup, p)
	if v11[_profile_store_lookup] == nil then
		v11[_profile_store_lookup] = {}
	end

	if v11[_profile_store_lookup][p] == nil then
		v11[_profile_store_lookup][p] = {
			LastWrite = 0,
			Queue = {},
			CleanupJob = nil
		}
	end

	local v12 = v11[_profile_store_lookup][p]
	local queue = v12.Queue

	if v12.CleanupJob ~= nil then
		v12.CleanupJob:Disconnect()
		v12.CleanupJob = nil
	end

	if os.clock() - v12.LastWrite > v.RobloxWriteCooldown and #queue == 0 then
		v12.LastWrite = os.clock()
		return fn()
	end

	table.insert(queue, fn)

	while not (os.clock() - v12.LastWrite > v.RobloxWriteCooldown) or queue[1] ~= fn do
		task.wait()
	end

	table.remove(queue, 1)
	v12.LastWrite = os.clock()
	return fn()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsCustomWriteQueueEmptyFor(_profile_store_lookup, _profile_key)
	local v12 = v11[_profile_store_lookup]

	if v12 == nil then
		return true
	end

	local v13 = v12[_profile_key]
	return v13 == nil or #v13.Queue == 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WaitForLiveAccessCheck()
	while v8 == true do
		task.wait()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WaitForPendingProfileStore(p)
	while p._is_pending == true do
		task.wait()
	end
end

local function RegisterIssue(p, _profile_store_name, _profile_store_scope, p2)
	warn("[ProfileService]: DataStore API error " .. string.format(
		"[Store:\"%s\";%sKey:\"%s\"]",
		_profile_store_name,
		_profile_store_scope == nil and "" or string.format("Scope:\"%s\";", _profile_store_scope) or "",
		p2
	) .. " - \"" .. tostring(p) .. "\"")
	table.insert(_issue_queue, os.clock())
	ProfileService.IssueSignal:Fire(tostring(p), _profile_store_name, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RegisterCorruption(_profile_store_name, _profile_store_scope, p)
	warn("[ProfileService]: Resolved profile corruption " .. string.format(
		"[Store:\"%s\";%sKey:\"%s\"]",
		_profile_store_name,
		_profile_store_scope == nil and "" or string.format("Scope:\"%s\";", _profile_store_scope) or "",
		p
	))
	ProfileService.CorruptionSignal:Fire(_profile_store_name, p)
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

local function MockUpdateAsync(p, _profile_store_lookup, p2, fn, p3)
	local v12 = p[_profile_store_lookup]

	if v12 == nil then
		v12 = {}
		p[_profile_store_lookup] = v12
	end

	local v13 = math.floor(os.time() * 1000)
	local v14 = v12[p2]
	local v15

	if v14 == nil then
		v15 = true

		if p3 ~= true then
			v14 = {
				Data = nil,
				CreatedTime = v13,
				UpdatedTime = v13,
				VersionId = 0,
				UserIds = {},
				MetaData = {}
			}
			v12[p2] = v14
		end
	else
		v15 = false
	end

	local v16

	if v15 == false then
		v16 = NewMockDataStoreKeyInfo(v14) or nil
	end

	local v17, v18, v19 = fn(v14 and v14.Data, v16)

	if v17 == nil then
		return nil
	end

	if v14 ~= nil and p3 ~= true then
		v14.Data = v17
		v14.UserIds = DeepCopyTable(v18 or {})
		v14.MetaData = DeepCopyTable(v19 or {})
		v14.VersionId += 1
		v14.UpdatedTime = v13
	end

	local deepCopyTable = DeepCopyTable(v17)
	local v21

	if v14 ~= nil then
		v21 = NewMockDataStoreKeyInfo(v14) or nil
	end

	return deepCopyTable, v21
end

local function IsThisSession(list)
	return list[1] == placeId and list[2] == jobId
end

local function StandardProfileUpdateAsyncDataStore(data, p, data2, p2, p3, p4)
	local v12 = nil
	local v13 = nil
	local success, result = pcall(function()
		local function fn(async)
			local v14 = false
			local v15 = false
			local globalUpdates = {
				0,
				{}
			}

			if async == nil then
				v14 = true
			elseif type(async) ~= "table" then
				v14 = true
				v15 = true
			end

			if type(async) == "table" then
				if type(async.Data) == "table" and type(async.MetaData) == "table" and type(async.GlobalUpdates) == "table" then
					async.WasCorrupted = false
					globalUpdates = async.GlobalUpdates

					if data2.ExistingProfileHandle ~= nil then
						data2.ExistingProfileHandle(async)
					end
				elseif async.Data == nil and async.MetaData == nil and type(async.GlobalUpdates) == "table" then
					async.WasCorrupted = false
					globalUpdates = async.GlobalUpdates or globalUpdates
					v14 = true
				else
					v14 = true
					v15 = true
				end
			end

			if v14 == true then
				async = {
					GlobalUpdates = globalUpdates
				}

				if data2.MissingProfileHandle ~= nil then
					data2.MissingProfileHandle(async)
				end
			end

			if data2.EditProfile ~= nil then
				data2.EditProfile(async)
			end

			if v15 == true then
				async.WasCorrupted = true
			end

			return async, async.UserIds, async.RobloxMetaData
		end

		if p2 == true then
			v12, v13 = MockUpdateAsync(_user_mock_data_store, data._profile_store_lookup, p, fn, p3)
			task.wait()
		elseif v9 == true then
			v12, v13 = MockUpdateAsync(_mock_data_store, data._profile_store_lookup, p, fn, p3)
			task.wait()
		else
			v12, v13 = CustomWriteQueueAsync(function()
				if p3 ~= true then
					return data._global_data_store:UpdateAsync(p, fn)
				end

				local async = nil
				local v14 = nil

				if p4 == nil then
					async, v14 = data._global_data_store:GetAsync(p)
				else
					local success2, result2 = pcall(function()
						async, v14 = data._global_data_store:GetVersionAsync(p, p4)
					end)

					if success2 == false and type(result2) == "string" and string.find(result2, "not valid") ~= nil then
						warn("[ProfileService]: Passed version argument is not valid; Traceback:\n" .. debug.traceback())
					end
				end

				async = fn(async)
				return async, v14
			end, data._profile_store_lookup, p)
		end
	end)

	if success ~= true or type(v12) ~= "table" then
		RegisterIssue(
			(result == nil or not result) and "Undefined error" or result,
			data._profile_store_name,
			data._profile_store_scope,
			p
		)
		return nil
	end

	if v12.WasCorrupted ~= true or p3 == true then
		return v12, v13
	end

	RegisterCorruption(data._profile_store_name, data._profile_store_scope, p) -- equivalent call inferred; original call site unknown
	return v12, v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveProfileFromAutoSave(p)
	local index = table.find(_auto_save_list, p)

	if index ~= nil then
		table.remove(_auto_save_list, index)

		if index < v4 then
			v4 -= 1
		end

		if _auto_save_list[v4] == nil then
			v4 = 1
		end
	end
end

local function AddProfileToAutoSave(p)
	table.insert(_auto_save_list, v4, p)

	if #_auto_save_list > 1 then
		v4 += 1
	elseif #_auto_save_list == 1 then
		now = os.clock()
	end
end

local function ReleaseProfileInternally(object)
	local _profile_store = object._profile_store;
	(object._is_user_mock == true and _profile_store._mock_loaded_profiles or _profile_store._loaded_profiles)[object._profile_key] = nil

	if next(_profile_store._loaded_profiles) == nil and next(_profile_store._mock_loaded_profiles) == nil then
		local index = table.find(_active_profile_stores, _profile_store)

		if index ~= nil then
			table.remove(_active_profile_stores, index)
		end
	end

	RemoveProfileFromAutoSave(object) -- equivalent call inferred; original call site unknown
	local activeSession = object.MetaData.ActiveSession
	local v12, v13

	if activeSession ~= nil then
		v12 = activeSession[1]
		v13 = activeSession[2]
	end

	object._release_listeners:Fire(v12, v13)
end

local function CheckForNewGlobalUpdates(object, _updates_latest, globalUpdates)
	local globalUpdates2 = object.GlobalUpdates
	local _pending_update_lock = globalUpdates2._pending_update_lock
	local _pending_update_clear = globalUpdates2._pending_update_clear

	for _, v12 in ipairs(globalUpdates[2]) do
		local v13 = nil

		for _, v15 in ipairs(_updates_latest[2]) do
			if v15[1] ~= v12[1] then
				continue
			end

			v13 = v15
			break
		end

		if (v13 == nil or v12[2] > v13[2] or v12[3] ~= v13[3]) ~= true then
			continue
		end

		if v12[3] == false then
			local v15 = false

			for _, v17 in ipairs(_pending_update_lock) do
				if v12[1] ~= v17 then
					continue
				end

				v15 = true
				break
			end

			if v15 == false then
				globalUpdates2._new_active_update_listeners:Fire(v12[1], v12[4])
			end
		end

		if v12[3] ~= true then
			continue
		end

		local v15 = false

		for _, v17 in ipairs(_pending_update_clear) do
			if v12[1] ~= v17 then
				continue
			end

			v15 = true
			break
		end

		if v15 ~= false then
			continue
		end

		local v17 = v12
		globalUpdates2._new_locked_update_listeners:FireUntil(function()
			return table.find(_pending_update_clear, v17[1]) == nil
		end, v12[1], v12[4])
	end
end

local function SaveProfileAsync(object, p, p2)
	if type(object.Data) ~= "table" then
		RegisterCorruption(
			object._profile_store._profile_store_name,
			object._profile_store._profile_store_scope,
			object._profile_key
		) -- equivalent call inferred; original call site unknown
		error("[ProfileService]: PROFILE DATA CORRUPTED DURING RUNTIME! Profile: " .. object:Identify())
	end

	if p == true and p2 ~= true then
		ReleaseProfileInternally(object)
	end

	v7 += 1
	local sessionLoadCount = object.MetaData.SessionLoadCount
	local v12 = true

	while v12 == true do
		if p ~= true then
			v12 = false
		end

		local v13, keyInfo = StandardProfileUpdateAsyncDataStore(object._profile_store, object._profile_key, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = nil,
			EditProfile = function(state)
				local v15 = false
				local v16 = false

				if p2 == true then
					v15 = true
				else
					local activeSession = state.MetaData.ActiveSession
					local forceLoadSession = state.MetaData.ForceLoadSession
					local sessionLoadCount2 = state.MetaData.SessionLoadCount

					if type(activeSession) == "table" then
						v15 = activeSession[1] == placeId and activeSession[2] == jobId and sessionLoadCount2 == sessionLoadCount
					end

					if type(forceLoadSession) == "table" then
						v16 = forceLoadSession[1] ~= placeId or forceLoadSession[2] ~= jobId
					end
				end

				if v15 == true then
					if p2 ~= true then
						local globalUpdate = state.GlobalUpdates[2]
						local globalUpdates = object.GlobalUpdates
						local _pending_update_lock = globalUpdates._pending_update_lock
						local _pending_update_clear = globalUpdates._pending_update_clear

						for i = 1, #globalUpdate do
							for _, v18 in ipairs(_pending_update_lock) do
								if globalUpdate[i][1] ~= v18 then
									continue
								end

								globalUpdate[i][3] = true
								break
							end
						end

						for _, v17 in ipairs(_pending_update_clear) do
							for i = 1, #globalUpdate do
								if not (globalUpdate[i][1] == v17 and globalUpdate[i][3] == true) then
									continue
								end

								table.remove(globalUpdate, i)
								break
							end
						end
					end

					state.Data = object.Data
					state.RobloxMetaData = object.RobloxMetaData
					state.UserIds = object.UserIds

					if p2 == true then
						state.MetaData = object.MetaData
						state.MetaData.ActiveSession = nil
						state.MetaData.ForceLoadSession = nil
						state.GlobalUpdates = object.GlobalUpdates._updates_latest
					else
						state.MetaData.MetaTags = object.MetaData.MetaTags
						state.MetaData.LastUpdate = os.time()

						if p == true or v16 == true then
							state.MetaData.ActiveSession = nil
						end
					end
				end
			end
		}, object._is_user_mock)

		if v13 == nil or keyInfo == nil then
			if v12 == true then
				task.wait()
			end
		else
			if p2 == true then
				break
			end

			object.KeyInfo = keyInfo
			local globalUpdates = object.GlobalUpdates
			local _updates_latest = globalUpdates._updates_latest
			local globalUpdates2 = v13.GlobalUpdates
			globalUpdates._updates_latest = globalUpdates2
			local metaData = object.MetaData
			local metaData2 = v13.MetaData
			v12 = false

			for k in pairs(v.MetaTagsUpdatedValues) do
				metaData[k] = metaData2[k]
			end

			metaData.MetaTagsLatest = metaData2.MetaTags
			local activeSession = v13.MetaData.ActiveSession
			local sessionLoadCount2 = v13.MetaData.SessionLoadCount
			local v15

			if type(activeSession) == "table" then
				v15 = activeSession[1] == placeId and activeSession[2] == jobId and sessionLoadCount2 == sessionLoadCount
			else
				v15 = false
			end

			local isActive = object:IsActive()

			if v15 == true then
				if isActive == true then
					CheckForNewGlobalUpdates(object, _updates_latest, globalUpdates2)
				end
			else
				if isActive == true then
					ReleaseProfileInternally(object)
				end

				CustomWriteQueueMarkForCleanup(object._profile_store._profile_store_lookup, object._profile_key)

				if object._hop_ready == false then
					object._hop_ready = true
					object._hop_ready_listeners:Fire()
				end
			end

			object.MetaTagsUpdated:Fire(object.MetaData.MetaTagsLatest)
			object.KeyInfoUpdated:Fire(keyInfo)
		end
	end

	v7 -= 1
end

local class3 = {}
class3.__index = class3

function class3:GetActiveUpdates()
	local result = {}

	for _, v12 in ipairs(self._updates_latest[2]) do
		if v12[3] ~= false then
			continue
		end

		local v13 = false

		if self._pending_update_lock ~= nil then
			for _, v15 in ipairs(self._pending_update_lock) do
				if v12[1] ~= v15 then
					continue
				end

				v13 = true
				break
			end
		end

		if v13 == false then
			table.insert(result, { v12[1], v12[4] })
		end
	end

	return result
end

function class3:GetLockedUpdates()
	local result = {}

	for _, v12 in ipairs(self._updates_latest[2]) do
		if v12[3] ~= true then
			continue
		end

		local v13 = false

		if self._pending_update_clear ~= nil then
			for _, v15 in ipairs(self._pending_update_clear) do
				if v12[1] ~= v15 then
					continue
				end

				v13 = true
				break
			end
		end

		if v13 == false then
			table.insert(result, { v12[1], v12[4] })
		end
	end

	return result
end

function class3:ListenToNewActiveUpdate(on_new_active_update_listeners)
	if type(on_new_active_update_listeners) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in GlobalUpdates:ListenToNewActiveUpdate()")
	end

	local _profile = self._profile

	if self._update_handler_mode == true then
		error("[ProfileService]: Can't listen to new global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._new_active_update_listeners == nil then
		error("[ProfileService]: Can't listen to new global updates in view mode")
	elseif _profile:IsActive() == false then
		return {
			Disconnect = function() end
		}
	end

	return self._new_active_update_listeners:Connect(on_new_active_update_listeners)
end

function class3:ListenToNewLockedUpdate(on_new_locked_update_listeners)
	if type(on_new_locked_update_listeners) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in GlobalUpdates:ListenToNewLockedUpdate()")
	end

	local _profile = self._profile

	if self._update_handler_mode == true then
		error("[ProfileService]: Can't listen to new global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._new_locked_update_listeners == nil then
		error("[ProfileService]: Can't listen to new global updates in view mode")
	elseif _profile:IsActive() == false then
		return {
			Disconnect = function() end
		}
	end

	return self._new_locked_update_listeners:Connect(on_new_locked_update_listeners)
end

function class3:LockActiveUpdate(value)
	if type(value) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end

	local _profile = self._profile

	if self._update_handler_mode == true then
		error("[ProfileService]: Can't lock active global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._pending_update_lock == nil then
		error("[ProfileService]: Can't lock active global updates in view mode")
	elseif _profile:IsActive() == false then
		error("[ProfileService]: PROFILE EXPIRED - Can't lock active global updates")
	end

	local v12 = nil

	for _, v14 in ipairs(self._updates_latest[2]) do
		if v14[1] ~= value then
			continue
		end

		v12 = v14
		break
	end

	if v12 == nil then
		error("[ProfileService]: Passed non-existant update_id")
	else
		local v14 = false

		for _, v16 in ipairs(self._pending_update_lock) do
			if value ~= v16 then
				continue
			end

			v14 = true
			break
		end

		if v14 == false and v12[3] == false then
			table.insert(self._pending_update_lock, value)
		end
	end
end

function class3:ClearLockedUpdate(value)
	if type(value) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end

	local _profile = self._profile

	if self._update_handler_mode == true then
		error("[ProfileService]: Can't clear locked global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._pending_update_clear == nil then
		error("[ProfileService]: Can't clear locked global updates in view mode")
	elseif _profile:IsActive() == false then
		error("[ProfileService]: PROFILE EXPIRED - Can't clear locked global updates")
	end

	local v12 = nil

	for _, v14 in ipairs(self._updates_latest[2]) do
		if v14[1] ~= value then
			continue
		end

		v12 = v14
		break
	end

	if v12 == nil then
		error("[ProfileService]: Passed non-existant update_id")
	else
		local v14 = false

		for _, v16 in ipairs(self._pending_update_clear) do
			if value ~= v16 then
				continue
			end

			v14 = true
			break
		end

		if v14 == false and v12[3] == true then
			table.insert(self._pending_update_clear, value)
		end
	end
end

function class3:AddActiveUpdate(p)
	if type(p) ~= "table" then
		error("[ProfileService]: Invalid update_data")
	end

	if self._new_active_update_listeners == nil then
		if self._update_handler_mode ~= true then
			error("[ProfileService]: Can't add active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
		end
	else
		error("[ProfileService]: Can't add active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	end

	local _updates_latest = self._updates_latest
	local v12 = _updates_latest[1] + 1
	_updates_latest[1] = v12
	table.insert(_updates_latest[2], {
		v12,
		1,
		false,
		p
	})
end

function class3:ChangeActiveUpdate(value, p)
	if type(value) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end

	if type(p) ~= "table" then
		error("[ProfileService]: Invalid update_data")
	end

	if self._new_active_update_listeners == nil then
		if self._update_handler_mode ~= true then
			error("[ProfileService]: Can't change active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
		end
	else
		error("[ProfileService]: Can't change active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	end

	local _updates_latest = self._updates_latest
	local v12 = nil

	for _, v14 in ipairs(_updates_latest[2]) do
		if value ~= v14[1] then
			continue
		end

		v12 = v14
		break
	end

	if v12 == nil then
		error("[ProfileService]: Passed non-existant update_id")
		return
	end

	if v12[3] == true then
		error("[ProfileService]: Can't change locked global update")
	end

	v12[2] += 1
	v12[4] = p
end

function class3:ClearActiveUpdate(value)
	if type(value) ~= "number" then
		error("[ProfileService]: Invalid update_id argument")
	end

	if self._new_active_update_listeners == nil then
		if self._update_handler_mode ~= true then
			error("[ProfileService]: Can't clear active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
		end
	else
		error("[ProfileService]: Can't clear active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	end

	local _updates_latest = self._updates_latest
	local v12 = nil
	local v13 = nil

	for i, v15 in ipairs(_updates_latest[2]) do
		if value ~= v15[1] then
			continue
		end

		v13 = i
		v12 = v15
		break
	end

	if v12 == nil then
		error("[ProfileService]: Passed non-existant update_id")
		return
	end

	if v12[3] == true then
		error("[ProfileService]: Can't clear locked global update")
	end

	table.remove(_updates_latest[2], v13)
end

local class4 = {}
class4.__index = class4

function class4:IsActive()
	return (self._is_user_mock == true and self._profile_store._mock_loaded_profiles or self._profile_store._loaded_profiles)[self._profile_key] == self
end

function class4.GetMetaTag(p, p2)
	if p.MetaData == nil then
		return nil
	end

	return p.MetaData.MetaTags[p2]
end

function class4.SetMetaTag(p, value, p2)
	if type(value) == "string" then
		if string.len(value) == 0 then
			error("[ProfileService]: Invalid tag_name")
		end
	else
		error("[ProfileService]: tag_name must be a string")
	end

	p.MetaData.MetaTags[value] = p2
end

function class4:Reconcile()
	ReconcileTable(self.Data, self._profile_store._profile_template)
end

function class4:ListenToRelease(on_release_listeners)
	if type(on_release_listeners) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in Profile:ListenToRelease()")
	end

	if self._view_mode == true then
		return {
			Disconnect = function() end
		}
	end

	if self:IsActive() ~= false then
		return self._release_listeners:Connect(on_release_listeners)
	end

	local activeSession = self.MetaData.ActiveSession
	local v12, v13

	if activeSession ~= nil then
		v12 = activeSession[1]
		v13 = activeSession[2]
	end

	on_release_listeners(v12, v13)
	return {
		Disconnect = function() end
	}
end

function class4:Save()
	if self._view_mode == true then
		error("[ProfileService]: Can't save Profile in view mode - Should you be calling :OverwriteAsync() instead?")
	end

	if self:IsActive() == false then
		warn("[ProfileService]: Attempted saving an inactive profile " .. self:Identify() .. "; Traceback:\n" .. debug.traceback())
		return
	end

	local customWriteQueueEmptyFor = IsCustomWriteQueueEmptyFor(
		self._profile_store._profile_store_lookup,
		self._profile_key
	) -- equivalent call inferred; original call site unknown

	if customWriteQueueEmptyFor == true then
		RemoveProfileFromAutoSave(self) -- equivalent call inferred; original call site unknown
		table.insert(_auto_save_list, v4, self)

		if #_auto_save_list > 1 then
			v4 += 1
		elseif #_auto_save_list == 1 then
			now = os.clock()
		end

		task.spawn(SaveProfileAsync, self)
	end
end

function class4:Release()
	if self._view_mode == true then
		return
	end

	if self:IsActive() == true then
		task.spawn(SaveProfileAsync, self, true)
	end
end

function class4:ListenToHopReady(on_hop_ready_listeners)
	if type(on_hop_ready_listeners) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in Profile:ListenToHopReady()")
	end

	if self._view_mode == true then
		return {
			Disconnect = function() end
		}
	end

	if self._hop_ready ~= true then
		return self._hop_ready_listeners:Connect(on_hop_ready_listeners)
	end

	task.spawn(on_hop_ready_listeners)
	return {
		Disconnect = function() end
	}
end

function class4:AddUserId(value)
	if type(value) ~= "number" or value % 1 ~= 0 then
		warn("[ProfileService]: Invalid UserId argument for :AddUserId() (" .. tostring(value) .. "); Traceback:\n" .. debug.traceback())
		return
	end

	if value < 0 and self._is_user_mock ~= true and v9 ~= true then
		return
	end

	if table.find(self.UserIds, value) == nil then
		table.insert(self.UserIds, value)
	end
end

function class4.RemoveUserId(p, value)
	if type(value) ~= "number" or value % 1 ~= 0 then
		warn("[ProfileService]: Invalid UserId argument for :RemoveUserId() (" .. tostring(value) .. "); Traceback:\n" .. debug.traceback())
		return
	end

	local index = table.find(p.UserIds, value)

	if index ~= nil then
		table.remove(p.UserIds, index)
	end
end

function class4:Identify()
	return IdentifyProfile(
		self._profile_store._profile_store_name,
		self._profile_store._profile_store_scope,
		self._profile_key
	)
end

function class4:ClearGlobalUpdates()
	if self._view_mode ~= true then
		error("[ProfileService]: :ClearGlobalUpdates() can only be used in view mode")
	end

	local globalUpdates = {
		_updates_latest = {
			0,
			{}
		},
		_profile = self
	}
	setmetatable(globalUpdates, class3)
	self.GlobalUpdates = globalUpdates
end

function class4:OverwriteAsync()
	if self._view_mode ~= true then
		error("[ProfileService]: :OverwriteAsync() can only be used in view mode")
	end

	SaveProfileAsync(self, nil, true)
end

local class5 = {}
class5.__index = class5

function class5:_MoveQueue()
	while #self._query_queue > 0 do
		local v12 = table.remove(self._query_queue, 1)
		task.spawn(v12)

		if self._is_query_yielded == true then
			break
		end
	end
end

function class5:NextAsync(p)
	if self._profile_store == nil then
		return nil
	end

	local v12 = nil
	local v13 = false

	local function query_job()
		if self._query_failure == true then
			v13 = true
		elseif self._query_pages == nil then
			self._is_query_yielded = true
			task.spawn(function()
				v12 = self:NextAsync(true)
				v13 = true
			end)
			local success, result = pcall(function()
				self._query_pages = self._profile_store._global_data_store:ListVersionsAsync(
					self._profile_key,
					self._sort_direction,
					self._min_date,
					self._max_date
				)
				self._query_index = 0
			end)

			if success == false or self._query_pages == nil then
				warn("[ProfileService]: Version query fail - " .. tostring(result))
				self._query_failure = true
			end

			self._is_query_yielded = false
			self:_MoveQueue()
		else
			local v14 = self._query_pages:GetCurrentPage()[self._query_index + 1]

			if self._query_pages.IsFinished == true and v14 == nil then
				v13 = true
			elseif v14 == nil then
				self._is_query_yielded = true
				task.spawn(function()
					v12 = self:NextAsync(true)
					v13 = true
				end)

				if pcall(function()
					self._query_pages:AdvanceToNextPageAsync()
					self._query_index = 0
				end) == false or #self._query_pages:GetCurrentPage() == 0 then
					self._query_failure = true
				end

				self._is_query_yielded = false
				self:_MoveQueue()
			else
				self._query_index += 1
				v12 = self._profile_store:ViewProfileAsync(self._profile_key, v14.Version)
				v13 = true
			end
		end
	end

	if self._is_query_yielded == false then
		query_job()
	elseif p == true then
		table.insert(self._query_queue, 1, query_job)
	else
		table.insert(self._query_queue, query_job)
	end

	while v13 == false do
		task.wait()
	end

	return v12
end

local class6 = {}
class6.__index = class6

function class6:LoadProfileAsync(profile_key, value2, p)
	local v12 = value2 or "ForceLoad"

	if self._profile_template == nil then
		error("[ProfileService]: Profile template not set - ProfileStore:LoadProfileAsync() locked for this ProfileStore")
	end

	if type(profile_key) == "string" then
		if string.len(profile_key) == 0 then
			error("[ProfileService]: Invalid profile_key")
		end
	else
		error("[ProfileService]: profile_key must be a string")
	end

	if type(v12) ~= "function" and v12 ~= "ForceLoad" and v12 ~= "Steal" then
		error("[ProfileService]: Invalid not_released_handler")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self) -- equivalent call inferred; original call site unknown
	local is_user_mock = p == v10

	for _, _active_profile_store in ipairs(_active_profile_stores) do
		if not (_active_profile_store._profile_store_lookup == self._profile_store_lookup and (is_user_mock == true and _active_profile_store._mock_loaded_profiles or _active_profile_store._loaded_profiles)[profile_key] ~= nil) then
			continue
		end

		local _profile_store_name = self._profile_store_name
		local _profile_store_scope = self._profile_store_scope
		error("[ProfileService]: Profile " .. string.format(
			"[Store:\"%s\";%sKey:\"%s\"]",
			_profile_store_name,
			_profile_store_scope == nil and "" or string.format("Scope:\"%s\";", _profile_store_scope) or "",
			profile_key
		) .. " is already loaded in this session")
	end

	v6 += 1
	local v14 = v12 == "ForceLoad"
	local count = 0
	local v15 = v14
	local v16 = false
	local v17

	if v12 == "Steal" then
		v17 = true
	else
		v17 = false
	end

	while ProfileService.ServiceLocked == false do
		local _mock_profile_load_jobs = is_user_mock == true and self._mock_profile_load_jobs or self._profile_load_jobs
		local v18 = v5 + 1
		v5 = v18
		local _mock_profile_load_job = _mock_profile_load_jobs[profile_key]
		local v19, keyInfo

		if _mock_profile_load_job == nil then
			local v21 = { v18, nil }
			_mock_profile_load_jobs[profile_key] = v21
			v21[2] = table.pack(StandardProfileUpdateAsyncDataStore(self, profile_key, {
				ExistingProfileHandle = function(p2)
					if ProfileService.ServiceLocked == false then
						local activeSession = p2.MetaData.ActiveSession
						local forceLoadSession = p2.MetaData.ForceLoadSession

						if activeSession == nil then
							p2.MetaData.ActiveSession = { placeId, jobId }
							p2.MetaData.ForceLoadSession = nil
						elseif type(activeSession) == "table" then
							local v22

							if activeSession[1] == placeId then
								v22 = activeSession[2] == jobId
							else
								v22 = false
							end

							if v22 == false then
								local lastUpdate = p2.MetaData.LastUpdate

								if lastUpdate == nil or not (os.time() - lastUpdate > v.AssumeDeadSessionLock) then
									if v16 == true or v17 == true then
										local v23

										if forceLoadSession == nil or forceLoadSession[1] ~= placeId then
											v23 = false
										else
											v23 = forceLoadSession[2] == jobId
										end

										if v23 == true or v17 == true then
											p2.MetaData.ActiveSession = { placeId, jobId }
											p2.MetaData.ForceLoadSession = nil
										end
									elseif v15 == true then
										p2.MetaData.ForceLoadSession = { placeId, jobId }
									end
								else
									p2.MetaData.ActiveSession = { placeId, jobId }
									p2.MetaData.ForceLoadSession = nil
								end
							else
								p2.MetaData.ForceLoadSession = nil
							end
						end
					end
				end,
				MissingProfileHandle = function(p2)
					p2.Data = DeepCopyTable(self._profile_template)
					p2.MetaData = {
						ProfileCreateTime = os.time(),
						SessionLoadCount = 0,
						ActiveSession = { placeId, jobId },
						ForceLoadSession = nil,
						MetaTags = {}
					}
				end,
				EditProfile = function(p2)
					if ProfileService.ServiceLocked == false then
						local activeSession = p2.MetaData.ActiveSession

						if activeSession ~= nil then
							local v22

							if activeSession[1] == placeId then
								v22 = activeSession[2] == jobId
							else
								v22 = false
							end

							if v22 == true then
								p2.MetaData.SessionLoadCount = p2.MetaData.SessionLoadCount + 1
								p2.MetaData.LastUpdate = os.time()
							end
						end
					end
				end
			}, is_user_mock))

			if v21[1] == v18 then
				v19, keyInfo = table.unpack(v21[2])
				_mock_profile_load_jobs[profile_key] = nil
			else
				v6 -= 1
				return nil
			end
		else
			_mock_profile_load_job[1] = v18

			while _mock_profile_load_job[2] == nil do
				task.wait()
			end

			if _mock_profile_load_job[1] == v18 then
				v19, keyInfo = table.unpack(_mock_profile_load_job[2])
				_mock_profile_load_jobs[profile_key] = nil
			else
				v6 -= 1
				return nil
			end
		end

		if v19 == nil or keyInfo == nil then
			task.wait()
		else
			local activeSession = v19.MetaData.ActiveSession

			if type(activeSession) ~= "table" then
				v6 -= 1
				return nil
			end

			local v21

			if activeSession[1] == placeId then
				v21 = activeSession[2] == jobId
			else
				v21 = false
			end

			if v21 == true then
				v19.MetaData.MetaTagsLatest = DeepCopyTable(v19.MetaData.MetaTags)
				local globalUpdates = {
					_updates_latest = v19.GlobalUpdates,
					_pending_update_lock = {},
					_pending_update_clear = {},
					_new_active_update_listeners = v3.NewScriptSignal(),
					_new_locked_update_listeners = v3.NewScriptSignal(),
					_profile = nil
				}
				setmetatable(globalUpdates, class3)
				local profile = {
					Data = v19.Data,
					MetaData = v19.MetaData,
					MetaTagsUpdated = v3.NewScriptSignal(),
					RobloxMetaData = v19.RobloxMetaData or {},
					UserIds = v19.UserIds or {},
					KeyInfo = keyInfo,
					KeyInfoUpdated = v3.NewScriptSignal(),
					GlobalUpdates = globalUpdates,
					_profile_store = self,
					_profile_key = profile_key,
					_release_listeners = v3.NewScriptSignal(),
					_hop_ready_listeners = v3.NewScriptSignal(),
					_hop_ready = false,
					_load_timestamp = os.clock(),
					_is_user_mock = is_user_mock
				}
				setmetatable(profile, class4)
				globalUpdates._profile = profile

				if next(self._loaded_profiles) == nil and next(self._mock_loaded_profiles) == nil then
					table.insert(_active_profile_stores, self)
				end

				if is_user_mock == true then
					self._mock_loaded_profiles[profile_key] = profile
				else
					self._loaded_profiles[profile_key] = profile
				end

				table.insert(_auto_save_list, v4, profile)

				if #_auto_save_list > 1 then
					v4 += 1
				elseif #_auto_save_list == 1 then
					now = os.clock()
				end

				if ProfileService.ServiceLocked == true then
					SaveProfileAsync(profile, true)
					profile = nil
				end

				v6 -= 1
				return profile
			elseif v14 == true then
				local forceLoadSession = v19.MetaData.ForceLoadSession
				local v22

				if forceLoadSession == nil or forceLoadSession[1] ~= placeId then
					v22 = false
				else
					v22 = forceLoadSession[2] == jobId
				end

				if v22 ~= true then
					v6 -= 1
					return nil
				end

				if v15 == false then
					count += 1

					if count == v.ForceLoadMaxSteps then
						v16 = true
					end
				end

				task.wait()
				v15 = false
			elseif v17 == true then
				task.wait()
			else
				local v22 = v12(activeSession[1], activeSession[2])

				if v22 == "Repeat" then
					task.wait()
				else
					if v22 == "Cancel" then
						v6 -= 1
						return nil
					end

					if v22 == "ForceLoad" then
						v14 = true
						v15 = true
						task.wait()
					elseif v22 == "Steal" then
						v17 = true
						task.wait()
					else
						local v23 = tostring(v22)
						local typeName = type(v22)
						local _profile_store_name = self._profile_store_name
						local _profile_store_scope = self._profile_store_scope
						error("[ProfileService]: Invalid return from not_released_handler (\"" .. v23 .. "\")(" .. typeName .. ");" .. "\n" .. string.format(
							"[Store:\"%s\";%sKey:\"%s\"]",
							_profile_store_name,
							_profile_store_scope == nil and "" or string.format("Scope:\"%s\";", _profile_store_scope) or "",
							profile_key
						) .. " Traceback:\n" .. debug.traceback())
					end
				end
			end
		end
	end

	v6 -= 1
	return nil
end

function class6:GlobalUpdateProfileAsync(value, callback, p2)
	if type(value) ~= "string" or string.len(value) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if type(callback) ~= "function" then
		error("[ProfileService]: Invalid update_handler")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self) -- equivalent call inferred; original call site unknown

	while ProfileService.ServiceLocked == false do
		local standardProfileUpdateAsyncDataStore = StandardProfileUpdateAsyncDataStore(self, value, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = nil,
			EditProfile = function(p3)
				local v13 = {
					_updates_latest = p3.GlobalUpdates,
					_update_handler_mode = true
				}
				setmetatable(v13, class3)
				callback(v13)
			end
		}, p2 == v10)
		CustomWriteQueueMarkForCleanup(self._profile_store_lookup, value)

		if standardProfileUpdateAsyncDataStore == nil then
			task.wait()
		else
			local v13 = {
				_updates_latest = standardProfileUpdateAsyncDataStore.GlobalUpdates
			}
			setmetatable(v13, class3)
			return v13
		end
	end

	return nil
end

function class6:ViewProfileAsync(profile_key, p2, p3)
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self) -- equivalent call inferred; original call site unknown

	if p2 ~= nil and (p3 == v10 or v9 == true) then
		return nil
	end

	while ProfileService.ServiceLocked == false do
		local v12, keyInfo = StandardProfileUpdateAsyncDataStore(self, profile_key, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = function(p4)
				p4.Data = DeepCopyTable(self._profile_template)
				p4.MetaData = {
					ProfileCreateTime = os.time(),
					SessionLoadCount = 0,
					ActiveSession = nil,
					ForceLoadSession = nil,
					MetaTags = {}
				}
			end,
			EditProfile = nil
		}, p3 == v10, true, p2)
		CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)

		if v12 == nil then
			task.wait()
		else
			if keyInfo == nil then
				return nil
			end

			local globalUpdates = {
				_updates_latest = v12.GlobalUpdates,
				_profile = nil
			}
			setmetatable(globalUpdates, class3)
			local profile = {
				Data = v12.Data,
				MetaData = v12.MetaData,
				MetaTagsUpdated = v3.NewScriptSignal(),
				RobloxMetaData = v12.RobloxMetaData or {},
				UserIds = v12.UserIds or {},
				KeyInfo = keyInfo,
				KeyInfoUpdated = v3.NewScriptSignal(),
				GlobalUpdates = globalUpdates,
				_profile_store = self,
				_profile_key = profile_key,
				_view_mode = true,
				_load_timestamp = os.clock()
			}
			setmetatable(profile, class4)
			globalUpdates._profile = profile
			return profile
		end
	end

	return nil
end

function class6.ProfileVersionQuery(profile_store, profile_key, sort_direction, unixTimestampMillis, unixTimestampMillis2, p3)
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return (setmetatable({}, class5))
	end

	WaitForPendingProfileStore(profile_store) -- equivalent call inferred; original call site unknown

	if p3 == v10 or v9 == true then
		error("[ProfileService]: :ProfileVersionQuery() is not supported in mock mode")
	end

	if sort_direction ~= nil and (typeof(sort_direction) ~= "EnumItem" or sort_direction.EnumType ~= Enum.SortDirection) then
		error("[ProfileService]: Invalid sort_direction (" .. tostring(sort_direction) .. ")")
	end

	if unixTimestampMillis ~= nil and typeof(unixTimestampMillis) ~= "DateTime" and typeof(unixTimestampMillis) ~= "number" then
		error("[ProfileService]: Invalid min_date (" .. tostring(unixTimestampMillis) .. ")")
	end

	if unixTimestampMillis2 ~= nil and typeof(unixTimestampMillis2) ~= "DateTime" and typeof(unixTimestampMillis2) ~= "number" then
		error("[ProfileService]: Invalid max_date (" .. tostring(unixTimestampMillis2) .. ")")
	end

	if typeof(unixTimestampMillis) == "DateTime" then
		unixTimestampMillis = unixTimestampMillis.UnixTimestampMillis or unixTimestampMillis
	end

	if typeof(unixTimestampMillis2) == "DateTime" then
		unixTimestampMillis2 = unixTimestampMillis2.UnixTimestampMillis or unixTimestampMillis2
	end

	local v12 = {
		_profile_store = profile_store,
		_profile_key = profile_key,
		_sort_direction = sort_direction,
		_min_date = unixTimestampMillis,
		_max_date = unixTimestampMillis2,
		_query_pages = nil,
		_query_index = 0,
		_query_failure = false,
		_is_query_yielded = false,
		_query_queue = {}
	}
	setmetatable(v12, class5)
	return v12
end

function class6:WipeProfileAsync(value, p2)
	if type(value) ~= "string" or string.len(value) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return false
	end

	WaitForPendingProfileStore(self) -- equivalent call inferred; original call site unknown
	local v12

	if p2 == v10 then
		local v13 = _user_mock_data_store[self._profile_store_lookup]

		if v13 ~= nil then
			v13[value] = nil
		end

		task.wait()
		v12 = true
	elseif v9 == true then
		local v13 = _mock_data_store[self._profile_store_lookup]

		if v13 ~= nil then
			v13[value] = nil
		end

		task.wait()
		v12 = true
	else
		v12 = pcall(function()
			self._global_data_store:RemoveAsync(value)
		end)
	end

	CustomWriteQueueMarkForCleanup(self._profile_store_lookup, value)
	return v12
end

function ProfileService.GetProfileStore(value, profile_template)
	local name = nil
	local scope = nil

	if type(value) == "string" then
		name = value
	elseif type(value) == "table" then
		name = value.Name
		scope = value.Scope
	else
		error("[ProfileService]: Invalid or missing profile_store_index")
	end

	if name == nil or type(name) ~= "string" then
		error("[ProfileService]: Missing or invalid \"Name\" parameter")
	elseif string.len(name) == 0 then
		error("[ProfileService]: ProfileStore name cannot be an empty string")
	end

	if scope ~= nil and (type(scope) ~= "string" or string.len(scope) == 0) then
		error("[ProfileService]: Invalid \"Scope\" parameter")
	end

	if type(profile_template) ~= "table" then
		error("[ProfileService]: Invalid profile_template")
	end

	local v12 = nil
	v12 = {
		Mock = {
			LoadProfileAsync = function(self, p2, p3)
				return v12:LoadProfileAsync(p2, p3, v10)
			end,
			GlobalUpdateProfileAsync = function(self, p2, p3)
				return v12:GlobalUpdateProfileAsync(p2, p3, v10)
			end,
			ViewProfileAsync = function(self, p2, p3)
				return v12:ViewProfileAsync(p2, p3, v10)
			end,
			FindProfileVersionAsync = function(self, p2, p3, p4, p5)
				return v12:FindProfileVersionAsync(p2, p3, p4, p5, v10)
			end,
			WipeProfileAsync = function(self, p2)
				return v12:WipeProfileAsync(p2, v10)
			end
		},
		_profile_store_name = name,
		_profile_store_scope = scope,
		_profile_store_lookup = name .. "\0" .. (scope or ""),
		_profile_template = profile_template,
		_global_data_store = nil,
		_loaded_profiles = {},
		_profile_load_jobs = {},
		_mock_loaded_profiles = {},
		_mock_profile_load_jobs = {},
		_is_pending = false
	}
	setmetatable(v12, class6)
	local dataStoreOptions = Instance.new("DataStoreOptions")
	dataStoreOptions:SetExperimentalFeatures({
		v2 = true
	})

	if v8 == true then
		v12._is_pending = true
		task.spawn(function()
			WaitForLiveAccessCheck() -- equivalent call inferred; original call site unknown

			if v9 == false then
				v12._global_data_store = DataStoreService:GetDataStore(name, scope, dataStoreOptions)
			end

			v12._is_pending = false
		end)
	elseif v9 == false then
		v12._global_data_store = DataStoreService:GetDataStore(name, scope, dataStoreOptions)
	end

	return v12
end

function ProfileService.IsLive()
	WaitForLiveAccessCheck() -- equivalent call inferred; original call site unknown
	return v9 == false
end

if isStudio == true then
	v8 = true
	task.spawn(function()
		local success, result = pcall(function()
			DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
		end)
		local v12

		if success == false then
			v12 = string.find(result, "ConnectFail", 1, true) ~= nil
		else
			v12 = false
		end

		if v12 == true then
			warn("[ProfileService]: No internet access - check your network connection")
		end

		if success == false and (string.find(result, "403", 1, true) ~= nil or string.find(
			result,
			"must publish",
			1,
			true
		) ~= nil or v12 == true) then
			v9 = true
			ProfileService._use_mock_data_store = true
			print("[ProfileService]: Roblox API services unavailable - data will not be saved")
		else
			print("[ProfileService]: Roblox API services available - data will be saved")
		end

		v8 = false
	end)
end

RunService.Heartbeat:Connect(function()
	local count = #_auto_save_list

	if count > 0 then
		local v12 = v.AutoSaveProfiles / count
		local now3 = os.clock()

		while v12 < now3 - now do
			now += v12
			local v13 = _auto_save_list[v4]

			if now3 - v13._load_timestamp < v.AutoSaveProfiles then
				v13 = nil

				for _ = 1, count - 1 do
					v4 += 1

					if count < v4 then
						v4 = 1
					end

					v13 = _auto_save_list[v4]

					if now3 - v13._load_timestamp >= v.AutoSaveProfiles then
						break
					else
						v13 = nil
					end
				end
			end

			v4 += 1

			if count < v4 then
				v4 = 1
			end

			if v13 ~= nil then
				task.spawn(SaveProfileAsync, v13)
			end
		end
	end

	if ProfileService.CriticalState == false then
		if #_issue_queue >= v.IssueCountForCriticalState then
			ProfileService.CriticalState = true
			ProfileService.CriticalStateSignal:Fire(true)
			now2 = os.clock()
			warn("[ProfileService]: Entered critical state")
		end
	elseif #_issue_queue >= v.IssueCountForCriticalState then
		now2 = os.clock()
	elseif os.clock() - now2 > v.CriticalStateLast then
		ProfileService.CriticalState = false
		ProfileService.CriticalStateSignal:Fire(false)
		warn("[ProfileService]: Critical state ended")
	end

	while true do
		local v12 = _issue_queue[1]

		if v12 == nil then
			break
		end

		if os.clock() - v12 > v.IssueLast then
			table.remove(_issue_queue, 1)
		else
			break
		end
	end
end)
task.spawn(function()
	WaitForLiveAccessCheck() -- equivalent call inferred; original call site unknown
	v3.ConnectToOnClose(function()
		ProfileService.ServiceLocked = true
		local v12 = {}
		local v13 = 0

		for i, v14 in ipairs(_auto_save_list) do
			v12[i] = v14
		end

		for _, v14 in ipairs(v12) do
			if v14:IsActive() ~= true then
				continue
			end

			v13 += 1
			local v15 = v14
			task.spawn(function()
				SaveProfileAsync(v15, true)
				v13 -= 1
			end)
		end

		while v13 > 0 or v6 > 0 or v7 > 0 do
			task.wait()
		end
	end, v9 == false)
end)
return ProfileService