local EquipService = {}
local equipContainer = script:WaitForChild("EquipContainer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local clientServices = ReplicatedStorage3:WaitForChild("ClientServices")
local ItemService = require(clientServices:WaitForChild("ItemService"))
local v = {
	Perks = true,
	Knife = true,
	Gun = true
}
local v2 = {}
EquipService.EquippedChanged = script:WaitForChild("EquippedChanged")

function EquipService.EquipItem(_, p: string, p2: string)
	local itemInfo = ItemService:GetItemInfo(p, p2)

	if p == "Weapons" then
		local itemType = itemInfo.ItemType
		ProfileData.Weapons.Equipped[itemType] = p2
		EquipService.EquippedChanged:Fire(itemType, p2)
	else
		ProfileData[p].Equipped = { p2 }
		EquipService.EquippedChanged:Fire(p, p2)
	end

	remotes.Inventory.Equip:FireServer(p2, p)
end

function EquipService.UnequipItem(_, p: string)
	if p == "Knife" then
		ProfileData.Weapons.Equipped.Knife = "DefaultKnife"
	elseif p == "Gun" then
		ProfileData.Weapons.Equipped.Gun = "DefaultGun"
	else
		ProfileData[p].Equipped = {}
		remotes.Inventory.Unequip:FireServer(1, p)
	end

	EquipService.EquippedChanged:Fire(p, nil)
end

function EquipService:GetEquipped(p: string)
	if p == "Knife" then
		return ProfileData.Weapons.Equipped.Knife
	elseif p == "Gun" then
		return ProfileData.Weapons.Equipped.Gun
	end

	return ProfileData[p].Equipped[1]
end

function EquipService.CreateEquipContainer(_, p: string)
	local clone = equipContainer:Clone()
	clone.ItemFrame:Destroy()
	local clone2 = ItemService.BaseItemFrame:Clone()
	clone2.Parent = clone

	if v[p] then
		clone2.UIPadding:Destroy()
	end

	v2[p] = clone
	return clone
end

local function onEquippedChanged(p: string, equipped: string?)
	local v3 = v2[p]

	if not v3 then
		return
	end

	local v4 = p == "Knife" and "Weapons" or p == "Gun" and "Weapons" or p
	local itemInfo

	if equipped then
		itemInfo = ItemService:GetItemInfo(v4, equipped)
	end

	local itemFrame = v3:WaitForChild("ItemFrame")
	itemFrame.Visible = equipped ~= nil
	local unequip = v3.Unequip
	unequip.Visible = equipped ~= nil and v4 ~= "Perks" and v4 ~= "Weapons"
	ItemService:ApplyItemToFrame(itemFrame, itemInfo)
	ItemService:UpdateTags(itemFrame, itemInfo)
end

function EquipService.BindEquipContainer(_, p: string, p2)
	v2[p] = p2
	onEquippedChanged(p, EquipService:GetEquipped(p))
end

EquipService.EquippedChanged.Event:Connect(onEquippedChanged)
return EquipService