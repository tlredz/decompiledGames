local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local StatusEffectsService = nil
local AnalyticTrackingService = nil
local RunService = game:GetService("RunService")
local forPlayerSafe

if RunService:IsServer() then
	StatusEffectsService = require(game.ServerScriptService.server.legacyServices.StatusEffectsService)
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayerSafe = legacyPlayerData.forPlayerSafe
	AnalyticTrackingService = require(ServerScriptService.server.legacyServices.AnalyticTrackingService)
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayerSafe = legacyLocalPlayerData.fetch
end

local Net = require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local recipes = require(ReplicatedStorage.shared.modules.library.recipes)
local UnlockFeatureData = require(ReplicatedStorage.shared.modules.SharedPersonalAquarium.SharedData.UnlockFeatureData)
local titles = require(ReplicatedStorage.shared.modules.character.titles)
local marketplace = require(ReplicatedStorage.shared.utils.marketplace)
require(ReplicatedStorage.shared.data.GameSettings)
local AnalyticsLevelGroupings = require(ReplicatedStorage.shared.modules.AnalyticsLevelGroupings)
local RunService2 = game:GetService("RunService")
local v

if RunService2:IsServer() then
	local handler = require(ServerScriptService:WaitForChild("server"):WaitForChild("player"):WaitForChild("data"):WaitForChild("handler"))
	v = handler or nil
else
	v = nil
end

local RunService3 = game:GetService("RunService")
local v2

if RunService3:IsServer() then
	local bobbers = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("fishing"):WaitForChild("bobbers"))
	v2 = bobbers or nil
else
	v2 = nil
end

local RunService4 = game:GetService("RunService")
local LanternService = RunService4:IsServer() and require(ServerScriptService:WaitForChild("server"):WaitForChild("legacyServices"):WaitForChild("LanternService")) or nil
local RunService5 = game:GetService("RunService")
local v3

if RunService5:IsServer() then
	local vessels = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("vessels"))
	v3 = vessels or nil
else
	v3 = nil
end

local modules = ReplicatedStorage.shared.modules
require(modules.Worlds)
local RunService6 = game:GetService("RunService")
local WorldService

if RunService6:IsServer() then
	local ServerScriptService2 = game:GetService("ServerScriptService")
	local legacyServices = ServerScriptService2.server.legacyServices
	WorldService = require(legacyServices.WorldService)
else
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local legacyControllers = ReplicatedStorage2:WaitForChild("client").legacyControllers
	WorldService = require(legacyControllers.WorldController)
end

local currentWorldLevelCap = WorldService:GetCurrentWorldLevelCap()

-- equivalent calls inferred from this helper; original call sites unknown
local function getXpPerLevelMultiplier(value: number)
	if value <= 1000 then
		return 190
	end

	return 2 ^ (math.floor((value - 1001) / 500) + 1) * 190
end

local remoteEvent = Net:RemoteEvent("Level/LevelUp")
local remoteEvent2 = Net:RemoteEvent("Level/Progress")
local Level = {
	LevelRewards = {
		[2] = {
			Title = "Rookie"
		},
		[7] = {
			Title = "Novice Explorer"
		},
		[12] = {
			Title = "Trusted Explorer"
		},
		[25] = {
			Title = "Sea Scout"
		},
		[30] = {
			Text = "You can now speak to Merlin.",
			Satchel = true
		},
		[33] = {
			Title = "Renowned Navigator"
		},
		[40] = {
			Title = "Famous Voyager"
		},
		[50] = {
			Title = "Ocean Hero"
		},
		[60] = {
			Title = "Legendary Explorer"
		},
		[70] = {
			Title = "Grand Pioneer"
		},
		[80] = {
			Title = "Mythical Seeker"
		},
		[90] = {
			Title = "Sea Sovereign"
		},
		[100] = {
			Title = "Eternal Voyager"
		},
		[101] = {
			Text = "now the push begins."
		},
		[300] = {
			Text = "On the right path!"
		},
		[400] = {
			Text = "You are getting there.."
		},
		[450] = {
			Text = "You feel a presence unlike any other.."
		},
		[500] = {
			Text = "An evil presence unlike any other lurks within you..",
			Rod = "No-Life Rod"
		},
		[750] = {
			Text = "You're transcending yourself into something else..."
		},
		[999] = {
			Text = "The power of the Heaven's are nearing..."
		},
		[1000] = {
			Rod = "Seraphic Rod"
		},
		[1001] = {
			Text = "You've surpassed the Heaven's!"
		},
		[1100] = {
			Item = {
				Name = "Elite Glider",
				Count = 1
			}
		},
		[1200] = {
			Bobber = "Chromatic Bobber"
		},
		[1300] = {
			Lantern = "Chromatic Lantern"
		},
		[1400] = {
			Vessel = "Chromatic Titan"
		},
		[1501] = {
			Text = "These levels seem to be getting a lot harder..."
		},
		[1600] = {
			Bobber = "Fisch"
		},
		[1700] = {
			Vessel = "Cardboard Box"
		},
		[1799] = {
			Text = "The power of the stars is arriving."
		},
		[1800] = {
			Item = {
				Name = "Celestial Waders",
				Count = 1
			}
		},
		[1900] = {
			Text = "The void strengthens you.",
			Item = {
				Name = "Voided Glove",
				Count = 1
			}
		},
		[1999] = {
			Text = "You're almost there!"
		}
	},
	Max = currentWorldLevelCap
}
local unlockLevel = UnlockFeatureData.UnlockLevel
local unlockMessage = UnlockFeatureData.UnlockMessage
local levelRewards = Level.LevelRewards
levelRewards[unlockLevel] = levelRewards[unlockLevel] or {}
levelRewards[unlockLevel].Text = unlockMessage
local v4 = {}

for _, analyticsLevelGrouping in AnalyticsLevelGroupings do
	local v5 = analyticsLevelGrouping:split("Level ")[2]
	local v6 = v5 and v5:split("-")

	if not v6 then
		continue
	end

	local v7 = v6[1]:gsub("%D+", "")
	local v8 = v6[2] and v6[2]:gsub("%D+", "")
	local min = tonumber(v7)
	local max = tonumber(v8)

	if min then
		table.insert(v4, {
			Min = min,
			Max = max
		})
	end
end

local function getLevelGroup(value: number)
	for _, v5 in v4 do
		if not v5.Max and v5.Min <= value then
			return (`Level {v5.Min}+`)
		end

		if v5.Min <= value and value <= v5.Max then
			return (`Level {v5.Min}-{v5.Max}`)
		end
	end

	return "Unknown Level"
end

local function grantOneTimeItem(player, name: string, fn, p: string?)
	local RunService7 = game:GetService("RunService")

	if not RunService7:IsServer() then
		return
	end

	local v5 = forPlayerSafe(player)

	if not v5 then
		return
	end

	local stats = v5:FindFirstChild("Stats")

	if not stats then
		return
	end

	local v6 = stats:FindFirstChild(name) or Instance.new("BoolValue")
	v6.Name = name
	v6.Value = v6.Value or false
	v6.Parent = stats

	if not v6.Value then
		fn(player)

		if p then
			ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_thought"):FireClient(player, p)
		end

		v6.Value = true
	end
end

function Level.GetLevel(_, p)
	local v5 = forPlayerSafe(p)

	if not v5 then
		return 0
	end

	local stats = v5:FindFirstChild("Stats")

	if stats and stats:FindFirstChild("realLevel") then
		return stats.realLevel.Value
	end

	return 0
end

function Level:LevelUp(player, p: number, p2: number?, p3: number?)
	local v5 = p2 == nil and 0 or p2
	task.spawn(function()
		local v6 = forPlayerSafe(player)

		if not v6 then
			return
		end

		local stats = v6:FindFirstChild("Stats")

		if not stats then
			return
		end

		local xp = stats.xp
		local realLevel = stats.realLevel
		local xpPerLevelMultiplier = getXpPerLevelMultiplier(realLevel.Value) -- equivalent call inferred; original call site unknown
		local v7 = xp.Value - realLevel.Value * xpPerLevelMultiplier

		if p3 ~= nil and p3 <= 0 then
			v7 *= ReplicatedStorage.world.admin_event.Value == "None" and 0.5 or 0.25
		end

		xp.Value = v7
		realLevel.Value = math.clamp(realLevel.Value + 1, 1, currentWorldLevelCap)
		local levelReward = Level.LevelRewards[realLevel.Value]

		if levelReward then
			if levelReward.Rod then
				fishing:GiveRodItem(player, levelReward.Rod, true)
			end

			if levelReward.Item then
				grantOneTimeItem(player, "Received" .. levelReward.Item.Name:gsub("%s+", ""), function(p4)
					v:GiveItem(p4, levelReward.Item.Name, nil, levelReward.Item.Count or 1)
				end, `You have received the <font color = '#ffffff'><b>{levelReward.Item.Name}</b></font> item!`)
			end

			if levelReward.Bobber then
				grantOneTimeItem(player, "Received" .. levelReward.Bobber:gsub("%s+", ""), function(p4)
					v2:Give(p4, levelReward.Bobber)
				end, `You have received the <font color = '#ffffff'><b>{levelReward.Bobber}</b></font>!`)
			end

			if levelReward.Lantern then
				grantOneTimeItem(player, "Received" .. levelReward.Lantern:gsub("%s+", ""), function(p4)
					LanternService:Give(p4, levelReward.Lantern)
				end, `You have received the <font color = '#ffffff'><b>{levelReward.Lantern}</b></font>!`)
			end

			if levelReward.Vessel then
				grantOneTimeItem(player, "Received" .. levelReward.Vessel:gsub("%s+", ""), function(p4)
					v3:Give(p4, levelReward.Vessel)
				end, `You have received the <font color = '#ffffff'><b>{levelReward.Vessel}</b></font> boat!`)
			end

			if levelReward.Satchel and not (player.Backpack:FindFirstChild("Companion Satchel") or player.Character and player.Character:FindFirstChild("Companion Satchel")) then
				local clone = ReplicatedStorage:FindFirstChild("resources"):FindFirstChild("items"):FindFirstChild("equipment"):FindFirstChild("Companion Satchel"):FindFirstChild("Companion Satchel"):Clone()
				clone:SetAttribute("ForceHotbar", true)
				clone.Parent = player.Backpack
				ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_thought"):FireClient(
					player,
					"You unlocked the <font color='#ffffff'><b>Companion Satchel</b></font>!"
				)
			end
		end

		AnalyticTrackingService:SetCustomDimension(player, "Level", (getLevelGroup(realLevel.Value)))

		for _, recipe in recipes do
			if not (recipe.Level ~= nil and tonumber(recipe.Level) and realLevel.Value >= tonumber(recipe.Level)) then
				continue
			end

			ReplicatedStorage:WaitForChild("events"):WaitForChild("giverecipe"):Fire(player, recipe.Name)
		end

		local xpPerLevelMultiplier2 = getXpPerLevelMultiplier(realLevel.Value) -- equivalent call inferred; original call site unknown

		if xp.Value >= realLevel.Value * xpPerLevelMultiplier2 and realLevel.Value < currentWorldLevelCap then
			task.wait()
			local v12

			if p3 then
				v12 = p3 - 1
			end

			Level:LevelUp(player, p, nil, v12)
		else
			remoteEvent:FireClient(player, v5, p)
			task.delay(0.7, function()
				local humanoidRootPart

				if player.Character then
					humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
				end

				if humanoidRootPart then
					local clone = ReplicatedStorage.resources.replicated.fx.lvlup:Clone()
					clone.Enabled = false
					clone.Parent = humanoidRootPart
					clone:Emit(math.random(30, 56))
					Debris:AddItem(clone, 4)
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.player.levelup, humanoidRootPart, false)
				end

				for k, levelReward2 in Level.LevelRewards do
					if p < k and k <= realLevel.Value and levelReward2.Title then
						titles:Give(player, levelReward2.Title)
					end
				end
			end)
		end
	end)
end

function Level:GetFinalXP(instance, p: number, flag: boolean?)
	local v5 = 0
	pcall(function()
		if marketplace.userHasGamepassAsync(instance, 837360470) then
			v5 = p
		end
	end)

	if flag then
		return p + v5
	end

	p *= ReplicatedStorage.world.multiple_XP.Value

	for _, v6 in StatusEffectsService:GetEffectsOfType(instance, "XpMultiply") do
		p *= v6.Data.BoostValue
	end

	if ReplicatedStorage.world.xp_Server.Value > 0 then
		p *= ReplicatedStorage.world.xp_Server.Value
	end

	local friendsInServer = instance:GetAttribute("friendsInServer") or 0

	if friendsInServer > 0 then
		p *= math.clamp(0.05 * friendsInServer, 0, 0.5) + 1
	end

	return p + v5
end

function Level.GiveXP(_, player, p: number, flag: boolean?, flag2: boolean?)
	local v5 = forPlayerSafe(player)

	if not v5 then
		return
	end

	local stats = v5:FindFirstChild("Stats")

	if not stats then
		return
	end

	local value = stats.xp.Value
	local humanoidRootPart

	if player.Character then
		humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart then
		fx:EmitParticles(
			ReplicatedStorage.resources.replicated.fx.xpGain,
			humanoidRootPart,
			(math.clamp(p / 10, 4, 70))
		)
	end

	local finalXP = Level:GetFinalXP(player, p, flag2)
	stats.xp.Value += finalXP
	local xpPerLevelMultiplier = getXpPerLevelMultiplier(stats.level.Value) -- equivalent call inferred; original call site unknown

	if stats.xp.Value >= stats.realLevel.Value * xpPerLevelMultiplier and stats.level.Value < currentWorldLevelCap then
		Level:LevelUp(player, stats.realLevel.Value, value, not flag and 1 or nil)
		return finalXP
	end

	remoteEvent2:FireClient(player, finalXP, value)
	return finalXP
end

return Level