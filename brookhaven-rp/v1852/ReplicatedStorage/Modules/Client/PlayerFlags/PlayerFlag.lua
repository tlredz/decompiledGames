local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local v = CountDownLatch.new(1)
local v2 = nil
local PlayerFlag = {}

function PlayerFlag.FrameworkInit() end

function PlayerFlag.FrameworkStart()
	local expect = ReplicatedDataController.GetSessionReplicaPromise():expect()
	v2 = expect

	if expect.Data.PlayerFlags == nil then
		expect:OnSet({ "PlayerFlags" }, function()
			v:countDown()
		end)
	else
		v:countDown()
	end
end

function PlayerFlag.IsEnabled(p: string)
	v:await()

	if v2 == nil then
		return false
	end

	local playerFlags = v2.Data.PlayerFlags

	if playerFlags == nil then
		return false
	end

	assert(playerFlags[p] ~= nil, "unknown flag: " .. p)
	return playerFlags[p] == true
end

return PlayerFlag