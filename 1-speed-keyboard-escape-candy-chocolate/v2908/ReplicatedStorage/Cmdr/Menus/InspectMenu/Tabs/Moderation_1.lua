local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local BanManager = RunService:IsServer() and require(ServerScriptService.BanManager)
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
local WebhookLogger = RunService:IsServer() and require(ServerScriptService.WebhookLogger)
local v = {
	TempBan = "cui.inspect.moderation.ban",
	Unban = "cui.inspect.moderation.unban",
	LeaderboardBan = "cui.inspect.moderation.lbban",
	LeaderboardUnban = "cui.inspect.moderation.lbban",
	TeleportToTarget = "cui.inspect.moderation.tptothem",
	TeleportTargetToMe = "cui.inspect.moderation.tphere",
	EraseData = "cui.inspect.moderation.erase"
}

for _, v2 in v do
	assert(AdminPermissions.registerPermission(v2), (`Invalid moderation permission {v2}`))
end

local function FormatValue(value)
	if type(value) == "string" then
		return value
	end

	local success, result = pcall(HttpService.JSONEncode, HttpService, value)

	if success then
		return result
	end

	return (tostring(value))
end

local function FormatHistory(data)
	local result = {}
	local v2 = {
		Block = true,
		Reason = true,
		Time = true,
		Level = true,
		Required = true
	}

	local function Append(list, source: string)
		if type(list) ~= "table" then
			return
		end

		for i, v3 in ipairs(list) do
			if type(v3) == "table" then
				local v4 = {}

				for k in v3 do
					if type(k) ~= "string" or v2[k] then
						continue
					end

					table.insert(v4, k)
				end

				table.sort(v4)
				local v5 = {}

				for _, v6 in v4 do
					local item = v3[v6]
					local result2

					if type(item) == "string" then
						result2 = item
					else
						local success
						success, result2 = pcall(HttpService.JSONEncode, HttpService, item)

						if not success then
							result2 = tostring(item)
						end
					end

					table.insert(v5, (`{v6}: {result2}`))
				end

				table.insert(result, {
					Source = source,
					Index = i,
					Block = tostring(v3.Block or "Unknown"),
					Reason = tostring(v3.Reason or "Unknown detection"),
					Timestamp = tonumber(v3.Time) or 0,
					Level = tonumber(v3.Level),
					Required = tonumber(v3.Required),
					Details = table.concat(v5, " | ")
				})
			else
				local result2

				if type(v3) == "string" then
					result2 = v3
				else
					local success
					success, result2 = pcall(HttpService.JSONEncode, HttpService, v3)

					if not success then
						result2 = tostring(v3)
					end
				end

				table.insert(result, {
					Source = source,
					Index = i,
					Block = "Unknown",
					Reason = "Legacy entry",
					Timestamp = 0,
					Level = nil,
					Required = nil,
					Details = result2
				})
			end
		end
	end

	Append(data.CheatHistory, "Legacy")
	Append(data.CheatHistory2, "Shield")
	return result
end

local function GetTargetReference(userId: number)
	local localPlayer = ProfileAccess.GetLocalPlayer(userId)
	local name

	if localPlayer then
		name = localPlayer.Name
	else
		name = tostring(userId)
	end

	if not localPlayer then
		pcall(function()
			name = Players:GetNameFromUserIdAsync(userId)
		end)
	end

	return {
		Name = name,
		UserId = userId
	}
end

local function BuildResponse(userId: number, p: string?, ok: boolean?)
	local v2 = ProfileAccess.Read(userId)
	local ban = BanManager:GetBan(userId)
	local banStatus

	if ban then
		local expiry = tonumber(ban.expiry)
		local v4 = not expiry and "Permanent" or os.date("!%Y-%m-%d %H:%M UTC", expiry)
		banStatus = `{expiry and "Temporary" or "Permanent"} | {ban.reason or "No reason"} | {v4}`
	else
		banStatus = "Not banned"
	end

	if ok == nil then
		ok = v2.Ok
	end

	return {
		Ok = ok,
		Message = p or v2.Message,
		BanStatus = banStatus,
		LeaderboardBanned = DataManager:IsLeaderboardBanned(userId),
		History = FormatHistory(v2.Data or {})
	}
end

local function EraseProfile(userId: number)
	local localPlayer = ProfileAccess.GetLocalPlayer(userId)

	if localPlayer then
		localPlayer:Kick("Your data was erased by an administrator")
		local profile = DataManager.Profiles[localPlayer]
		DataManager:EndSession(localPlayer)
		local v2 = os.clock() + 15

		while profile and profile:IsActive() and os.clock() < v2 do
			task.wait()
		end

		if profile and profile:IsActive() then
			return false, "Timed out ending the local profile session"
		end
	end

	local v2 = tostring(userId)
	local success, result = pcall(function()
		return DataManager.PlayerStore:StartSessionAsync(v2, {
			Steal = true
		})
	end)

	if not success then
		return false, (`Profile session takeover failed: {tostring(result)}`)
	end

	if not result then
		return false, "Profile session takeover returned no profile"
	end

	result:EndSession()
	local v3 = os.clock() + 15

	while result:IsActive() and os.clock() < v3 do
		task.wait()
	end

	if result:IsActive() then
		return false, "Timed out releasing the stolen profile session"
	end

	local success2, result2 = pcall(function()
		return DataManager.PlayerStore:RemoveAsync(v2)
	end)

	if not success2 then
		return false, (`ProfileStore erase failed: {tostring(result2)}`)
	end

	if result2 ~= true then
		return false, "ProfileStore did not confirm the erase"
	end

	ProfileAccess.Invalidate(userId)
	local v4 = {}

	local function Clean(p: string, callback)
		local success3, result3 = pcall(callback)

		if not success3 then
			table.insert(v4, (`{p}: {tostring(result3)}`))
		end
	end

	local function fn()
		DataStoreService:GetDataStore("MainGameSave"):RemoveAsync(v2)
	end

	local success3, result3 = pcall(fn)

	if not success3 then
		table.insert(v4, (`legacy save: {tostring(result3)}`))
	end

	local function fn2()
		DataStoreService:GetDataStore("EmergencyBackups_V1"):RemoveAsync((`Backup_{userId}`))
	end

	local success4, result4 = pcall(fn2)

	if not success4 then
		table.insert(v4, (`emergency backup: {tostring(result4)}`))
	end

	local function fn3()
		DataStoreService:GetOrderedDataStore("WinsV1"):RemoveAsync(v2)
	end

	local success5, result5 = pcall(fn3)

	if not success5 then
		table.insert(v4, (`wins leaderboard: {tostring(result5)}`))
	end

	local function fn4()
		DataStoreService:GetOrderedDataStore("TotalXPV2"):RemoveAsync(v2)
	end

	local success6, result6 = pcall(fn4)

	if not success6 then
		table.insert(v4, (`XP leaderboard: {tostring(result6)}`))
	end

	if #v4 > 0 then
		return false, (`Profile erased, but cleanup failed for {table.concat(v4, "; ")}`)
	end

	return true, "Player data was permanently erased"
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetModeration`,
	"cui.inspect.moderation",
	false,
	function(_, p)
		return (BuildResponse(p.UserId))
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_RunModeration`,
	"cui.inspect.moderation",
	true,
	function(p, data)
		local v2 = v[data.Action]

		if not (v2 and AdminPermissions.hasPermission(p.UserId, v2)) then
			return (BuildResponse(data.UserId, "You do not have permission to perform this moderation action", false))
		end

		if data.Action ~= "TeleportToTarget" then
			local canTarget, v3 = ProfileAccess.CanTarget(p, data.UserId)

			if not canTarget then
				return (BuildResponse(data.UserId, v3, false))
			end
		end

		local success, v3

		if data.Action == "TempBan" then
			local v4 = (type(data.Reason) ~= "string" or data.Reason == "") and "No reason" or data.Reason
			local v5 = type(data.Duration) ~= "string" and "" or string.gsub(data.Duration, "%s+", "")
			local v6 = tonumber(v5)
			local v7

			if v5 == "" then
				v7 = true
			elseif v6 == nil then
				v7 = false
			else
				v7 = v6 <= 0
			end

			if not (v7 or v6) then
				return (BuildResponse(data.UserId, "Ban duration must be a number, blank, -1", false))
			end

			if v7 then
				success = BanManager:BanAndIndex(data.UserId, v4, p.Name)
				v3 = success and "Player permanently banned" or "Permanent ban failed"

				if success then
					WebhookLogger:LogBan(p, GetTargetReference(data.UserId), v4)
				end
			else
				local v8 = math.min(v6, 7)
				success = BanManager:TempBanAndIndex(data.UserId, v4, v8 * 86400, p.Name)
				v3 = not success and "Temporary ban failed" or `Player temporarily banned for {v8} day(s){v6 > 7 and " (capped at 7)" or ""}`

				if success then
					WebhookLogger:LogTempBan(p, GetTargetReference(data.UserId), v4, v8, "day")
				end
			end

			return (BuildResponse(data.UserId, v3, success))
		elseif data.Action == "Unban" then
			success = BanManager:UnbanAndIndex(data.UserId)
			v3 = success and "Player unbanned" or "Unban failed"

			if success then
				WebhookLogger:LogUnban(p, data.UserId)
			end

			return (BuildResponse(data.UserId, v3, success))
		elseif data.Action == "LeaderboardBan" then
			local v4
			success, v4 = DataManager:BanFromLeaderboard(data.UserId)
			v3 = success and "Player banned from the leaderboards" or v4 or "Leaderboard ban failed"

			if success then
				WebhookLogger:LogBanLeaderboard(p, data.UserId, GetTargetReference(data.UserId).Name)
			end

			return (BuildResponse(data.UserId, v3, success))
		elseif data.Action == "LeaderboardUnban" then
			local v4
			success, v4 = DataManager:UnbanFromLeaderboard(data.UserId)

			if success then
				v3 = "Player restored to the leaderboards"
			else
				v3 = v4 or "Leaderboard unban failed"
			end

			return (BuildResponse(data.UserId, v3, success))
		elseif data.Action == "TeleportToTarget" then
			local v4 = ProfileAccess.Read(data.UserId)

			if not v4.Ok then
				return (BuildResponse(data.UserId, v4.Message, false))
			end

			if v4.IsLocal then
				return (BuildResponse(data.UserId, "Player is already in this server", false))
			end

			if not v4.ServerJobId then
				return (BuildResponse(data.UserId, "Player is offline", false))
			end

			local data2 = v4.Data
			local VIP_ID

			if type(data2) == "table" then
				VIP_ID = data2.VIP_ID
			end

			if type(VIP_ID) == "table" and type(VIP_ID.code) == "string" and VIP_ID.code ~= "" then
				local VIPServer = require(ServerScriptService.VIPServer)
				local VIPServerConfig = require(ServerScriptService.VIPServer.VIPServerConfig)
				local placeId = tonumber(VIP_ID.placeId) or VIPServerConfig.WORDS[1]
				local profile = DataManager.Profiles[p]

				if not profile then
					return (BuildResponse(data.UserId, "Your profile is not ready for VIP teleportation", false))
				end

				if not placeId then
					return (BuildResponse(data.UserId, "The player's VIP destination is unavailable", false))
				end

				profile.Data.VIP_ID = table.clone(VIP_ID)
				local v5
				success, v5 = VIPServer.Teleport:TeleportInPrivateServer({ p }, VIP_ID.code, placeId):await()

				if not success then
					profile.Data.VIP_ID = false
				end

				if success then
					v3 = "Teleporting you to the player's VIP server"
				else
					v3 = `VIP teleport failed: {tostring(v5)}`
				end
			else
				local result
				success, result = pcall(function()
					TeleportService:TeleportToPlaceInstance(v4.ServerPlaceId or game.PlaceId, v4.ServerJobId, p)
				end)

				if success then
					v3 = "Teleporting you to the player's server"
				else
					v3 = `Teleport failed: {tostring(result)}`
				end
			end

			if success then
				WebhookLogger:LogTPServer(p, data.UserId)
			end

			return (BuildResponse(data.UserId, v3, success))
		elseif data.Action == "TeleportTargetToMe" then
			local v4 = ProfileAccess.Read(data.UserId)

			if not v4.Ok then
				return (BuildResponse(data.UserId, v4.Message, false))
			end

			if v4.IsLocal then
				return (BuildResponse(data.UserId, "Player is already in your server", false))
			end

			if not v4.ServerJobId then
				return (BuildResponse(data.UserId, "Player is offline", false))
			end

			local result
			success, result = pcall(function()
				MessagingService:PublishAsync("AdminTpToMe", HttpService:JSONEncode({
					targetUserId = data.UserId,
					placeId = game.PlaceId,
					jobId = game.JobId
				}))
			end)

			if success then
				v3 = "Player is being teleported to your server"
			else
				v3 = `Cross-server teleport failed: {tostring(result)}`
			end

			return (BuildResponse(data.UserId, v3, success))
		else
			if data.Action ~= "EraseData" then
				return (BuildResponse(data.UserId, "Unknown moderation action", false))
			end

			success, v3 = EraseProfile(data.UserId)

			if success then
				local targetReference = GetTargetReference(data.UserId)
				WebhookLogger:LogResetPlayer(p, data.UserId, targetReference.Name)
			end

			return (BuildResponse(data.UserId, v3, success))
		end
	end
)
return {
	DisplayName = "Moderation",
	Permission = "cui.inspect.moderation",
	Order = 60,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local reason = ""
		local duration = ""
		local history = {}
		local v4 = ""

		local function fn() end

		local function Notify(p: string, flag: boolean)
			if not NotificationSystem or p == "" then
				return
			end

			local v5

			if flag then
				v5 = Color3.fromRGB(100, 255, 100)
			else
				v5 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(p, v5, 4)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Cheat history")
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v4 = string.lower(value)
				fn()
			end)
		end)
		local v5 = object:AddList(function(object2)
			object2:SetSizeY(145)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Moderative actions")
		end)
		local v6 = nil
		local v7 = nil
		object:AddSplit(function(p)
			v6 = p.LeftComponents:AddField(function(object2)
				object2:SetText("Ban status"):SetValue(""):SetEnabled(false)
			end)
			v7 = p.RightComponents:AddCheckbox(function(object2)
				object2:SetText("LB Ban"):SetValue(false):SetEnabledPermission("cui.inspect.moderation.lbban")
			end)
		end)
		object:AddField(function(object2)
			object2:SetText("Reason"):SetPlaceholder("Moderation reason"):SetEnabledPermission("cui.inspect.moderation.ban"):SetOnChangedRaw(function(p)
				reason = p
			end)
		end)
		object:AddField(function(object2)
			object2:SetText("Ban duration (days)"):SetPlaceholder("Blank or -1 = permanent"):SetEnabledPermission("cui.inspect.moderation.ban"):SetOnChangedRaw(function(p)
				duration = p
			end)
		end)

		local function ApplyResponse(data2, flag: boolean?)
			v6:SetValue(data2.BanStatus)
			v7:SetValue(data2.LeaderboardBanned)
			history = data2.History
			fn()

			if flag == true then
				Notify(data2.Message, data2.Ok)
			elseif not data2.Ok then
				data.NotifyProfileError(data2.Message)
			end
		end

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(ApplyResponse):catch(function(p)
				Notify(`Failed to load moderation data: {tostring(p)}`, false)
			end)
		end

		local function Execute(action: string)
			if not clientEvent2 then
				return
			end

			clientEvent2:Fire({
				UserId = data.UserId,
				Action = action,
				Reason = reason,
				Duration = duration
			}):andThen(function(data2)
				v6:SetValue(data2.BanStatus)
				v7:SetValue(data2.LeaderboardBanned)
				history = data2.History
				fn()
				Notify(data2.Message, data2.Ok)
			end):catch(function(p2)
				Notify(`Moderation action failed: {tostring(p2)}`, false)
			end)
		end

		v7:SetOnChanged(function(p)
			Execute(p and "LeaderboardBan" or "LeaderboardUnban")
		end)

		fn = function()
			for _, v8 in v5.Components:GetAll() do
				v8:Destroy()
			end

			if #history == 0 then
				v5.Components:AddText(function(object2)
					object2:SetText("No cheat history entries.")
				end)
				return
			end

			local count = 0

			for _, v8 in history do
				local v9 = string.lower((`{v8.Source} {v8.Index} {v8.Block} {v8.Reason} {v8.Timestamp} {v8.Level or ""} {v8.Required or ""} {v8.Details}`))

				if not (v4 == "" or string.find(v9, v4, 1, true)) then
					continue
				end

				count += 1
				local v10 = v8
				v5.Components:AddExpandable(function(object2)
					object2:SetText((`{v10.Source} #{v10.Index} | {v10.Reason}`))
					object2.Components:AddField(function(object3)
						object3:SetText("Reason"):SetValue(v10.Reason):SetEnabled(false)
					end)

					if v10.Timestamp > 0 then
						object2.Components:AddSplit(function(p)
							p.LeftComponents:AddField(function(object3)
								object3:SetText("Block"):SetValue(v10.Block):SetEnabled(false)
							end)
							p.RightComponents:AddTime(function(object3)
								object3:SetText("Detected at"):SetTime(v10.Timestamp):SetEnabled(false)
							end)
						end)
					else
						object2.Components:AddField(function(object3)
							object3:SetText("Block"):SetValue(v10.Block):SetEnabled(false)
						end)
					end

					if v10.Level == nil or v10.Required == nil then
						if v10.Level ~= nil or v10.Required ~= nil then
							object2.Components:AddNumberField(function(object3)
								object3:SetText(v10.Level == nil and "Required" or "Level"):SetValue(v10.Level or v10.Required or 0):SetEnabled(false)
							end)
						end
					else
						object2.Components:AddSplit(function(p)
							p.LeftComponents:AddNumberField(function(object3)
								object3:SetText("Level"):SetValue(v10.Level):SetEnabled(false)
							end)
							p.RightComponents:AddNumberField(function(object3)
								object3:SetText("Required"):SetValue(v10.Required):SetEnabled(false)
							end)
						end)
					end

					if v10.Details ~= "" then
						object2.Components:AddText(function(object3)
							object3:SetText((`Details: {v10.Details}`)):SetAutoResize(true)
						end)
					end
				end)
			end

			if count == 0 then
				v5.Components:AddText(function(object2)
					object2:SetText("No cheat history entries match this search.")
				end)
			end
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Temp / permanent ban"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation.ban"):DoNeedConfirmation(true):SetButtonCallback(function()
					Execute("TempBan")
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Unban"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation.unban"):DoNeedConfirmation(true):SetButtonCallback(function()
					Execute("Unban")
				end)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Server actions")
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Teleport to their server"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation.tptothem"):SetButtonCallback(function()
					Execute("TeleportToTarget")
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Teleport to my server"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation.tphere"):DoNeedConfirmation(true):SetButtonCallback(function()
					Execute("TeleportTargetToMe")
				end)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Destructive actions")
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("ERASE ALL PLAYER DATA"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation.erase"):DoNeedConfirmation(true):SetButtonColor(Color3.fromRGB(
				190,
				45,
				45
			)):SetButtonCallback(function()
				Execute("EraseData")
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh moderation data"):SetYSize(22):SetEnabledPermission("cui.inspect.moderation"):SetButtonCallback(Refresh)
		end)
		data.PresenceChanged:Connect(Refresh)
		fn()
		Refresh()
	end
}