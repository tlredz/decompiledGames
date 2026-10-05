local createVector = vector.create
local GuiAnimations = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
game:GetService("StarterGui")

local function playRandomSound(instance)
	local children = instance:GetChildren()

	if #children == 0 then
		return
	end

	local v = children[math.random(1, #children)]
	v:Play()
	return v
end

local v = {
	Hover = {
		Time = 0.2,
		EasingDirection = Enum.EasingDirection.InOut,
		EasingStyle = Enum.EasingStyle.Quint
	},
	Click = {
		Time = 0.2,
		EasingDirection = Enum.EasingDirection.InOut,
		EasingStyle = Enum.EasingStyle.Quint
	},
	Fade = {
		Time = 0.3,
		EasingDirection = Enum.EasingDirection.Out,
		EasingStyle = Enum.EasingStyle.Quad
	}
}

function GuiAnimations.SetupButtonAnimations(instance, p)
	if typeof(instance) ~= "Instance" then
		error("Expected 'button' to be a Roblox GUI object")
	end

	local v2 = typeof(p) == "table" and p or {}
	print("Button:", instance, "Options:", v2)
	local hoverScale = v2.hoverScale or 1.25
	local clickScale = v2.clickScale or 0.8
	local _ = v2.selectable or false
	local onClick = v2.onClick
	local sounds = v2.sounds or {
		hover = SoundService.UI.Hover,
		click = SoundService.UI.Clicks
	}
	local size = instance.Size
	local uDim = UDim2.new(size.X.Scale * hoverScale, 0, size.Y.Scale * hoverScale, 0)
	local uDim2 = UDim2.new(size.X.Scale * clickScale, 0, size.Y.Scale * clickScale, 0)
	instance.MouseEnter:Connect(function()
		instance:TweenSize(uDim, v.Hover.EasingDirection, v.Hover.EasingStyle, v.Hover.Time, true)

		if sounds.hover then
			local children = sounds.hover:GetChildren()

			if #children == 0 then
				return
			else
				children[math.random(1, #children)]:Play()
			end
		end
	end)
	instance.MouseLeave:Connect(function()
		instance:TweenSize(size, v.Hover.EasingDirection, v.Hover.EasingStyle, v.Hover.Time, true)
	end)
	instance.MouseButton1Click:Connect(function()
		instance:TweenSize(uDim2, v.Click.EasingDirection, v.Click.EasingStyle, v.Click.Time, true)

		if onClick and typeof(onClick) == "function" then
			onClick(instance)
		end

		if sounds.click then
			local children = sounds.click:GetChildren()

			if #children == 0 then
				return
			else
				children[math.random(1, #children)]:Play()
			end
		end
	end)
end

local v2 = {
	Hover = {
		EasingDirection = Enum.EasingDirection.Out,
		EasingStyle = Enum.EasingStyle.Quad,
		Time = 0.2
	},
	Click = {
		EasingDirection = Enum.EasingDirection.Out,
		EasingStyle = Enum.EasingStyle.Quad,
		Time = 0.1
	}
}

function GuiAnimations.SetupButtonAnimationsSimple(instance)
	if not instance:GetAttribute("OriginalSize") then
		instance:SetAttribute("OriginalSize", instance.Size)
	end

	local originalSize = instance:GetAttribute("OriginalSize")
	local v3 = {
		hover = SoundService.UI.Hover,
		click = SoundService.UI.Clicks
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resetToOriginal()
		if instance and instance.Parent then
			instance:TweenSize(originalSize, v2.Hover.EasingDirection, v2.Hover.EasingStyle, v2.Hover.Time, true)
		end
	end

	instance.MouseEnter:Connect(function()
		if not (instance and instance.Parent) then
			return
		end

		instance:TweenSize(
			UDim2.new(
				originalSize.X.Scale * 1.1,
				originalSize.X.Offset,
				originalSize.Y.Scale * 1.1,
				originalSize.Y.Offset
			),
			v2.Hover.EasingDirection,
			v2.Hover.EasingStyle,
			v2.Hover.Time,
			true
		)

		if v3.hover then
			local children = v3.hover:GetChildren()

			if #children ~= 0 then
				children[math.random(1, #children)]:Play()
			end
		end

		task.delay(0.5, resetToOriginal)
	end)
	instance.MouseLeave:Connect(function()
		if instance and instance.Parent then
			resetToOriginal() -- equivalent call inferred; original call site unknown
		end
	end)
	instance.MouseButton1Down:Connect(function()
		if not (instance and instance.Parent) then
			return
		end

		instance:TweenSize(
			UDim2.new(
				originalSize.X.Scale * 0.95,
				originalSize.X.Offset,
				originalSize.Y.Scale * 0.95,
				originalSize.Y.Offset
			),
			v2.Click.EasingDirection,
			v2.Click.EasingStyle,
			v2.Click.Time,
			true
		)

		if v3.click then
			local children = v3.click:GetChildren()

			if #children ~= 0 then
				children[math.random(1, #children)]:Play()
			end
		end

		task.delay(0.5, resetToOriginal)
	end)
	instance.MouseButton1Up:Connect(function()
		if instance and instance.Parent then
			resetToOriginal() -- equivalent call inferred; original call site unknown
		end
	end)
	resetToOriginal() -- equivalent call inferred; original call site unknown
	return instance
end

function GuiAnimations.SetupScrollingButtonAnimations(object, options)
	local v3 = options or {}
	GuiAnimations.SetupButtonAnimations(object, {
		selectable = v3.selectable,
		hoverScale = v3.hoverScale,
		clickScale = v3.clickScale,
		onSelected = v3.onSelected,
		onClick = v3.onClick,
		sounds = v3.sounds
	})
	object.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			object:TweenSize(
				UDim2.new(0.8, 0, 0.8, 0),
				v2.Click.EasingDirection,
				v2.Click.EasingStyle,
				v2.Click.Time,
				true
			)

			if v3.selectable then
				GuiAnimations.SetSelected(object, true)
			end

			if v3.sounds and v3.sounds.click then
				local children = v3.sounds.click:GetChildren()

				if #children == 0 then
					return
				else
					children[math.random(1, #children)]:Play()
				end
			end
		end
	end)
end

function GuiAnimations.SetupScreenFuzzHoverEffects(p, p2, options)
	local hoverColor = (options or {}).hoverColor or Color3.new(0, 0.184314, 1)
	local imageColor3 = p2.ImageColor3
	p.MouseEnter:Connect(function()
		p2.ImageColor3 = hoverColor
	end)
	p.MouseLeave:Connect(function()
		p2.ImageColor3 = imageColor3
	end)
end

function GuiAnimations:SetSelected(p2)
	if p2 then
		self.ImageColor3 = Color3.new(1, 0, 0.0156863)
	else
		self.ImageColor3 = Color3.new(1, 1, 1)
	end
end

function GuiAnimations:SetupViewportFrame(instance, options)
	local v3 = options or {}
	local soundOverride = v3.soundOverride or false
	local camera = v3.camera or {
		CFrame = CFrame.new(0, -0.2, 5),
		FieldOfView = 30
	}

	if soundOverride then
	end

	local children = SoundService.UI.TVClick:GetChildren()

	if #children ~= 0 then
		children[math.random(1, #children)]:Play()
	end

	if not self:FindFirstChild("Camera") then
		local camera2 = Instance.new("Camera")
		camera2.Parent = self
		self.CurrentCamera = camera2
		camera2.CFrame = camera.CFrame
		camera2.FieldOfView = camera.FieldOfView
	end

	repeat
		task.wait(0.1)
	until game:IsLoaded()

	local v4 = tostring(instance) == "Drone"
	local total = 0

	repeat
		task.wait(0.1)
		total += 0.1
	until instance:FindFirstChild("HumanoidRootPart") or total >= 1

	if total < 1 then
		instance.Archivable = true
		local clone = instance:Clone()

		if self:FindFirstChild("WorldModel") then
			local worldModel = self:FindFirstChild("WorldModel")

			for _, child in ipairs(worldModel:GetChildren()) do
				child:Destroy()
			end

			clone.Parent = worldModel
			local humanoidRootPart = clone:WaitForChild("HumanoidRootPart")
			humanoidRootPart.CFrame = CFrame.new(createVector(0, -0.5, -5), createVector(0, 0, 0))

			if not v4 and clone:FindFirstChild("Humanoid") then
				local track = clone.Humanoid:LoadAnimation(clone.Animations.IdleHUD)
				track.Looped = true
				track:Play()
			end
		else
			clone:Destroy()
		end
	end
end

function GuiAnimations.ClearViewportFrame(instance)
	if instance:FindFirstChild("WorldModel") then
		local worldModel = instance:FindFirstChild("WorldModel")

		for _, child in ipairs(worldModel:GetChildren()) do
			child:Destroy()
		end
	end
end

function GuiAnimations.SetLandscapeSensor()
	local localPlayer = game.Players.LocalPlayer

	if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
		localPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
	end
end

function GuiAnimations.SetupHoverTexts()
	if UserInputService.KeyboardEnabled then
		local tagged = CollectionService:GetTagged("HoverText")
		local mainFrame = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CommerceHub"):WaitForChild("MainFrame")
		local hoverFrame = ReplicatedStorage.UI:WaitForChild("HoverFrame")

		for _, v3 in ipairs(tagged) do
			local clone = hoverFrame:Clone()
			clone.Parent = mainFrame
			local hoverText = clone:WaitForChild("HoverText")
			hoverText.Text = v3.Value
			clone.Visible = false
			local inputChangedConnection = nil

			local function updateHoverGuiPosition(p)
				if p.UserInputType == Enum.UserInputType.MouseMovement then
					clone.Position = UDim2.new(0, p.Position.X - 275, 0, p.Position.Y)
				end
			end

			local v5 = clone
			local updateHoverGuiPosition2 = updateHoverGuiPosition

			local function showHoverGui()
				v5.Visible = true
				inputChangedConnection = UserInputService.InputChanged:Connect(updateHoverGuiPosition2)
			end

			local v6 = clone

			local function hideHoverGui()
				v6.Visible = false

				if inputChangedConnection then
					inputChangedConnection:Disconnect()
					inputChangedConnection = nil
				end
			end

			v3.Parent.MouseEnter:Connect(showHoverGui)
			v3.Parent.MouseLeave:Connect(hideHoverGui)
		end
	end
end

function GuiAnimations:FadeIn(value, options)
	local v3 = value or 0.5
	local v4 = options or {}
	local easingStyle = v4.easingStyle or Enum.EasingStyle.Quad
	local easingDirection = v4.easingDirection or Enum.EasingDirection.Out
	self.BackgroundTransparency = 1
	self:TweenProperty("BackgroundTransparency", 0, easingStyle, easingDirection, v3, true)

	if self:IsA("TextLabel") or self:IsA("TextButton") then
		self.TextTransparency = 1
		self:TweenProperty("TextTransparency", 0, easingStyle, easingDirection, v3, true)
	end
end

function GuiAnimations:FadeOut(value, options)
	local v3 = value or 0.5
	local v4 = options or {}
	local easingStyle = v4.easingStyle or Enum.EasingStyle.Quad
	local easingDirection = v4.easingDirection or Enum.EasingDirection.Out
	self.BackgroundTransparency = 0
	self:TweenProperty("BackgroundTransparency", 1, easingStyle, easingDirection, v3, true)

	if self:IsA("TextLabel") or self:IsA("TextButton") then
		self.TextTransparency = 0
		self:TweenProperty("TextTransparency", 1, easingStyle, easingDirection, v3, true)
	end
end

function GuiAnimations:SlideIn(p, p2, value, options)
	local v3 = p or Enum.NormalId.Left
	local v4 = p2 or UDim2.new(1, 0, 0, 0)
	local v6 = options or {}
	local easingStyle = v6.easingStyle or Enum.EasingStyle.Quad
	local easingDirection = v6.easingDirection or Enum.EasingDirection.Out
	local position = self.Position

	if v3 == Enum.NormalId.Left then
		self.Position = position - UDim2.new(v4.X.Scale, v4.X.Offset, 0, 0)
	elseif v3 == Enum.NormalId.Right then
		self.Position = position + UDim2.new(v4.X.Scale, v4.X.Offset, 0, 0)
	elseif v3 == Enum.NormalId.Top then
		self.Position = position - UDim2.new(0, 0, v4.Y.Scale, v4.Y.Offset)
	elseif v3 == Enum.NormalId.Bottom then
		self.Position = position + UDim2.new(0, 0, v4.Y.Scale, v4.Y.Offset)
	end

	self:TweenPosition(position, easingDirection, easingStyle, value or 0.5, true)
end

function GuiAnimations.SlideOut(object, p, p2, value, options)
	local v3 = p or Enum.NormalId.Left
	local v4 = p2 or UDim2.new(1, 0, 0, 0)
	local v6 = options or {}
	local easingStyle = v6.easingStyle or Enum.EasingStyle.Quad
	local easingDirection = v6.easingDirection or Enum.EasingDirection.In
	local position = object.Position
	local v7 = nil

	if v3 == Enum.NormalId.Left then
		v7 = position - UDim2.new(v4.X.Scale, v4.X.Offset, 0, 0)
	elseif v3 == Enum.NormalId.Right then
		v7 = position + UDim2.new(v4.X.Scale, v4.X.Offset, 0, 0)
	elseif v3 == Enum.NormalId.Top then
		v7 = position - UDim2.new(0, 0, v4.Y.Scale, v4.Y.Offset)
	elseif v3 == Enum.NormalId.Bottom then
		v7 = position + UDim2.new(0, 0, v4.Y.Scale, v4.Y.Offset)
	end

	object:TweenPosition(v7, easingDirection, easingStyle, value or 0.5, true)
end

function GuiAnimations.ScaleUp(object, value, value2, options)
	local v3 = value or 1.25
	local v4 = options or {}
	local easingStyle = v4.easingStyle or Enum.EasingStyle.Quint
	local easingDirection = v4.easingDirection or Enum.EasingDirection.Out
	object:TweenSize(
		UDim2.new(object.Size.X.Scale * v3, object.Size.X.Offset, object.Size.Y.Scale * v3, object.Size.Y.Offset),
		easingDirection,
		easingStyle,
		value2 or 0.2,
		true
	)
end

function GuiAnimations.ScaleDown(object, value, value2, options)
	local v3 = value or 0.8
	local v4 = options or {}
	local easingStyle = v4.easingStyle or Enum.EasingStyle.Quint
	local easingDirection = v4.easingDirection or Enum.EasingDirection.Out
	object:TweenSize(
		UDim2.new(object.Size.X.Scale * v3, object.Size.X.Offset, object.Size.Y.Scale * v3, object.Size.Y.Offset),
		easingDirection,
		easingStyle,
		value2 or 0.2,
		true
	)
end

function GuiAnimations.Rotate(object, p, value, options)
	local v3 = options or {}
	object:TweenRotation(
		p,
		v3.easingStyle or Enum.EasingStyle.Linear,
		v3.easingDirection or Enum.EasingDirection.Out,
		value or 0.5,
		true
	)
end

function GuiAnimations.AppearFromOffscreen(p, p2, p3, p4, p5)
	GuiAnimations.SlideIn(p, p2, p3, p4, p5)
end

return GuiAnimations