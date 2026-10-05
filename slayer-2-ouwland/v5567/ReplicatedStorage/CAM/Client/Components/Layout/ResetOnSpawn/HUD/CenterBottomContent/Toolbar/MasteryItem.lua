local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2, Enum.EasingStyle.Back)
local info2 = faye.Info(0.2)

function GetList(object, p, udim: UDim)
	return object:Create("UIListLayout")({
		Name = "List",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = p or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = udim or UDim.new(0, 10)
	})
end

local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
return function(maid, data2)
	local size = maid:Value(UDim2.fromScale(0.5, 1))
	local text = maid:Value("5 / 10")
	local text2 = maid:Value("Lv 1")
	local incrementAmount = data2.Mastery ~= nil and data2.Mastery.IncrementAmount or gameSettings.expPerMasteryDefault

	local function updateMasteryThing(value4, p)
		local v = value4 or 0
		local v2 = p or incrementAmount
		size:Set(UDim2.fromScale(v / v2, 1))
		text:Set((`{v} / {v2}`))
		text2:Set((`Lv {math.floor(v2 / incrementAmount)}`))
	end

	updateMasteryThing()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function HandleValue(child)
		updateMasteryThing(child.Current.Value, child.Goal.Value)
		maid:Connect(child.Current.Changed, function()
			updateMasteryThing(child.Current.Value, child.Goal.Value)
		end)
	end

	if data.MasteryProgressionList:FindFirstChild(data2.Name) == nil then
		local connection = nil
		connection = maid:Add(data.MasteryProgressionList.ChildAdded:Connect(function(child)
			if child.Name == data2.Name then
				if connection ~= nil then
					maid:Remove(connection)
					connection:Disconnect()
					connection = nil
				end

				HandleValue(child) -- equivalent call inferred; original call site unknown
			end
		end))
	else
		local v = data.MasteryProgressionList[data2.Name]
		updateMasteryThing(v.Current.Value, v.Goal.Value)
		maid:Connect(v.Current.Changed, function()
			updateMasteryThing(v.Current.Value, v.Goal.Value)
		end)
	end

	return maid:Create("CanvasGroup")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = maid:Animation(0, info2, {
			From = 1
		}),
		Name = data2.Name,
		maid:Create("Frame")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = maid:Animation(UDim2.fromScale(1, 1), info, {
				From = UDim2.fromScale(0.7, 0.7)
			}),
			Name = "Bg",
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0.5)
			}),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = 0.25,
			maid:Create("UIStroke")({
				Thickness = 1,
				Color = Color3.new(1, 1, 1),
				Transparency = 0.65,
				BorderOffset = UDim.new(-0.1)
			})
		}),
		maid:Create("Frame")({
			Name = "Content",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.75),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			GetList(maid, Enum.HorizontalAlignment.Center, UDim.new(0, 5)),
			function()
				if data2.Icon == nil then
					return
				else
					return maid:Create("ImageLabel")({
						Name = "Icon",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Image = "rbxassetid://79024618338298",
						ImageColor3 = Color3.new(0.35, 0.35, 0.35),
						Instance.new("UIAspectRatioConstraint"),
						maid:Create("ImageLabel")({
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Image = data2.Icon,
							Name = "Fg",
							ZIndex = 2
						})
					})
				end
			end,
			maid:Create("Frame")({
				Name = "NameAndBarHolder",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				maid:Create("Frame")({
					Name = "NameHolder",
					Size = UDim2.fromScale(1, 0.55),
					BackgroundTransparency = 1,
					GetList(maid, Enum.HorizontalAlignment.Center),
					maid:Create("TextLabel")({
						Name = "Txt",
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Text = data2.Name .. " Mastery",
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextColor3 = Color3.new(1, 1, 1),
						TextStrokeTransparency = 0.5,
						Font = Enum.Font.SourceSansBold,
						After = function(p)
							p.Size = UDim2.new(0, p.TextBounds.X, 1)
						end
					})
				}),
				maid:Create("Frame")({
					Name = "BottomHolder",
					Size = UDim2.fromScale(1, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					GetList(maid, Enum.HorizontalAlignment.Center, UDim.new(0, 5)),
					maid:Create("TextLabel")({
						Name = "CurrentValue",
						Size = UDim2.fromScale(100, 1.2),
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = gameSettings.masteryColor,
						TextStrokeTransparency = 0.5,
						Text = text2,
						TextScaled = true
					}),
					maid:Create("Frame")({
						Name = "BarHolder",
						Size = UDim2.fromScale(1, 0.5),
						maid:Create("UIAspectRatioConstraint")({
							AspectRatio = 8.2,
							DominantAxis = Enum.DominantAxis.Height,
							AspectType = Enum.AspectType.ScaleWithParentSize
						}),
						BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
						maid:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						maid:Create("UIStroke")({
							Color = Color3.new(1, 1, 1),
							Transparency = 0.75,
							BorderOffset = UDim.new(0, -1)
						}),
						maid:Create("Frame")({
							Name = "Inner",
							Size = UDim2.new(1, -5, 1, -5),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							maid:Create("Frame")({
								Name = "Bar",
								Size = size,
								Position = UDim2.fromScale(0, 0.5),
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundColor3 = gameSettings.masteryColor,
								maid:Create("UICorner")({
									CornerRadius = UDim.new(1)
								})
							})
						})
					}),
					maid:Create("TextLabel")({
						Name = "Progress",
						Size = UDim2.fromScale(100, 1),
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = gameSettings.masteryColor,
						TextStrokeTransparency = 0.5,
						Text = text,
						TextTransparency = 0.25,
						TextScaled = true
					})
				}),
				After = function(state)
					if state == nil then
						return
					end

					state.NameHolder.Txt.Size = UDim2.new(0, state.NameHolder.Txt.TextBounds.X, 1)
					state.BottomHolder.CurrentValue.Size = UDim2.new(
						0,
						state.BottomHolder.CurrentValue.TextBounds.X,
						state.BottomHolder.CurrentValue.Size.Y.Scale
					)
					state.BottomHolder.Progress.Size = UDim2.new(
						0,
						state.BottomHolder.Progress.TextBounds.X,
						state.BottomHolder.Progress.Size.Y.Scale
					)
					local X = state.NameHolder.List.AbsoluteContentSize.X
					local X2 = state.BottomHolder.List.AbsoluteContentSize.X
					state.Size = UDim2.new(0, math.max(X, X2), 1)
				end
			}),
			After = function(data3)
				if data3 == nil or data3.Parent == nil then
					return
				end

				local v = math.max(
					data3.NameAndBarHolder.NameHolder.List.AbsoluteContentSize.X,
					data3.NameAndBarHolder.BottomHolder.List.AbsoluteContentSize.X
				)
				data3.Parent.Size = UDim2.new(
					data3.List.AbsoluteContentSize.X / data3.Parent.Parent.AbsoluteSize.X,
					15,
					1
				)
				data3.NameAndBarHolder.Size = UDim2.fromScale(v / data3.NameAndBarHolder.Parent.AbsoluteSize.X, 1)
				data3.NameAndBarHolder.NameHolder.Txt.Size = UDim2.fromScale(
					data3.NameAndBarHolder.NameHolder.Txt.TextBounds.X / data3.NameAndBarHolder.NameHolder.AbsoluteSize.X,
					1
				)
			end
		})
	})
end