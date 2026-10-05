local parent = script.Parent.Parent
local Enums = require(parent.Enums)
local State = require(parent.State)
local Widgets = require(parent.Widgets)
local shared = parent.Parent.Shared
local Auras = require(shared.Auras)
local React = require(shared.React)
local Emotes = require(shared.Emotes)
local Boombox = require(shared.Boombox)
local Ownership = require(shared.Ownership)
local EquipWheel = require(shared.EquipWheel)
local ReactRoblox = require(shared.ReactRoblox)
local hooks = parent.Hooks
local useAuras = require(hooks.useAuras)
local useChild = require(hooks.useChild)
local useEmotes = require(hooks.useEmotes)
local useMotion = require(hooks.useMotion)
local useTagged = require(hooks.useTagged)
local useSpring = require(hooks.useSpring)
local useAuraData = require(hooks.useAuraData)
local useUgcSkins = require(hooks.useUgcSkins)
local useKeybinds = require(hooks.useKeybinds)
local useOwnership = require(hooks.useOwnership)
local useEquipWheel = require(hooks.useEquipWheel)
local usePlayerData = require(hooks.usePlayerData)
local components = parent.Components
local AuraPreview = require(components.AuraPreview)
local EmotePreview = require(components.EmotePreview)
local BoomboxPreview = require(components.BoomboxPreview)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local localPlayer = Players.LocalPlayer
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

-- equivalent calls inferred from this helper; original call sites unknown
local function getSlotFromPosition(point: Vector2, point2: Vector2, p: number)
	local v4 = point2 - point
	local magnitude = v4.Magnitude

	if magnitude < p * 0.28 or p < magnitude then
		return nil
	end

	local v5 = math.atan2(v4.Y, v4.X)
	local v6 = 3.141592653589793 / NUM_SLOTS
	local v7 = v5 - -1.5707963267948966 + v6

	if v7 < 0 then
		v7 += 6.283185307179586
	end

	local v8 = math.floor(v7 / (6.283185307179586 / NUM_SLOTS)) + 1
	return NUM_SLOTS < v8 and 1 or v8
end

local function EquipWheelOverlay(props)
	local v4 = React.useContext(State.Context)
	local v5 = useEquipWheel()
	local v6 = useTagged("RelicsDesign")[1]
	local v7 = useChild(v6, "StyleSheetOverride")
	local v8 = useChild(v6, "MainWindow")
	local v9 = useAuraData()
	local v10 = usePlayerData("UGCSkin/Skin")
	local v11 = useAuras()
	local v12 = useEmotes()
	local v13 = useUgcSkins()
	local v14 = useKeybinds()
	local v15, v16 = React.useBinding(props.Visible and 1 or 0)
	local scale = useSpring(v15, v2)
	v16(props.Visible and 1 or 0)
	local state, setState = React.useState(nil)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(false)
	local ref5 = React.useRef(false)
	local ref6 = React.useRef(-90)
	local rotation, v19 = useMotion(-90)
	local v20 = useOwnership((Ownership.BulkGet(v12, function(p)
		return p.Name
	end)))
	React.useEffect(function()
		if state then
			local current2 = (state - 1) * 45 - 90

			if ref2.current == nil then
				ref6.current = current2
				v19:immediate(current2)
			else
				local current = ref6.current
				local v22 = current2 - current

				while v22 > 180 do
					v22 -= 360
				end

				while v22 < -180 do
					v22 += 360
				end

				local current3 = current + v22
				ref6.current = current3
				v19:spring(current3, v2)
			end
		end

		ref2.current = state
	end, { state })
	local v21 = React.useCallback(function(p)
		local current = ref3.current

		if not current then
			return
		end

		if v20 then
			local absolutePosition = current.AbsolutePosition
			local absoluteSize = current.AbsoluteSize
			local v22 = absolutePosition + absoluteSize / 2
			local v23 = math.min(absoluteSize.X, absoluteSize.Y) / 2
			local slotFromPosition = getSlotFromPosition(v22, Vector2.new(p.Position.X, p.Position.Y), v23) -- equivalent call inferred; original call site unknown
			ref.current = slotFromPosition
			setState(slotFromPosition)
		else
			setState(nil)
			ref.current = nil
		end
	end, { v20 })
	local v22 = React.useCallback(function(p: number)
		if v20 then
			local v23 = v5[p]

			if not v23 then
				return
			end

			local type = v23.Type
			local id = v23.Id

			if type == "AURA" then
				if v9.Aura == id then
					Auras.EquipAura(nil)
				else
					Auras.EquipAura(id)
				end
			elseif type == "EMOTE" then
				local v24 = Emotes.GetEmotes()[id]

				if v24 then
					Emotes.PlayEmoteLocal(v24, v4)
				end
			elseif type == "SKIN" then
				if v10.UGCSkin.Skin == id then
					Boombox.EquipSkin(nil)
				else
					Boombox.EquipSkin(id)
				end
			elseif type == "PLAYLIST" then
				print("PLAYLIST", id)
			end

			props.OnClose()
		else
			v4.SetWindowState(Enums.WindowState.Full)
			v4.SetWindowTab(Enums.WindowTab.Collect)
			v4.SetWidget({
				Widget = Widgets.Collect,
				Context = "Dances"
			})
			props.OnClose()
		end
	end, {
		v20,
		v5,
		v9,
		v10,
		v12,
		v11,
		v13,
		props
	})
	local v23 = React.useCallback(function(_, p)
		local userInputType = p.UserInputType

		if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		v21(p)
		ref4.current = true
		ref5.current = false
		task.delay(0.25, function()
			if not ref4.current then
				return
			end

			local current = ref.current

			if not current then
				return
			end

			ref4.current = false
			ref5.current = true
			props.OnEditSlot(current)
		end)
	end, { v21, props })
	local v24 = React.useCallback(function(_, p)
		local userInputType = p.UserInputType

		if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if ref5.current then
			ref5.current = false
			ref4.current = false
		else
			ref4.current = false
			local current = ref.current

			if current or not v20 then
				v22(current)
			else
				props.OnClose()
			end
		end
	end, { v22, v20, props })
	local v25 = React.useCallback(function(_, p)
		v21(p)
	end, { v21 })
	local children = {}

	for k, v26 in pairs(v3) do
		local children2 = {}

		for _, keyCode in pairs(v26) do
			children2[keyCode.Name] = React.createElement("InputBinding", {
				KeyCode = keyCode
			})
		end

		local formatted = `Slot{k}`
		local createElement = React.createElement
		local v27 = {
			Type = Enum.InputActionType.Bool
		}
		local v28 = k

		v27[React.Event.Pressed] = function()
			v22(v28)
		end

		children[formatted] = createElement("InputAction", v27, children2)
	end

	local name = ""
	local v26 = ""
	local v27 = state and v5[state]
	local text

	if v20 then
		if v27 then
			local type = v27.Type
			local id = v27.Id

			if type == "AURA" then
				name = id or "Aura"
			elseif type == "EMOTE" then
				local v29 = id and v12[id]
				name = v29 and v29.Name or id or "Emote"
			elseif type == "SKIN" then
				local v29 = id and v13[id]
				name = v29 and v29.DisplayName or id or "Skin"
			end

			text = `Slot {state}\n{name}`
		elseif state then
			text = `Slot {state}\n(Unassigned)`
		else
			v26 = v and "Tap Center - Toggle Music Player" or `[{v14.EquipWheel.Name}] Toggle Music Player`
			text = "Equip Wheel"
		end
	else
		text = "CLICK HERE TO\nBUY DANCES"
	end

	local text2 = state and (v and "Click and Hold to Customize" or "Hold to Customize") or v26
	local children2 = {}

	for i = 1, NUM_SLOTS do
		local skinPreview = v5[i]
		local v31 = -1.5707963267948966 + 6.283185307179586 * (i - 1) / NUM_SLOTS
		local v32 = math.cos(v31) * 0.35 + 0.5
		local v33 = math.sin(v31) * 0.35 + 0.5
		local image = ""
		local animation = nil
		local type, id

		if skinPreview then
			type = skinPreview.Type
			id = skinPreview.Id

			if type == "AURA" then
				local v34 = id and v11[id]
				image = v34 and v34.Image or ""
			elseif type == "EMOTE" then
				local v34 = id and v12[id]
				animation = v34 and v34.Animation
			end
		end

		local formatted = `Item{i}`
		local createElement = React.createElement
		local v35 = {
			[React.Tag] = "EquipWheelOverlaySlot",
			Position = UDim2.fromScale(v32, v33)
		}
		local slotNumber = v20 and not skinPreview

		if slotNumber then
			slotNumber = React.createElement("TextLabel", {
				[React.Tag] = "EquipWheelSlotNumber",
				Text = tostring(i)
			})
		end

		local slotLock = not v20

		if slotLock then
			slotLock = React.createElement("ImageLabel", {
				[React.Tag] = "EquipWheelSlotLock"
			})
		end

		local auraImage

		if skinPreview then
			if type == "AURA" and image ~= "" then
				auraImage = React.createElement("ImageLabel", {
					[React.Tag] = "EquipWheelSlotImage",
					Image = image
				})
			else
				auraImage = false
			end
		else
			auraImage = skinPreview
		end

		local auraPreview

		if skinPreview then
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
			auraPreview = skinPreview
		end

		local emotePreview

		if skinPreview then
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
			emotePreview = skinPreview
		end

		if skinPreview then
			if type == "SKIN" then
				skinPreview = id and React.createElement(BoomboxPreview, {
					Size = UDim2.fromScale(0.9, 0.9),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Skin = id,
					ViewportScale = 0.9,
					BackgroundTransparency = 1,
					ZIndex = 50
				})
			else
				skinPreview = false
			end
		end

		children2[formatted] = createElement("Frame", v35, {
			SlotNumber = slotNumber,
			SlotLock = slotLock,
			AuraImage = auraImage,
			AuraPreview = auraPreview,
			EmotePreview = emotePreview,
			SkinPreview = skinPreview
		})
	end

	local v30 = {
		StyleLink = React.createElement("StyleLink", {
			StyleSheet = v7 or v8
		}),
		SlotInputContext = React.createElement("InputContext", {
			Sink = true,
			Priority = 2000,
			Enabled = props.Visible
		}, children),
		Overlay = 0
	}
	local createElement = React.createElement
	local v32 = {
		[React.Tag] = "EquipWheelOverlayRoot",
		Visible = scale:map(function(p)
			return p > 0
		end)
	}
	local createElement2 = React.createElement
	local v35 = {
		[React.Tag] = "EquipWheelOverlayWheel",
		ref = ref3
	}
	local children3 = {
		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1
		}),
		Scale = React.createElement("UIScale", {
			Scale = scale
		}),
		SelectedGradient = 0,
		SegmentedCircle = 0,
		CircleBackground = 0,
		SelectedLine = 0,
		CenterContent = 0,
		WheelClickDetector = 0
	}
	local selectedGradient

	if state then
		selectedGradient = React.createElement("ImageLabel", {
			[React.Tag] = "EquipWheelHighlight",
			Rotation = (state - 1) * 45 - 90
		})
	else
		selectedGradient = state
	end

	children3.SelectedGradient = selectedGradient
	children3.SegmentedCircle = React.createElement("ImageLabel", {
		[React.Tag] = "EquipWheelSegments"
	})
	children3.CircleBackground = React.createElement("ImageLabel", {
		[React.Tag] = "EquipWheelCenterRing"
	})

	if state then
		state = React.createElement("ImageLabel", {
			[React.Tag] = "EquipWheelPointer",
			Rotation = rotation
		})
	end

	children3.SelectedLine = state
	local createElement5 = React.createElement
	local v40 = {
		[React.Tag] = "EquipWheelOverlayLabel"
	}
	local v41 = {
		EmotePreview = not v20 and React.createElement(EmotePreview, {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			NoMask = true,
			ZIndex = 0
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			})
		}),
		MainText = 0,
		KeybindHints = 0
	}
	local createElement6 = React.createElement
	local v43 = {
		[React.Tag] = "EquipWheelOverlayTitle"
	}
	local size

	if text2 == "" then
		size = UDim2.fromScale(1, 1)
	else
		size = UDim2.fromScale(1, 0.5)
	end

	v43.Size = size
	v43.Position = UDim2.fromScale(0.5, text2 == "" and 0.5 or 0.35)
	v43.Text = text
	v41.MainText = createElement6("TextLabel", v43)
	local keybindHints

	if text2 == "" then
		keybindHints = false
	else
		keybindHints = React.createElement("TextLabel", {
			[React.Tag] = "EquipWheelOverlayHint",
			Text = text2
		})
	end

	v41.KeybindHints = keybindHints
	children3.CenterContent = createElement5("Frame", v40, v41)
	children3.WheelClickDetector = React.createElement("TextButton", {
		[React.Event.InputBegan] = v23,
		[React.Event.InputChanged] = v25,
		[React.Event.InputEnded] = v24,
		[React.Tag] = "EquipWheelOverlayButton"
	})
	v30.Overlay = createElement("Frame", v32, {
		WheelContainer = createElement2("Frame", v35, children3, children2)
	})
	local root = props.Root or localPlayer:FindFirstChildOfClass("PlayerGui")

	if not root then
		return nil
	end

	if root:IsA("BasePlayerGui") then
		return (ReactRoblox.createPortal({
			EquipWheelOverlay = React.createElement("ScreenGui", {
				[React.Tag] = "EquipWheelOverlayScreenGui",
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			}, v30)
		}, root))
	else
		return (ReactRoblox.createPortal({
			EquipWheelOverlay = React.createElement("Folder", {
				[React.Tag] = "EquipWheelOverlayFolder"
			}, v30)
		}, root))
	end
end

return EquipWheelOverlay