local CmdrPermissions = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Logger = require(packages.Logger)
local Permissions = require(ReplicatedStorage.Modules.Shared.Permissions)
local GroupUtil = require(ReplicatedStorage.Modules.Shared.Utils.GroupUtil)
local RolePermissions = require(ReplicatedStorage.Modules.Shared.DB.CMDR.RolePermissions)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
CmdrPermissions.PRIVATE_SERVER_COMMAND_ACCESS_ATTRIBUTE = "HasPrivateServerCmdrAccess"
local v = {
	cc_setCommandAccess = true,
	cc_listCommandAccess = true
}

local function doesCommandSetHaveAccessToCommand(items, commandSets, p: string)
	local v2 = false

	for _, item in pairs(items) do
		if commandSets[item] then
			if table.find(commandSets[item], p) then
				v2 = true
			end
		else
			Logger.warn("Command set not found: ", item)
		end
	end

	return v2
end

local function hasGrantedPrivateServerCommandAccess(instance, p: string)
	if not (instance:GetAttribute(CmdrPermissions.PRIVATE_SERVER_COMMAND_ACCESS_ATTRIBUTE) == true and GameUtil.IsPrivateServer() == true and v[p] ~= true) then
		return false
	end

	local config = RolePermissions.GetConfig()
	local contentCreators = config.Roles.ContentCreators

	if contentCreators == nil then
		return false
	end

	local placeId = tostring(game.PlaceId)
	local v2 = contentCreators.AllowOnOwnedPrivateServersByPlaceId[placeId]
	return v2 ~= nil and doesCommandSetHaveAccessToCommand(v2, config.CommandSets, p)
end

local function doesCommandGroupHaveAccessToCommand(p, rank: number, roles, p2: string)
	if Permissions.hasAdminAccess(p) or hasGrantedPrivateServerCommandAccess(p, p2) then
		return true
	end

	local config = RolePermissions.GetConfig()

	for _, role in pairs(config.Roles) do
		if typeof(role) ~= "table" then
			continue
		end

		local v2 = false
		local roles2 = role.Roles

		if roles2 ~= nil then
			for _, item in roles do
				if table.find(roles2, item.Id) == nil then
					continue
				end

				v2 = true
				break
			end
		end

		if not (role.RoleId == rank or v2) then
			continue
		end

		local commandSets = config.CommandSets
		local placeId = tostring(game.PlaceId)

		if role.AllowPlaceIds[placeId] and doesCommandSetHaveAccessToCommand(
			role.AllowPlaceIds[placeId],
			commandSets,
			p2
		) then
			return true
		end

		if GameUtil.IsPrivateServerOwner(p) and role.AllowOnOwnedPrivateServersByPlaceId[placeId] and doesCommandSetHaveAccessToCommand(
			role.AllowOnOwnedPrivateServersByPlaceId[placeId],
			commandSets,
			p2
		) then
			return true
		end

		return false
	end

	if table.find(config.DefaultCommandSet, p2) then
		return true
	end

	return false
end

function CmdrPermissions.hasCmdrAccess(instance)
	if Permissions.hasAdminAccess(instance) or Permissions.hasContentCreatorAccess(instance) or Permissions.hasModeratorAccess(instance) then
		return true
	end

	return instance:GetAttribute(CmdrPermissions.PRIVATE_SERVER_COMMAND_ACCESS_ATTRIBUTE) == true
end

function CmdrPermissions.hasCommandAccess(p, p2: string)
	return (doesCommandGroupHaveAccessToCommand(p, GroupUtil.getRank(p), GroupUtil.getRoles(p), p2))
end

return CmdrPermissions