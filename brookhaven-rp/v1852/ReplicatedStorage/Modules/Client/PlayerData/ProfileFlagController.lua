local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local ProfileFlagController = {}

function ProfileFlagController.IsCompleted(p)
	local v, v2 = ReplicatedDataController.GetClientReplicaPromise():await()

	if v and v2 ~= nil then
		return v2.Data.flags[ProfileFlags.GetKey(p)] or false
	end

	return false
end

function ProfileFlagController.Complete(p)
	Remotes.fireServer("ProfileFlag:Complete", ProfileFlags.GetKey(p))
end

return ProfileFlagController