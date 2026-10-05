local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AccessoriesShared = require(ReplicatedStorage.AccessoriesShared)
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local React = require(ReplicatedStorage.Packages.React)
local TileGrid = require(ReplicatedStorage.React.Components.Inventory.Main.TileGrid)
local useMultiSelection = require(ReplicatedStorage.React.Hooks.Item.useMultiSelection)
local useDynamicAccessories = require(ReplicatedStorage.React.Hooks.Player.useDynamicAccessories)
require(script.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local Notification

if GlobalUtil.FFlags.IsUnitTest then
	Notification = nil
else
	Notification = require(game.ReplicatedStorage.Notification)
end

local createElement = React.createElement
return function(props)
	local v = useDynamicAccessories()
	local v2, _, v3 = useMultiSelection()
	local v4

	if props.IsOpen then
		local v5 = {}

		if v then
			for k, v6 in v2 do
				local _, v7 = unpack(string.split(k, "-"))

				if v7 == nil then
					continue
				end

				local v8 = v[v7]

				if v8 and v6 == true then
					v5[v7] = v8
				end
			end
		end

		v4 = AccessoriesShared.GetDataReward(v5)
	else
		v4 = 0
	end

	local v5

	if props.IsOpen then
		return (createElement(React.Fragment, nil, {
			window = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
				BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
				Position = UDim2.fromScale(0.499368, 0.498871),
				Size = UDim2.fromScale(0.756063, 0.812541),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uISizeConstraint = createElement("UISizeConstraint", {
					MaxSize = Vector2.new(650, 425),
					MinSize = Vector2.new(475, 273)
				}),
				main = createElement("Frame", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0, 0.11846),
					Size = UDim2.fromScale(1, 0.88154),
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					crafting = createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1)
					}, {
						footer = createElement("Frame", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
							BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.fromScale(1, 0.148902)
						}, {
							uIListLayout = createElement("UIListLayout", {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center
							}),
							confirm = createElement("TextButton", {
								BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
								BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
								BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
								FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
								Position = UDim2.fromScale(0.454775, 0.15),
								Size = UDim2.fromScale(0.2107, 0.7),
								Text = "",
								TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
								TextScaled = true,
								TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								[React.Event.MouseButton1Click] = function()
									local v21 = {}

									for k in v2 do
										local _, v22 = unpack(string.split(k, "-"))

										if v22 ~= nil then
											table.insert(v21, v22)
										end
									end

									local simulationData = game.Players.LocalPlayer:GetAttribute("SimulationData")
									local PromptController = require(game.ReplicatedStorage.Controllers.UI.PromptController)
									local fruitShop = PromptController.new("FruitShop")
									local v22 = fruitShop:AddTemplate("Default")
									local v23 = 100000 - simulationData

									if v23 == 0 then
										v22.Description.Text = "You won't gain any Simulation Data due to having the maximum amount."
									else
										v22.Description.Text = `You'll gain {math.min(v23, v4)} Simulation Data from this. Are you sure?`
									end

									local v24 = fruitShop:AddButton("Confirm", {
										TextLabel = {
											Text = "Scrap"
										},
										Visible = true
									})
									local v25 = fruitShop:AddButton("Cancel", {
										Appearance = "Inactive",
										TextLabel = {
											Text = "Cancel"
										},
										Visible = true
									})
									v24.Instance.Activated:Connect(function()
										print("Bought")
										fruitShop:Destroy()
										local v26, v27 = ReplicatedStorage.Remotes.AccessoryInteract:InvokeServer(
											"b",
											v21
										)

										if v26 then
											v3()
										elseif Notification then
											Notification.new((`<Color=Red>{v27}<Color=/>`)):Display()
										end

										print(v26, v27)
									end)
									v25.Instance.Activated:Connect(function()
										print("Cancelled")
										fruitShop:Destroy()
									end)
									fruitShop:SetTitle("Warning")
									fruitShop:Open()
								end
							}, {
								trans = createElement("Frame", {
									BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
									BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
									Position = UDim2.fromOffset(2, 2),
									Size = UDim2.new(1, -4, 0.4, 0),
									ZIndex = CONSTANTS.LAYER.BASE
								}),
								textLabel = createElement("TextLabel", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
									FontFace = CONSTANTS.FONT.FACE.DISPLAY,
									Position = UDim2.fromScale(0.5, 0.55),
									Size = UDim2.fromScale(0.95, 0.75),
									Text = "Scrap",
									TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
									TextScaled = true,
									ZIndex = CONSTANTS.LAYER.RAISED
								}, {
									uIStroke = createElement("UIStroke", {
										Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
									}),
									textLabel = createElement("TextLabel", {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
										FontFace = CONSTANTS.FONT.FACE.DISPLAY,
										Position = UDim2.fromScale(0.5, 0.45),
										Size = UDim2.fromScale(1, 1),
										Text = "Scrap",
										TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
										TextScaled = true
									}, {
										uIStroke = createElement("UIStroke", {
											Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
										})
									})
								})
							}),
							uICorner = createElement("UICorner", {
								CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
							})
						}),
						content = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(0, 1.62911e-7),
							Size = UDim2.fromScale(1, 0.848782)
						}, {
							result = createElement("Frame", {
								AnchorPoint = Vector2.new(0, 0.5),
								AutomaticSize = Enum.AutomaticSize.Y,
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								Position = UDim2.fromScale(0.658, 0.5),
								Size = UDim2.fromScale(0.331279, 0.792746)
							}, {
								uIListLayout = createElement("UIListLayout", {
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									Padding = UDim.new(0.035, 0),
									SortOrder = Enum.SortOrder.LayoutOrder,
									VerticalAlignment = Enum.VerticalAlignment.Center
								}),
								oG = createElement("Frame", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
									LayoutOrder = -999,
									Position = UDim2.fromScale(0.5, 0.232342),
									Size = UDim2.fromOffset(90, 90)
								}, {
									blank = createElement("ImageLabel", {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(1, 1),
										Image = "rbxassetid://109946525658150",
										ImageTransparency = v4 == 0 and 0.5 or 0
									}, {
										uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
									})
								}),
								itemInfo = createElement("Frame", {
									AnchorPoint = Vector2.new(0.5, 0.5),
									AutomaticSize = Enum.AutomaticSize.Y,
									BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
									Position = UDim2.fromScale(0.5, 0.589987),
									Size = UDim2.fromScale(1, 0.182942)
								}, {
									itemName = createElement("TextLabel", {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
										FontFace = CONSTANTS.FONT.FACE.DISPLAY,
										Position = UDim2.fromScale(0.5, 0.268373),
										Size = UDim2.fromScale(1, 0.606199),
										Text = `Simulation Data x{v4}`,
										TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
										TextScaled = true
									}, {
										uIStroke = createElement("UIStroke", {
											Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
										}),
										uISizeConstraint = createElement("UISizeConstraint", {
											MinSize = Vector2.new(0, 25)
										})
									})
								})
							}),
							imageLabel = createElement("ImageLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								Image = "rbxassetid://109323886099551",
								Position = UDim2.fromScale(0.6, 0.5),
								Size = UDim2.fromScale(0.075, 0.157977)
							}, {
								uIGradient = createElement("UIGradient", {
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
										ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
										ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
									})
								})
							}),
							frame = createElement("Frame", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								Position = UDim2.fromScale(0.019, 0.503902),
								Selectable = false,
								Size = UDim2.fromScale(0.552, 0.919904)
							}, {
								grid = createElement(TileGrid, {
									Size = UDim2.new(1, 0, 1, 0),
									RowCellCount = 3,
									IsMultiSelect = true,
									Variant = "Elevated",
									OnScrollToTop = function() end,
									ScrollToTop = true,
									OnGamepadBorderExit = function() end,
									Tiles = props.Tiles,
									SelectionBorderColor = Color3.new(1, 0, 0)
								})
							})
						})
					})
				}),
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
				}),
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				title = createElement("Frame", {
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
					Position = UDim2.fromScale(0, 3.91313e-8),
					Size = UDim2.fromScale(1, 0.11846)
				}, {
					uICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
					}),
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					}),
					uIGradient = createElement("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
							ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
							ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
						})
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.8, 0.75),
						Text = "Trinket Scrapper",
						TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						TextScaled = true
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.DISPLAY,
							Position = UDim2.fromScale(0.5, 0.45),
							Size = UDim2.fromScale(1, 1),
							Text = "Trinket Scrapper",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
							})
						})
					}),
					close = createElement("TextButton", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
						BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
						LayoutOrder = -999,
						Position = UDim2.fromScale(0.985, 0.5),
						Size = UDim2.fromScale(0.0535928, 0.7),
						Text = "",
						TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						TextScaled = true,
						TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						ZIndex = CONSTANTS.LAYER.RAISED,
						[React.Event.MouseButton1Click] = function()
							props.SetIsOpen(false)
							v3()
						end
					}, {
						trans = createElement("Frame", {
							AnchorPoint = Vector2.new(0.5, 1),
							BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
							BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.94, 0.47)
						}),
						icon = createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Image = "rbxassetid://127503254560275",
							ImageRectSize = Vector2.new(100, 100),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = CONSTANTS.LAYER.OVERLAY
						})
					})
				})
			})
		}))
	end

	return v5
end