local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Set = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Set)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local remo = require(ReplicatedStorage.Packages.remo)
local v = Set.new()
local PlayerReady = {
	onPlayerReady = Signal.new(),
	remotes = remo.createRemotes({
		PlayerReady = remo.remote()
	})
}
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			Players.PlayerAdded:Connect(function(player)
				PlayerReady.onPlayerReady:Fire(player)
			end)
			return
		end

		PlayerReady.remotes.PlayerReady:connect(function(p)
			if v:has(p) then
				return
			end

			v:add(p)
			PlayerReady.onPlayerReady:Fire(p)
		end)
		Players.PlayerRemoving:Connect(function(player)
			v:delete(player)
		end)
	end
})
return PlayerReady