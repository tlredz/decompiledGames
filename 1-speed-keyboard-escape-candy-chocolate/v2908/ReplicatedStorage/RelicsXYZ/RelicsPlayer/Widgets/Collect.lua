local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local Enums = require(parent.Enums)
local State = require(parent.State)
local Util = require(parent.Util)
local React = require(shared.React)
local Bundles = require(shared.Bundles)
local Promise = require(shared.Promise)
local Ownership = require(shared.Ownership)
require(shared.GamePasses)
local Marketplace = require(shared.Marketplace)
local components = parent.Components
local Button = require(components.Button)
local TextButton = require(components.TextButton)
local CollectFlow = require(components.CollectFlow)
local BoomboxPreview = require(components.BoomboxPreview)
local EmotePreview = require(components.EmotePreview)
local GamePassItem = require(components.GamePassItem)
local SongList = require(components.SongList)
local Upsell = require(components.Upsell)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local useOwnership = require(hooks.useOwnership)
local usePlaylists = require(hooks.usePlaylists)
local useGamePasses = require(hooks.useGamePasses)
local useStyleSheet = require(hooks.useStyleSheet)
local useActiveBundle = require(hooks.useActiveBundle)
local v = {}
local v2 = utf8.char(57346)

function v.Auras(props)
	local v3 = useStyleSheet("Palette", "Color3")
	local v4 = useStyleSheet("Icons", "string")
	local v5 = useGamePasses({
		AssetType = "AURA",
		Featured = true
	})
	local v6 = React.useContext(State.Context)

	if not v6.Features.Auras then
		v6.WidgetReturn()
		return nil
	end

	local v7 = false
	local nodes = {}

	for _, gamePass in v5 do
		if not gamePass.IsActive or v7 then
			continue
		end

		table.insert(nodes, {
			Type = "GamePass",
			GamePass = gamePass,
			NoStencil = true
		})
		break
	end

	local v9 = {
		Title = "BUY AURAS",
		Type = "FlowItem",
		Image = v4("$Image-CollectButton-BuyAuras"),
		ForegroundImage = v4("$Image-CollectButton-BuyAurasForeground"),
		ForegroundImageScale = 0.9,
		StrokeColor = Color3.fromHex("#68C2B3"),
		Widget = require(components.GridAuras),
		BackgroundColor = v3("Color-Collection-Auras")
	}
	table.insert(nodes, v9)
	local flag = true

	for _, gamePass in v5 do
		if not (gamePass.IsActive and gamePass.RelicsAssetType == "AURA") then
			continue
		end

		if flag then
			flag = false
		else
			table.insert(nodes, {
				Type = "GamePass",
				GamePass = gamePass,
				NoStencil = true
			})
		end
	end

	local v10 = {
		Title = "ROLL FOR AURAS",
		Type = "FlowItem",
		Image = v4("$Image-CollectButton-RollAuras"),
		ForegroundImage = v4("$Image-CollectButton-RollAurasForeground"),
		ForegroundImageScale = 0.6,
		StrokeColor = Color3.fromHex("#68C2B3"),
		Widget = require(components.RollForAuras),
		BackgroundColor = v3("Color-Collection-Auras")
	}
	table.insert(nodes, v10)
	return React.createElement(CollectFlow, {
		[React.Tag] = "ofStartCollectPage ofCollectFlow ofPlaylistsFlow",
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Nodes = nodes
	})
end

function v.Cosmetics(props)
	local v3 = useStyleSheet("Palette", "Color3")
	local v4 = useStyleSheet("Icons", "string")
	local v5 = useGamePasses({
		AssetType = "SKIN",
		Featured = true
	})
	local v6 = React.useContext(State.Context)

	if not v6.Features.Skins then
		v6.WidgetReturn()
		return nil
	end

	local v7 = {}
	local nodes = {}

	for _, v9 in v5 do
		if v9.IsActive and v9.RelicsAssetType == "SKIN" then
			table.insert(v7, v9)
		end
	end

	table.sort(v7, function(a, b)
		local sortOrder = tonumber(a.SortOrder) or 1e999
		local sortOrder2 = tonumber(b.SortOrder) or 1e999

		if sortOrder ~= sortOrder2 then
			return sortOrder < sortOrder2
		end

		local v9 = not a.StartDate and 0 or a.StartDate.UnixTimestamp or 0
		local v10 = not b.StartDate and 0 or b.StartDate.UnixTimestamp or 0

		if v9 == v10 then
			return (a.Name or "") < (b.Name or "")
		end

		return v10 < v9
	end)
	local count = #v7

	if count >= 1 then
		table.insert(nodes, {
			Type = "GamePass",
			GamePass = v7[1],
			OverrideBackgroundImage = v4("Image-CategoryBackgrounds-SkinsDropdown")
		})
	end

	local v9 = {
		Title = "BUY SKINS",
		Type = "FlowItem",
		GamePass = v7[2],
		Image = v4("$Image-CollectButton-BuySkins"),
		StrokeColor = Color3.fromHex("#7B19DB"),
		Render = function(props2)
			local createElement = React.createElement
			local skin

			if v7[2] then
				skin = v7[2].Name
			end

			return createElement(BoomboxPreview, {
				Skin = skin,
				Size = props2.Size,
				Position = props2.Position,
				AnchorPoint = props2.AnchorPoint,
				ViewportScale = 0.75
			})
		end,
		Widget = require(components.GridSkins),
		BackgroundColor = v3("Color-Collection-Cosmetics")
	}
	table.insert(nodes, v9)

	if count > 2 then
		for i = 3, count do
			table.insert(nodes, {
				Type = "GamePass",
				GamePass = v7[i],
				OverrideBackgroundImage = v4("Image-CategoryBackground-SkinsDropdown")
			})
		end
	end

	return React.createElement("Frame", {
		[React.Tag] = "StartCollectCosmeticsContainer"
	}, {
		Cosmetics = React.createElement(CollectFlow, {
			[React.Tag] = "ofStartCollectPage ofCollectFlow ofPlaylistsFlow",
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			Nodes = nodes
		})
	})
end

function v.Playlists(_)
	local v3 = React.useContext(State.Context)
	local v4 = v3.Status == Enums.UserStatus.BoomboxPurchased
	local v5 = useStyleSheet("Palette", "Color3")
	local features = v3.Features
	local v6 = usePlaylists()
	local v7 = useGamePasses({
		AssetType = "PLAYLIST"
	})
	local v8 = v3.Status == Enums.UserStatus.BoomboxPurchased
	local nodes = {}

	for _, playlist in v6 do
		local sortPrioritiesById = {}
		local songs = {}

		for _, song in playlist.Songs do
			sortPrioritiesById[song.Id] = song.SortPriority or 1e999
			table.insert(songs, {
				Id = song.Id,
				PlaylistName = playlist.Name
			})
		end

		table.sort(songs, function(a, b)
			return sortPrioritiesById[a.Id] < sortPrioritiesById[b.Id]
		end)
		local productId = playlist.ProductId
		local gamePass = nil

		for _, v15 in v7 do
			if not (v15.RelicsAssetType == "PLAYLIST" and (v15.Id == playlist.LimitedInfo or productId and v15.ProductId == productId or v15.Name:lower() == playlist.Name:lower())) then
				continue
			end

			gamePass = v15
			break
		end

		if gamePass then
			if v8 then
				table.insert(nodes, {
					Type = "GamePass",
					GamePass = gamePass,
					NoStencil = true,
					ColorCoded = true
				})
			end
		else
			local productId2 = playlist.ProductId

			if not productId2 or not (productId2 > 0) or v8 then
				v4 = playlist.IsIncluded and v8 and true or v4
				local v15 = playlist
				local songs2 = songs
				local v17 = {
					Type = "FlowItem",
					Image = playlist.Image,
					Title = playlist.Name:upper(),
					StrokeColor = v5("Color-Collection-Playlists"),
					NoTextStroke = true,
					Playlist = playlist,
					Widget = function()
						local isFree = v15.IsFree
						local isIncluded = v15.IsIncluded
						local v18 = React.useContext(State.Context).Status == Enums.UserStatus.BoomboxPurchased
						return React.createElement(SongList, {
							Songs = songs2,
							SampleMode = not (v4 or isFree or isIncluded and v18)
						})
					end
				}

				if playlist.IsFree then
					table.insert(nodes, 1, v17)
				else
					table.insert(nodes, v17)
				end
			end
		end
	end

	if not features.Playlists then
		v3.WidgetReturn()
		return nil
	end

	local createElement = React.createElement
	local v11 = {
		[React.Tag] = "StartCollectPlaylistsContainer"
	}
	local upsell

	if not v4 then
		upsell = React.createElement(Upsell, {
			[React.Tag] = "ofStartCollectPage ofPlaylistsFlow"
		}, {})
	end

	return createElement("Frame", v11, {
		Upsell = upsell,
		Playlists = React.createElement(CollectFlow, {
			[React.Tag] = Util.ClassNames("ofStartCollectPage", "ofCollectFlow", "ofPlaylistsFlow", "isCollectPlaylist"),
			Nodes = nodes,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			FillDirection = Enum.FillDirection.Horizontal,
			Position = UDim2.fromScale(0.5, 0.5),
			LayoutOrder = 1
		})
	})
end

function v.Dances(props)
	local v3 = useStyleSheet("Palette", "Color3")
	local v4 = useStyleSheet("Icons", "string")
	local v5 = React.useContext(State.Context)
	local features = v5.Features
	local v6 = useGamePasses({
		AssetType = "EMOTE",
		Featured = true
	})

	if not features.Emotes then
		v5.WidgetReturn()
		return nil
	end

	local v7 = {}
	local nodes = {}

	for _, v9 in v6 do
		table.insert(v7, v9)
	end

	if #v7 >= 1 then
		table.insert(nodes, {
			Type = "GamePass",
			GamePass = v7[1],
			OverrideBackgroundImage = v4("Image-CategoryBackground-DancesFirst"),
			NoStencil = true,
			ColorCoded = true,
			ColorCodedPadding = 0.08
		})
	end

	local v9 = {
		Type = "FlowItem",
		Title = "BUY DANCES",
		Image = v4("$Image-CollectButton-BuyDances"),
		BackgroundColor = v3("Color-Collection-Dances"),
		StrokeThickness = 3,
		StrokeColor = Color3.fromHex("#FA4AF8"),
		Render = function(props2)
			local createElement = React.createElement
			local emote

			if v7[2] then
				emote = v7[2].Content
			end

			return createElement(EmotePreview, {
				Emote = emote,
				Size = props2.Size,
				Position = props2.Position,
				AnchorPoint = props2.AnchorPoint,
				ViewportScale = 0.75
			})
		end,
		Widget = require(components.GridEmotes)
	}
	table.insert(nodes, v9)

	for i = 3, #v7 do
		table.insert(nodes, {
			Type = "GamePass",
			GamePass = v7[i],
			OverrideBackgroundImage = v4("Image-CategoryBackground-DancesDefault"),
			NoStencil = true,
			ColorCoded = true,
			ColorCodedPadding = 0.08
		})
	end

	return React.createElement(CollectFlow, {
		[React.Tag] = "ofStartCollectPage ofCollectFlow ofPlaylistsFlow",
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Nodes = nodes
	})
end

local function CollectPage(props)
	local v3 = React.useContext(State.Context)
	return React.createElement(React.Fragment, {}, {
		Header = React.createElement(Button, {
			[React.Tag] = "CollectHeaderButton",
			OnActivated = function()
				v3.SetWidget(props.Return)
			end,
			HoverScale = 1.01,
			PressScale = 0.99
		}, {
			Back = React.createElement("ImageLabel", {
				[React.Tag] = "BackIcon"
			}, {
				Text = React.createElement("TextLabel", {
					Text = props.Header
				})
			})
		}),
		Body = React.createElement(props.Body, {
			[React.Tag] = "ofStartCollectPage",
			Size = UDim2.fromScale(1, 0.8),
			Position = UDim2.fromScale(0, 0.2),
			AnchorPoint = Vector2.zero
		})
	})
end

local function BundleBody(props)
	local v3 = useStyleSheet("Icons", "string")
	local bundleItems = props.BundleItems
	local assetId = props.AssetId
	local state, setState = React.useState(0)
	local state2, setState2 = React.useState(0)
	local state3, setState3 = React.useState()
	React.useEffect(function()
		if assetId then
			local v4 = Marketplace.GetProductInfo(assetId, Enum.InfoType.Asset, true):andThen(setState3)
			return function()
				v4:cancel()
			end
		else
			setState3(nil)
		end
	end, { assetId })
	local children = {}
	local productInfos = {}

	for i = 1, #bundleItems do
		local bundleItem = bundleItems[i]
		local overrideBackgroundImage = nil

		if bundleItem.RelicsAssetType == "SKIN" then
			overrideBackgroundImage = v3("Image-CategoryBackground-SkinsCollect")
		elseif bundleItem.RelicsAssetType ~= "AURAS" and bundleItem.RelicsAssetType ~= "PLAYLIST" then
			overrideBackgroundImage = v3("Image-CategoryBackground-FeaturedSecond")

			if i == 1 then
				overrideBackgroundImage = v3("Image-CategoryBackground-FeaturedFirst")
			elseif i == 2 then
				overrideBackgroundImage = v3("Image-CategoryBackground-FeaturedSecond")
			end
		end

		local productId = bundleItem.ProductId
		local productType = bundleItem.ProductType
		local productInfo = Marketplace.GetProductInfo(productId, productType, true)
		local id = bundleItem.Id
		children[id] = React.createElement(GamePassItem, {
			[React.Tag] = "ofCollectPage",
			GamePass = bundleItem,
			LayoutOrder = i,
			Compact = false,
			Vertical = true,
			ShowCategoryBadge = true,
			OverrideBackgroundImage = overrideBackgroundImage,
			ColorCoded = true
		})
		table.insert(productInfos, productInfo)
	end

	React.useEffect(function()
		local v4 = Promise.allSettled(productInfos):andThen(function()
			local total = 0
			local count = 0

			for _, v5 in productInfos do
				local v6, v7 = v5:await()

				if not v6 then
					continue
				end

				total += v7.PriceInRobux
				count += 1
			end

			setState(total)
			setState2(count)
		end)
		return function()
			v4:cancel()
		end
	end, { bundleItems })
	local textColor, v5 = React.useBinding(Color3.new(1, 0, 0))
	local priceInRobux = state3 and state3.PriceInRobux or 0
	local v6 = priceInRobux > 0 and priceInRobux or "..."
	local v7 = (not (state > 0) or #bundleItems ~= state2 or not state) and "..." or state
	local text = (v7 == "..." or v6 == "...") and "<font color=\"#7F7F7F\">(Loading Price...)</font>" or `<s><font color="#7F7F7F">{v2}{v7}</font></s> {v2}{v6}`
	useClock(30, function()
		local v9 = os.clock() / 2
		v5((Color3.fromHSV(v9 % 1, 1, 1)))
	end)
	local createElement = React.createElement
	local v10 = {
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = 1
	}
	local assetId2 = props.AssetId

	if assetId2 then
		assetId2 = React.createElement("Folder", {}, {
			SafeZone = React.createElement("Frame", {
				[React.Tag] = "CollectHeaderSafeZone"
			}, {
				Discount = React.createElement("TextLabel", {
					Text = text,
					TextColor3 = textColor,
					[React.Tag] = "CollectHeaderDiscountLabel"
				}),
				BuyButton = React.createElement(Button, {
					[React.Tag] = "UpsellBuyButton",
					Size = UDim2.fromScale(0.75, 0.3),
					OnActivated = function()
						Marketplace.PromptPurchase(props.AssetId)
					end
				}, {
					Text = React.createElement("TextLabel", {
						Text = "BUY",
						[React.Tag] = "UpsellBuyButtonLabel"
					})
				})
			})
		})
	end

	return createElement("Frame", v10, children, {
		NoList = assetId2,
		List = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8)
		}),
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8)
		})
	})
end

local function Collect(_)
	local v3 = useStyleSheet("Palette", "Color3")
	local v4 = useStyleSheet("Icons", "string")
	local v5 = React.useContext(State.Context)
	local v6 = useGamePasses()
	local widget = v5.Widget
	local context = widget and widget.Context
	local textColor, v8 = React.useBinding(Color3.fromHSV(1, 1, 1))
	local v9 = usePlaylists({
		IncludeInactiveUnowned = true
	})
	local state, setState = React.useState({})
	local features = v5.Features
	React.useEffect(function()
		local v10 = {}

		if features.Emotes then
			table.insert(v10, "Dances")
		end

		if features.Playlists then
			table.insert(v10, "Playlists")
		end

		if features.Skins then
			table.insert(v10, "Cosmetics")
		end

		if features.Auras then
			table.insert(v10, "Auras")
		end

		setState(v10)
	end, { features })
	local children = {}
	local children2 = {}
	local v10 = useActiveBundle()
	local v11 = useGamePasses()
	local v12 = React.useMemo(function()
		local result = {}

		for _, v13 in v11 do
			result[v13.ProductId] = v13
		end

		return result
	end, { v11 })
	local v13 = React.useMemo(function()
		if v10 then
			return v10.Type == "LastItemLocked"
		end

		return false
	end, { v10 })
	useClock(30, function()
		local v14 = os.clock() / 2 % 1
		v8(Color3.fromHSV(v14, 1, 1))
	end)
	local v14 = React.useCallback(function(p)
		if not p then
			return {}
		end

		local clone = table.clone(p.Items)
		table.sort(clone, function(a, b)
			return (a.Sort or 1e999) < (b.Sort or 1e999)
		end)
		local assetId = p.AssetId
		local result = {}

		for _, v15 in ipairs(clone) do
			local assetId2 = Bundles.ResolveAssetId(v15)
			local id = assetId2 and assetId2.Id

			if id == assetId then
				continue
			end

			local v16 = assetId2 and v12[id]

			if not v16 then
				continue
			end

			local relicsAssetType = v16.RelicsAssetType
			local auras

			if relicsAssetType == "AURA" then
				auras = features.Auras
			elseif relicsAssetType == "SKIN" then
				auras = features.Skins
			elseif relicsAssetType == "EMOTE" then
				auras = features.Emotes
			else
				auras = relicsAssetType ~= "PLAYLIST" or features.Playlists
			end

			if auras then
				table.insert(result, v16)
			end
		end

		local v15 = v12[p.AssetId]

		if v15 then
			table.insert(result, v15)
		end

		return result
	end, { v12, features })
	local bundleItems = React.useMemo(function()
		return v14(v10)
	end, { v10, v12, features })
	local assetId

	if v10 then
		assetId = v10.AssetId or nil
	else
		assetId = nil
	end

	local v16 = React.useMemo(function()
		local result = {}
		local v17 = {}
		local v18 = {}

		if v10 then
			local v19 = v14(v10)

			for _, v20 in v19 do
				v18[v20.ProductId] = true
			end
		end

		local v19 = {}

		for _, v20 in v6 do
			if v20.IsActive == false or v18[v20.ProductId] or not (not assetId or v20.ProductId ~= assetId) or not v20.IsFeatured then
				continue
			end

			local relicsAssetType = v20.RelicsAssetType
			local playlists = relicsAssetType == "PLAYLIST" and features.Playlists or relicsAssetType == "EMOTE" and features.Emotes or relicsAssetType == "AURA" and features.Auras

			if not playlists then
				if relicsAssetType == "SKIN" then
					playlists = features.Skins
				else
					playlists = false
				end
			end

			if playlists then
				table.insert(v19, v20)
			end
		end

		table.sort(v19, function(a, b)
			return (a.SortOrder or 0) < (b.SortOrder or 0)
		end)

		for _, v20 in v19 do
			table.insert(result, v20)
			v17[v20.ProductId] = true
		end

		if not v10 then
			return result
		end

		local v20 = v14(v10)

		for _, v21 in v20 do
			if v21.ProductId == assetId or not v21.IsFeatured or v17[v21.ProductId] then
				continue
			end

			table.insert(result, v21)
			v17[v21.ProductId] = true
		end

		return result
	end, {
		features,
		v6,
		v10,
		v12,
		assetId
	})
	local v17 = React.useMemo(function()
		local records = {}

		for _, v19 in bundleItems do
			Ownership.Get(v19, records, v19.Id)
		end

		return {
			Records = records,
			AutoOwnedCount = 0
		}
	end, { bundleItems, v9 })
	local count = #bundleItems
	local count2 = #v16
	local body = React.useCallback(function(props, _)
		local createElement = React.createElement
		local v20 = {
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			AssetId = 0,
			BundleItems = 0
		}
		local assetId2

		if not v13 then
			assetId2 = assetId
		end

		v20.AssetId = assetId2
		v20.BundleItems = bundleItems
		return createElement(BundleBody, v20)
	end, { bundleItems })

	for k, gamePass in v16 do
		local overrideBackgroundImage = nil
		local disabledOverlay = assetId and gamePass.ProductId == assetId

		if disabledOverlay then
			overrideBackgroundImage = "rbxassetid://132855273143799"
		elseif gamePass.RelicsAssetType == "SKIN" then
			overrideBackgroundImage = v4("Image-CategoryBackground-SkinsCollect")
		elseif gamePass.RelicsAssetType == "EMOTE" then
			overrideBackgroundImage = v4("Image-CategoryBackground-FeaturedSecond")

			if k == 1 then
				overrideBackgroundImage = v4("Image-CategoryBackground-FeaturedFirst")
			elseif k == 2 then
				overrideBackgroundImage = v4("Image-CategoryBackground-FeaturedSecond")
			end
		end

		local v22 = "Item" .. tostring(k)
		children2[v22] = React.createElement(GamePassItem, {
			[React.Tag] = "ofCollectPage",
			GamePass = gamePass,
			LayoutOrder = k,
			Compact = count2 > 4,
			NoStencil = true,
			ColorCoded = true,
			OverrideBackgroundImage = overrideBackgroundImage,
			ColorCodedPadding = 0.125,
			DisabledOverlay = disabledOverlay
		})
	end

	local _, v19 = useOwnership(v17.Records)
	local v20 = v19 + v17.AutoOwnedCount

	for k, text in pairs(state) do
		local backgroundColor = v3((`Color-Collection-{text}`)) or v3("Color-BLACK")
		local createElement = React.createElement
		local v24 = {
			[React.Tag] = Util.ClassNames("StartCollectingButton", (`is{text}`)),
			Text = text,
			BackgroundColor3 = backgroundColor,
			LayoutOrder = k,
			HoverScale = 1.025,
			PressScale = 0.9,
			Flex = {
				FlexMode = Enum.UIFlexMode.Fill
			}
		}
		local v25 = text

		function v24.OnActivated()
			local v26 = assert(v5.Widget)
			local body2 = v[v25]

			if body2 then
				v5.SetWidget({
					ReturnFunc = function()
						v5.SetWidget(v26)
					end,
					Widget = function()
						return React.createElement(CollectPage, {
							Header = `COLLECT {v25:upper()}`,
							Return = v26,
							Body = body2
						})
					end
				})
			else
				warn("[RelicsPlayer] No widget found for collection:", v25)
			end
		end

		children[text] = createElement(TextButton, v24)
	end

	local collected

	if v10 == nil then
		collected = false
	else
		collected = count > 0
	end

	local items = count2 > 0
	local itemHeader = collected or items
	local onActivated = React.useCallback(function()
		local v25 = assert(v5.Widget)
		local name = v10 and v10.Name or "FEATURE BUNDLE"

		if v25.Context == "OpenBundle" then
			v25.Context = nil
		end

		v5.SetWidget({
			ReturnFunc = function()
				v5.SetWidget(v25)
			end,
			Widget = function()
				return React.createElement(CollectPage, {
					Header = name:upper(),
					Return = v25,
					Body = body
				})
			end
		})
	end, { v5, v10, body })

	if context == "OpenBundle" and v10 then
		onActivated()
	elseif v[context] then
		local v25 = assert(v5.Widget)
		local body2 = v[context]
		v5.SetWidget({
			ReturnFunc = function()
				v5.SetWidget(v25)
			end,
			Widget = function()
				return React.createElement(CollectPage, {
					Header = `COLLECT {context:upper()}`,
					Return = v25,
					Body = body2
				})
			end
		})
		v25.Context = nil
	end

	local createElement = React.createElement
	local v26 = {
		[React.Tag] = "CollectPageContainer"
	}
	local children3 = {
		StartCollecting = React.createElement("TextLabel", {
			[React.Tag] = "StartCollectingHeader"
		}),
		CategoryButtons = React.createElement("Frame", {
			[React.Tag] = Util.ClassNames(
				"StartCollectingButtonsContainer",
				#state > 2 and "isVertical" or "isHorizonal"
			)
		}, children),
		ItemHeader = 0,
		Items = 0
	}

	if itemHeader then
		local createElement4 = React.createElement
		local v30 = {
			[React.Tag] = "FeaturedItemsHeader"
		}

		if collected then
			collected = React.createElement(Button, {
				[React.Tag] = "ItemsCollectedButton",
				OnActivated = onActivated,
				HoverScale = 1.02,
				PressScale = 0.98
			}, {
				Text = React.createElement("TextLabel", {
					Text = "<b>" .. (v10 and v10.Name:upper() or "FEATURE BUNDLE") .. "</b> >" .. (not v13 and "" or `\n<font size="8">({v20}/{count} COLLECTED)      </font>`),
					RichText = true,
					TextColor3 = textColor
				})
			})
		end

		itemHeader = createElement4("TextLabel", v30, {
			Collected = collected
		})
	end

	children3.ItemHeader = itemHeader

	if items then
		items = React.createElement("Frame", {
			[React.Tag] = "FeaturedItemsButtonsContainer"
		}, children2)
	end

	children3.Items = items
	return createElement("Frame", v26, children3)
end

return Collect