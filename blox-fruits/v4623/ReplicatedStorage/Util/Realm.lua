local RunService = game:GetService("RunService")
local Net = require(game.ReplicatedStorage.Modules.Net)
require(script.Types)
local v = nil
local v2 = {}
local getHasTag

if RunService:IsRunning() then
	getHasTag = Net:RemoteFunction("GetRealmHasTag")
else
	getHasTag = nil
end

local getDifficulty

if RunService:IsRunning() then
	getDifficulty = Net:RemoteFunction("GetRealmDifficulty")
else
	getDifficulty = nil
end

local getIslands

if RunService:IsRunning() then
	getIslands = Net:RemoteFunction("GetRealmIslands")
end

local Realm = {
	_Remotes = {
		GetHasTag = getHasTag,
		GetDifficulty = getDifficulty,
		GetIslands = getIslands
	}
}

function Realm.getCurrentSeaAsync()
	if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") then
		return "Sea3"
	end

	if Realm.getIfCurrentRealmHasTagAsync("IsSecondSea") then
		return "Sea2"
	end

	if Realm.getIfCurrentRealmHasTagAsync("IsFirstSea") then
		return "Sea1"
	end

	return nil
end

function Realm.safeGetCurrentSeaAsync()
	if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") then
		return "Sea3"
	end

	if Realm.getIfCurrentRealmHasTagAsync("IsSecondSea") then
		return "Sea2"
	end

	if Realm.getIfCurrentRealmHasTagAsync("IsFirstSea") then
		return "Sea1"
	end

	local currentRealmDifficultyAsync = Realm.getCurrentRealmDifficultyAsync()

	if currentRealmDifficultyAsync >= 3 then
		return "Sea3"
	end

	if currentRealmDifficultyAsync == 2 then
		return "Sea2"
	end

	return "Sea1"
end

function Realm.getIfCurrentRealmHasTagAsync(tag)
	if RunService:IsServer() then
		local Realms = require(game.ServerStorage.Realms)
		return Realms.getCurrentRealm():HasTag(tag)
	end

	local v6 = v2[tag]

	if v6 ~= nil then
		return v6
	end

	assert(getHasTag, "no GetRealmHasTagRemoteFunction")
	local v7 = getHasTag:InvokeServer(tag)
	assert(type(v7) == "boolean", "Bad result from GetRealmHasTagRemoteFunction")
	v2[tag] = v7
	return v7
end

function Realm.getCurrentRealmDifficultyAsync()
	if RunService:IsServer() then
		local Realms = require(game.ServerStorage.Realms)
		return Realms.getCurrentRealm().Difficulty
	end

	if v then
		return v
	end

	assert(getDifficulty, "no GetRealmDifficulty")
	local v6 = getDifficulty:InvokeServer()
	assert(type(v6) == "number", "Bad result from GetRealmDifficulty")
	v = v6
	return v6
end

return Realm