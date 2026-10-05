local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserService = game:GetService("UserService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._is_fetching_user_info = {}
	self._user_info_cache = {}
	self:_Init()
	return self
end

function class:IsChina(p)
	local v = p or PlayerDataController:Get("PolicyInfo")
	return not v or v.IsSubjectToChinaPolicies
end

function class:IsExternalReferencesAllowed(value)
	local policyInfo = PlayerDataController:Get("PolicyInfo")
	return policyInfo and not self:IsChina() and table.find(
		policyInfo.AllowedExternalLinkReferences,
		value or "YouTube"
	)
end

function class:ArePaidRandomItemsRestricted(p)
	local v = p or PlayerDataController:Get("PolicyInfo")
	return not v or v.ArePaidRandomItemsRestricted or self:IsChina(v)
end

function class.IsPaidItemTradingAllowed(_)
	local policyInfo = PlayerDataController:Get("PolicyInfo")
	return policyInfo and policyInfo.IsPaidItemTradingAllowed
end

function class:UserIDsAllowed()
	return not self:IsChina()
end

function class:UsernamesAllowed()
	return not self:IsChina()
end

function class:UseDisplayNames()
	return true
end

function class:GetName(p)
	return Utility:GetName(p, self:UseDisplayNames() and p.DisplayName or p.Name)
end

function class:GetUserInfos(items, p)
	if not p then
		return self:_GetUserInfos(items)
	end

	local v = {}
	local v2 = {}

	for k, item in pairs(items) do
		if k <= p then
			table.insert(v, item)
		else
			table.insert(v2, item)
		end
	end

	local result = {}

	for _, v3 in pairs({ v, v2 }) do
		for k, v4 in pairs(self:_GetUserInfos(v3)) do
			result[k] = v4
		end
	end

	return result
end

function class:_GetUserInfos(items)
	local v = {}

	for _, item in pairs(items) do
		if self._user_info_cache[tostring(item)] or self._is_fetching_user_info[tostring(item)] then
			continue
		end

		table.insert(v, item)
	end

	for _, v2 in pairs(v) do
		self._is_fetching_user_info[tostring(v2)] = true
	end

	local success, userInfosByUserIdsAsync = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, v)

	for _, v2 in pairs(v) do
		self._is_fetching_user_info[tostring(v2)] = nil
	end

	if not success then
		return {}
	end

	for _, v2 in pairs(userInfosByUserIdsAsync) do
		self._user_info_cache[tostring(v2.Id)] = v2
	end

	local result = {}

	for _, item in pairs(items) do
		result[tostring(item)] = self._user_info_cache[tostring(item)] or nil
	end

	for _, v2 in pairs(userInfosByUserIdsAsync) do
		result[tostring(v2.Id)] = v2
	end

	return result
end

function class:_BlacklistedObject(instance)
	if self._country_code == instance:GetAttribute("CountryCode") then
		task.defer(instance.Destroy, instance)
	end
end

function class:_WhitelistedObject(instance)
	if self._country_code ~= instance:GetAttribute("CountryCode") then
		task.defer(instance.Destroy, instance)
	end
end

function class:_SetupLocaleObjects()
	local success, countryRegionForPlayerAsync = pcall(
		LocalizationService.GetCountryRegionForPlayerAsync,
		LocalizationService,
		Players.LocalPlayer
	)

	if success then
		self._country_code = countryRegionForPlayerAsync
	else
		warn("Failed to fetch country code, error:", countryRegionForPlayerAsync)
	end

	CollectionService:GetInstanceAddedSignal("RegionHideThisObject"):Connect(function(p)
		self:_BlacklistedObject(p)
	end)
	CollectionService:GetInstanceAddedSignal("RegionShowThisObject"):Connect(function(p)
		self:_WhitelistedObject(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("RegionHideThisObject")) do
		task.defer(self._BlacklistedObject, self, v)
	end

	for _, v in pairs(CollectionService:GetTagged("RegionShowThisObject")) do
		task.defer(self._WhitelistedObject, self, v)
	end
end

function class:_Init()
	task.defer(self._SetupLocaleObjects, self)
end

return class._new()