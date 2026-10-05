local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
local SimpleButton = require(game.ReplicatedStorage.React.Components.SimpleButton)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local MaterialSprite = require(script.Parent.MaterialSprite)
local createElement = React.createElement
local DISPLAY = CONSTANTS.FONT.FACE.DISPLAY
local uDim = UDim2.fromScale(0.4396, 0.4476)
local vector = Vector2.new(475, 300)
local vector2 = Vector2.new(1000, 800)
local uDim2 = UDim2.fromScale(0.015, 0.5)
local uDim3 = UDim2.fromScale(0.46, 0.98)
local uDim4 = UDim2.fromScale(0.48, 0.48)
local uDim5 = UDim2.fromScale(0.04, 0.04)
local uDim6 = UDim2.fromScale(0.485, 0.5)
local uDim7 = UDim2.fromScale(0.07, 0.18)
local uDim8 = UDim2.fromScale(0.575, 0.5)
local uDim9 = UDim2.fromScale(0.41, 0.98)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
	ColorSequenceKeypoint.new(0.51, Color3.fromRGB(255, 239, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
})
local color = Color3.fromRGB(53, 229, 0)
local color2 = Color3.fromRGB(236, 0, 3)
local color3 = Color3.fromRGB(196, 200, 208)
local color4 = Color3.fromRGB(72, 72, 72)
local badgeStar = SpriteMap.UI["Badge Star"]

local function ScaledText(props)
	return createElement("TextLabel", {
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = 1,
		FontFace = DISPLAY,
		Position = props.Position,
		Size = props.Size,
		Text = props.Text,
		TextColor3 = props.Color,
		TextScaled = true,
		TextWrapped = props.Wrapped,
		ZIndex = props.ZIndex
	}, {
		SizeConstraint = createElement("UITextSizeConstraint", {
			MaxTextSize = props.MaxTextSize
		}),
		Stroke = createElement("UIStroke", {
			Color = Color3.new(0, 0, 0),
			Thickness = 2
		})
	})
end

local function Slot(data)
	local config = MaterialSprite.config(data.Material)
	local display

	if config then
		display = config.Display
	end

	local v = data.InPot and 1 or data.Owned
	local v2 = v >= 1
	local v5 = {
		BackgroundTransparency = 1,
		LayoutOrder = data.LayoutOrder
	}
	local icon

	if display then
		icon = display.Sprite
	end

	local outlineIcon

	if display then
		outlineIcon = display.OutlineSprite
	end

	local iconColor

	if not v2 then
		iconColor = color4
	end

	local title

	if display then
		title = display.Title or display.Name or data.Material
	else
		title = data.Material
	end

	local onActivatedsByActivated = {
		DrawContext = "Default",
		Variant = "Elevated",
		Icon = icon,
		OutlineIcon = outlineIcon,
		IconColor = iconColor,
		Title = title,
		Category = data.InPot and "In Pot" or nil
	}
	local rarity

	if config then
		rarity = config.Quality.Rarity
	end

	onActivatedsByActivated.Rarity = rarity
	onActivatedsByActivated.IsSelected = data.InPot
	onActivatedsByActivated.Size = UDim2.fromScale(1, 0.86)
	onActivatedsByActivated[React.Event.Activated] = data.OnActivated
	local v6 = {
		Tile = createElement(Tile, onActivatedsByActivated),
		Count = 0
	}
	local v16 = {
		Text = `{v}/1`,
		Color = 0,
		MaxTextSize = 18,
		AnchorPoint = 0,
		Position = 0,
		Size = 0
	}
	local color5

	if v2 then
		color5 = color
	else
		color5 = color2
	end

	v16.Color = color5
	v16.AnchorPoint = Vector2.new(0.5, 1)
	v16.Position = UDim2.fromScale(0.5, 1)
	v16.Size = UDim2.fromScale(1, 0.14)
	v6.Count = createElement(ScaledText, v16)
	return createElement("Frame", v5, v6)
end

local function Result(p)
	local v3 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = uDim8,
		Size = uDim9
	}
	local v7 = {
		DrawContext = "Default",
		Variant = "Elevated",
		Icon = badgeStar,
		IconColor = 0,
		Title = "Awakened Chef",
		Category = "Boss",
		Rarity = "Mythical",
		IsSelected = 0,
		AnchorPoint = 0,
		Position = 0,
		Size = 0
	}
	local iconColor

	if not p.Ready then
		iconColor = color4
	end

	v7.IconColor = iconColor
	v7.IsSelected = p.Ready
	v7.AnchorPoint = Vector2.new(0.5, 0.5)
	v7.Position = UDim2.fromScale(0.5, 0.5)
	v7.Size = UDim2.fromScale(0.62, 0.62)
	return createElement("Frame", v3, {
		ResultTile = createElement(Tile, v7, {
			Aspect = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Width
			})
		}),
		ResultDesc = createElement(ScaledText, {
			Text = "The Chef tastes your cooking and stops holding back.",
			Color = color3,
			MaxTextSize = 15,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.95, 0.17),
			Wrapped = true
		})
	})
end

local function Menu(p)
	local state, setState = React.useState(p.State)
	local state2, setState2 = React.useState(false)
	React.useEffect(function()
		setState(p.State)
	end, { p.State })
	local v = {}

	for _, v2 in state.Placed do
		v[v2] = true
	end

	local ready

	if #state.Recipe > 0 then
		ready = #state.Placed >= #state.Recipe
	else
		ready = false
	end

	local function insert(p2: string)
		if state2 or v[p2] then
			return
		end

		setState2(true)
		task.spawn(function()
			local v3 = p.Handlers.Insert(p2)

			if v3 then
				setState(v3)
			end

			setState2(false)
		end)
	end

	local function cook()
		if state2 or not ready then
			return
		end

		setState2(true)
		task.spawn(function()
			local cook2 = p.Handlers.Cook()
			setState2(false)

			if cook2 == "Cooked" or cook2 == "NoChef" then
				p.Handlers.Close()
			end
		end)
	end

	local children = {}

	for k, material in state.Recipe do
		local v4 = material
		children[material] = createElement(Slot, {
			Material = material,
			InPot = v[material] == true,
			Owned = state.Owned[material] or 0,
			LayoutOrder = k,
			OnActivated = function()
				local v5 = v4

				if not state2 then
					if v[v5] then
						return
					end

					setState2(true)
					task.spawn(function()
						local v6 = p.Handlers.Insert(v5)

						if v6 then
							setState(v6)
						end

						setState2(false)
					end)
				end
			end
		})
	end

	local v3 = {
		Grid = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = uDim2,
			Size = uDim3
		}, {
			Aspect = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Height
			}),
			Layout = createElement("UIGridLayout", {
				CellPadding = uDim5,
				CellSize = uDim4,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Slots = createElement(React.Fragment, {}, children)
		}),
		Arrow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://109323886099551",
			ImageTransparency = ready and 0 or 0.55,
			Position = uDim6,
			ScaleType = Enum.ScaleType.Fit,
			Size = uDim7
		}, {
			Gradient = createElement("UIGradient", {
				Color = colorSequence
			})
		}),
		Result = createElement(Result, {
			Ready = ready
		})
	}
	local v4 = {
		Aspect = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.6
		}),
		SizeLimits = createElement("UISizeConstraint", {
			MinSize = vector,
			MaxSize = vector2
		}),
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.PALETTE.BLACK,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Header = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.fromScale(1, 0.1366),
			Position = UDim2.fromScale(0, 0)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.8),
				Text = "THE CHEF'S RECIPE",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "THE CHEF'S RECIPE",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			Close = createElement(SimpleButton, {
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
				BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
				HighlightColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				AnchorPoint = Vector2.new(1, 0.5),
				HighlightVariant = "Centered",
				Icon = {
					Image = "rbxassetid://127503254560275",
					ImageRectSize = Vector2.new(100, 100),
					ImageRectOffset = Vector2.zero
				},
				IconSize = UDim2.fromScale(1, 1),
				LayoutOrder = -999,
				Position = UDim2.fromScale(0.99, 0.5),
				Size = UDim2.fromScale(0.0738499, 0.748107),
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.Activated] = p.Handlers.Close
			})
		}),
		Body = createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.1366),
			Size = UDim2.fromScale(1, 0.69)
		}, v3),
		Cook = createElement(SimpleButton, {
			Label = "COOK",
			HighlightColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
			AutomaticSize = Enum.AutomaticSize.None,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.9135),
			Size = UDim2.fromScale(0.4, 0.1557),
			Active = true,
			[React.Event.Activated] = cook
		})
	}
	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, {
		Backdrop = createElement("Frame", {
			Active = true,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1)
		}),
		Panel = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			AutomaticSize = Enum.AutomaticSize.None,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = uDim
		}, v4)
	})
end

local CauldronMenu = {
	Menu = Menu
}
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyHandle(p)
	p.root:unmount()
	p.gui:Destroy()
end

function CauldronMenu.isOpen()
	return v ~= nil
end

function CauldronMenu.close()
	local v2 = v

	if not v2 then
		return
	end

	local handlers = v2.handlers

	if handlers then
		handlers.Close()
		return
	end

	v = nil
	destroyHandle(v2) -- equivalent call inferred; original call site unknown
end

function CauldronMenu.open(state, props)
	if v then
		return
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ChefsKissCauldron"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.DisplayOrder = 60
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local root = ReactRoblox.createRoot(screenGui)
	local v2 = {
		root = root,
		gui = screenGui,
		handlers = nil
	}
	v = v2
	local handlers = {
		Insert = props.Insert,
		Cook = props.Cook,
		Close = function()
			if v ~= v2 then
				return
			end

			v = nil
			task.defer(destroyHandle, v2)
			props.Close()
		end
	}
	v2.handlers = handlers
	root:render(createElement(Menu, {
		State = state,
		Handlers = handlers
	}))
end

function CauldronMenu.update(state)
	local v2 = v

	if not v2 then
		return
	end

	v2.root:render(createElement(Menu, {
		State = state,
		Handlers = v2.handlers
	}))
end

return CauldronMenu