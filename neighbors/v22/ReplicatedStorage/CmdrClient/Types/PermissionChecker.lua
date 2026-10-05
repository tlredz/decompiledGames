local v = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local FeatureFlags = require(game.ReplicatedStorage.Modules.FeatureFlags)
local Server = require(game.ReplicatedStorage.Modules.Server)
local isTestServer = Server:IsTestServer()
local v2 = {
	Manager = 250,
	CommunityManager = 240,
	StudioDeveloper = 200,
	Developer = 175,
	Administrator = 125,
	SeniorModerator = 105,
	Moderator = 100,
	ContentManager = 76,
	Influencer = 75,
	Contractor = 65,
	QALead = 55,
	VIP = 50,
	Helper = 35,
	ActiveTester = 30,
	Tester = 25,
	DefaultUtil = 3,
	DefaultDebug = 2,
	Help = 0
}
local v3 = {
	[689602534] = {
		"gear",
		"smite",
		"fling",
		"forcequeue",
		"unfreeze",
		"freeze",
		"sit",
		"light",
		"speed",
		"hat",
		"sparkles",
		"unsparkles",
		"smoke",
		"unsmoke",
		"fire",
		"jump",
		"visible",
		"smallhead",
		"name",
		"invisible",
		"followplayer",
		"normalhead",
		"splatter",
		"bighead",
		"unfire",
		"devprotect"
	},
	[41372847] = {
		"unfreeze",
		"freeze",
		"sit",
		"light",
		"speed",
		"hat",
		"sparkles",
		"unsparkles",
		"smoke",
		"unsmoke",
		"fire",
		"unfire",
		"jump",
		"visible",
		"smallhead",
		"name",
		"invisible",
		"normalhead",
		"splatter",
		"bighead"
	},
	[1551878098] = {
		"unfreeze",
		"freeze",
		"sit",
		"light",
		"speed",
		"hat",
		"sparkles",
		"unsparkles",
		"smoke",
		"unsmoke",
		"fire",
		"unfire",
		"jump",
		"visible",
		"smallhead",
		"name",
		"invisible",
		"normalhead",
		"splatter",
		"bighead",
		"devprotect",
		"splatter",
		"esp",
		"followplayer"
	},
	QALead = { "forcequeue" },
	Testers = {
		"awardtool",
		"awardskin",
		"awardtitle",
		"removeskin",
		"removetool",
		"partybring",
		"partyjoin",
		"awardtitle",
		"partyassignleader",
		"gift"
	},
	ActiveTesters = {
		"awardtool",
		"awardskin",
		"awardtitle",
		"removeskin",
		"removetool"
	},
	Contractors = {
		"gear",
		"fling",
		"forcequeue",
		"unfreeze",
		"freeze",
		"sit",
		"light",
		"speed",
		"hat",
		"sparkles",
		"unsparkles",
		"smoke",
		"unsmoke",
		"fire",
		"jump",
		"visible",
		"smallhead",
		"name",
		"invisible",
		"followplayer",
		"normalhead",
		"splatter",
		"bighead",
		"unfire",
		"devprotect"
	},
	Helper = {
		"warn",
		"unwarn",
		"warns",
		"clearbio",
		"viewprofile",
		"viewComments",
		"removeComment",
		"esp",
		"forcequeue"
	}
}
Players.PlayerRemoving:Connect(function(player)
	if v[player.UserId] then
		v[player.UserId] = nil
	end
end)
return function(registry)
	registry:RegisterHook("BeforeRun", function(data)
		if RunService:IsStudio() or v3[data.Executor.UserId] and table.find(v3[data.Executor.UserId], data.Name) then
			return
		end

		local v4 = v[data.Executor.UserId] or data.Executor:GetRankInGroup(15109848)
		local executor = data.Executor
		local success, roleInGroup = pcall(executor.GetRoleInGroup, executor, 15109848)

		if success and roleInGroup == "Community Manager" then
			v4 = math.max(v4 or 0, 240)
		end

		if RunService:IsServer() then
			local child = game.ServerStorage.Stats:FindFirstChild(data.Executor.Name)

			if child and child.ForcedAdmin.Value then
				v4 = math.max(v4 or 0, 250)
			end
		elseif executor:GetAttribute("ForcedAdmin") then
			v4 = math.max(v4 or 0, 250)
		end

		if FeatureFlags:IsEnabled("FFlagTestAllowTestersAllCommands") and isTestServer then
			v4 = math.max(v4 or 0, 150)
		end

		v[data.Executor.UserId] = v4

		if v4 == 65 and table.find(v3.Contractors, data.Name) or v4 == 35 and table.find(v3.Helper, data.Name) then
			return
		end

		if isTestServer and v4 > 29 and table.find(v3.ActiveTesters, data.Name) or isTestServer and table.find(
			v3.Testers,
			data.Name
		) then
			return
		end

		local v5 = v2[data.Group] or 250
		local v6 = {}

		for _, v7 in registry:GetCommand(data.Name).Blacklist or {} do
			table.insert(v6, v2[v7])
		end

		if v4 < v5 or table.find(v6, v4) then
			return "You do not have permission to run this command."
		end
	end)
end