local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local Enums = require(parent.Enums)
local State = require(parent.State)
local Util = require(parent.Util)
local React = require(shared.React)
local Bundles = require(shared.Bundles)
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
local v = {
	Auras = function(props)
		local v2 = useStyleSheet("Palette", "Color3")
		local v3 = useStyleSheet("Icons", "string")
		local v4 = useGamePasses({
			AssetType = "AURA",
			Featured = true
		})
		local v5 = React.useContext(State.Context)

		if not v5.Features.Auras then
			v5.WidgetReturn()
			return nil
		end

		local v6 = false
		local nodes = {}

		for _, gamePass in v4 do
			if not gamePass.IsActive or v6 then
				continue
			end

			table.insert(nodes, {
				Type = "GamePass",
				GamePass = gamePass,
				NoStencil = true
			})
			break
		end

		local v8 = {
			Title = "BUY AURAS",
			Type = "FlowItem",
			Image = v3("$Image-CollectButton-BuyAuras"),
			ForegroundImage = v3("$Image-CollectButton-BuyAurasForeground"),
			ForegroundImageScale = 0.9,
			StrokeColor = Color3.fromHex("#68C2B3"),
			Widget = require(components.GridAuras),
			BackgroundColor = v2("Color-Collection-Auras")
		}
		table.insert(nodes, v8)
		local flag = true

		for _, gamePass in v4 do
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

		local v9 = {
			Title = "ROLL FOR AURAS",
			Type = "FlowItem",
			Image = v3("$Image-CollectButton-RollAuras"),
			ForegroundImage = v3("$Image-CollectButton-RollAurasForeground"),
			ForegroundImageScale = 0.6,
			StrokeColor = Color3.fromHex("#68C2B3"),
			Widget = require(components.RollForAuras),
			BackgroundColor = v2("Color-Collection-Auras")
		}
		table.insert(nodes, v9)
		return React.createElement(CollectFlow, {
			[React.Tag] = "ofStartCollectPage ofCollectFlow ofPlaylistsFlow",
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			Nodes = nodes
		})
	end,
	Cosmetics = function(props)
		local v2 = useStyleSheet("Palette", "Color3")
		local v3 = useStyleSheet("Icons", "string")
		local v4 = useGamePasses({
			AssetType = "SKIN",
			Featured = true
		})
		local v5 = React.useContext(State.Context)

		if not v5.Features.Skins then
			v5.WidgetReturn()
			return nil
		end

		local v6 = {}
		local nodes = {}

		for _, v8 in v4 do
			if v8.IsActive and v8.RelicsAssetType == "SKIN" then
				table.insert(v6, v8)
			end
		end

		table.sort(v6, function(a, b)
			local sortOrder = tonumber(a.SortOrder) or 1e999
			local sortOrder2 = tonumber(b.SortOrder) or 1e999

			if sortOrder ~= sortOrder2 then
				return sortOrder < sortOrder2
			end

			local v8 = not a.StartDate and 0 or a.StartDate.UnixTimestamp or 0
			local v9 = not b.StartDate and 0 or b.StartDate.UnixTimestamp or 0

			if v8 == v9 then
				return (a.Name or "") < (b.Name or "")
			end

			return v9 < v8
		end)
		local count = #v6

		if count >= 1 then
			table.insert(nodes, {
				Type = "GamePass",
				GamePass = v6[1],
				OverrideBackgroundImage = v3("Image-CategoryBackgrounds-SkinsDropdown")
			})
		end

		local v8 = {
			Title = "BUY SKINS",
			Type = "FlowItem",
			GamePass = v6[2],
			Image = v3("$Image-CollectButton-BuySkins"),
			StrokeColor = Color3.fromHex("#7B19DB"),
			Render = function(props2)
				local createElement = React.createElement
				local skin

				if v6[2] then
					skin = v6[2].Name
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
			BackgroundColor = v2("Color-Collection-Cosmetics")
		}
		table.insert(nodes, v8)

		if count > 2 then
			for i = 3, count do
				table.insert(nodes, {
					Type = "GamePass",
					GamePass = v6[i],
					OverrideBackgroundImage = v3("Image-CategoryBackground-SkinsDropdown")
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
	end,
	Playlists = function(_)
		local v2 = React.useContext(State.Context)
		local v3 = v2.Status == Enums.UserStatus.BoomboxPurchased
		local v4 = useStyleSheet("Palette", "Color3")
		local features = v2.Features
		local v5 = usePlaylists()
		local v6 = useGamePasses({
			AssetType = "PLAYLIST"
		})
		local v7 = v2.Status == Enums.UserStatus.BoomboxPurchased
		local nodes = {}

		for _, playlist in v5 do
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

			for _, v14 in v6 do
				if not (v14.RelicsAssetType == "PLAYLIST" and (v14.Id == playlist.LimitedInfo or productId and v14.ProductId == productId or v14.Name:lower() == playlist.Name:lower())) then
					continue
				end

				gamePass = v14
				break
			end

			if gamePass then
				if v7 then
					table.insert(nodes, {
						Type = "GamePass",
						GamePass = gamePass,
						NoStencil = true,
						ColorCoded = true
					})
				end
			else
				local productId2 = playlist.ProductId

				if not productId2 or not (productId2 > 0) or v7 then
					v3 = playlist.IsIncluded and v7 and true or v3
					local v14 = playlist
					local songs2 = songs
					local v16 = {
						Type = "FlowItem",
						Image = playlist.Image,
						Title = playlist.Name:upper(),
						StrokeColor = v4("Color-Collection-Playlists"),
						NoTextStroke = true,
						Playlist = playlist,
						Widget = function()
							local isFree = v14.IsFree
							local isIncluded = v14.IsIncluded
							local v17 = React.useContext(State.Context).Status == Enums.UserStatus.BoomboxPurchased
							return React.createElement(SongList, {
								Songs = songs2,
								SampleMode = not (v3 or isFree or isIncluded and v17)
							})
						end
					}

					if playlist.IsFree then
						table.insert(nodes, 1, v16)
					else
						table.insert(nodes, v16)
					end
				end
			end
		end

		if not features.Playlists then
			v2.WidgetReturn()
			return nil
		end

		local createElement = React.createElement
		local v10 = {
			[React.Tag] = "StartCollectPlaylistsContainer"
		}
		local upsell

		if not v3 then
			upsell = React.createElement(Upsell, {
				[React.Tag] = "ofStartCollectPage ofPlaylistsFlow"
			}, {})
		end

		return createElement("Frame", v10, {
			Upsell = upsell,
			Playlists = React.createElement(CollectFlow, {
				[React.Tag] = Util.ClassNames(
					"ofStartCollectPage",
					"ofCollectFlow",
					"ofPlaylistsFlow",
					"isCollectPlaylist"
				),
				Nodes = nodes,
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				FillDirection = Enum.FillDirection.Horizontal,
				Position = UDim2.fromScale(0.5, 0.5),
				LayoutOrder = 1
			})
		})
	end,
	Dances = function(props)
		local v2 = useStyleSheet("Palette", "Color3")
		local v3 = useStyleSheet("Icons", "string")
		local v4 = React.useContext(State.Context)
		local features = v4.Features
		local v5 = useGamePasses({
			AssetType = "EMOTE",
			Featured = true
		})

		if not features.Emotes then
			v4.WidgetReturn()
			return nil
		end

		local v6 = {}
		local nodes = {}

		for _, v8 in v5 do
			table.insert(v6, v8)
		end

		if #v6 >= 1 then
			table.insert(nodes, {
				Type = "GamePass",
				GamePass = v6[1],
				OverrideBackgroundImage = v3("Image-CategoryBackground-DancesFirst"),
				NoStencil = true,
				ColorCoded = true,
				ColorCodedPadding = 0.08
			})
		end

		local v8 = {
			Type = "FlowItem",
			Title = "BUY DANCES",
			Image = v3("$Image-CollectButton-BuyDances"),
			BackgroundColor = v2("Color-Collection-Dances"),
			StrokeThickness = 3,
			StrokeColor = Color3.fromHex("#FA4AF8"),
			Render = function(props2)
				local createElement = React.createElement
				local emote

				if v6[2] then
					emote = v6[2].Content
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
		table.insert(nodes, v8)

		for i = 3, #v6 do
			table.insert(nodes, {
				Type = "GamePass",
				GamePass = v6[i],
				OverrideBackgroundImage = v3("Image-CategoryBackground-DancesDefault"),
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
}

local function CollectPage(props)
	local v2 = React.useContext(State.Context)
	return React.createElement(React.Fragment, {}, {
		Header = React.createElement(Button, {
			[React.Tag] = "CollectHeaderButton",
			OnActivated = function()
				v2.SetWidget(props.Return)
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
	local v2 = useStyleSheet("Icons", "string")
	local bundleItems = props.BundleItems
	local children = {}

	for i = 1, #bundleItems do
		local bundleItem = bundleItems[i]
		local overrideBackgroundImage = nil

		if bundleItem.RelicsAssetType == "SKIN" then
			overrideBackgroundImage = v2("Image-CategoryBackground-SkinsCollect")
		elseif bundleItem.RelicsAssetType ~= "AURAS" and bundleItem.RelicsAssetType ~= "PLAYLIST" then
			overrideBackgroundImage = v2("Image-CategoryBackground-FeaturedSecond")

			if i == 1 then
				overrideBackgroundImage = v2("Image-CategoryBackground-FeaturedFirst")
			elseif i == 2 then
				overrideBackgroundImage = v2("Image-CategoryBackground-FeaturedSecond")
			end
		end

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
	end

	local createElement = React.createElement
	local v4 = {
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = 1
	}
	local assetId = props.AssetId

	if assetId then
		assetId = React.createElement("Folder", {}, {
			BuyButton = React.createElement(Button, {
				[React.Tag] = "UpsellBuyButton",
				Size = UDim2.fromScale(0.2, 0.1125),
				Position = UDim2.fromScale(1, -0.125),
				AnchorPoint = Vector2.new(1, 1),
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
	end

	return createElement("Frame", v4, children, {
		NoList = assetId,
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
	local v2 = useStyleSheet("Palette", "Color3")
	local v3 = useStyleSheet("Icons", "string")
	local v4 = React.useContext(State.Context)
	local v5 = useGamePasses()
	local widget = v4.Widget
	local context = widget and widget.Context
	local textColor, v7 = React.useBinding(Color3.fromHSV(1, 1, 1))
	local v8 = usePlaylists({
		IncludeInactiveUnowned = true
	})
	local state, setState = React.useState({})
	local features = v4.Features
	React.useEffect(function()
		local v9 = {}

		if features.Emotes then
			table.insert(v9, "Dances")
		end

		if features.Playlists then
			table.insert(v9, "Playlists")
		end

		if features.Skins then
			table.insert(v9, "Cosmetics")
		end

		if features.Auras then
			table.insert(v9, "Auras")
		end

		setState(v9)
	end, { features })
	local children = {}
	local children2 = {}
	local v9 = useActiveBundle()
	local v10 = useGamePasses()
	local v11 = React.useMemo(function()
		local result = {}

		for _, v12 in v10 do
			result[v12.ProductId] = v12
		end

		return result
	end, { v10 })
	local v12 = React.useMemo(function()
		if v9 then
			return v9.Type == "LastItemLocked"
		end

		return false
	end, { v9 })
	useClock(30, function()
		local v13 = os.clock() / 2 % 1
		v7(Color3.fromHSV(v13, 1, 1))
	end)
	local v13 = React.useCallback(function(p)
		if not p then
			return {}
		end

		local clone = table.clone(p.Items)
		table.sort(clone, function(a, b)
			return (a.Sort or 1e999) < (b.Sort or 1e999)
		end)
		local assetId = p.AssetId
		local result = {}

		for _, v14 in ipairs(clone) do
			local assetId2 = Bundles.ResolveAssetId(v14)
			local id = assetId2 and assetId2.Id

			if id == assetId then
				continue
			end

			local v15 = assetId2 and v11[id]

			if not v15 then
				continue
			end

			local relicsAssetType = v15.RelicsAssetType
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
				table.insert(result, v15)
			end
		end

		local v14 = v11[p.AssetId]

		if v14 then
			table.insert(result, v14)
		end

		return result
	end, { v11, features })
	local bundleItems = React.useMemo(function()
		return v13(v9)
	end, { v9, v11, features })
	local assetId

	if v9 then
		assetId = v9.AssetId or nil
	else
		assetId = nil
	end

	local v15 = React.useMemo(function()
		local result = {}
		local v16 = {}
		local v17 = {}

		if v9 then
			local v18 = v13(v9)

			for _, v19 in v18 do
				v17[v19.ProductId] = true
			end
		end

		local v18 = {}

		for _, v19 in v5 do
			if v19.IsActive == false or v17[v19.ProductId] or not (not assetId or v19.ProductId ~= assetId) or not v19.IsFeatured then
				continue
			end

			local relicsAssetType = v19.RelicsAssetType
			local playlists = relicsAssetType == "PLAYLIST" and features.Playlists or relicsAssetType == "EMOTE" and features.Emotes or relicsAssetType == "AURA" and features.Auras

			if not playlists then
				if relicsAssetType == "SKIN" then
					playlists = features.Skins
				else
					playlists = false
				end
			end

			if playlists then
				table.insert(v18, v19)
			end
		end

		table.sort(v18, function(a, b)
			return (a.SortOrder or 0) < (b.SortOrder or 0)
		end)

		for _, v19 in v18 do
			table.insert(result, v19)
			v16[v19.ProductId] = true
		end

		if not v9 then
			return result
		end

		local v19 = v13(v9)

		for _, v20 in v19 do
			if v20.ProductId == assetId or not v20.IsFeatured or v16[v20.ProductId] then
				continue
			end

			table.insert(result, v20)
			v16[v20.ProductId] = true
		end

		return result
	end, {
		features,
		v5,
		v9,
		v11,
		assetId
	})
	local v16 = React.useMemo(function()
		local records = {}

		for _, v18 in bundleItems do
			Ownership.Get(v18, records, v18.Id)
		end

		return {
			Records = records,
			AutoOwnedCount = 0
		}
	end, { bundleItems, v8 })
	local count = #bundleItems
	local count2 = #v15
	local body = React.useCallback(function(props, _)
		local createElement = React.createElement
		local v19 = {
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			AssetId = 0,
			BundleItems = 0
		}
		local assetId2

		if not v12 then
			assetId2 = assetId
		end

		v19.AssetId = assetId2
		v19.BundleItems = bundleItems
		return createElement(BundleBody, v19)
	end, { bundleItems })

	for k, gamePass in v15 do
		local overrideBackgroundImage = nil
		local disabledOverlay = assetId and gamePass.ProductId == assetId

		if disabledOverlay then
			overrideBackgroundImage = "rbxassetid://132855273143799"
		elseif gamePass.RelicsAssetType == "SKIN" then
			overrideBackgroundImage = v3("Image-CategoryBackground-SkinsCollect")
		elseif gamePass.RelicsAssetType == "EMOTE" then
			overrideBackgroundImage = v3("Image-CategoryBackground-FeaturedSecond")

			if k == 1 then
				overrideBackgroundImage = v3("Image-CategoryBackground-FeaturedFirst")
			elseif k == 2 then
				overrideBackgroundImage = v3("Image-CategoryBackground-FeaturedSecond")
			end
		end

		local v21 = "Item" .. tostring(k)
		children2[v21] = React.createElement(GamePassItem, {
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

	local _, v18 = useOwnership(v16.Records)
	local v19 = v18 + v16.AutoOwnedCount

	for k, text in pairs(state) do
		local backgroundColor = v2((`Color-Collection-{text}`)) or v2("Color-BLACK")
		local createElement = React.createElement
		local v23 = {
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
		local v24 = text

		function v23.OnActivated()
			local v25 = assert(v4.Widget)
			local body2 = v[v24]

			if body2 then
				v4.SetWidget({
					ReturnFunc = function()
						v4.SetWidget(v25)
					end,
					Widget = function()
						return React.createElement(CollectPage, {
							Header = `COLLECT {v24:upper()}`,
							Return = v25,
							Body = body2
						})
					end
				})
			else
				warn("[RelicsPlayer] No widget found for collection:", v24)
			end
		end

		children[text] = createElement(TextButton, v23)
	end

	local collected

	if v9 == nil then
		collected = false
	else
		collected = count > 0
	end

	local items = count2 > 0
	local itemHeader = collected or items
	local onActivated = React.useCallback(function()
		local v24 = assert(v4.Widget)
		local name = v9 and v9.Name or "FEATURE BUNDLE"

		if v24.Context == "OpenBundle" then
			v24.Context = nil
		end

		v4.SetWidget({
			ReturnFunc = function()
				v4.SetWidget(v24)
			end,
			Widget = function()
				return React.createElement(CollectPage, {
					Header = name:upper(),
					Return = v24,
					Body = body
				})
			end
		})
	end, { v4, v9, body })

	if context == "OpenBundle" and v9 then
		onActivated()
	elseif v[context] then
		local v24 = assert(v4.Widget)
		local body2 = v[context]
		v4.SetWidget({
			ReturnFunc = function()
				v4.SetWidget(v24)
			end,
			Widget = function()
				return React.createElement(CollectPage, {
					Header = `COLLECT {context:upper()}`,
					Return = v24,
					Body = body2
				})
			end
		})
		v24.Context = nil
	end

	local createElement = React.createElement
	local v25 = {
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
		local v29 = {
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
					Text = "<b>" .. (v9 and v9.Name:upper() or "FEATURE BUNDLE") .. "</b> >" .. (not v12 and "" or `\n<font size="8">({v19}/{count} COLLECTED)      </font>`),
					RichText = true,
					TextColor3 = textColor
				})
			})
		end

		itemHeader = createElement4("TextLabel", v29, {
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
	return createElement("Frame", v25, children3)
end

return Collect