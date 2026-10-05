local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.Util.Maid)
local createElement = React.createElement

local function FloorDiamond(props)
	local hasBoss

	if props.FloorReplicationFolder then
		hasBoss = props.FloorReplicationFolder:GetAttribute("HasBoss") or false
	else
		hasBoss = false
	end

	local v = {
		Size = hasBoss and UDim2.new(1, 0, 1, 0) or UDim2.new(0.8, 0, 0.8, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Rotation = 45,
		ZIndex = 10
	}
	local color

	if hasBoss then
		color = Color3.fromRGB(220, 0, 0)
	elseif props.IsExplored then
		color = Color3.fromRGB(255, 214, 49)
	else
		color = Color3.fromRGB(158, 158, 158)
	end

	v.BackgroundColor3 = color
	local v4 = {
		UIStroke = createElement("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Transparency = 0,
			ZIndex = 1
		}),
		Highlight = 0
	}
	local v7 = {
		Size = UDim2.new(0.8, 0, 0.8, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = 0,
		AnchorPoint = 0,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 11
	}
	local color2

	if hasBoss then
		color2 = Color3.fromRGB(255, 0, 0)
	elseif props.IsExplored then
		color2 = Color3.fromRGB(255, 241, 87)
	else
		color2 = Color3.fromRGB(191, 191, 191)
	end

	v7.BackgroundColor3 = color2
	v7.AnchorPoint = Vector2.new(0.5, 0.5)
	v4.Highlight = createElement("Frame", v7, {
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Rotation = 45,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.498, 0),
				NumberSequenceKeypoint.new(0.503, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	local diamond = createElement("Frame", v, v4)
	local v11 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 2
	}
	local v12 = {
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
			DominantAxis = Enum.DominantAxis.Width,
			AspectType = Enum.AspectType.FitWithinMaxSize
		}),
		Connection = 0,
		Diamond = 0,
		LevelIndicator = 0
	}
	local v15 = {
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(1.297, 0, 0.162, 0),
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		ZIndex = 1,
		Visible = 0
	}
	local backgroundColor

	if props.CanConnect then
		backgroundColor = Color3.fromRGB(248, 216, 86)
	else
		backgroundColor = Color3.fromRGB(191, 191, 191)
	end

	v15.BackgroundColor3 = backgroundColor
	v15.Visible = not props.IsLast
	v12.Connection = createElement("Frame", v15)
	v12.Diamond = diamond
	v12.LevelIndicator = createElement("TextLabel", {
		Size = hasBoss and UDim2.new(1.1, 0, 1.1, 0) or UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5 - (props.FloorId == 4 and 0.025 or 0), 0, 0.48, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = tostring(props.FloorId + 0) or "?",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Font = Enum.Font.SourceSansBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 20
	}, {
		UIStroke = createElement("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Transparency = 0,
			ZIndex = 3
		})
	})
	return (createElement("Frame", v11, v12))
end

local function FloorDiamondsListContainer(p)
	local v2 = {
		Size = UDim2.new(0.639, 0, 0.65, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = false
	}
	local element = createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		VerticalFlex = "None",
		ItemLineAlignment = "Automatic",
		HorizontalFlex = "None",
		Wraps = false,
		Padding = UDim.new(0.12, 0)
	})
	local v3 = math.max(1, math.floor((p.currentExploredFloor - 1) / 5) * 5 + 1)
	local children = {}
	local v4 = {}

	for i = v3, v3 + 4 do
		table.insert(children, createElement(FloorDiamond, {
			FloorReplicationFolder = p.floorFolders:FindFirstChild((tostring(i))),
			IsLast = i == v3 + 4,
			LayoutOrder = i,
			FloorId = i,
			IsExplored = i <= p.currentExploredFloor,
			CanConnect = i < p.currentExploredFloor
		}))
	end

	v4[1], v4[2] = element, children
	return (createElement("Frame", v2, v4))
end

local function FloorCounter(p)
	local ref = React.useRef(p.DungeonFolder:GetAttribute("ShowTimer") or false)
	local ref2 = React.useRef(p.DungeonFolder:GetAttribute("ShowEnemyCounter") or false)
	local ref3 = React.useRef(p.DungeonFolder:GetAttribute("HasBoss") or false)
	local state, setState = React.useState(1)
	local ref4 = React.useRef("")
	local ref5 = React.useRef(Color3.fromRGB(255, 255, 255))
	local ref6 = React.useRef(0.5)
	local ref7 = React.useRef(Color3.fromRGB(0, 0, 0))
	React.useEffect(function()
		local function updateCurrentFloor()
			setState(p.DungeonFolder:GetAttribute("CurrentExploredLevel") or 1)
		end

		local currentExploredLevelChangedConnection = p.DungeonFolder:GetAttributeChangedSignal("CurrentExploredLevel"):Connect(updateCurrentFloor)
		local thread = nil

		local function updateEnemyCount()
			local deadEnemies = p.DungeonFolder:GetAttribute("DeadEnemies") or 0
			local totalEnemies = p.DungeonFolder:GetAttribute("TotalEnemies") or 0

			if thread then
				task.cancel(thread)
				thread = nil
			end

			if deadEnemies > 0 then
				local v = (deadEnemies + 1) / (totalEnemies + 1)
				ref5.current = Color3.fromRGB(255, 255, 255):Lerp(Color3.new(1, 0, 0), v * v * v)
				thread = task.spawn(function()
					ref6.current = 0.5
					ref7.current = Color3.fromRGB(255, 255, 255)

					repeat
						local v2 = task.wait() * 2
						ref7.current = Color3.new(1, 1, 1)
						ref6.current -= 0.05 * v2 * 60
						ref7.current = Color3.new(1, 1, 1):Lerp(Color3.new(0, 0, 0), ref6.current * 2)
					until ref6.current <= 0

					ref4.current = `{deadEnemies}/{totalEnemies}`

					repeat
						local v2 = task.wait()
						ref7.current = Color3.new(1, 1, 1)
						ref6.current += 0.05 * v2 * 60
						ref7.current = Color3.new(1, 1, 1):Lerp(Color3.new(0, 0, 0), ref6.current * 2)
					until ref6.current >= 0.5

					ref6.current = 0.5
					ref7.current = Color3.fromRGB(0, 0, 0)
				end)
			else
				ref6.current = 0.5
				ref7.current = Color3.fromRGB(0, 0, 0)
				ref5.current = Color3.fromRGB(255, 255, 255)
				ref4.current = `{deadEnemies}/{totalEnemies}`
			end
		end

		updateEnemyCount()
		local totalEnemiesChangedConnection = p.DungeonFolder:GetAttributeChangedSignal("TotalEnemies"):Connect(updateEnemyCount)
		local deadEnemiesChangedConnection = p.DungeonFolder:GetAttributeChangedSignal("DeadEnemies"):Connect(updateEnemyCount)
		return function()
			currentExploredLevelChangedConnection:Disconnect()
			totalEnemiesChangedConnection:Disconnect()
			deadEnemiesChangedConnection:Disconnect()
		end
	end, { p })
	React.useMemo(function()
		local child = p.DungeonFolder:FindFirstChild("Floors"):FindFirstChild((tostring(state)))
		local visible = ref
		local current

		if child then
			current = child:GetAttribute("ShowTimer") or false
		else
			current = false
		end

		visible.current = current
		local v3 = ref3
		local current2

		if child then
			current2 = child:GetAttribute("HasBoss") or false
		else
			current2 = false
		end

		v3.current = current2
		ref2.current = not (ref3.current or not child) and (child:GetAttribute("ShowEnemyCounter") or false)
	end, { state })
	return (createElement("Frame", {
		Size = UDim2.new(0.426, 0, 0.086, 0),
		Position = UDim2.new(0.5, 0, 0.017, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Style = Enum.FrameStyle.Custom,
		ClipsDescendants = false,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 0
	}, {
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 8.818
		}),
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(450, 450),
			MinSize = Vector2.new(0, 0)
		}),
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.298, 0),
				NumberSequenceKeypoint.new(0.701, 0.0125),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		Diamonds = React.useMemo(function()
			return createElement(FloorDiamondsListContainer, {
				currentExploredFloor = state,
				floorFolders = p.DungeonFolder:FindFirstChild("Floors")
			})
		end, { state }),
		SecondaryInfo = createElement("Frame", {
			Size = UDim2.new(0.818, 0, 0.95, 0),
			Position = UDim2.new(0.5, 0, 0.97, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = true
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				VerticalFlex = "None",
				ItemLineAlignment = "Automatic",
				HorizontalFlex = "None",
				Wraps = false,
				Padding = UDim.new(0.02, 0)
			}),
			EnemiesLeft = createElement("ImageLabel", {
				Size = UDim2.new(0.409, 0, 0.879, 0),
				Position = UDim2.new(0.426, 0, 0.97, 0),
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://122150060492757",
				ImageColor3 = ref7,
				ImageTransparency = ref6,
				ResampleMode = "Default",
				ScaleType = "Stretch",
				Visible = ref2,
				LayoutOrder = 2
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					VerticalFlex = "None",
					ItemLineAlignment = "Automatic",
					HorizontalFlex = "None",
					Wraps = false,
					Padding = UDim.new(0.02, 0)
				}),
				Timer = createElement("ImageLabel", {
					Size = UDim2.new(0.6, 0, 0.6, 0),
					Position = UDim2.new(0, 0, 0, 0),
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = "rbxassetid://87986492321337",
					ImageColor3 = Color3.new(1, 1, 1),
					ImageTransparency = 0,
					ResampleMode = "Default",
					ScaleType = "Stretch",
					LayoutOrder = 1
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
						DominantAxis = Enum.DominantAxis.Width,
						AspectType = Enum.AspectType.FitWithinMaxSize
					})
				}),
				TextLabel = createElement("TextLabel", {
					Size = UDim2.new(0.381, 0, 0.6, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = ref4,
					TextColor3 = ref5,
					TextScaled = true,
					Font = Enum.Font.RobotoMono,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ClipsDescendants = false,
					LayoutOrder = 2
				})
			}),
			Timer = createElement("ImageLabel", {
				Size = UDim2.new(0.409, 0, 0.879, 0),
				Position = UDim2.new(0.162, 0, 0.97, 0),
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://122150060492757",
				ImageColor3 = Color3.new(0, 0, 0),
				ImageTransparency = 0.5,
				ResampleMode = "Default",
				ScaleType = "Stretch",
				Visible = ref,
				LayoutOrder = 1
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					VerticalFlex = "None",
					ItemLineAlignment = "Automatic",
					HorizontalFlex = "None",
					Wraps = false,
					Padding = UDim.new(0.02, 0)
				}),
				Timer = createElement("ImageLabel", {
					Size = UDim2.new(0.6, 0, 0.6, 0),
					Position = UDim2.new(0, 0, 0, 0),
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = "rbxassetid://139139968199665",
					ImageColor3 = Color3.new(1, 1, 1),
					ImageTransparency = 0,
					ResampleMode = "Default",
					ScaleType = "Stretch"
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
						DominantAxis = Enum.DominantAxis.Width,
						AspectType = Enum.AspectType.FitWithinMaxSize
					})
				}),
				TextLabel = createElement("TextLabel", {
					Size = UDim2.new(0.35, 0, 0.6, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = p.TimerValue,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					Font = Enum.Font.RobotoMono,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					RichText = true,
					ClipsDescendants = false
				})
			})
		})
	}))
end

return FloorCounter