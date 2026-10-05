local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local testAttribute = TestLibrary:GetTestAttribute("StudioPermissionsRoleTest")
local PermissionsLibrary = {
	USE_GROUP_ROLES_INSTEAD_OF_DATASTORES = true,
	ALWAYS_AUTHORIZED_TO_USE_COMMANDS = not testAttribute and (CONSTANTS.IS_STUDIO or CONSTANTS.IS_TESTING_SERVER),
	ALWAYS_HAS_PERMISSION = not testAttribute and CONSTANTS.IS_STUDIO,
	PermissionsOrder = {},
	Permissions = {},
	Teams = {},
	Roles = {},
	GetPermissionsRoleNameFromDisplayName = function(self, p2)
		for k, role in pairs(self.Roles) do
			if role.DisplayName == p2 then
				return k
			end
		end
	end,
	IsAdministrator = function(self, items)
		if self.ALWAYS_HAS_PERMISSION then
			return true
		end

		for _, item in pairs(items) do
			local role = self.Roles[item]

			for _, v in pairs(role and role.PermissionNames or {}) do
				local permission = self.Permissions[v]

				if permission and permission.ExtraInformation.IsAdministrator then
					return true
				end
			end
		end

		return false
	end,
	HasPermission = function(self, p, items)
		if self:IsAdministrator(items) then
			return true
		end

		for _, item in pairs(items) do
			local role = self.Roles[item]

			if role and table.find(role.PermissionNames, p) then
				return true
			end
		end

		return false
	end,
	CanViewPermissionsPage = function(self, p)
		return self:HasPermission("permission_permissions_page_access", p)
	end,
	CanManageRole = function(self, p, items)
		if self:IsAdministrator(items) then
			return true
		end

		for _, item in pairs(items) do
			local role = self.Roles[item]

			for _, v in pairs(role and role.PermissionNames or {}) do
				local permission = self.Permissions[v]

				if permission and permission.ExtraInformation.ManageableRoles and table.find(
					permission.ExtraInformation.ManageableRoles,
					p
				) then
					return true
				end
			end
		end

		return false
	end,
	GetManageableRoles = function(self, p)
		local result = {}

		for k, _ in pairs(self.Roles) do
			if self:CanManageRole(k, p) then
				table.insert(result, k)
			end
		end

		return result
	end
}

local function add_permission(name, displayName, description, options)
	assert(not PermissionsLibrary.Permissions[name])
	local v = {
		Name = name,
		DisplayName = displayName,
		Description = description,
		ExtraInformation = options or {},
		PermissionValue = -#PermissionsLibrary.PermissionsOrder
	}
	PermissionsLibrary.Permissions[v.Name] = v
	table.insert(PermissionsLibrary.PermissionsOrder, v.Name)
end

add_permission("permission_administrator", "Administrator", "All permissions are granted", {
	IsAdministrator = true
})
add_permission("permission_permissions_page_access", "Permissions Page", "Grants access to view the Permissions page")
add_permission("permission_leaders_management", "Manage Leaders", "Add, remove, promote, & demote Team Leads", {
	ManageableRoles = { "role_leadtester", "role_leadgamemod" }
})
add_permission("permission_freecamaccess", "Freecam Access", "Grants access to using Freecam mode any time")
add_permission("permission_funcommands", "Fun Commands", "Grants access to using fun commands in all servers")
add_permission("permission_moderation_modpanel_access", "Moderation Page", "Grants access to view the Moderation page")
add_permission(
	"permission_moderation_modpanel_investigate_full",
	"Investigative Tools",
	"Allows you use tools to investigate top leaderboard players"
)
add_permission(
	"permission_moderation_modpanel_viewbanned_full",
	"View Ban Status & Logs",
	"Allows you to view the ban status & ban logs of any player"
)
add_permission(
	"permission_moderation_modpanel_viewactions_full",
	"View Action History",
	"Allows you to view the action history of any other Moderator"
)
add_permission(
	"permission_moderation_modpanel_teleport_full",
	"Join Any Player",
	"Allows you to teleport to anyone's server (except Private Servers)"
)
add_permission("permission_moderation_modpanel_unban", "Unban Any Player", "Allows you to unban any player")
add_permission(
	"permission_moderation_modpanel_moderate_limited",
	"Ban Average Players",
	"Allows you to ban players under 10,000 Robux spent / 1,000 historic peak Win Streak / 3,600 historic peak ELO",
	{
		UnderThisELO = 3600,
		UnderThisStreak = 1000,
		UnderThisRobuxSpent = 10000
	}
)
add_permission(
	"permission_moderation_modpanel_moderate_most",
	"Ban Most Players",
	"Allows you to ban any player, except high ranking Nosniy Games group members"
)
add_permission("permission_moderation_modpanel_moderate_full", "Ban Any Player", "Allows you to ban any player")
add_permission(
	"permission_moderation_modpanel_evict_limited",
	"Evict From Hub & Arcade",
	"Allows you to kick players from hub duels & arcade servers only (affects bans)"
)
add_permission(
	"permission_moderation_modpanel_evict_full",
	"Evict From Anywhere",
	"Allows you to kick players from anywhere (affects bans)"
)
add_permission(
	"permission_moderation_modpanel_viewdata_limited",
	"View Necessary Player Data",
	"Allows you to view player data that is only relevant to obvious moderation purposes"
)
add_permission(
	"permission_moderation_modpanel_viewdata_most",
	"View Most Player Data",
	"Allows you to view everything in someone's player data, except total robux spent"
)
add_permission(
	"permission_moderation_modpanel_viewdata_full",
	"View All Player Data",
	"Allows you to view everything in someone's player data"
)
add_permission(
	"permission_moderation_modpanel_pardon_limited",
	"Pardon Some Anticheat Bans",
	"Allows you to pardon anticheat bans from a strict whitelist"
)
add_permission(
	"permission_moderation_modpanel_pardon_full",
	"Pardon Any Anticheat Ban",
	"Allows you to pardon any anticheat ban"
)
add_permission(
	"permission_moderation_modpanel_lock",
	"Ban Lock Powers",
	"Allows you to lock a player from being banned, unbanned, kicked, etc"
)
add_permission(
	"permission_moderation_modpanel_removelbs_limited",
	"Remove From Leaderboards",
	"Allows you to wipe players from all leaderboards (only works for banned / restricted players)"
)
add_permission(
	"permission_moderation_modpanel_warn_template",
	"Warn Players On Ban",
	"Allows you to send a template warning message to any player during a ban"
)
add_permission(
	"permission_moderation_modpanel_warn_custom",
	"Warn Any Player",
	"Allows you to send a custom warning message to any player"
)
add_permission(
	"permission_moderation_modpanel_restrict",
	"Restrict Any Player",
	"Allows you to restrict players from features such as casual & competitive leaderboards"
)
add_permission(
	"permission_moderation_management",
	"Manage Moderators",
	"Add, remove, promote, & demote anyone related to the Moderation Team",
	{
		ManageableRoles = {
			"role_trialgamemod",
			"role_jrgamemod",
			"role_gamemod",
			"role_srgamemod"
		}
	}
)
add_permission("permission_testing_zfaccess", "ZF Access", "Grants access to the testing server")
add_permission(
	"permission_testing_publiccommands_safe",
	"Helpful Commands",
	"Gives access to a few helpful debug commands in public servers"
)
add_permission(
	"permission_testing_publiccommands_bugrewards",
	"Bug Rewarder Command",
	"Gives access to the command to hand out bug rewards"
)
add_permission(
	"permission_testing_management",
	"Manage Testers",
	"Add, remove, promote, & demote anyone related to the Testing Team",
	{
		ManageableRoles = { "role_backuptester", "role_tester" }
	}
)

local function add_team(teamValue, name, displayName, icon, color)
	assert(not PermissionsLibrary.Teams[name])
	local v = {
		TeamValue = teamValue,
		Name = name,
		DisplayName = displayName,
		Icon = icon,
		Color = color,
		RoleNames = {}
	}
	PermissionsLibrary.Teams[v.Name] = v
	table.sort(v.RoleNames, function(a, b)
		return PermissionsLibrary.Permissions[a].PermissionValue > PermissionsLibrary.Permissions[b].PermissionValue
	end)
end

add_team(4, "team_leadership", "Leadership", "rbxassetid://111377968573170", Color3.fromRGB(191, 0, 255))
add_team(3, "team_moderation", "Moderation", "rbxassetid://118920750856778", Color3.fromRGB(230, 126, 34))
add_team(2, "team_testing", "Testing", "rbxassetid://18223601855", Color3.fromRGB(241, 196, 15))
add_team(1, "team_other", "Other", "rbxassetid://17548980857", Color3.fromRGB(127, 127, 127))

local function add_role(groupRoleID, teamName, roleValue, name, color, displayName, permissionNames)
	assert(PermissionsLibrary.Teams[teamName])
	assert(not (PermissionsLibrary.Roles[name] or PermissionsLibrary:GetPermissionsRoleNameFromDisplayName(displayName)))

	for _, item in pairs(permissionNames) do
		assert(PermissionsLibrary.Permissions[item], item)
	end

	local v = {
		GroupRoleID = groupRoleID,
		TeamName = teamName,
		RoleValue = roleValue,
		Name = name,
		Color = color,
		DisplayName = displayName,
		PermissionNames = permissionNames
	}
	PermissionsLibrary.Roles[v.Name] = v
	table.insert(PermissionsLibrary.Teams[v.TeamName].RoleNames, v.Name)
end

add_role(
	23832226,
	"team_leadership",
	2,
	"role_administrator",
	Color3.fromRGB(191, 0, 255),
	"Administrator",
	{ "permission_administrator" }
)
add_role(855122020, "team_leadership", 1, "role_director", Color3.fromRGB(113, 122, 254), "Director", {
	"permission_permissions_page_access",
	"permission_leaders_management",
	"permission_testing_management",
	"permission_moderation_management"
})
add_role(855486017, "team_moderation", 5, "role_leadgamemod", Color3.fromRGB(156, 41, 0), "Lead Game Moderator", {
	"permission_moderation_modpanel_access",
	"permission_moderation_modpanel_viewbanned_full",
	"permission_moderation_modpanel_removelbs_limited",
	"permission_moderation_modpanel_teleport_full",
	"permission_moderation_modpanel_moderate_full",
	"permission_moderation_modpanel_viewdata_full",
	"permission_moderation_modpanel_evict_full",
	"permission_moderation_modpanel_pardon_full",
	"permission_moderation_modpanel_warn_template",
	"permission_moderation_modpanel_warn_custom",
	"permission_moderation_modpanel_restrict",
	"permission_moderation_modpanel_viewactions_full",
	"permission_moderation_modpanel_investigate_full",
	"permission_moderation_modpanel_unban",
	"permission_moderation_modpanel_lock",
	"permission_permissions_page_access",
	"permission_moderation_management"
})
add_role(855568028, "team_moderation", 4, "role_srgamemod", Color3.fromRGB(255, 68, 0), "Senior Game Moderator", {
	"permission_moderation_modpanel_access",
	"permission_moderation_modpanel_viewbanned_full",
	"permission_moderation_modpanel_removelbs_limited",
	"permission_moderation_modpanel_teleport_full",
	"permission_moderation_modpanel_moderate_most",
	"permission_moderation_modpanel_viewdata_most",
	"permission_moderation_modpanel_evict_full",
	"permission_moderation_modpanel_pardon_limited",
	"permission_moderation_modpanel_warn_template",
	"permission_moderation_modpanel_warn_custom",
	"permission_moderation_modpanel_restrict",
	"permission_moderation_modpanel_viewactions_full",
	"permission_moderation_modpanel_investigate_full",
	"permission_moderation_modpanel_unban"
})
add_role(854242030, "team_moderation", 3, "role_gamemod", Color3.fromRGB(230, 126, 34), "Game Moderator", {
	"permission_moderation_modpanel_access",
	"permission_moderation_modpanel_viewbanned_full",
	"permission_moderation_modpanel_removelbs_limited",
	"permission_moderation_modpanel_teleport_full",
	"permission_moderation_modpanel_moderate_most",
	"permission_moderation_modpanel_viewdata_most",
	"permission_moderation_modpanel_evict_full",
	"permission_moderation_modpanel_pardon_limited",
	"permission_moderation_modpanel_warn_template",
	"permission_moderation_modpanel_warn_custom",
	"permission_moderation_modpanel_restrict",
	"permission_moderation_modpanel_viewactions_full",
	"permission_moderation_modpanel_investigate_full",
	"permission_moderation_modpanel_unban"
})
add_role(854812013, "team_moderation", 2, "role_jrgamemod", Color3.fromRGB(230, 150, 80), "Junior Game Moderator", {
	"permission_moderation_modpanel_access",
	"permission_moderation_modpanel_viewbanned_full",
	"permission_moderation_modpanel_removelbs_limited",
	"permission_moderation_modpanel_teleport_full",
	"permission_moderation_modpanel_moderate_most",
	"permission_moderation_modpanel_viewdata_limited",
	"permission_moderation_modpanel_evict_limited",
	"permission_moderation_modpanel_pardon_limited",
	"permission_moderation_modpanel_warn_template",
	"permission_moderation_modpanel_warn_custom",
	"permission_moderation_modpanel_restrict",
	"permission_moderation_modpanel_viewactions_full",
	"permission_moderation_modpanel_investigate_full",
	"permission_moderation_modpanel_unban"
})
add_role(853986021, "team_moderation", 1, "role_trialgamemod", Color3.fromRGB(230, 170, 118), "Trial Game Moderator", {
	"permission_moderation_modpanel_access",
	"permission_moderation_modpanel_viewbanned_full",
	"permission_moderation_modpanel_removelbs_limited",
	"permission_moderation_modpanel_teleport_full",
	"permission_moderation_modpanel_moderate_most",
	"permission_moderation_modpanel_viewdata_limited",
	"permission_moderation_modpanel_evict_limited",
	"permission_moderation_modpanel_pardon_limited",
	"permission_moderation_modpanel_warn_template",
	"permission_moderation_modpanel_restrict"
})
add_role(855640022, "team_testing", 3, "role_leadtester", Color3.fromRGB(162, 130, 0), "Lead Tester", {
	"permission_testing_zfaccess",
	"permission_testing_publiccommands_safe",
	"permission_testing_publiccommands_bugrewards",
	"permission_permissions_page_access",
	"permission_testing_management",
	"permission_moderation_modpanel_access",
	"permission_moderation_modpanel_teleport_full",
	"permission_moderation_modpanel_viewdata_full"
})
add_role(
	33929719,
	"team_testing",
	2,
	"role_tester",
	Color3.fromRGB(241, 196, 15),
	"Tester",
	{ "permission_testing_zfaccess", "permission_testing_publiccommands_safe" }
)
add_role(
	854386033,
	"team_testing",
	1,
	"role_backuptester",
	Color3.fromRGB(252, 231, 145),
	"Backup Tester",
	{ "permission_testing_zfaccess", "permission_testing_publiccommands_safe" }
)
add_role(
	854788035,
	"team_other",
	2,
	"role_funcommands",
	Color3.fromRGB(127, 127, 127),
	"Fun Commands",
	{ "permission_funcommands" }
)
add_role(
	854710017,
	"team_other",
	1,
	"role_freecam",
	Color3.fromRGB(127, 127, 127),
	"Freecam",
	{ "permission_freecamaccess" }
)

local function final_asserts()
	for _, permission in pairs(PermissionsLibrary.Permissions) do
		for _, v in pairs(permission.ExtraInformation.ManageableRoles or {}) do
			assert(PermissionsLibrary.Roles[v] ~= nil, v)
		end
	end
end

final_asserts()
return PermissionsLibrary