return function(object, p)
	local frame = Instance.new("Frame")
	frame:SetAttribute("WidgetUID", object.UID)
	frame.Name = "Widget"
	frame.BackgroundTransparency = 1
	frame.Visible = true
	frame.ZIndex = 20
	frame.Active = false
	frame.ClipsDescendants = true
	local frame2 = Instance.new("Frame")
	frame2.Name = "IconButton"
	frame2.Visible = true
	frame2.ZIndex = 2
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	frame2.ClipsDescendants = true
	frame2.Active = false
	object.deselected:Connect(function()
		frame2.ClipsDescendants = true
	end)
	object.selected:Connect(function()
		task.defer(function()
			object.resizingComplete:Once(function()
				if object.isSelected then
					frame2.ClipsDescendants = false
				end
			end)
		end)
	end)
	local uICorner = Instance.new("UICorner")
	uICorner:SetAttribute("Collective", "IconCorners")
	uICorner.Parent = frame2
	local Menu = require(script.Parent.Menu)
	local parent = Menu(object)
	local menuUIListLayout = parent.MenuUIListLayout
	local menuGap = parent.MenuGap
	parent.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "IconSpot"
	frame3.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
	frame3.BackgroundTransparency = 0.9
	frame3.Visible = true
	frame3.AnchorPoint = Vector2.new(0, 0.5)
	frame3.ZIndex = 5
	frame3.Parent = parent
	local clone_2 = uICorner:Clone()
	clone_2.Parent = frame3
	local clone = frame3:Clone()
	clone.Name = "IconOverlay"
	clone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	clone.ZIndex = frame3.ZIndex + 1
	clone.Size = UDim2.new(1, 0, 1, 0)
	clone.Position = UDim2.new(0, 0, 0, 0)
	clone.AnchorPoint = Vector2.new(0, 0)
	clone.Visible = false
	clone.Parent = frame3
	local textButton = Instance.new("TextButton")
	textButton:SetAttribute("CorrespondingIconUID", object.UID)
	textButton.Name = "ClickRegion"
	textButton.BackgroundTransparency = 1
	textButton.Visible = true
	textButton.Text = ""
	textButton.ZIndex = 20
	textButton.Selectable = true
	textButton.SelectionGroup = true
	textButton.Parent = frame3
	local Gamepad = require(script.Parent.Parent.Features.Gamepad)
	Gamepad.registerButton(textButton)
	local clone_3 = uICorner:Clone()
	clone_3.Parent = textButton
	local frame4 = Instance.new("Frame")
	frame4.Name = "Contents"
	frame4.BackgroundTransparency = 1
	frame4.Size = UDim2.fromScale(1, 1)
	frame4.Parent = frame3
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "ContentsList"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
	uIListLayout.Padding = UDim.new(0, 3)
	uIListLayout.Parent = frame4
	local frame5 = Instance.new("Frame")
	frame5.Name = "PaddingLeft"
	frame5.LayoutOrder = 1
	frame5.ZIndex = 5
	frame5.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame5.BackgroundTransparency = 1
	frame5.BorderSizePixel = 0
	frame5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame5.Parent = frame4
	local frame6 = Instance.new("Frame")
	frame6.Name = "PaddingCenter"
	frame6.LayoutOrder = 3
	frame6.ZIndex = 5
	frame6.Size = UDim2.new(0, 0, 1, 0)
	frame6.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame6.BackgroundTransparency = 1
	frame6.BorderSizePixel = 0
	frame6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame6.Parent = frame4
	local frame7 = Instance.new("Frame")
	frame7.Name = "PaddingRight"
	frame7.LayoutOrder = 5
	frame7.ZIndex = 5
	frame7.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame7.BackgroundTransparency = 1
	frame7.BorderSizePixel = 0
	frame7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame7.Parent = frame4
	local frame8 = Instance.new("Frame")
	frame8.Name = "IconLabelContainer"
	frame8.LayoutOrder = 4
	frame8.ZIndex = 3
	frame8.AnchorPoint = Vector2.new(0, 0.5)
	frame8.Size = UDim2.new(0, 0, 0.5, 0)
	frame8.BackgroundTransparency = 1
	frame8.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame8.Parent = frame4
	local textLabel = Instance.new("TextLabel")
	local v2 = workspace.CurrentCamera.ViewportSize.X + 200
	textLabel.Name = "IconLabel"
	textLabel.LayoutOrder = 4
	textLabel.ZIndex = 15
	textLabel.AnchorPoint = Vector2.new(0, 0)
	textLabel.Size = UDim2.new(0, v2, 1, 0)
	textLabel.ClipsDescendants = false
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromScale(0, 0)
	textLabel.RichText = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = ""
	textLabel.TextWrapped = true
	textLabel.TextWrap = true
	textLabel.TextScaled = false
	textLabel.Active = false
	textLabel.AutoLocalize = true
	textLabel.Parent = frame8
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "IconImage"
	imageLabel.LayoutOrder = 2
	imageLabel.ZIndex = 15
	imageLabel.AnchorPoint = Vector2.new(0, 0.5)
	imageLabel.Size = UDim2.new(0, 0, 0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.new(0, 11, 0.5, 0)
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Active = false
	imageLabel.Parent = frame4
	local clone2 = uICorner:Clone()
	clone2:SetAttribute("Collective", nil)
	clone2.CornerRadius = UDim.new(0, 0)
	clone2.Name = "IconImageCorner"
	clone2.Parent = imageLabel
	local TweenService = game:GetService("TweenService")
	local v3 = 0

	local function handleLabelAndImageChangesUnstaggered(_)
		task.defer(function()
			local indicator = object.indicator
			local visible = indicator and indicator.Visible
			local v4 = visible or textLabel.Text ~= ""
			local v5

			if imageLabel.Image == "" then
				v5 = false
			else
				v5 = imageLabel.Image ~= nil
			end

			local _ = Enum.HorizontalAlignment.Center
			local uDim = UDim2.fromScale(1, 1)

			if v5 and not v4 then
				frame8.Visible = false
				imageLabel.Visible = true
				frame5.Visible = false
				frame6.Visible = false
				frame7.Visible = false
			elseif v5 or not v4 then
				if v5 and v4 then
					frame8.Visible = true
					imageLabel.Visible = true
					frame5.Visible = true
					frame6.Visible = not visible
					frame7.Visible = not visible
					local _ = Enum.HorizontalAlignment.Left
				end
			else
				frame8.Visible = true
				imageLabel.Visible = false
				frame5.Visible = true
				frame6.Visible = false
				frame7.Visible = true
			end

			frame2.Size = uDim

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getItemWidth(instance)
				return instance:GetAttribute("TargetWidth") or instance.AbsoluteSize.X
			end

			local offset = uIListLayout.Padding.Offset
			local X = textLabel.TextBounds.X
			frame8.Size = UDim2.new(0, X, textLabel.Size.Y.Scale, 0)
			local v6 = offset

			for _, guiObject in pairs(frame4:GetChildren()) do
				if guiObject:IsA("GuiObject") and guiObject.Visible == true then
					v6 += getItemWidth(guiObject) + offset
				end
			end

			local minimumWidth = frame:GetAttribute("MinimumWidth")
			local minimumHeight = frame:GetAttribute("MinimumHeight")
			local borderSize = frame:GetAttribute("BorderSize")
			local v7 = math.clamp(v6, minimumWidth, v2)
			local v8 = 0
			local isSelected = #object.menuIcons > 0 and object.isSelected

			if isSelected then
				for _, guiObject in pairs(parent:GetChildren()) do
					if guiObject ~= frame3 and guiObject:IsA("GuiObject") and guiObject.Visible then
						v8 += getItemWidth(guiObject) + menuUIListLayout.Padding.Offset
					end
				end

				if not frame3.Visible then
					v7 -= getItemWidth(frame3) + menuUIListLayout.Padding.Offset * 2 + borderSize
				end

				v8 -= borderSize * 0.5
				v7 += v8 - borderSize * 0.75
			end

			menuGap.Visible = isSelected and frame3.Visible
			local desiredWidth = frame:GetAttribute("DesiredWidth")

			if desiredWidth and v7 < desiredWidth then
				v7 = desiredWidth
			end

			object.updateMenu:Fire()
			local v9 = math.max(v7 - v8, minimumWidth) - borderSize * 2
			local menuWidth = parent:GetAttribute("MenuWidth")
			local v10 = menuWidth and menuWidth + v9 + menuUIListLayout.Padding.Offset + 10

			if v10 then
				local maxWidth = parent:GetAttribute("MaxWidth")

				if maxWidth then
					v10 = math.max(maxWidth, minimumWidth)
				end

				parent:SetAttribute("MenuCanvasWidth", v7)

				if v10 < v7 then
					v7 = v10
				end
			end

			local quint = Enum.EasingStyle.Quint
			local out = Enum.EasingDirection.Out
			local v12 = math.max(v9, getItemWidth(frame3), frame3.AbsoluteSize.X)
			local v14 = math.max(v7, getItemWidth(frame), frame.AbsoluteSize.X)
			local tweenInfo = TweenInfo.new(v12 / 750, quint, out)
			local tweenInfo2 = TweenInfo.new(v14 / 750, quint, out)
			TweenService:Create(frame3, tweenInfo, {
				Position = UDim2.new(0, borderSize, 0.5, 0),
				Size = UDim2.new(0, v9, 1, -borderSize * 2)
			}):Play()
			TweenService:Create(textButton, tweenInfo, {
				Size = UDim2.new(0, v9, 1, 0)
			}):Play()
			local uDim2 = UDim2.fromOffset(v7, minimumHeight)

			if frame.Size.Y.Offset ~= minimumHeight then
				frame.Size = uDim2
			end

			frame:SetAttribute("TargetWidth", uDim2.X.Offset)
			TweenService:Create(frame, tweenInfo2, {
				Size = uDim2
			}):Play()
			v3 += 1

			for i = 1, tweenInfo2.Time * 100 do
				task.delay(i / 100, function()
					p.iconChanged:Fire(object)
				end)
			end

			task.delay(tweenInfo2.Time - 0.2, function()
				v3 -= 1
				task.defer(function()
					if v3 == 0 then
						object.resizingComplete:Fire()
					end
				end)
			end)
			object:updateParent()
		end)
	end

	local Utility = require(script.Parent.Parent.Utility)
	local stagger = Utility.createStagger(0.01, handleLabelAndImageChangesUnstaggered)
	local flag = true
	object:setBehaviour("IconLabel", "Text", stagger)
	object:setBehaviour("IconLabel", "FontFace", function(p2)
		if textLabel.FontFace == p2 then
			return
		end

		task.spawn(function()
			stagger()

			if flag then
				flag = false

				for _ = 1, 10 do
					task.wait(1)
					stagger()
				end
			end
		end)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBorderSize()
		task.defer(function()
			local borderSize = frame:GetAttribute("BorderSize")
			local alignment = object.alignment
			local v4

			if frame3.Visible == false then
				v4 = 0
			elseif alignment == "Right" then
				v4 = -borderSize or borderSize
			else
				v4 = borderSize
			end

			parent.Position = UDim2.new(0, v4, 0, 0)
			menuGap.Size = UDim2.fromOffset(borderSize, 0)
			menuUIListLayout.Padding = UDim.new(0, 0)
			stagger()
		end)
	end

	object:setBehaviour("Widget", "BorderSize", updateBorderSize)
	object:setBehaviour("IconSpot", "Visible", updateBorderSize)
	object.startMenuUpdate:Connect(stagger)
	object.updateSize:Connect(stagger)
	object:setBehaviour("ContentsList", "HorizontalAlignment", stagger)
	object:setBehaviour("Widget", "Visible", stagger)
	object:setBehaviour("Widget", "DesiredWidth", stagger)
	object:setBehaviour("Widget", "MinimumWidth", stagger)
	object:setBehaviour("Widget", "MinimumHeight", stagger)
	object:setBehaviour("Indicator", "Visible", stagger)
	object:setBehaviour("IconImageRatio", "AspectRatio", stagger)
	object:setBehaviour("IconImage", "Image", function(value)
		local v4 = tonumber(value) and "http://www.roblox.com/asset/?id=" .. value or value or ""

		if imageLabel.Image ~= v4 then
			stagger()
		end

		return v4
	end)
	object.alignmentChanged:Connect(function(p2)
		local v4 = p2 == "Center" and "Left" or p2
		menuUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment[v4]
		updateBorderSize() -- equivalent call inferred; original call site unknown
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "IconImageScale"
	numberValue.Parent = imageLabel
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		imageLabel.Size = UDim2.new(numberValue.Value, 0, numberValue.Value, 0)
	end)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "IconImageRatio"
	uIAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint.Parent = imageLabel
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "IconGradient"
	uIGradient.Enabled = true
	uIGradient.Parent = frame2
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Name = "IconSpotGradient"
	uIGradient2.Enabled = true
	uIGradient2.Parent = frame3
	return frame
end