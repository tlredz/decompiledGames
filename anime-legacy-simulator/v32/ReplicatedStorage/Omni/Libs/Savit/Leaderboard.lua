local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local LocalizationService = game:GetService("LocalizationService")
require(script.Parent.GoodSignal)
local dataStore = DataStoreService:GetDataStore("Leaderboards")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local Leaderboard = {}
Leaderboard.__index = Leaderboard

local function AscendingOrdering(p, p2)
	local saveTime = p.SaveTime or 0
	local saveTime2 = p2.SaveTime or 0

	if p.Value == p2.Value then
		return saveTime < saveTime2
	end

	return p.Value < p2.Value
end

local function DescendingOrdering(p, p2)
	local saveTime = p.SaveTime or 0
	local saveTime2 = p2.SaveTime or 0

	if p.Value == p2.Value then
		return saveTime < saveTime2
	end

	return p.Value > p2.Value
end

local function Try(p: number, callback, ...)
	for _ = 1, p do
		local v6 = { pcall(callback, ...) }

		if v6[1] then
			return table.unpack(v6)
		end

		if typeof(v6[2]) == "string" and string.find(v6[2], "Throttled", 1, true) then
			break
		else
			task.wait(0.25)
		end
	end

	return nil
end

local function GetPlayerCountry(value: number)
	local playerByUserId = Players:GetPlayerByUserId(value)

	if not playerByUserId then
		return ""
	end

	if v[playerByUserId.UserId] or os.clock() < (v4[playerByUserId.UserId] or 0) then
		return v[playerByUserId.UserId] or ""
	end

	local v6, v7 = Try(2, LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, playerByUserId)
	local v8 = v6 and v7 or nil

	if playerByUserId.Parent ~= Players then
		return v8 or ""
	end

	v[playerByUserId.UserId] = v8
	local v9 = v4
	local userId = playerByUserId.UserId
	local v10

	if not v8 then
		v10 = os.clock() + 60
	end

	v9[userId] = v10
	return v8 or ""
end

local function GetPlayerIcon(value: number)
	local playerByUserId = Players:GetPlayerByUserId(value)

	if not playerByUserId then
		return ""
	end

	if v2[playerByUserId.UserId] or os.clock() < (v5[playerByUserId.UserId] or 0) then
		return v2[playerByUserId.UserId] or ""
	end

	local v6, v7 = Try(
		2,
		Players.GetUserThumbnailAsync,
		Players,
		playerByUserId.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	local v8 = v6 and v7 or nil

	if playerByUserId.Parent ~= Players then
		return v8 or ""
	end

	v2[playerByUserId.UserId] = v8
	local v9 = v5
	local userId = playerByUserId.UserId
	local v10

	if not v8 then
		v10 = os.clock() + 60
	end

	v9[userId] = v10
	return v8 or ""
end

local function GetPlayerInfo(userId: number)
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

	local v6, v7 = Try(2, UserService.GetUserInfosByUserIdsAsync, UserService, { userId })
	local v8 = v6 and v7 and v7[1]

	if not v8 then
		return {
			UserName = "Not Found",
			NickName = "Not Found",
			UserId = userId
		}
	end

	local v9 = {
		UserName = v8.Username,
		NickName = v8.DisplayName,
		UserId = userId
	}
	v3[userId] = v9
	return v9
end

local function EncodeNumber(p: number)
	return (math.floor(math.log(p) / 9.999999505838704e-8))
end

local function DecodeNumber(p: number)
	return (math.round(1.0000001 ^ p))
end

local function GetRequestBudget(p)
	return DataStoreService:GetRequestBudgetForRequestType(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsRequestCurrentlySafe(p)
	return DataStoreService:GetRequestBudgetForRequestType(p) >= 1
end

local function WaitForRequestToBeSafe(p)
	while true do
		local requestCurrentlySafe = IsRequestCurrentlySafe(p) -- equivalent call inferred; original call site unknown

		if requestCurrentlySafe then
			break
		end

		task.wait(1)

		if requestCurrentlySafe then
			break
		end
	end
end

local function IsListed(list, p)
	for _, item in list do
		for _, v6 in item do
			if v6.UserId == p then
				return true
			end
		end
	end

	return false
end

local function IsEntryRelevant(data, data2)
	if IsListed(data.List, data2.UserId) then
		return true
	end

	local value

	if data2.IsEncoded then
		value = math.round(1.0000001 ^ data2.Value)
	else
		value = data2.Value
	end

	for k in data2.Categories do
		local v6 = data.List[k]

		if not data.Size or not v6 or #v6 < data.Size or data.Ordering({
			Value = value,
			SaveTime = 1e999
		}, v6[#v6]) then
			return true
		end
	end

	return false
end

function Leaderboard:SetCountrySaving(flag: boolean)
	self.ShoulSaveCountry = flag == true
end

function Leaderboard:SetPlayerIconSaving(flag: boolean)
	self.ShouldSavePlayerIcon = flag == true
end

function Leaderboard:SetPreSave(preSave)
	if preSave ~= nil and typeof(preSave) ~= "function" then
		return
	end

	self.PreSave = preSave
end

function Leaderboard:SetMinimumValue(minimumValue: number?)
	if minimumValue ~= nil and typeof(minimumValue) ~= "number" then
		return
	end

	self.MinimumValue = minimumValue
end

function Leaderboard:SetMaximumValue(maximumValue: number?)
	if maximumValue ~= nil and typeof(maximumValue) ~= "number" then
		return
	end

	self.MaximumValue = maximumValue
end

function Leaderboard:SetSize(size: number?)
	if size ~= nil and typeof(size) ~= "number" then
		return
	end

	self.Size = size
end

function Leaderboard:SetOrdering(ordering)
	if ordering == "Ascending" then
		self.Ordering = AscendingOrdering
	elseif ordering == "Descending" then
		self.Ordering = DescendingOrdering
	elseif typeof(ordering) == "function" then
		self.Ordering = ordering
	end
end

function Leaderboard:SetChecker(checker)
	if checker ~= nil and typeof(checker) ~= "function" then
		return
	end

	self.Checker = checker
end

function Leaderboard:Clear()
	if self.IsUpdating then
		repeat
			task.wait()
		until not self.IsUpdating
	end

	self.IsClearing = true
	WaitForRequestToBeSafe(Enum.DataStoreRequestType.StandardRemove)
	Try(5, dataStore.RemoveAsync, dataStore, self.Name)
	table.clear(self.List)
	self.IsClearing = nil
	self.OnUpdate:Fire(self.List)
end

function Leaderboard.Save(data, userId, value2: number, items, data2)
	if typeof(userId) ~= "number" and typeof(userId) ~= "string" or typeof(value2) ~= "number" then
		return
	end

	if typeof(items) ~= "table" then
		return
	end

	local v6 = typeof(userId) == "number"
	local v7 = tostring(userId)

	if data.Saving[v7] then
		return
	end

	local categories = {}

	for _, item in items do
		if typeof(item) == "string" then
			categories[item] = true
		end
	end

	if not (next(categories) or IsListed(data.List, userId)) then
		return
	end

	data.Saving[v7] = true
	local icon = ""
	local country = ""
	local description = nil
	local isEncoded = value2 >= 1.152921504606847e18
	local userName, nickName

	if v6 then
		local playerInfo = GetPlayerInfo(userId)
		userName = playerInfo.UserName
		nickName = playerInfo.NickName

		if data.ShoulSaveCountry then
			country = GetPlayerCountry(userId)
		end

		if data.ShouldSavePlayerIcon then
			icon = GetPlayerIcon(userId)
		end
	else
		userName = not data2 and "" or data2.Name or ""
		nickName = not data2 and "" or data2.Name or ""
		icon = not data2 and "" or data2.Icon or ""
		description = data2 and data2.Description
	end

	if isEncoded then
		value2 = math.floor(math.log(value2) / 9.999999505838704e-8)
	end

	local v12 = {
		UserId = userId,
		UserName = userName,
		NickName = nickName,
		Value = value2,
		Icon = icon,
		Country = country,
		Description = description,
		IsEncoded = isEncoded,
		Categories = categories
	}

	if not data.Checker or data.Checker(v12) then
		data.Queue[v7] = v12
	else
		data.Queue[v7] = nil
	end

	data.Saving[v7] = nil
end

function Leaderboard:Update()
	if self.IsUpdating or self.IsClearing then
		return
	end

	self.IsUpdating = true
	WaitForRequestToBeSafe(Enum.DataStoreRequestType.UpdateAsync)
	local clone = table.clone(self.Queue)

	for k, v6 in clone do
		if IsEntryRelevant(self, v6) then
			continue
		end

		clone[k] = nil

		if self.Queue[k] == v6 then
			self.Queue[k] = nil
		end
	end

	local v6, v7

	if next(clone) then
		v6, v7 = Try(2, dataStore.UpdateAsync, dataStore, self.Name, function(buf)
			local serverTimeNow = workspace:GetServerTimeNow()
			local v8 = buf and HttpService:JSONDecode(buffer.tostring(buf)) or {
				Info = {},
				Categories = {}
			}

			for _, v9 in clone do
				local clone2 = table.clone(v9)
				clone2.Categories = table.clone(v9.Categories)
				local userId = clone2.UserId

				for k, list in v8.Categories do
					if clone2.Categories[k] then
						continue
					end

					local index = table.find(list, userId)

					if index then
						table.remove(list, index)
					end
				end

				if next(clone2.Categories) then
					clone2.SaveTime = serverTimeNow

					if self.PreSave then
						self.PreSave(clone2)
					end

					for k in clone2.Categories do
						local userIdsByIndex = v8.Categories[k]

						if not userIdsByIndex then
							userIdsByIndex = {}
							v8.Categories[k] = userIdsByIndex
						end

						local index = table.find(userIdsByIndex, userId)
						local v10 = (self.MinimumValue and clone2.Value < self.MinimumValue or self.MaximumValue and clone2.Value > self.MaximumValue) and true or false

						if index then
							if v10 then
								table.remove(userIdsByIndex, index)
							else
								userIdsByIndex[index] = userId
							end
						elseif not v10 then
							table.insert(userIdsByIndex, userId)
						end
					end

					clone2.Categories = nil
					v8.Info[tostring(userId)] = clone2
				else
					v8.Info[tostring(userId)] = nil
				end
			end

			local v9 = {}

			for _, list in v8.Categories do
				for i = #list, 1, -1 do
					if not v8.Info[tostring(list[i])] then
						table.remove(list, i)
					end
				end

				table.sort(list, function(a, b)
					return self.Ordering(v8.Info[tostring(a)], v8.Info[tostring(b)])
				end)

				if not (self.Size and #list > self.Size) then
					continue
				end

				for i = #list, self.Size + 1, -1 do
					v9[list[i]] = true
					table.remove(list, i)
				end
			end

			for _, category in v8.Categories do
				for _, v10 in category do
					v9[v10] = nil
				end
			end

			for k in v9 do
				v8.Info[tostring(k)] = nil
			end

			return buffer.fromstring(HttpService:JSONEncode(v8))
		end)
	else
		v6, v7 = Try(2, dataStore.GetAsync, dataStore, self.Name)
	end

	if v6 and v7 then
		local jSONDecode = HttpService:JSONDecode(buffer.tostring(v7))

		if typeof(jSONDecode) == "table" then
			local list = {}

			for k, category in jSONDecode.Categories do
				list[k] = {}

				for k2, v9 in category do
					local v10 = jSONDecode.Info[tostring(v9)]

					if not v10 then
						continue
					end

					if v10.IsEncoded then
						v10.IsEncoded = nil
						v10.Value = math.round(1.0000001 ^ v10.Value)
					end

					list[k][k2] = v10
				end
			end

			self.List = list
		end
	end

	if v6 and v7 then
		for k, v8 in clone do
			if self.Queue[k] == v8 then
				self.Queue[k] = nil
			end
		end
	end

	self.LastUpdate = workspace:GetServerTimeNow()
	self.UpdateOffset = (self.UpdateInterval or 0) * 1 * math.random()
	self.IsUpdating = nil
	self.OnUpdate:Fire(self.List)
end

function Leaderboard:SetUpdateInterval(updateInterval: number)
	if updateInterval ~= nil and typeof(updateInterval) ~= "number" then
		return
	end

	self.UpdateInterval = updateInterval
end

function Leaderboard.GetRank(p, value: string, value2)
	if typeof(value) ~= "string" or typeof(value2) ~= "number" and typeof(value2) ~= "string" then
		return
	end

	local v6 = p.List[value]

	if not v6 then
		return
	end

	for k, v7 in v6 do
		if v7.UserId == value2 then
			return k
		end
	end

	return nil
end

Players.PlayerRemoving:Connect(function(player)
	v3[player.UserId] = nil
	v2[player.UserId] = nil
	v[player.UserId] = nil
	v5[player.UserId] = nil
	v4[player.UserId] = nil
end)
return Leaderboard