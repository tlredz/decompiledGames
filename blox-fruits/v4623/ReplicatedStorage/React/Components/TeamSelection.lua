local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local TextUtil = require(ReplicatedStorage.Modules.Util.TextUtil)
local useClock = require(ReplicatedStorage.React.Hooks.useClock)
local useToggledState = require(ReplicatedStorage.React.Hooks.useToggledState)
local useViewportSize = require(ReplicatedStorage.React.Hooks.useViewportSize)
local Util = require(ReplicatedStorage.React.Util)
local tweenBinding = Util.tweenBinding
local LimbFlicker = require(ReplicatedStorage.Util.LimbFlicker)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local Notification

if GlobalUtil.FFlags.IsUnitTest then
	Notification = nil
else
	Notification = require(game.ReplicatedStorage.Notification)
end

local flag = false

local function change(p: string)
	if Players.LocalPlayer == nil or flag then
		return
	end

	flag = true

	if Notification then
		Notification.new("Joining..."):Display()
	end

	if pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", p)
	end) then
		local localPlayer = Players.LocalPlayer

		repeat
			task.wait()
		until localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Characters)
	else
		flag = false

		if Notification then
			Notification.new("<Color=Red>Player data still not ready, please wait and try again.<Color=/>"):Display()
		end
	end
end

local function format(p: number)
	return TextUtil.commaValue(p)
end

local createElement = React.createElement
return function(_)
	local localPlayer = Players.LocalPlayer
	local v, v2 = React.useBinding(0)
	local v3, v4 = React.useBinding(0)
	local v5, v6 = React.useBinding(0)
	local v7, v8 = React.useBinding(0)
	local v9 = useToggledState(false)
	local v10 = useToggledState(false)
	local v11 = useToggledState(false)
	local v12 = useToggledState(false)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(nil)
	local v13 = useClock()
	local v14 = useViewportSize()
	local scale = math.min(v14.X, v14.Y) <= 500 and 1 or 0.8
	React.useEffect(function()
		local v16 = v9.on and 1 or 0
		tweenBinding(v, v2, v16, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		if ref3.current ~= nil then
			ref3.current:AdjustWeight(math.max(v16, 0.001), 0.25)
		end
	end, { v9.on })
	React.useEffect(function()
		tweenBinding(v3, v4, v10.on and 1 or 0, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end, { v10.on })
	React.useEffect(function()
		local v16 = v11.on and 1 or 0
		tweenBinding(v5, v6, v16, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		if ref4.current ~= nil then
			ref4.current:AdjustWeight(math.max(v16, 0.001), 0.25)
		end
	end, { v11.on })
	React.useEffect(function()
		tweenBinding(v7, v8, v12.on and 1 or 0, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end, { v12.on })
	local state, setState = React.useState({
		Bounty = 0,
		Honor = 0
	})
	React.useEffect(function()
		local initBountyChangedConnection, initHonorChangedConnection

		if localPlayer == nil then
			initBountyChangedConnection = nil
			initHonorChangedConnection = nil
		else
			local initBounty = localPlayer:GetAttribute("InitBounty") or 0
			local initHonor = localPlayer:GetAttribute("InitHonor") or 0

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				setState({
					Bounty = initBounty,
					Honor = initHonor
				})
			end

			initBountyChangedConnection = localPlayer:GetAttributeChangedSignal("InitBounty"):Connect(function()
				initBounty = localPlayer:GetAttribute("InitBounty") or 0
				update() -- equivalent call inferred; original call site unknown
			end)
			initHonorChangedConnection = localPlayer:GetAttributeChangedSignal("InitHonor"):Connect(function()
				initHonor = localPlayer:GetAttribute("InitHonor") or 0
				update() -- equivalent call inferred; original call site unknown
			end)
			update() -- equivalent call inferred; original call site unknown
		end

		return function()
			if initBountyChangedConnection ~= nil then
				initBountyChangedConnection:Disconnect()
				initBountyChangedConnection = nil
			end

			if initHonorChangedConnection ~= nil then
				initHonorChangedConnection:Disconnect()
				initHonorChangedConnection = nil
			end
		end
	end, { localPlayer })
	React.useEffect(function()
		local flag2 = false
		task.spawn(function()
			if ref.current then
				local menuPirate = ReplicatedStorage:WaitForChild("MenuPirate", 20)

				if flag2 then
					return
				end

				if menuPirate then
					local clone = menuPirate:Clone()
					LimbFlicker.fix(clone)
					local model = ref.current:FindFirstChildOfClass("Model")

					if model then
						model:Destroy()
					end

					task.spawn(function()
						repeat
							task.wait()
						until clone.Parent and clone:IsDescendantOf(game)

						if clone:FindFirstChild("Animation") then
							return
						end

						local animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://112500829580510"
						animation.Parent = clone
						local animation2 = Instance.new("Animation")
						animation2.AnimationId = "rbxassetid://73822708531083"
						animation2.Parent = clone
						local track = clone.Humanoid:LoadAnimation(animation2)
						track.Looped = true
						ref3.current = track
						track:Play(nil, 0.001, nil)
						clone.Humanoid:LoadAnimation(animation):Play(0, 1, 1)
					end)
					clone.HumanoidRootPart.Anchored = true
					clone:PivotTo(CFrame.new(-0.1, -1.2, -4) * CFrame.Angles(0, -2.6179938779914944, 0))
					clone.Parent = ref.current
				end
			end
		end)
		return function()
			flag2 = true
			ref3.current = nil
		end
	end, { ref.current })
	React.useEffect(function()
		local flag2 = false
		task.spawn(function()
			if ref2.current then
				local menuMarine = ReplicatedStorage:WaitForChild("MenuMarine", 20)

				if flag2 then
					return
				end

				if menuMarine then
					local clone = menuMarine:Clone()
					LimbFlicker.fix(clone)
					local model = ref2.current:FindFirstChildOfClass("Model")

					if model then
						model:Destroy()
					end

					task.spawn(function()
						repeat
							task.wait()
						until clone.Parent and clone:IsDescendantOf(game)

						if clone:FindFirstChild("Animation") then
							return
						end

						local animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://112500829580510"
						animation.Parent = clone
						local animation2 = Instance.new("Animation")
						animation2.AnimationId = "rbxassetid://112759065109026"
						animation2.Parent = clone
						local track = clone.Humanoid:LoadAnimation(animation2)
						track.Looped = true
						ref4.current = track
						track:Play(nil, 0.001, nil)
						clone.Humanoid:LoadAnimation(animation):Play(0, 1, 1)
					end)
					clone.HumanoidRootPart.Anchored = true
					clone:PivotTo(CFrame.new(0.2, -3.6, -4) * CFrame.Angles(0, 2.6179938779914944, 0))
					clone.Parent = ref2.current
				end
			end
		end)
		return function()
			flag2 = true
		end
	end, { ref2.current })
	local v17 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1)
	}
	local v18 = {
		header = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.114202),
			Size = UDim2.fromScale(0.47326, 0.071708)
		}, {
			uIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.30137, 0),
					NumberSequenceKeypoint.new(0.701121, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.525),
				Size = UDim2.fromScale(0.9, 0.8),
				Text = "Pick A Side!",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			})
		}),
		playButton = createElement("TextButton", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.SECONDARY.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.014652, 0.977836),
			Size = UDim2.fromScale(0.119049, 0.057567),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.96, 0.45)
			}),
			uISizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(175, 55),
				MinSize = Vector2.new(32, 32)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.95, 0.75),
				Text = "Fast Mode",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.05
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.425),
					Size = UDim2.fromScale(1, 1),
					Text = "Fast Mode",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						Thickness = 0.05
					})
				})
			})
		}),
		content = 0
	}
	local v20 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.571421, 0.620159)
	}
	local v22 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = -1
	}
	local v23 = {
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.81
		}),
		pirate = 0
	}
	local v25 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://85220450463423",
		ImageRectOffset = v:map(function(p: number)
			return Vector2.new(p > 0.5 and 434 or 0, 0)
		end),
		ImageRectSize = Vector2.new(434, 512),
		Size = v3:map(function(p: number)
			local v26 = math.lerp(1, 0.95, p)
			return UDim2.fromScale(v26, v26)
		end),
		Position = v13:map(function(p: number)
			return UDim2.fromScale(0.5, 0.5 + (math.sin(p) * 0.01 + -0.05) * v:getValue())
		end),
		[React.Event.MouseButton1Down] = function()
			v10.enable()
			change("Pirates")
		end,
		[React.Event.MouseButton1Up] = v10.disable,
		[React.Event.MouseEnter] = v9.enable,
		[React.Event.MouseLeave] = v9.disable
	}
	local children2 = {
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.81
		}),
		brush = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://97360618731415",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			Position = UDim2.fromScale(-0.078, 0.67),
			Size = UDim2.fromScale(1.01107, 0.189108),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			imageLabel = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://97360618731415",
				Position = UDim2.fromScale(0.48, 0.385),
				Size = UDim2.fromScale(1, 1)
			}, {
				uIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 0, 0)),
						ColorSequenceKeypoint.new(0.455959, Color3.fromRGB(195, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 133, 133))
					}),
					Rotation = -90
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.546076, 0.55),
					Size = UDim2.fromScale(0.734497, 0.8),
					Text = "PIRATES",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						Thickness = 0.035
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.TITLE,
						Position = UDim2.fromScale(0.5, 0.45),
						Size = UDim2.fromScale(1, 1),
						Text = "PIRATES",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true
					}, {
						uIStroke = createElement("UIStroke", {
							StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
							Thickness = 0.035
						})
					})
				})
			})
		}),
		textLabel = 0,
		imageLabel = 0,
		viewportFrame = 0,
		description = 0
	}
	local v27 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 0.905),
		Size = UDim2.fromScale(0.85, 0.0787426),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		ZIndex = 0
	}
	local bounty = state.Bounty
	v27.Text = `Bounty: ${TextUtil.commaValue(bounty)}`
	v27.TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK
	v27.ZIndex = CONSTANTS.LAYER.RAISED
	local v28 = {
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		}),
		textLabel = 0
	}
	local v30 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 0.425),
		Size = UDim2.fromScale(1, 1),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true
	}
	local bounty2 = state.Bounty
	v30.Text = `Bounty: ${TextUtil.commaValue(bounty2)}`
	v30.TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	v28.textLabel = createElement("TextLabel", v30, {
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		})
	})
	children2.textLabel = createElement("TextLabel", v27, v28)
	children2.imageLabel = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://74108443213821",
		ImageColor3 = Color3.fromRGB(45, 0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.3, 1.3),
		ZIndex = CONSTANTS.LAYER.BASE
	})
	children2.viewportFrame = createElement("ViewportFrame", {
		BackgroundColor3 = Color3.fromRGB(48, 2, 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.925, 1),
		ZIndex = CONSTANTS.LAYER.CONTENT
	}, {
		wm = createElement("WorldModel", {
			ref = ref
		}),
		uIGradient = createElement("UIGradient", {
			Rotation = 91.5,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.96264, 0),
				NumberSequenceKeypoint.new(0.965131, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	children2.description = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 1.13055),
		Size = UDim2.fromScale(1.2, 0.221095),
		Text = [[
Defy the marines and battle pirates!
Create your own pirate crew!
Get a high player bounty!]],
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true
	}, {
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.465),
			Size = UDim2.fromScale(1, 1),
			Text = [[
Defy the marines and battle pirates!
Create your own pirate crew!
Get a high player bounty!]],
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}, {
			uIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.05
			})
		})
	})
	v23.pirate = createElement("ImageButton", v25, children2)
	local children = {
		pirateFrame = createElement("Frame", v22, v23),
		uIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		marineFrame = 0,
		folder = 0,
		uIScale = 0,
		uIAspectRatioConstraint = 0
	}
	local v32 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = 1
	}
	local v33 = {
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.81
		}),
		marine = 0
	}
	local v35 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://117883459036704",
		ImageRectOffset = v5:map(function(p: number)
			return Vector2.new(p > 0.5 and 433 or 0, 0)
		end),
		ImageRectSize = Vector2.new(433, 512),
		Size = v7:map(function(p: number)
			local v36 = math.lerp(1, 0.95, p)
			return UDim2.fromScale(v36, v36)
		end),
		Position = v13:map(function(p: number)
			return UDim2.fromScale(0.5, 0.5 + (math.sin(p) * 0.01 + -0.05) * v5:getValue())
		end),
		[React.Event.MouseButton1Down] = function()
			v12.enable()
			change("Marines")
		end,
		[React.Event.MouseButton1Up] = v12.disable,
		[React.Event.MouseEnter] = v11.enable,
		[React.Event.MouseLeave] = v11.disable
	}
	local children3 = {
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.81
		}),
		textLabel = 0,
		imageLabel = 0,
		brush = 0,
		viewportFrame = 0,
		description = 0
	}
	local v37 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 0.905),
		Size = UDim2.fromScale(0.85, 0.0787426),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		ZIndex = 0
	}
	local honor = state.Honor
	v37.Text = `Honor: ${TextUtil.commaValue(honor)}`
	v37.TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK
	v37.ZIndex = CONSTANTS.LAYER.RAISED
	local v38 = {
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		}),
		textLabel = 0
	}
	local v40 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 0.425),
		Size = UDim2.fromScale(1, 1),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true
	}
	local honor2 = state.Honor
	v40.Text = `Honor: ${TextUtil.commaValue(honor2)}`
	v40.TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	v38.textLabel = createElement("TextLabel", v40, {
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		})
	})
	children3.textLabel = createElement("TextLabel", v37, v38)
	children3.imageLabel = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://74108443213821",
		ImageColor3 = Color3.fromRGB(0, 17, 35),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.3, 1.3),
		ZIndex = CONSTANTS.LAYER.BASE
	})
	children3.brush = createElement("ImageLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://95362816320725",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		Position = UDim2.fromScale(0.108456, 0.67),
		Size = UDim2.fromScale(1.01107, 0.189108),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		imageLabel = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://95362816320725",
			Position = UDim2.fromScale(0.48, 0.385),
			Size = UDim2.fromScale(1, 1)
		}, {
			uIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 73, 170)),
					ColorSequenceKeypoint.new(0.455959, Color3.fromRGB(23, 121, 204)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 185, 246))
				}),
				Rotation = -90
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.45, 0.55),
				Size = UDim2.fromScale(0.734497, 0.8),
				Text = "MARINES",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = 4
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.035
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "MARINES",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = CONSTANTS.LAYER.OVERLAY
				}, {
					uIStroke = createElement("UIStroke", {
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						Thickness = 0.035
					})
				})
			})
		})
	})
	children3.viewportFrame = createElement("ViewportFrame", {
		BackgroundColor3 = Color3.fromRGB(5, 38, 63),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.925, 1),
		ZIndex = CONSTANTS.LAYER.CONTENT
	}, {
		wm = createElement("WorldModel", {
			ref = ref2
		}),
		uIGradient = createElement("UIGradient", {
			Rotation = 88.5,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.96264, 0),
				NumberSequenceKeypoint.new(0.965131, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	children3.description = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 1.131),
		Size = UDim2.fromScale(1.2, 0.221),
		Text = [[
Team up on pirates!
Faster, cheaper ships!
Claim bounties!]],
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true
	}, {
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.05
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.465),
			Size = UDim2.fromScale(1, 1),
			Text = [[
Team up on pirates!
Faster, cheaper ships!
Claim bounties!]],
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}, {
			uIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.05
			})
		})
	})
	v33.marine = createElement("ImageButton", v35, children3)
	children.marineFrame = createElement("Frame", v32, v33)
	children.folder = createElement("Folder", nil, {
		imageLabel = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://74108443213821",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			ImageTransparency = 0.57,
			Position = UDim2.fromScale(0.5, 0.56865),
			Size = UDim2.fromScale(0.219939, 0.275495)
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.860942, 0.586473),
				Text = "VS",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.035
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "VS",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						Thickness = 0.035
					})
				})
			})
		})
	})
	children.uIScale = createElement("UIScale", {
		Scale = scale
	})
	children.uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 1.87537
	})
	v18.content = createElement("Frame", v20, children)
	return createElement("Frame", v17, v18)
end