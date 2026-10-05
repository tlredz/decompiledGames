local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = {}

local function serverModule(childName: string)
	local v3 = v2[childName]

	if v3 ~= nil then
		return v3
	end

	local game2 = ServerScriptService.Game
	v3 = require3(game2.Server:FindFirstChild(childName) or game2.Services:FindFirstChild(childName))
	v2[childName] = v3
	return v3
end

local v3 = {
	Credits = {
		label = "Credits",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddCredits(p, p2)
		end,
		set = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:SetCredits(p, p2)
		end
	},
	Wins = {
		label = "Wins",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddWins(p, p2)
		end,
		set = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:SetWins(p, p2)
		end
	},
	Rolls = {
		label = "Rolls",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddRolls(p, p2)
		end,
		set = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:SetRolls(p, p2)
		end
	},
	Kills = {
		label = "Kills",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddKills(p, nil, p2)
		end,
		set = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:SetKills(p, p2)
		end
	},
	SafeKills = {
		label = "safe Kills",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddKills(p, nil, p2, nil, nil, true)
		end,
		permission = "Developer",
		testGameOnly = true
	},
	Crowns = {
		label = "Crowns",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddCrowns(p, p2)
		end
	},
	OctoCoins = {
		label = "Octo Coins",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddOctoCoins(p, p2)
		end
	},
	Starfish = {
		label = "Starfish",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddStarfish(p, p2)
		end,
		permission = "Developer"
	},
	DungeonRunes = {
		label = "Dungeon Runes",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddDungeonRunes(p, p2)
		end
	},
	ChristmasSwordKeys = {
		label = "Christmas Sword Keys",
		add = function(p, p2)
			local awardService = v2.AwardService

			if awardService == nil then
				local game2 = ServerScriptService.Game
				local awardService2 = game2.Server:FindFirstChild("AwardService") or game2.Services:FindFirstChild("AwardService")
				awardService = require3(awardService2)
				v2.AwardService = awardService
			end

			awardService:AddChristmasSwordKeys(p, p2)
		end
	},
	ActivityPoints = {
		label = "Activity Points",
		add = function(p, p2)
			local clansActivityService = v2.ClansActivityService

			if clansActivityService == nil then
				local game2 = ServerScriptService.Game
				local clansActivityService2 = game2.Server:FindFirstChild("ClansActivityService") or game2.Services:FindFirstChild("ClansActivityService")
				clansActivityService = require3(clansActivityService2)
				v2.ClansActivityService = clansActivityService
			end

			clansActivityService:GiveActivityPoints(p, p2)
		end
	},
	TeamworkChest = {
		label = "Teamwork Chests",
		add = function(p, p2)
			local clanCrateService = v2.ClanCrateService

			if clanCrateService == nil then
				local game2 = ServerScriptService.Game
				local clanCrateService2 = game2.Server:FindFirstChild("ClanCrateService") or game2.Services:FindFirstChild("ClanCrateService")
				clanCrateService = require3(clanCrateService2)
				v2.ClanCrateService = clanCrateService
			end

			clanCrateService:OnPurchaseClanCrate(p, p2, true)
		end
	}
}
local names = {}
local settableNames = {}

for k, v6 in v3 do
	table.insert(names, k)

	if v6.set then
		table.insert(settableNames, k)
	end
end

table.sort(names)
table.sort(settableNames)
local ResourceTypes = {}
ResourceTypes.Names = names
ResourceTypes.SettableNames = settableNames

function ResourceTypes.label(p: string)
	local v6 = v3[p]

	if v6 then
		return v6.label
	end

	return p
end

function ResourceTypes.canSet(p: string)
	local v6 = v3[p]
	return v6 ~= nil and v6.set ~= nil
end

function ResourceTypes.canUse(p, p2: string)
	local v6 = v3[p2]

	if not v6 then
		return false, (`Unknown resource "{p2}"`)
	end

	if v6.testGameOnly and not v.isTestGame() then
		return false, (`{v6.label} can only be granted on the test server`)
	end

	local permission = v6.permission

	if not permission then
		return true
	end

	local operatorRoles = v2.OperatorRoles

	if operatorRoles == nil then
		local game2 = ServerScriptService.Game
		local operatorRoles2 = game2.Server:FindFirstChild("OperatorRoles") or game2.Services:FindFirstChild("OperatorRoles")
		operatorRoles = require3(operatorRoles2)
		v2.OperatorRoles = operatorRoles
	end

	local permissions = operatorRoles:GetPermissions(p) or {}

	if not table.find(permissions, permission) then
		return false, (`{v6.label} requires the {permission} permission`)
	end

	return true
end

function ResourceTypes.apply(p: string, p2: string, items, p3: number)
	local v6 = v3[p]
	local set

	if p2 == "set" then
		set = v6.set
	else
		set = v6.add
	end

	local v7 = {}
	local v8 = {}

	for _, item in items do
		local v9

		if pcall(set, item, p3) then
			v9 = v7
		else
			v9 = v8
		end

		table.insert(v9, item.Name)
	end

	return v7, v8
end

return ResourceTypes