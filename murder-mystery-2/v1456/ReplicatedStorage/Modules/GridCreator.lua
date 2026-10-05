local GridCreator = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local rarity = Sync.Rarity

if not _G.Cache then
	_G.Cache = {}
end

local v = {
	Classic = 1,
	Common = 2,
	Uncommon = 3,
	Rare = 4,
	Legendary = 5,
	Godly = 6,
	Victim = 7,
	Unique = 7,
	Christmas = 1.5,
	Halloween = 1.6,
	Ancient = 6.5
}
local CopyTable

CopyTable = function(items)
	local result = {}

	for k2, item in pairs(items) do
		if type(item) == "table" then
			item = CopyTable(item)
		end

		result[k2] = item
	end

	return result
end

function GridCreator.GetImage(p)
	if _G.Cache[p] ~= nil then
		return _G.Cache[p]
	end

	local v2

	if tonumber(p) then
		v2 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. p or p
	else
		v2 = p
	end

	local v3 = v2 .. "&bust=" .. math.random(1, 10000)
	_G.Cache[p] = v3
	return v3
end

function GridCreator.GetSortedInventory()
	local copyTable = CopyTable(ProfileData.Weapons)
	local result = {}

	for k2, amount in pairs(copyTable.Owned) do
		if Sync.Weapons[k2] then
			table.insert(result, {
				ItemID = k2,
				Amount = amount
			})
		end
	end

	table.sort(result, function(a, b)
		local v3 = { a.ItemID, b.ItemID }
		local v4 = { a.Amount, b.Amount }
		local v5 = { Sync.Item[v3[1]], Sync.Item[v3[2]] }
		local v6 = { v[v5[1].Rarity], v[v5[2].Rarity] }

		if v3[1] == "DefaultKnife" then
			return true
		end

		if v3[2] == "DefaultKnife" then
			return false
		end

		if v3[1] == "DefaultGun" then
			return true
		end

		if v3[2] == "DefaultGun" then
			return false
		end

		if v6[1] ~= v6[2] then
			return v6[1] > v6[2]
		end

		if v4[1] == v4[2] then
			return v5[1].ItemName < v5[2].ItemName
		end

		return v4[1] > v4[2]
	end)
	return result
end

function GridCreator.CreateFrame(p, p2, callback, instance, _, p3, _, p4)
	local clone = instance:Clone()
	clone.Name = p4 or p2.ID or p2.ItemID or tostring(instance.Name .. p3)
	callback(clone, p2, p)
	return clone
end

function GridCreator.CreateGrid(p, p2, items, scrollingFrame)
	local container = scrollingFrame.Container
	local scale = p2.Size.X.Scale
	container:ClearAllChildren()
	local count = 0
	local v2 = nil

	for k2, item in pairs(items) do
		if not (item.ItemID ~= "DefaultKnife" and item.ItemID ~= "DefaultGun") then
			continue
		end

		local v3 = math.floor(count / math.floor(1 / scale))
		local v4 = count % math.floor(1 / scale)
		local frame = GridCreator.CreateFrame(k2, item, p, p2, scrollingFrame, count, v3)
		frame.Parent = container
		v2 = v2 or frame.AbsoluteSize
		frame.Position = UDim2.new(scale * v4, 0, 0, v2.Y * v3)

		if scrollingFrame:IsA("ScrollingFrame") then
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (v3 + 1) * v2.Y)
		end

		count += 1
	end
end

function GridCreator.CreateList(p, p2, items, p3)
	local container = p3.Container
	container:ClearAllChildren()
	local count = 0

	for k2, item in items do
		local v2 = math.floor(count / 1)
		local frame = GridCreator.CreateFrame(k2, item, p, p2, p3, count, v2)
		frame.Parent = container
		frame.Position = UDim2.new(0, 0, 0, frame.AbsoluteSize.Y * v2)
		p3.CanvasSize = UDim2.new(0, 0, 0, (v2 + 1) * frame.AbsoluteSize.Y)
		count += 1
	end
end

function GridCreator.CreatePass(callback, p, p2, parent, instance)
	local count = 0

	for i = 1, p2.TotalTiers do
		local v2 = tostring(i)
		local v3 = math.floor(count / 5)
		local v4 = count % 5
		local clone = parent:FindFirstChild("Page" .. v3)

		if not clone then
			clone = instance:Clone()
			clone.Name = "Page" .. v3
			clone.Parent = parent
		end

		local v5 = p2.Rewards[v2] or {}
		local child = clone:FindFirstChild("Tier" .. v2)

		if child then
			callback(child, v5, i)
		else
			local frame = GridCreator.CreateFrame(i, v5, callback, p, nil, v4, nil, "Tier" .. v2)
			frame.Parent = clone
			frame.Position = UDim2.new(0, frame.AbsoluteSize.X * v4, 0, 0)
		end

		count += 1
	end
end

function GridCreator.MakeItemFrame(container, data, p)
	local itemID = data.ItemID
	local amount = data.Amount

	if container:FindFirstChild("Container") then
		container = container.Container
	end

	local itemName = container.Icon:FindFirstChild("ItemName") or container.ItemName
	local v2 = (Sync[data.ItemType] or Sync.Item)[itemID] or itemID or {
		Image = "",
		ItemName = "",
		Rarity = "Common"
	}
	local icon = container.Icon
	local image = v2.Image
	local image2

	if _G.Cache[image] == nil then
		local v4

		if tonumber(image) then
			v4 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
		else
			v4 = image
		end

		image2 = v4 .. "&bust=" .. math.random(1, 10000)
		_G.Cache[image] = image2
	else
		image2 = _G.Cache[image]
	end

	icon.Image = image2
	itemName.Text = v2.ItemName or v2.Name
	itemName.TextColor3 = rarity[v2.Rarity or "Common"]

	if amount then
		container.Rarity.Text = v2.Rarity
		container.Rarity.TextColor3 = rarity[v2.Rarity]
		container.Year.Text = v2.Year or ""
		container.Event.Text = v2.Event or ""
		container.Event.TextColor3 = v2.Event and rarity[v2.Event] or Color3.new()

		if amount > 1 then
			container.Amount.Text = "x" .. math.floor(amount)
		end

		if p == nil then
			container.MouseEnter:connect(function()
				container.Rarity.Visible = true
				container.Year.Visible = true
				container.Event.Visible = true
			end)
			container.MouseLeave:connect(function()
				container.Rarity.Visible = false
				container.Year.Visible = false
				container.Event.Visible = false
			end)
		end
	end
end

function GridCreator.Commafy(value)
	repeat
		local v2
		value, v2 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v2
	until k == 0

	return value
end

function GridCreator.Pluralize(p, p2)
	if p == 1 then
		return p2
	end

	return p2 .. "s"
end

function GridCreator.ConvertTimestamp(p)
	local v2 = math.floor(p / 86400)
	local v3 = math.floor(p % 86400 / 3600)
	local v4 = v2 .. "d, " .. v3 .. "h"

	if v2 < 1 then
		local v5 = v3 .. "h"
		v4 = v3 == 1 and "Less than 2 hours" or v5
	end

	local v5 = p <= 3600 and "Less than 1 hour!" or v4
	return p <= 0 and "ENDED!" or v5
end

return GridCreator