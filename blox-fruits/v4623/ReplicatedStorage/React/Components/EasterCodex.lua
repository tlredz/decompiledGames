local React = require(game.ReplicatedStorage.Packages.React)
local EasterEggs = require(game.ReplicatedStorage.Modules.Data.EasterEggs)
local Easter2026 = require(game.ReplicatedStorage.EventConfig.Easter2026)
local Timer = require(script.Timer)
local RewardTrack = require(script.RewardTrack)
local EggTile = require(script.EggTile)
local useTimer = require(game.ReplicatedStorage.React.Hooks.Easter.useTimer)
local useTotalEggs = require(game.ReplicatedStorage.React.Hooks.Easter.useTotalEggs)
local useItemChanged = require(game.ReplicatedStorage.React.Hooks.Easter.useItemChanged)
local useIndex = require(game.ReplicatedStorage.React.Hooks.Easter.useIndex)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local unixTimestamp = Easter2026.START_AT:ToDateTimeUTC().UnixTimestamp
local unixTimestamp2 = Easter2026.NO_MORE_GAMEPLAY_AT:ToDateTimeUTC().UnixTimestamp
local uDim = UDim2.new(0.5, 0, 0.460396, 0)
local uDim2 = UDim2.new(0.5, 0, 1.5, 0)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local createElement = React.createElement

local function fn()
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local children = {
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0.003, 0),
			PaddingTop = UDim.new(0.003, 0),
			PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.XL
		}),
		UIGridLayout = createElement("UIGridLayout", {
			ref = ref,
			CellPadding = UDim2.fromScale(0.016, 0.017),
			CellSize = UDim2.fromScale(0.15066666666666667, 1),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, {
			UIAspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.8
			})
		})
	}
	local v = useIndex()

	for k, v2 in pairs(EasterEggs.List) do
		assert(children[k] == nil, (`{k} is duped`))
		local numOwned = useItemChanged(k)
		local v4 = v[k]
		children[k] = createElement(EggTile, {
			Name = k,
			NumOwned = numOwned,
			IsNew = v4 and v4.IsNew == true and true or false,
			LayoutOrder = v2.Id
		})
	end

	local state, setState = React.useState(2)
	React.useEffect(function()
		if not (ref.current and ref2.current) then
			return nil
		end

		local thread = nil
		local flag = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tryCancel()
			if thread then
				task.cancel(thread)
				thread = nil
			end
		end

		local function update()
			tryCancel() -- equivalent call inferred; original call site unknown

			if flag then
				setState(ref.current.AbsoluteContentSize.Y + 5)
			else
				thread = task.delay(0.2, function()
					thread = nil
					setState(ref.current.AbsoluteContentSize.Y + 5)
				end)
			end

			flag = false
		end

		update()
		local absoluteContentSizeChangedConnection = ref.current:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		return function()
			absoluteContentSizeChangedConnection:Disconnect()
			tryCancel() -- equivalent call inferred; original call site unknown
		end
	end, { ref.current, ref2.current })
	return createElement("ScrollingFrame", {
		ref = ref2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		Position = UDim2.fromScale(0.5, 0.540369),
		ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.REGULAR,
		Size = UDim2.fromScale(0.97, 0.862778),
		CanvasSize = React.useMemo(function()
			if ref.current and ref2.current then
				ref2.current.CanvasSize = UDim2.new(0, 0, 0, state)
			end
		end, { state, ref.current, ref2.current })
	}, children)
end

return function(props)
	local seconds = useTimer(props.TimeStarts or unixTimestamp, props.TimeEnds or unixTimestamp2)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local v2 = nil

		if ref.current then
			if props.IsOpen == true then
				local TweenService = game:GetService("TweenService")
				v2 = TweenService:Create(ref.current, tweenInfo, {
					Position = uDim
				})
			elseif props.IsOpen == false then
				local TweenService = game:GetService("TweenService")
				v2 = TweenService:Create(ref.current, tweenInfo2, {
					Position = uDim2
				})
			else
				ref.current.Position = uDim
			end

			if v2 then
				v2:Play()
				v2.Completed:Once(function(p)
					if p == Enum.PlaybackState.Completed and props.OnFinish then
						props.OnFinish()
					end
				end)
			elseif props.OnFinish then
				props.OnFinish()
			end
		end

		return function()
			if v2 then
				v2:Cancel()
				v2 = nil
			end
		end
	end, { props.IsOpen })
	local v2 = useTotalEggs()
	local v5 = {
		ref = ref,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		Position = 0,
		Size = 0,
		ZIndex = 0
	}
	local position

	if props.IsOpen == nil then
		position = uDim
	else
		position = uDim2
	end

	v5.Position = position
	v5.Size = UDim2.fromScale(0.543877, 0.605178)
	v5.ZIndex = CONSTANTS.LAYER.RAISED
	return createElement("Frame", v5, {
		Main = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0, 0.11846),
			Size = UDim2.fromScale(1, 0.88154),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			ScrollingFrame = createElement(fn),
			TimeImageLabel = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://82808720915825",
				Position = UDim2.fromScale(0.02, 0.0598576),
				Size = UDim2.fromScale(0.0340631, 0.0593359)
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Title = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Position = UDim2.fromScale(4.11071e-8, 7.19374e-8),
			Size = UDim2.fromScale(1, 0.121284)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			Title = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.75),
				Text = "Easter Egg Hunt Codex",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "Easter Egg Hunt Codex",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			Close = createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
				BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
				LayoutOrder = -999,
				Position = UDim2.fromScale(0.985, 0.5),
				Size = UDim2.fromScale(0.0518086, 0.747541),
				Text = "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.Activated] = function()
					if props.OnClose then
						props.OnClose()
					end
				end
			}, {
				Trans = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.94, 0.47),
					ZIndex = CONSTANTS.LAYER.RAISED
				}),
				Icon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://127503254560275",
					ImageRectSize = Vector2.new(100, 100),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				}),
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			EggTopRight1 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.4, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://88521607622333",
				ImageRectOffset = Vector2.new(408, 0),
				ImageRectSize = Vector2.new(136, 168),
				Position = UDim2.fromScale(0.991123, 0),
				Rotation = 20,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.0516255, 0.620823)
			}),
			EggTopRight2 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://88521607622333",
				ImageRectOffset = Vector2.new(272, 0),
				ImageRectSize = Vector2.new(136, 168),
				Position = UDim2.fromScale(0.92, 0.772818),
				Rotation = -45,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.07712, 0.822388)
			}),
			EggTopLeft2 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://88521607622333",
				ImageRectOffset = Vector2.new(136, 0),
				ImageRectSize = Vector2.new(136, 168),
				Position = UDim2.fromScale(0.0508986, 0.713561),
				Rotation = 20,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.0530466, 0.834537)
			}),
			EggTopLeft1 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://88521607622333",
				ImageRectSize = Vector2.new(136, 168),
				Position = UDim2.fromScale(0.0097743, 0.155303),
				Rotation = -15,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.0550797, 0.668644)
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(212, 255, 120)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(171, 251, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 179, 255))
				})
			})
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.6
		}),
		RewardsContainer = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1.125, 0.5),
			Size = UDim2.fromScale(0.100891, 1)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			UIPadding = createElement("UIPadding", {
				PaddingTop = UDim.new(0, 3),
				PaddingLeft = UDim.new(0, 3)
			}),
			RewardTrack = createElement(RewardTrack, {
				OnClaim = props.OnClaim
			})
		}),
		CollectedLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Regular, Enum.FontStyle.Italic),
			Position = UDim2.fromScale(0.813829, 0.172211),
			Size = UDim2.fromScale(0.338489, 0.053509),
			Text = React.useMemo(function()
				return (`{v2}/{EasterEggs.Total} Eggs Collected`)
			end, { v2 }),
			TextColor3 = Color3.fromRGB(191, 191, 191),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right
		}),
		Timer = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.234, 0.172211),
			Size = UDim2.fromScale(0.347347, 0.053509)
		}, {
			TextLabel = Timer({
				Seconds = seconds
			})
		})
	})
end