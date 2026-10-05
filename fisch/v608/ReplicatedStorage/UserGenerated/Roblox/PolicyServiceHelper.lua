local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Cache = require(game.ReplicatedStorage.UserGenerated.Concurrency.Cache)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local externalLinkReference = {
	Discord = 0,
	Facebook = 1,
	Twitch = 2,
	YouTube = 3,
	X = 4,
	GitHub = 5,
	Guilded = 6
}
table.freeze(externalLinkReference)
local v2 = Cache.new({
	Callback = function(p)
		local playerByUserId = Players:GetPlayerByUserId(p)
		assert(playerByUserId, "PlayerNotOnline")
		return PolicyService:GetPolicyInfoForPlayerAsync(playerByUserId)
	end,
	AssertKey = Asserts.Integer
})
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	task.delay(60, function()
		if not Players:GetPlayerByUserId(userId) then
			v2:Delete(userId)
		end
	end)
end)

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(player)
		v2:GetAsync(player.UserId)
	end)
end

return table.freeze({
	ExternalLinkReference = externalLinkReference,
	ExternalLinkReferencesToInts = function(list)
		local result = {}

		for _, v3 in ipairs(list) do
			local v4 = externalLinkReference[v3]

			if v4 then
				table.insert(result, v4)
			end
		end

		return result
	end,
	GetPolicyInfoForPlayerAsync = function(self, flag: boolean?)
		Asserts.Player(self)
		Asserts.Optional(Asserts.Boolean)(flag)

		if flag then
			return v2:Get(self.UserId)
		end

		return v2:GetAsync(self.UserId)
	end
})