local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local faye = require(ReplicatedStorage.Packages.faye)
local uDim = UDim2.fromScale(0.45, 1.6)
local uDim2 = UDim2.fromScale(0.3, 1.1)
local uDim3 = UDim2.fromScale(0.275, 0.245)

local function scaled(udim: UDim2, p: number)
	if p == 1 then
		return udim
	end

	return UDim2.fromScale(udim.X.Scale * p, udim.Y.Scale * p)
end

local info = faye.Info(0.15)
local info2 = faye.Info(0.4)
local info3 = faye.Info(0.3, Enum.EasingStyle.Back)
local v = {
	Yes = BunchaIcons.Checkmark2,
	No = BunchaIcons.DeniedMark2,
	Accept = BunchaIcons.Checkmark2,
	Decline = BunchaIcons.DeniedMark2
}

local function resolveHost()
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if playerGui == nil then
		return nil
	end

	local questionStrip = playerGui:FindFirstChild("QuestionStrip", true)

	if questionStrip ~= nil then
		return questionStrip
	end

	local componentsHolder = playerGui:FindFirstChild("ComponentsHolder")
	local bottomHolder

	if componentsHolder ~= nil then
		bottomHolder = componentsHolder:FindFirstChild("BottomHolder") or nil
	end

	local aAABottomCenterNotifications

	if bottomHolder ~= nil then
		aAABottomCenterNotifications = bottomHolder:FindFirstChild("AAABottomCenterNotifications") or nil
	end

	if aAABottomCenterNotifications ~= nil then
		return aAABottomCenterNotifications
	end

	local bottomCenterNotifications = playerGui:FindFirstChild("BottomCenterNotifications", true)

	if bottomCenterNotifications == nil then
		warn("[CenterBottomQuestion] no BottomCenterNotifications strip in PlayerGui, popup not shown")
	end

	return bottomCenterNotifications
end

return function(object, _, p, p2: number, object2)
	local flag = false
	local timout = p.Timout or 5
	local content = p.Content
	local text, options

	if typeof(content) == "table" then
		text = content.Text or "Are you sure about this?"
		options = content.Options
	else
		text = content or "Are you sure about this?"
	end

	local v2 = options == nil and {
		{
			Color = Color3.new(0.15, 1, 0.15),
			Text = "Yes"
		},
		{
			Color = Color3.new(1, 0.15, 0.15),
			Text = "No"
		}
	} or options
	local pS2notificationOPEN = script:FindFirstChild("PS2notificationOPEN")

	if pS2notificationOPEN then
		pS2notificationOPEN.TimePosition = 0
		pS2notificationOPEN:Play()
	end

	local v3 = Platform_Handler.Platform.Value == "Mobile"
	local v4 = v3 and 1.35 or 1
	local v5 = v3 and 1.8 or 1
	local v6 = object:Create("CanvasGroup")
	local v7 = {
		Parent = resolveHost()
	}
	local uDim4 = uDim

	if v4 ~= 1 then
		uDim4 = UDim2.fromScale(uDim4.X.Scale * v4, uDim4.Y.Scale * v4)
	end

	v7.Size = uDim4
	v7.BackgroundTransparency = 1
	v7.CleanDelay = info2.Time
	v7.GroupTransparency = object:Animation(0, info, {
		From = 1
	})

	function v7.OnClean()
		return {
			GroupTransparency = object:Animation(1, info2)
		}
	end

	local v8 = object:Create("UIAspectRatioConstraint")({
		AspectRatio = 2.2
	})
	local v9 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.1)
	})
	local v10 = object:Create("Frame")({
		Name = "Bg",
		ZIndex = -1,
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(
					1,
					0.3
				) }),
			Rotation = 40
		}),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = object:Animation(0.1, info, {
			From = 1
		})
	})
	local v11 = object:Create("Frame")
	local v12 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Name = "Holder"
	}
	local v13 = object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5)
	})
	local v14 = object:Create("TextLabel")({
		Name = "TextContent",
		Size = UDim2.fromScale(0.9, 0.9),
		BackgroundTransparency = 1,
		Text = text,
		RichText = true,
		Font = Enum.Font.SourceSansSemibold,
		TextColor3 = Color3.new(1, 1, 1),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextBoundsOnChangedInit = function(state)
			state.TextSize = math.clamp(state.Parent.AbsoluteSize.X * 0.1, 5, 100)

			if state.TextBounds.X > 0 then
				state.Size = UDim2.fromOffset(state.TextBounds.X, state.TextBounds.Y)
			end
		end
	})
	local v15 = object:Create("Frame")
	local uDim5 = uDim3

	if v5 ~= 1 then
		uDim5 = UDim2.fromScale(uDim5.X.Scale * v5, uDim5.Y.Scale * v5)
	end

	do local _values = table.pack(v13, v14, v15({
	BackgroundTransparency = 1,
	Name = "ZButtonsHolder",
	Size = uDim5,
	object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0.15, 0)
	}),
	object:Iterate(v2, function(p3, p4, _, _)
		local text2, color

		if typeof(p4) == "table" then
			text2 = p4.Text or ""
			color = p4.Color
		else
			text2 = p4
			color = nil
		end

		return object:Create("Frame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			CleanDelay = info2.Time,
			GradientButton(object, {
				GradientRotation = -90,
				BgColor = color,
				Clicked = function()
					if flag then
						return
					end

					flag = true

					if object2 ~= nil then
						object2:Fire(text2)
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
				GradientTransparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })
			}),
			function()
				if p3 == #v2 then
					return object:Create("Frame")({
						Name = "Countdown",
						Size = UDim2.new(0.8, 0, 0, 2),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0.5, 0, 1, 4),
						BackgroundColor3 = color or Color3.new(1, 0.15, 0.15),
						BackgroundTransparency = 0.75,
						object:Create("Frame")({
							Name = "Bar",
							BackgroundColor3 = color or Color3.new(1, 0.15, 0.15),
							Size = object:Animation(UDim2.fromScale(0, 1), object.Info(timout), {
								From = UDim2.fromScale(1, 1)
							})
						})
					})
				end
			end
		})
	end)
})); for _k = 1, _values.n do v12[_k] = _values[_k] end end
	v7[1], v7[2], v7[3], v7[4] = v8, v9, v10, (v11(v12))

	function v7.After(p3)
		local size = p3.Size
		local uDim6 = uDim2
		local v21 = v4

		if v21 ~= 1 then
			uDim6 = UDim2.fromScale(uDim6.X.Scale * v21, uDim6.Y.Scale * v21)
		end

		return {
			Size = object:Animation(size, info3, {
				From = uDim6
			})
		}
	end

	v6(v7)
end