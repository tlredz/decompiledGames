local CraftingService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clientServices = ReplicatedStorage:WaitForChild("ClientServices")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
ReplicatedStorage2:WaitForChild("Remotes")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage3:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("ProfileData"))
require(clientServices:WaitForChild("InventoryService"))
local ItemService = require(clientServices:WaitForChild("ItemService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local RecipeService = require(ReplicatedStorage5:WaitForChild("SharedServices"):WaitForChild("RecipeService"))
CraftingService.CurrentlyCrafting = {}

function CraftingService:IsMaterialCraftable(p: string)
	if p == nil then
		return false
	end

	local material = Sync.Materials[p]

	if material == nil then
		return false
	end

	if material.Craftable then
		return true
	end

	return false
end

function CraftingService:GetWeaponSalvageRewards(p: string)
	local rarity = Sync.Weapons[p].Rarity
	local rewards = Sync.SalvageRewards[p] and Sync.SalvageRewards[p].Rewards
	local rewards2 = Sync.SalvageRewards[rarity] and Sync.SalvageRewards[rarity].Rewards
	return rewards or rewards2 or {}
end

function CraftingService.GetSalvageInventory(_)
	local result = {}

	for k, v in ProfileData.Weapons.Owned do
		if RecipeService:IsItemSalvageable(k) then
			result[k] = v
		end
	end

	return result
end

function CraftingService.GenerateMaterialInventory(_)
	local result = {}

	for k, v in ProfileData.Materials.Owned do
		if CraftingService:IsMaterialCraftable(k) then
			result[k] = v
		end
	end

	return result
end

function CraftingService:ClearMultipleContainer(p)
	for _, frame in p.MultipleContainer:GetChildren() do
		if frame:IsA("Frame") then
			ItemService:ApplyMiniItemFrame(frame, nil, 1)
		end
	end
end

function CraftingService.ClearCrafting(_, p, p2)
	CraftingService.CurrentlyCrafting = {}
	p.SingleContainer.Visible = false
	p.MultipleContainer.Visible = false
	p2.SingleContainer.Visible = false
	p2.MultipleContainer.Visible = false
end

function CraftingService.SelectItemForCrafting(_, p, p2, p3: string, itemID: string)
	local v = Sync[p3][itemID]

	if not v then
		return
	end

	if p3 == "Weapons" then
		ItemService:ApplyItemToFrame(p.SingleContainer.NewItem, v, 1)
		p.SingleContainer.Visible = true
		p.MultipleContainer.Visible = false
		p2.SingleContainer.Visible = false
		p2.MultipleContainer.Visible = true
		CraftingService:ClearMultipleContainer(p2)
		local weaponSalvageRewards = CraftingService:GetWeaponSalvageRewards(itemID)
		local v2 = 1

		for k, weaponSalvageReward in weaponSalvageRewards do
			local v3 = weaponSalvageReward.Amount[1]
			local itemInfo = ItemService:GetItemInfo("Materials", k)
			ItemService:ApplyMiniItemFrame(p2.MultipleContainer["Material" .. v2], itemInfo, v3)
			v2 += 1
		end

		CraftingService.CurrentlyCrafting = {
			{
				itemType = "Weapons",
				itemID = itemID,
				amount = 1
			}
		}
	elseif p3 == "Materials" then
		for _, v2 in CraftingService.CurrentlyCrafting do
			if v2.itemType ~= "Weapons" then
				continue
			end

			CraftingService.CurrentlyCrafting = {}
			break
		end

		local v2 = nil

		for k, v4 in CraftingService.CurrentlyCrafting do
			if v4.itemID ~= itemID then
				continue
			end

			v2 = k
			break
		end

		if v2 then
			if CraftingService.CurrentlyCrafting[v2].amount < ProfileData.Materials.Owned[itemID] then
				CraftingService.CurrentlyCrafting[v2].amount += 1
			end
		elseif #CraftingService.CurrentlyCrafting < 4 then
			table.insert(CraftingService.CurrentlyCrafting, {
				itemType = "Materials",
				itemID = itemID,
				amount = 1
			})
		end

		for i = 1, 4 do
			local v4 = CraftingService.CurrentlyCrafting[i]

			if v4 then
				local itemInfo = ItemService:GetItemInfo("Materials", v4.itemID)
				ItemService:ApplyMiniItemFrame(p.MultipleContainer["Material" .. i], itemInfo, v4.amount)
			else
				ItemService:ApplyMiniItemFrame(p.MultipleContainer["Material" .. i], nil, 0)
			end
		end

		local craftingResult = RecipeService:GetCraftingResult(CraftingService.CurrentlyCrafting)

		if craftingResult then
			local itemInfo = ItemService:GetItemInfo("Recipes", craftingResult)
			ItemService:ApplyItemToFrame(p2.SingleContainer.NewItem, itemInfo, 1)
		else
			ItemService:ApplyItemToFrame(p2.SingleContainer.NewItem, nil, 1)
		end

		p2.SingleContainer.Visible = craftingResult ~= nil
		p2.MultipleContainer.Visible = false
		p.SingleContainer.Visible = false
		p.MultipleContainer.Visible = true
	end
end

return CraftingService