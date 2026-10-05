local ProfileTags = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
ProfileTags.ProfileTags = {}

function ProfileTags.HasTag(_, p: string)
	return table.find(ProfileTags.ProfileTags, p) and true or false
end

Network:listen("ReceivedProfile", function(p, p2)
	if p == Players.LocalPlayer then
		ProfileTags.ProfileTags = p2.Tags
	end
end)
task.spawn(function()
	if not localPlayer:GetAttribute("Loaded") then
		localPlayer:GetAttributeChangedSignal("Loaded"):Wait()
	end

	ProfileTags.ProfileTags = Network:invoke("GetProfileTags")
end)
return ProfileTags