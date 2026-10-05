local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyServices = ServerScriptService.server.legacyServices
require(legacyServices.DataService)
local utils = ServerScriptService.server.utils
local getItemFromLink = require(utils.getItemFromLink)
local PlayerService = require(ServerScriptService.server.legacyServices.PlayerService)
local handler = require(ServerScriptService.server.player.data.handler)
local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local modules = ReplicatedStorage.shared.modules
local vessels = require(modules.vessels)
local titles = require(modules.character.titles)
local library = modules.library
local bait = require(library.bait)
local rods = require(library.rods)
local items = require(library.items)
local accessorydata = require(library.items.accessorydata)
local RodSkins = require(modules.RodSkins)
local packages = ReplicatedStorage.packages
require(packages.Net)
local module = require("./Shared")
local _ = ReplicatedStorage.events.anno_top
local anno_thought = ReplicatedStorage.events.anno_thought
local _ = ReplicatedStorage.events.chat
local v = {
	AuditTool = function(player, p, items2, flag: boolean?)
		local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
		local v2 = false
		local clone = nil
		local v3 = not p and "none" or type(p) == "table" and p or { p }
		local name = tool and tool.Name
		local v4 = nil

		if v3 == "none" then
			return tool and getItemFromLink(tool) or false
		end

		if tool and table.find(v3, name) then
			v4 = getItemFromLink(tool)

			if v4 then
				clone = table.clone(v4.sub)
				clone.Stack = nil

				for k, item in items2 do
					if k ~= "Name" and clone[k] ~= item then
						return false
					end
				end

				v2 = true
			end
		end

		if not v2 then
			return false
		end

		if flag then
			clone.Stack = nil
			handler:RemoveItem(player, name, clone, 1)
		end

		return flag or v4
	end,
	Item = function(player, p: string, p2: number)
		assert(player and p and p2)
		handler:GiveItem(player, p, nil, p2)
		anno_thought:FireClient(player, (`Received <b>{p2} {p}</b>`))
	end,
	Title = function(p, p2)
		assert(p and p2)
		titles:Give(p, p2)
	end,
	Bait = function(p, p2, p3)
		assert(p and p2 and p3)
		bait:Give(p, p2, p3)
	end,
	Boat = function(p, p2)
		assert(p and p2)
		vessels:Give(p, p2)
	end,
	TeleportPlayer = require("@self/TeleportPlayerServer"),
	RemoveRod = function(p, p2: string, value: string?)
		if p2 == "" then
			return false, nil
		end

		local v2, v3 = legacyPlayerData.forPlayerSafe(p)

		if not v2 then
			return false, nil
		end

		local rods2 = v3 and v3.Data.NewFormat.Rods
		local stats = v2:FindFirstChild("Stats")

		if not (v3 and rods2 and stats) then
			return false, nil
		end

		local rod = stats:FindFirstChild("rod")
		local rod2 = rods2[p2]

		if not rod2 then
			return false, nil
		end

		local _ = rod2.secondaryEnchant
		local _ = rod2.skin
		local v4 = {
			Enchant = rod2.enchant,
			SecondaryEnchant = rod2.secondaryEnchant,
			Skin = rod2.skin,
			Caught = rod2.caught,
			Favorited = rod2.favorited,
			RemovedAt = workspace:GetServerTimeNow()
		}
		local v5 = value or "Flimsy Rod"
		local v6

		if rod == nil then
			v6 = false
		else
			v6 = rod.Value == p2
		end

		if v6 and rod then
			rod.Value = v5
			fishing:ReloadRod(p, false, true)
		end

		rods2[p2] = nil
		v3.Data.NewFormat.RemovedRodData[p2] = v4
		PlayerService.OnRodRemoved:Fire(p, p2)
		return true, v4
	end
}
local v2 = nil

function v.CheckDevItems(p)
	local FishingRodService = require(ServerScriptService.server.legacyServices.FishingRodService)
	local AccessoryService = require(ServerScriptService.server.legacyServices.AccessoryService)
	local rod = FishingRodService:GetRod(p)

	if rod then
		local rod2 = rods[rod.Name]

		if not rod2 or rod2.DEV then
			return true, "rod", rod.Name
		end

		if rod.Skin and rod.Skin ~= "Default" then
			local skin = RodSkins.Skins[rod.Skin]

			if skin and skin.DEV then
				return true, "skin", rod.Skin
			end
		end
	end

	if v2 == nil then
		v2 = {}

		for k, _ in accessorydata do
			local item = items.Items[k]

			if item and item.DEV then
				table.insert(v2, k)
			end
		end
	end

	for _, v3 in v2 do
		if AccessoryService.IsEquipped(p, v3) then
			return true, "accessory", v3
		end
	end

	return false, nil, nil
end

function v.CanPurchase(instance, value: string, p: string)
	local canPurchase, v3, v4 = module.CanPurchase(instance, value, p)

	if not canPurchase then
		return canPurchase, v3, v4
	end

	if value:lower() == "rod" and p == "Brick Rod" and not _G.CheckBrickRod(instance, true) then
		return false, "You are unworthy.", v4
	end

	local isPlayerBusy = require(ServerScriptService.server.utils.isPlayerBusy)

	if isPlayerBusy.isPlayerBusy(instance) then
		return false, "You can't do that right now."
	end

	local crewRatingRequirement = v4.CrewRatingRequirement

	if crewRatingRequirement and not instance:GetAttribute("BypassProgressionChecks") then
		local CrewService = require(legacyServices.CrewService)
		local membershipInfo = CrewService:GetMembershipInfo(instance)

		if not membershipInfo or membershipInfo.CrewSeasonRating < crewRatingRequirement then
			local module3 = require("../NumberUtils")
			return
				false,
				`You must be in a Crew with at least <b>{module3:Comma(crewRatingRequirement)} Rating</b> to purchase this.`,
				v4
		end
	end

	return true, nil, v4
end

v.ProximityPrompt = module.ProximityPrompt
v.IsTradePlaza = module.IsTradePlaza
v.GetPlayerZone = module.GetPlayerZone
v.GetZoneName = module.GetZoneName
v.GetZonesAt = module.GetZonesAt
v.GetZoneMeta = module.GetZoneMeta
v.ItemDisplay = module.ItemDisplay
v.GradientRichText = module.GradientRichText
v.GetWeightClass = module.GetWeightClass
v.CheckWeightClass = module.CheckWeightClass
v.QuickFishAttributes = module.QuickFishAttributes
v.QuickFishName = module.QuickFishName
v.FindQuestFish = module.FindQuestFish
v.GetItemIcon = module.GetItemIcon
v.PreloadAsync = module.PreloadAsync
v.PreloadSpawn = module.PreloadSpawn
return table.freeze(v)