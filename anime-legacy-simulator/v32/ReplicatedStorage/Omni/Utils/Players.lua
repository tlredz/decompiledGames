local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local GroupService = game:GetService("GroupService")
game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local module = require("@game/ReplicatedStorage/Omni/Settings")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = nil
local v13 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearHumanoidCache(p: number)
	v6[p] = nil

	if v7[p] then
		v7[p]:Destroy()
		v7[p] = nil
	end

	local index = table.find(v8, p)

	if index then
		table.remove(v8, index)
	end
end

local function TrackOfflineHumanoid(p: number)
	if Players:GetPlayerByUserId(p) or table.find(v8, p) then
		return
	end

	table.insert(v8, p)

	while #v8 > 10 do
		ClearHumanoidCache(v8[1]) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearPlayerInfo(p: number)
	v3[p] = nil
	v4[p] = nil
	local index = table.find(v5, p)

	if index then
		table.remove(v5, index)
	end
end

local function TrackOfflineInfo(p: number)
	if table.find(v5, p) then
		return
	end

	table.insert(v5, p)

	while #v5 > 100 do
		ClearPlayerInfo(v5[1]) -- equivalent call inferred; original call site unknown
	end
end

function v13.GetPlayerCountry(p: number)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return ""
	end

	if not v[playerByUserId.UserId] then
		local success, result = pcall(function()
			return LocalizationService:GetCountryRegionForPlayerAsync(playerByUserId)
		end)

		if success and result then
			v[playerByUserId.UserId] = result
		end
	end

	return v[playerByUserId.UserId] or ""
end

function v13.GetPlayerIcon(p: number)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return ""
	end

	if not v2[playerByUserId.UserId] then
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(
				playerByUserId.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)
		end)

		if success and result then
			v2[playerByUserId.UserId] = result
		end
	end

	return v2[playerByUserId.UserId] or ""
end

function v13.GetPlayerInfo(userId: number)
	local playerByUserId = Players:GetPlayerByUserId(userId)

	if playerByUserId then
		return {
			UserName = playerByUserId.Name,
			NickName = playerByUserId.DisplayName,
			UserId = userId
		}
	end

	if v3[userId] then
		return v3[userId]
	end

	local now = os.clock()
	local v14 = {
		UserName = "Not Found",
		NickName = "Not Found",
		UserId = userId
	}
	local v15 = v4[userId]

	if v15 and now < v15 then
		return v14
	end

	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({ userId })
	end)
	local v16 = success and result and result[1]

	if v16 then
		v14 = {
			UserName = v16.Username,
			NickName = v16.DisplayName,
			UserId = userId
		}
		v3[userId] = v14
		v4[userId] = nil
	else
		v4[userId] = now + 30
	end

	TrackOfflineInfo(userId)
	return v14
end

function v13.GetHumanoidDescription(p: number)
	if v6[p] then
		return v6[p]
	end

	local success, result = pcall(function()
		return Players:GetHumanoidDescriptionFromUserIdAsync(p)
	end)

	if success and result then
		v6[p] = result
		TrackOfflineHumanoid(p)
	end

	return v6[p]
end

function v13.GetHumanoidModel(p: number)
	if v7[p] then
		return v7[p]:Clone()
	end

	local humanoidDescription = v13.GetHumanoidDescription(p)

	if not humanoidDescription then
		return
	end

	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(humanoidDescription, Enum.HumanoidRigType.R15)
	end)

	if not (success and result) then
		return
	end

	for _, script in result:GetChildren() do
		if not (script:IsA("LocalScript") or script:IsA("Script") or script:IsA("ModuleScript")) then
			continue
		end

		script:Destroy()
	end

	v7[p] = result
	TrackOfflineHumanoid(p)
	return v7[p]:Clone()
end

function v13.IsPlayerInGroup(p)
	local now = os.clock()
	local v14 = v9[p.UserId]

	if v14 and (v14.Value or now < v14.ExpiresAt) then
		return v14.Value
	end

	local success, result = pcall(p.IsInGroupAsync, p, module.GroupId)
	local value

	if success then
		value = result == true
	elseif v14 then
		value = v14.Value
	else
		value = false
	end

	if Players:GetPlayerByUserId(p.UserId) then
		v9[p.UserId] = {
			Value = value,
			ExpiresAt = now + 10
		}
	end

	return value
end

function v13.GetPlayerGroupInfo(value)
	local v14 = typeof(value) == "number" and value or value.UserId
	local now = os.clock()
	local v15 = v10[v14]

	if v15 and now < v15.ExpiresAt then
		return v15.Rank, v15.Role, true, table.clone(v15.Ranks)
	end

	local v16 = v11[v14]

	if v16 and now < v16 then
		if v15 then
			return v15.Rank, v15.Role, true, table.clone(v15.Ranks)
		end

		return 0, "Guest", false, {}
	else
		local success, result = pcall(function()
			return GroupService:GetRolesInGroupAsync(v14, module.GroupId)
		end)

		if not success and Players:GetPlayerByUserId(v14) then
			v11[v14] = now + 10
		end

		if not success and v15 then
			return v15.Rank, v15.Role, true, table.clone(v15.Ranks)
		end

		local name = "Guest"
		local rank = 0
		local ranks = {}

		if success and result.IsMember then
			for _, role in result.Roles do
				table.insert(ranks, role.Rank)

				if not (rank < role.Rank) then
					continue
				end

				name = role.Name
				rank = role.Rank
			end
		end

		if success then
			v11[v14] = nil
		end

		if success and Players:GetPlayerByUserId(v14) then
			v10[v14] = {
				Rank = rank,
				Role = name,
				Ranks = table.clone(ranks),
				ExpiresAt = now + 60
			}
		end

		return rank, name, success, ranks
	end
end

function v13.GetGroupRoles()
	if v12 then
		return v12
	end

	local success, result = pcall(function()
		return GroupService:GetGroupInfoAsync(module.GroupId)
	end)

	if not (success and result and result.Roles) then
		return {}
	end

	local result2 = {}

	for _, role in result.Roles do
		if not (role.Rank <= 0) then
			table.insert(result2, {
				Name = role.Name,
				Rank = role.Rank
			})
		end
	end

	table.sort(result2, function(a, b)
		return a.Rank < b.Rank
	end)
	v12 = result2
	return result2
end

function v13.IsPlayerContentCreator(p)
	local _, _, _, v14 = v13.GetPlayerGroupInfo(p)

	for _, v15 in v14 do
		if v15 == 12 or v15 == 11 or v15 == 10 then
			return true
		end
	end

	return false
end

function v13.GetCustomPlayerRoleByRank(p)
	local playerGroupInfo = v13.GetPlayerGroupInfo(p)

	if playerGroupInfo >= 254 then
		return "Owner", Color3.new(1, 1, 1)
	end

	if playerGroupInfo == 253 then
		return "Co Owner", Color3.new(1, 1, 1)
	elseif playerGroupInfo == 250 then
		return "StarX Team", Color3.new(0.392157, 1, 0.32549)
	elseif playerGroupInfo == 200 then
		return "Director", Color3.new(0.1, 0.2, 1)
	elseif playerGroupInfo == 199 then
		return "Staff", Color3.new(1, 0.5, 0)
	end

	if playerGroupInfo == 33 or playerGroupInfo == 32 then
		return "Early Access", Color3.new(0.376471, 1, 0.854902)
	end

	if playerGroupInfo == 12 then
		return "Senior CC", Color3.new(1, 0, 0)
	elseif playerGroupInfo == 11 then
		return "Junior CC", Color3.new(1, 0, 0)
	elseif playerGroupInfo == 10 then
		return "Beginner CC", Color3.new(1, 0, 0)
	elseif playerGroupInfo == 2 then
		return "Tester", Color3.new(0.792157, 0.376471, 1)
	end

	if playerGroupInfo > 0 then
		return "Member", Color3.new(1, 1, 0.25)
	end

	return "Guest", Color3.new(0.568627, 0.568627, 0.568627)
end

function v13.GetContextKey(value: string?, value2: string?, p)
	if p == nil then
		return (`M:{value or ""}`)
	end

	return (`S:{value2 or ""}:{p}`)
end

function v13.GetDataContextKey(data)
	local gamemode = data.Gamemode
	local gamemodeSession = data.GamemodeSession
	local v14

	if typeof(gamemode) == "string" and gamemode ~= "" and typeof(gamemodeSession) == "string" then
		v14 = gamemodeSession ~= ""
	else
		v14 = false
	end

	if v14 then
		return v13.GetContextKey(nil, gamemode, gamemodeSession)
	end

	local maps = data.Maps
	return v13.GetContextKey(maps and maps.Current, nil, nil)
end

Players.PlayerRemoving:Connect(function(player)
	ClearPlayerInfo(player.UserId) -- equivalent call inferred; original call site unknown
	v2[player.UserId] = nil
	v[player.UserId] = nil
	v9[player.UserId] = nil
	v10[player.UserId] = nil
	v11[player.UserId] = nil
	ClearHumanoidCache(player.UserId) -- equivalent call inferred; original call site unknown
end)
return table.freeze(v13)