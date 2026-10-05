game:GetService("ReplicatedStorage")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
local Maid = require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
require(game.ReplicatedStorage.Spritesheets)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
local createElement = React.createElement
local ExplorerBuffs = require(game.ReplicatedStorage.DungeonShared.ExplorerBuffs)
local explorerBuffs = ExplorerBuffs.ExplorerBuffs
local fn

local function CompositeBuffIcon(props)
	local cardImageInfo = props.cardImageInfo
	local cornerSprite = props.cornerSprite
	local itemColorTheme = props.itemColorTheme
	local ref = React.useRef(nil)
	local ref2 = React.useRef(0)
	local ref3 = React.useRef(0)
	local ref4 = React.useRef(UDim2.new(0, 0))
	local ref5 = React.useRef(UDim2.new(1, 0, 1, 0))
	local ref6 = React.useRef(0)
	local HSV, v, v2 = itemColorTheme:ToHSV()
	local v5 = {
		Visible = props.componentsAreVisibleRef,
		BorderSizePixel = 0,
		Size = props.Size or UDim2.fromScale(1, 0.3)
	}
	local backgroundColor

	if props.showValue then
		backgroundColor = Color3.new(0.545098, 0.545098, 0.545098)
	else
		backgroundColor = Color3.fromHSV((HSV + 0) % 1, math.min(1, v * 1.15), v2 * 0.4)
	end

	v5.BackgroundColor3 = backgroundColor
	local imageColor

	if cardImageInfo.Outline then
		imageColor = Color3.fromRGB(0, 0, 0)
	else
		imageColor = Color3.fromRGB(255, 255, 255)
	end

	v5.ImageColor3 = imageColor
	local _ = props.showValue
	v5.BackgroundTransparency = 1
	v5.Image = cardImageInfo.Image
	v5.ImageRectOffset = cardImageInfo.ImageRectOffset
	v5.ImageRectSize = cardImageInfo.ImageRectSize
	v5.ScaleType = Enum.ScaleType.Fit
	v5.ref = ref
	v5[React.Event.MouseEnter] = props.showValue and function()
		if not props.setPreviewCard then
			return
		end

		local now = tick()
		ref3.current = now
		task.wait(0.5)

		if now ~= ref3.current then
			return
		end

		local _ = ref.current.AbsoluteSize
		local _ = ref.current.AbsolutePosition
		ref4.current = UDim2.new(0, 0, 0, 0)
		task.spawn(function()
			local v9 = 0

			while ref3.current == now do
				v9 -= task.wait() * 5
				ref6.current = math.max(0, v9 + 1)
			end
		end)
		ref2.current = math.random(0, 1) == 0 and -1 or 1
		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		props.setPreviewCard(createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, ref.current.AbsoluteSize.X * 2.85, 0, ref.current.AbsoluteSize.Y * 5),
			AnchorPoint = Vector2.new(
				1 / viewportSize.X * ref.current.AbsolutePosition.X,
				1 / viewportSize.Y * ref.current.AbsolutePosition.Y
			),
			Position = ref.current and UDim2.new(
				1 / viewportSize.X * ref.current.AbsolutePosition.X,
				0,
				1 / viewportSize.Y * ref.current.AbsolutePosition.Y,
				ref.current.AbsoluteSize.Y * -0.5
			)
		}, { createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.57
			}), createElement(fn, {
				buffName = props.buffName,
				newValue = props.currentValue or 0,
				oldValue = nil,
				onClose = function() end,
				nonSelectable = true,
				goalPosition = ref4,
				goalSize = ref5,
				goalRotation = ref2,
				transparency = ref6
			}) }))
	end or nil
	v5[React.Event.MouseLeave] = props.showValue and function()
		if not props.setPreviewCard then
			return
		end

		ref3.current = 0
		props.setPreviewCard(nil)
	end or nil
	local v10

	if props.cardInfo.Colors.IconGradient then
		v10 = createElement("UIGradient", {
			Color = props.cardInfo.Colors.IconGradient,
			Rotation = 90
		})
	end

	local v11

	if props.showValue then
		v11 = createElement("UICorner", {
			CornerRadius = UDim.new(0, 0)
		})
	end

	local v12

	if props.showValue then
		v12 = createElement("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})
	end

	local v13

	if cornerSprite then
		v13 = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0.55, 0, 0, 0),
			Size = UDim2.fromScale(0.45, 0.45),
			BackgroundTransparency = 1,
			Image = cornerSprite.Image,
			ImageRectOffset = cornerSprite.ImageRectOffset,
			ImageRectSize = cornerSprite.ImageRectSize,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = itemColorTheme,
			ZIndex = 3
		})
	end

	local v14

	if cardImageInfo.Outline then
		v14 = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = cardImageInfo.Outline.Image,
			ImageRectOffset = cardImageInfo.Outline.ImageRectOffset,
			ImageRectSize = cardImageInfo.Outline.ImageRectSize,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 2
		}, {})
	end

	local v15

	if props.cardInfo.LetterDescriptor and props.showValue then
		local v18 = {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Text = props.cardInfo.LetterDescriptor,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Font = 0,
			ZIndex = 3
		}
		local font

		if props.showValue then
			font = Enum.Font.ArialBold
		else
			font = Enum.Font.Bangers
		end

		v18.Font = font
		v15 = createElement("TextLabel", v18, { (createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1
			})) })
	end

	local v16

	if props.showValue and props.cardInfo.GetValue and props.currentValue then
		v16 = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 0, 1.1, 0),
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			Text = props.cardInfo.GetValue(props.currentValue),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			RichText = true,
			ZIndex = 4,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextXAlignment = Enum.TextXAlignment.Right
		}, { (createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1
			})) })
	end

	return createElement("ImageLabel", v5, {
		v10,
		v11,
		v12,
		v13,
		v14,
		v15,
		v16
	})
end

fn = function(data)
	local explorerBuff = explorerBuffs[data.buffName]
	local HSV, v, v2 = explorerBuff.Rarity.Color:ToHSV()
	local cornerSprite = nil
	local v4

	if explorerBuff.GetCardImage then
		v4, cornerSprite = explorerBuff.GetCardImage()
	else
		v4 = {
			Image = "rbxassetid://0",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(64, 64),
			Outline = nil
		}
	end

	local v5 = v4 or {
		Image = "rbxassetid://0",
		ImageRectOffset = Vector2.new(0, 0),
		ImageRectSize = Vector2.new(64, 64)
	}
	local color = v5.Color or Color3.fromRGB(255, 255, 255)

	if v5.Outline then
		local outline = v5.Outline
		outline.Outline = v5
		v5 = outline
	end

	local flag = false
	local ref = React.useRef(ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV((HSV + 0) % 1, v, v2 * 0.85)),
		ColorSequenceKeypoint.new(0.45, Color3.fromHSV(HSV, v * 1, v2 * 1)),
		ColorSequenceKeypoint.new(0.55, Color3.fromHSV(HSV, v * 1, v2 * 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV((HSV - 0) % 1, v, v2 * 0.85))
	}))
	local ref2 = React.useRef(nil)
	React.useEffect(function()
		ref2.current = task.spawn(function()
			local lastTime = tick()

			while true do
				local v6 = math.clamp(math.clamp(tick() - lastTime, 0, 0.35) / 0.35, 0, 0.5)
				local colorSequenceKeypoints = {}
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(0, Color3.fromHSV((HSV + 0.05 + (v6 * 0.1 + 0)) % 1, v, v2 * 0.8))
				)
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(0.45, Color3.fromHSV((HSV - 0.05 + v6 * 0.1) % 1, v * 1, v2 * 1))
				)
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(0.55, Color3.fromHSV((HSV - 0.05 + v6 * 0.1) % 1, v * 1, v2 * 1))
				)
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(1, Color3.fromHSV((HSV - 0.05 + (v6 * 0.1 + -0)) % 1, v, v2 * 0.8))
				)
				ref.current = ColorSequence.new(colorSequenceKeypoints)

				if v6 >= 0.5 then
					break
				end

				task.wait()
			end

			flag = true
		end)
		return function()
			task.cancel(ref2.current)
		end
	end, {})
	local ref3 = React.useRef(0)
	local ref4 = React.useRef(110)
	local ref5 = React.useRef(nil)
	local ref6 = React.useRef(UDim2.new(0, 0))
	local ref7 = React.useRef(UDim2.new(0, 0))
	local ref8 = React.useRef(Color3.fromRGB(0, 0, 0))
	React.useEffect(function()
		local v6 = ref5
		local current = ref5.current

		if not current then
			local v8

			if game.Players.LocalPlayer then
				v8 = game.Players.LocalPlayer.PlayerGui
			else
				v8 = game.StarterGui
			end

			current = Instance.new("ScreenGui", v8)
		end

		v6.current = current
		return function()
			ref5.current:Destroy()
		end
	end, { ref5 })
	local v6 = React.useMemo(function()
		local v9 = createElement("TextButton", {
			ref = data.cardInstanceRef,
			AutoButtonColor = false,
			BackgroundTransparency = data.transparency or 0.05,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Text = "",
			[React.Event.Activated] = function()
				if flag then
					data.onClose(data.buffName)
				end
			end
		}, {
			React.useMemo(function()
				return {
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0, 2)
					}),
					UIStroke = createElement("UIStroke", {
						Color = ref8,
						Thickness = 2.5,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Transparency = data.transparency or 0
					}),
					UIPadding = createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 2),
						PaddingTop = UDim.new(0.05, 10),
						PaddingLeft = UDim.new(0, 0),
						PaddingRight = UDim.new(0, 0)
					}),
					UIGradient = createElement("UIGradient", {
						Color = ref,
						Rotation = ref4
					}),
					UIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0.05, 0)
					}),
					CompositeBuffIcon = createElement(CompositeBuffIcon, {
						cardImageInfo = v5,
						cornerSprite = cornerSprite,
						itemColorTheme = color,
						cardInfo = explorerBuff,
						buffName = data.buffName,
						componentsAreVisibleRef = data.componentsAreVisibleRef
					})
				}
			end, { explorerBuff }),
			{
				DisplayName = React.useMemo(function()
					return (createElement("TextLabel", {
						Visible = data.componentsAreVisibleRef,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(0.9, 0.1),
						BackgroundTransparency = 1,
						Text = explorerBuff.DisplayName,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						RichText = true
					}, { (createElement("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1
						})) }))
				end, { explorerBuff })
			},
			{
				BuffDescription = React.useMemo(function()
					return (createElement("TextLabel", {
						Visible = data.componentsAreVisibleRef,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(0.9, 0.5),
						BackgroundTransparency = 1,
						Text = (not (data.oldValue and explorerBuff.GetLevelUpText) and "" or explorerBuff.GetLevelUpText(
							data.oldValue,
							data.newValue
						)) .. explorerBuff.GetDescription(data.oldValue or nil, data.newValue),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextYAlignment = Enum.TextYAlignment.Top,
						RichText = true
					}, { createElement("UITextSizeConstraint", {
							MaxTextSize = 20
						}), (createElement("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = explorerBuff.Rarity.Name == "Legendary" and 1 or 0,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
							Transparency = data.transparency or 0
						})) }))
				end, { data.oldValue, data.newValue, explorerBuff })
			}
		})
		return (createElement("Frame", {
			BackgroundTransparency = 1,
			Parent = ref5,
			Size = ref6,
			Position = ref7,
			Rotation = ref3
		}, { React.useMemo(function()
				if explorerBuff.Rarity.Name ~= "Epic" and explorerBuff.Rarity.Name ~= "Legendary" then
					return
				end

				local colorSequence = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(242, 255, 98)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 138, 255))
				})
				local colorSequenceKeypoints = {}

				for _, keypoint in pairs(colorSequence.Keypoints) do
					local HSV2, v10, v11 = keypoint.Value:ToHSV()
					table.insert(
						colorSequenceKeypoints,
						ColorSequenceKeypoint.new(keypoint.Time, Color3.fromHSV(HSV2, v10, v11))
					)
				end

				local colorSequence2 = ColorSequence.new(colorSequenceKeypoints)
				return (createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 3, 1, 3),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}, { (createElement("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						Thickness = 5,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}, { createElement(function()
							local ref9 = React.useRef(0)
							React.useEffect(function()
								local thread = nil
								thread = task.defer(function()
									while thread do
										ref9.current = (ref9.current + 120 * task.wait()) % 360 + (ref4.current - 110) * -0.1
									end
								end)
								return function()
									pcall(task.cancel, thread)
								end
							end, {})
							return (createElement("UIGradient", {
								Color = colorSequence2,
								Rotation = ref9
							}))
						end, {}) })) }))
			end, { explorerBuff }), v9, (createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -3, 1, -2),
				Position = UDim2.new(0.5, -1, 0.5, -1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = -1
			}, { (createElement("UIStroke", {
					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 4,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				})) })) }))
	end, { data, explorerBuff })
	local ref9 = React.useRef(nil)
	local v7 = React.useMemo(function()
		return createElement(function()
			local state, setState = React.useState(0)
			ref9.current = setState
			React.useEffect(function()
				local thread = task.spawn(function()
					local v8 = state + (data.goalRotation and data.goalRotation.current or 0)

					while v8 ~= ref3.current do
						local v9 = task.wait()
						ref3.current += (v8 - ref3.current) * 0.2 * (v9 * 60)
						ref4.current += (v8 * -40 * (v9 * 60) + 110 - ref4.current) * 0.2 * (v9 * 60)
					end
				end)
				return function()
					pcall(task.cancel, thread)
					ref3.current = state
				end
			end, { state, data.goalRotation and data.goalRotation.current })
			return nil
		end, {})
	end, {})
	local ref10 = React.useRef(nil)
	React.useEffect(function()
		local current = ref10.current

		if not current then
			return function() end
		end

		ref6.current = UDim2.new(0, current.AbsoluteSize.X - 1, 0, current.AbsoluteSize.Y - 1)
		ref7.current = UDim2.new(0, current.AbsolutePosition.X, 0, current.AbsolutePosition.Y)
		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			ref6.current = UDim2.new(0, current.AbsoluteSize.X - 1, 0, current.AbsoluteSize.Y - 1)
		end)
		local absolutePositionChangedConnection = current:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			ref7.current = UDim2.new(0, current.AbsolutePosition.X, 0, current.AbsolutePosition.Y)
		end)
		return function()
			if absoluteSizeChangedConnection then
				absoluteSizeChangedConnection:Disconnect()
			end

			if absolutePositionChangedConnection then
				absolutePositionChangedConnection:Disconnect()
			end
		end
	end, { ref10 })
	return (createElement("Frame", {
		Size = data.goalSize,
		Position = data.goalPosition,
		BackgroundTransparency = 1,
		Rotation = ref3,
		AnchorPoint = data.AnchorPoint,
		[React.Event.InputBegan] = function(_, _)
			ref9.current(2)
		end,
		[React.Event.InputEnded] = function(_, _)
			ref9.current(0)
		end,
		[React.Change.Parent] = function(current)
			ref10.current = current
		end
	}, { v6, v7 }))
end

local function cardGroupController(items)
	local children = {}

	if items then
		for _, item in pairs(items) do
			table.insert(children, createElement(fn, {
				buffName = item.buffName,
				oldValue = item.oldValue,
				newValue = item.newValue,
				goalPosition = item.goalPosition,
				goalSize = item.goalSize,
				goalRotation = item.goalRotation,
				onClose = function() end
			}))
		end
	end

	return children
end

local v = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5
}
local BuffSelector = {}

function BuffSelector.BuffSelector(state)
	Maid.new()
	local children = {}

	if not state.buffs then
		state.buffs = {}

		for _, buffName in {
			"Lifesteal",
			"Size",
			"Skyjumps",
			"Lifesteal",
			"Size",
			"Skyjumps"
		} do
			table.insert(state.buffs, {
				buffName = buffName,
				oldValue = 0,
				newValue = 1
			})
		end
	end

	local flag = false

	if state.buffs then
		local count = #state.buffs
		local _ = (count - 1) * 0.01

		for k, buff in pairs(state.buffs) do
			local v2 = false
			local v3 = 1 / math.max(1, count / 3.5)
			local v4 = 0.5 + (k - (count + 1) / 2) * (v3 * 0.35)
			local ref = React.useRef(UDim2.new(v3 * 0.3, 5, v3 * 0.95, 5))
			local ref2 = React.useRef(UDim2.new(v4, 0, -1, 0))
			local ref3 = React.useRef(1)
			local ref4 = React.useRef(false)
			local ref5 = React.useRef(nil)

			local function tween(callback, p)
				local lastTime = tick()

				while true do
					local v5 = (tick() - lastTime) * p
					callback((math.clamp(v5, 0, 1)))

					if v5 >= 1 then
						break
					end

					task.wait()
				end
			end

			local function anchorSize(childName)
				local child = ref5.current:FindFirstChild(childName)
				local absoluteSize

				if child then
					absoluteSize = child.AbsoluteSize
				else
					absoluteSize = child
				end

				while not absoluteSize or absoluteSize.X == 0 do
					task.wait()
					absoluteSize = child and child.AbsoluteSize
				end

				child.Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y)
			end

			local cardInstanceRef = ref5
			local anchorSize2 = anchorSize
			local v10 = k
			local tween2 = tween
			task.defer(function()
				while not cardInstanceRef.current do
					task.wait()
				end

				anchorSize2("BuffDescription")
				anchorSize2("DisplayName")
				anchorSize2("CompositeBuffIcon")
				cardInstanceRef.current.ClipsDescendants = true
				local lastTime = tick()

				while true do
					local v14 = (tick() - lastTime) * 5
					local v15 = math.clamp(-1 + 1.5 * v14, -1, 0.5)
					ref3.current = math.clamp(1 - v14, 0, 1)
					ref2.current = UDim2.new(v4, 0, v15, 0)

					if v15 >= 0.5 then
						break
					end

					task.wait()
				end

				local lastTime2 = tick()

				while true do
					local v14 = math.clamp(0.5 + 1 * ((tick() - lastTime2) * 1), 0.5, 0.55)
					ref2.current = UDim2.new(v4, 0, v14, 0)

					if v14 >= 0.55 then
						break
					end

					task.wait()
				end

				local lastTime3 = tick()

				while true do
					local v14 = math.clamp(0.55 - 1 * ((tick() - lastTime3) * 1), 0.5, 0.55)
					ref2.current = UDim2.new(v4, 0, v14, 0)

					if v14 <= 0.5 then
						break
					end

					task.wait()
				end

				ref2.current = UDim2.new(v4, 0, 0.5, 0)
				ref3.current = 0.05

				if v10 == 1 then
					local sound = Instance.new("Sound")
					task.delay(1, sound.Destroy, sound)
					local Sound = require(game.ReplicatedStorage.Util.Sound)
					sound.SoundId = Sound:Get("Dungeons.BFLab_Reveal_Cards_01"):GetAttribute("SoundId")
					Groups.assign(sound, "HighPriority")
					sound.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
					sound:Play()
				end

				task.wait(0.1 * v10)
				tween2(function(p)
					ref.current = UDim2.new(v3 * 0.3 + -0.2 * p * v3, 0, v3 * 0.95, 0)
				end, 7)
				ref4.current = true
				tween2(function(p)
					ref.current = UDim2.new(v3 * 0.1 + 0.2 * p * v3, 0, v3 * 0.95, 0)
				end, 7)
				v2 = true
			end)
			local v14 = buff
			table.insert(children, createElement(fn, {
				cardInstanceRef = ref5,
				componentsAreVisibleRef = ref4,
				buffName = buff.buffName,
				oldValue = buff.oldValue,
				newValue = buff.newValue,
				onClose = function(...)
					if not v2 or flag then
						return
					end

					flag = true

					for k2, v15 in pairs(children) do
						if v15.props.buffName == v14.buffName then
							local v16 = v15
							task.spawn(function()
								local lastTime = tick()

								while tick() - lastTime < 0.5 do
									local v17 = (tick() - lastTime) * 10
									v16.props.goalPosition.current = UDim2.new(
										v16.props.goalPosition.current.X.Scale,
										0,
										0.5 + 1.5 * v17 * v17,
										0
									)
									task.wait()
								end
							end)
						else
							local v16 = v15
							task.spawn(function()
								local lastTime = tick()

								while tick() - lastTime < 0.5 do
									local v17 = (tick() - lastTime) * 10
									v16.props.goalPosition.current = UDim2.new(
										v16.props.goalPosition.current.X.Scale,
										0,
										0.5 - 1.5 * v17 * v17,
										0
									)
									task.wait()
								end
							end)
						end
					end

					local sound = Instance.new("Sound")
					task.delay(1, sound.Destroy, sound)
					local Sound = require(game.ReplicatedStorage.Util.Sound)
					sound.SoundId = Sound:Get((`Dungeons.BFLab_UI_Card_Select_0{math.random(1, 4)}`)):GetAttribute("SoundId")
					Groups.assign(sound, "HighPriority")
					sound.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
					sound:Play()
					task.wait(0.5)
					return state.onClose(...)
				end,
				goalSize = ref,
				transparency = ref3,
				goalPosition = ref2,
				AnchorPoint = Vector2.new(0.5, 0.5)
			}))
		end
	end

	local element = createElement("Frame", {
		Size = UDim2.fromScale(0.85, 0.4),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}, {
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 2,
			DominantAxis = Enum.DominantAxis.Width
		}),
		CardsFrame = createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5)
		}, { children })
	})
	return React.useMemo(function()
		return element
	end, {})
end

function BuffSelector.BuffList(p)
	local state, setState = React.useState(nil)
	local useMemo = React.useMemo

	local function fn2()
		local result = {}

		for k, buff in pairs(p.buffs) do
			table.insert(result, { k, buff })
		end

		table.sort(result, function(a, b)
			local v2 = not explorerBuffs[a[1]] and 0 or v[explorerBuffs[a[1]].Rarity] or 0
			local v3 = not explorerBuffs[b[1]] and 0 or v[explorerBuffs[b[1]].Rarity] or 0

			if v2 == v3 then
				return a[1] < b[1]
			end

			return v3 < v2
		end)
		return result
	end

	local HttpService = game:GetService("HttpService")
	local v2 = useMemo(fn2, { HttpService:JSONEncode(p.buffs) })
	local ref = React.useRef({})
	local current = ref.current
	local useMemo2 = React.useMemo

	local function fn3()
		return createElement(function(p2)
			local icons = p2.icons

			for k, v3 in pairs(v2) do
				local buffName = v3[1]
				local currentValue = v3[2]
				local explorerBuff = explorerBuffs[buffName]

				if not explorerBuff then
					continue
				end

				local cornerSprite = nil
				local v7

				if explorerBuff.GetCardImage then
					v7, cornerSprite = explorerBuff.GetCardImage()
				else
					v7 = {
						Image = "rbxassetid://0",
						ImageRectOffset = Vector2.new(0, 0),
						ImageRectSize = Vector2.new(64, 64),
						Outline = nil
					}
				end

				local v8 = v7 or {
					Image = "rbxassetid://0",
					ImageRectOffset = Vector2.new(0, 0),
					ImageRectSize = Vector2.new(64, 64)
				}
				local color = v8.Color or Color3.fromRGB(255, 255, 255)

				if v8.Outline then
					local outline = v8.Outline
					outline.Outline = v8
					v8 = outline
				end

				local v9 = current and current.props and current.props.icons[k]

				if v9 and v9.props.currentValue == currentValue and v9.props.buffName == buffName then
					table.insert(icons, v9)
				else
					local itemColorTheme = color
					local cardInfo = explorerBuff
					local currentValue2 = currentValue
					local buffName2 = buffName
					table.insert(icons, React.useMemo(function()
						return createElement(CompositeBuffIcon, {
							cardImageInfo = v8,
							cornerSprite = cornerSprite,
							itemColorTheme = itemColorTheme,
							cardInfo = cardInfo,
							currentValue = currentValue2,
							showValue = true,
							setPreviewCard = setState,
							buffName = buffName2
						})
					end, { buffName, currentValue }))
				end
			end

			return icons
		end, {
			icons = {}
		})
	end

	local HttpService2 = game:GetService("HttpService")
	local current2 = useMemo2(fn3, { HttpService2:JSONEncode(v2) })
	ref.current = current2
	local v4 = React.useMemo(function()
		return state or nil
	end, { state })
	local element = createElement("Frame", {
		Size = UDim2.fromScale(0.25, 0.12),
		Position = UDim2.fromScale(0.2075, 0.8),
		BackgroundTransparency = 1
	}, { createElement("UIAspectRatioConstraint", {
			AspectRatio = 2,
			DominantAxis = Enum.DominantAxis.Width
		}), createElement("UIGridLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			CellSize = UDim2.fromScale(0.17799, 0.329),
			CellPadding = UDim2.fromScale(0.03, 0.06)
		}), current2 })
	return (createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1
	}, { element, v4 }))
end

return BuffSelector