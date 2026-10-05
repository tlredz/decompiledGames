local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function minigameLocksItem(p)
	local lockedItemCategories = MinigameSettings.Get("LockedItemCategories")
	local item = Items[p.Name]
	return lockedItemCategories ~= nil and item ~= nil and lockedItemCategories[item.Category] == true
end

local ToolbarItemRestrictions = {
	Inventory = {
		Locked = {
			Icon = BunchaIcons.Locked,
			Desc = "Item is locked and can't be used"
		},
		NoSave = {
			Icon = BunchaIcons.NoSave,
			Desc = "When you leave and rejoin you won't have this item"
		},
		ActionsDisabled = {
			Icon = "",
			Desc = "Equiping and UnEquiping will be disabled"
		}
	},
	functions = {
		Locked = function(p, p2)
			if p == nil or p2 == nil then
				return false
			end

			local lockedItemCategories = MinigameSettings.Get("LockedItemCategories")
			local item = Items[p2.Name]
			local v

			if lockedItemCategories == nil or item == nil then
				v = false
			else
				v = lockedItemCategories[item.Category] == true
			end

			if v then
				return true
			end

			return not ItemRequirements.SatisfiesEquip(Utility.GetData(p), p2.Name)
		end,
		NoSave = function(_, instance)
			return instance ~= nil and instance:FindFirstChild("NoSave") ~= nil
		end,
		ActionsDisabled = function(p, p2)
			if p2 == nil then
				return false
			end

			local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(p.Name)

			if child == nil then
				return false
			end

			local tooldisabled = child:FindFirstChild("tooldisabled")

			if tooldisabled == nil then
				return false
			end

			local value = tooldisabled.Value

			if string.find(value, "all") then
				if not string.find(value, "except" .. p2.Name) then
					return true
				end
			elseif string.find(value, p2.Name) then
				return true
			end

			return false
		end
	},
	Changed = not RunService:IsClient() and "Not available on server" or simplesignal.new() or "Not available on server"
}

function ToolbarItemRestrictions.GetCurrentRestrictions(p, childName)
	if childName == nil then
		return {}
	end

	local data = Utility.GetData(p)

	if data == nil then
		return {}
	end

	local child = data.Inventory.Toolbar:FindFirstChild(childName)
	local item = Character_info_provider.GetItemFromId(p, child.Value)
	local result = {}

	for k, v in pairs(ToolbarItemRestrictions.functions) do
		if v(p, item) == true then
			result[tostring(k)] = true
		end
	end

	return result
end

if not RunService:IsClient() then
	return ToolbarItemRestrictions
end

local data = Utility.GetData(localPlayer, true)
local v = nil
ToolbarItemRestrictions.CurrentRestrictions = {
	One = {
		Restrictions = {},
		Changed = simplesignal.new()
	},
	Two = {
		Restrictions = {},
		Changed = simplesignal.new()
	},
	Three = {
		Restrictions = {},
		Changed = simplesignal.new()
	},
	Four = {
		Restrictions = {},
		Changed = simplesignal.new()
	},
	Five = {
		Restrictions = {},
		Changed = simplesignal.new()
	}
}

local function updchar(_)
	if v ~= nil then
		v:Destroy()
		v = nil
	end

	v = cleanit.new()

	local function UpdateRestrictions()
		local v2 = false

		for k, currentRestriction in pairs(ToolbarItemRestrictions.CurrentRestrictions) do
			local restrictions = ToolbarItemRestrictions.GetCurrentRestrictions(localPlayer, k) or {}
			local count = 0
			local count2 = 0
			local v4 = true
			local v5 = true

			for k2, restriction in pairs(currentRestriction.Restrictions) do
				count += 1

				if restrictions[k2] ~= restriction then
					v4 = false
				end
			end

			for k2, v6 in pairs(restrictions) do
				count2 += 1

				if currentRestriction.Restrictions[k2] ~= v6 then
					v5 = false
				end
			end

			if (count ~= count2 or not (v4 and v5)) ~= true then
				continue
			end

			ToolbarItemRestrictions.CurrentRestrictions[k].Restrictions = restrictions
			ToolbarItemRestrictions.CurrentRestrictions[k].Changed:Fire()
			v2 = true
		end

		if v2 == true then
			ToolbarItemRestrictions.Changed:Fire()
		end
	end

	local inventory = data:FindFirstChild("Inventory")

	if inventory ~= nil then
		for _, child in pairs(inventory.Toolbar:GetChildren()) do
			v:Connect(child.Changed, UpdateRestrictions)
		end
	end

	local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)

	if child ~= nil then
		v:Connect(child.ChildAdded, function(p)
			if p.Name == "tooldisabled" then
				UpdateRestrictions()
				v:Connect(p.Changed, UpdateRestrictions)
			end
		end)
		v:Connect(child.ChildRemoved, function(p)
			if p.Name == "tooldisabled" then
				UpdateRestrictions()
			end
		end)
		local tooldisabled = child:FindFirstChild("tooldisabled")

		if tooldisabled then
			v:Connect(tooldisabled.Changed, UpdateRestrictions)
		end
	end

	for _, v2 in ipairs(ItemRequirements.Keys()) do
		local resolved = ItemRequirements.Resolve(data, v2 == "Level" and "Exp.Goal" or v2)

		if resolved ~= nil then
			v:Connect(resolved.Changed, UpdateRestrictions)
		end
	end

	v:Connect(workspace:GetAttributeChangedSignal("MinigameKey"), UpdateRestrictions)
	UpdateRestrictions()
end

local character = localPlayer.Character

if character ~= nil then
	task.spawn(function()
		task.wait()

		if localPlayer.Character == character then
			updchar(localPlayer.Character)
		end
	end)
end

localPlayer.CharacterAdded:Connect(updchar)
return ToolbarItemRestrictions