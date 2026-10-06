local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local remoteFunction = Net:RemoteFunction("GroupJoinRewardRequest")
local remoteFunction2 = Net:RemoteFunction("GroupJoinRewardHasClaimed")
local v = nil
local v2 = {}

local function serverHandleRequest(object)
	if not v then
		return {
			ok = false,
			reason = "not_initialized"
		}
	end

	if v2[object] then
		return {
			ok = false,
			reason = "pending"
		}
	end

	if v.hasClaimed(object) then
		return {
			ok = false,
			reason = "already_claimed"
		}
	end

	v2[object] = true
	local success, result = pcall(function()
		return object:IsInGroupAsync(game.CreatorId)
	end)

	if not (success and result) then
		v2[object] = nil
		return {
			ok = false,
			reason = "not_in_group"
		}
	end

	if v.hasClaimed(object) then
		v2[object] = nil
		return {
			ok = false,
			reason = "already_claimed"
		}
	end

	local success2, result2 = pcall(v.grantReward, object)

	if success2 then
		if typeof(result2) == "table" and result2.ok == true then
			v.markClaimed(object)
			v2[object] = nil
			return {
				ok = true,
				results = result2.results
			}
		else
			local reason

			if typeof(result2) == "table" then
				reason = result2.reason
			end

			warn((`[GroupJoinRewardService] 发奖未成功: {reason}`))
			v2[object] = nil
			return {
				ok = false,
				reason = reason or "error"
			}
		end
	else
		warn((`[GroupJoinRewardService] 发奖回调出错: {result2}`))
		v2[object] = nil
		return {
			ok = false,
			reason = "error"
		}
	end
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p)
		local success, result = pcall(serverHandleRequest, p)

		if success then
			return result
		end

		warn((`[GroupJoinRewardService] 处理请求出错: {result}`))
		v2[p] = nil
		return {
			ok = false,
			reason = "error"
		}
	end

	remoteFunction2.OnServerInvoke = function(p)
		if not v then
			return false
		end

		local success, result = pcall(v.hasClaimed, p)
		return success and result == true
	end

	Players.PlayerRemoving:Connect(function(player)
		v2[player] = nil
	end)
end

local function initServer(p)
	v = p
end

local function clientRequest()
	local success, result = pcall(function()
		return GroupService:PromptJoinAsync(game.CreatorId)
	end)

	if not success then
		warn((`[GroupJoinRewardService] 加群弹窗出错: {result}`))
		return {
			ok = false,
			reason = "prompt_failed"
		}
	end

	if result ~= Enum.GroupMembershipStatus.Joined and result ~= Enum.GroupMembershipStatus.AlreadyMember then
		return {
			ok = false,
			reason = "not_joined"
		}
	end

	local success2, result2 = pcall(function()
		return remoteFunction:InvokeServer()
	end)

	if success2 then
		return result2
	end

	warn((`[GroupJoinRewardService] 领取请求出错: {result2}`))
	return {
		ok = false,
		reason = "request_failed"
	}
end

local function clientHasClaimed()
	local success, result = pcall(function()
		return remoteFunction2:InvokeServer()
	end)

	if success then
		return result == true
	end

	warn((`[GroupJoinRewardService] 查询领取状态出错: {result}`))
	return false
end

return {
	server = {
		init = initServer
	},
	client = {
		request = clientRequest,
		hasClaimed = clientHasClaimed
	}
}