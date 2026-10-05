_G.GroupId = 16357742

local function verifyCreator(object)
	return object.UserId < 0 or object:GetRoleInGroup(_G.GroupId) == "Owner"
end

local function verifyDeveloper(object)
	return object:GetRoleInGroup(_G.GroupId) == "Developers"
end

local function verifyContributor(object)
	return object:GetRoleInGroup(_G.GroupId) == "Contributors"
end

local function verifyHeadModerator(object)
	local roleInGroup = object:GetRoleInGroup(_G.GroupId)
	return roleInGroup == "Head Moderators" or roleInGroup == "Community Manager"
end

local function verifyModerator(object)
	return object:GetRoleInGroup(_G.GroupId) == "Moderators"
end

local function verifyYoutuber(instance)
	return instance:GetAttribute("Youtuber")
end

local function verifyCustomMoveset(instance)
	return instance:GetAttribute("AllowCustomMoveset")
end

local function verifyTester(object)
	return object:GetRoleInGroup(_G.GroupId) == "Testers" and game.PlaceId == 9164905432
end

local function verifyTesterPublic(object)
	return object:GetRoleInGroup(_G.GroupId) == "Testers"
end

local v = {
	Owner = verifyCreator,
	Developer = verifyDeveloper,
	HeadMod = verifyHeadModerator,
	Mod = verifyModerator,
	Contrib = verifyContributor,
	Tester = verifyTester,
	TesterPublic = verifyTesterPublic,
	Youtuber = verifyYoutuber,
	CustomMoveset = verifyCustomMoveset
}
return function(registry)
	registry:RegisterHook("BeforeRun", function(p)
		local group = p.Group

		if not group then
			return "A group isn't linked to this command!"
		end

		local flag = false

		for _, v3 in group do
			if not v[v3](p.Executor) then
				continue
			end

			flag = true
			break
		end

		if flag then
			return
		else
			return "You don't have permission to run this command"
		end
	end)
end