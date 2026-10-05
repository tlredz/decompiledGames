local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Types.TradeTypes)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local rbxassetfontsfamiliesNunitojson = Font.new("rbxasset://fonts/families/Nunito.json")
local font = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json")
local userId

if RunService:IsRunning() and Players.LocalPlayer then
	userId = Players.LocalPlayer.UserId
else
	userId = nil
end

local createElement = React.createElement

function solveLevenshteinDistance(value: string, value2: string)
	if value == value2 then
		return 0
	end

	if value:len() == 0 then
		return value2:len()
	end

	if value2:len() == 0 then
		return value:len()
	end

	if value:len() < value2:len() then
		value2, value = value, value2
	end

	local v = {}

	for i = 1, #value + 1 do
		v[i] = { i - 1 }
	end

	for i = 1, #value2 + 1 do
		v[1][i] = i - 1
	end

	local function min(...)
		local v2 = { ... }
		local v3 = v2[1]

		for i = 1, #v2 do
			if v2[i] < v3 then
				v3 = v2[i]
			end
		end

		return v3
	end

	for i = 2, #value + 1 do
		for i2 = 2, #value2 + 1 do
			local v2 = value:sub(i - 1, i - 1) == value2:sub(i2 - 1, i2 - 1) and 0 or 1
			v[i][i2] = min(v[i - 1][i2] + 1, v[i][i2 - 1] + 1, v[i - 1][i2 - 1] + v2)
		end
	end

	return v[#value + 1][#value2 + 1]
end

function filterSearchResults(p, value: string)
	if value == "" or #value < 3 then
		return nil
	end

	local result = {}

	for k in string.gmatch(string.lower(value), "%w+") do
		for _, name in p.Names do
			local v = string.lower(name)

			for k2 in string.gmatch(v, "%w+") do
				if not (string.find(k2, k, 1, true) or string.sub(k, 1, 1) == string.sub(k2, 1, 1) and solveLevenshteinDistance(
					k2,
					k
				) <= 2) then
					continue
				end

				local v2 = p.NameToIdMap[name]

				if not v2 then
					continue
				end

				for _, v3 in v2 do
					result[v3] = true
				end
			end
		end
	end

	return result
end

function countdown(p)
	local state, setState = React.useState(p.TradeAt.UnixTimestamp - DateTime.now().UnixTimestamp)
	local ref = React.useRef(state)
	ref.current = state
	React.useEffect(function()
		if not p.TradeAt then
			return function() end
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
			local v = p.TradeAt.UnixTimestamp - DateTime.now().UnixTimestamp

			if v ~= ref.current then
				setState(v)
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { p.TradeAt.UnixTimestamp })

	if state <= 0 then
		return nil
	end

	return (createElement("TextLabel", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = 0.9,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.new(0, 0, 0.15, 1),
		Size = UDim2.new(1, 0, 0.85, -4),
		Text = tostring(state),
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	}))
end

function tileButton(p)
	return createElement("ImageButton", RobloxTypes.mergeImageButton({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2882228740",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		Position = UDim2.fromScale(0.5, 0.04),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(0.24, 0.24),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		SliceCenter = Rect.new(4, 4, 16, 16),
		[React.Event.Activated] = function()
			p.OnClick()
		end
	}, p), {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
		}),
		IconLabel = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageColor3 = Color3.fromRGB(255, 158, 119),
			ImageTransparency = 0.7,
			Position = UDim2.fromScale(0, 0.2),
			Size = UDim2.fromScale(1, 0.6),
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = rbxassetfontsfamiliesNunitojson,
				Position = UDim2.new(0.5, 0, 0.5, -3),
				Size = UDim2.fromScale(0.9, 1.5),
				Text = p.Text,
				TextColor3 = Color3.fromRGB(255, 238, 0),
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
				ZIndex = CONSTANTS.LAYER.RAISED
			})
		}),
		ImageLabel = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = Color3.fromRGB(243, 243, 243),
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(4, 4, 16, 16)
		})
	})
end

function itemTile(p)
	local v = useMatch(p.TradeItem.ItemId)
	assert(v, "bad item config")
	local mergeImageButton = RobloxTypes.mergeImageButton({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2882228740",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		Position = UDim2.fromScale(0.5, 0.04),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(0.24, 0.24),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		SliceCenter = Rect.new(4, 4, 16, 16)
	}, p)
	local children = {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
		}),
		ImageLabel = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(4, 4, 16, 16)
		}),
		IconLabel = 0,
		Title = 0,
		Type = 0,
		Layer = 0
	}
	local v6 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = "rbxassetid://2750909498",
		ImageTransparency = 0.7,
		Position = UDim2.fromScale(0, 0.2),
		Size = UDim2.fromScale(1, 0.6),
		SliceCenter = Rect.new(4, 4, 16, 16),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v10 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		Position = 0,
		ScaleType = 0,
		Size = 0,
		SizeConstraint = 0,
		ZIndex = 0
	}
	local image

	if v.Display.Sprite then
		image = v.Display.Sprite.Image
	end

	v10.Image = image
	local imageRectOffset

	if v.Display.Sprite then
		imageRectOffset = v.Display.Sprite.ImageRectOffset
	end

	v10.ImageRectOffset = imageRectOffset
	local imageRectSize

	if v.Display.Sprite then
		imageRectSize = v.Display.Sprite.ImageRectSize
	end

	v10.ImageRectSize = imageRectSize
	v10.Position = UDim2.fromScale(0.5, 0.5)
	v10.ScaleType = Enum.ScaleType.Fit
	v10.Size = UDim2.fromScale(0.6, 0.525)
	v10.SizeConstraint = Enum.SizeConstraint.RelativeXX
	v10.ZIndex = CONSTANTS.LAYER.RAISED
	local v7 = {
		Icon = createElement("ImageLabel", v10),
		OverlayText = 0,
		CornerIcon = 0
	}
	local overlayText

	if p.OverlayText then
		overlayText = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = rbxassetfontsfamiliesNunitojson,
			Position = UDim2.new(0.5, 0, 0.5, -3),
			Size = UDim2.fromScale(0.9, 1.5),
			Text = p.OverlayText,
			TextColor3 = Color3.fromRGB(255, 238, 0),
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	end

	v7.OverlayText = overlayText
	local cornerIcon

	if v.Display.CornerIcon then
		local v18 = {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0,
			SizeConstraint = 0,
			ZIndex = 0
		}
		local image2

		if v.Display.CornerIcon then
			image2 = v.Display.CornerIcon.Image
		end

		v18.Image = image2
		local imageRectOffset2

		if v.Display.CornerIcon then
			imageRectOffset2 = v.Display.CornerIcon.ImageRectOffset
		end

		v18.ImageRectOffset = imageRectOffset2
		local imageRectSize2

		if v.Display.CornerIcon then
			imageRectSize2 = v.Display.CornerIcon.ImageRectSize
		end

		v18.ImageRectSize = imageRectSize2
		v18.Position = UDim2.new(1, -2, 1, -2)
		v18.ScaleType = Enum.ScaleType.Fit
		v18.Size = UDim2.fromScale(0.25, 1)
		v18.SizeConstraint = Enum.SizeConstraint.RelativeXX
		v18.ZIndex = CONSTANTS.LAYER.RAISED
		cornerIcon = createElement("ImageLabel", v18, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	v7.CornerIcon = cornerIcon
	children.IconLabel = createElement("ImageLabel", v6, v7)
	children.Title = createElement("ImageLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2882228740",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		ImageRectSize = Vector2.new(20, 16),
		LayoutOrder = 1,
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(1, 0.2),
		SliceCenter = Rect.new(4, 4, 16, 16),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XXS
		}),
		ImageLabel = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = Color3.fromRGB(19, 203, 31),
			ImageRectSize = Vector2.new(20, 16),
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			ImageLabel = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageRectSize = Vector2.new(20, 16),
				ImageTransparency = 0.9,
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 0.5),
				SliceCenter = Rect.new(4, 4, 16, 16),
				ZIndex = CONSTANTS.LAYER.RAISED
			})
		}),
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Position = UDim2.fromScale(0, 0.05),
			Size = UDim2.fromScale(1, 0.9),
			Text = v.Display.Title or v.Display.Name or v.Index.StorageKey,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	})
	children.Type = createElement("ImageLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2882228740",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		ImageRectOffset = Vector2.new(0, 4),
		ImageRectSize = Vector2.new(20, 16),
		LayoutOrder = 1,
		Position = UDim2.fromScale(0, 0.8),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(1, 0.2),
		SliceCenter = Rect.new(4, 0, 12, 12),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
		}),
		ImageLabel = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = Color3.fromRGB(255, 0, 234),
			ImageRectOffset = Vector2.new(0, 4),
			ImageRectSize = Vector2.new(20, 16),
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(4, 0, 12, 12),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Position = UDim2.fromScale(0, 0.05),
			Size = UDim2.fromScale(1, 0.9),
			Text = p.TradeItem.Type ~= "PhysicalMoveset" and "Special" or `${FormatUtil.commaInteger(p.TradeItem.Price)}`,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	})
	children.Layer = createElement("ImageLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2750909498",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		ImageTransparency = CONSTANTS.ALPHA.HEAVY,
		Position = UDim2.fromScale(0, 0.2),
		Size = UDim2.fromScale(1, 0.6),
		SliceCenter = Rect.new(4, 4, 16, 16),
		ZIndex = CONSTANTS.LAYER.RAISED
	})
	return createElement("ImageButton", mergeImageButton, children)
end

function tradeAddItem(props)
	print((`serach text: "{props.SearchText}"`))
	local v = {
		GoBack = createElement(tileButton, {
			Text = "<",
			OnClick = function()
				props.OnSelect(nil)
			end,
			LayoutOrder = 0
		}),
		UIGridLayout = createElement("UIGridLayout", {
			CellPadding = UDim2.new(),
			CellSize = UDim2.fromScale(0.492, 0.495),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}
	local v2 = React.useMemo(function()
		local nameToIdMap = {}
		local titles = {}

		for _, item in props.Items do
			local unwrapped = ItemConfig.match(item.ItemId):unwrap()
			local title = unwrapped.Display.Title or unwrapped.Display.Name or unwrapped.Index.StorageKey

			if not nameToIdMap[title] then
				nameToIdMap[title] = {}
			end

			table.insert(nameToIdMap[title], item.ItemId)
			table.insert(titles, title)
		end

		return {
			Names = titles,
			NameToIdMap = nameToIdMap
		}
	end, { props.Items })
	local v3 = React.useMemo(function()
		if props.SearchText then
			return filterSearchResults(v2, props.SearchText)
		end

		return nil
	end, { v2, props.SearchText })
	local count = 0

	for k, item in props.Items do
		if not (not v3 or v3[item.ItemId] == true) then
			continue
		end

		count += 1
		local formatted = `{k}`
		local itemTile2 = itemTile
		local v6 = item
		v[formatted] = createElement(itemTile2, {
			TradeItem = item,
			LayoutOrder = count,
			[React.Event.Activated] = function()
				props.OnSelect(v6.ItemId)
			end
		})
	end

	return createElement("ScrollingFrame", RobloxTypes.mergeScrollingFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderColor3 = Color3.fromRGB(68, 68, 68),
		CanvasSize = UDim2.fromScale(0, math.ceil((count + 1) / 2) * 0.495),
		ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THICK
	}, props), {
		UIPadding = createElement("UIPadding"),
		UIListLayout = createElement("UIListLayout", {
			Padding = UDim.new(0.008, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Frame = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = 2,
			Size = UDim2.new(1, -7, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		}, v)
	})
end

function tradeDisplay(props)
	local openAddMenu

	if props.OnOpenAddFrame then
		openAddMenu = createElement(tileButton, {
			Text = "+",
			LayoutOrder = 5,
			OnClick = function()
				props.OnOpenAddFrame()
			end
		})
	end

	local v = {
		OpenAddMenu = openAddMenu,
		UIGridLayout = createElement("UIGridLayout", {
			CellPadding = UDim2.new(),
			CellSize = UDim2.fromScale(0.495, 0.495),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}

	if props.Offer then
		local count = 0

		for k, item in props.Offer.Items do
			for i = 1, item.Amount do
				count += 1
				local formatted = `{k}-{i}`
				local itemTile2 = itemTile
				local v5 = item
				v[formatted] = createElement(itemTile2, {
					TradeItem = item,
					LayoutOrder = count,
					[React.Event.Activated] = props.OnSelect and function()
						props.OnSelect(v5.ItemId)
					end or nil
				})
			end
		end
	end

	local playerByUserId = Players:GetPlayerByUserId(props.UserId)
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR
	}, props)
	local v7 = {
		AutoLocalize = false,
		BackgroundColor3 = Color3.fromRGB(34, 34, 34),
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = CONSTANTS.FONT.FACE.BODY,
		LayoutOrder = 1,
		Position = UDim2.fromScale(0, -0.1),
		Size = UDim2.new(1, 0, 0.1, -2),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true
	}
	local text

	if playerByUserId then
		text = playerByUserId.DisplayName
	else
		text = `User #{props.UserId}`
	end

	v7.Text = text
	v7.TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	local children = {
		TextLabel = createElement("TextLabel", v7),
		Frame = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = 3,
			Position = UDim2.fromScale(0, 0.1),
			Size = UDim2.fromScale(1, 0.9)
		}, v),
		SearchFrame = 0,
		UIListLayout = 0
	}
	local searchFrame

	if props.OnSearchTextChanged then
		searchFrame = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(34, 34, 34),
			BorderColor3 = Color3.fromRGB(255, 197, 20),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.5, 0.1),
			Size = UDim2.fromScale(1, 0.1)
		}, {
			TextBox = createElement("TextBox", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = font,
				PlaceholderColor3 = Color3.fromRGB(86, 86, 86),
				PlaceholderText = "Search",
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.9, 1),
				Text = props.SearchText or "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				[React.Change.Text] = function(p)
					props.OnSearchTextChanged(p.Text)
				end
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0.2, 0),
					PaddingTop = UDim.new(0.2, 0)
				})
			}),
			ImageLabel = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "http://www.roblox.com/asset/?id=9889498499",
				ImageColor3 = Color3.fromRGB(86, 86, 86),
				Position = UDim2.fromScale(0.01, 0.5),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				SliceScale = 0.5
			})
		})
	end

	children.SearchFrame = searchFrame
	children.UIListLayout = createElement("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = CONSTANTS.SPACING.PADDING.OFFSET.XS,
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	return createElement("Frame", mergeFrame, children)
end

function yellowButton(p)
	return createElement("TextButton", RobloxTypes.mergeTextButton({
		BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderColor3 = Color3.fromRGB(255, 240, 69),
		FontFace = CONSTANTS.FONT.FACE.BODY_LIGHT,
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, p), {
		Trans = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0)
		}),
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY,
			Size = UDim2.fromScale(1, 1),
			Text = p.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	})
end

function tradeScrims(p)
	local fragment = React.Fragment
	local areYouLocked

	if p.AreYouLocked then
		areYouLocked = createElement("TextLabel", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 0.4,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.new(0, 0, 0.15, 1),
			Size = UDim2.new(0.5, 0, 0.85, -4),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 4
		})
	end

	local areTheyLocked

	if p.AreTheyLocked then
		areTheyLocked = createElement("TextLabel", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 0.4,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.new(0.5, 0, 0.15, 1),
			Size = UDim2.new(0.5, 0, 0.85, -4),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 4
		})
	end

	return createElement(fragment, {}, {
		AreYouLocked = areYouLocked,
		AreTheyLocked = areTheyLocked
	})
end

function borderAnimation(p)
	local state, setState = React.useState(2)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local Global = require(game.ReplicatedStorage.Global)

		if Global.updateMusic2 then
			local Global2 = require(game.ReplicatedStorage.Global)
			Global2.updateMusic2(true)
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
			local current = ref.current

			if not current then
				return
			end

			setState(2 + (current.PlaybackLoudness or 0) / 1000 * 88)

			if not current.IsPlaying then
				current:Play()
			end
		end)
		return function()
			local Global2 = require(game.ReplicatedStorage.Global)

			if Global2.updateMusic2 then
				local Global3 = require(game.ReplicatedStorage.Global)
				Global3.updateMusic2(false)
			end

			renderSteppedConnection:Disconnect()
		end
	end, {})
	return createElement("Frame", RobloxTypes.mergeFrame({
		BorderSizePixel = state
	}, p), {
		DripSound = createElement("Sound", {
			ref = ref,
			Looped = true,
			SoundId = "rbxassetid://9165268097",
			Volume = RunService:IsRunning() and 0.85 or 0
		})
	})
end

return function(props)
	local state, setState = React.useState(false)
	local useMemo = React.useMemo

	local function fn()
		if props.Trade and props.Trade.State.Type ~= "NotReady" and state then
			setState(false)
		end
	end

	local v2

	if props.Trade then
		v2 = props.Trade.State.Type == "NotReady"
	else
		v2 = false
	end

	useMemo(fn, { v2, state })
	local v3 = userId and props.Trade and props.Trade.Trader[2] == userId and 2 or 1
	local v4 = v3 == 1 and 2 or 1
	local v5

	if props.Trade and props.Trade.State.Type == "NotReady" then
		v5 = props.Trade.State.Ready[v3]
	else
		v5 = props.Trade and true or false
	end

	local areTheyLocked

	if props.Trade and props.Trade.State.Type == "NotReady" then
		areTheyLocked = props.Trade.State.Ready[v4]
	else
		areTheyLocked = props.Trade and true or false
	end

	local state2, setState2 = React.useState(nil)
	local items = React.useMemo(function()
		if not props.Trade then
			return {}
		end

		local clones = {}

		for _, v8 in props.Owned do
			local item = props.Trade.Offer[v3].Items[tostring(v8.ItemId)]
			local amount

			if item then
				amount = v8.Amount - item.Amount
			else
				amount = v8.Amount
			end

			if amount <= 0 then
				continue
			end

			local clone = table.clone(v8)
			clone.Amount = amount
			table.insert(clones, clone)
		end

		return clones
	end, { props.Owned, props.Trade and props.Trade.Offer[v3] })
	local v8 = React.useMemo(function()
		if not props.Trade then
			return {
				Text = "",
				Total = { 0, 0 }
			}
		end

		local total = 0
		local total2 = 0
		local flag = false

		for _, item in props.Trade.Offer[1].Items do
			for _ = 1, item.Amount do
				if item.Type == "PhysicalMoveset" then
					total2 += item.Price
				else
					total += item.Reducer
					flag = true
				end
			end
		end

		local total3 = 0
		local total4 = 0

		for _, item in props.Trade.Offer[2].Items do
			for _ = 1, item.Amount do
				if item.Type == "PhysicalMoveset" then
					total4 += item.Price
				else
					total3 += item.Reducer
					flag = true
				end
			end
		end

		local v9 = total + total3
		local v10 = 1 - math.min(total2, total4) / math.max(total2, total4, 0.01)
		local text = ("Value difference: " .. math.ceil(v10 * 100) .. "%") .. " (Max. " .. math.min(
			100,
			(math.ceil((v9 + 0.4) * 100))
		) .. "%)"

		if v10 <= v9 + 0.4 then
			if flag then
				text ..= " - Special items are auto-redeemed."
			end

			return {
				Text = text,
				Total = { total2, total4 }
			}
		else
			return {
				Text = text .. " - Value must be around the same.",
				Total = { total2, total4 },
				TextColor = Color3.new(1, 0.1, 0.1)
			}
		end
	end, { props.Trade })
	local total = v8.Total
	local v11 = {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		Position = UDim2.new(0.5, 10, 0.46, 0),
		Size = UDim2.fromScale(0.4, 0.42)
	}
	local children = {
		Title = createElement("TextLabel", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderColor3 = Color3.fromRGB(255, 197, 20),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
			Position = UDim2.fromScale(0, -0.09),
			Size = UDim2.fromScale(1, 0.15),
			Text = "TREASURE TRADE",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}),
		Container = 0,
		Scrims = 0,
		Info = 0,
		UIAspectRatioConstraint = 0,
		UISizeConstraint = 0,
		Countdown = 0,
		Border = 0,
		BottomTitle = 0
	}
	local v14 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0, 0.06),
		Size = UDim2.fromScale(1, 0.94)
	}
	local addItem

	if state and props.Trade and props.Trade.State.Type == "NotReady" and not v5 then
		addItem = createElement(tradeAddItem, {
			OnSelect = function(p: number?)
				setState(false)
				setState2(nil)

				if p then
					props.OnItemAction(p, "Add")
				end
			end,
			SearchText = state2,
			Items = items,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(0.5, 0.78)
		})
	end

	local yourItems

	if props.Trade then
		local tradeDisplay2 = tradeDisplay
		local v19 = {
			UserId = props.Trade.Trader[v3],
			Offer = 0,
			SearchText = 0,
			OnSearchTextChanged = 0,
			OnOpenAddFrame = 0,
			OnSelect = 0,
			Position = 0,
			Size = 0
		}
		local offer

		if not state then
			offer = props.Trade.Offer[v3]
		end

		v19.Offer = offer
		v19.SearchText = state2
		v19.OnSearchTextChanged = state and not v5 and function(value: string?)
			if not (value and value:len() > 0) then
				value = nil
			end

			setState2(value)
		end or nil
		v19.OnOpenAddFrame = not (props.Trade.Offer[v3].SlotsFilled >= 4 or state or v5) and function()
			setState(true)
		end or nil
		v19.OnSelect = not (state or v5) and function(p: number?)
			if p then
				props.OnItemAction(p, "Remove")
			end
		end or nil
		v19.Position = UDim2.fromScale(0, 0)
		v19.Size = UDim2.fromScale(0.5, 1)
		yourItems = createElement(tradeDisplay2, v19)
	end

	local theirItems

	if props.Trade then
		theirItems = createElement(tradeDisplay, {
			UserId = props.Trade.Trader[v4],
			Offer = props.Trade.Offer[v4],
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1)
		})
	end

	children.Container = createElement("Frame", v14, {
		AddItem = addItem,
		YourItems = yourItems,
		TheirItems = theirItems
	})
	local scrims

	if props.Trade then
		scrims = createElement(tradeScrims, {
			AreYouLocked = v5,
			AreTheyLocked = areTheyLocked
		})
	end

	children.Scrims = scrims
	local v22 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.2)
	}
	local yellowButton2 = yellowButton
	local children2 = {
		Accept = createElement(yellowButton2, {
			Position = UDim2.new(0.35, 0, 0, 3),
			Size = UDim2.new(0.3, 0, 0.5, -5),
			Text = "Accept",
			AutoButtonColor = not v5,
			[React.Event.Activated] = not v5 and function()
				if state then
					setState(false)
				end

				props.OnAction("Accept")
			end or nil
		}),
		Cancel = 0,
		AreYouReady = 0,
		OurValue = 0,
		AreTheyReady = 0,
		TheirValue = 0
	}
	local yellowButton3 = yellowButton
	children2.Cancel = createElement(yellowButton3, {
		Position = UDim2.new(0.35, 0, 0.5, 2),
		Size = UDim2.new(0.3, 0, 0.5, -5),
		Text = "Cancel",
		AutoButtonColor = v5,
		[React.Event.Activated] = v5 and function()
			if state then
				setState(false)
			end

			props.OnAction("Cancel")
		end or nil
	})
	local v29 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
		Position = UDim2.fromOffset(6, 3),
		Size = UDim2.new(0.2, 0, 0.5, -6),
		Text = v5 and "Ready!" or "Not ready",
		TextColor3 = 0,
		TextScaled = true,
		TextXAlignment = 0
	}
	local textColor

	if v5 then
		textColor = Color3.new(0.25, 1, 0.25)
	else
		textColor = CONSTANTS.COLOR.PALETTE.WHITE
	end

	v29.TextColor3 = textColor
	v29.TextXAlignment = Enum.TextXAlignment.Left
	children2.AreYouReady = createElement("TextLabel", v29)
	children2.OurValue = createElement("TextLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
		Position = UDim2.new(0, 6, 0.5, 3),
		Size = UDim2.new(0.4, 0, 0.5, -6),
		Text = `Value: ${FormatUtil.commaInteger(total[v3])}`,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local v33 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
		Position = UDim2.new(0.8, -6, 0, 3),
		Size = UDim2.new(0.2, 0, 0.5, -6),
		Text = areTheyLocked and "Ready!" or "Not ready",
		TextColor3 = 0,
		TextScaled = true,
		TextXAlignment = 0
	}
	local textColor2

	if areTheyLocked then
		textColor2 = Color3.new(0.25, 1, 0.25)
	else
		textColor2 = CONSTANTS.COLOR.PALETTE.WHITE
	end

	v33.TextColor3 = textColor2
	v33.TextXAlignment = Enum.TextXAlignment.Right
	children2.AreTheyReady = createElement("TextLabel", v33)
	children2.TheirValue = createElement("TextLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
		Position = UDim2.new(0.6, -6, 0.5, 3),
		Size = UDim2.new(0.4, 0, 0.5, -6),
		Text = `Value: ${FormatUtil.commaInteger(total[v4])}`,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	children.Info = createElement("Frame", v22, children2)
	children.UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 1.8,
		AspectType = Enum.AspectType.ScaleWithParentSize,
		DominantAxis = Enum.DominantAxis.Height
	})
	children.UISizeConstraint = createElement("UISizeConstraint", {
		MaxSize = Vector2.new(600, 600)
	})
	local countdown2

	if props.Trade and props.Trade.State.Type == "Countdown" then
		countdown2 = createElement(countdown, {
			TradeAt = DateTime.fromUnixTimestamp(props.Trade.State.StartTime.UnixTimestamp + 10)
		})
	end

	children.Countdown = countdown2
	children.Border = createElement(borderAnimation, {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		Position = UDim2.fromScale(0, -0.09),
		Size = UDim2.fromScale(1, 1.4),
		ZIndex = CONSTANTS.LAYER.BASE
	})
	children.BottomTitle = createElement("TextLabel", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
		Position = UDim2.new(0, 0, 1.2, 2),
		Size = UDim2.fromScale(1, 0.1),
		Text = v8.Text,
		TextColor3 = v8.TextColor or CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true
	})
	return createElement("Frame", v11, children)
end