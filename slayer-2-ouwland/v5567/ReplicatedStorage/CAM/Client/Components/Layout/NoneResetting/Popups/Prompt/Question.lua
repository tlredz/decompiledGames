local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker.Presets)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.15)
local info2 = faye.Info(0.4)
local info3 = faye.Info(0.3, Enum.EasingStyle.Back)
local v = {
	Yes = BunchaIcons.Checkmark2,
	No = BunchaIcons.DeniedMark2
}
return function(animator, p, data, p2: number, object)
	local parent = p.Parent or p
	local v2 = parent:FindFirstChild("QuestionCounter")
	local Y = GuiService:GetGuiInset().Y

	if v2 == nil then
		v2 = Instance.new("Frame")
		v2.Size = UDim2.new(1, 0, 1, Y)
		v2.Name = "QuestionCounter"
		v2.Position = UDim2.fromOffset(0, -Y)
		v2.ZIndex = p.ZIndex
		v2.Parent = parent
		v2.BackgroundColor3 = Color3.new()
		v2.BackgroundTransparency = 1
		local frame = Instance.new("Frame", v2)
		frame.Name = "Holder"
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		animator:LoadAnimation(v2, {
			BackgroundTransparency = data.BackgroundTransparency or 0.2
		}, info):Play()
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Parent = frame
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.FillDirection = Enum.FillDirection.Vertical
		uIListLayout.Padding = UDim.new(0, 5)
		local textButton = Instance.new("TextButton", v2)
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Name = "Button"
		textButton.Text = ""
		textButton.ZIndex = -1
		textButton.BackgroundTransparency = 1
	end

	local flag = false
	local timout = data.Timout or 5
	script.PS2notificationOPEN.TimePosition = 0
	script.PS2notificationOPEN:Play()
	local count = v2:GetAttribute("Count") or 0

	if count < 0 then
		local button = v2:FindFirstChild("Button")

		if button ~= nil then
			button.Size = UDim2.fromScale(1, 1)
		end

		count = 0
	end

	v2:SetAttribute("Count", count + 1)
	local content = data.Content
	local text, options

	if typeof(content) == "table" then
		text = content.Text or "Are you sure about this?"
		options = content.Options
	else
		text = content or "Are you sure about this?"
	end

	local v3 = options == nil and {
		{
			Color = Color3.new(0.15, 1, 0.15),
			Text = "Yes"
		},
		{
			Color = Color3.new(1, 0.15, 0.15),
			Text = "No"
		}
	} or options
	local count2 = #v3

	if data.Default ~= nil then
		for k, text2 in v3 do
			if typeof(text2) == "table" then
				text2 = text2.Text
			end

			if text2 ~= data.Default then
				continue
			end

			count2 = k
			break
		end
	end

	animator:Add(function()
		if v2.Parent == nil then
			return
		end

		local v4 = (v2:GetAttribute("Count") or 1) - 1
		v2:SetAttribute("Count", v4)

		if v4 == 0 then
			local v5 = math.random(-999, -1)
			v2:SetAttribute("Count", v5)
			TweenService:Create(v2, TweenInfo.new(info2.Time), {
				BackgroundTransparency = 1
			}):Play()
			local button = v2:FindFirstChild("Button")

			if button ~= nil then
				button.Size = UDim2.fromScale()
			end

			task.delay(info2.Time, function()
				local count3 = v2:GetAttribute("Count")

				if v2.Parent ~= nil and count3 == v5 then
					v2:Destroy()
				end
			end)
		end
	end)
	local canvasSize = animator:Value(UDim2.new())
	animator:Create("CanvasGroup")({
		Parent = v2.Holder,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromScale(0.2, 0.2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		GroupTransparency = animator:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = animator:Animation(1, info2),
				Size = animator:Animation(UDim2.fromScale(0.17, 0.17), info2)
			}
		end,
		animator:Create("UIAspectRatioConstraint")({
			AspectRatio = 2
		}),
		animator:Create("UICorner")({
			CornerRadius = UDim.new(0.1)
		}),
		animator:Create("Frame")({
			Name = "Bg",
			ZIndex = -1,
			animator:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.1),
					NumberSequenceKeypoint.new(1, 0.3)
				}),
				Rotation = 40
			}),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = animator:Animation(0.1, info, {
				From = 1
			})
		}),
		animator:Create("UIStroke")({
			BorderOffset = UDim.new(0, -6),
			Color = Color3.new(1, 1, 1),
			Transparency = 0.8
		}),
		animator:Create("ScrollingFrame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Name = "Holder",
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = canvasSize,
			ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.6,
			animator:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 5),
				AbsoluteContentSizeOnChangedInit = function(p3)
					canvasSize:Set(UDim2.fromOffset(0, p3.AbsoluteContentSize.Y))
				end
			}),
			animator:Create("TextLabel")({
				Name = "TextContent",
				Size = UDim2.fromScale(0.9, 0.55),
				BackgroundTransparency = 1,
				Text = text,
				RichText = true,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				TextWrapped = true,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				animator:Create("UITextSizeConstraint")({
					MaxTextSize = 30
				}),
				animator:Create("UIStroke")({
					Thickness = 1.5,
					Color = Color3.new(),
					Transparency = 0.35
				})
			}),
			animator:Create("Frame")({
				BackgroundTransparency = 1,
				Name = "ZButtonsHolder",
				Size = UDim2.fromScale(0.25, 0.15),
				animator:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.15, 0)
				}),
				animator:Iterate(v3, function(p3, p4, _, _)
					local text2, color

					if typeof(p4) == "table" then
						text2 = p4.Text or ""
						color = p4.Color
					else
						text2 = p4
						color = nil
					end

					return animator:Create("Frame")({
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						CleanDelay = info2.Time,
						GradientButton(animator, {
							GradientRotation = -90,
							BgColor = color,
							Clicked = function()
								if flag then
									return
								end

								flag = true

								if object ~= nil then
									object:Fire(text2)
								end

								PopUpCreator.signal:Fire(p2)
							end,
							Text = text2,
							StrokeClick = true,
							Properties = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5)
							},
							Image = v[text2],
							GradientTransparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.4),
								NumberSequenceKeypoint.new(1, 1)
							})
						}),
						function()
							if p3 == count2 then
								return animator:Create("Frame")({
									Size = UDim2.new(0.8, 0, 0, 2),
									AnchorPoint = Vector2.new(0.5, 0),
									Position = UDim2.new(0.5, 0, 1, 4),
									BackgroundTransparency = 0.75,
									BackgroundColor3 = color,
									animator:Create("Frame")({
										Name = "Bar",
										BackgroundColor3 = color,
										Size = animator:Animation(UDim2.fromScale(0, 1), animator.Info(timout), {
											From = UDim2.fromScale(1, 1)
										})
									})
								})
							end
						end
					})
				end)
			})
		}),
		After = function(p3)
			return {
				Size = animator:Animation(p3.Size, info3, {
					From = UDim2.fromScale(0.15, 0.15)
				})
			}
		end
	})
end