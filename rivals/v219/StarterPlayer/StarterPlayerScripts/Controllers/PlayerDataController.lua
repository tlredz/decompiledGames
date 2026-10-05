local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EnumLibrary = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EnumLibrary"))
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Signal"))
local ClientPlayerData = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"):WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientPlayerData"))
local data = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Data")
local requestPlayerData = data:WaitForChild("RequestPlayerData")
local playerDataChanged = data:WaitForChild("PlayerDataChanged")
local playerDataAdded = data:WaitForChild("PlayerDataAdded")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.PlayerDataAdded = Signal.new()
	self.StatisticsUpdated = Signal.new()
	self.SettingsSliderChanged = Signal.new()
	self.CurrentData = nil
	self._setting_changed_events = {}
	self:_Init()
	return self
end

function class:Get(...)
	return self.CurrentData:Get(...)
end

function class:Set(...)
	return self.CurrentData:Set(...)
end

function class:GetDataChangedSignal(...)
	return self.CurrentData:GetDataChangedSignal(...)
end

function class:GetSetting(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetSetting(self, ...)
end

function class:GetSettingChangedSignal(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetSettingChangedSignal(self, ...)
end

function class:SetSetting(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:SetSetting(self, ...)
end

function class:IsNosniyGamesTeamMember(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:IsNosniyGamesTeamMember(self, ...)
end

function class:GetWeaponData(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetWeaponData(self, ...)
end

function class:HasGamepass(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:HasGamepass(self, ...)
end

function class:GetStatistic(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetStatistic(self, ...)
end

function class:GetDirectoryStatistic(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetDirectoryStatistic(self, ...)
end

function class:GetWeaponStatistic(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetWeaponStatistic(self, ...)
end

function class:GetMapStatistic(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetMapStatistic(self, ...)
end

function class:GetUnlockedWeapons(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:GetUnlockedWeapons(self, ...)
end

function class:AreTasksCompleted(...)
	local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
	return PlayerDataUtility:AreTasksCompleted(self, ...)
end

function class:GetFavoritedWeapons()
	local result = {}

	for _, v in pairs(self:Get("WeaponInventory")) do
		if v.IsFavorited then
			result[v.Name] = true
		end
	end

	return result
end

function class:OwnsAllWeapons(p, p2, p3)
	local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
	local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
	local count = 0
	local count2 = 0

	for _, v in pairs(ShopLibrary:GetReleasedOwnableWeapons()) do
		if not (not p or ItemLibrary.Items[v].Status == p) then
			continue
		end

		local v2 = not p3 or ShopLibrary:IsWeaponReleased(v)
		local v3 = not p2 or ShopLibrary.Weapons[v].KeyPrice

		if v2 and v3 then
			count += 1
		end
	end

	for _, v in pairs(self:Get("WeaponInventory")) do
		if not (not p or ItemLibrary.Items[v.Name].Status == p) then
			continue
		end

		local v2 = not p3 or ShopLibrary:IsWeaponReleased(v.Name)
		local v3 = not p2 or ShopLibrary.Weapons[v.Name] and ShopLibrary.Weapons[v.Name].KeyPrice

		if v2 and v3 then
			count2 += 1
		end
	end

	return count <= count2
end

function class:GetNumTasksCompleted(value)
	local count = 0

	for _, v in pairs(self:Get(value or "Tasks")) do
		if v.Completed then
			count += 1
		end
	end

	return count
end

function class:IsEmoteEquipped(p)
	for _, v in pairs(self:Get("EquippedEmotes")) do
		if v.Name == p then
			return true
		end
	end
end

function class:SilenceCosmeticNotification(p, p2)
	if p then
		local cosmeticNotifications = self:Get("CosmeticNotifications")

		if p2 then
			if typeof(cosmeticNotifications[p]) == "table" then
				cosmeticNotifications[p][p2] = nil
				self.CurrentData:Replicate("CosmeticNotifications")
				ReplicatedStorage.Remotes.Data.SilenceCosmeticNotification:FireServer(p, p2)
			end
		else
			cosmeticNotifications[p] = nil
			self.CurrentData:Replicate("CosmeticNotifications")
			ReplicatedStorage.Remotes.Data.SilenceCosmeticNotification:FireServer(p, nil)
		end
	else
		self.CurrentData:SetReplicate("CosmeticNotifications", {})
		ReplicatedStorage.Remotes.Data.SilenceCosmeticNotification:FireServer(nil, nil)
	end
end

function class.WaitUntilLoaded(p)
	if not p.CurrentData then
		p.PlayerDataAdded:Wait()
	end
end

function class:_PlayerDataChanged(p, ...)
	local currentData = self.CurrentData

	if not currentData then
		return
	end

	EnumLibrary:WaitForEnumBuilder()
	local v = EnumLibrary:FromEnum(p) or p

	if v == "DataValueChanged" then
		currentData:SetReplicate(...)
	elseif v == "BulkDataValueChanged" then
		local v2 = ...

		for _, v3 in pairs(v2) do
			currentData:SetReplicate(v3[1], v3[2])
		end
	elseif v == "StatisticsBatchUpdate" then
		local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
		local v2 = ...

		for k, v3 in pairs(v2[utf8.char(0)] or {}) do
			currentData:Set(currentData:FromEnum(k), v3)
		end

		for k, list in pairs(StatisticsLibrary.STATISTICS_DIRECTORY_INFO) do
			local v3, _ = table.unpack(list)
			local v4 = self:Get(v3)

			for k2, v5 in pairs(v2[utf8.char(0 + k)] or {}) do
				local v6 = currentData:FromEnum(k2)
				v4[v6] = v4[v6] or {}

				for k3, v7 in pairs(v5) do
					v4[v6][currentData:FromEnum(k3)] = v7
				end
			end
		end

		self.StatisticsUpdated:Fire()
	elseif v == "WeaponDataChanged" then
		local v2 = ...
		local weaponInventory = currentData:Get("WeaponInventory")

		for k, v3 in pairs(weaponInventory) do
			if v3.Name ~= v2.Name then
				continue
			end

			weaponInventory[k] = v2
			break
		end

		currentData:Replicate("WeaponInventory")
	elseif v == "BatchUpdateWeaponXP" then
		local v2 = ...
		local flag = false

		for _, v3 in pairs(v2) do
			local weaponData = self:GetWeaponData(currentData:FromEnum(v3[utf8.char(0)]))

			if not weaponData then
				continue
			end

			weaponData.Level = v3[utf8.char(1)]
			weaponData.XP = v3[utf8.char(2)]
			flag = true
		end

		if flag then
			currentData:Replicate("WeaponInventory")
		end
	elseif v == "SettingChanged" then
		self:SetSetting(...)
	elseif v == "AddReceipt" then
		local v2 = ...
		table.insert(currentData:Get("Receipts"), v2)
		currentData:Replicate("Receipts")
	else
		currentData:ReplicateFromServer(v, ...)
	end
end

function class:_CreatePlayerData(p2)
	assert(typeof(p2) == "table", "Argument 1 invalid, expected a table, got " .. tostring(p2))
	local currentData = ClientPlayerData.new(p2)
	self.CurrentData = currentData
	self.PlayerDataAdded:Fire(currentData)
end

function class:_RequestPlayerData()
	local v = requestPlayerData:InvokeServer()

	if not v then
		return
	end

	self:_CreatePlayerData(v)
end

function class:_Init()
	playerDataChanged.OnClientEvent:Connect(function(...)
		self:_PlayerDataChanged(...)
	end)
	playerDataAdded.OnClientEvent:Connect(function(...)
		self:_CreatePlayerData(...)
	end)
	task.spawn(self._RequestPlayerData, self)
end

return class._new()