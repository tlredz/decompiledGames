local ItemService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local color = Color3.fromRGB(95, 95, 95)
local itemFrame = script:WaitForChild("ItemFrame")
script:WaitForChild("MiniItemFrame")
local v = {
	Unique = 100000,
	Ancient = 200000,
	Godly = 300000,
	Legendary = 400000,
	Rare = 500000,
	Uncommon = 600000,
	Common = 700000
}
ItemService.BaseItemFrame = itemFrame

local function GetItemNameOrder(displayName: string)
	local v2 = string.lower(displayName)
	local v3 = 0

	for i = 1, math.min(#v2, 3) do
		local v4 = string.byte(v2, i) - 97 + 1
		v3 = v3 * 26 + v4
	end

	return v3
end

function ItemService.FindItemInfo(_, p: string, p2: string)
	if not Sync[p2] then
		return nil
	end

	if p2 == "Emotes" then
		return Sync.Emotes[p] or Sync.Toys[p]
	end

	return Sync[p2][p]
end

function ItemService:GetItemInfo(p: string, p2: string)
	local v2 = nil

	if p2 == "Emotes" then
		v2 = Sync.Emotes[p] or Sync.Toys[p]
	elseif Sync[p2] then
		v2 = Sync[p2][p]
	end

	if v2 then
		return v2
	end

	warn("ItemService: Failed to find data for item: " .. tostring(p) .. ", " .. tostring(p2))
	return Sync.Materials.ErrorItem
end

function ItemService.ItemExists(_, p: string, p2: string)
	return Sync[p2][p] ~= nil
end

function ItemService:GetRarityColor(p)
	local rarity = p.Rarity

	if rarity == "Common" or rarity == nil then
		return color
	end

	return Sync.Rarity[rarity]
end

function ItemService.GetDisplayInfo(_, p: string, p2: string)
	local itemInfo = ItemService:GetItemInfo(p, p2)
	return {
		Name = ItemService:GetDisplayName(itemInfo),
		Image = ItemService:GetItemImage(itemInfo),
		Color = ItemService:GetRarityColor(itemInfo),
		Chroma = itemInfo.Chroma
	}
end

function ItemService:GetDisplayName(data)
	return data.Name or data.DisplayName or data.ItemName
end

function ItemService:GetItemImage(p)
	local image = p.Image or p.Icon
	local v2 = tonumber(image)

	if v2 then
		return "rbxthumb://type=Asset&w=150&h=150&id=" .. v2
	end

	if typeof(image) == "string" then
		return image
	end

	return ""
end

function ItemService:GetAmountText(p: number)
	return p > 1 and "x" .. p or ""
end

function ItemService.GetLayoutOrder(_, p: string, p2: string)
	if p2 == "DefaultKnife" then
		return 0
	elseif p2 == "DefaultGun" then
		return 1
	end

	local itemInfo = ItemService:GetItemInfo(p, p2)
	local rarity = itemInfo.Rarity
	local displayName = ItemService:GetDisplayName(itemInfo) or ""
	return (v[rarity] or 700000) + GetItemNameOrder(displayName)
end

function ItemService:UpdateTags(p, options)
	local v2 = options or {}
	p.Tags.Chroma.Visible = v2.Chroma == true
	p.Tags.FX.Visible = v2.FX == true
	p.Tags.Evo.Visible = v2.EvoBaseID ~= nil
	local count = 0

	for _, frame in p.Tags:GetChildren() do
		if frame:IsA("Frame") and frame.Visible then
			count += 1
		end
	end

	return count
end

function ItemService.ApplyTags(_, p, p2)
	if ItemService:UpdateTags(p, p2) < 1 then
		p.Tags:Destroy()
	end
end

function ItemService.ApplyMiniItemFrame(_, data, p, value: number?)
	local v2 = value or 1

	if p == nil then
		data.Title.Text = ""
		data.Icon.Image = ""
		data.Amount.Text = ""
	else
		data.Title.Text = ItemService:GetDisplayName(p)
		data.Icon.Image = ItemService:GetItemImage(p)
		data.Amount.Text = ItemService:GetAmountText(v2)
	end
end

function ItemService.ApplyItemToFrame(_, p, p2, value: number?)
	local v2 = value or 1

	if p2 == nil then
		p.ItemName.Label.Text = ""
		p.ItemName.BackgroundColor3 = Sync.Rarity.Common
		p.Container.Icon.Image = ""
		p.Container.Amount.Text = ""
	else
		p.ItemName.Label.Text = ItemService:GetDisplayName(p2)
		p.ItemName.BackgroundColor3 = ItemService:GetRarityColor(p2)
		p.Container.Icon.Image = ItemService:GetItemImage(p2)
		p.Container.Amount.Text = ItemService:GetAmountText(v2)
	end

	return p
end

function ItemService.CommaNumber(_, p: number)
	local v2 = tostring(p)

	repeat
		local v3
		v2, v3 = string.gsub(v2, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v3 == 0

	return v2
end

return ItemService