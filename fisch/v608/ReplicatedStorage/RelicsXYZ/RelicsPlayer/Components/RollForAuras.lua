local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local Enums = require(parent.Enums)
local State = require(parent.State)
local React = require(shared.React)
local useAuras = require(hooks.useAuras)
local useAuraData = require(hooks.useAuraData)
local useOwnership = require(hooks.useOwnership)
local useStyleSheet = require(hooks.useStyleSheet)
local components = parent.Components
local Button = require(components.Button)
local ItemTile = require(components.ItemTile)
local ItemPage = require(components.ItemPage)
local Confetti = require(components.Confetti)
local TextButton = require(components.TextButton)
local Auras = require(shared.Auras)
local RunContext = require(shared.RunContext)
local Players = game:GetService("Players")
local Marketplace = require(shared.Marketplace)
local v = {
	"OOF!",
	"MISS!",
	"NOPE!",
	"SORRY!",
	"ALMOST!",
	"NO DICE!",
	"UNLUCKY!",
	"SO CLOSE!",
	"TRY AGAIN!",
	"NOT QUITE!"
}

local function RollForAuras(_)
	local v2 = useStyleSheet("Fonts", "Font")
	local v3 = React.useContext(State.Context)
	local status = v3.Status
	local v4 = v3.WindowState == Enums.WindowState.Compact
	local v5, v6 = useAuraData()
	local v7 = useAuras()
	local rollsPerDay = v6.RollsPerDay or 0
	local v8 = (v6.RollsWithProduct or 0) - rollsPerDay
	local v9 = { v7, (React.useMemo(function()
			local count = 0

			for _ in v5.Unlocks do
				count += 1
			end

			return count
		end, { v5.Unlocks })) }
	local v10 = React.useMemo(function()
		local v11 = {}
		local v12 = {}

		for _, v13 in v7 do
			if v5.Unlocks[v13.Name] then
				table.insert(v11, v13)
			else
				table.insert(v12, v13)
			end
		end

		table.sort(v11, function(a, b)
			return a.Chance < b.Chance
		end)
		local result = {}

		for _, v13 in v12 do
			table.insert(result, v13)
		end

		for _, v13 in v11 do
			table.insert(result, v13)
		end

		if #result >= 3 then
			return { result[1], result[2], result[3] }
		end

		return result
	end, v9)
	local ref = React.useRef(false)
	local ref2 = React.useRef(0)
	local count = 0
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(nil)
	local children = {}
	local children2 = {}

	if not v4 then
		for k, v11 in v10 do
			local formatted = `Aura{k}`
			children2[formatted] = React.createElement(ItemTile, {
				[React.Tag] = "ofRollForAuras",
				LayoutOrder = k,
				Target = {
					Type = "AURA",
					Id = v11.Name
				},
				OverrideStrokeColor = v11.TitleColor
			})
		end
	end

	local v11 = useOwnership({
		{
			Id = v6.RollAssetId or 0,
			InfoType = Enum.InfoType.Asset
		},
		{
			Id = v6.RollGamePass or 0,
			InfoType = Enum.InfoType.GamePass
		}
	})
	local v12 = React.useState(function()
		local result = {}

		for _ = 1, 2 do
			local clone = table.clone(v)

			while #clone > 0 do
				local v13 = math.random(1, #clone)
				table.insert(result, assert((table.remove(clone, v13))))
			end
		end

		return result
	end)

	for i = -3.05, 1, 0.05 do
		local text = v12[(count - 1) % #v12 + 1]
		local richText

		if count % 20 == 1 then
			text = "AURA REVEAL!\n<font size=\"4\" weight=\"400\" color=\"#4E059E\">5% CHANCE</font>"
			richText = true
		else
			richText = false
		end

		children[`Label_{count}`] = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, i * 20),
			BackgroundTransparency = 1
		}, {
			Text = React.createElement("TextLabel", {
				Text = text,
				RichText = richText,
				TextColor3 = Color3.fromHex("#130736"),
				TextScaled = true,
				FontFace = v2("Font-Bold"),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, richText and 1.1 or 0.7),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
		})
		count += 1
	end

	React.useEffect(function()
		local current = ref4.current

		if not current then
			return
		end

		local thread = task.spawn(function()
			while true do
				if v5.Rolls < 1 then
					local v13 = math.clamp(86400 - (os.time() - v5.LastRenew), 0, 86400)
					local v14 = math.floor(v13 / 3600)
					local v15 = math.floor(v13 % 3600 / 60)
					local v16 = v13 % 60
					current.Text = string.format(
						"<font size=\"4\" weight=\"600\">ROLLS RENEW IN:</font>\n<b>%02d:%02d:%02d</b>",
						v14,
						v15,
						v16
					)

					if v13 == 0 then
						Auras.RenewRolls()
					end
				end

				task.wait(1)
			end
		end)
		return function()
			task.cancel(thread)
		end
	end, { v5 })
	React.useEffect(function()
		if status ~= Enums.UserStatus.BoomboxPurchased then
			v3.SetWindowTab(Enums.WindowTab.Upsell)
		end
	end, { status })

	if status ~= Enums.UserStatus.BoomboxPurchased then
		return nil
	end

	local createElement = React.createElement
	local fragment = React.Fragment
	local v14 = {
		List = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
		Padding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10)
		}),
		View = 0
	}
	local createElement2 = React.createElement
	local v16 = {
		Size = UDim2.new(1, -16, 0, 0),
		Transparency = 1,
		LayoutOrder = -1
	}
	local children3 = {
		List = React.createElement("UIListLayout", {
			Wraps = true,
			Padding = UDim.new(0.025, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left
		}),
		SlotDisplay = React.createElement("Frame", {
			Size = UDim2.fromScale(v4 and 0.741 or 1, 0.206),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			BackgroundColor3 = Color3.new(1, 1, 1),
			ClipsDescendants = true,
			LayoutOrder = 5
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 9)
			}),
			Gradient = React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("#7753aa")),
					ColorSequenceKeypoint.new(0.3, Color3.fromHex("FFFFFF")),
					ColorSequenceKeypoint.new(0.7, Color3.fromHex("FFFFFF")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("7753aa"))
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(0.3, 0),
					NumberSequenceKeypoint.new(0.7, 0.3),
					NumberSequenceKeypoint.new(1, 0.5)
				}),
				Rotation = 90
			}),
			LeftWave = React.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.6, 0.3),
				Image = "rbxassetid://89948083083415",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				SizeConstraint = Enum.SizeConstraint.RelativeYY
			}),
			RightWave = React.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.6, 0.3),
				Image = "rbxassetid://114028734806103",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				SizeConstraint = Enum.SizeConstraint.RelativeYY
			}),
			RollTable = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.2),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ref = ref3
			}, children, {
				Scale = React.createElement("UIScale", {
					Scale = 2.5
				})
			})
		}),
		AddRolls = React.createElement(Button, {
			Size = UDim2.fromScale(0.225, 0.206),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Image = "rbxassetid://127812013490839",
			ScaleType = Enum.ScaleType.Crop,
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			HoverScale = 1.05,
			PressScale = 0.95,
			OnActivated = not v11 and function()
				local localPlayer = Players.LocalPlayer
				local rollAssetId = v6.RollAssetId
				local rollGamePass = v6.RollGamePass

				if localPlayer then
					if rollAssetId and rollAssetId > 0 then
						Marketplace.PromptPurchase(rollAssetId, Enum.InfoType.Asset)
					elseif rollGamePass then
						Marketplace.PromptPurchase(rollGamePass, Enum.InfoType.GamePass)
					end
				end
			end or nil
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.1, 0)
			}),
			Text = React.createElement("TextLabel", {
				Text = `ADD {v8}\nROLLS\nPER DAY`,
				TextColor3 = Color3.fromHex("#FFFFFF"),
				FontFace = v2("Font-Bold"),
				TextScaled = true,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0.6),
				Position = UDim2.fromScale(0.5, 0.35),
				AnchorPoint = Vector2.new(0.5, 0.5),
				LayoutOrder = 1
			}),
			ButtonLabel = React.createElement("Frame", {
				Position = UDim2.new(0.5, 0, 1, -18),
				Size = UDim2.fromOffset(60, 15),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = v11 and Color3.fromHex("#868686") or Color3.fromHex("#FFFFFF"),
				BackgroundTransparency = 0,
				LayoutOrder = 2,
				ZIndex = 2
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0)
				}),
				Text = React.createElement("TextLabel", {
					Text = v11 and "OWNED" or "BUY",
					TextScaled = true,
					FontFace = v2("Font-Bold"),
					BackgroundTransparency = 1,
					TextColor3 = Color3.new(),
					Size = UDim2.fromScale(1, 0.75),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}),
				Stroke = React.createElement("UIStroke", {
					Color = Color3.new(),
					Transparency = 0.75,
					Thickness = 0.5
				})
			})
		}),
		SlotCountdown = 0,
		Flex = 0
	}
	local createElement3 = React.createElement
	local v18 = {
		Size = UDim2.fromScale(1, 0.206),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		LayoutOrder = 6
	}
	local createElement4 = React.createElement
	local v20 = {
		Padding = UDim.new(0.1, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = 0,
		FillDirection = 0,
		VerticalAlignment = 0,
		HorizontalAlignment = 0
	}
	local horizontalFlex

	if v5.Rolls > 0 then
		horizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
	else
		horizontalFlex = Enum.UIFlexAlignment.Fill
	end

	v20.HorizontalFlex = horizontalFlex
	v20.FillDirection = Enum.FillDirection.Horizontal
	v20.VerticalAlignment = Enum.VerticalAlignment.Center
	v20.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local children4 = {
		List = createElement4("UIListLayout", v20),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 9)
		}),
		Padding = React.createElement("UIPadding", {
			PaddingRight = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingBottom = UDim.new(),
			PaddingTop = UDim.new()
		}),
		Roll = 0,
		RollInfo = 0
	}
	local roll

	if v5.Rolls > 0 then
		roll = React.createElement(TextButton, {
			[React.Tag] = "ofRollForAuras",
			Text = "ROLL",
			OnActivated = function()
				local current = ref3.current

				if ref.current or not current then
					return
				end

				local rollForAura = Auras.RollForAura()
				ref.current = not RunContext.IsEdit
				local v25, v26 = rollForAura:await()

				if RunContext.IsEdit and v25 then
					print(v26)
				end

				if not (v25 and v26.Rolled) then
					ref.current = false
					return
				end

				local current3 = math.ceil(assert(v26.Roll) * 20) - 1
				local current2 = ref2.current or 0
				current.Position = UDim2.fromScale(0.5, 0.5 - current2 / 2)
				ref2.current = current3
				current.Position += UDim2.fromScale(0, 30)

				if v26.UnlockedAura then
					local unlockedAura = v26.UnlockedAura
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://1842442567"
					sound.Parent = current
					task.delay(2, function()
						sound:Play()
						sound.Ended:Connect(function()
							sound:Destroy()
						end)
					end)
					task.delay(5, function()
						local widget = v3.Widget
						local sound2 = Instance.new("Sound")
						sound2.Parent = current:FindFirstAncestorWhichIsA("LayerCollector")
						sound2.SoundId = "rbxassetid://1843648200"
						sound2.Playing = true
						sound2.Ended:Once(function()
							sound2:Destroy()
						end)
						v3.SetWidget({
							ReturnText = `{v26.UnlockedAura:upper()} UNLOCKED! 🎉`,
							HideBackground = true,
							ReturnFunc = function()
								v3.SetWidget(widget)
							end,
							Widget = function(props)
								return React.createElement(ItemPage, {
									Size = props.Size,
									Position = props.Position,
									AnchorPoint = props.AnchorPoint,
									Target = {
										RenderContext = "ItemPage",
										Type = "AURA",
										Id = unlockedAura
									}
								})
							end,
							ExtraComponents = {
								Confetti = React.createElement(Confetti)
							}
						})
					end)
				end

				current:TweenPosition(
					UDim2.fromScale(0.5, 0.5 - current3 / 2),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quint,
					6,
					true,
					function(_)
						ref.current = false
					end
				)
			end
		})
	else
		roll = false
	end

	children4.Roll = roll
	children4.RollInfo = React.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.fromScale(1.2, 0.6),
		LayoutOrder = 2
	}, {
		Stroke = React.createElement("UIStroke", {
			Color = Color3.new(),
			Thickness = 1
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 9)
		}),
		Rolls = React.createElement("TextLabel", {
			RichText = true,
			Text = not (v5.Rolls > 0) and "" or `<b><font size="20">{v5.Rolls}</font></b>\n<b>ROLLS LEFT</b>`,
			LineHeight = 1,
			TextScaled = true,
			Size = UDim2.fromScale(1, 0.75),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = v2("Font-Regular"),
			TextColor3 = Color3.new(),
			ref = ref4
		})
	})
	children3.SlotCountdown = createElement3("ImageLabel", v18, children4)
	children3.Flex = React.createElement("UIFlexItem", {
		FlexMode = Enum.UIFlexMode.Fill
	})
	v14.View = createElement2("Frame", v16, children3, children2)
	return createElement(fragment, nil, v14)
end

return RollForAuras