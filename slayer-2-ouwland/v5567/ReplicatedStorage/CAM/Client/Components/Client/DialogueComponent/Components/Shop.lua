local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local v = Platform_Handler.Platform.Value == "Mobile"
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Adders = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.Adders)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Wen = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.HudBottomRight.FirstVertical.Wen)
local faye = require(ReplicatedStorage.Packages.faye)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local info = faye.Info(0.15, Enum.EasingStyle.Sine)
local info2 = faye.Info(0.2)
local info3 = faye.Info(0.45)
local color = Color3.fromRGB(155, 208, 255)
local uDim = UDim2.fromScale(0.45, 0.7)
return function(items, p)
	local counter = p ~= nil and p.Counter or Wen
	local v2

	if p == nil then
		v2 = false
	else
		v2 = p.Single == true
	end

	return function(object, parent2, _, p3)
		local buySelection = typeof(p3.BuySelection) ~= "table" and {} or p3.BuySelection or {}
		p3.BuySelection = buySelection
		local v4 = {}

		for _, item in items do
			v4[item] = true
		end

		local count = 0

		for k, v5 in pairs(buySelection) do
			if v4[k] and Shop.itemsforsale[k] ~= nil then
				if v2 and count > 0 then
					buySelection[k] = nil
				else
					buySelection[k] = Shop.EffectiveAmount(k, v5)
					count += 1
				end
			else
				buySelection[k] = nil
			end
		end

		local text = object:Value("")
		local textColor = object:Value(Color3.new(1, 1, 1))
		local value3 = object:Value(nil)
		local value4 = object:Value(items)
		local canvasSize = object:Value(UDim2.fromScale(1, 1))
		return object:Create("Frame")({
			Parent = parent2,
			Size = UDim2.fromScale(0.7, 0.5),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.96),
			object:Create("UIAspectRatioConstraint")({
				AspectRatio = 1.4
			}),
			BackgroundTransparency = 1,
			CleanDelay = 0.45,
			object:Create("CanvasGroup")({
				Name = "WenCounter",
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1.04, 1.098),
				Size = UDim2.fromScale(1, 0.15),
				BackgroundTransparency = 1,
				ZIndex = 99,
				GroupTransparency = object:Animation(0, info3, {
					From = 1
				}),
				OnClean = function(object2)
					return {
						GroupTransparency = object2:Animation(1, info3)
					}
				end,
				object:Create("Frame")({
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.fromScale(1, 1),
					Size = UDim2.fromScale(1, 1),
					object:Create("UIAspectRatioConstraint")({
						AspectRatio = 1
					}),
					BackgroundTransparency = 1,
					counter(object)
				})
			}),
			object:Create("CanvasGroup")({
				Name = "Panel",
				Size = UDim2.fromScale(1, 1),
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
						Size = UDim2.fromScale(1, 0.5),
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.fromScale(0.5, 1),
						BackgroundColor3 = Color3.new(),
						object:Create("UICorner")({
							CornerRadius = UDim.new(0, 5)
						}),
						object:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.7),
								NumberSequenceKeypoint.new(1, 1)
							}),
							Rotation = -90
						})
					}),
					object:Create("ScrollingFrame")({
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Name = "Actual",
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
							AbsoluteContentSizeOnChangedInit = function(p4)
								local parent = p4.Parent
								local Y = parent.AbsoluteWindowSize.Y
								local v5 = math.max(p4.AbsoluteContentSize.Y - Y, 0)
								canvasSize:Set(UDim2.new(1, 0, 1, v5))

								local function toBottom()
									if parent.Parent == nil then
										return
									end

									local v6 = parent.AbsoluteCanvasSize.Y - parent.AbsoluteWindowSize.Y
									parent.CanvasPosition = Vector2.new(0, (math.max(v6, 0)))
								end

								local Y2 = parent.AbsoluteCanvasSize.Y

								if Y + v5 - 1 <= Y2 then
									task.defer(toBottom)
								else
									parent:GetPropertyChangedSignal("AbsoluteCanvasSize"):Once(toBottom)
								end
							end
						}),
						object:Iterate(value4, function(_, p4, object2, _)
							local v5 = Shop.itemsforsale[p4]
							local v6 = Items[p4] ~= nil or nil
							local item = Items[p4]

							if not item then
								if v5 == nil or v5.Icon == nil or not v5 then
									item = nil
								else
									item = v5
								end
							end

							if item == nil then
								warn((`Shop: "{p4}" is not in the item catalogue, tile skipped`))
								return nil
							end

							local v7 = Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
							local _, v8 = next(item.PackContents or {})
							local canBuyResults = Shop.CanBuyResults(Players.LocalPlayer, p4)
							local v9

							if canBuyResults == nil then
								v9 = false
							else
								v9 = #canBuyResults > 0
							end

							for _, v11 in canBuyResults or {} do
								if v11.CanBuy then
									continue
								end

								v9 = false
								break
							end

							local v11

							if v5 == nil or v5.Price == nil then
								v11 = false
							else
								v11 = v5.Price.Product ~= nil or v5.Price.Gamepass ~= nil
							end

							local v12

							if v5 == nil or item.Skills ~= nil then
								v12 = false
							else
								v12 = not (item.HasCombat or v11 or v2)
							end

							local v13 = buySelection[p4]
							local value6 = object2:Value(v13 ~= nil)
							local value7 = object2:Value(v13 or 1)
							local v14 = 1
							local v15

							if v12 then
								v15 = {}

								for k, v16 in canBuyResults or {} do
									v15[k] = object2:Value(Utility.addCommasToNumber(v16.Price * (v13 or 1)))
								end
							else
								v15 = nil
							end

							local value8 = object2:Value(v9 and 0.25 or 0.45)
							local value9 = object2:Value(0.75)
							local value10 = object2:Value(v9 and 0.4 or 0.65)
							local value11 = object2:Value(0.2)
							local value12 = object2:Value(v9 and 0.25 or 0.5)
							local value13 = object2:Value(1)

							local function ApplyEmphasis(p5: string)
								if p5 == "Selected" then
									value8:Set(0.05)
									value9:Set(0.5)
									value10:Set(0.05)
									value11:Set(0)
									value12:Set(0)
									value13:Set(0.2)
								elseif p5 == "Hover" then
									value8:Set(0.15)
									value9:Set(0.65)
									value10:Set(0.2)
									value11:Set(0.1)
									value12:Set(0.1)
									value13:Set(1)
								else
									value8:Reset()
									value9:Reset()
									value10:Reset()
									value11:Reset()
									value12:Reset()
									value13:Reset()
								end
							end

							if v13 ~= nil then
								value8:Set(0.05)
								value9:Set(0.5)
								value10:Set(0.05)
								value11:Set(0)
								value12:Set(0)
								value13:Set(0.2)

								if v2 then
									value3:Set(p4)
								end
							end

							local function SetCount(value14: number?)
								if value14 == nil then
									buySelection[p4] = nil
									value6:Set(false)
									value8:Set(0.15)
									value9:Set(0.65)
									value10:Set(0.2)
									value11:Set(0.1)
									value12:Set(0.1)
									value13:Set(1)
								else
									if v2 then
										value3:Set(p4)
										value14 = 1
									end

									value14 = math.clamp(value14, 1, 99)
									buySelection[p4] = value14
									value6:Set(true)
									value7:Set(value14)
									value8:Set(0.05)
									value9:Set(0.5)
									value10:Set(0.05)
									value11:Set(0)
									value12:Set(0)
									value13:Set(0.2)
								end

								if v15 ~= nil then
									for k, v16 in canBuyResults or {} do
										v15[k]:Set(Utility.addCommasToNumber(v16.Price * (value14 or 1)))
									end
								end
							end

							if v2 then
								object2:Reactive(function(callback)
									if callback(value3) ~= p4 and buySelection[p4] ~= nil then
										buySelection[p4] = nil
										value6:Set(false)
										value8:Reset()
										value9:Reset()
										value10:Reset()
										value11:Reset()
										value12:Reset()
										value13:Reset()
									end
								end)
							end

							local function AdjustAmount(p5: number)
								if buySelection[p4] == nil then
									return
								end

								local v16 = math.clamp(value7.Value + p5, 1, 99)

								if v16 == value7.Value or value7.Value < v16 and not Shop.CanBuy(
									Players.LocalPlayer,
									p4,
									nil,
									v16
								) then
									return
								end

								v14 = p5
								SetCount(v16)
							end

							local function SelectMax()
								if buySelection[p4] == nil then
									return
								end

								local v16 = 1
								local v17 = 99

								while v16 < v17 do
									local v18 = math.ceil((v16 + v17) / 2)

									if Shop.CanBuy(Players.LocalPlayer, p4, nil, v18) then
										v16 = v18
									else
										v17 = v18 - 1
									end
								end

								if v16 == value7.Value then
									return
								end

								v14 = value7.Value < v16 and 1 or -1
								SetCount(v16)
							end

							local v16 = nil
							local cframe = CFrame.new()
							local position = createVector(0, 0, 0)
							local v17 = 0
							local renderSteppedConnection = nil
							local v18 = nil
							local numberValue = Instance.new("NumberValue")

							-- equivalent calls inferred from this helper; original call sites unknown
							local function ApplyAngle(p5: number)
								v17 = p5

								if v16 ~= nil then
									v16:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(p5), 0) * cframe)
								end
							end

							numberValue.Changed:Connect(ApplyAngle)

							-- equivalent calls inferred from this helper; original call sites unknown
							local function StartSpin()
								if v18 ~= nil then
									v18:Cancel()
									v18 = nil
								end

								if renderSteppedConnection ~= nil or v16 == nil then
									return
								end

								renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
									ApplyAngle(v17 + dt * 120) -- equivalent call inferred; original call site unknown
								end)
							end

							local function StopSpin()
								if renderSteppedConnection ~= nil then
									renderSteppedConnection:Disconnect()
									renderSteppedConnection = nil
								end

								if v16 == nil then
									return
								end

								v17 %= 360
								numberValue.Value = v17
								v18 = TweenService:Create(numberValue, tweenInfo, {
									Value = v17 > 180 and 360 or 0
								})
								v18:Play()
							end

							local v19 = object2:Create("Frame")
							local v20 = {
								BackgroundTransparency = 1,
								CleanDelay = info3.Time
							}
							local v21 = object2:Create("Frame")({
								Name = "Bg",
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.new(1, -4, 1, -4),
								object2:Create("UICorner")({
									CornerRadius = UDim.new(0.1)
								}),
								BackgroundTransparency = object2:Animation(value8, info),
								object2:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0),
										NumberSequenceKeypoint.new(1, 0.65)
									}),
									Rotation = 90
								}),
								BackgroundColor3 = Color3.new(0, 0, 0),
								object2:Create("Frame")({
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.new(1, -8, 1, -8),
									object2:Create("UICorner")({
										CornerRadius = UDim.new(0.1)
									}),
									BackgroundColor3 = v7,
									BackgroundTransparency = object2:Animation(value9, info),
									object2:Create("UIGradient")({
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0),
											NumberSequenceKeypoint.new(1, 1)
										}),
										Rotation = -90
									}),
									object2:Create("UIStroke")({
										Color = v7,
										Transparency = object2:Animation(value10, info),
										object2:Create("UIGradient")({
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 0),
												NumberSequenceKeypoint.new(1, 1)
											}),
											Rotation = -90
										})
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
											Transparency = object2:Animation(value13, info)
										})
									})
								})
							})
							local v22 = object2:Create("ImageLabel")({
								Name = "BgImage",
								Image = item.Icon,
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.new(0.7, 0.7, 0.7),
								object2:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0.4),
										NumberSequenceKeypoint.new(1, 1)
									}),
									Rotation = 90
								})
							})
							local v23 = v6 and object2:Create("ViewportFrame")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(0.8, 0.8),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								BorderColor3 = Color3.new(),
								BackgroundColor3 = Color3.new(),
								ImageTransparency = object2:Animation(value11, info),
								function(parent)
									local v24 = ItemModels.Get(p4)

									if v24 == nil then
										warn((`Shop: no ItemAssets model for "{p4}"`))
										return
									end

									local clone = v24:Clone()

									if clone:IsA("BasePart") then
										clone.Anchored = true
									end

									for _, v25 in clone:QueryDescendants("BasePart") do
										v25.Anchored = true
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
									v16 = clone
									v17 = 0

									if v16 ~= nil then
										v16:PivotTo(CFrame.new(position) * CFrame.Angles(0, 0, 0) * cframe)
									end

									local camera = Instance.new("Camera")
									camera.Parent = parent
									parent.CurrentCamera = camera
									local halfMagnitude = size.Magnitude / 2
									local v26 = halfMagnitude / math.tan((math.rad(camera.FieldOfView / 2))) + halfMagnitude - 1 + (tonumber(viewmodelSettings.CameraOffset) or 0)
									camera.CFrame = CFrame.new(Vector3.new(0, 0, v26), createVector(0, 0, 0))
									parent.Destroying:Connect(function()
										if renderSteppedConnection ~= nil then
											renderSteppedConnection:Disconnect()
											renderSteppedConnection = nil
										end

										if v18 ~= nil then
											v18:Cancel()
											v18 = nil
										end

										v16 = nil
									end)
								end
							}) or object2:Create("ImageLabel")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(0.6, 0.6),
								BackgroundTransparency = 1,
								Image = item.Icon,
								ImageTransparency = object2:Animation(value11, info),
								object2:Create("UIAspectRatioConstraint")({})
							})
							local v24

							if (v8 or 0) > 1 then
								v24 = object2:Create("TextLabel")({
									Name = "PackCount",
									ZIndex = 4,
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.new(1, -4, 0, 2),
									Size = UDim2.fromScale(0.4, 0.18),
									BackgroundTransparency = 1,
									Text = `x{v8}`,
									TextScaled = true,
									TextXAlignment = Enum.TextXAlignment.Right,
									Font = Enum.Font.SourceSansBold,
									TextColor3 = Color3.new(1, 1, 1),
									TextTransparency = 0.2,
									object2:Create("UIStroke")({
										Thickness = 1,
										Transparency = 0.6
									})
								}) or nil
							end

							do local _values = table.pack(v21, v22, v23, v24, object2:Create("CanvasGroup")({
	Name = "PriceHolder",
	ZIndex = 4,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -8),
	Size = UDim2.fromScale(0.9, 1),
	BackgroundTransparency = 1,
	GroupTransparency = object2:Animation(value12, info),
	object2:Create("UIListLayout")({
		Wraps = true,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 2)
	}),
	object2:Iterate(canBuyResults or {}, function(p5, data, object3)
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
				ZIndex = 5,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				Image = data.Icon,
				ImageColor3 = data.Color or Color3.new(1, 1, 1)
			}),
			object3:Create("TextLabel")({
				ZIndex = 4,
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.7, 1),
				BackgroundTransparency = 1,
				Text = v15 ~= nil and v15[p5] or Utility.addCommasToNumber(data.Price),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = v9 and (data.Color or Color3.new(1, 1, 1)) or Color3.new(1, 0.35, 0.35),
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
}), object2:State(function(callback, object3)
	if v12 and callback(value6) then
		local v25 = nil
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
				LayoutOrder = 1,
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
					local text2 = callback2(value7)

					if v25 ~= nil and text2 == v25 then
						return
					end

					if v25 == nil then
						v25 = text2
						return object4:Create("TextLabel")({
							ZIndex = 5,
							Size = UDim2.fromScale(1, 0.95),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							BackgroundTransparency = 1,
							OnClean = function(object5, p5)
								object5:Configure(p5)({
									Position = object5:Animation(UDim2.fromScale(0.5, v14 * 1 * -1), info2)
								})
							end,
							TextScaled = true,
							Font = Enum.Font.SourceSansBold,
							Text = text2,
							TextColor3 = Color3.new(1, 1, 1)
						})
					end

					v25 = text2
					return object4:Create("TextLabel")({
						ZIndex = 5,
						Size = UDim2.fromScale(1, 0.95),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = object4:Animation(UDim2.fromScale(0.5, 0.5), info2, {
							From = UDim2.fromScale(0.5, v14 * 1)
						}),
						BackgroundTransparency = 1,
						CleanDelay = 0.2,
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						Text = text2,
						TextColor3 = Color3.new(1, 1, 1),
						OnClean = function(object5, p5)
							object5:Configure(p5)({
								Position = object5:Animation(UDim2.fromScale(0.5, v14 * 1 * -1), info2)
							})
						end
					})
				end)
			}),
			Adders(object3, nil, nil, function()
				AdjustAmount(1)
			end, 2),
			Adders(object3, {
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(1, 0.5)
			}, 90, function()
				AdjustAmount(-1)
			end, 2),
			GradientButton(object3, {
				Text = "Max",
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextBoxSize = UDim2.fromScale(0.8, 0.75),
				BgColor = color,
				CornerRadius = UDim.new(1, 0),
				Clicked = SelectMax,
				Properties = {
					ZIndex = 5,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 1, 0),
					Size = uDim
				}
			})
		})
	end
end), object2:Create("TextButton")({
	Name = "Hover",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	MouseButton1Click = function()
		if not v9 then
			return
		end

		ScreenEffects.CircleClick()

		if buySelection[p4] == nil then
			SetCount(1)
		else
			SetCount(nil)
		end
	end,
	MouseEnter = function()
		if not v9 then
			return
		end

		text:Set(p4)
		textColor:Set(v7)
		StartSpin() -- equivalent call inferred; original call site unknown
		ApplyEmphasis(buySelection[p4] == nil and "Hover" or "Selected")
	end,
	MouseLeave = function()
		StopSpin()

		if not v then
			text:Reset()
			textColor:Reset()
		end

		if buySelection[p4] == nil then
			value8:Reset()
			value9:Reset()
			value10:Reset()
			value11:Reset()
			value12:Reset()
			value13:Reset()
		end
	end
})); for _k = 1, _values.n do v20[_k] = _values[_k] end end
							return v19(v20)
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
		})
	end
end