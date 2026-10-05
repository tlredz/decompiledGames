local TweenHelpers = {}
TweenHelpers.__index = TweenHelpers
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

if RunService:IsClient() then
	TweenHelpers.mouseOver = require(script.Parent.MouseOver)
end

TweenHelpers.initialPrefix = "start_"
TweenHelpers.TextScaler = require(script.TextScaler)

function TweenHelpers.hasProperty(p, p2)
	return (pcall(function()
		return p[p2]
	end))
end

function TweenHelpers.playTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)

	if p2.RepeatCount ~= -1 then
		local completedConnection = nil
		completedConnection = tween.Completed:Connect(function()
			if completedConnection then
				completedConnection:Disconnect()
				completedConnection = nil
			end

			tween:Destroy()
		end)
	end

	tween:Play()
	return tween
end

function TweenHelpers.getInitial(instance, p)
	if TweenHelpers.hasProperty(instance, p) then
		return instance:GetAttribute(TweenHelpers.initialPrefix .. p)
	end
end

function TweenHelpers.saveInitials(folder, p)
	local v = p or {
		"Position",
		"Size",
		"Rotation",
		"BackgroundTransparency",
		"BackgroundColor3",
		"TextColor3",
		"TextTransparency",
		"ZIndex",
		"ImageTransparency",
		"Transparency"
	}

	if folder:GetAttribute("InitialPropertiesSaved") then
		return
	end

	if folder:IsA("GuiObject") or folder:IsA("UIStroke") then
		for _, v2 in pairs(v) do
			if TweenHelpers.hasProperty(folder, v2) then
				folder:SetAttribute(TweenHelpers.initialPrefix .. v2, folder[v2])
			end
		end
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("GuiObject") or descendant:IsA("UIStroke")) then
			continue
		end

		for _, v2 in pairs(v) do
			if TweenHelpers.hasProperty(descendant, v2) then
				descendant:SetAttribute(TweenHelpers.initialPrefix .. v2, descendant[v2])
			end
		end
	end

	folder:SetAttribute("InitialPropertiesSaved", true)
end

function TweenHelpers.scanGui(folder)
	local guiObjectsByName = {}

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if not guiObject:IsA("GuiObject") or guiObject.Name == "" or guiObject:IsA("TextButton") then
			continue
		end

		guiObjectsByName[guiObject.Name] = guiObject
	end

	return guiObjectsByName
end

function TweenHelpers:fadeIn(p)
	local v = {
		"ImageTransparency",
		"BackgroundTransparency",
		"TextTransparency",
		"Transparency"
	}

	for _, descendant in pairs(self:GetDescendants()) do
		if not (descendant:IsA("GuiObject") or descendant:IsA("UIStroke")) then
			continue
		end

		for _, v2 in pairs(v) do
			if not (descendant:GetAttribute("ignoreList") == nil or not string.find(
				descendant:GetAttribute("ignoreList"),
				v2
			)) then
				continue
			end

			if not TweenHelpers.hasProperty(descendant, v2) then
				continue
			end

			descendant[v2] = 1
			TweenHelpers.playTween(descendant, p, {
				[v2] = descendant:GetAttribute(TweenHelpers.initialPrefix .. v2)
			})
		end
	end

	self.Visible = true
end

function TweenHelpers.fadeOut(folder, p)
	local v = {
		"ImageTransparency",
		"BackgroundTransparency",
		"TextTransparency",
		"Transparency"
	}

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("UIStroke") then
			TweenHelpers.playTween(descendant, p, {
				Transparency = 1
			})
		end

		if not (descendant:IsA("GuiObject") or descendant:IsA("UIStroke")) then
			continue
		end

		for _, v2 in pairs(v) do
			if not TweenHelpers.hasProperty(descendant, v2) then
				continue
			end

			descendant[v2] = descendant:GetAttribute(TweenHelpers.initialPrefix .. v2)
			TweenHelpers.playTween(descendant, p, {
				[v2] = 1
			})
		end
	end
end

function TweenHelpers.getPositionInParent(data, p)
	local absolutePosition = data.AbsolutePosition
	local absoluteSize = data.AbsoluteSize
	local anchorPoint = data.AnchorPoint
	local absolutePosition2 = p.AbsolutePosition
	local absoluteSize2 = p.AbsoluteSize
	local v = absolutePosition.X + absoluteSize.X * anchorPoint.X
	local v2 = absolutePosition.Y + absoluteSize.Y * anchorPoint.Y
	local v3 = v - absolutePosition2.X
	local v4 = v2 - absolutePosition2.Y
	return UDim2.fromScale(v3 / absoluteSize2.X, v4 / absoluteSize2.Y)
end

function TweenHelpers.getSizeInParent(p, p2)
	local absoluteSize = p.AbsoluteSize
	local absoluteSize2 = p2.AbsoluteSize
	return UDim2.fromScale(absoluteSize.X / absoluteSize2.X, absoluteSize.Y / absoluteSize2.Y)
end

function TweenHelpers.customScrollbar(instance, folder, p)
	local thumb = instance:WaitForChild("Thumb")
	local uIDragDetector = thumb.UIDragDetector
	local uIScale = thumb:FindFirstChild("UIScale", true)
	local v = 1 - thumb.Size.Y.Scale
	folder.Changed:Connect(function()
		local v2 = folder.AbsoluteCanvasSize.Y > folder.AbsoluteWindowSize.Y

		if thumb.ScaleType == Enum.ScaleType.Slice then
			thumb.Size = UDim2.fromScale(thumb.Size.X.Scale, folder.AbsoluteWindowSize.Y / folder.AbsoluteCanvasSize.Y)
		end

		v = 1 - thumb.Size.Y.Scale
		thumb.Position = UDim2.new(
			thumb.Position.X.Scale,
			0,
			folder.CanvasPosition.Y / (folder.AbsoluteCanvasSize.Y - folder.AbsoluteWindowSize.Y) * v,
			0
		)
		thumb.Visible = v2
		thumb.Selectable = v2
		uIDragDetector.Enabled = v2

		if p then
			local v3 = folder.AbsoluteSize.X / p

			for _, label in ipairs(folder:GetDescendants()) do
				if not label:IsA("TextLabel") then
					continue
				end

				if not label:GetAttribute("OriginalFontSize") then
					label:SetAttribute("OriginalFontSize", label.TextSize)
				end

				label.TextSize = math.round(label:GetAttribute("OriginalFontSize") * v3)
			end
		end
	end)
	uIDragDetector.DragContinue:Connect(function()
		v = 1 - thumb.Size.Y.Scale
		local v2 = thumb.Position.Y.Scale / v
		local v3 = folder.AbsoluteCanvasSize.Y - folder.AbsoluteWindowSize.Y
		folder.CanvasPosition = Vector2.new(0, v3 * v2)
	end)
	uIDragDetector.DragStart:Connect(function()
		if uIScale then
			TweenHelpers.playTween(uIScale, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
				Scale = 1.15
			})
		end
	end)
	uIDragDetector.DragEnd:Connect(function()
		if uIScale then
			TweenHelpers.playTween(uIScale, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
				Scale = 1
			})
		end
	end)
end

return TweenHelpers