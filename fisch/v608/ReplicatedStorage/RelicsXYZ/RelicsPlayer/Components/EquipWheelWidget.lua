local parent = script.Parent.Parent
local State = require(parent.State)
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local React = require(shared.React)
local Ownership = require(shared.Ownership)
local EquipWheel = require(shared.EquipWheel)
local hooks = parent.Hooks
local useAuras = require(hooks.useAuras)
local useEmotes = require(hooks.useEmotes)
local useMotion = require(hooks.useMotion)
local useSpring = require(hooks.useSpring)
require(hooks.useAuraData)
require(hooks.useKeybinds)
local useUgcSkins = require(hooks.useUgcSkins)
local useOwnership = require(hooks.useOwnership)
local useEquipWheel = require(hooks.useEquipWheel)
local useStyleSheet = require(hooks.useStyleSheet)
local useBulkOwnership = require(hooks.useBulkOwnership)
local useRelicsAssetInfo = require(hooks.useRelicsAssetInfo)
local components = parent.Components
local Button = require(components.Button)
local VirtualGrid = require(components.VirtualGrid)
local AuraPreview = require(components.AuraPreview)
local BoomboxPreview = require(components.BoomboxPreview)
local EmotePreview = require(components.EmotePreview)
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local NUM_SLOTS = EquipWheel.NUM_SLOTS
local v2 = {
	tension = 800,
	friction = 40
}
local v3 = {
	{ Enum.KeyCode.One, Enum.KeyCode.KeypadOne },
	{ Enum.KeyCode.Two, Enum.KeyCode.KeypadTwo },
	{ Enum.KeyCode.Three, Enum.KeyCode.KeypadThree },
	{ Enum.KeyCode.Four, Enum.KeyCode.KeypadFour },
	{ Enum.KeyCode.Five, Enum.KeyCode.KeypadFive },
	{ Enum.KeyCode.Six, Enum.KeyCode.KeypadSix },
	{ Enum.KeyCode.Seven, Enum.KeyCode.KeypadSeven },
	{ Enum.KeyCode.Eight, Enum.KeyCode.KeypadEight }
}

local function WheelSlotButton(props)
	local v4 = useAuras()
	local v5 = useEmotes()
	local data = props.Data
	local index = props.Index
	local v6 = -1.5707963267948966 + 6.283185307179586 * (index - 1) / NUM_SLOTS
	local v7 = math.cos(v6) * 0.35 + 0.5
	local v8 = math.sin(v6) * 0.35 + 0.5
	local image = ""
	local animation = nil
	local type, id

	if data then
		type = data.Type
		id = data.Id

		if type == "AURA" then
			local v9 = v4[id]
			image = v9 and v9.Image or ""
		elseif type == "EMOTE" then
			local v9 = v5[id]
			animation = v9 and v9.Animation
		end
	end

	local createElement = React.createElement
	local v10 = {
		[React.Tag] = "EquipWheelWidgetSlot",
		Position = UDim2.fromScale(v7, v8),
		[React.Event.Activated] = props.OnClick,
		[React.Event.MouseEnter] = function()
			props.OnHover(true)
		end,
		[React.Event.MouseLeave] = function()
			props.OnHover(false)
		end
	}
	local v11 = {
		UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1
		}),
		SlotNumber = 0,
		AuraImage = 0,
		AuraPreview = 0,
		EmotePreview = 0,
		SkinPreview = 0
	}
	local slotNumber = not data

	if slotNumber then
		slotNumber = React.createElement("TextLabel", {
			[React.Tag] = "EquipWheelSlotNumber",
			Text = tostring(index)
		})
	end

	v11.SlotNumber = slotNumber
	local auraImage

	if data then
		if type == "AURA" and image ~= "" then
			auraImage = React.createElement("ImageLabel", {
				[React.Tag] = "EquipWheelSlotImage",
				Image = image
			})
		else
			auraImage = false
		end
	else
		auraImage = data
	end

	v11.AuraImage = auraImage
	local auraPreview

	if data then
		if type == "AURA" and image == "" then
			auraPreview = id and React.createElement(AuraPreview, {
				Aura = id,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 50
			})
		else
			auraPreview = false
		end
	else
		auraPreview = data
	end

	v11.AuraPreview = auraPreview
	local emotePreview

	if data then
		if type == "EMOTE" then
			emotePreview = animation and React.createElement(EmotePreview, {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Emote = animation,
				NoMask = true,
				BackgroundTransparency = 1,
				ZIndex = 50
			})
		else
			emotePreview = false
		end
	else
		emotePreview = data
	end

	v11.EmotePreview = emotePreview

	if data then
		if type == "SKIN" then
			data = id and React.createElement(BoomboxPreview, {
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Skin = id,
				ViewportScale = 0.9,
				BackgroundTransparency = 1,
				ZIndex = 50
			})
		else
			data = false
		end
	end

	v11.SkinPreview = data
	return createElement("TextButton", v10, v11)
end

local function SelectionTile(props)
	local v4 = useRelicsAssetInfo(props.Target)
	local image = v4.Image or ""
	local overrideGlowImage = props.OverrideGlowImage
	local backgroundColor = props.BackgroundColor
	local state, setState = React.useState(false)
	local v5, v6 = React.useBinding(1)
	local v7 = useSpring(v5, {
		tension = 200,
		friction = 20
	})
	v6(state and 0 or 1)
	local createElement = React.createElement
	local v9 = {
		[React.Tag] = Util.ClassNames("PurchaseableItem", "EquipSelectionTile"),
		LayoutOrder = props.LayoutOrder,
		OnActivated = props.OnSelect,
		HoverScale = 1.05,
		PressScale = 0.95,
		OnHoverStart = function()
			setState(true)
		end,
		OnHoverEnd = function()
			setState(false)
		end
	}
	local v10 = {
		Title = React.createElement("TextLabel", {
			[React.Tag] = "ItemTitleHeading",
			TextStrokeTransparency = v7,
			TextTransparency = v7,
			Size = v7:map(function(p: number)
				local v12 = (1 - p) / 2
				return UDim2.fromScale(v12, v12)
			end),
			Visible = v7:map(function(p: number)
				return p < 1
			end),
			Text = v4.Title,
			TextScaled = true,
			ZIndex = 100
		}),
		ColoredBackground = 0,
		GlowImage = 0,
		Preview = 0,
		Image = 0
	}

	if backgroundColor then
		backgroundColor = React.createElement("Frame", {
			[React.Tag] = "ColoredBackground",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = 0.3,
			ZIndex = 0
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8)
			}),
			UIStroke = React.createElement("UIStroke", {
				Color = backgroundColor,
				Thickness = 2
			})
		})
	end

	v10.ColoredBackground = backgroundColor

	if overrideGlowImage then
		overrideGlowImage = React.createElement("ImageLabel", {
			[React.Tag] = "GlowImage",
			Image = overrideGlowImage,
			ZIndex = 1
		})
	end

	v10.GlowImage = overrideGlowImage
	v10.Preview = props.OverrideRender and React.createElement(props.OverrideRender.Widget, props.OverrideRender.Props)
	local image2 = not props.OverrideRender

	if image2 then
		if image == "" then
			image2 = false
		else
			image2 = React.createElement("ImageLabel", {
				[React.Tag] = "ItemImage",
				Image = image,
				ZIndex = 2
			})
		end
	end

	v10.Image = image2
	return createElement(Button, v9, v10)
end

local function SkinSelectionTile(props)
	local skinId = props.SkinId
	local v4 = useUgcSkins()

	if useOwnership((React.useMemo(function()
		local v6 = v4[skinId]
		return not v6 and {} or Ownership.Get(v6)
	end, { v4, skinId }))) then
		return React.createElement(SelectionTile, {
			Target = {
				RenderContext = "ItemTile",
				Type = "SKIN",
				Id = skinId
			},
			LayoutOrder = props.LayoutOrder,
			BackgroundColor = props.BackgroundColor,
			OverrideRender = {
				Widget = BoomboxPreview,
				Props = {
					Skin = skinId,
					ViewportScale = 0.75
				}
			},
			OnSelect = props.OnSelect
		})
	end

	return nil
end

local function FilterButton(props)
	local active = props.Active
	local v4 = "is" .. props.Text:sub(1, 1) .. props.Text:sub(2):lower()
	local createElement = React.createElement
	local v6 = {
		[React.Tag] = Util.ClassNames("FilterButton", active and "active" or "inactive", v4),
		Size = UDim2.new(0.3333333333333333, -4, 0, 28),
		LayoutOrder = props.LayoutOrder,
		OnActivated = props.OnClick,
		HoverScale = 1.02,
		PressScale = 0.98
	}
	local v7 = {
		Background = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		}),
		Label = 0
	}
	local createElement2 = React.createElement
	local v9 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = props.Text,
		TextColor3 = 0,
		Font = 0,
		TextSize = 11,
		ZIndex = 1
	}
	local textColor

	if active then
		textColor = Color3.new(1, 1, 1)
	else
		textColor = Color3.fromHex("#888888")
	end

	v9.TextColor3 = textColor
	v9.Font = Enum.Font.GothamBold
	v7.Label = createElement2("TextLabel", v9)
	return createElement(Button, v6, v7)
end

local function ItemSelectionModal(p)
	local v4 = useStyleSheet("Tweaks")
	local v5 = useStyleSheet("Palette", "Color3")
	local features = React.useContext(State.Context).Features
	local v6 = useAuras()
	local v7 = useEmotes()
	local v8 = useUgcSkins()
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState(true)
	local state3, setState3 = React.useState(true)
	local v9 = v5("Color-Collection-Auras", Color3.fromHex("#68C2B3"))
	local v10 = v5("Color-Collection-Dances", Color3.fromHex("#FF6B9D"))
	local v11 = v5("Color-Collection-Cosmetics", Color3.fromHex("#9B59B6"))
	local v12 = React.useMemo(function()
		return Ownership.BulkGet(v6)
	end, { v6 })
	local v13 = React.useMemo(function()
		return Ownership.BulkGet(v7)
	end, { v7 })
	local v14 = useBulkOwnership(v12)
	local v15 = useBulkOwnership(v13)
	local children = {}
	local count = 0

	if state then
		for k, _ in v6 do
			if not v14[k] then
				continue
			end

			count += 1
			local id = k
			children[`aura_{k}`] = React.createElement(SelectionTile, {
				Target = {
					RenderContext = "ItemTile",
					Type = "AURA",
					Id = k
				},
				LayoutOrder = count,
				BackgroundColor = v9,
				OnSelect = function()
					p.OnSelect({
						Type = "AURA",
						Id = id
					})
				end
			})
		end
	end

	if state2 then
		for k, v16 in v7 do
			if not v15[k] then
				continue
			end

			count += 1
			local id = k
			children[`emote_{k}`] = React.createElement(SelectionTile, {
				Target = {
					RenderContext = "ItemTile",
					Type = "EMOTE",
					Id = k
				},
				LayoutOrder = count,
				BackgroundColor = v10,
				OverrideRender = {
					Widget = EmotePreview,
					Props = {
						Emote = v16.Animation,
						NoMask = true
					}
				},
				OnSelect = function()
					p.OnSelect({
						Type = "EMOTE",
						Id = id
					})
				end
			})
		end
	end

	local children2 = {}
	local layoutOrder = 1000

	if state3 then
		for k, skinData in v8 do
			if skinData.ProductId == 0 then
				continue
			end

			layoutOrder += 1
			local id = k
			children2[`skin_{k}`] = React.createElement(SkinSelectionTile, {
				SkinId = k,
				SkinData = skinData,
				LayoutOrder = layoutOrder,
				BackgroundColor = v11,
				OnSelect = function()
					p.OnSelect({
						Type = "SKIN",
						Id = id
					})
				end
			})
		end
	end

	local v17 = {}

	for k, v18 in children do
		v17[k] = v18
	end

	for k, v18 in children2 do
		v17[k] = v18
	end

	local createElement = React.createElement
	local v19 = {
		[React.Tag] = Util.ClassNames("PurchaseableItemsContainer", "EquipSelectionContainer")
	}
	local v20 = {
		FilterBar = React.createElement("Frame", {
			[React.Tag] = "FilterBar"
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6)
			}),
			AurasFilter = features.Auras and React.createElement(FilterButton, {
				Text = "AURAS",
				Color = v9,
				Active = state,
				LayoutOrder = 1,
				OnClick = function()
					setState(not state)
				end
			}),
			DancesFilter = features.Emotes and React.createElement(FilterButton, {
				Text = "DANCES",
				Color = v10,
				Active = state2,
				LayoutOrder = 2,
				OnClick = function()
					setState2(not state2)
				end
			}),
			CosmeticsFilter = features.Skins and React.createElement(FilterButton, {
				Text = "COSMETICS",
				Color = v11,
				Active = state3,
				LayoutOrder = 3,
				OnClick = function()
					setState3(not state3)
				end
			})
		}),
		Items = next(v17) and React.createElement(VirtualGrid, {
			CanvasSize = UDim2.fromScale(1, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Position = UDim2.new(0.5, 0, 0.5, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 0, 1, -40),
			Transparency = 1,
			ZIndex = 0,
			CellSize = UDim2.new(
				1 / v4("Tweak-MaxVirtualGridCells", 4),
				-12,
				1 / v4("Tweak-MaxVirtualGridCells", 4),
				-12
			),
			CellPadding = UDim2.fromOffset(9, 9),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirectionMaxCells = v4("Tweak-MaxVirtualGridCells", 4)
		}, v17),
		EmptyState = 0
	}
	local emptyState = not next(v17)

	if emptyState then
		emptyState = React.createElement("TextLabel", {
			[React.Tag] = "EquipSelectionEmpty",
			Text = "No items to show.\nClick a filter to show items."
		})
	end

	v20.EmptyState = emptyState
	return createElement("Frame", v19, v20)
end

local function EquipWheelWidget(p)
	local v4 = React.useContext(State.Context)
	local v5 = useEquipWheel()
	local state, setState = React.useState()
	local state2, setState2 = React.useState()
	local ref = React.useRef()
	local ref2 = React.useRef(-90)
	local rotation, v7 = useMotion(-90)
	React.useEffect(function()
		if state2 then
			local current2 = (state2 - 1) * 45 - 90

			if ref.current == nil then
				ref2.current = current2
				v7:immediate(current2)
			else
				local current = ref2.current
				local v9 = current2 - current

				while v9 > 180 do
					v9 -= 360
				end

				while v9 < -180 do
					v9 += 360
				end

				local current3 = current + v9
				ref2.current = current3
				v7:spring(current3, v2)
			end
		end

		ref.current = state2
	end, { state2 })
	React.useEffect(function()
		local equipTargetSlot = v4.EquipTargetSlot

		if equipTargetSlot then
			setState(equipTargetSlot)
			v4.SetEquipTargetSlot(nil)
		end
	end, { v4.EquipTargetSlot })

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleSlotClick(p2: number)
		if v4.EquipReturnToWheel then
			v4.SetEquipReturnToWheel(false)
		end

		setState(p2)
	end

	local function handleItemSelect(p2)
		if state then
			local equipReturnToWheel = v4.EquipReturnToWheel

			-- equivalent calls inferred from this helper; original call sites unknown
			local function finishSelection()
				setState(nil)

				if equipReturnToWheel then
					v4.SetEquipReturnToWheel(false)
					v4.SetEquipWheelOpen(true)
				end
			end

			local v8 = v5[state]

			if v8 and v8.Type == p2.Type and v8.Id == p2.Id then
				EquipWheel.ClearSlot(state)
				finishSelection() -- equivalent call inferred; original call site unknown
			else
				for i = 1, NUM_SLOTS do
					local v9 = v5[i]

					if v9 and v9.Type == p2.Type and v9.Id == p2.Id then
						EquipWheel.ClearSlot(i)
					end
				end

				EquipWheel.SetSlot(state, p2)
				finishSelection() -- equivalent call inferred; original call site unknown
			end
		end
	end

	local children = {}

	for i = 1, NUM_SLOTS do
		local v8 = i
		local v9 = i
		children[`Slot{i}`] = React.createElement(WheelSlotButton, {
			Index = i,
			Data = v5[i],
			IsHovered = state2 == i,
			OnClick = function()
				handleSlotClick(v8) -- equivalent call inferred; original call site unknown
			end,
			OnHover = function(flag: boolean)
				if flag then
					setState2(v9)
				else
					setState2(function(p2)
						if p2 == v9 then
							return nil
						end

						return p2
					end)
				end
			end
		})
	end

	if state then
		return React.createElement("Frame", {
			[React.Tag] = Util.ClassNames("EquipWheelContainer", p[React.Tag])
		}, {
			ItemSelection = React.createElement(ItemSelectionModal, {
				SlotIndex = state,
				OnSelect = handleItemSelect
			})
		})
	else
		local children2 = {}

		for k, v8 in pairs(v3) do
			local children3 = {}

			for _, keyCode in pairs(v8) do
				children3[keyCode.Name] = React.createElement("InputBinding", {
					KeyCode = keyCode
				})
			end

			local formatted = `Slot{k}`
			local createElement = React.createElement
			local v9 = {
				Type = Enum.InputActionType.Bool
			}
			local v10 = k

			v9[React.Event.Pressed] = function()
				handleSlotClick(v10) -- equivalent call inferred; original call site unknown
			end

			children2[formatted] = createElement("InputAction", v9, children3)
		end

		local createElement = React.createElement
		local v9 = {
			[React.Tag] = Util.ClassNames("EquipWheelContainer", p[React.Tag])
		}
		local v10 = {
			SlotInputContext = not v and React.createElement("InputContext", {
				Enabled = true,
				Sink = false,
				Priority = 100
			}, children2),
			Wheel = 0
		}
		local createElement2 = React.createElement
		local v12 = {
			[React.Tag] = "EquipWheelWidgetWheel"
		}
		local children3 = {
			UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1
			}),
			SelectedGradient = 0,
			SegmentedCircle = 0,
			CircleBackground = 0,
			SelectedLine = 0,
			CenterContent = 0
		}
		local selectedGradient

		if state2 then
			selectedGradient = React.createElement("ImageLabel", {
				[React.Tag] = "EquipWheelHighlight",
				Rotation = (state2 - 1) * 45 - 90
			})
		else
			selectedGradient = state2
		end

		children3.SelectedGradient = selectedGradient
		children3.SegmentedCircle = React.createElement("ImageLabel", {
			[React.Tag] = "EquipWheelSegments"
		})
		children3.CircleBackground = React.createElement("ImageLabel", {
			[React.Tag] = "EquipWheelCenterRing"
		})

		if state2 then
			state2 = React.createElement("ImageLabel", {
				[React.Tag] = "EquipWheelPointer",
				Rotation = rotation
			})
		end

		children3.SelectedLine = state2
		children3.CenterContent = React.createElement("TextButton", {
			[React.Tag] = "EquipWheelWidgetLabel",
			[React.Event.Activated] = function()
				v4.SetEquipWheelOpen(true)
			end
		}, {
			MainText = React.createElement("TextLabel", {
				[React.Tag] = "EquipWheelWidgetTitle",
				Text = "EQUIP\nWHEEL"
			})
		})
		v10.Wheel = createElement2("Frame", v12, children3, children)
		return createElement("Frame", v9, v10)
	end
end

return EquipWheelWidget