local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)

local function isNumber(value)
	return type(value) == "number"
end

local function isString(value)
	return type(value) == "string"
end

local function isTable(p)
	return type(p) == "table"
end

local function isBoolean(p)
	return type(p) == "boolean"
end

local function isUserRef(value)
	return type(value) == "number" or type(value) == "string"
end

local function optional(callback)
	return function(p)
		return p == nil or callback(p)
	end
end

return remo.createRemotes({
	CCPanel = remo.namespace({
		SpectateFollow = remo.remote(function(p)
			return p == nil or isNumber(p)
		end),
		TrollAction = remo.remote(isString, isNumber),
		CheckRole = remo.remote().returns(isTable),
		GiftTreadmill = remo.remote(isString, isNumber, function(p)
			return p == nil or isString(p)
		end).returns(isTable),
		GetGiftTreadmillState = remo.remote().returns(isTable),
		SelfGiftCandy = remo.remote().returns(isTable),
		GetSelfCandyState = remo.remote().returns(isTable),
		GetTrollState = remo.remote().returns(isTable),
		GetCCWorldState = remo.remote().returns(isTable),
		TeleportToCCWorld = remo.remote(isNumber).returns(isTable),
		ReturnToProd = remo.remote().returns(isTable),
		CCWorldGiveAll = remo.remote(isString).returns(isTable),
		CCWorldCatalog = remo.remote(isString).returns(isTable),
		CCWorldGiveOne = remo.remote(isString, isString).returns(isTable),
		CCWorldSetStat = remo.remote(isString, isNumber).returns(isTable),
		CCWorldResetData = remo.remote().returns(isTable),
		SendCCWorldInvite = remo.remote(isUserRef).returns(isTable),
		RespondCCWorldInvite = remo.remote(isString, isBoolean).returns(isTable),
		CCWorldInviteReceived = remo.remote(isTable),
		CCWorldInviteAck = remo.remote(isTable)
	})
}).CCPanel