local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GroupUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Utils"):WaitForChild("GroupUtil"))
local GameUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Game"):WaitForChild("GameUtil"))
local Permissions = {}

function Permissions.hasAdminAccess(p)
	if RunService:IsStudio() or (GameUtil.isDevPlace() or GameUtil.isQAPlace()) then
		return true
	end

	return GroupUtil.isAdmin(p)
end

function Permissions.hasContentCreatorAccess(p)
	if RunService:IsStudio() then
		return true
	end

	return GroupUtil.isContentCreator(p)
end

function Permissions.hasModeratorAccess(p)
	if RunService:IsStudio() then
		return true
	end

	return GroupUtil.isModerator(p)
end

return Permissions