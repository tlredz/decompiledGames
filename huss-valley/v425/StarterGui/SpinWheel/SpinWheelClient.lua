local createVector = vector.create
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local playerGui = localPlayer:WaitForChild("PlayerGui")
local spinWheelEvent = game.ReplicatedStorage.ChickenOrHero:WaitForChild("SpinWheelEvent")
local proximityPrompt = workspace:WaitForChild("SpinTheWheel"):WaitForChild("SpinPad"):WaitForChild("PromptPad"):WaitForChild("ProximityPrompt")
local main = parent:WaitForChild("Main")
local spinner = main.Wheel.Spinner
local spin = main.Spin
local buy1 = main.Buy1
local buy10 = main.Buy10
local robuxSpin = main.RobuxSpin
local closeButton = main.CloseButton
local v = {
	credits = 0,
	nextFreeAt = 0,
	discountAvailable = true,
	purchasesAvailable = false
}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local message = nil
local v6 = false
local flag = false
local flag2 = false
local v7 = false
local count = 0
local now = 0
local v8 = math.floor(workspace:GetServerTimeNow() / 86400)
local sound = Instance.new("Sound")
sound.Name = "WheelTick"
sound.SoundId = "rbxassetid://10066931761"
sound.Volume = 0.35
sound.Parent = SoundService

-- equivalent calls inferred from this helper; original call sites unknown
local function playTick()
	local clone = sound:Clone()
	clone.Parent = SoundService
	clone:Play()
	Debris:AddItem(clone, 1)
end

local textLabel = Instance.new("TextLabel")
textLabel.Name = "WheelResult"
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.Position = UDim2.fromScale(0.5, 0.79)
textLabel.Size = UDim2.fromScale(0.74, 0.08)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 220, 126)
textLabel.TextStrokeColor3 = Color3.fromRGB(35, 17, 52)
textLabel.TextStrokeTransparency = 0.1
textLabel.Font = Enum.Font.GothamBlack
textLabel.TextScaled = true
textLabel.Text = ""
textLabel.Visible = false
textLabel.ZIndex = 50
textLabel.Parent = main

local function showMessage(text, value)
	if not text or text == "" then
		return
	end

	textLabel.Text = text
	textLabel.Visible = true
	textLabel.TextTransparency = 0
	textLabel.TextStrokeTransparency = 0.1
	textLabel.Rotation = -3
	TweenService:Create(textLabel, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0
	}):Play()
	task.delay(value or 3, function()
		if textLabel.Text ~= text then
			return
		end

		TweenService:Create(textLabel, TweenInfo.new(0.3), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		task.wait(0.32)

		if textLabel.Text == text then
			textLabel.Visible = false
		end
	end)
end

local v9 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function rewardSound(p, volume, value)
	local sound2 = Instance.new("Sound")
	sound2.SoundId = "rbxassetid://" .. p
	sound2.Volume = volume
	sound2.PlaybackSpeed = value or 1
	sound2.Parent = SoundService
	sound2:Play()
	Debris:AddItem(sound2, 5)
end

local function tween(p, duration, p2, p3)
	local tween2 = TweenService:Create(
		p,
		TweenInfo.new(duration, p3 or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		p2
	)
	tween2:Play()
	return tween2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notifyReward(text)
	if not text or text == "" then
		return
	end

	task.spawn(function()
		for i = 1, 5 do
			if pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
				Title = "SPIN WHEEL REWARD",
				Text = text,
				Duration = 6
			}) then
				break
			else
				task.wait(i * 0.3)
			end
		end
	end)
end

local function showSecretPencil(parent2, position, size, zIndex)
	local secretPencil = game.ReplicatedStorage.ChickenOrHero.Weapons.Models:FindFirstChild("SecretPencil")
	local blade = secretPencil and secretPencil:FindFirstChild("Blade")

	if not (blade and blade:IsA("BasePart")) then
		return
	end

	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "SecretPencilPreview"
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.Position = position
	viewportFrame.Size = size
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Ambient = Color3.fromRGB(210, 190, 130)
	viewportFrame.LightColor = Color3.fromRGB(255, 238, 188)
	viewportFrame.LightDirection = createVector(-0.4, -0.8, -1)
	viewportFrame.ZIndex = zIndex
	viewportFrame.Parent = parent2
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local clone = blade:Clone()

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("LuaSourceContainer")) then
			continue
		end

		descendant:Destroy()
	end

	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CFrame = CFrame.Angles(0.2617993877991494, 1.1344640137963142, -0.4363323129985824)
	clone.Parent = worldModel
	local size2 = clone.Size
	clone.CFrame += createVector(0, 0, 0) - clone.Position
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, math.max(size2.X, size2.Y, size2.Z) * 2.7), createVector(0, 0, 0))
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	return viewportFrame
end

spinner.Knife.Prize.PrizeImage.ImageTransparency = 1
showSecretPencil(
	spinner.Knife.Prize.PrizeImage,
	UDim2.fromScale(0.5, 0.5),
	UDim2.fromScale(1, 1),
	spinner.Knife.Prize.PrizeImage.ZIndex + 1
)

local function celebrate(p)
	if v9 then
		v9:Destroy()
	end

	local v10 = p.id == "Ability" or p.id == "Knife"
	local color = p.id == "Knife" and Color3.fromRGB(255, 211, 78) or p.id == "Ability" and Color3.fromRGB(
		190,
		136,
		255
	) or p.id == "2xGems" and Color3.fromRGB(97, 224, 255) or Color3.fromRGB(255, 199, 105)
	local sound2 = Instance.new("Sound")
	sound2.SoundId = "rbxassetid://82803453482376"
	sound2.Volume = 0.35
	sound2.PlaybackSpeed = v10 and 0.85 or 1.15 or 1
	sound2.Parent = SoundService
	sound2:Play()
	Debris:AddItem(sound2, 5)

	if v10 then
		local sound3 = Instance.new("Sound")
		sound3.SoundId = "rbxassetid://10128766965"
		sound3.Volume = 0.35
		sound3.PlaybackSpeed = 0.85
		sound3.Parent = SoundService
		sound3:Play()
		Debris:AddItem(sound3, 5)
		task.delay(0.18, function()
			rewardSound(p.id == "Knife" and "9117278724" or "10066947742", 0.35) -- equivalent call inferred; original call site unknown
		end)
	end

	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "WheelCelebration"
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.Size = UDim2.fromScale(1, 1)
	canvasGroup.ZIndex = 60
	canvasGroup.Parent = main
	v9 = canvasGroup
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = v10 and 0.55 or 0.72
	frame.BorderSizePixel = 0
	frame.ZIndex = 60
	frame.Parent = canvasGroup
	TweenService:Create(frame, TweenInfo.new(v10 and 0.8 or 0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	local uDim = UDim2.fromScale(0.5, 0.416)

	for i = 1, v10 and 3 or 2 do
		local frame2 = Instance.new("Frame")
		frame2.Name = "RewardRing"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = uDim
		frame2.Size = UDim2.fromScale(0.02, 0.02)
		frame2.BackgroundTransparency = 1
		frame2.ZIndex = 61
		frame2.Parent = canvasGroup
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame2
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = color
		uIStroke.Thickness = v10 and 4 or 2
		uIStroke.Transparency = 0.06
		uIStroke.Parent = frame2
		local v12 = i
		task.delay((i - 1) * 0.16, function()
			if not frame2.Parent then
				return
			end

			local v15 = {
				Size = UDim2.fromScale(v12 * 0.12 + 0.36, v12 * 0.17 + 0.6)
			}
			TweenService:Create(frame2, TweenInfo.new(0.72, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), v15):Play()
			TweenService:Create(uIStroke, TweenInfo.new(0.72, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end

	local v11 = v10 and 24 or 12

	for i = 1, v11 do
		local frame2 = Instance.new("Frame")
		frame2.Name = "RewardRay"
		frame2.AnchorPoint = Vector2.new(0.5, 1)
		frame2.Position = uDim
		frame2.Size = UDim2.fromScale(i % 2 == 0 and 0.006 or 0.003, 0.02)
		frame2.Rotation = i * 360 / v11
		frame2.BackgroundColor3 = color
		frame2.BackgroundTransparency = 0.35
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 61
		frame2.Parent = canvasGroup
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Transparency = NumberSequence.new(0, 1)
		uIGradient.Parent = frame2
		local v12 = {
			Size = UDim2.fromScale(i % 2 == 0 and 0.006 or 0.003, v10 and 0.32 or 0.2),
			BackgroundTransparency = 1
		}
		TweenService:Create(
			frame2,
			TweenInfo.new(v10 and 1.1 or 0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			v12
		):Play()
	end

	for i = 1, v10 and 42 or 22 do
		local frame2 = Instance.new("Frame")
		frame2.Name = "RewardConfetti"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = uDim
		frame2.Size = UDim2.fromScale(v10 and 0.009 or 0.006, v10 and 0.018 or 0.012)
		frame2.Rotation = math.random(0, 360)
		local backgroundColor

		if i % 3 == 0 then
			backgroundColor = Color3.new(1, 1, 1) or color
		else
			backgroundColor = color
		end

		frame2.BackgroundColor3 = backgroundColor
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 63
		frame2.Parent = canvasGroup
		local v13 = math.random() * 3.141592653589793 * 2
		local v14 = (0.12 + math.random() * 0.35) * (v10 and 1 or 0.75)
		local v15 = 0.8 + math.random() * 0.6
		local v16 = {
			Position = UDim2.fromScale(0.5 + math.cos(v13) * v14, 0.416 + math.sin(v13) * v14),
			Rotation = frame2.Rotation + math.random(-270, 270),
			BackgroundTransparency = 1
		}
		local cubic = Enum.EasingStyle.Cubic
		TweenService:Create(frame2, TweenInfo.new(v15, cubic or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), v16):Play()
	end

	if v10 then
		local canvasGroup2 = Instance.new("CanvasGroup")
		canvasGroup2.Name = "JackpotCard"
		canvasGroup2.AnchorPoint = Vector2.new(0.5, 0.5)
		canvasGroup2.Position = uDim
		canvasGroup2.Size = UDim2.fromOffset(
			math.min(420, main.AbsoluteSize.X * 0.48),
			(math.min(300, main.AbsoluteSize.Y * 0.48))
		)
		canvasGroup2.BackgroundColor3 = Color3.fromRGB(18, 22, 37)
		canvasGroup2.BackgroundTransparency = 0.06
		canvasGroup2.GroupTransparency = 1
		canvasGroup2.ZIndex = 70
		canvasGroup2.Parent = canvasGroup
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 20)
		uICorner.Parent = canvasGroup2
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = color
		uIStroke.Thickness = 3
		uIStroke.Parent = canvasGroup2
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 0.55
		uIScale.Parent = canvasGroup2
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "PrizeArt"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.46)
		imageLabel.Size = UDim2.fromScale(0.48, 0.56)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Image = p.id == "Knife" and "" or spinner.Ability.Prize.PrizeImage.Image
		imageLabel.ZIndex = 71
		imageLabel.Parent = canvasGroup2

		if p.id == "Knife" then
			showSecretPencil(canvasGroup2, imageLabel.Position, imageLabel.Size, imageLabel.ZIndex + 1)
		end

		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "PrizeTitle"
		textLabel2.Position = UDim2.fromScale(0.06, 0.74)
		textLabel2.Size = UDim2.fromScale(0.88, 0.17)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = p.id == "Knife" and "SECRET PENCIL" or "ROCKET SHOES"
		textLabel2.TextColor3 = color
		textLabel2.TextStrokeTransparency = 0.35
		textLabel2.Font = Enum.Font.GothamBlack
		textLabel2.TextScaled = true
		textLabel2.ZIndex = 71
		textLabel2.Parent = canvasGroup2
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.Name = "JackpotTitle"
		textLabel3.Position = UDim2.fromScale(0.06, 0.05)
		textLabel3.Size = UDim2.fromScale(0.88, 0.14)
		textLabel3.BackgroundTransparency = 1
		textLabel3.Text = p.id == "Knife" and "✦ LEGENDARY KNIFE ✦" or "✦ ABILITY UNLOCK ✦"
		textLabel3.TextColor3 = Color3.new(1, 1, 1)
		textLabel3.Font = Enum.Font.GothamBold
		textLabel3.TextScaled = true
		textLabel3.ZIndex = 71
		textLabel3.Parent = canvasGroup2
		local back = Enum.EasingStyle.Back
		TweenService:Create(
			canvasGroup2,
			TweenInfo.new(0.45, back or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				GroupTransparency = 0
			}
		):Play()
		local back2 = Enum.EasingStyle.Back
		TweenService:Create(uIScale, TweenInfo.new(0.6, back2 or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end

	task.delay(v10 and 3 or 1.7, function()
		if canvasGroup.Parent then
			TweenService:Create(canvasGroup, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				GroupTransparency = 1
			}):Play()
			Debris:AddItem(canvasGroup, 0.5)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function durationText(p)
	local v10 = math.max(0, (math.ceil(p)))
	return string.format("%dm %02ds", math.floor(v10 / 60), v10 % 60)
end

local function updateLabels()
	spin.SpinAmount.Text = string.format("Spin! (%d)", v.credits or 0)
	local v10 = (v.nextFreeAt or 0) - workspace:GetServerTimeNow()
	local nextFreeSpin = spin.NextFreeSpin
	local text

	if v10 > 0 then
		text = durationText(v10) or "Free spin ready!"
	else
		text = "Free spin ready!"
	end

	nextFreeSpin.Text = text
	buy1.Price.Text = "Buy 1 Spin " .. "" .. " " .. (v2[3716057178] or "...")
	buy10.Price.Text = "Buy 10 Spins " .. "" .. " " .. (v2[3716072886] or "...")
	robuxSpin.Price.Text = "" .. " " .. (v2[v.discountAvailable and 3716057142 or 3716057178] or "...")
	robuxSpin.FlavorText.Visible = v.discountAvailable
	robuxSpin.Discount.Visible = v.discountAvailable
	robuxSpin.Price.Position = v.discountAvailable and UDim2.fromScale(0.311, 0.5) or UDim2.fromScale(0.5, 0.5)

	if v.discountAvailable then
		robuxSpin.Discount.Text = "" .. " " .. (v2[3716057178] or "...")
	end

	spin.AutoButtonColor = (v.credits or 0) > 0 and not (v6 or flag2)
	buy1.AutoButtonColor = not v6 and not v7 and v.purchasesAvailable
	buy10.AutoButtonColor = not v6 and not v7 and v.purchasesAvailable
	robuxSpin.AutoButtonColor = not v6 and not v7 and v.purchasesAvailable
end

local function hideGui(screenGui)
	if screenGui:IsA("ScreenGui") and screenGui ~= parent and screenGui.Name ~= "TouchGui" then
		if v3[screenGui] == nil then
			v3[screenGui] = screenGui.Enabled
		end

		if not v4[screenGui] then
			v4[screenGui] = screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
				if flag and screenGui.Enabled then
					v3[screenGui] = true
					screenGui.Enabled = false
				end
			end)
		end

		screenGui.Enabled = false
	end
end

local function openWheel()
	if flag or localPlayer:GetAttribute("InMatch") == true then
		return
	end

	flag = true

	for _, child in playerGui:GetChildren() do
		hideGui(child)
	end

	parent.Enabled = true

	if os.clock() - now > 0.4 then
		now = os.clock()
		spinWheelEvent:FireServer("State")
	end

	spinner.Rotation = -30
	updateLabels()
end

local function closeWheel()
	if not flag then
		return
	end

	if v5 then
		v5:Cancel()
		v5 = nil
		v6 = false
	end

	if message then
		local v10 = message

		if v10 and v10 ~= "" then
			notifyReward(true) -- equivalent call inferred; original call site unknown
		end

		message = nil
	end

	flag = false
	parent.Enabled = false

	if v9 then
		v9:Destroy()
		v9 = nil
	end

	for k, connection in v4 do
		connection:Disconnect()
		v4[k] = nil
	end

	for k, enabled in v3 do
		if k.Parent == playerGui then
			k.Enabled = enabled
		end

		v3[k] = nil
	end

	textLabel.Visible = false
end

local function animate(p)
	if type(p) ~= "table" or type(p.angle) ~= "number" then
		return
	end

	if localPlayer:GetAttribute("InMatch") == true then
		local v10 = message or p.message
		message = nil
		closeWheel()

		if v10 then
			if v10 == "" then
				return
			else
				notifyReward(true) -- equivalent call inferred; original call site unknown
			end
		end
	else
		if v5 then
			v5:Cancel()
		end

		if not flag then
			openWheel()
		end

		v6 = true
		textLabel.Visible = false
		updateLabels()
		local rotation = spinner.Rotation
		local rotation2 = p.angle + math.ceil((rotation + 2160 - p.angle) / 360) * 360
		local v11 = math.floor((rotation + 30) / 60)
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v12 = math.floor((spinner.Rotation + 30) / 60)

			if v11 < v12 then
				for _ = v11 + 1, v12 do
					playTick() -- equivalent call inferred; original call site unknown
				end

				v11 = v12
			end
		end)
		local tween2 = TweenService:Create(
			spinner,
			TweenInfo.new(5.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Rotation = rotation2
			}
		)
		v5 = tween2
		tween2:Play()
		tween2.Completed:Wait()
		renderSteppedConnection:Disconnect()

		if v5 ~= tween2 then
			return
		end

		v5 = nil
		spinner.Rotation = p.angle
		v6 = false
		updateLabels()
		celebrate(p)
		showMessage(p.message or "YOU WON!", 4)
		local v12 = message or p.message

		if v12 and v12 ~= "" then
			notifyReward(true) -- equivalent call inferred; original call site unknown
		end

		message = nil
		local size = spinner.Size
		TweenService:Create(spinner, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(size.X.Scale * 1.04, size.X.Offset, size.Y.Scale * 1.04, size.Y.Offset)
		}):Play()
		task.delay(0.17, function()
			TweenService:Create(spinner, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
		end)
	end
end

localPlayer:GetAttributeChangedSignal("InMatch"):Connect(function()
	if localPlayer:GetAttribute("InMatch") == true then
		closeWheel()
	end
end)
script.Destroying:Connect(closeWheel)
proximityPrompt.Triggered:Connect(openWheel)
playerGui.ChildAdded:Connect(function(child)
	if flag then
		hideGui(child)
	end
end)
closeButton.Activated:Connect(closeWheel)
spin.Activated:Connect(function()
	if v6 or flag2 or (v.credits or 0) < 1 then
		return
	end

	flag2 = true
	updateLabels()
	spinWheelEvent:FireServer("Spin")
	task.delay(10, function()
		if flag2 then
			flag2 = false
			updateLabels()
		end
	end)
end)
buy1.Activated:Connect(function()
	if v6 or v7 or not v.purchasesAvailable then
		return
	end

	v7 = true
	count += 1
	local v10 = count
	spinWheelEvent:FireServer("PurchaseIntent", 3716057178, "Add")
	task.delay(30, function()
		if count == v10 then
			v7 = false
			updateLabels()
		end
	end)
end)
buy10.Activated:Connect(function()
	if v6 or v7 or not v.purchasesAvailable then
		return
	end

	v7 = true
	count += 1
	local v10 = count
	spinWheelEvent:FireServer("PurchaseIntent", 3716072886, "Add")
	task.delay(30, function()
		if count == v10 then
			v7 = false
			updateLabels()
		end
	end)
end)
robuxSpin.Activated:Connect(function()
	if v6 or v7 or not v.purchasesAvailable then
		return
	end

	v7 = true
	count += 1
	local v10 = count
	spinWheelEvent:FireServer("PurchaseIntent", v.discountAvailable and 3716057142 or 3716057178, "Auto")
	task.delay(30, function()
		if count == v10 then
			v7 = false
			updateLabels()
		end
	end)
end)
spinWheelEvent.OnClientEvent:Connect(function(p, data)
	if p == "PromptProduct" then
		if not pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, localPlayer, data) then
			v7 = false
			showMessage("Purchase window unavailable.", 3)
		end
	elseif p == "State" and type(data) == "table" then
		if data.result or data.message then
			flag2 = false
		end

		if data.message then
			v7 = false
		end

		v.credits = data.credits or 0
		v.nextFreeAt = data.nextFreeAt or 0
		v.discountAvailable = data.discountAvailable == true
		v.purchasesAvailable = data.purchasesAvailable == true
		updateLabels()

		if data.result then
			message = data.result.message
			task.spawn(animate, data.result)
		elseif data.message then
			showMessage(data.message, 3)
		end
	end
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer.UserId and (p2 == 3716057178 or p2 == 3716057142 or p2 == 3716072886) then
		v7 = false
		updateLabels()
	end
end)

for _, v10 in { 3716057178, 3716057142, 3716072886 } do
	local v11 = v10
	task.spawn(function()
		for i = 1, 5 do
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				v11,
				Enum.InfoType.Product
			)

			if success and type(productInfoAsync) == "table" and type(productInfoAsync.PriceInRobux) == "number" then
				v2[v11] = tostring(productInfoAsync.PriceInRobux)
				break
			elseif i < 5 then
				task.wait(i * 2)
			end
		end

		v2[v11] = v2[v11] or "?"
		updateLabels()
	end)
end

task.spawn(function()
	while parent.Parent do
		task.wait(0.25)

		if not flag then
			continue
		end

		updateLabels()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v10 = math.floor(serverTimeNow / 86400)

		if not (v10 ~= v8 or (v.nextFreeAt or 1e999) <= serverTimeNow) then
			continue
		end

		v8 = v10

		if not (os.clock() - now >= 1) then
			continue
		end

		now = os.clock()
		spinWheelEvent:FireServer("State")
	end
end)
parent.Enabled = false
spinner.Rotation = -30