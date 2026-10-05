local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.ClansData)
local frozen = table.freeze({
	INVITE_MEMBERS = 0,
	CHANGE_BADGE = 1,
	MANAGE_APPLICATIONS = 2,
	SET_RECOMMENDED_UPGRADE = 3,
	POST_SHOUT = 4,
	VIEW_AUDIT_LOGS = 5,
	VIEW_PERMISSIONS = 6,
	CHANGE_PERMISSIONS = 7,
	CHANGE_DESCRIPTION = 8,
	CHANGE_REQUIREMENTS = 9,
	HOST_CLAN_BATTLE = 10,
	KICK_MEMBERS = 11
})
local v2 = 0

for _, v3 in frozen do
	local v4 = bit32.lshift(1, v3)
	v2 = bit32.bor(v2, v4)
end

local function getPermissionsBitfield(items)
	local v3 = {}

	for _, item in items do
		table.insert(v3, (bit32.lshift(1, (assert(frozen[item], (`"{item}" is not a valid permission!`))))))
	end

	return (bit32.bor(table.unpack(v3)))
end

local v3 = {
	Permissions = frozen,
	ReplacedLegacyRoles = table.freeze({
		Underboss = "Admin"
	}),
	Ranks = table.freeze({
		"Member",
		"Admin",
		"Co-Owner",
		"Owner"
	}),
	RanksColor = table.freeze({
		Underboss = Color3.fromRGB(255, 56, 56),
		Member = Color3.fromRGB(180, 180, 180),
		Admin = Color3.fromRGB(255, 56, 56),
		["Co-Owner"] = Color3.fromRGB(0, 255, 51),
		Owner = Color3.fromRGB(255, 200, 0)
	}),
	DefaultPermissions = table.freeze({
		Admin = getPermissionsBitfield({ "INVITE_MEMBERS" }),
		["Co-Owner"] = getPermissionsBitfield({
			"INVITE_MEMBERS",
			"CHANGE_BADGE",
			"MANAGE_APPLICATIONS",
			"SET_RECOMMENDED_UPGRADE",
			"POST_SHOUT",
			"VIEW_AUDIT_LOGS",
			"VIEW_PERMISSIONS",
			"CHANGE_DESCRIPTION",
			"HOST_CLAN_BATTLE"
		})
	}),
	getPermissionBitfield = function(p: string)
		return (bit32.lshift(1, (assert(frozen[p], (`"{p}" is not a valid permission!`)))))
	end,
	getPermissionsBitfield = getPermissionsBitfield,
	hasPermission = function(p: string, p2: number)
		local v4 = bit32.lshift(1, (assert(frozen[p], (`"{p}" is not a valid permission!`))))
		return bit32.band(p2, v4) == v4
	end,
	getBitfieldPermissions = function(p: number)
		local result = {}

		for k in frozen do
			local v4 = bit32.lshift(1, (assert(frozen[k], (`"{k}" is not a valid permission!`))))

			if bit32.band(p, v4) == v4 then
				table.insert(result, k)
			end
		end

		return result
	end,
	isValidPermissionsBitfield = function(p: number)
		return p >= 0 and p <= v2
	end,
	getRank = function(p, p2)
		local formattedUserId = v.getFormattedUserId(p)

		if v.parseUserId(formattedUserId) == v.parseUserId(p2.owner) then
			return "Owner"
		end

		if p2.ranks then
			return p2.ranks[formattedUserId] or "Member"
		end

		return "Member"
	end
}

function v3.hasPermissionFor(p, p2: string, p3)
	local rank = v3.getRank(p, p3)

	if rank == "Owner" then
		return true
	end

	local v4

	if p3.ranksPermission then
		v4 = p3.ranksPermission[rank]
	else
		v4 = v3.DefaultPermissions[rank]
	end

	if not v4 then
		return false
	end

	local v5 = bit32.lshift(1, (assert(frozen[p2], (`"{p2}" is not a valid permission!`))))
	return bit32.band(v4, v5) == v5
end

return table.freeze(v3)