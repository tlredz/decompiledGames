local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
local AdminConfig = RunService:IsServer() and require(ServerScriptService.AdminConfig)
local ProfileAccess = {}
local v = {}
local v2 = {}

local function GetRoleForUserId(p: number)
	if not AdminConfig then
		return nil
	end

	local priority = -1
	local v3 = nil

	for k, v4 in AdminConfig.ROLES do
		if not (table.find(v4.UserIds, p) and priority < v4.Priority) then
			continue
		end

		priority = v4.Priority
		v3 = k
	end

	return v3
end

local function GetLastUpdate(p)
	local updatedTime = tonumber(p and p.KeyInfo and p.KeyInfo.UpdatedTime) or 0

	if updatedTime > 100000000000 then
		updatedTime /= 1000
	end

	return (math.floor(updatedTime))
end

function ProfileAccess.GetLocalPlayer(p: number)
	return Players:GetPlayerByUserId(p)
end

function ProfileAccess.Invalidate(p: number)
	v[p] = nil
end

function ProfileAccess.Read(p: number)
	assert(RunService:IsServer(), "ProfileAccess.Read is server-only")
	local localPlayer = ProfileAccess.GetLocalPlayer(p)

	if localPlayer then
		ProfileAccess.Invalidate(p)
		local playerData = DataManager:GetPlayerData(localPlayer)
		local v3 = {
			Ok = playerData ~= nil,
			Data = playerData,
			IsLocal = true,
			IsSessionActive = true,
			IsOnlineElsewhere = false,
			LastUpdate = 0,
			ServerPlaceId = 0,
			ServerJobId = 0,
			Message = 0
		}
		local profile = DataManager.Profiles[localPlayer]
		local updatedTime = tonumber(profile and profile.KeyInfo and profile.KeyInfo.UpdatedTime) or 0

		if updatedTime > 100000000000 then
			updatedTime /= 1000
		end

		v3.LastUpdate = math.floor(updatedTime)
		v3.ServerPlaceId = game.PlaceId
		v3.ServerJobId = game.JobId
		v3.Message = playerData and "" or "Profile is still loading"
		return v3
	else
		local v3 = v[p]

		if v3 and v3.ExpiresAt > os.clock() then
			return v3.Result
		end

		local v4 = v2[p]

		if v4 then
			v4.Event:Wait()
			local v5 = v[p]

			if v5 then
				return v5.Result
			end

			return {
				Ok = false,
				Data = nil,
				IsLocal = false,
				IsSessionActive = false,
				IsOnlineElsewhere = false,
				LastUpdate = 0,
				ServerPlaceId = nil,
				ServerJobId = nil,
				Message = "Offline profile read did not complete"
			}
		else
			local bindableEvent = Instance.new("BindableEvent")
			v2[p] = bindableEvent
			local success, result = pcall(function()
				return DataManager.PlayerStore:GetAsync((tostring(p)))
			end)
			local v5

			if success then
				if result then
					local isSessionActive = result.Session ~= nil
					local isOnlineElsewhere = isSessionActive and result.Session.JobId ~= game.JobId
					v5 = {
						Ok = true,
						Data = result.Data,
						IsLocal = false,
						IsSessionActive = isSessionActive,
						IsOnlineElsewhere = isOnlineElsewhere,
						LastUpdate = 0,
						ServerPlaceId = 0,
						ServerJobId = 0,
						Message = ""
					}
					local updatedTime = tonumber(result and result.KeyInfo and result.KeyInfo.UpdatedTime) or 0

					if updatedTime > 100000000000 then
						updatedTime /= 1000
					end

					v5.LastUpdate = math.floor(updatedTime)
					local serverPlaceId

					if result.Session then
						serverPlaceId = result.Session.PlaceId or nil
					end

					v5.ServerPlaceId = serverPlaceId
					v5.ServerJobId = result.Session and result.Session.JobId or nil
				else
					v5 = {
						Ok = false,
						Data = nil,
						IsLocal = false,
						IsSessionActive = false,
						IsOnlineElsewhere = false,
						LastUpdate = 0,
						ServerPlaceId = nil,
						ServerJobId = nil,
						Message = "No saved profile"
					}
				end
			else
				v5 = {
					Ok = false,
					Data = nil,
					IsLocal = false,
					IsSessionActive = false,
					IsOnlineElsewhere = false,
					LastUpdate = 0,
					ServerPlaceId = nil,
					ServerJobId = nil,
					Message = tostring(result)
				}
			end

			v[p] = {
				ExpiresAt = os.clock() + 3,
				Result = v5
			}
			v2[p] = nil
			bindableEvent:Fire()
			task.defer(bindableEvent.Destroy, bindableEvent)
			return v5
		end
	end
end

function ProfileAccess.GetPresence(p)
	if p.IsLocal then
		return "In Server"
	end

	if p.IsOnlineElsewhere then
		return "Another Server"
	end

	return "Offline"
end

function ProfileAccess.Write(p: number, items)
	assert(RunService:IsServer(), "ProfileAccess.Write is server-only")
	ProfileAccess.Invalidate(p)
	local localPlayer = ProfileAccess.GetLocalPlayer(p)

	if localPlayer then
		if not DataManager:GetPlayerData(localPlayer) then
			return false, "Profile is still loading"
		end

		for k, item in items do
			local store = DataManager:GetStore(localPlayer, k)

			if not store then
				return false, (`Unknown data key: {k}`)
			end

			store:Set(item)
		end

		DataManager:Save(localPlayer)
		return true, "Saved to the live profile"
	else
		local success, result = pcall(function()
			local async = DataManager.PlayerStore:GetAsync((tostring(p)))

			if not async then
				return "No saved profile"
			end

			if async.Session ~= nil then
				return "Player is online in another server; editing is disabled"
			end

			local data = async.Data

			for k, item in items do
				if data[k] == nil then
					return (`Unknown data key: {k}`)
				else
					data[k] = item
				end
			end

			async:SetAsync()
			return nil
		end)
		ProfileAccess.Invalidate(p)

		if not success then
			return false, (tostring(result))
		end

		if result then
			return false, result
		end

		return true, "Saved to the offline profile"
	end
end

function ProfileAccess:HasPermission(p2: string)
	assert(RunService:IsServer(), "ProfileAccess.HasPermission is server-only")
	return AdminConfig:HasPermission(self, p2)
end

function ProfileAccess.CanTarget(p, p2: number)
	assert(RunService:IsServer(), "ProfileAccess.CanTarget is server-only")
	local role = AdminConfig:GetRole(p)
	local roleForUserId = GetRoleForUserId(p2)
	local priority = AdminConfig:GetPriority(role)
	local priority2 = AdminConfig:GetPriority(roleForUserId)

	if roleForUserId and priority <= priority2 then
		return false, "You cannot target an administrator with equal or higher priority"
	end

	return true, ""
end

function ProfileAccess:GetRole()
	return GetRoleForUserId(self) or "Player"
end

return ProfileAccess