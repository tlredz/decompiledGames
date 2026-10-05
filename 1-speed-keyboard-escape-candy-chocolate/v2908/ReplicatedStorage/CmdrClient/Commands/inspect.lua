local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
AdminPermissions.linkCommandToPermission("inspect", "cui.admin.inspect")

if RunService:IsServer() then
	require(ReplicatedStorage.Cmdr.Menus.InspectMenu)
end

return {
	Name = "inspect",
	Aliases = {},
	Description = "Inspect the data of a certain user, online or not.",
	Group = "Admin",
	Args = {
		{
			Type = "player # number ? string",
			Name = "Target Player",
			Description = "Target player to inspect data of (prefix # for userid, ? for offline username)"
		}
	},
	ClientRun = function(_, userId)
		if typeof(userId) == "Instance" then
			userId = userId.UserId
		elseif typeof(userId) ~= "number" then
			userId = Players:GetUserIdFromNameAsync(userId)
		end

		local InspectMenu = require(ReplicatedStorage.Cmdr.Menus.InspectMenu)
		InspectMenu.Open(userId)
		return "Menu Opened"
	end
}