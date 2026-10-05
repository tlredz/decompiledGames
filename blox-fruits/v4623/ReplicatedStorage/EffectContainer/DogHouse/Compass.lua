local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenIfSupported(p, tweenInfo, items)
	pcall(function()
		local v = {}

		for k, item in pairs(items) do
			local v2 = k

			if not pcall(function()
				p[v2] = p[v2]
			end) then
				continue
			end

			v[k] = item
		end

		if next(v) ~= nil then
			TweenService:Create(p, tweenInfo, v):Play()
		end
	end)
end

local function burstCompass(clone, _: number?, point: Vector2?, p, p2)
	local guiObject = p2 or clone:FindFirstChild("Frame") or clone

	if not guiObject:IsA("GuiObject") then
		return
	end

	local playerGui = game.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local maid2 = Maid.new()
	maid:GiveTask(maid2)
	local random = Random.new()
	local v = point or guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2
	local parent = p or Instance.new("ScreenGui")

	if not p then
		parent.Name = "DoghousePossessionScreen"
		parent.IgnoreGuiInset = true
		parent.DisplayOrder = 999999
		parent.ResetOnSpawn = false
		parent.Parent = playerGui
		task.delay(3.2, function()
			if parent.Parent then
				parent:Destroy()
			end
		end)
	end

	local currentCamera = workspace.CurrentCamera
	local fieldOfView

	if currentCamera then
		fieldOfView = currentCamera.FieldOfView or nil
	else
		fieldOfView = nil
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "DoghousePossessionColor"
	colorCorrectionEffect.Brightness = -0.12
	colorCorrectionEffect.Contrast = 1.15
	colorCorrectionEffect.Saturation = -0.75
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 45, 45)
	colorCorrectionEffect.Parent = Lighting
	maid2:GiveTask(colorCorrectionEffect)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "DoghousePossessionBlur"
	blurEffect.Size = 0
	blurEffect.Parent = Lighting
	maid2:GiveTask(blurEffect)
	tweenIfSupported(blurEffect, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = 18
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.12, function()
		tweenIfSupported(blurEffect, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0
		}) -- equivalent call inferred; original call site unknown
	end)
	task.delay(1.25, function()
		tweenIfSupported(colorCorrectionEffect, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}) -- equivalent call inferred; original call site unknown
	end)
	task.delay(2, function()
		if colorCorrectionEffect.Parent then
			colorCorrectionEffect:Destroy()
		end

		if blurEffect.Parent then
			blurEffect:Destroy()
		end
	end)
	local frame = Instance.new("Frame")
	frame.Name = "PossessionHolder"
	frame.Size = UDim2.fromScale(1, 1)
	frame.Position = UDim2.fromScale(0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 1000
	frame.ClipsDescendants = false
	frame.Parent = parent
	maid2:GiveTask(frame)
	local frame2 = Instance.new("Frame")
	frame2.Name = "DarkBloodFlash"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = Color3.fromRGB(5, 0, 0)
	frame2.BackgroundTransparency = 0.08
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 1001
	frame2.Parent = frame
	maid2:GiveTask(frame2)
	tweenIfSupported(frame2, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.68
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.55, function()
		tweenIfSupported(frame2, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown
	end)
	local frame3 = Instance.new("Frame")
	frame3.Name = "RedSplit"
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.Position = UDim2.fromOffset(-8, 0)
	frame3.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	frame3.BackgroundTransparency = 0.9
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 1002
	frame3.Parent = frame
	maid2:GiveTask(frame3)
	local frame4 = Instance.new("Frame")
	frame4.Name = "CyanSplit"
	frame4.Size = UDim2.fromScale(1, 1)
	frame4.Position = UDim2.fromOffset(8, 0)
	frame4.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
	frame4.BackgroundTransparency = 0.93
	frame4.BorderSizePixel = 0
	frame4.ZIndex = 1002
	frame4.Parent = frame
	maid2:GiveTask(frame4)
	task.delay(0.35, function()
		tweenIfSupported(frame3, TweenInfo.new(0.45), {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		tweenIfSupported(frame4, TweenInfo.new(0.45), {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown
	end)
	local v5 = {
		{ UDim2.fromScale(1, 0.18), UDim2.fromScale(0, 0) },
		{ UDim2.fromScale(1, 0.18), UDim2.fromScale(0, 0.82) }
	}

	for _, v6 in ipairs(v5) do
		local frame5 = Instance.new("Frame")
		frame5.Name = "BlackVignetteEdge"
		frame5.Size = v6[1]
		frame5.Position = v6[2]
		frame5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame5.BackgroundTransparency = 0.38
		frame5.BorderSizePixel = 0
		frame5.ZIndex = 1003
		frame5.Parent = frame
		maid2:GiveTask(frame5)
		task.delay(0.95, function()
			tweenIfSupported(frame5, TweenInfo.new(0.55), {
				BackgroundTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end)
	end

	local frame5 = Instance.new("Frame")
	frame5.Name = "TopPossessionBlink"
	frame5.Size = UDim2.fromScale(1, 0.55)
	frame5.Position = UDim2.fromScale(0, -0.55)
	frame5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame5.BorderSizePixel = 0
	frame5.ZIndex = 1100
	frame5.Parent = frame
	maid2:GiveTask(frame5)
	local frame6 = Instance.new("Frame")
	frame6.Name = "BottomPossessionBlink"
	frame6.Size = UDim2.fromScale(1, 0.55)
	frame6.Position = UDim2.fromScale(0, 1)
	frame6.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame6.BorderSizePixel = 0
	frame6.ZIndex = 1100
	frame6.Parent = frame
	maid2:GiveTask(frame6)
	local frame7 = Instance.new("Frame")
	frame7.Name = "RedEyeCut"
	frame7.AnchorPoint = Vector2.new(0.5, 0.5)
	frame7.Size = UDim2.fromScale(1, 0.018)
	frame7.Position = UDim2.fromScale(0.5, 0.5)
	frame7.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	frame7.BackgroundTransparency = 1
	frame7.BorderSizePixel = 0
	frame7.ZIndex = 1101
	frame7.Parent = frame
	maid2:GiveTask(frame7)
	tweenIfSupported(frame5, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, -0.08)
	}) -- equivalent call inferred; original call site unknown
	tweenIfSupported(frame6, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0.53)
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.06, function()
		tweenIfSupported(frame7, TweenInfo.new(0.04), {
			BackgroundTransparency = 0
		}) -- equivalent call inferred; original call site unknown
	end)
	task.delay(0.17, function()
		tweenIfSupported(frame7, TweenInfo.new(0.14), {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		tweenIfSupported(frame5, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(0, -0.55)
		}) -- equivalent call inferred; original call site unknown
		tweenIfSupported(frame6, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(0, 1)
		}) -- equivalent call inferred; original call site unknown
	end)
	task.delay(0.72, function()
		if not frame.Parent then
			return
		end

		frame5.Position = UDim2.fromScale(0, -0.55)
		frame6.Position = UDim2.fromScale(0, 1)
		tweenIfSupported(frame5, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
			Position = UDim2.fromScale(0, -0.28)
		}) -- equivalent call inferred; original call site unknown
		tweenIfSupported(frame6, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
			Position = UDim2.fromScale(0, 0.73)
		}) -- equivalent call inferred; original call site unknown
		task.delay(0.07, function()
			tweenIfSupported(frame5, TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0, -0.55)
			}) -- equivalent call inferred; original call site unknown
			tweenIfSupported(frame6, TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0, 1)
			}) -- equivalent call inferred; original call site unknown
		end)
	end)

	for i = 1, 36 do
		local v8 = i
		task.delay(random:NextNumber(0, 1.15), function()
			if not frame.Parent then
				return
			end

			local frame8 = Instance.new("Frame")
			frame8.Name = "ScreenTearStrip"
			frame8.Size = UDim2.new(1, random:NextInteger(80, 420), 0, random:NextInteger(3, 34))
			frame8.Position = UDim2.new(0, random:NextInteger(-220, 120), random:NextNumber(0, 1), 0)
			frame8.BackgroundTransparency = random:NextNumber(0.05, 0.38)
			frame8.BorderSizePixel = 0
			frame8.ZIndex = v8 + 1040
			local integer = random:NextInteger(1, 5)

			if integer == 1 then
				frame8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif integer == 2 then
				frame8.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			elseif integer == 3 then
				frame8.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
			elseif integer == 4 then
				frame8.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
			else
				frame8.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end

			frame8.Parent = frame
			maid2:GiveTask(frame8)
			tweenIfSupported(frame8, TweenInfo.new(random:NextNumber(0.045, 0.16), Enum.EasingStyle.Linear), {
				Position = frame8.Position + UDim2.fromOffset(random:NextInteger(-280, 280), random:NextInteger(-8, 8)),
				BackgroundTransparency = 1
			}) -- equivalent call inferred; original call site unknown
			task.delay(0.2, function()
				if frame8.Parent then
					frame8:Destroy()
				end
			end)
		end)
	end

	for i = 1, 55 do
		local frame8 = Instance.new("Frame")
		frame8.Name = "PossessionScanline"
		frame8.Size = UDim2.new(1, 0, 0, random:NextInteger(1, 2))
		frame8.Position = UDim2.new(0, 0, i / 55, 0)
		frame8.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame8.BackgroundTransparency = random:NextNumber(0.64, 0.86)
		frame8.BorderSizePixel = 0
		frame8.ZIndex = 1010
		frame8.Parent = frame
		maid2:GiveTask(frame8)
		task.delay(random:NextNumber(0.45, 1.25), function()
			tweenIfSupported(frame8, TweenInfo.new(0.35), {
				BackgroundTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end)
	end

	for _ = 1, 120 do
		task.delay(random:NextNumber(0, 1.35), function()
			if not frame.Parent then
				return
			end

			local frame8 = Instance.new("Frame")
			frame8.Name = "PossessionStaticChunk"
			frame8.Size = UDim2.fromOffset(random:NextInteger(3, 48), random:NextInteger(2, 22))
			frame8.Position = UDim2.fromScale(random:NextNumber(0, 1), random:NextNumber(0, 1))
			frame8.BackgroundTransparency = random:NextNumber(0.05, 0.55)
			frame8.BorderSizePixel = 0
			frame8.ZIndex = 1050 + random:NextInteger(1, 30)

			if random:NextNumber() < 0.5 then
				frame8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elseif random:NextNumber() < 0.75 then
				frame8.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			else
				frame8.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
			end

			frame8.Parent = frame
			maid2:GiveTask(frame8)
			tweenIfSupported(frame8, TweenInfo.new(random:NextNumber(0.04, 0.16), Enum.EasingStyle.Linear), {
				Position = frame8.Position + UDim2.fromOffset(random:NextInteger(-60, 60), random:NextInteger(-14, 14)),
				BackgroundTransparency = 1
			}) -- equivalent call inferred; original call site unknown
			task.delay(0.2, function()
				if frame8.Parent then
					frame8:Destroy()
				end
			end)
		end)
	end

	local v8 = {
		"RUN",
		"NO",
		"NO",
		"LOOK",
		"I HATE YOU ALL",
		"HE SEES YOU",
		"BAD DOG",
		"GET OUT"
	}

	for _ = 1, 12 do
		task.delay(random:NextNumber(0.05, 1.05), function()
			if not frame.Parent then
				return
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "PossessionText"
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Size = UDim2.fromOffset(random:NextInteger(180, 520), random:NextInteger(40, 110))
			textLabel.Position = UDim2.fromScale(random:NextNumber(0.18, 0.82), random:NextNumber(0.18, 0.82))
			textLabel.BackgroundTransparency = 1
			textLabel.Text = v8[random:NextInteger(1, #v8)]
			textLabel.Font = Enum.Font.GothamBlack
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.TextStrokeTransparency = 0
			textLabel.TextTransparency = random:NextNumber(0, 0.18)
			textLabel.Rotation = random:NextNumber(-8, 8)
			textLabel.ZIndex = 1120
			textLabel.Parent = frame
			maid2:GiveTask(textLabel)
			tweenIfSupported(textLabel, TweenInfo.new(random:NextNumber(0.05, 0.14), Enum.EasingStyle.Linear), {
				Position = textLabel.Position + UDim2.fromOffset(
					random:NextInteger(-28, 28),
					random:NextInteger(-12, 12)
				),
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}) -- equivalent call inferred; original call site unknown
			task.delay(0.18, function()
				if textLabel.Parent then
					textLabel:Destroy()
				end
			end)
		end)
	end

	for i = 1, 14 do
		local v9 = i
		task.delay(i * 0.035, function()
			if not frame.Parent then
				return
			end

			local frame8 = Instance.new("Frame")
			frame8.Name = "PossessedCompassPulse"
			frame8.AnchorPoint = Vector2.new(0.5, 0.5)
			frame8.Position = UDim2.fromOffset(v.X, v.Y)
			frame8.Size = UDim2.fromOffset(v9 * 8 + 20, v9 * 8 + 20)
			frame8.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
			frame8.BackgroundTransparency = 0.83
			frame8.BorderSizePixel = 0
			frame8.Rotation = random:NextNumber(-20, 20)
			frame8.ZIndex = 1075
			frame8.Parent = frame
			maid2:GiveTask(frame8)
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(1, 0)
			uICorner.Parent = frame8
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromRGB(255, 0, 0)
			uIStroke.Thickness = random:NextNumber(1.5, 4)
			uIStroke.Transparency = 0.05
			uIStroke.Parent = frame8
			tweenIfSupported(frame8, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(v9 * 24 + 320, v9 * 24 + 320),
				BackgroundTransparency = 1,
				Rotation = frame8.Rotation + random:NextNumber(-35, 35)
			}) -- equivalent call inferred; original call site unknown
			tweenIfSupported(uIStroke, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = 1
			}) -- equivalent call inferred; original call site unknown
			task.delay(0.46, function()
				if frame8.Parent then
					frame8:Destroy()
				end
			end)
		end)
	end

	for _ = 1, 18 do
		task.delay(random:NextNumber(0.08, 1), function()
			if not frame.Parent then
				return
			end

			local frame8 = Instance.new("Frame")
			frame8.Name = "RedSlash"
			frame8.AnchorPoint = Vector2.new(0.5, 0.5)
			frame8.Size = UDim2.fromOffset(random:NextInteger(70, 230), random:NextInteger(3, 9))
			frame8.Position = UDim2.fromOffset(v.X + random:NextInteger(-260, 260), v.Y + random:NextInteger(-190, 190))
			frame8.Rotation = random:NextNumber(-35, 35)
			frame8.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			frame8.BackgroundTransparency = random:NextNumber(0.05, 0.22)
			frame8.BorderSizePixel = 0
			frame8.ZIndex = 1110
			frame8.Parent = frame
			maid2:GiveTask(frame8)
			tweenIfSupported(frame8, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(random:NextInteger(230, 500), frame8.Size.Y.Offset),
				BackgroundTransparency = 1
			}) -- equivalent call inferred; original call site unknown
			task.delay(0.22, function()
				if frame8.Parent then
					frame8:Destroy()
				end
			end)
		end)
	end

	local position = guiObject.Position
	local rotation = guiObject.Rotation
	local size = guiObject.Size
	local v9 = guiObject:FindFirstChild("DoghousePossessionScale")

	if not v9 then
		v9 = Instance.new("UIScale")
		v9.Name = "DoghousePossessionScale"
		v9.Scale = 1
		v9.Parent = guiObject
	end

	maid2:GiveTask(v9)
	task.spawn(function()
		for i = 1, 30 do
			if not guiObject.Parent then
				break
			end

			local v10 = i < 14
			guiObject.Position = UDim2.new(
				position.X.Scale,
				position.X.Offset + random:NextInteger(v10 and -18 or -8, v10 and 18 or 8),
				position.Y.Scale,
				position.Y.Offset + random:NextInteger(v10 and -18 or -8, v10 and 18 or 8)
			)
			guiObject.Rotation = rotation + random:NextNumber(v10 and -22 or -9, v10 and 22 or 9)

			if v9:IsA("UIScale") then
				v9.Scale = random:NextNumber(v10 and 0.82 or 0.94, v10 and 1.24 or 1.08)
			end

			task.wait(random:NextNumber(0.012, 0.035))
		end

		if guiObject.Parent then
			guiObject.Position = position
			guiObject.Rotation = rotation
			guiObject.Size = size

			if v9 and v9.Parent then
				v9.Scale = 1
			end
		end
	end)

	if currentCamera and fieldOfView then
		currentCamera.FieldOfView = fieldOfView + 12
		task.delay(0.12, function()
			if currentCamera then
				currentCamera.FieldOfView = fieldOfView - 8
			end
		end)
		task.delay(0.25, function()
			if currentCamera then
				tweenIfSupported(currentCamera, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					FieldOfView = fieldOfView
				}) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local total = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		total += dt

		if total >= 1.75 then
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if guiObject.Parent then
				guiObject.Position = position
				guiObject.Rotation = rotation

				if v9 and v9.Parent then
					v9.Scale = 1
				end
			end

			if currentCamera and fieldOfView then
				currentCamera.FieldOfView = fieldOfView
			end
		else
			local v10 = math.max(1 - total / 1.75, 0.12)
			frame.Position = UDim2.fromOffset(random:NextInteger(-28, 28) * v10, random:NextInteger(-18, 18) * v10)
			frame3.Position = UDim2.fromOffset(random:NextInteger(-18, 2) * v10, random:NextInteger(-8, 8) * v10)
			frame4.Position = UDim2.fromOffset(random:NextInteger(-2, 18) * v10, random:NextInteger(-8, 8) * v10)

			if currentCamera then
				currentCamera.CFrame = currentCamera.CFrame * CFrame.new(
					random:NextNumber(-0.09, 0.09) * v10,
					random:NextNumber(-0.09, 0.09) * v10,
					0
				) * CFrame.Angles(0, 0, (math.rad(random:NextNumber(-0.95, 0.95) * v10)))
			end
		end
	end)
	maid2:GiveTask(renderSteppedConnection)
	task.delay(1.82, function()
		if frame.Parent then
			tweenIfSupported(frame2, TweenInfo.new(0.18), {
				BackgroundTransparency = 1
			}) -- equivalent call inferred; original call site unknown
			frame:Destroy()
		end
	end)
	task.delay(2.3, function()
		maid2:DoCleaning()
	end)
end

return function(p)
	if p.Stage == "Start" then
		maid:DoCleaning()
		local main = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
		local clone = game.ReplicatedStorage.GuideModule.DogHouseCompass:Clone()
		clone.Parent = main
		local compass = main:WaitForChild("Compass")
		maid:GiveTask(clone)
		maid:GiveTask(compass:GetPropertyChangedSignal("Visible"):Connect(function()
			if compass.Visible then
				compass.Visible = false
			end
		end))
		compass.Visible = false
		maid:GiveTask(function()
			task.delay(1, function()
				compass.Visible = true
			end)
		end)
		maid:GiveTask(task.spawn(function()
			while task.wait() do
				local character = game.Players.LocalPlayer.Character
				local position = character and character:GetPivot().Position

				if not position then
					continue
				end

				local map = workspace:FindFirstChild("Map")
				local doghouseDimension = map and map:FindFirstChild("doghouseDimension")

				if not doghouseDimension then
					continue
				end

				local bossSpawns = doghouseDimension:FindFirstChild("BossSpawns")
				local part = bossSpawns and bossSpawns:FindFirstChild("Part", true)

				if not part then
					continue
				end

				if (position - part.Position).Magnitude > 2000 then
					clone.Visible = true
				else
					clone.Visible = false
				end
			end
		end))
		local flag = false
		maid:GiveTask(clone.Frame.Button.TextButton.Activated:Connect(function()
			if flag then
				return
			end

			burstCompass(clone)
			flag = true
			task.delay(10, function()
				flag = false
			end)
			assert(ReplicatedStorage.Remotes:FindFirstChild("DogHouseAdminAbuse")):FireServer("CompassClicked")
		end))
	elseif p.Stage == "End" then
		maid:DoCleaning()
	end
end