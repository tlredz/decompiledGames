local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Result = require(game.ReplicatedStorage.Packages.Result)
local Future = require(game.ReplicatedStorage.Packages.Future)
require(script.Types)
local Remotes = require(script.Remotes)
local CONSTANTS = require(script.CONSTANTS)
local TestingGroupUtil = {
	getReplicationAttributeKey = function(p)
		return CONSTANTS.TESTING_GROUP_PREFIX .. p
	end
}

function TestingGroupUtil.getGroup(p: number, p2)
	return Future.from(function()
		local playerByUserId = Players:GetPlayerByUserId(p)

		if not playerByUserId then
			return Result.err("NullPlayer")
		end

		local attribute = playerByUserId:GetAttribute(TestingGroupUtil.getReplicationAttributeKey(p2))

		if attribute ~= nil then
			return Result.ok(attribute)
		end

		if RunService:IsServer() then
			local TestingService = require(game.ServerScriptService.Services.TestingService)

			while TestingService:GetIfInitialized() == false do
				task.wait()
			end

			local GlobalUtil = require(game.ServerStorage.GlobalUtil)
			local v = GlobalUtil.tryGetSessionByUserId(p)
			assert(v, "bad session")
			return TestingService.getGroup(v.Data, p2)
		else
			local v = Remotes.GetGroupRemoteFunction:InvokeServer(p2)

			if typeof(v) == "string" or typeof(v) == "boolean" or typeof(v) == "number" then
				return Result.ok(v)
			end

			return Result.err("BadResponse")
		end
	end)
end

function TestingGroupUtil.getGroupAsync(p: number, p2)
	local v = TestingGroupUtil.getGroup(p, p2):await()
	v:inspectErr(warn)
	return v:asNullable()
end

return TestingGroupUtil