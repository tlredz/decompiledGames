local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local items = require(ReplicatedStorage.shared.modules.library.items)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local accessorydata = require(ReplicatedStorage.shared.modules.library.items.accessorydata)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local inventoryReplicator = DataController.InventoryReplicator
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local Item = {}
local v2 = {
	["Magic Thread"] = true,
	["Ancient Thread"] = true,
	["Lunar Thread"] = true,
	["Dusky Thread"] = true,
	["Poisonous Spearhead"] = true,
	["Toxic Core"] = true,
	["Mossy Core"] = true,
	["Barbed Spearhead"] = true,
	["Vine Line"] = true,
	["Murky Thread"] = true,
	Fillionaire = true,
	["Regular Token"] = true,
	["Elite Token"] = true,
	["Bag of Presents"] = true,
	["Sunstone Present"] = true,
	["Side Fins"] = true,
	["Metal Panels"] = true,
	["Back Fins"] = true,
	Windows = true,
	["Submarine Top"] = true,
	["Ice Crystal"] = true,
	["Lava Crystal"] = true,
	["Magnifying Glass"] = true,
	["Bunker Key"] = true,
	["Eternal Fuel"] = true,
	["Hourglass Hull"] = true,
	["Ethereal Glass"] = true,
	["Mythical Essence"] = true,
	["1000-Year-Old Wood"] = true,
	["Hourglass Lantern"] = true,
	["Sand Of Time"] = true,
	["Timeless Threading"] = true,
	["Evil Sigil"] = true,
	["Rokko's Fragment"] = true,
	["Vimble's Fragment"] = true,
	["Tilli's Fragment"] = true,
	["Wixie's Fragment"] = true,
	["Cepo's Fragment"] = true,
	Translator = true,
	["Mushroom Keystone"] = true,
	["Snowflake Keystone"] = true,
	["Turtle Keystone"] = true,
	["Sun Keystone"] = true,
	["Volcano Keystone"] = true,
	["Lightning Keystone"] = true,
	["Skull Keystone"] = true,
	["Cliff Keystone"] = true,
	["Fossil Keystone"] = true
}
local v3 = {
	["Blight Idol"] = true
}

function Item._HasKeyItem(childName: string)
	local backpack = v:FindFirstChildWhichIsA("Backpack")
	local tool = backpack and backpack:FindFirstChild(childName)

	if tool and tool:IsA("Tool") then
		return true
	end

	local character = v.Character
	local tool2 = character and character:FindFirstChild(childName)

	if tool2 and tool2:IsA("Tool") then
		return true
	end

	return false
end

function Item.GetOptions()
	local result = { "Fishing Rod", "Spear", "Harpoon Gun" }

	for k in items.KeyItems do
		if Item._HasKeyItem(k) then
			table.insert(result, k)
		end
	end

	inventoryReplicator:WaitForLoaded()
	local v4 = {}

	for _, v5 in inventoryReplicator:Index({ "Inventory" }) do
		v4[v5.name] = true
	end

	for k, item in items.Items do
		if not v4[k] or (item.NonPersistent or accessorydata[k] or v2[k]) then
			continue
		end

		table.insert(result, k)
	end

	for k, v5 in fish do
		if not (v4[k] and typeof(v5) == "table" and (v5.RelicGroup or v5.IsCrate or v3[k])) then
			continue
		end

		table.insert(result, k)
	end

	table.sort(result)
	return result
end

function Item.Select(p: string)
	if p == "Fishing Rod" then
		if Backpack.equipRod() then
			return
		end
	elseif p == "Spear" then
		if Backpack.equipSpear() then
			return
		end
	elseif p == "Harpoon Gun" then
		if Backpack.equipHarpoonGun() then
			return
		end
	else
		local v4, v5 = Backpack.equipItemByName(p)

		if v5 then
			task.wait()
			v5:Activate()
			v5:Deactivate()
			return
		elseif v4 then
			return
		end
	end

	anno_localthought:Fire(string.format("You don't have \"%s\" in your inventory right now.", p))
end

function Item.GetDisplay(p: string)
	if p == "Fishing Rod" then
		return "IconSmall", "rbxassetid://110276457326464"
	elseif p == "Spear" then
		return "IconSmall", "rbxassetid://113705241307272"
	elseif p == "Harpoon Gun" then
		return "IconSmall", "rbxassetid://70502746092006"
	end

	local keyItem = items.KeyItems[p]

	if keyItem and keyItem.Icon and keyItem.Icon ~= "" then
		return "IconSmall", keyItem.Icon
	end

	local v4 = items.Items[p] or fish[p]

	if v4 and v4.Icon and v4.Icon ~= "" then
		return "Icon", v4.Icon
	end

	return "Text", p
end

function Item.GetDescription(p: string)
	return (`Equip {p}`)
end

return Item