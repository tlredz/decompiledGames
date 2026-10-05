local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local CategorySeparator = require(script.Parent.CategorySeparator)
local IndexRow = require(script.Parent.IndexRow)
require(script.Parent.Types)
local Button = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.Button)
local PanelModal = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.PanelModal)
local TabBar = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.TabBar)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
local read = VideUtil.read
local colorSequence = ColorSequence.new(Color3.fromRGB(76, 86, 112), Color3.fromRGB(48, 55, 74))
local color = Color3.fromRGB(22, 28, 44)
local color2 = Color3.fromRGB(226, 234, 250)
local color3 = Color3.fromRGB(206, 216, 240)
local color4 = Color3.fromRGB(22, 28, 44)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)

-- equivalent calls inferred from this helper; original call sites unknown
local function itemFrom(callback)
	local v = callback()
	assert(v.kind == "item")
	return v.item
end

local function separatorLabelOf(callback)
	local v = callback()
	assert(v.kind == "separator")
	return v.label
end

local function appendItems(list, list2, flag: boolean)
	if flag then
		for i = #list2, 1, -1 do
			local v = list2[i]
			table.insert(list, {
				kind = "item",
				id = v.id,
				item = v
			})
		end
	else
		for _, v in ipairs(list2) do
			table.insert(list, {
				kind = "item",
				id = v.id,
				item = v
			})
		end
	end
end

local function renderSeparator(callback, data)
	return CategorySeparator({
		Name = "Separator",
		Size = UDim2.fromScale(1, 1),
		Variant = data.Variant,
		Label = function()
			local v = callback()
			assert(v.kind == "separator")
			return v.label
		end
	})
end

local function renderItem(callback, data)
	return IndexRow({
		Name = "Item",
		Size = UDim2.fromScale(1, 1),
		Variant = data.Variant,
		Label = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.label
		end,
		Icon = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.icon
		end,
		Rarity = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.rarity
		end,
		Bonus = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.bonus
		end,
		NextBonus = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.nextBonus or ""
		end,
		StatLabel = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.stat or ""
		end,
		Tier = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.tier
		end,
		Owned = function()
			local v = callback()
			assert(v.kind == "item")
			return v.item.owned
		end,
		OnActivated = data.OnSelect and function()
			data.OnSelect((itemFrom(callback)).id)
		end or nil
	})
end

local function IndexMenu(data)
	local categories = data.Categories or {}
	local category = categories[1]
	local source = Vide.source(not category and "" or category.id)
	local source2 = Vide.source(false)
	local mainCategory = data.MainCategory or "Main"
	local itemCategories = data.ItemCategories or {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function activeFilter()
		local v = source()

		for _, category2 in ipairs(categories) do
			if category2.id == v then
				return category2.categories
			end
		end

		return nil
	end

	local function items()
		local v = activeFilter() -- equivalent call inferred; original call site unknown
		local items2 = data.Items()
		local result = {}

		for _, item in ipairs(items2) do
			if v == nil or table.find(v, item.category) then
				table.insert(result, item)
			end
		end

		return result
	end

	local function listRows()
		local labelsById = {}
		local ids = {}

		for _, itemCategory in ipairs(itemCategories) do
			labelsById[itemCategory.id] = itemCategory.label
			table.insert(ids, itemCategory.id)
		end

		local v = {}
		local categories2 = {}

		for _, v2 in ipairs((items())) do
			if v[v2.category] == nil then
				v[v2.category] = {}
				table.insert(categories2, v2.category)
			end

			table.insert(v[v2.category], v2)
		end

		local v2 = source2()
		local v3 = {}
		local v4 = {}

		local function emit(p: string)
			local v5 = v[p]

			if v5 then
				if p ~= mainCategory then
					table.insert(v4, {
						kind = "separator",
						id = "sep:" .. p,
						label = labelsById[p] or p
					})
				end

				appendItems(v4, v5, v2)
				v3[p] = true
			end
		end

		for _, v5 in ipairs(ids) do
			emit(v5)
		end

		for _, v5 in ipairs(categories2) do
			if not v3[v5] then
				emit(v5)
			end
		end

		return v4
	end

	local function statusText()
		local statusText2 = data.StatusText

		if statusText2 ~= nil then
			return read(statusText2)
		end

		local v = items()
		local count = 0

		for _, v2 in ipairs(v) do
			if v2.owned then
				count += 1
			end
		end

		return string.format("COLLECTED: %d / %d", count, #v)
	end

	local tabs = {}

	for i, category2 in ipairs(categories) do
		tabs[i] = {
			Id = category2.id,
			Label = category2.label
		}
	end

	local hint = data.Hint
	local text = hint == nil and "Click an icon to see its next tier" or read(hint)
	local v3 = text ~= ""
	local showSort = data.ShowSort ~= false
	local v4 = v3 and 0.58 or 0.78
	local v5 = showSort and 0.905 or 1
	local v6

	if #tabs > 0 then
		v6 = TabBar({
			Name = "CategoryTabs",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(v5, v4),
			Tabs = tabs,
			SelectedId = source,
			OnSelect = function(p: string)
				source(p)
			end
		})
	end

	local v7

	if showSort then
		v7 = Button({
			Name = "SortButton",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.08, v4),
			Text = function()
				if source2() then
					return "▼"
				end

				return "▲"
			end,
			TextColor = color2,
			TextStrokeColor = color,
			Gradient = colorSequence,
			StrokeColor = color,
			StrokeThickness = 0.08,
			CornerRadius = UDim.new(0.35, 0),
			PaddingX = 0.1,
			PaddingY = 0.16,
			OnActivated = function()
				local v8 = not source2()
				source2(v8)
				local onSortChanged = data.OnSortChanged

				if onSortChanged then
					onSortChanged(v8)
				end
			end
		})
	end

	local v8

	if v3 then
		v8 = create("TextLabel")({
			Name = "Hint",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = text,
			TextColor3 = color3,
			TextTransparency = 0.25,
			TextScaled = true,
			create("UIStroke")({
				Color = color4,
				Thickness = 0.12,
				Transparency = 0.25,
				StrokeSizingMode = 1
			})
		})
	end

	local header

	if v6 or v8 or v7 then
		header = create("Frame")({
			Name = "IndexHeader",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			v8,
			v6,
			v7
		})
	end

	return PanelModal({
		Name = data.Name or "ItemIndexModal",
		Visible = data.Visible,
		BannerText = data.Title or "ITEM INDEX",
		StatusText = statusText,
		Header = header,
		HeaderHeight = header and (v3 and 0.2 or 0.12) or 0,
		OnClose = data.OnClose
	}, { Vide.indexes(listRows, function(callback, layoutOrder: number)
			return create("Frame")({
				Name = function()
					return callback().id
				end,
				LayoutOrder = layoutOrder,
				Size = function()
					if callback().kind == "separator" then
						return (UDim2.fromScale(1, 0.14))
					end

					return (UDim2.fromScale(1, 0.33))
				end,
				BackgroundTransparency = 1,
				Vide.switch(function()
					return callback().kind
				end)({
					separator = function()
						return renderSeparator(callback, data)
					end,
					item = function()
						return renderItem(callback, data)
					end
				})
			})
		end) })
end

return IndexMenu