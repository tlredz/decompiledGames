local PingDatabase = {
	MainFire = { function(instance, _)
			local fuelRemaining = instance:GetAttribute("FuelRemaining") or 0
			local v = math.clamp(math.ceil(fuelRemaining / (instance:GetAttribute("FuelTarget") or 100) * 100), 0, 100)

			if fuelRemaining == 0 then
				return "Camp Fire (out)"
			end

			return "Camp Fire (" .. v .. "%)"
		end },
	ExplodableGate = { "Explodable gate here" },
	HardModeLever = { "Hard Mode lever here" },
	Landmark = { function(instance, _)
			if instance:GetAttribute("Stronghold") then
				local functional = instance:FindFirstChild("Functional")
				local v = (functional and functional:GetAttribute("OpenTime") or 0) - workspace:GetServerTimeNow()

				if v <= 0 then
					return "Stronghold ready"
				end

				local v2 = math.floor(v / 60)
				local v3 = math.floor(v % 60)

				if v2 > 0 then
					return "Stronghold in " .. v2 .. "m " .. v3 .. "s"
				end

				return "Stronghold in " .. v3 .. "s"
			else
				if instance:GetAttribute("HasFrogKey") then
					return "Frog Key here - need fishing rod"
				end

				if not instance:HasTag("HardModeRift") then
					return (instance:GetAttribute("FullLandmarkName") or LandmarkDisplayNames[instance.Name] or instance.Name) .. " here"
				end

				local corruptionLevel = math.floor(instance:GetAttribute("CorruptionLevel") or 0)
				return instance.Name .. " here (" .. corruptionLevel .. "% corruption)"
			end
		end },
	Beehive = { function(instance, _)
			local beehive = instance:FindFirstChild("Beehive")
			local level = beehive and beehive:GetAttribute("Level")

			if level == nil or level <= 0 then
				return "Beehive here"
			end

			local maxHoney = beehive:GetAttribute("MaxHoney") or 0

			if maxHoney <= 0 then
				return "Beehive here"
			end

			return "Beehive (Lv" .. level .. " - " .. math.clamp(
				math.floor((beehive:GetAttribute("Honey") or 0) / maxHoney * 100),
				0,
				100
			) .. "% honey)"
		end },
	BeeBox = { function(instance, _)
			local level = instance:GetAttribute("Level")

			if level == nil then
				return "Bee Box here"
			end

			local honeycombDays = instance:GetAttribute("HoneycombDays") or 0
			local v = honeycombDays .. " days"
			return "Bee Box (Lv" .. level .. ") - honeycomb in " .. (honeycombDays == 1 and "1 day" or v)
		end },
	OilDrill = { function(instance, _)
			local fillPercent = instance:GetAttribute("FillPercent")

			if fillPercent == nil or instance:GetAttribute("Destroyed") then
				return "Oil Drill here"
			end

			return "Oil Drill (" .. math.clamp(math.floor(fillPercent * 100), 0, 100) .. "% to next barrel)"
		end },
	MissingKidPoster = { function(instance, _)
			local kidName = instance:GetAttribute("KidName")
			local kidFullName = instance:GetAttribute("KidFullName")
			local missingKidTracker = instance.Parent:FindFirstChild("MissingKidTracker")
			local child = missingKidTracker and missingKidTracker:FindFirstChild(kidName)

			if not child then
				return
			end

			if child:GetAttribute("Found") then
				return kidFullName .. " (found)"
			end

			return "Need to find " .. kidFullName
		end },
	DeadBody = { function(instance, p, _)
			if instance:GetAttribute("PlayerBody") == p.UserId then
				return "Dead - need revive"
			end

			local playerBody = instance:GetAttribute("PlayerBody")
			local playerByUserId = game.Players:GetPlayerByUserId(playerBody)

			if playerByUserId then
				return playerByUserId.DisplayName .. " dead - on my way"
			end
		end },
	Scrapper = { function(_, _)
			return "Need crafting materials"
		end },
	Item = { function(p, _)
			return p.Name .. " here"
		end },
	["NPC:Pelt Trader"] = { function(instance, p)
			local attribute = instance:GetAttribute("ItemRequested_" .. p.UserId)

			if attribute then
				return "Pelt trader wants " .. attribute
			end

			return "Pelt trader here"
		end },
	NPC = { function(instance, _)
			return (instance:GetAttribute("PingName") or instance.Name) .. " here"
		end },
	Chest = { function(instance, _)
			return (instance:GetAttribute("ChestName") or instance.Name) .. " here"
		end }
}

function GetSunDialTime()
	local secondsLeft = workspace:GetAttribute("SecondsLeft")
	local state = workspace:GetAttribute("State")

	if secondsLeft > 0 then
		local v = math.floor(secondsLeft / 60)
		local v2 = secondsLeft - v * 60
		local v3 = string.format("%01im %02is", v, v2)

		if state == "Day" then
			return "Sundial - night in " .. v3
		end

		return "Sundial - day in " .. v3
	elseif state == "Night" then
		return "Sundial - becoming night"
	else
		return "Sundial - becoming day"
	end
end

PingDatabase["Interface:SunDial"] = { function(_, _)
		return GetSunDialTime()
	end }
PingDatabase.SunDial = { function(_, _)
		return GetSunDialTime()
	end }
PingDatabase["Interface:Ammo"] = { function(_, _, data)
		if data.WeaponName then
			if data.Reloading then
				return data.WeaponName .. " - reloading"
			end

			if data.AmmoLabel then
				return data.WeaponName .. " ammo - " .. data.AmmoLabel
			end
		end
	end }
PingDatabase["Interface:HealthBar"] = { function(_, player, _)
		if player:GetAttribute("DeathTime") or player.Character == nil then
			return "Dead"
		end

		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

		if humanoid then
			return "Health " .. math.ceil(humanoid.Health / humanoid.MaxHealth * 100) .. "%"
		end
	end }
PingDatabase.Ground = { "" }
PingDatabase.CraftingBench = { "Crafting Bench" }
PingDatabase["Interface:HotbarButton"] = { function(_, _, p)
		if not (p and p.HotbarItem) then
			return
		end

		local v = "I have <b>" .. p.HotbarItem.Name .. "</b>"

		if p.BagLabel then
			return v .. " (" .. p.BagLabel .. ")"
		end

		return v
	end }
PingDatabase["Interface:CraftingButton"] = { function(_, _, p)
		if p and p.RecipeFolder then
			return GetCraftingRecipeMessage(p.RecipeFolder)
		end
	end }
PingDatabase["Interface:CraftingPreview"] = PingDatabase["Interface:CraftingButton"]
PingDatabase["Interface:BeekeeperButton"] = { function(_, _, p)
		local shopItem = p and p.ShopItem
		local name = shopItem and shopItem:GetAttribute("Name")

		if not name then
			return
		end

		if (shopItem:GetAttribute("Stock") or 0) <= 0 then
			return name .. " (sold out)"
		end

		return "Want to buy: <b>" .. name .. "</b>"
	end }
PingDatabase["Interface:FairyButton"] = { function(_, instance, p)
		local shopItem = p and p.ShopItem

		if not shopItem then
			return
		end

		local price = shopItem:GetAttribute("Price") or 10
		local v = price - (instance:GetAttribute("Flowers") or 0)

		if v > 0 then
			return "Want to buy: <b>" .. shopItem.Name .. "</b> (" .. price .. " flowers, need " .. v .. " more)"
		end

		return "Want to buy: <b>" .. shopItem.Name .. "</b> (" .. price .. " flowers)"
	end }
PingDatabase["Interface:PollinateButton"] = { "wants to pollinate" }
PingDatabase["Interface:HungerBar"] = { function(_, instance)
		return "Hunger " .. math.ceil(instance:GetAttribute("Hunger") / 2) .. "%"
	end }
PingDatabase["Interface:FlowerAmount"] = { function(_, instance)
		local flowers = instance:GetAttribute("Flowers") or 0

		if flowers == 1 then
			return "I have 1 flower"
		end

		return "I have " .. flowers .. " flowers"
	end }
CraftingMaterials = {
	Scrap = {
		Singular = "Scrap",
		Plural = "Scrap",
		Total = "TotalScrap",
		Price = "ScrapPrice"
	},
	Wood = {
		Singular = "Wood",
		Plural = "Wood",
		Total = "TotalWood",
		Price = "WoodPrice"
	},
	Gem = {
		Singular = "Cultist Gem",
		Plural = "Cultist Gems",
		Total = "TotalGems",
		Price = "GemPrice"
	},
	GreenGem = {
		Singular = "Forest Gem",
		Plural = "Forest Gems",
		Total = "TotalGreenGems",
		Price = "GreenGemPrice"
	}
}
CraftingMaterialOrder = {
	"Wood",
	"Scrap",
	"Gem",
	"GreenGem"
}

function GetCampground()
	local map = workspace:FindFirstChild("Map")
	return map and map:FindFirstChild("Campground")
end

function GetMaterialLabel(p, p2)
	if p2 == 1 then
		return p.Singular
	end

	return p.Plural
end

function GetCraftingRecipeMessage(instance)
	if instance:GetAttribute("SoldOut") then
		return instance.Name .. " (sold out)"
	end

	local v = GetCampground()
	local v2 = {}

	if v then
		for _, v3 in pairs(CraftingMaterialOrder) do
			local craftingMaterial = CraftingMaterials[v3]
			local attribute = instance:GetAttribute(craftingMaterial.Price)

			if attribute and (v:GetAttribute(craftingMaterial.Total) or 0) < attribute then
				table.insert(v2, attribute .. " " .. GetMaterialLabel(craftingMaterial, attribute))
			end
		end
	end

	local v3 = "Want to craft: <b>" .. instance.Name .. "</b>"

	if #v2 > 0 then
		return v3 .. " - needs " .. table.concat(v2, ", ")
	end

	return v3
end

PingDatabase["Interface:CraftingIngredient"] = { function(_, _, p)
		local recipeFolder = p and p.RecipeFolder
		local v = p and CraftingMaterials[p.Material]

		if not (recipeFolder and v) then
			return
		end

		local attribute = recipeFolder:GetAttribute(v.Price) or 0
		local v2 = GetCampground()

		if (not v2 and 0 or v2:GetAttribute(v.Total) or 0) < attribute then
			return recipeFolder.Name .. " - needs " .. attribute .. " " .. GetMaterialLabel(v, attribute)
		end

		return recipeFolder.Name .. " - enough " .. v.Plural
	end }
PingDatabase["Interface:CraftingCraftButton"] = { function(_, _, p)
		if p and p.RecipeFolder then
			return p.RecipeFolder.Name .. " - wants to craft"
		end
	end }
PingDatabase["Interface:CraftingBenchTitle"] = { function(_, _, p)
		if p and p.BenchNumber then
			return "Needs Crafting Bench " .. p.BenchNumber
		end
	end }
PingDatabase["Interface:CraftingMaterial"] = { function(_, _, p)
		local v = p and CraftingMaterials[p.Material]

		if not v then
			return
		end

		local v2 = GetCampground()
		local v3 = not v2 and 0 or v2:GetAttribute(v.Total) or 0
		return v.Plural .. ": " .. v3
	end }
PingDatabase["Interface:ToolSmithButton"] = { function(_, _, p)
		if p and p.ShopItemName then
			if p.Purchased then
				return p.ShopItemName .. " (already bought)"
			end

			return "Want to buy: <b>" .. p.ShopItemName .. "</b>"
		end
	end }
PingDatabase["Interface:WorkshopRecipe"] = { function(_, _, p)
		local recipeFolder = p and p.RecipeFolder
		local recipeName = recipeFolder and recipeFolder:GetAttribute("RecipeName")

		if not recipeName then
			return
		end

		if recipeFolder:GetAttribute("Cooldown") then
			return "Workshop: " .. recipeName .. " (on cooldown)"
		end

		return "Workshop: want to craft <b>" .. recipeName .. "</b>"
	end }
PingDatabase["Interface:TemperatureBar"] = { function(_, instance)
		return "Temperature " .. math.ceil(instance:GetAttribute("Temperature") or 100) .. "%"
	end }
PingDatabase["Interface:BatteryBar"] = { function(_, instance)
		local battery = instance:GetAttribute("Battery")
		local maxBattery = instance:GetAttribute("MaxBattery")

		if battery and maxBattery and maxBattery > 0 then
			return "Battery " .. math.clamp(math.ceil(battery / maxBattery * 100), 0, 100) .. "%"
		end
	end }
PingDatabase["Interface:AlienBar"] = { function(_, instance)
		if instance:GetAttribute("EnergyOverheat") then
			return "Energy - overheating"
		end

		return "Energy " .. math.clamp(math.ceil(instance:GetAttribute("EnergyAmmo") or 100), 0, 100) .. "%"
	end }
PingDatabase["Interface:FlamethrowerBar"] = { function(_, instance)
		return "Flamethrower fuel " .. math.clamp(math.ceil(instance:GetAttribute("FlamethrowerFuel") or 0), 0, 100) .. "%"
	end }
PingDatabase["Interface:LifestealBar"] = { function(_, instance)
		return "Lifesteal " .. math.clamp(math.ceil(instance:GetAttribute("LifestealEnergy") or 0), 0, 100) .. "%"
	end }
PingDatabase["Interface:MeteorBar"] = { function(_, instance)
		return "Shockwave charge " .. math.clamp(math.ceil(instance:GetAttribute("ShockwaveCharge") or 0), 0, 100) .. "%"
	end }
PingDatabase.Trap = { "Trap here" }
PingDatabase.Teleporter = { function(instance, _)
		if instance:GetAttribute("IsCharging") then
			return "Teleporter - needs charging"
		end

		return "Teleporter - charged"
	end }
PingDatabase["Item:Gem of the Forest Fragment"] = { function(instance, _)
		local localPieces = instance:GetAttribute("LocalPieces") or instance:GetAttribute("NumberPieces") or 1

		if localPieces > 1 then
			return "Gem of the Forest Fragment x" .. localPieces .. " here"
		end

		return "Gem of the Forest Fragment here"
	end }
PingDatabase.OwnArmour = { function(_, instance, p)
		local armour = instance:FindFirstChild("Armour")
		local armourSlot = p and p.ArmourSlot
		local names = {}

		if armour then
			for _, child in pairs(armour:GetChildren()) do
				if armourSlot == nil or child:GetAttribute("ArmourSlot") == armourSlot then
					table.insert(names, child.Name)
				end
			end

			if #names == 0 and armourSlot then
				for _, child in pairs(armour:GetChildren()) do
					table.insert(names, child.Name)
				end
			end
		end

		if #names == 0 then
			return "Wearing no armour"
		end

		return "Wearing " .. table.concat(names, " + ")
	end }
PingDatabase.MapIcon = { function(_, _, p)
		if p and p.IconName then
			return (LandmarkDisplayNames[p.IconName] or string.gsub(p.IconName, "(%a)(%d+)$", "%1 %2")) .. " here"
		end
	end }
PingDatabase.VolcanoSacrifice = { function(instance, _)
		local count = 0
		local lanterns = instance:FindFirstChild("Lanterns")

		if lanterns then
			for _, child in pairs(lanterns:GetChildren()) do
				if child:GetAttribute("Done") then
					count += 1
				end
			end
		end

		return "Volcano sacrifices: " .. count .. "/8"
	end }
PingDatabase.OwlNest = { function(p, _)
		local parent = p.Parent
		local feathersPlaced = parent:GetAttribute("FeathersPlaced") or 0
		local v = (parent:GetAttribute("FeathersTotal") or 5) - feathersPlaced

		if parent:GetAttribute("Completed") or v <= 0 then
			return "Owl Nest - all feathers placed"
		end

		if v == 1 then
			return "Owl Nest - needs 1 more feather"
		end

		return "Owl Nest - needs " .. v .. " more feathers"
	end }
PingDatabase.BigCarrot = { "Big Carrot here" }
LandmarkDisplayNames = {
	["Jungle MiniTemple1"] = "Jungle Mini Temple",
	["Jungle MiniTemple2"] = "Jungle Mini Temple",
	["Jungle MiniTemple3"] = "Jungle Mini Temple",
	["Jungle MiniTemple4"] = "Jungle Mini Temple",
	["Cave Entrance1"] = "Cave Entrance",
	["Cave Entrance2"] = "Cave Entrance",
	["Cave Entrance3"] = "Cave Entrance",
	["Cave Entrance4"] = "Cave Entrance",
	["Cave Entrance5"] = "Cave Entrance",
	["Jail Cellar1"] = "Guarded Cave",
	["Jail Cellar2"] = "Guarded Cave",
	["Jail Cellar3"] = "Guarded Cave",
	["Jail Cellar4"] = "Guarded Cave",
	UFOCrash1 = "Crashed Alien Ship",
	UFOCrash2 = "Crashed Alien Ship",
	UFOCrash3 = "Crashed Alien Ship",
	UFOCrash4 = "Crashed Alien Ship",
	["Polar Bear Den1"] = "Polar Bear Den",
	["Polar Bear Den2"] = "Polar Bear Den",
	ToolWorkshop = "Workshop",
	ToolWorkshopMeteorShower = "Workshop",
	FurnitureTrader = "Furniture Trader",
	ToolSmith = "Tool Smith",
	TotemPole = "Totem Pole",
	LightCrystal = "Light Crystal",
	BlessingStatues = "Blessing Statues",
	["Beekeepers House"] = "Beekeeper's House",
	["Kings Palace"] = "Cultist King Palace",
	HappyHalloweenPlot1 = "Halloween Plot",
	HappyHalloweenPlot2 = "Halloween Plot",
	HappyHalloweenPlot3 = "Halloween Plot",
	HappyHalloweenPlot4 = "Halloween Plot",
	HappyHalloweenPlot5 = "Halloween Plot",
	HappyHalloweenPlot6 = "Halloween Plot"
}
return PingDatabase