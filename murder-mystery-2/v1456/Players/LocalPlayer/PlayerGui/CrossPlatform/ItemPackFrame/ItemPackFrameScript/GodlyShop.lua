local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentItemPack = require(ReplicatedStorage:WaitForChild("SharedServices"):WaitForChild("EventInfoService")):GetCurrentItemPack()

if not currentItemPack then
	return {}
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ItemService = require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("ItemService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ItemPackService = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("ItemPackService"))
local main = script.Parent.Parent:WaitForChild("Container"):WaitForChild("ItemPack"):WaitForChild("Main")
local itemID = currentItemPack.ItemPackItems.Knife.ItemID
local itemID2 = currentItemPack.ItemPackItems.Gun.ItemID
local effectItemID = currentItemPack.ItemPackItems.Bundle.EffectItemID
local itemInfo = ItemService:GetItemInfo("Weapons", itemID)
main.Knife.Center.Item.IconContainer.Icon.Image = ItemService:GetItemImage(itemInfo)
main.Knife.Center.Item.ItemName.NameLabel.Text = ItemService:GetDisplayName(itemInfo)
main.Knife.Center.Item.ItemName.Shadow.Text = ItemService:GetDisplayName(itemInfo)
local itemInfo2 = ItemService:GetItemInfo("Weapons", itemID2)
main.Gun.Center.Item.IconContainer.Icon.Image = ItemService:GetItemImage(itemInfo2)
main.Gun.Center.Item.ItemName.NameLabel.Text = ItemService:GetDisplayName(itemInfo2)
main.Gun.Center.Item.ItemName.Shadow.Text = ItemService:GetDisplayName(itemInfo2)
local itemInfo3 = ItemService:GetItemInfo("Effects", effectItemID)
main.Bundle.Center.Item.IconContainer.KnifeIcon.Image = ItemService:GetItemImage(itemInfo)
main.Bundle.Center.Item.IconContainer.GunIcon.Image = ItemService:GetItemImage(itemInfo2)
main.Bundle.Center.Item.IconContainer.EffectIcon.Image = ItemService:GetItemImage(itemInfo3)
main.Knife.Center.Confirm.Activated:Connect(ItemPackService.PromptBuyKnife)
main.Gun.Center.Confirm.Activated:Connect(ItemPackService.PromptBuyGun)
main.Bundle.Center.Confirm.Activated:Connect(ItemPackService.PromptBuyBundle)
return {}