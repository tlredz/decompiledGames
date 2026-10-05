local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local createElement = React.createElement
local v = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"CLR",
	"0",
	"OK"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function paletteForKey(p: string)
	if p == "CLR" then
		return CONSTANTS.COLOR.DANGER
	elseif p == "OK" then
		return CONSTANTS.COLOR.PURCHASE
	end

	return CONSTANTS.COLOR.SECONDARY
end

local function Keypad(props)
	local state, setState = React.useState("")
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(false)
	local ref = React.useRef(true)
	React.useEffect(function()
		return function()
			ref.current = false
		end
	end, {})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reject()
		setState2(true)
		setState("")
		pcall(function()
			Sound:PlayUI("LowerSkyBonusMomentSFX.BF_LowerSky_Enter_Incorrect_Code_01")
		end)
	end

	local function submit(state4: string)
		local onSubmit = props.OnSubmit

		if onSubmit then
			setState3(true)
			task.spawn(function()
				local v2 = onSubmit(state4) == true

				if not ref.current then
					return
				end

				setState3(false)

				if v2 then
					props.OnFinish(true)
					return
				end

				reject() -- equivalent call inferred; original call site unknown
			end)
		else
			if state4 == props.Code then
				props.OnFinish(true)
				return
			end

			reject() -- equivalent call inferred; original call site unknown
		end
	end

	local function pressKey(p: string)
		if state3 then
			return
		end

		if p == "CLR" then
			setState2(false)
			setState("")
		elseif p == "OK" then
			if #state == 4 then
				submit(state)
			end
		elseif #state < 4 then
			setState2(false)
			setState(state .. p)
		end
	end

	local v2 = {}

	for i = 1, 4 do
		local v3 = state:sub(i, i)
		v2[i] = v3 == "" and "_" or v3
	end

	local children = {
		Layout = createElement("UIGridLayout", {
			CellPadding = UDim2.fromOffset(10, 10),
			CellSize = UDim2.fromOffset(102, 86),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center
		})
	}

	for k, text in v do
		local v4 = paletteForKey(text) -- equivalent call inferred; original call site unknown
		local v5 = text
		children["Key" .. k] = createElement(Button, {
			Text = text,
			LayoutOrder = k,
			IsDisabled = state3,
			BackgroundColor3 = v4.BACKGROUND,
			ElevatedBackgroundColor3 = v4.HIGHLIGHT,
			BorderColor3 = v4.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			OnClick = function()
				pressKey(v5)
			end
		})
	end

	local v5 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1)
	}
	local v6 = {
		Backdrop = createElement("Frame", {
			Active = true,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Size = UDim2.fromScale(1, 1)
		}),
		Panel = 0
	}
	local v9 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(350, 516),
		ZIndex = CONSTANTS.LAYER.MODAL
	}
	local v10 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Header = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.HEADER.BACKGROUND,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Size = UDim2.new(1, 0, 0, 44)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.5, CONSTANTS.COLOR.HEADER.HIGHLIGHT),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			}),
			Title = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.7, 0.7),
				Text = "VAULT KEYPAD",
				TextColor3 = CONSTANTS.COLOR.HEADER.TEXT,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			}),
			Close = createElement(Button, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -11, 0.5, 0),
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Text = "X",
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
				ElevatedBackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				ZIndex = CONSTANTS.LAYER.RAISED,
				OnClick = function()
					props.OnFinish(false)
				end
			})
		}),
		Display = 0,
		Grid = 0
	}
	local v13 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromOffset(11, 66),
		Size = UDim2.new(1, -22, 0, 56)
	}
	local v14 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Label = 0
	}
	local v17 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Size = UDim2.fromScale(1, 1),
		Text = table.concat(v2, "   "),
		TextColor3 = 0,
		TextSize = 44,
		TextTransparency = 0
	}
	local textColor

	if state2 then
		textColor = CONSTANTS.COLOR.DANGER.HIGHLIGHT
	else
		textColor = CONSTANTS.COLOR.PALETTE.WHITE
	end

	v17.TextColor3 = textColor
	local textTransparency

	if state3 then
		textTransparency = CONSTANTS.ALPHA.HALF
	else
		textTransparency = CONSTANTS.ALPHA.OPAQUE
	end

	v17.TextTransparency = textTransparency
	v14.Label = createElement("TextLabel", v17, {
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		})
	})
	v10.Display = createElement("Frame", v13, v14)
	v10.Grid = createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromOffset(11, 130),
		Size = UDim2.new(1, -22, 0, 374)
	}, children)
	v6.Panel = createElement("Frame", v9, v10)
	return createElement("Frame", v5, v6)
end

local VaultKeypad = {
	Keypad = Keypad
}
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyHandle(p)
	p.root:unmount()
	p.gui:Destroy()
end

function VaultKeypad.isOpen()
	return v2 ~= nil
end

function VaultKeypad.close()
	local v3 = v2

	if not v3 then
		return
	end

	v2 = nil
	destroyHandle(v3) -- equivalent call inferred; original call site unknown

	if v3.onClose then
		v3.onClose()
	end
end

function VaultKeypad.open(onSubmit, callback, onClose)
	if v2 then
		return
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AngelicVaultKeypad"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.DisplayOrder = 60
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local root = ReactRoblox.createRoot(screenGui)
	local v3 = {
		root = root,
		gui = screenGui,
		onClose = onClose
	}
	v2 = v3

	local function finish(flag: boolean)
		if v2 ~= v3 then
			return
		end

		v2 = nil

		if flag then
			callback()
		else
			onClose()
		end

		task.defer(destroyHandle, v3)
	end

	local code

	if type(onSubmit) == "string" then
		code = onSubmit
	end

	if type(onSubmit) ~= "function" then
		onSubmit = nil
	end

	root:render(createElement(Keypad, {
		Code = code,
		OnSubmit = onSubmit,
		OnFinish = finish
	}))
end

return VaultKeypad