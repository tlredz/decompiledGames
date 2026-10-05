local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local RunService = game:GetService("RunService")
local Cache = require(game.ReplicatedStorage.UserGenerated.Concurrency.Cache)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local cache = Cache.new({
	Callback = function(p)
		return GroupService:GetGroupsAsync(p)
	end,
	AssertKey = Asserts.Integer,
	MaxAge = 1e999
})
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	task.delay(60, function()
		if not Players:GetPlayerByUserId(userId) then
			cache:Delete(userId)
		end
	end)
end)

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(player)
		cache:GetAsync(player.UserId)
	end)
else
	task.spawn(function()
		cache:GetAsync(Players.LocalPlayer.UserId)
	end)
end

return table.freeze({
	Cache = cache,
	GetGroupsAsync = function(self: number, flag: boolean?)
		Asserts.Integer(self)
		Asserts.Optional(Asserts.Boolean)(flag)

		if flag then
			return cache:Get(self)
		end

		return cache:GetAsync(self)
	end
})