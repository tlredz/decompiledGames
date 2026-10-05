local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local FFlags = require(packages.FFlags)
local Shop = require(ReplicatedStorage.Datas.Shop)
local ServerLuck = require(ReplicatedStorage.Datas.ServerLuck)
local Layout = require(script.Parent.Layout)
local localPlayer = Players.LocalPlayer
local v = { 3329528158, 3329527999, 3329528437 }
local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function setLayoutOrder(instance, p: number?)
	local originalOrder = instance:GetAttribute("OriginalOrder")

	if not originalOrder then
		originalOrder = instance.LayoutOrder
		instance:SetAttribute("OriginalOrder", originalOrder)
	end

	instance.LayoutOrder = p or originalOrder
end

local function respaceSections(resolved, frames)
	local guiObjects = {}

	for _, guiObject in resolved:GetChildren() do
		if not (guiObject:IsA("GuiObject") and string.match(guiObject.Name, "^PaddingLO%d+$")) then
			continue
		end

		table.insert(guiObjects, guiObject)
	end

	if #guiObjects == 0 then
		return
	end

	table.sort(guiObjects, function(a, b)
		return (a:GetAttribute("OriginalOrder") or a.LayoutOrder) < (b:GetAttribute("OriginalOrder") or b.LayoutOrder)
	end)

	for k, v3 in guiObjects do
		local v4 = frames[k]

		if v4 and k < #frames then
			setLayoutOrder(v3, v4.LayoutOrder + 1) -- equivalent call inferred; original call site unknown
		else
			if not v3:GetAttribute("OriginalOrder") then
				v3:SetAttribute("OriginalOrder", v3.LayoutOrder)
			end

			v3.LayoutOrder = 1000
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addProductIds(names, instance)
	if not instance then
		return
	end

	for _, child in instance:GetChildren() do
		local name = tonumber(child.Name)

		if name then
			table.insert(names, name)
		end
	end
end

local function cardContainer(instance)
	if not instance then
		return nil
	end

	local main = instance:FindFirstChild("Main")
	local grid = main and main:FindFirstChild("Grid")

	if grid then
		return grid
	end

	local child = instance:FindFirstChild(instance.Name)
	local list = child and child:FindFirstChild("List")
	return list or instance
end

local function moneyRowContainer(frame)
	if not frame then
		return nil
	end

	if frame:FindFirstChild("1") and frame:FindFirstChild("2") then
		return frame
	end

	for _, child in frame:GetChildren() do
		if child:FindFirstChild("1") and child:FindFirstChild("2") then
			return child
		end
	end

	return nil
end

local function sortMoney(instance, productIds, p)
	local _1 = instance:FindFirstChild("1")
	local _2 = instance:FindFirstChild("2")

	if not (_2 and _1) then
		return
	end

	local guiObject = _2:FindFirstChildWhichIsA("GuiObject")
	local guiObject2 = _1:FindFirstChildWhichIsA("GuiObject")
	local uIListLayout = _2:FindFirstChildWhichIsA("UIListLayout")
	local uIListLayout2 = _1:FindFirstChildWhichIsA("UIListLayout")

	if not (guiObject and guiObject2) then
		return
	end

	local clone = guiObject2:Clone()
	local clone2 = guiObject:Clone()

	if _2:IsA("GuiObject") then
		_2.LayoutOrder = 1
	end

	if _1:IsA("GuiObject") then
		_1.LayoutOrder = 2
	end

	local uIListLayout3 = instance:FindFirstChildWhichIsA("UIListLayout")

	if uIListLayout3 then
		uIListLayout3.Padding = UDim.new(0.05, 0)
	end

	if uIListLayout then
		uIListLayout.Parent = _2
	end

	if uIListLayout2 then
		uIListLayout2.Parent = _1
	end

	for _, v3 in productIds do
		local v4 = FFlags:Get(`ShopProductRankOverrides/{v3}`, 0)

		if v4 ~= 0 and p[v3] then
			p[v3] -= v4
		end
	end

	local v3 = productIds[1]
	local v4 = {}
	local v5 = {}

	for _, v6 in productIds do
		if (p[v6] or 1) < (p[v3] or 1) then
			v3 = v6
		end

		local v7 = Shop[v6]

		if not v7 then
			return
		end

		table.insert(v4, v6)
		v5[v6] = v7.Value
	end

	local v6 = v3 ~= v4[#v4]
	table.sort(v4, function(a, b)
		if v6 then
			return v5[a] < v5[b]
		end

		return v5[a] > v5[b]
	end)
	local v7 = { v3 }

	for _, v8 in v4 do
		if v8 ~= v3 then
			table.insert(v7, v8)
		end
	end

	for k, v8 in v7 do
		local guiObject3 = _1:FindFirstChild((tostring(v8))) or _2:FindFirstChild((tostring(v8)))

		if not (guiObject3 and guiObject3:IsA("GuiObject")) then
			continue
		end

		guiObject3.LayoutOrder = k
		local v9 = k <= 2
		local image

		if v9 then
			image = clone2
		else
			image = clone
		end

		guiObject3.Size = image.Size

		if guiObject3:IsA("ImageLabel") and image:IsA("ImageLabel") then
			guiObject3.Image = image.Image
		end

		for _, guiObject4 in guiObject3:GetChildren() do
			local guiObject5 = image:FindFirstChild(guiObject4.Name)

			if not (guiObject4:IsA("GuiObject") and guiObject5 and guiObject5:IsA("GuiObject")) then
				continue
			end

			guiObject4.Size = guiObject5.Size
			guiObject4.Position = guiObject5.Position
			guiObject4.AnchorPoint = guiObject5.AnchorPoint
		end

		local parent

		if v9 then
			parent = _2
		else
			parent = _1
		end

		guiObject3.Parent = parent
	end

	clone:Destroy()
	clone2:Destroy()
end

function v2.SortByProductRank(p, p2, flag: boolean?, flag2: boolean?)
	local resolved = Layout.Resolve(p, p2.List)

	if not resolved then
		return
	end

	local v3 = Synchronizer:Get(localPlayer)

	local function sectionOf(p3: string, productIds)
		local section = p2.Sections[p3]
		local resolved2

		if section then
			resolved2 = Layout.Resolve(resolved, section.Frame)
		end

		local title

		if section and section.Title then
			title = Layout.Resolve(resolved, section.Title)
		end

		return {
			Frame = resolved2,
			Title = title,
			ProductIds = productIds,
			Rank = 0
		}
	end

	local v4 = {
		ServerLuck = sectionOf("ServerLuck", { ServerLuck[1].ProductId, ServerLuck[2].ProductId }),
		StarterPack = sectionOf("StarterPack", { 3290334159 }),
		LuckyBlocks = sectionOf("LuckyBlocks", table.clone(v)),
		Gear = sectionOf("Items", {}),
		Gamepasses = sectionOf("Gamepasses", {}),
		Money = sectionOf("Money", {})
	}
	local frame = v4.Gear.Frame
	local grid

	if frame then
		local main = frame:FindFirstChild("Main")
		grid = main and main:FindFirstChild("Grid")

		if not grid then
			local child = frame:FindFirstChild(frame.Name)
			grid = child and child:FindFirstChild("List") or frame
		end
	end

	addProductIds(v4.Gear.ProductIds, grid) -- equivalent call inferred; original call site unknown
	local frame2 = v4.Gamepasses.Frame
	local grid2

	if frame2 then
		local main = frame2:FindFirstChild("Main")
		grid2 = main and main:FindFirstChild("Grid")

		if not grid2 then
			local child = frame2:FindFirstChild(frame2.Name)
			grid2 = child and child:FindFirstChild("List") or frame2
		end
	end

	addProductIds(v4.Gamepasses.ProductIds, grid2) -- equivalent call inferred; original call site unknown
	local gridMain = grid2 and grid2:FindFirstChild("Main")
	addProductIds(v4.Gamepasses.ProductIds, gridMain) -- equivalent call inferred; original call site unknown
	local v5 = moneyRowContainer(v4.Money.Frame)

	if v5 then
		for _, guiObject in v5:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			addProductIds(v4.Money.ProductIds, guiObject) -- equivalent call inferred; original call site unknown
		end
	end

	local v6 = {}

	for _, v7 in v4 do
		for _, productId in v7.ProductIds do
			local v8 = Shop[productId]

			if v8 then
				local infoType

				if v8.Type == "Gamepass" then
					infoType = Enum.InfoType.GamePass
				else
					infoType = Enum.InfoType.Product
				end

				table.insert(v6, {
					Id = productId,
					InfoType = infoType
				})
			else
				warn((`ShopUI.Sorting: product {productId} is in the shop but not in ShopData`))
			end
		end
	end

	local success, result = pcall(function()
		return MarketplaceService:RankProductsAsync(v6)
	end)

	if not success or typeof(result) ~= "table" then
		warn((`ShopUI.Sorting: RankProductsAsync failed: {result}`))
		return
	end

	local v7 = {}

	for k, v8 in result do
		v7[v8.ProductIdentifier.Id] = k
	end

	for k, v8 in v4 do
		local total = 0
		local rank = 1e999

		for _, productId in v8.ProductIds do
			local v10 = v7[productId]

			if not v10 then
				continue
			end

			total += v10
			rank = math.min(rank, v10)
		end

		if flag2 then
			v8.Rank = rank
		elseif #v8.ProductIds > 0 then
			v8.Rank = total / #v8.ProductIds
		end

		v8.Rank -= FFlags:Get(`ShopSectionRankOverrides/{k}`, 0)
	end

	local v8 = {}

	for k in v4 do
		table.insert(v8, k)
	end

	table.sort(v8, function(a, b)
		return v4[a].Rank < v4[b].Rank
	end)

	if flag then
		local frames = {}

		for k, v9 in v8 do
			local v10 = v4[v9]
			local v11 = k * 10 + 5

			if v10.Frame and v10.Frame:IsA("GuiObject") then
				setLayoutOrder(v10.Frame, v11) -- equivalent call inferred; original call site unknown
				table.insert(frames, v10.Frame)
			end

			if not (v10.Title and v10.Title:IsA("GuiObject")) then
				continue
			end

			setLayoutOrder(v10.Title, v11 - 1) -- equivalent call inferred; original call site unknown
		end

		local codes = p2.Sections.Codes

		if codes then
			local resolved2 = Layout.Resolve(resolved, codes.Frame)

			if resolved2 and resolved2:IsA("GuiObject") then
				if not resolved2:GetAttribute("OriginalOrder") then
					resolved2:SetAttribute("OriginalOrder", resolved2.LayoutOrder)
				end

				resolved2.LayoutOrder = 1001
			end

			local resolved3

			if codes.Title then
				resolved3 = Layout.Resolve(resolved, codes.Title)
			end

			if resolved3 and resolved3:IsA("GuiObject") then
				if not resolved3:GetAttribute("OriginalOrder") then
					resolved3:SetAttribute("OriginalOrder", resolved3.LayoutOrder)
				end

				resolved3.LayoutOrder = 1000
			end
		end

		respaceSections(resolved, frames)
	end

	if v3 then
		for k in v7 do
			local v9 = Shop[k]

			if not v9 then
				continue
			end

			local v10

			if v9.Type == "Gamepass" then
				v10 = v3:Get((`Gamepass.{v9.Display}`))
			elseif v9.Type == "Item" then
				v10 = v3:Get((`Items.{v9.Display}`))
			else
				v10 = false
			end

			if v10 then
				v7[k] += 1000
			end
		end
	end

	if grid then
		for _, guiObject in grid:GetChildren() do
			local name = tonumber(guiObject.Name)

			if not (name and guiObject:IsA("GuiObject")) then
				continue
			end

			setLayoutOrder(guiObject, v7[name] or 1) -- equivalent call inferred; original call site unknown
		end
	end

	if gridMain and gridMain:IsA("GuiObject") then
		local v9 = v7[1227013099] or 1
		local v10 = true

		for _, productId in v4.Gamepasses.ProductIds do
			if not ((v7[productId] or 1) < v9) then
				continue
			end

			v10 = false
			break
		end

		gridMain.LayoutOrder = v10 and 100 or -1

		for _, guiObject in gridMain:GetChildren() do
			local name = tonumber(guiObject.Name)

			if not (name and guiObject:IsA("GuiObject")) then
				continue
			end

			setLayoutOrder(guiObject, v7[name] or 1) -- equivalent call inferred; original call site unknown
		end
	end

	if v5 then
		sortMoney(v5, v4.Money.ProductIds, v7)
	end
end

function v2.RunExperiments(p, p2, object2)
	if object[p] then
		return
	end

	object[p] = true
	local v3 = object2:Get({ "Configs", "ShopProductRankSorting" })
	local v4 = object2:Get({ "Configs", "ShopSectionRankSorting" })
	local v5 = object2:Get({ "Configs", "ShopSectionTopProductRankSorting" })

	if v3 or v4 or v5 then
		v2.SortByProductRank(p, p2, v4 == true or v5 == true, v5 == true)
	end
end

return table.freeze(v2)