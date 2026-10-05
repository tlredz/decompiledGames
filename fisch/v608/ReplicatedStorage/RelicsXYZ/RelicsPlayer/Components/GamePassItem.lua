local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local components = parent.Components
local State = require(parent.State)
local Util = require(parent.Util)
local Enums = require(parent.Enums)
local React = require(shared.React)
require(shared.GamePasses)
local Button = require(components.Button)
local Upsell = require(components.Upsell)
local ItemPage = require(components.ItemPage)
local EmotePreview = require(components.EmotePreview)
local BoomboxPreview = require(components.BoomboxPreview)
local hooks = parent.Hooks
local useUgcSkins = require(hooks.useUgcSkins)
local useCountdown = require(hooks.useCountdown)
local useStyleSheet = require(hooks.useStyleSheet)
local useProductInfo = require(hooks.useProductInfo)
local useRelicsRotato = require(hooks.useRelicsRotato)
local useRelicsAssetInfo = require(hooks.useRelicsAssetInfo)

local function getRenderParams(gamePass, items)
	local v = nil
	local content = gamePass.Content
	local relicsAssetType = gamePass.RelicsAssetType

	if not content then
		return v
	end

	if relicsAssetType == "EMOTE" and content:IsA("Animation") then
		return {
			Widget = EmotePreview,
			Props = {
				Emote = content
			}
		}
	end

	if relicsAssetType ~= "SKIN" then
		return v
	end

	local name = content.Name
	local value = nil

	if content:IsA("IntValue") then
		value = content.Value
	elseif content:IsA("StringValue") then
		value = tonumber(content.Value:match("%d+$")) or value
	elseif content:IsA("Decal") then
		value = tonumber(content.Texture:match("%d+$")) or value
	end

	if value then
		for k, item in items do
			if item.TextureId ~= value then
				continue
			end

			name = k
			break
		end
	end

	return name and {
		Widget = BoomboxPreview,
		Props = {
			Skin = name
		}
	} or v
end

local function GamePassItem(data)
	local v = useStyleSheet("Icons", "string")
	local v2 = useStyleSheet("Palette", "Color3")
	local v3 = React.useContext(State.Context)
	local v4 = useUgcSkins()
	local gamePass = data.GamePass
	local compact = data.Compact or false
	local text, v6 = useCountdown(gamePass, gamePass.IsActive)
	local v7 = {
		RenderContext = "ItemTile",
		Type = gamePass.RelicsAssetType,
		Id = gamePass.Name
	}
	local target = {
		RenderContext = "ItemPage",
		Type = gamePass.RelicsAssetType,
		Id = gamePass.Name
	}
	local v9 = useRelicsAssetInfo(v7)
	local v10 = useRelicsAssetInfo(target)
	local v11 = getRenderParams(gamePass, v4) or v9.Render
	local product = v9.Product
	local v12 = useProductInfo(product and product.Id, product and product.InfoType)
	local v13 = useProductInfo(gamePass.ProductId, gamePass.ProductType)
	local v14 = v12 or v13
	local rotation = useRelicsRotato(v9.IconSpinStyle)
	local disabledOverlay = data.DisabledOverlay or v10.Locked or false
	local enabled = v10.Enabled

	if v10.Owned then
		disabledOverlay = false
	end

	local strokeColor

	if disabledOverlay then
		strokeColor = v2("Color-Locked")
	else
		strokeColor = v9.StrokeColor or v2("Color-White")
	end

	local v16

	if enabled then
		if disabledOverlay then
			v16 = v("Image-Locked-Background-GamePass")
		else
			v16 = Util.CoerceImage(gamePass.BackgroundImageAssetId) or Util.CoerceImage(data.OverrideBackgroundImage) or Util.CoerceImage(gamePass.ItemImageAssetId) or Util.CoerceImage(v9.BackgroundImage) or v("Image-Background-GamePass")
		end
	else
		v16 = v("Image-LockedPlaylist")
	end

	if v11 and (v11.Widget == BoomboxPreview or v11.Widget == EmotePreview) then
		local props = v11.Props

		if not props then
			props = {}
			v11.Props = props
		end

		props.SkyboxImg = v16
	end

	local countdown = gamePass.EndDate and text

	if not v6 then
		return v6
	end

	local createElement = React.createElement
	local v19 = {
		[React.Tag] = Util.ClassNames("GamepassProductButtonWrapper", data[React.Tag])
	}
	local layoutOrder

	if enabled then
		layoutOrder = data.LayoutOrder
	else
		layoutOrder = 1000 + (data.LayoutOrder or 0)
	end

	v19.LayoutOrder = layoutOrder
	v19.Size = data.Size
	v19.Position = data.Position
	v19.AnchorPoint = data.AnchorPoint
	local createElement2 = React.createElement
	local v23 = {
		[React.Tag] = Util.ClassNames(
			"GamepassProductButton",
			data[React.Tag],
			data.ColorCoded and "isColorCoded" or nil
		),
		BackgroundColor3 = strokeColor,
		OnActivated = function()
			local widget = v3.Widget

			if enabled then
				v3.SetWidget({
					HideBackground = v10.HideBackground,
					Widget = function(props)
						return React.createElement(ItemPage, {
							Size = props.Size,
							Position = props.Position,
							AnchorPoint = props.AnchorPoint,
							Locked = disabledOverlay,
							Target = target
						})
					end,
					ReturnFunc = function()
						v3.SetWidget(widget)
					end,
					ReturnText = gamePass.Name
				})
				return
			end

			local widget2 = v3.Widget
			v3.SetWidget({
				Widget = Upsell,
				ReturnText = "Collect",
				ReturnFunc = function()
					v3.SetWindowTab(Enums.WindowTab.Collect)
					v3.SetWidget(widget2)
				end
			})
			v3.SetWindowTab(Enums.WindowTab.Upsell)
		end
	}
	local showCategoryBadge = data.ShowCategoryBadge

	if showCategoryBadge then
		showCategoryBadge = React.createElement("Frame", {
			[React.Tag] = "CategoryContainer"
		}, {
			CategoryLabel = React.createElement("TextLabel", {
				[React.Tag] = "CategoryLabel",
				Text = gamePass.RelicsAssetType == "EMOTE" and "Dance" or gamePass.RelicsAssetType == "AURA" and "Aura" or gamePass.RelicsAssetType == "SKIN" and "Skin" or gamePass.RelicsAssetType == "PLAYLIST" and "Playlist" or gamePass.RelicsAssetType
			}),
			Checkmark = React.createElement("ImageLabel", {
				[React.Tag] = "CheckmarkIcon",
				Image = disabledOverlay and v("Icon-Lock") or v("Icon-Checkmark"),
				ImageTransparency = (v9.Owned or disabledOverlay) and 0 or 1
			}, {})
		})
	end

	local createElement3 = React.createElement
	local v26 = {
		[React.Tag] = "Design Backdrop ofGamePassItem"
	}
	local v27 = {
		Background = React.createElement("ImageLabel", {
			[React.Tag] = "Design Background",
			Image = v16
		}),
		Item = 0,
		Title = 0,
		Render = 0,
		DisabledOverlay = 0,
		Countdown = 0
	}
	local v29 = enabled and not v11

	if v29 then
		v29 = React.createElement("ImageLabel", {
			[React.Tag] = "Design ItemImage",
			Image = v9.Image or gamePass.ItemImageAssetId,
			Rotation = rotation
		})
	end

	v27.Item = v29
	local displayTitleOnTile = enabled and not v11 and compact and v9.DisplayTitleOnTile

	if displayTitleOnTile then
		displayTitleOnTile = React.createElement("TextLabel", {
			[React.Tag] = "Design Title",
			Text = v9.Title or ""
		})
	end

	v27.Title = displayTitleOnTile
	v27.Render = enabled and v11 and React.createElement(v11.Widget, v11.Props)
	local disabledOverlay2

	if enabled and data.DisabledOverlay then
		disabledOverlay2 = React.createElement("Frame", {
			[React.Tag] = "Design DisabledOverlay"
		}, {
			Lock = React.createElement("ImageLabel", {
				[React.Tag] = "LockIcon"
			}, {})
		}) or nil
	end

	v27.DisabledOverlay = disabledOverlay2

	if enabled then
		if countdown then
			countdown = React.createElement("Frame", {
				[React.Tag] = Util.ClassNames(
					"CountdownContainer",
					"ofGamePassItem",
					data.Vertical and "isVertical" or nil
				)
			}, {
				Icon = React.createElement("ImageLabel", {
					[React.Tag] = "CountdownIcon"
				}),
				Timer = React.createElement("TextLabel", {
					[React.Tag] = "ElapsedText",
					Text = text
				})
			})
		end
	else
		countdown = enabled
	end

	v27.Countdown = countdown
	local v24 = {
		CategoryBadge = showCategoryBadge,
		Backdrop = createElement3("CanvasGroup", v26, v27),
		Title = 0,
		Price = 0
	}
	local title = enabled and not compact

	if title then
		title = React.createElement("TextLabel", {
			[React.Tag] = "TitleHeading",
			Text = (v9.Title or gamePass.Name):upper()
		}, {})
	end

	v24.Title = title
	local price = enabled and not compact

	if price then
		price = React.createElement("TextLabel", {
			[React.Tag] = Util.ClassNames("PriceHeading"),
			Text = string.format(utf8.char(57346) .. "%s", v14 and tostring(v14.PriceInRobux or "...") or "...")
		})
	end

	v24.Price = price
	return (createElement("Frame", v19, {
		Button = createElement2(Button, v23, v24)
	}))
end

return GamePassItem