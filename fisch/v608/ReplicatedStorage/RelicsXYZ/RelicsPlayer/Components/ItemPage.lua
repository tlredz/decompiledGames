local parent = script.Parent.Parent
local parent2 = parent.Parent
local hooks = parent.Hooks
local shared = parent2.Shared
local components = parent.Components
local Upsell = require(components.Upsell)
local TextButton = require(components.TextButton)
local EmotePreview = require(components.EmotePreview)
local BoomboxPreview = require(components.BoomboxPreview)
local Util = require(parent.Util)
local Enums = require(parent.Enums)
local State = require(parent.State)
local React = require(shared.React)
local useCountdown = require(hooks.useCountdown)
local useProductInfo = require(hooks.useProductInfo)
local useRelicsRotato = require(hooks.useRelicsRotato)
local useRelicsAssetInfo = require(hooks.useRelicsAssetInfo)
local useGamePasses = require(hooks.useGamePasses)
local useStyleSheet = require(hooks.useStyleSheet)
require(hooks.useFeatures)
require(hooks.usePreviewOcclusion)
local GamePasses = require(shared.GamePasses)
require(shared.Signal)

local function ItemPage(props)
	local v = useStyleSheet("Icons", "string")
	local v2 = React.useContext(State.Context)
	local v3 = useGamePasses()
	local target = props.Target
	local v4 = type(target) == "table" and {
		RenderContext = "ItemPage",
		Type = target.Type,
		Id = target.Id
	} or target
	local v5 = useRelicsAssetInfo(v4)
	local title = string.upper(v5.Title or "[UNKNOWN ITEM]")
	local backgroundImage = v5.BackgroundImage
	local equipped = v5.Equipped
	local product = v5.Product
	local owned = v5.Owned
	local image = v5.Image
	local v6 = nil

	for _, v8 in v3 do
		if v8.Name ~= v4.Id then
			continue
		end

		v6 = v8
		break
	end

	local text

	if v6 then
		text = useCountdown(v6, v6.IsActive)
	end

	local v9 = v6 and v6.EndDate and text
	local strokeColor = v5.StrokeColor
	local titleStrokeColor = v5.TitleStrokeColor or v5.StrokeColor
	local v10 = useProductInfo(product and product.Id, product and product.InfoType)
	local v11

	if type(v4) == "string" then
		v11 = GamePasses.FindGamePass(v4)
	end

	local v12 = useProductInfo(v11 and v11.ProductId, v11 and v11.ProductType)
	local v13 = v10 or v12
	React.useEffect(function()
		if v2.Status ~= Enums.UserStatus.BoomboxPurchased then
			local v14

			if type(props.Target) == "table" then
				v14 = props.Target.Type
			else
				v14 = props.Target
			end

			if v14 == "EMOTE" then
				return
			end

			v2.SetWidget({
				Widget = Upsell,
				ReturnText = (type(props.Target) ~= "table" or type(props.Target.Id) ~= "string") and "BOOMBOX" or props.Target.Id,
				ReturnFunc = v2.WidgetReturn
			})
			v2.SetWindowTab(Enums.WindowTab.Upsell)
		end
	end, { v2.Status })
	local v14 = props.Locked == true or v5.Locked == true
	local pageRender = v5.PageRender or v5.Render

	if owned then
		v14 = false
	end

	local rotation = useRelicsRotato(v5.IconSpinStyle)
	local skyboxImg = Util.CoerceImage(backgroundImage) or v("Image-Background-GamePass")
	local props2

	if pageRender and (pageRender.Widget == BoomboxPreview or pageRender.Widget == EmotePreview) then
		props2 = pageRender.Props

		if not props2 then
			props2 = {}
			pageRender.Props = props2
		end

		props2.RenderInWorld = true
		props2.SkyboxImg = skyboxImg
	end

	if v2.Status ~= Enums.UserStatus.BoomboxPurchased then
		local v17

		if type(props.Target) == "table" then
			v17 = props.Target.Type
		else
			v17 = props.Target
		end

		if v17 ~= "EMOTE" then
			return nil
		end
	end

	local createElement = React.createElement
	local fragment = React.Fragment
	local children = {
		Background = React.createElement("CanvasGroup", {
			[React.Tag] = "Design ItemViewerPageBackground"
		}, {
			LeftFrame = React.createElement("Frame", {
				[React.Tag] = "LeftFrame"
			}),
			RightFrame = React.createElement("Frame", {
				[React.Tag] = "RightFrame"
			}, {})
		}),
		Widget = 0,
		Footer = 0
	}
	local createElement5 = React.createElement
	local v22 = {
		[React.Tag] = "ItemViewerPageContainer",
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint
	}
	local createElement6 = React.createElement
	local v24 = {
		[React.Tag] = "Design ItemViewerPageInfoPanel"
	}
	local v25 = {
		Background = React.createElement("ImageLabel", {
			[React.Tag] = "ItemTitleBackground",
			Image = backgroundImage
		}),
		Image = image and React.createElement("ImageLabel", {
			Image = image,
			Rotation = rotation
		}),
		Title = 0,
		Stroke = 0
	}

	if title then
		title = React.createElement("TextLabel", {
			[React.Tag] = "ItemTitleHeading",
			Text = title
		}, {
			Stroke = React.createElement("UIStroke", {
				Color = titleStrokeColor
			})
		})
	end

	v25.Title = title

	if strokeColor then
		strokeColor = React.createElement("UIStroke", {
			[React.Tag] = "UIStroke",
			Color = strokeColor
		})
	end

	v25.Stroke = strokeColor
	local children3 = {
		InfoPanel = createElement6("CanvasGroup", v24, v25),
		ActionPanel = 0,
		PreviewPanel = 0
	}
	local createElement8 = React.createElement
	local v28 = {
		[React.Tag] = "Design ItemInteractPanelBackground"
	}
	local children4 = {
		Ownership = React.createElement("TextLabel", {
			[React.Tag] = "OwnershipStatusLabel",
			Text = owned and "YOU OWN THIS!" or "PRICE: " .. (not (v13 and v13.PriceInRobux) and "..." or `{v13.PriceInRobux}`)
		}),
		Action = 0,
		NoList = 0
	}
	local createElement10 = React.createElement
	local v31 = {
		[React.Tag] = "ItemInteractButton",
		LoadRefresh = true
	}
	local unequipText

	if v14 then
		unequipText = "[LOCKED]"
	elseif owned then
		if equipped then
			unequipText = v5.UnequipText or "UNEQUIP"
		else
			unequipText = v5.EquipText or "EQUIP"
		end
	else
		unequipText = "BUY"
	end

	v31.Text = unequipText
	local equip

	if not v14 then
		if owned then
			equip = v5.Equip
		else
			equip = v5.Purchase
		end
	end

	v31.OnActivated = equip
	children4.Action = createElement10(TextButton, v31)
	local noList

	if v9 then
		noList = React.createElement("Folder", {}, {
			Countdown = React.createElement("Frame", {
				[React.Tag] = Util.ClassNames("CountdownContainer", "ofItemViewerPage")
			}, {
				Icon = React.createElement("ImageLabel", {
					[React.Tag] = "CountdownIcon"
				}),
				Timer = React.createElement("TextLabel", {
					[React.Tag] = "ElapsedText",
					Text = text
				}),
				RemainingLabel = React.createElement("TextLabel", {
					[React.Tag] = "RemainingLabel"
				})
			})
		})
	end

	children4.NoList = noList
	children3.ActionPanel = createElement8("ImageLabel", v28, children4)
	local createElement11 = React.createElement
	local v34 = {
		[React.Tag] = "Design ItemPreviewPanelBackground",
		ImageTransparency = v5.PreviewBackground == false and 1 or 0
	}
	local image2

	if v5.PreviewBackground ~= false then
		image2 = v5.PreviewBackground
	end

	v34.Image = image2
	children3.PreviewPanel = createElement11("ImageLabel", v34, {
		Preview = pageRender and React.createElement(pageRender.Widget, props2 or pageRender.Props or {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5)
		})
	})
	children.Widget = createElement5("Frame", v22, children3)
	children.Footer = React.createElement("Frame", {
		[React.Tag] = "Design MiniplayerFooterBackground"
	})
	return createElement(fragment, {}, children)
end

return ItemPage