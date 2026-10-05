local parent = script.Parent.Parent
local parent2 = parent.Parent
local hooks = parent.Hooks
local shared = parent2.Shared
local components = parent.Components
local Upsell = require(components.Upsell)
local TextButton = require(components.TextButton)
local EmotePreview = require(components.EmotePreview)
local DraggableList = require(components.DraggableList)
local BoomboxPreview = require(components.BoomboxPreview)
local Util = require(parent.Util)
local Enums = require(parent.Enums)
local State = require(parent.State)
local React = require(shared.React)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.RelicsXYZ.Shared.UserId)
local useSignal = require(hooks.useSignal)
local useCountdown = require(hooks.useCountdown)
local useGamePasses = require(hooks.useGamePasses)
local useStyleSheet = require(hooks.useStyleSheet)
local useProductInfo = require(hooks.useProductInfo)
local useRelicsRotato = require(hooks.useRelicsRotato)
local useRelicsAssetInfo = require(hooks.useRelicsAssetInfo)
local GamePasses = require(shared.GamePasses)
require(shared.Signal)

local function PlayerInfo(props)
	local v = props.Lookup[props.Id]
	local v2 = props.Active == props.Id and " selected" or ""
	return React.createElement("Frame", {
		[React.Tag] = "PlayerInfo" .. v2
	}, {
		Icon = React.createElement("ImageLabel", {
			[React.Tag] = "PlayerIcon" .. v2,
			Image = `rbxthumb://type=AvatarHeadShot&id={v.UserId}&w=150&h=150`,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(1, 1)
		}),
		Name = React.createElement("TextLabel", {
			[React.Tag] = "PlayerNameLabel" .. v2,
			Text = v.DisplayName
		})
	})
end

local function ItemPage(props)
	local v = useStyleSheet("Icons", "string")
	local v2 = React.useContext(State.Context)
	local v3 = useGamePasses()
	local target = props.Target

	if type(target) == "table" then
		target = table.clone(target)
		target.RenderContext = "ItemPage"
	end

	local v4 = useRelicsAssetInfo(target)
	local title = string.upper(v4.Title or "[UNKNOWN ITEM]")
	local backgroundImage = v4.BackgroundImage
	local equipped = v4.Equipped
	local product = v4.Product
	local owned = v4.Owned
	local image = v4.Image
	local gamePass

	if type(target) == "string" then
		gamePass = GamePasses.FindGamePass(target)
	else
		gamePass = target.GamePass
	end

	for _, v6 in v3 do
		if v6.Name ~= target.Id then
			continue
		end

		gamePass = v6
		break
	end

	local text

	if gamePass then
		text = useCountdown(gamePass, gamePass.IsActive)
	end

	local countdown = gamePass and gamePass.EndDate and text
	local strokeColor = v4.StrokeColor
	local titleStrokeColor = v4.TitleStrokeColor or v4.StrokeColor
	local v8 = useProductInfo(product and product.Id, product and product.InfoType)
	local v9 = useProductInfo(gamePass and gamePass.ProductId, gamePass and gamePass.ProductType)
	local v10 = v8 or v9
	local state, setState = React.useState(false)
	local giftProductId = gamePass and gamePass.GiftProductId
	local state2, setState2 = React.useState(Players:GetPlayers())
	local state3, setState3 = React.useState()
	useSignal(Players.PlayerAdded, function()
		setState2(Players:GetPlayers())
	end, {})
	useSignal(Players.PlayerRemoving, function()
		setState2(Players:GetPlayers())
	end, {})
	local lookup, items = React.useMemo(function()
		local names = {}
		local result = {}

		for _, v13 in state2 do
			local _ = v13 == Players.LocalPlayer
			local name = v13.Name
			table.insert(names, name)
			result[name] = v13
		end

		table.sort(names)
		return result, names
	end, { state2 })
	React.useEffect(function()
		if v2.Status ~= Enums.UserStatus.BoomboxPurchased then
			local v13

			if type(props.Target) == "table" then
				v13 = props.Target.Type
			else
				v13 = props.Target
			end

			if v13 == "EMOTE" then
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
	local v13 = props.Locked == true or v4.Locked == true
	local pageRender = v4.PageRender or v4.Render

	if owned then
		v13 = false
	end

	local rotation = useRelicsRotato(v4.IconSpinStyle)
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
		local v16

		if type(props.Target) == "table" then
			v16 = props.Target.Type
		else
			v16 = props.Target
		end

		if v16 ~= "EMOTE" then
			return nil
		end
	end

	local v16 = giftProductId and next(lookup)
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
		GiftPanel = 0,
		PreviewPanel = 0
	}
	local actionPanel = not state

	if actionPanel then
		local createElement8 = React.createElement
		local v29 = {
			[React.Tag] = "Design ItemInteractPanelBackground"
		}
		local children4 = {
			Ownership = React.createElement("TextLabel", {
				Text = owned and "YOU OWN THIS!" or "PRICE: " .. (not (v10 and v10.PriceInRobux) and "..." or `{v10.PriceInRobux}`),
				[React.Tag] = "OwnershipStatusLabel"
			}),
			Action = 0,
			Gift = 0,
			NoList = 0
		}
		local createElement10 = React.createElement
		local v32 = {
			[React.Tag] = "ItemInteractButton",
			LoadRefresh = true
		}
		local unequipText

		if v13 then
			unequipText = "[LOCKED]"
		elseif owned then
			if equipped then
				unequipText = v4.UnequipText or "UNEQUIP"
			else
				unequipText = v4.EquipText or "EQUIP"
			end
		else
			unequipText = "BUY"
		end

		v32.Text = unequipText
		local equip

		if not v13 then
			if owned then
				equip = v4.Equip
			else
				equip = v4.Purchase
			end
		end

		v32.OnActivated = equip
		v32.LayoutOrder = 100
		children4.Action = createElement10(TextButton, v32)
		local gift

		if v16 then
			gift = React.createElement(TextButton, {
				[React.Tag] = "ItemInteractButton",
				LoadRefresh = true,
				Text = "GIFT",
				OnActivated = function()
					setState(true)
				end,
				LayoutOrder = 200
			}) or nil
		end

		children4.Gift = gift
		local createElement11 = React.createElement

		if countdown then
			countdown = React.createElement("Frame", {
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
		end

		children4.NoList = createElement11("Folder", {}, {
			Countdown = countdown
		})
		actionPanel = createElement8("ImageLabel", v29, children4)
	end

	children3.ActionPanel = actionPanel
	local giftPanel

	if state then
		local createElement8 = React.createElement
		local v29 = {
			[React.Tag] = "Design ItemInteractPanelBackground"
		}
		local children4 = {
			GiftInfo = React.createElement("TextLabel", {
				[React.Tag] = "GiftInfoLabel",
				Text = "Select Recipient:",
				LayoutOrder = -100
			}),
			Players = React.createElement(DraggableList, {
				InnerComponent = PlayerInfo,
				InnerProps = {
					Lookup = lookup,
					Active = state3
				},
				Size = UDim2.fromScale(1, 0.5),
				Items = items,
				OnActivated = setState3,
				ActiveItem = state3
			}),
			Send = React.createElement(TextButton, {
				[React.Tag] = "ItemInteractButton",
				LoadRefresh = true,
				Text = "BUY & SEND",
				OnActivated = function()
					local v33 = state3 and lookup[state3]

					if v33 and gamePass then
						GamePasses.PerformGiftTransaction(gamePass.Id, v33)
					end
				end,
				LayoutOrder = 100
			}),
			Cancel = React.createElement(TextButton, {
				[React.Tag] = "ItemInteractButton",
				LoadRefresh = true,
				Text = "CANCEL",
				OnActivated = function()
					setState(false)
				end,
				LayoutOrder = 200
			})
		}
		giftPanel = createElement8("ImageLabel", v29, children4) or nil
	end

	children3.GiftPanel = giftPanel
	local createElement8 = React.createElement
	local v30 = {
		[React.Tag] = "Design ItemPreviewPanelBackground",
		ImageTransparency = v4.PreviewBackground == false and 1 or 0
	}
	local image2

	if v4.PreviewBackground ~= false then
		image2 = v4.PreviewBackground
	end

	v30.Image = image2
	children3.PreviewPanel = createElement8("ImageLabel", v30, {
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