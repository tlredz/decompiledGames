local insert = table.insert
local CharacterInfoProvider = {
	BossInfo = {}
}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isClient = RunService:IsClient()
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local AiMimic = require(ReplicatedStorage.CAM.AiStuffGlobal.AiMimic)
local localPlayer = game.Players.LocalPlayer
local v = {
	run = "walk"
}

function CharacterInfoProvider.Get_equipped_tool(instance)
	if instance == nil then
		return
	end

	if instance.Parent ~= game.Players then
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter == nil then
			local equippedTool = AiMimic:Get(instance, "Equipped_Tool")

			if equippedTool then
				return {
					Name = equippedTool
				}
			else
				return
			end
		else
			instance = playerFromCharacter
		end
	end

	local items_Config = instance:FindFirstChild("Items_Config") or instance:FindFirstChild("Items_ConfigServer")

	if items_Config and items_Config:FindFirstChild("Equipped") ~= nil then
		return CharacterInfoProvider.getEquippedItems(instance, items_Config.Equipped.Value)
	end
end

local function accountBag(instance)
	local accountItems

	if instance ~= nil then
		accountItems = instance:FindFirstChild("AccountItems")
	end

	if accountItems == nil then
		return nil
	end

	return (accountItems:FindFirstChild("Inventory"))
end

local function findById(data, instance, p: number)
	local inventory = data:FindFirstChild("Inventory")
	local inventory2

	if p < 0 then
		local accountItems

		if instance ~= nil then
			accountItems = instance:FindFirstChild("AccountItems")
		end

		if accountItems ~= nil then
			inventory2 = accountItems:FindFirstChild("Inventory")
		end
	elseif inventory ~= nil then
		inventory2 = inventory:FindFirstChild("Inventory")
	end

	if inventory2 == nil then
		return
	end

	for _, child in pairs(inventory2:GetChildren()) do
		if child.Id.Value == p then
			return child
		end
	end
end

function CharacterInfoProvider.GetItemBag(p, p2: string)
	return Utility.ItemBag(Utility.GetData(p, false), p2)
end

function CharacterInfoProvider.GetItemBags(p)
	return Utility.ItemBags(Utility.GetData(p, false))
end

function CharacterInfoProvider.GetItemNameOnSlot(p: string, p2: string)
	if p == nil or p2 == nil then
		return ""
	end

	local data, v2 = Utility.GetData(p, nil, true)

	if data ~= nil and data:FindFirstChild("Inventory") and data.Inventory:FindFirstChild("Inventory") then
		local v3 = findById(data, v2, data.Inventory.Toolbar[p2].Value)

		if v3 ~= nil then
			return v3.Name
		end
	end

	return ""
end

function CharacterInfoProvider.GetItemOnSlot(p: string, p2: string)
	if p or p2 == nil then
		return nil
	end

	local data, v2 = Utility.GetData(p, nil, true)

	if data == nil or not (data:FindFirstChild("Inventory") and data.Inventory:FindFirstChild("Inventory")) then
		return
	else
		return findById(data, v2, data.Inventory.Toolbar[p2].Value)
	end
end

function CharacterInfoProvider.GetEquippedPowers(p)
	if p ~= nil then
		local data = Utility.GetData(p)

		if data ~= nil then
			local value = data.Race.Value
			local value2 = data.Powers.Breathing.Value
			local value3 = data.Powers.DemonArt.Value
			local v2 = {}

			if value == "Hybrid" then
				table.insert(v2, value2)
				table.insert(v2, value3)
			elseif value == "Demon" then
				table.insert(v2, value3)
			else
				table.insert(v2, value2)
			end

			return v2
		end
	end

	return {}
end

function CharacterInfoProvider.HasPowerAccess(p, p2: string)
	if p == nil or p2 == nil then
		return false
	end

	local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
	local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
	local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
	local v2 = Breathings[p2] ~= nil
	local v3 = DemonArts[p2] ~= nil
	local fightingStyle = FightingStyles[p2]

	if not v2 and not v3 and fightingStyle == nil then
		return true
	end

	local data = Utility.GetData(p)

	if data == nil then
		return false
	end

	if fightingStyle ~= nil then
		local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
		return ItemRequirements.Passes(data, fightingStyle.Requirements)
	end

	local value = data.Race.Value

	if value == "Hybrid" then
		return true
	elseif value == "Demon" then
		return v3
	end

	return v2
end

function CharacterInfoProvider.IsSkillAvailable(p, childName: string)
	if p == nil or childName == nil then
		return false
	end

	local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
	local skillInfo = Stats.GetSkillInfo(childName)

	if skillInfo == nil or skillInfo.Category ~= nil and not CharacterInfoProvider.HasPowerAccess(p, skillInfo.Category) then
		return false
	end

	local data = Utility.GetData(p)

	if data == nil then
		return false
	end

	if skillInfo.CategoryType == "Weapon" and skillInfo.Category ~= nil then
		local v2 = false

		for _, v3 in CharacterInfoProvider.GetItemBags(p) do
			for _, child in v3:GetChildren() do
				local item = Items[child.Name]

				if not (item ~= nil and (item.SkillCategory or child.Name) == skillInfo.Category) then
					continue
				end

				v2 = true
				break
			end
		end

		if not v2 then
			return false
		end
	end

	if skillInfo.CategoryType == "Fighting Style" and skillInfo.Category ~= nil then
		local powers = data:FindFirstChild("Powers")
		local fightingStyle

		if powers ~= nil then
			fightingStyle = powers:FindFirstChild("FightingStyle") or nil
		end

		if fightingStyle == nil or fightingStyle.Value ~= skillInfo.Category then
			return false
		end
	end

	local skillTreeUnlockedList = data:FindFirstChild("SkillTreeUnlockedList")

	if skillTreeUnlockedList == nil then
		return false
	end

	local category = skillInfo.Category or childName
	local index = skillInfo.Index or 1

	if skillInfo.Index == nil or skillInfo.Category == nil then
		if skillTreeUnlockedList:FindFirstChild(childName) == nil then
			return data.MetRequirements.Boss:FindFirstChild(childName) == nil
		end

		return false
	else
		local child = skillTreeUnlockedList:FindFirstChild(category)
		local value = child and child.Value or 0

		if index <= value and skillInfo.Boss == nil or data.MetRequirements.Boss:FindFirstChild(childName) ~= nil then
			return false
		end

		if index <= 1 then
			return true
		end

		if value < index - 1 then
			return false
		end

		local _, v2 = Stats.GetRequirementsAt(p, category, index - 1)
		return select(2, Stats.GetRequirements(p, v2)) == true
	end
end

function CharacterInfoProvider.GetSkillDimReason(p, childName: string)
	if p == nil or childName == nil then
		return nil
	end

	local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
	local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
	local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
	local skillInfo = Stats.GetSkillInfo(childName)

	if skillInfo == nil then
		return nil
	end

	local data = Utility.GetData(p)

	if data == nil then
		return nil
	end

	local skillTreeUnlockedList = data:FindFirstChild("SkillTreeUnlockedList")
	local category = skillInfo.Category or childName
	local index = skillInfo.Index or 1

	if skillTreeUnlockedList and skillInfo.Index ~= nil and skillInfo.Category ~= nil then
		local child = skillTreeUnlockedList:FindFirstChild(category)

		if index <= (child and child.Value or 0) and (skillInfo.Boss == nil or data.MetRequirements.Boss:FindFirstChild(childName) ~= nil) then
			return nil
		end
	end

	if data.MetRequirements.Boss:FindFirstChild(childName) ~= nil then
		return "Already Have"
	end

	if skillInfo.Category ~= nil then
		local v2 = Breathings[skillInfo.Category] ~= nil
		local v3 = DemonArts[skillInfo.Category] ~= nil

		if v2 or v3 then
			if CharacterInfoProvider.HasPowerAccess(p, skillInfo.Category) then
				local powers = data:FindFirstChild("Powers")

				if powers then
					if v2 and powers.Breathing.Value ~= skillInfo.Category or v3 and powers.DemonArt.Value ~= skillInfo.Category then
						return "Missing " .. skillInfo.Category
					end
				end
			elseif v3 then
				return "Must be Demon"
			else
				return "Must be Slayer"
			end
		end

		local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
		local fightingStyle = FightingStyles[skillInfo.Category]

		if fightingStyle ~= nil then
			if CharacterInfoProvider.HasPowerAccess(p, skillInfo.Category) then
				local powers = data:FindFirstChild("Powers")
				local fightingStyle2

				if powers ~= nil then
					fightingStyle2 = powers:FindFirstChild("FightingStyle") or nil
				end

				if fightingStyle2 == nil or fightingStyle2.Value ~= skillInfo.Category then
					return "Missing " .. skillInfo.Category
				end
			else
				local race = fightingStyle.Requirements ~= nil and fightingStyle.Requirements.Race or nil

				if typeof(race) == "table" then
					race = race[1]
				end

				return "Must be " .. tostring(race)
			end
		end
	end

	if skillInfo.CategoryType == "Weapon" and skillInfo.Category ~= nil then
		local v2 = false

		for _, v3 in CharacterInfoProvider.GetItemBags(p) do
			for _, child in v3:GetChildren() do
				local item = Items[child.Name]

				if not (item ~= nil and (item.SkillCategory or child.Name) == skillInfo.Category) then
					continue
				end

				v2 = true
				break
			end
		end

		if not v2 then
			return "Missing " .. skillInfo.Category
		end
	end

	if not skillTreeUnlockedList then
		return nil
	end

	if skillInfo.Index == nil or skillInfo.Category == nil then
		if skillTreeUnlockedList:FindFirstChild(childName) == nil then
			return "Unlock Previous"
		end
	else
		local child = skillTreeUnlockedList:FindFirstChild(category)
		local value = child and child.Value or 0

		if index > 1 then
			local _, v2 = Stats.GetRequirementsAt(p, category, index - 1)

			if value < index - 1 or not select(2, Stats.GetRequirements(p, v2)) then
				return "Unlock Previous"
			end
		end
	end

	return nil
end

function CharacterInfoProvider.HasUnlockedSkills(p, items)
	local result = {}

	if p == nil or items == nil then
		return false, result
	end

	local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)

	for _, item in items do
		if typeof(item) ~= "string" or Stats.IsSkillUnlocked(p, item) then
			continue
		end

		table.insert(result, item)
	end

	return #result == 0, result
end

function CharacterInfoProvider.GetItemFromId(p, p2: number)
	if p == nil or p2 == nil then
		return
	end

	local v2 = tonumber(p2)

	if v2 == nil then
		return
	end

	local data, v3 = Utility.GetData(p, false)

	if data == nil then
		return
	else
		return findById(data, v3, v2)
	end
end

local v2 = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five"
}

function CharacterInfoProvider.getEquippedAccessoryVanity(p, childName)
	if p == nil then
		return {}
	end

	local data = Utility.GetData(p, false)

	if data == nil then
		return {}
	end

	if childName == nil then
		local v3 = {}

		for _, child in pairs(data.Inventory.Accessories.Vanity:GetChildren()) do
			local value = child.Value

			if value == 0 then
				continue
			end

			local item = CharacterInfoProvider.GetItemFromId(p, value)

			if item then
				insert(v3, item.Name)
			end
		end

		return v3
	else
		if v2[childName] then
			childName = v2[childName]
		end

		if data.Inventory.Accessories.Vanity:FindFirstChild(childName) == nil then
			return
		else
			return CharacterInfoProvider.GetItemFromId(
				p,
				data.Inventory.Accessories.Vanity:FindFirstChild(childName).Value
			)
		end
	end
end

function CharacterInfoProvider.getEquippedAccessoryStats(p, childName)
	if p == nil then
		return {}
	end

	local data = Utility.GetData(p, false)

	if data == nil then
		return {}
	end

	if childName == nil then
		local v3 = {}

		for _, child in pairs(data.Inventory.Accessories.Stats:GetChildren()) do
			local value = child.Value

			if value == 0 then
				continue
			end

			local item = CharacterInfoProvider.GetItemFromId(p, value)

			if item then
				insert(v3, item.Name)
			end
		end

		return v3
	else
		if v2[childName] then
			childName = v2[childName]
		end

		if data.Inventory.Accessories.Stats:FindFirstChild(childName) == nil then
			return
		else
			return CharacterInfoProvider.GetItemFromId(
				p,
				data.Inventory.Accessories.Stats:FindFirstChild(childName).Value
			)
		end
	end
end

function CharacterInfoProvider.getEquippedItems(p, childName)
	if p == nil then
		return {}
	end

	local data = Utility.GetData(p, false)

	if data == nil then
		return {}
	end

	if childName then
		if v2[childName] then
			childName = v2[childName]
		end

		if data.Inventory.Toolbar:FindFirstChild(childName) == nil then
			return
		else
			return CharacterInfoProvider.GetItemFromId(p, data.Inventory.Toolbar:FindFirstChild(childName).Value)
		end
	else
		local v3 = {}

		for _, child in pairs(data.Inventory.Toolbar:GetChildren()) do
			local value = child.Value

			if value == 0 then
				continue
			end

			local item = CharacterInfoProvider.GetItemFromId(p, value)

			if item then
				insert(v3, item.Name)
			end
		end

		return v3
	end
end

local curPower = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Skills_Provider"):WaitForChild("CurPower")
local v3 = nil
local v4 = nil

function CharacterInfoProvider.get_core_anim(playerFromCharacter, childName, p)
	if playerFromCharacter == nil or childName == nil then
		return
	end

	local v5 = isClient and playerFromCharacter == localPlayer
	local equippedTool = v5 and CharacterInfoProvider.EquippedTool or ""
	local walk = nil

	if p ~= true then
		childName = v[childName] or childName
	end

	local v6 = false
	local value

	if v5 then
		value = curPower.Value
	end

	if not v5 and playerFromCharacter:HasTag("Players") then
		playerFromCharacter = game.Players:GetPlayerFromCharacter(playerFromCharacter) or playerFromCharacter
	end

	if playerFromCharacter.Parent == game.Players then
		v6 = true

		if not v5 then
			local items_Config = playerFromCharacter:FindFirstChild("Items_Config") or playerFromCharacter:FindFirstChild("Items_ConfigServer")

			if items_Config ~= nil and items_Config:FindFirstChild("Equipped") ~= nil and Utility.GetData(playerFromCharacter) ~= nil then
				local get_equipped_tool = CharacterInfoProvider.Get_equipped_tool(playerFromCharacter)

				if get_equipped_tool ~= nil then
					equippedTool = get_equipped_tool.Name
				end
			end
		end
	else
		local get_equipped_tool = CharacterInfoProvider.Get_equipped_tool(playerFromCharacter)

		if get_equipped_tool ~= nil then
			equippedTool = get_equipped_tool.Name
		end
	end

	if v5 then
		local formatted = `{childName}-{equippedTool}-{value}`

		if v3 == formatted then
			return v4
		else
			v3 = formatted
		end
	end

	if v6 and equippedTool ~= nil and equippedTool ~= "" and childName ~= "Run_Hit" and not string.match(
		childName,
		"^Swing_"
	) then
		local item = Items[equippedTool]

		if item ~= nil and type(item.DemonArt) == "string" and item.CombatPreset ~= nil and item.CombatPreset ~= "Combat" then
			local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
			local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)

			for _, childName2 in CharacterInfoProvider.GetEquippedPowers(playerFromCharacter) do
				if not (DemonArts[childName2] ~= nil and Resolve.LaneCarries(item.DemonArt, childName2)) then
					continue
				end

				local child = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild(childName2)

				if child and child:FindFirstChild(childName) then
					walk = child[childName]
				end

				break
			end
		end
	end

	if equippedTool and walk == nil then
		local v7 = "Toolbar_" .. equippedTool
		local toolbar_RegularKatana = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild(v7) or game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild(equippedTool)

		if toolbar_RegularKatana and toolbar_RegularKatana:FindFirstChild(childName) then
			walk = toolbar_RegularKatana[childName]
		elseif toolbar_RegularKatana == nil or not Utility.IsMeshRig(playerFromCharacter) or childName == "Run_Hit" or string.match(
			childName,
			"^Swing_"
		) then
			local item = Items[equippedTool]

			if item and item.CombatPreset then
				toolbar_RegularKatana = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild("Toolbar_" .. item.CombatPreset) or toolbar_RegularKatana
			elseif item and item.Breathing ~= nil then
				toolbar_RegularKatana = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild("Toolbar_Regular Katana")
			end

			if toolbar_RegularKatana and toolbar_RegularKatana:FindFirstChild(childName) then
				walk = toolbar_RegularKatana[childName]
			elseif item and item.CombatPreset and item.Breathing ~= nil then
				local toolbar_RegularKatana2 = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild("Toolbar_Regular Katana")

				if toolbar_RegularKatana2 and toolbar_RegularKatana2:FindFirstChild(childName) then
					walk = toolbar_RegularKatana2[childName]
				end
			end
		else
			walk = toolbar_RegularKatana:FindFirstChild("walk") or toolbar_RegularKatana:FindFirstChild("idle")
		end
	end

	local v7

	if equippedTool == nil or equippedTool == "" then
		v7 = false
	else
		local item = Items[equippedTool]

		if item == nil or item.CombatPreset == nil then
			v7 = false
		else
			v7 = item.CombatPreset ~= "Combat"
		end
	end

	if walk == nil and not v7 and value ~= nil and #value > 0 then
		for _, childName2 in ipairs(string.split(value, ",")) do
			local child = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild(childName2)

			if not (child and child:FindFirstChild(childName)) then
				continue
			end

			walk = child[childName]
			break
		end
	end

	if walk == nil then
		local default = game.ReplicatedStorage.Assets.Animations.Default_Core:FindFirstChild("Default")

		if default and default:FindFirstChild(childName) then
			walk = default[childName]
		end
	end

	if walk == nil and game.StarterPlayer:FindFirstChild("StarterCharacterScripts") and game.StarterPlayer.StarterCharacterScripts:FindFirstChild("Animate") then
		local child = game.StarterPlayer.StarterCharacterScripts.Animate:FindFirstChild(childName)

		if child then
			walk = child:FindFirstChildOfClass("Animation")
		end
	end

	if v5 then
		v4 = walk
	end

	return walk
end

return CharacterInfoProvider