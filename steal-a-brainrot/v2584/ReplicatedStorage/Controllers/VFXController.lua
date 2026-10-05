local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local localPlayer = Players.LocalPlayer
return {
	Start = function(_)
		local enabled2 = false
		Synchronizer:WaitAndCall(localPlayer, function(object)
			object:OnChanged("Settings.VFX", function(enabled: boolean)
				enabled2 = enabled

				for _, v2 in CollectionService:GetTagged("VFX") do
					v2.Enabled = enabled
				end
			end, true)
		end)
		Observers.observeTagNoAncestry("VFX", function(p)
			p.Enabled = enabled2
			return nil
		end)
	end
}