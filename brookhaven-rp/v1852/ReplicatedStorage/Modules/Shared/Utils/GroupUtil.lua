local GroupService = game:GetService("GroupService")
local GroupUtil = {
	GROUP_ID = 3104358,
	RANK = {
		OWNER = 255,
		LT = 250,
		ADMIN = 240,
		DEVELOPER = 200,
		DESIGN = 180,
		ANALYTICS = 170,
		QA_LEAD = 150,
		VOLDEX_QA = 130,
		VOLDEX_QA_ALT = 100,
		MODERATOR = 80,
		SENIOR_MODERATOR = 90,
		CONTENT_CREATOR = 70
	}
}
local v = {
	[39193858] = true,
	[75249861] = true,
	[379520467] = true,
	[3991272] = true,
	[22748597] = true,
	[3628278923] = true,
	[1422050509] = true,
	[666535490] = true,
	[7462783190] = true,
	[67241739] = true,
	[67243992] = true,
	[2450762569] = true,
	[4391860484] = true,
	[140258990] = true,
	[390311109] = true,
	[4222629767] = true,
	[4603292052] = true,
	[137550731] = true,
	[5178142581] = true,
	[3122797441] = true,
	[1600164993] = true
}
local v2 = {}
setmetatable(v2, {
	__mode = "k"
})
local roles = {}
setmetatable(roles, {
	__mode = "k"
})

function GroupUtil.getRank(object)
	local success, result = pcall(function()
		return object:GetRankInGroupAsync(GroupUtil.GROUP_ID)
	end)

	if not success then
		return v2[object] or 0
	end

	v2[object] = result
	return result
end

function GroupUtil.getRoles(p)
	local success, result = pcall(function()
		return GroupService:GetRolesInGroupAsync(p.UserId, GroupUtil.GROUP_ID)
	end)

	if success ~= true or result == nil or result.Roles == nil then
		return roles[p] or {}
	end

	roles[p] = result.Roles
	return result.Roles
end

function GroupUtil.isAdmin(p)
	local rank = GroupUtil.getRank(p)
	return rank == GroupUtil.RANK.OWNER or rank == GroupUtil.RANK.LT or rank == GroupUtil.RANK.ADMIN or rank == GroupUtil.RANK.DEVELOPER or rank == GroupUtil.RANK.QA_LEAD or rank == GroupUtil.RANK.VOLDEX_QA or rank == GroupUtil.RANK.VOLDEX_QA_ALT or rank == GroupUtil.RANK.ANALYTICS or rank == GroupUtil.RANK.DESIGN
end

function GroupUtil.isModerator(p)
	local rank = GroupUtil.getRank(p)
	return rank == GroupUtil.RANK.MODERATOR or rank == GroupUtil.RANK.SENIOR_MODERATOR
end

function GroupUtil.isContentCreator(p)
	local rank = GroupUtil.getRank(p)

	if v[p.UserId] then
		return true
	end

	return rank == GroupUtil.RANK.CONTENT_CREATOR
end

function GroupUtil.isIdContentCreator(p: number)
	local success, result = pcall(function()
		return GroupService:GetGroupsAsync(p, GroupUtil.GROUP_ID)
	end)

	if not success then
		return false
	end

	for _, v3 in result do
		if v3.Id == GroupUtil.GROUP_ID and v3.Rank == GroupUtil.RANK.CONTENT_CREATOR then
			return true
		end
	end

	return false
end

function GroupUtil.isInGroup(p)
	return GroupUtil.getRank(p) > 0
end

return GroupUtil