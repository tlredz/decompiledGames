local NewUserDataController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil

function NewUserDataController.FrameworkInit() end

function NewUserDataController.FrameworkStart() end

function NewUserDataController.QueryUserData()
	if v == nil then
		v = Promise.try(function()
			local v2, v3, v4 = Remotes.invokeServer("NewUserData")
			return { v2, v3, v4 }
		end)
	end
end

function NewUserDataController.IsFirstSession()
	NewUserDataController.QueryUserData()
	local v2, v3 = v:await()
	local v4 = v2 and v3[1]

	if v4 then
		if v3[2] == nil or not (v3[2] <= 1) or v3[3] == nil then
			return false
		else
			return v3[3] > 1744295545000
		end
	end

	return v4
end

function NewUserDataController.GetNewUserData()
	NewUserDataController.QueryUserData()
	local v2, v3 = v:await()

	if v2 then
		return v3[1], v3[2], v3[3]
	end

	return false, nil, nil
end

return NewUserDataController