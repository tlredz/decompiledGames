local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getlibrary()
	v2 = v2 or require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"))
	return v2
end

function v:ProximityPrompt()
	local proximityPrompt = Instance.new("ProximityPrompt")

	if not self.Style then
		self.Style = Enum.ProximityPromptStyle.Custom
	end

	for k, v3 in self do
		local v4 = k
		local v5 = v3
		local success, result = pcall(function()
			proximityPrompt[v4] = v5
		end)

		if not success then
			warn(result)
		end
	end

	return proximityPrompt
end

local module = require("@self/ZoneUtils")
v.GetPlayerZone = module.GetPlayerZone
v.GetZoneName = module.GetZoneName
v.GetZonesAt = module.GetZonesAt
v.GetZoneMeta = module.GetZoneMeta
v.FindNearestIsland = module.FindNearestIsland
v.IsTradePlaza = require("@self/IsTradePlaza")
v.GradientRichText = require("@self/GradientRichText")
local module4 = require("@self/PreloadUtils")
v.PreloadAsync = module4.PreloadAsync
v.PreloadSpawn = module4.PreloadSpawn
Color3.fromRGB(255, 240, 188)
Color3.fromRGB(139, 255, 137)
local v3 = { Color3.fromRGB(124, 255, 101), Color3.fromRGB(93, 179, 255), (Color3.fromRGB(226, 83, 255)) }

function v.ItemDisplay(data, options)
	local v4 = getlibrary() -- equivalent call inferred; original call site unknown
	local module5 = require("../../modules/WitcherPotions")
	local isTradePlaza = v.IsTradePlaza()
	local v5 = {}
	local v6 = options or {}
	local hide_attributes = v6.hide_attributes or {}
	local v7 = hide_attributes == true and {
		"Weight",
		"Shiny",
		"Sparkling",
		"Glitched",
		"Mutation"
	} or hide_attributes

	local function addModifier(p: string, p2, flag: boolean?, flag2: boolean?)
		if not v6.rich then
			table.insert(v5, p)
			return
		end

		if p2 and not v6.disable_color then
			if typeof(p2) == "Color3" then
				p = `<font color='#{p2:ToHex()}'>{p}</font>`
			else
				p = v.GradientRichText(p, p2)
			end
		end

		if flag then
			p = `<b>{p}</b>`
		end

		if flag2 and not v6.disable_italic then
			p = `<i>{p}</i>`
		end

		table.insert(v5, p)
	end

	local sub = data.sub or data
	local name = data.name or data.Name

	if name == "Skin Crate" and sub.Type then
		local type = sub.Type
		local color = v4.skinCrates[sub.Type].Color

		if v6.rich and color and not v6.disable_color then
			if typeof(color) == "Color3" then
				type = `<font color='#{color:ToHex()}'>{type}</font>`
			else
				type = v.GradientRichText(type, color)
			end
		end

		table.insert(v5, type)
	end

	if name == "Cosmetic Egg" and sub.Type then
		local egg = v4.eggs[sub.Type]
		local color = egg and egg.Color or Color3.fromRGB(255, 170, 0)
		local type = sub.Type

		if v6.rich and color and not v6.disable_color then
			if typeof(color) == "Color3" then
				type = `<font color='#{color:ToHex()}'>{type}</font>`
			else
				type = v.GradientRichText(type, color)
			end
		end

		table.insert(v5, type)
	end

	if v6.add_weight and sub.Weight then
		addModifier(string.format("%.1fkg", sub.Weight))
	end

	for _, v8 in v4.attributes.ordered do
		if v8.Type ~= "Independent" or not sub[v8.Name] or table.find(v7, v8.Name) then
			continue
		end

		addModifier(v8.Name, v8.Color, v8.Bold, v8.Italic)
	end

	if sub.Weight and v4.fish[name] and not table.find(v7, "Weight") then
		local weight = sub.Weight
		local weightClass = v.GetWeightClass(name, weight)

		if weightClass then
			local color = v4.attributes.byName[weightClass].Color

			if v6.rich and color and not v6.disable_color then
				if typeof(color) == "Color3" then
					weightClass = `<font color='#{color:ToHex()}'>{weightClass}</font>`
				else
					weightClass = v.GradientRichText(weightClass, color)
				end
			end

			table.insert(v5, weightClass)
		end
	end

	local mutation = v4.mutations[sub.Mutation]

	if mutation and not table.find(v7, "Mutation") then
		local display = mutation.Display or sub.Mutation
		local color = mutation.Color

		if v6.rich and color and not v6.disable_color then
			if typeof(color) == "Color3" then
				display = `<font color='#{color:ToHex()}'>{display}</font>`
			else
				display = v.GradientRichText(display, color)
			end
		end

		table.insert(v5, display)
	end

	if v6.hide_main then
		return `{table.concat(v5, " ")}`, #v5 > 1
	end

	if name == "Friend Fish" and sub.FriendId ~= nil then
		local v8 = sub.FriendIsVerified and "Verified Fish" or "Friend Fish"
		local v9

		if v6.disable_newlines then
			v9 = v8 .. `: {sub.FriendDisplayName}`
		else
			v9 = v8 .. `\n{sub.FriendDisplayName}`
		end

		addModifier(v9, v6.rarity_color and v4.rarities.Rarities.Secret.ColorGradient or nil, v6.bold_main)
	else
		local v8 = nil

		if v6.rarity_color then
			local rarity = v4.fish[name] and v4.fish[name].Rarity or not v4.items[name] and "Common" or v4.items[name].Rarity or "Common"
			v8 = v4.rarities.AnyColors[rarity] or v8
		end

		local v9 = name:gsub("’", "'")

		if name == "Imprinted Relic" and sub.Enchant or name == "Treasure Map" and sub.x and not isTradePlaza or module5.Potions[name] then
			if v6.disable_newlines then
				v9 ..= ":"
			else
				v9 ..= "\n"
			end
		end

		addModifier(v9, v8, v6.bold_main)

		if name == "Imprinted Relic" and typeof(sub.Enchant) == "string" and v4.enchants[sub.Enchant] then
			local enchant = sub.Enchant
			local color = v4.enchants[sub.Enchant].Color

			if v6.rich and color and not v6.disable_color then
				if typeof(color) == "Color3" then
					enchant = `<font color='#{color:ToHex()}'>{enchant}</font>`
				else
					enchant = v.GradientRichText(enchant, color)
				end
			end

			table.insert(v5, enchant)
		elseif name == "Treasure Map" and sub.x and not isTradePlaza then
			if sub.Repaired then
				addModifier(v.GetZoneName((Vector3.new(sub.x, sub.y, sub.z))), Color3.fromRGB(79, 141, 217))
			else
				addModifier("Unrevealed", Color3.fromRGB(143, 143, 143))
			end
		elseif module5.Potions[name] then
			local formatted = `Tier {sub.Tier or 1}`
			local v10 = v3[sub.Tier or 1] or v3[3]

			if v6.rich then
				if v10 and not v6.disable_color then
					if typeof(v10) == "Color3" then
						formatted = `<font color='#{v10:ToHex()}'>{formatted}</font>`
					else
						formatted = v.GradientRichText(formatted, v10)
					end
				end

				table.insert(v5, (`<b>{formatted}</b>`))
			else
				table.insert(v5, formatted)
			end
		end
	end

	return `{table.concat(v5, " ")}`, #v5 > 1
end

function v.GetWeightClass(p: string, p2: number?)
	local v4 = getlibrary() -- equivalent call inferred; original call site unknown

	if p2 and v4.fish[p] then
		local v5 = v4.fish[p].WeightPool[2] / 10
		local v6 = v4.fish[p].WeightPool[1] / 10

		for _, weightClass in v4.attributes.weightClasses do
			if weightClass.WeightRequirement >= 1 and v5 * weightClass.WeightRequirement < p2 or weightClass.WeightRequirement < 1 and p2 < v6 * weightClass.WeightRequirement then
				return weightClass.Name
			end
		end
	end

	return nil
end

function v.CheckWeightClass(p: string, p2: number?, p3: string)
	local v4 = getlibrary() -- equivalent call inferred; original call site unknown

	if not (p2 and v4.fish[p]) then
		return false
	end

	local v5 = v4.attributes.byName[p3]

	if not v5 then
		return false
	end

	local v6 = v4.fish[p].WeightPool[2] / 10
	local v7 = v4.fish[p].WeightPool[1] / 10

	if v5.WeightRequirement >= 1 and v6 * v5.WeightRequirement < p2 then
		return true
	end

	return v5.WeightRequirement < 1 and p2 < v7 * v5.WeightRequirement
end

function v.QuickFishAttributes(list)
	local v4 = getlibrary() -- equivalent call inferred; original call site unknown
	local v5 = table.create(#list)

	for _, v6 in list do
		local v7 = v4.attributes.byName[v6]

		if v7 and typeof(v7.Color) == "Color3" then
			table.insert(v5, (`<font color="#{v7.Color:ToHex()}">{v7.Name}</font>`))
		else
			local mutation = v4.mutations[v6]

			if mutation then
				if typeof(mutation.Color) == "Color3" then
					table.insert(v5, (`<font color="#{mutation.Color:ToHex()}">{mutation.Display}</font>`))
					continue
				end

				if typeof(mutation.Color) == "ColorSequence" then
					table.insert(v5, v.GradientRichText(mutation.Display, mutation.Color))
					continue
				end
			end

			table.insert(v5, v6)
		end
	end

	return table.concat(v5, " ")
end

function v.QuickFishName(p: string, list)
	local v4 = getlibrary() -- equivalent call inferred; original call site unknown
	local v5 = table.create(list and #list > 0 and 2 or 1)

	if list and #list > 0 then
		table.insert(v5, v.QuickFishAttributes(list))
	end

	local v6 = v4.fish[p]
	local v7 = false

	if v6 then
		local rarity = v4.rarities.Rarities[v6.Rarity]

		if rarity then
			if rarity.ColorGradient then
				table.insert(v5, v.GradientRichText(p, rarity.ColorGradient))
				v7 = true
			elseif rarity.Color then
				table.insert(v5, (`<font color="#{rarity.Color:ToHex()}">{p}</font>`))
				v7 = true
			end
		end
	end

	if not v7 then
		table.insert(v5, p)
	end

	return table.concat(v5, " ")
end

function v.GetItemIcon(p: string, p2)
	local v4 = getlibrary() -- equivalent call inferred; original call site unknown

	if v4.fish[p] then
		return v4.fish[p].Icon
	end

	if v4.potions[p] then
		local potion = v4.potions[p]

		if p2 and p2.Tier then
			return potion.ItemIcons[p2.Tier] or potion.ItemIcons[1]
		end

		return potion.ItemIcons[1]
	else
		if p == "Skin Crate" and p2 and p2.Type then
			return v4.skinCrates[p2.Type] and v4.skinCrates[p2.Type].Icon
		end

		if v4.items[p] then
			return v4.items[p].Icon
		end

		if v4.keyItems[p] then
			return v4.keyItems[p].Icon
		end

		return nil
	end
end

function v.FindQuestFish(value, p, player, value2: number?)
	local module5 = require("../../modules/SharedDataHelper")
	local module6 = require("../../modules/fishing")
	local fish = (getlibrary()).fish
	local newFormat = module5.fetchNewFormat(player)

	if not newFormat then
		return {}, 0
	end

	local inventory = newFormat.Inventory
	local v4 = value2 or 1e999
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = typeof(value) == "string" and { value } or value
	local value3 = nil
	local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")

	if tool then
		local link = tool:FindFirstChild("link")

		if link and link:IsA("StringValue") then
			value3 = link.Value
		end
	end

	for k, v9 in inventory do
		if not table.find(v8, v9.name) then
			continue
		end

		if p then
			local v10 = true

			for k2, v12 in p do
				if k2 == "WeightClass" then
					if not v.CheckWeightClass(v9.name, v9.sub.Weight, v12) then
						v10 = false
						break
					end
				elseif k2 == "ShinyOrSparkling" then
					if not (v9.sub.Shiny or v9.sub.Sparkling) then
						v10 = false
						break
					end
				elseif typeof(v12) == "table" then
					if not table.find(v12, v9.sub[k2]) then
						v10 = false
						break
					end
				elseif v9.sub[k2] ~= v12 then
					v10 = false
					break
				end
			end

			if not v10 then
				continue
			end
		end

		if not (v9.sub.Mutation ~= "Aether" or p and p.Mutation == "Aether") then
			continue
		end

		if v9.sub and v9.sub.Favourited then
			v7[k] = true
		end

		table.insert(v5, k)

		if fish[v9.name] then
			v6[k] = module6:SellFish(player, v9, true)
		else
			v6[k] = 0
		end
	end

	table.sort(v5, function(a: string, b: string)
		if value3 == a then
			return true
		end

		if value3 == b then
			return false
		end

		if v7[a] ~= v7[b] then
			return v7[b]
		end

		local v9 = v6[a] or 0
		local v10 = v6[b] or 0

		if v9 ~= v10 then
			return v9 < v10
		end

		local index = table.find(v8, inventory[a].name) or 0
		local index2 = table.find(v8, inventory[b].name) or 0

		if index == index2 then
			return a < b
		end

		return index < index2
	end)
	local total = 0
	local result = {}

	for _, v10 in v5 do
		local v11 = math.min(not inventory[v10].sub and 1 or inventory[v10].sub.Stack or 1, v4 - total)
		result[v10] = v11
		total += v11

		if v4 <= total then
			break
		end
	end

	return result, total
end

local function sentenceJoin(names, value: string)
	local v4 = value or "and"

	if typeof(names) == "string" then
		return names
	end

	local v5 = ""

	for k, v6 in names do
		if k > 1 then
			if #names == 2 then
				v5 ..= ` {v4} `
			elseif k == #names then
				v5 ..= `, {v4} `
			else
				v5 ..= ", "
			end
		end

		v5 ..= v6
	end

	return v5
end

function v.CanPurchase(instance, value: string, value2: string)
	if typeof(value) ~= "string" or typeof(value2) ~= "string" then
		return false, "Unknown or invalid item."
	end

	if instance:GetAttribute("SellingFish") or instance:GetAttribute("Appriasing") or instance:GetAttribute("IsLeaving") or not instance:GetAttribute("SpawnFinished") then
		return false, "You can't do that right now."
	end

	local v4 = getlibrary() -- equivalent call inferred; original call site unknown
	local module5 = require("../../modules/SharedDataHelper")
	local vessels = require(ReplicatedStorage.shared.modules.vessels)
	local Bestiary = require(ReplicatedStorage.shared.modules.Bestiary)
	local v5 = string.lower(value)
	local rods

	if v5 == "rod" then
		rods = v4.rods
	elseif v5 == "item" then
		rods = v4.items
	elseif v5 == "fish" then
		rods = v4.fish
	elseif v5 == "boat" then
		rods = vessels.library
	elseif v5 == "utility" then
		rods = v4.utilities
	elseif v5 == "bait" then
		rods = v4.bait
	elseif v5 == "spear" then
		rods = v4.spears
	elseif v5 == "lantern" then
		rods = v4.lanterns
	elseif v5 == "bobber" then
		rods = v4.bobbers
	elseif v5 == "harpoongun" then
		rods = v4.harpoonGuns
	end

	if rods == nil then
		return false, "Unknown item type."
	end

	local rod = rods[value2]

	if typeof(rod) ~= "table" then
		return false, "Unknown item."
	end

	local price = rod.Price

	if typeof(price) ~= "number" or not math.isfinite(price) or price <= 0 or rod.Unpurchasable or v5 == "fish" and not rod.BuyMult then
		return false, "This item is not for sale."
	end

	local levelRequirement = rod.LevelRequirement

	if levelRequirement and not instance:GetAttribute("BypassProgressionChecks") then
		local v6 = module5.readLegacyPathValue(instance, { "Stats", "realLevel" }) or module5.readLegacyPathValue(
			instance,
			{ "Stats", "level" }
		)

		if not v6 or v6 < levelRequirement then
			return false, (`You must be at least level {levelRequirement} to purchase this.`)
		end
	end

	if v5 == "rod" then
		if module5.indexNewFormat(instance, { "Rods", value2 }) ~= nil then
			return false, "You already own this rod."
		end
	elseif v5 == "spear" then
		if module5.indexNewFormat(instance, { "Spears", value2 }) ~= nil then
			return false, "You already own this spear."
		end
	elseif v5 == "harpoongun" then
		if module5.indexNewFormat(instance, { "HarpoonGuns", "Owned", value2 }) ~= nil then
			return false, "You already own this harpoon gun."
		end
	elseif v5 == "boat" then
		if vessels:Has(instance, value2) then
			return false, "You already own this boat."
		end
	elseif v5 == "lantern" then
		if (module5.readLegacyPathValue(instance, { "Lanterns", value2 }) or 0) > 0 then
			return false, "You already own this lantern."
		end
	elseif v5 == "bobber" then
		if module5.readLegacyPath(instance, { "Stats", "bobber", value2 }) ~= nil then
			return false, "You already own this bobber."
		end
	elseif (v5 == "fish" or v5 == "item") and rod.OnlyBuyOne then
		if RunService:IsServer() then
			local handler = require(game.ServerScriptService.server.player.data.handler)

			if handler:HasItem(instance, value2) then
				return false, "You already own this item."
			end
		else
			local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)

			if DataController.HasItem(value2) then
				return false, "You already own this item."
			end
		end
	end

	local bestiaryRequirement = rod.BestiaryRequirement

	if bestiaryRequirement and not instance:GetAttribute("BypassProgressionChecks") then
		local names = {}
		local requirement = 1e999

		for _, v6 in bestiaryRequirement do
			if #names > 0 and requirement < v6.Requirement then
				continue
			end

			local location = v4.locations[v6.Island]
			local discoveryPercentages, v7, v8 = Bestiary:GetDiscoveryPercentages(instance, v6.Island)
			local v9 = math.min(v7, v8)
			local name = nil

			if v6.RequirementType == "both" then
				if v9 < v6.Requirement then
					name = "<i>Shiny Sparkling</i> " .. location.Name
				end
			elseif v6.RequirementType == "shiny" then
				if v7 < v6.Requirement then
					name = "<i>Shiny</i> " .. location.Name
				end
			elseif v6.RequirementType == "sparkling" then
				if v8 < v6.Requirement then
					name = "<i>Sparkling</i> " .. location.Name
				end
			elseif discoveryPercentages < v6.Requirement then
				name = location.Name
			end

			if not name then
				continue
			end

			if v6.Requirement < requirement then
				table.clear(names)
				requirement = v6.Requirement
			end

			table.insert(names, name)
		end

		if #names > 0 then
			return
				false,
				(`Return with {requirement}% of the {sentenceJoin(names, "and")} bestiar{#names == 1 and "y" or "ies"} discovered.`)
		end
	end

	local requirements = rod.Requirements

	if requirements and not instance:GetAttribute("BypassProgressionChecks") then
		if requirements.GatesOpened and RunService:IsServer() then
			local DoorService = require(game.ServerScriptService.server.legacyServices.DoorService)
			local clientDoorsOpened = DoorService:GetClientDoorsOpened(instance)

			for _, v6 in requirements.GatesOpened do
				if not clientDoorsOpened[v6] then
					return false, "You can't purchase this yet..."
				end
			end
		end

		if requirements.DataValues then
			for _, dataValue in requirements.DataValues do
				if module5.indexNewFormat(instance, dataValue.Path) ~= dataValue.ExpectedValue then
					return false, dataValue.FailMessage or "You can't purchase this yet..."
				end
			end
		end

		if requirements.PlayerAttributes and not instance:GetAttribute("BypassProgressionChecks") then
			for _, playerAttribute in requirements.PlayerAttributes do
				if instance:GetAttribute(playerAttribute.Name) ~= playerAttribute.ExpectedValue then
					return false, playerAttribute.FailMessage or "You can't purchase this yet..."
				end
			end
		end

		if requirements.WorldState then
			for _, v6 in requirements.WorldState do
				local child = ReplicatedStorage.world:FindFirstChild(v6.Name, true)

				if not child or child.Value ~= v6.ExpectedValue then
					return false, v6.FailMessage or "You can't purchase this yet..."
				end
			end
		end

		if requirements.DataInstanceRequiriment and module5.readLegacyPathValue(
			instance,
			requirements.DataInstanceRequiriment[1]
		) ~= requirements.DataInstanceRequiriment[2] then
			return false, requirements.DataInstanceRequiriment[3] or "You can't purchase this yet..."
		end
	end

	local localCurrency = rod.LocalCurrency
	local v6 = (rod and rod.Price) * (not rod and 1 or rod.BuyMult or 1)

	if localCurrency then
		local LocalCurrencies = require(ReplicatedStorage.shared.modules.LocalCurrencies)
		local localCurrency2 = LocalCurrencies[localCurrency]

		if not localCurrency2 then
			return false, "Unknown LocalCurrency"
		end

		local legacyPathValue = module5.readLegacyPathValue(instance, { "LocalCurrencies", localCurrency })

		if not legacyPathValue or legacyPathValue < v6 then
			return false, (`Insufficient {localCurrency2.DisplayName or localCurrency}.`)
		end
	else
		local legacyPathValue = module5.readLegacyPathValue(instance, { "Stats", "coins" })

		if not legacyPathValue or legacyPathValue < v6 then
			return false, "Insufficient funds."
		end
	end

	return true, nil, rod
end

return table.freeze(v)