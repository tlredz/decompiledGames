local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Adders = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.Adders)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local info = faye.Info(0.15, Enum.EasingStyle.Sine)
local info2 = faye.Info(0.2)
local info3 = faye.Info(0.45)
local v = Platform_Handler.Platform.Value == "Mobile"
local color = Color3.fromRGB(155, 208, 255)
local uDim = UDim2.fromScale(0.45, 0.7)

local function GatherSellables()
	local result = {}
	local data = Utility.GetData(Players.LocalPlayer)

	if data == nil then
		return result
	end

	local v2 = {}
	local v3 = {}

	for _, v4 in ipairs(Utility.HeldEntries(data)) do
		local name = v4.Name

		if v4:FindFirstChild("NoSave") == nil and v4:FindFirstChild("QuestGrant") == nil then
			local item = Items[name]

			if item ~= nil and item.NoDelete ~= true and item.NoSell ~= true and item.Requirements == nil and item.NoSaveRequirements == nil and (item.Price ~= nil or Shop.itemsforsale[name] ~= nil) then
				local amount = v4:FindFirstChild("Amount")
				v3[name] = (v3[name] or 0) + (amount == nil and 1 or amount.Value or 1)
			end
		else
			v2[name] = true
		end
	end

	for k, owned in pairs(v3) do
		if not v2[k] then
			table.insert(result, {
				Name = k,
				Owned = owned
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

return function()
	return function(object, parent2, _, p2)
		local sellSelection = typeof(p2.SellSelection) ~= "table" and {} or p2.SellSelection or {}
		p2.SellSelection = sellSelection
		local gatherSellables = GatherSellables()
		local ownedsByName = {}

		for _, v4 in ipairs(gatherSellables) do
			ownedsByName[v4.Name] = v4.Owned
		end

		for k, value in pairs(sellSelection) do
			local v4

			if ownedsByName[k] ~= nil then
				v4 = math.clamp(value, 1, (math.min(ownedsByName[k], 999)))
			end

			sellSelection[k] = v4
		end

		local text = object:Value("")
		local textColor = object:Value(Color3.new(1, 1, 1))
		local value3 = object:Value(gatherSellables)
		local canvasSize = object:Value(UDim2.fromScale(1, 1))
		return object:Create("CanvasGroup")({
			Parent = parent2,
			Size = UDim2.fromScale(0.7, 0.5),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.96),
			object:Create("UIAspectRatioConstraint")({
				AspectRatio = 1.4
			}),
			BackgroundTransparency = 1,
			GroupTransparency = object:Animation(0, info3, {
				From = 1
			}),
			OnClean = function(object2)
				return {
					GroupTransparency = object2:Animation(1, info3)
				}
			end,
			object:Create("Frame")({
				Name = "TilesHolder",
				Size = UDim2.fromScale(1, 0.94),
				BackgroundTransparency = 1,
				object:Create("Frame")({
					Name = "Bg",
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.fromScale(1, 0.5),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.35,
					object:Create("UICorner")({
						CornerRadius = UDim.new(0, 5)
					}),
					object:Create("UIGradient")({
						Rotation = -90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					})
				}),
				object:Create("ScrollingFrame")({
					Name = "Actual",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					CanvasSize = canvasSize,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
					ScrollBarThickness = 0,
					object:Create("UIGridLayout")({
						StartCorner = Enum.StartCorner.BottomLeft,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						CellSize = UDim2.fromScale((v and 1.5 or 1) * 0.159, 1),
						CellPadding = UDim2.new((v and 1.5 or 1) * 0.008, 0, 0, 5),
						object:Create("UIAspectRatioConstraint")({}),
						AbsoluteContentSizeOnChangedInit = function(p3)
							local parent = p3.Parent
							local Y = parent.AbsoluteWindowSize.Y
							local v4 = math.max(p3.AbsoluteContentSize.Y - Y, 0)
							canvasSize:Set(UDim2.new(1, 0, 1, v4))

							local function toBottom()
								if parent.Parent == nil then
									return
								end

								local v5 = parent.AbsoluteCanvasSize.Y - parent.AbsoluteWindowSize.Y
								parent.CanvasPosition = Vector2.new(0, (math.max(v5, 0)))
							end

							local Y2 = parent.AbsoluteCanvasSize.Y

							if Y + v4 - 1 <= Y2 then
								task.defer(toBottom)
							else
								parent:GetPropertyChangedSignal("AbsoluteCanvasSize"):Once(toBottom)
							end
						end
					}),
					object:Iterate(value3, function(_, p3, object2, _)
						local name = p3.Name
						local owned = p3.Owned
						local item = Items[name]

						if item == nil then
							return nil
						end

						local v4 = Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
						local value5 = object2:Value(0.25)
						local value6 = object2:Value(0.75)
						local value7 = object2:Value(0.4)
						local value8 = object2:Value(0.2)
						local value9 = object2:Value(0.25)
						local value10 = object2:Value(1)
						local value11 = object2:Value({
							{
								Text = "..."
							}
						})
						local v5 = sellSelection[name]
						local value12 = object2:Value(v5 ~= nil)
						local value13 = object2:Value(v5 or 1)

						local function ApplyEmphasis(p4: string)
							if p4 == "Selected" then
								value5:Set(0.05)
								value6:Set(0.5)
								value7:Set(0.05)
								value8:Set(0)
								value9:Set(0)
								value10:Set(0.2)
							elseif p4 == "Hover" then
								value5:Set(0.15)
								value6:Set(0.65)
								value7:Set(0.2)
								value8:Set(0.1)
								value9:Set(0.1)
								value10:Set(1)
							else
								value5:Reset()
								value6:Reset()
								value7:Reset()
								value8:Reset()
								value9:Reset()
								value10:Reset()
							end
						end

						if v5 ~= nil then
							value5:Set(0.05)
							value6:Set(0.5)
							value7:Set(0.05)
							value8:Set(0)
							value9:Set(0)
							value10:Set(0.2)
						end

						local v6 = false
						task.spawn(function()
							local sellContent = Shop.GetSellContent(name)

							if sellContent == nil or not (#sellContent > 0) then
								value11:Set({
									{
										Text = "?"
									}
								})
								return
							end

							v6 = true
							value11:Set(sellContent)
						end)

						local function SetCount(value14: number?)
							if value14 == nil then
								sellSelection[name] = nil
								value12:Set(false)
								value5:Set(0.15)
								value6:Set(0.65)
								value7:Set(0.2)
								value8:Set(0.1)
								value9:Set(0.1)
								value10:Set(1)
							else
								local v7 = math.clamp(value14, 1, (math.min(owned, 999)))
								sellSelection[name] = v7
								value12:Set(true)
								value13:Set(v7)
								value5:Set(0.05)
								value6:Set(0.5)
								value7:Set(0.05)
								value8:Set(0)
								value9:Set(0)
								value10:Set(0.2)
							end
						end

						local v7 = nil
						local cframe = CFrame.new()
						local position = createVector(0, 0, 0)
						local value14 = 0
						local renderSteppedConnection = nil
						local v8 = nil
						local numberValue = Instance.new("NumberValue")

						-- equivalent calls inferred from this helper; original call sites unknown
						local function ApplyAngle(p4: number)
							if v7 == nil then
								return
							end

							v7:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(p4), 0) * cframe)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function StartSpin()
							if renderSteppedConnection ~= nil or v7 == nil then
								return
							end

							if v8 ~= nil then
								v8:Cancel()
								v8 = nil
							end

							renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
								value14 += 120 * dt
								ApplyAngle(value14) -- equivalent call inferred; original call site unknown
							end)
						end

						local function StopSpin()
							if v7 == nil then
								return
							end

							if renderSteppedConnection ~= nil then
								renderSteppedConnection:Disconnect()
								renderSteppedConnection = nil
							end

							value14 %= 360
							numberValue.Value = value14
							local v9 = value14 > 180 and 360 or 0
							local TweenService = game:GetService("TweenService")
							v8 = TweenService:Create(numberValue, tweenInfo, {
								Value = v9
							})
							v8:Play()
						end

						numberValue:GetPropertyChangedSignal("Value"):Connect(function()
							value14 = numberValue.Value
							ApplyAngle(value14) -- equivalent call inferred; original call site unknown
						end)
						return object2:Create("Frame")({
							CleanDelay = info3.Time,
							BackgroundTransparency = 1,
							object2:Create("Frame")({
								Name = "Bg",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = Color3.new(0, 0, 0),
								BackgroundTransparency = object2:Animation(value5, info),
								object2:Create("UICorner")({
									CornerRadius = UDim.new(0.1)
								}),
								object2:Create("UIGradient")({
									Rotation = 90,
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0),
										NumberSequenceKeypoint.new(1, 0.5)
									})
								}),
								object2:Create("Frame")({
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.new(1, -6, 1, -6),
									BackgroundColor3 = v4,
									BackgroundTransparency = object2:Animation(value6, info),
									object2:Create("UICorner")({
										CornerRadius = UDim.new(0.1)
									}),
									object2:Create("UIStroke")({
										Color = v4,
										Thickness = 1.5,
										Transparency = object2:Animation(value7, info)
									}),
									object2:Create("Frame")({
										Name = "SelectedRing",
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.new(1, -8, 1, -8),
										BackgroundTransparency = 1,
										object2:Create("UICorner")({
											CornerRadius = UDim.new(0.1)
										}),
										object2:Create("UIStroke")({
											Color = Color3.new(1, 1, 1),
											Thickness = 1.5,
											Transparency = object2:Animation(value10, info)
										})
									}),
									object2:Create("ImageLabel")({
										Name = "BgImage",
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(0.95, 0.95),
										BackgroundTransparency = 1,
										ImageTransparency = 0.65,
										Image = item.Icon
									})
								})
							}),
							object2:Create("ViewportFrame")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(0.8, 0.8),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								BorderColor3 = Color3.new(),
								BackgroundColor3 = Color3.new(),
								ImageTransparency = object2:Animation(value8, info),
								function(parent)
									local v9 = ItemModels.Get(name)

									if v9 == nil then
										warn((`Sell: no ItemAssets model for "{name}"`))
										return
									end

									local clone = v9:Clone()

									if clone:IsA("BasePart") then
										clone.Anchored = true
									end

									for _, v10 in clone:QueryDescendants("BasePart") do
										v10.Anchored = true
									end

									clone.Parent = parent
									local viewmodelSettings = item.ViewmodelSettings or {}
									local cframe2 = CFrame.new()

									if typeof(viewmodelSettings.CFrameOffset) == "CFrame" then
										cframe2 = viewmodelSettings.CFrameOffset.Rotation
										position = viewmodelSettings.CFrameOffset.Position
									end

									clone:PivotTo(cframe2)
									local boundingBox, size

									if clone:IsA("Model") then
										boundingBox, size = clone:GetBoundingBox()
									else
										boundingBox = clone.CFrame
										size = clone.Size
									end

									cframe = CFrame.new(-boundingBox.Position) * cframe2
									v7 = clone

									if v7 ~= nil then
										v7:PivotTo(CFrame.new(position) * CFrame.Angles(0, 0, 0) * cframe)
									end

									local camera = Instance.new("Camera")
									camera.Parent = parent
									parent.CurrentCamera = camera
									local halfMagnitude = size.Magnitude / 2
									local v11 = halfMagnitude / math.tan((math.rad(camera.FieldOfView / 2))) + halfMagnitude - 1 + (tonumber(viewmodelSettings.CameraOffset) or 0)
									camera.CFrame = CFrame.new(Vector3.new(0, 0, v11), createVector(0, 0, 0))
									parent.Destroying:Connect(function()
										if renderSteppedConnection ~= nil then
											renderSteppedConnection:Disconnect()
											renderSteppedConnection = nil
										end

										if v8 ~= nil then
											v8:Cancel()
											v8 = nil
										end

										v7 = nil
									end)
								end
							}),
							object2:Create("TextLabel")({
								ZIndex = 4,
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, -4, 0, 2),
								Size = UDim2.fromScale(0.4, 0.18),
								BackgroundTransparency = 1,
								Text = `x{owned}`,
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Right,
								Font = Enum.Font.SourceSansBold,
								TextColor3 = Color3.new(1, 1, 1),
								TextTransparency = 0.2,
								object2:Create("UIStroke")({
									Thickness = 1,
									Transparency = 0.6
								})
							}),
							object2:Create("CanvasGroup")({
								Name = "PriceHolder",
								ZIndex = 4,
								AnchorPoint = Vector2.new(0.5, 1),
								Position = UDim2.new(0.5, 0, 1, -8),
								Size = UDim2.fromScale(0.9, 1),
								BackgroundTransparency = 1,
								GroupTransparency = object2:Animation(value9, info),
								object2:Create("UIListLayout")({
									Wraps = true,
									FillDirection = Enum.FillDirection.Horizontal,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									VerticalAlignment = Enum.VerticalAlignment.Bottom,
									Padding = UDim.new(0, 2)
								}),
								object2:Iterate(value11, function(_, data, object3)
									local visible = data.Icon ~= nil
									return object3:Create("Frame")({
										CleanDelay = info3.Time,
										ZIndex = 4,
										Size = UDim2.new(0.65, 0, 0.25, 0),
										BackgroundTransparency = 1,
										object3:Create("UIListLayout")({
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											Padding = UDim.new(0, 2)
										}),
										object3:Create("ImageLabel")({
											ZIndex = 4,
											LayoutOrder = 1,
											Visible = visible,
											Size = UDim2.fromScale(1, 1),
											Instance.new("UIAspectRatioConstraint"),
											BackgroundTransparency = 1,
											Image = data.Icon or "",
											ImageColor3 = data.Color or Color3.new(1, 1, 1)
										}),
										object3:Create("TextLabel")({
											ZIndex = 4,
											LayoutOrder = 2,
											Size = UDim2.fromScale(0.7, 1),
											BackgroundTransparency = 1,
											Text = data.Text or Utility.addCommasToNumber(data.Price),
											TextScaled = true,
											Font = Enum.Font.SourceSansBold,
											TextXAlignment = visible and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
											TextColor3 = data.Color or Color3.new(1, 1, 1),
											object3:Create("UIStroke")({
												Thickness = 1,
												Transparency = 0.6
											}),
											object3:Create("UIShadow")({
												BlurRadius = UDim.new(0.5),
												Spread = UDim2.fromScale(0.2, 0.15),
												Offset = UDim2.fromScale(-0.2, 0),
												Transparency = 0.5
											})
										})
									})
								end)
							}),
							object2:State(function(callback, object3)
								if not (callback(value12) and owned > 1) then
									return
								end

								local v9 = 1

								local function add(p4)
									v9 = p4

									if sellSelection[name] == nil then
										return
									end

									SetCount(math.clamp(value13.Value + p4, 1, owned))
								end

								local function sellMax()
									if sellSelection[name] == nil then
										return
									end

									local v10 = math.min(owned, 999)

									if v10 == value13.Value then
										return
									end

									v9 = value13.Value < v10 and 1 or -1
									SetCount(v10)
								end

								local v10 = nil
								return object3:Create("Frame")({
									ZIndex = 5,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.3),
									Size = UDim2.fromScale(0.9, 0.25),
									BackgroundTransparency = object3:Animation(0.2, info2, {
										From = 1
									}),
									BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
									object3:Create("UIGradient")({
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 1),
											NumberSequenceKeypoint.new(0.25, 0),
											NumberSequenceKeypoint.new(0.75, 0),
											NumberSequenceKeypoint.new(1, 1)
										})
									}),
									object3:Create("Frame")({
										Name = "TxtHolder",
										ZIndex = 5,
										Size = UDim2.fromScale(0.45, 1),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.fromScale(0.5, 0.5),
										object3:Create("UICorner")({
											CornerRadius = UDim.new(1)
										}),
										ClipsDescendants = true,
										BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
										BackgroundTransparency = 0.5,
										object3:State(function(callback2, object4)
											local text2 = callback2(value13)

											if v10 ~= nil and text2 == v10 then
												return
											end

											if v10 == nil then
												v10 = text2
												return object4:Create("TextLabel")({
													ZIndex = 5,
													Size = UDim2.fromScale(1, 0.95),
													AnchorPoint = Vector2.new(0.5, 0.5),
													Position = UDim2.fromScale(0.5, 0.5),
													BackgroundTransparency = 1,
													OnClean = function(object5, p4)
														object5:Configure(p4)({
															Position = object5:Animation(
																UDim2.fromScale(0.5, v9 * 1 * -1),
																info2
															)
														})
													end,
													TextScaled = true,
													Font = Enum.Font.SourceSansBold,
													Text = text2,
													TextColor3 = Color3.new(1, 1, 1)
												})
											end

											v10 = text2
											return object4:Create("TextLabel")({
												ZIndex = 5,
												Size = UDim2.fromScale(1, 0.95),
												AnchorPoint = Vector2.new(0.5, 0.5),
												Position = object4:Animation(UDim2.fromScale(0.5, 0.5), info2, {
													From = UDim2.fromScale(0.5, v9 * 1)
												}),
												BackgroundTransparency = 1,
												CleanDelay = 0.2,
												TextScaled = true,
												Font = Enum.Font.SourceSansBold,
												Text = text2,
												TextColor3 = Color3.new(1, 1, 1),
												OnClean = function(object5, p4)
													object5:Configure(p4)({
														Position = object5:Animation(
															UDim2.fromScale(0.5, v9 * 1 * -1),
															info2
														)
													})
												end
											})
										end)
									}),
									Adders(object3, nil, nil, function()
										v9 = 1

										if sellSelection[name] == nil then
											return
										end

										SetCount(math.clamp(value13.Value + 1, 1, owned))
									end, 2),
									Adders(object3, {
										Position = UDim2.fromScale(1, 0.5),
										AnchorPoint = Vector2.new(1, 0.5)
									}, 90, function()
										v9 = -1

										if sellSelection[name] == nil then
											return
										end

										SetCount(math.clamp(value13.Value + -1, 1, owned))
									end, 2),
									GradientButton(object3, {
										Text = "Max",
										Font = Enum.Font.SourceSansBold,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextBoxSize = UDim2.fromScale(0.8, 0.75),
										BgColor = color,
										CornerRadius = UDim.new(1, 0),
										Clicked = sellMax,
										Properties = {
											ZIndex = 5,
											AnchorPoint = Vector2.new(0.5, 0),
											Position = UDim2.new(0.5, 0, 1, 0),
											Size = uDim
										}
									})
								})
							end),
							object2:Create("TextButton")({
								Name = "Hover",
								ZIndex = 3,
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Text = "",
								MouseButton1Click = function()
									if not v6 then
										return
									end

									ScreenEffects.CircleClick()

									if sellSelection[name] == nil then
										SetCount(1)
									else
										SetCount(nil)
									end
								end,
								MouseEnter = function()
									text:Set(name)
									textColor:Set(v4)
									StartSpin() -- equivalent call inferred; original call site unknown
									ApplyEmphasis(sellSelection[name] == nil and "Hover" or "Selected")
								end,
								MouseLeave = function()
									StopSpin()
									text:Reset()
									textColor:Reset()

									if sellSelection[name] == nil then
										value5:Reset()
										value6:Reset()
										value7:Reset()
										value8:Reset()
										value9:Reset()
										value10:Reset()
									end
								end
							})
						})
					end)
				})
			}),
			object:Create("TextLabel")({
				Name = "HoveredName",
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0.005, 1),
				Size = UDim2.fromScale(0.5, 0.055),
				BackgroundTransparency = 1,
				Text = text,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = textColor,
				object:Create("UIStroke")({
					Thickness = 3,
					Transparency = 0.8
				})
			})
		})
	end
end