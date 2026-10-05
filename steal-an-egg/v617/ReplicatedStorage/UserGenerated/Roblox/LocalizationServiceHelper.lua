local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Cache = require(ReplicatedStorage.UserGenerated.Concurrency.Cache)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local v = Cache.new({
	Callback = function(p)
		local playerByUserId = Players:GetPlayerByUserId(p)
		assert(playerByUserId, "PlayerNotOnline")
		return LocalizationService:GetCountryRegionForPlayerAsync(playerByUserId)
	end,
	AssertKey = Asserts.Integer
})
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	task.delay(60, function()
		if not Players:GetPlayerByUserId(userId) then
			v:Delete(userId)
		end
	end)
end)

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(player)
		v:GetAsync(player.UserId)
	end)
else
	task.spawn(function()
		v:GetAsync(Players.LocalPlayer.UserId)
	end)
end

return table.freeze({
	GetCountryRegionForPlayerAsync = function(self, flag: boolean?)
		Asserts.Player(self)
		Asserts.Optional(Asserts.Boolean)(flag)

		if flag then
			return v:Get(self.UserId)
		end

		return v:GetAsync(self.UserId)
	end
})