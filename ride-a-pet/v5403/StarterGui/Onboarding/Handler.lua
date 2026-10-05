local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GameSettings = require(ReplicatedStorage2:WaitForChild("GameSettings"))
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local instruction = parent:WaitForChild("Header"):WaitForChild("Instruction")
local GamepadGlyphs = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadGlyphs"))
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local savedData = localPlayer:WaitForChild("SavedData")
local hasFinishedTutorial = savedData:WaitForChild("HasFinishedTutorial")
local cash = savedData:WaitForChild("Cash")
local hatchUpgrades = savedData:WaitForChild("HatchUpgrades")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local game2 = remotes:WaitForChild("Game")
game2:WaitForChild("PlacePet", 10)
local tutorial = remotes:WaitForChild("Tutorial", 30)
local step = tutorial and tutorial:WaitForChild("Step", 10)
local starterEgg = tutorial and tutorial:WaitForChild("StarterEgg", 10)

if not (step and starterEgg) then
	warn("[Onboarding] Remotes.Tutorial never appeared - is ServerScriptService.Remotes.Game.Tutorial running?")
	return
end

local main = playerGui:WaitForChild("Main", 60)

if not main then
	warn("[Onboarding] PlayerGui.Main never arrived - tutorial cannot run")
	return
end

local actionsHolder = main:WaitForChild("ActionsHolder")
local ride = actionsHolder:WaitForChild("Ride")
local useRadar = actionsHolder:WaitForChild("UseRadar")
main:WaitForChild("GearShop")
local shop = main:WaitForChild("Shop")
local gears = shop:WaitForChild("Holders"):WaitForChild("Gears")
local v = { main:WaitForChild("ShopToggle"), main:WaitForChild("RebirthToggle"), main:WaitForChild("IndexToggle") }
local plots = workspace:WaitForChild("Plots")
workspace:WaitForChild("Stalls")
local basket = localPlayer:WaitForChild("Basket", 30)

if not basket then
	warn("[Onboarding] Player.Basket never appeared - is EggSpawning running?")
	return
end

local beam = workspace:WaitForChild("TutorialBeam"):WaitForChild("Beam")
local flag = false
local fn = nil
local v2 = {}
parent.Enabled = false

-- equivalent calls inferred from this helper; original call sites unknown
local function AddCleanup(p)
	table.insert(v2, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RunCleanup()
	for _, callback in v2 do
		pcall(callback)
	end

	table.clear(v2)
	fn = nil
end

task.spawn(function()
	while not flag do
		local v3 = fn

		if v3 then
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local success, result = pcall(v3)

			if success and result and humanoid and humanoid.Health > 0 and result.Parent ~= character then
				local v4 = humanoid
				local v5 = result
				pcall(function()
					v4:EquipTool(v5)
				end)
			end
		end

		task.wait(0.3)
	end
end)
local v3 = nil

local function StartFloating()
	local parent2 = instruction.Parent

	if not (parent2 and parent2:IsA("GuiObject")) then
		parent2 = instruction
	end

	local position = parent2.Position
	v3 = TweenService:Create(
		parent2,
		TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
		{
			Position = position - UDim2.fromScale(0, 0.015)
		}
	)
	v3:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetInstruction(text: string)
	instruction.Text = text
	instruction.TextTransparency = 0
	local uIStroke = instruction:FindFirstChildOfClass("UIStroke")

	if uIStroke then
		uIStroke.Transparency = 0
	end

	instruction.Visible = text ~= ""
	local parent2 = instruction.Parent

	if parent2 and parent2:IsA("GuiObject") then
		parent2.Visible = text ~= ""
	end
end

local v4 = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OnboardingSpotlight"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ClipToDeviceSafeArea = false
screenGui.DisplayOrder = 145
screenGui.Enabled = false
screenGui.Parent = playerGui
local parent2 = script.Parent

if parent2:IsA("ScreenGui") then
	parent2.DisplayOrder = screenGui.DisplayOrder + 1
end

local function MakePanel()
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.4
	frame.ZIndex = 1
	frame.Parent = screenGui
	return frame
end

local frame = Instance.new("Frame")
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.ZIndex = 1
frame.Parent = screenGui
local frame2 = Instance.new("Frame")
frame2.BorderSizePixel = 0
frame2.BackgroundColor3 = Color3.new(0, 0, 0)
frame2.BackgroundTransparency = 0.4
frame2.ZIndex = 1
frame2.Parent = screenGui
local frame3 = Instance.new("Frame")
frame3.BorderSizePixel = 0
frame3.BackgroundColor3 = Color3.new(0, 0, 0)
frame3.BackgroundTransparency = 0.4
frame3.ZIndex = 1
frame3.Parent = screenGui
local frame4 = Instance.new("Frame")
frame4.BorderSizePixel = 0
frame4.BackgroundColor3 = Color3.new(0, 0, 0)
frame4.BackgroundTransparency = 0.4
frame4.ZIndex = 1
frame4.Parent = screenGui
local frame5 = Instance.new("Frame")
frame5.BackgroundTransparency = 1
frame5.BorderSizePixel = 0
frame5.AnchorPoint = Vector2.new(0.5, 0.5)
frame5.ZIndex = 2
frame5.Parent = screenGui
local uIStroke = Instance.new("UIStroke")
uIStroke.Color = Color3.fromRGB(255, 255, 255)
uIStroke.Thickness = 5
uIStroke.Parent = frame5
local uICorner = Instance.new("UICorner", frame5)
uICorner.CornerRadius = UDim.new(0, 4)
local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "PointingHand"
imageLabel.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
imageLabel.Rotation = 180
imageLabel.BackgroundTransparency = 1
imageLabel.Size = UDim2.fromOffset(56, 56)
imageLabel.AnchorPoint = Vector2.new(0.5, 1)
imageLabel.ZIndex = 3
imageLabel.Parent = screenGui
local v5 = nil
local activatedConnection = nil
local total = 0

local function OnScreen(parent3)
	while parent3 and not parent3:IsA("ScreenGui") do
		if parent3:IsA("GuiObject") and not parent3.Visible then
			return false
		else
			parent3 = parent3.Parent
		end
	end

	return parent3 ~= nil and parent3:IsA("ScreenGui") and parent3.Enabled
end

local v6 = 0
local v7 = 0
local v8 = 0
local v9 = 0
local v10 = false
local v11 = 0
local v12 = 0
local v13 = 0
local v14 = 0
local flag2 = false
local total2 = 0

local function TargetRect(p)
	local guiInset = GuiService:GetGuiInset()
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return
		math.max(math.floor(absolutePosition.X), 0),
		math.max(math.floor(absolutePosition.Y + guiInset.Y), 0),
		math.ceil(absolutePosition.X + absoluteSize.X),
		(math.ceil(absolutePosition.Y + guiInset.Y + absoluteSize.Y))
end

local function BeginShowTween()
	if not v10 then
		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
		local v15 = viewportSize.X / 2
		local v16 = viewportSize.Y / 2
		v6 = v15
		v7 = v16
		v8 = v15
		v9 = v16
		v10 = true
	end

	v11 = v6
	v12 = v7
	v13 = v8
	v14 = v9
	flag2 = true
	total2 = 0
end

RunService.RenderStepped:Connect(function(dt)
	if not v5 then
		return
	end

	if not v5.Parent or not OnScreen(v5) or v5.AbsoluteSize.X <= 0 then
		screenGui.Enabled = false
		return
	end

	screenGui.Enabled = true
	local v15, v16, v17, v18 = TargetRect(v5)

	if flag2 then
		total2 += dt
		local v19 = math.clamp(total2 / 0.5, 0, 1)
		local v20 = 1 - (1 - v19) * (1 - v19)
		v6 = v11 + (v15 - v11) * v20
		v7 = v12 + (v16 - v12) * v20
		v8 = v13 + (v17 - v13) * v20
		v9 = v14 + (v18 - v14) * v20

		if v19 >= 1 then
			flag2 = false
		end
	else
		v6 = v15
		v7 = v16
		v8 = v17
		v9 = v18
		v10 = true
	end

	local v19 = math.max(math.floor(v6), 0)
	local v20 = math.max(math.floor(v7), 0)
	local v21 = math.ceil(v8)
	local v22 = math.ceil(v9)
	local v23 = v22 - v20
	frame.Position = UDim2.fromOffset(-1000, -1000)
	frame.Size = UDim2.new(1, 2000, 0, v20 + 1000)
	frame2.Position = UDim2.fromOffset(-1000, v22)
	frame2.Size = UDim2.new(1, 2000, 1, 1000 - v22)
	frame3.Position = UDim2.fromOffset(-1000, v20)
	frame3.Size = UDim2.fromOffset(v19 + 1000, v23)
	frame4.Position = UDim2.fromOffset(v21, v20)
	frame4.Size = UDim2.new(1, 1000 - v21, 0, v23)
	frame5.Position = UDim2.fromOffset(math.floor(v19 + (v21 - v19) / 2), (math.floor(v20 + v23 / 2)))
	frame5.Size = UDim2.fromOffset(v21 - v19, v23)
	total += dt
	uIStroke.Transparency = (math.sin(total * 5) * 0.5 + 0.5) * 0.25 + 0.1
	local v24 = math.abs((math.sin(total * 6))) * 14
	imageLabel.Position = UDim2.fromOffset(math.floor(v19 + (v21 - v19) / 2), v20 - 4 - v24)
end)

function v4.Hide()
	v5 = nil
	screenGui.Enabled = false

	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end
end

function v4.Show(button)
	v4.Hide()
	v5 = button
	screenGui.Enabled = true
	BeginShowTween()

	if button:IsA("GuiButton") then
		activatedConnection = button.Activated:Connect(v4.Hide)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HighlightButton(p)
	v4.Show(p)
	AddCleanup(v4.Hide) -- equivalent call inferred; original call site unknown
end

local function BoothCenter(folder)
	for _, model in folder:GetChildren() do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			return model:GetPivot().Position + createVector(0, 4, 0)
		end
	end

	local v15 = nil
	local v16 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position

		if v15 then
			v15 = v15:Min(position) or position
		else
			v15 = position
		end

		if v16 then
			v16 = v16:Max(position) or position
		else
			v16 = position
		end
	end

	return v15 and (v15 + v16) / 2 or createVector(0, 0, 0)
end

local function ShowBeam(position: Vector3, callback)
	local part = Instance.new("Part")
	part.Name = "TutorialBeamAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position
	part.Parent = workspace
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local clone = beam:Clone()
	clone.Attachment0 = attachment
	clone.Enabled = true
	clone.Parent = part

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AttachToCharacter(character)
		local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart", 5)

		if not (humanoidRootPart and part.Parent) then
			return
		end

		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "TutorialBeamAttachment"
		attachment2.Parent = humanoidRootPart
		clone.Attachment1 = attachment2
	end

	AttachToCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
	local characterAddedConnection = localPlayer.CharacterAdded:Connect(AttachToCharacter)
	local heartbeatConnection

	if callback then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local position2 = callback()

			if position2 then
				part.Position = position2
			end
		end)
	else
		heartbeatConnection = nil
	end

	table.insert(v2, function()
		characterAddedConnection:Disconnect()

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		part:Destroy()
	end)
end

local function GetMyPlot()
	for _, child in plots:GetChildren() do
		local data = child:FindFirstChild("Data")
		local owner = data and data:FindFirstChild("Owner")

		if owner and owner.Value == localPlayer then
			return child
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RootPosition()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position or nil
end

local function FindTool(fn2)
	for _, v15 in { localPlayer.Character, localPlayer:FindFirstChild("Backpack") } do
		if not v15 then
			continue
		end

		for _, tool in v15:GetChildren() do
			if tool:IsA("Tool") and fn2(tool) then
				return tool
			end
		end
	end

	return nil
end

local function StallCenter(folder)
	local v15 = nil
	local v16 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position

		if v15 then
			v15 = v15:Min(position) or position
		else
			v15 = position
		end

		if v16 then
			v16 = v16:Max(position) or position
		else
			v16 = position
		end
	end

	return v15 and (v15 + v16) / 2 + createVector(0, 3, 0) or createVector(0, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlotPetCount()
	local myPlot = GetMyPlot()
	local pets = myPlot and myPlot:FindFirstChild("Pets")
	return pets and #pets:GetChildren() or 0
end

local function MyPlacedPet(p: string?)
	for _, model in CollectionService:GetTagged("Pet") do
		if model:IsA("Model") and model.Parent and model:GetAttribute("OwnerUserId") == localPlayer.UserId and model:IsDescendantOf(workspace) and (p == nil or model:GetAttribute("PetKey") == p) then
			return model
		end
	end

	if p then
		return nil
	end

	local myPlot = GetMyPlot()
	local pets = myPlot and myPlot:FindFirstChild("Pets")
	local model = pets and pets:GetChildren()[1]

	if not (model and model:IsA("Model") and model) then
		model = nil
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlacedPetPosition(p: string?)
	local myPlacedPet = MyPlacedPet(p)
	return myPlacedPet and myPlacedPet:GetPivot().Position + createVector(0, 4, 0) or nil
end

local function BuildTapBillboard(adornee, parent3, p: number)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "TutorialTapHint"
	billboardGui.Size = UDim2.fromScale(p, p)
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.ResetOnSpawn = false
	billboardGui.Adornee = adornee
	billboardGui.Parent = parent3
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "Hand"
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = "rbxassetid://92534278124110"
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel2.Size = UDim2.fromScale(1, 1)
	imageLabel2.Parent = billboardGui
	local tween = TweenService:Create(
		imageLabel2,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Size = UDim2.fromScale(0.75, 0.75)
		}
	)
	tween:Play()
	return billboardGui, tween
end

local function ShowTapHint(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		return
	end

	local boundingBox, v15 = instance:GetBoundingBox()
	local attachment = Instance.new("Attachment")
	attachment.Name = "TutorialTapHintPoint"
	attachment.CFrame = primaryPart.CFrame:ToObjectSpace(CFrame.new(boundingBox.Position))
	attachment.Parent = primaryPart
	local v17, v18 = BuildTapBillboard(attachment, primaryPart, math.clamp(math.max(v15.X, v15.Y, v15.Z) * 0.9, 3, 9))
	table.insert(v2, function()
		v18:Cancel()
		v17:Destroy()
		attachment:Destroy()
	end)
end

local function ShowTapHintAt(position: Vector3, value: number?, flag3: boolean?)
	local part = Instance.new("Part")
	part.Name = "TutorialTapHintAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position
	part.Parent = workspace
	local parent3, v16 = BuildTapBillboard(part, part, value or 6)
	local v17

	if flag3 then
		local hand = parent3:FindFirstChild("Hand")

		if hand then
			hand.Rotation = 180
		end

		v16:Cancel()
		parent3.StudsOffset = createVector(0, 4.5, 0)
		v17 = TweenService:Create(
			parent3,
			TweenInfo.new(0.84, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				StudsOffset = createVector(0, 2, 0)
			}
		)
		v17:Play()
	else
		v17 = nil
	end

	table.insert(v2, function()
		v16:Cancel()

		if v17 then
			v17:Cancel()
		end

		parent3:Destroy()
		part:Destroy()
	end)
end

local function ShowTapHintOnGui(dollar)
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "TutorialTapHint"
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = "rbxassetid://92534278124110"
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Position = UDim2.fromScale(0.5, 0.88)
	imageLabel2.SizeConstraint = Enum.SizeConstraint.RelativeYY
	imageLabel2.Size = UDim2.fromScale(0.93, 0.93)
	imageLabel2.ZIndex = dollar.ZIndex + 10
	imageLabel2.Parent = dollar
	local tween = TweenService:Create(
		imageLabel2,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Size = UDim2.fromScale(0.72, 0.72)
		}
	)
	tween:Play()

	local function Remove()
		tween:Cancel()
		imageLabel2:Destroy()
	end

	AddCleanup(Remove) -- equivalent call inferred; original call site unknown
	return Remove
end

local function SurfaceButtonPosition(surfaceGui, purchase)
	local adornee = surfaceGui.Adornee

	if not (adornee and adornee:IsA("BasePart")) then
		return nil
	end

	local absoluteSize = surfaceGui.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return adornee.Position
	end

	local v15 = purchase.AbsolutePosition + purchase.AbsoluteSize / 2 - surfaceGui.AbsolutePosition
	local v16 = v15.X / absoluteSize.X - 0.5
	local v17 = v15.Y / absoluteSize.Y - 0.5
	return adornee.CFrame:PointToWorldSpace((Vector3.new(
		-v16 * adornee.Size.X,
		-v17 * adornee.Size.Y,
		-(adornee.Size.Z / 2) - 1
	)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShopOpenOnGears()
	return shop.Visible and gears.Visible
end

local function WaitUntil(callback)
	while not (flag or callback()) do
		task.wait(0.25)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReportStep(p: number)
	step:FireServer(p)
end

local function WaitForPress(object, callback)
	local v15 = false
	local activatedConnection2 = object.Activated:Connect(function()
		v15 = true
	end)
	local pressedAtChangedConnection = object:GetAttributeChangedSignal("PressedAt"):Connect(function()
		v15 = true
	end)
	WaitUntil(function()
		local v16 = v15

		if not v16 then
			if callback == nil then
				return false
			else
				return (callback())
			end
		end

		return v16
	end)
	activatedConnection2:Disconnect()
	pressedAtChangedConnection:Disconnect()
end

local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function StopDistance()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	instruction.RichText = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TrackDistanceTo(fn2, p: string)
	StopDistance() -- equivalent call inferred; original call site unknown
	instruction.RichText = true
	local v15 = nil
	local v16 = "#5BE05B"
	local total3 = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if flag then
			return
		end

		local v17 = fn2()
		local rootPosition = RootPosition() -- equivalent call inferred; original call site unknown

		if not (v17 and rootPosition) then
			return
		end

		local magnitude = ((v17 - rootPosition) * createVector(1, 0, 1)).Magnitude
		total3 += dt

		if total3 >= 0.25 then
			if v15 then
				local v19 = magnitude - v15

				if math.abs(v19) >= 0.75 then
					v16 = v19 < 0 and "#5BE05B" or "#FF6B6B"
				end
			end

			v15 = magnitude
			total3 = 0
		end

		instruction.Text = string.format(
			"%s  <font color=\"%s\">%dm</font> Away",
			p,
			v16,
			(math.max(math.floor(magnitude + 0.5), 0))
		)
		instruction.Visible = true
	end)
	AddCleanup(StopDistance) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FlashBeam(position: Vector3, color: Color3?, p: number, p2: number, callback)
	task.spawn(function()
		if callback and not callback() then
			return
		end

		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local Debris = game:GetService("Debris")
		local part = Instance.new("Part")
		part.Name = "FlashBeamAnchor"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = position
		part.Parent = workspace
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "FlashBeamAttachment"
		attachment2.Parent = humanoidRootPart
		local clone = beam:Clone()
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2

		if color then
			clone.Color = ColorSequence.new(color)
		end

		clone.Enabled = true
		clone.Parent = part
		local v15 = p + p2
		Debris:AddItem(part, v15 + 0.5)
		Debris:AddItem(attachment2, v15 + 0.5)
		local transparency = clone.Transparency
		local lastTime = os.clock()

		while part.Parent and (not callback or callback()) do
			local v16 = os.clock() - lastTime
			local v17 = p2 > 0 and math.clamp((v16 - p) / p2, 0, 1) or p <= v16 and 1 or 0
			local numberSequenceKeypoints = {}

			for _, keypoint in transparency.Keypoints do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(keypoint.Time, 1 - (1 - keypoint.Value) * (1 - v17))
				)
			end

			clone.Transparency = NumberSequence.new(numberSequenceKeypoints)

			if v17 >= 1 then
				break
			else
				task.wait()
			end
		end

		part:Destroy()
		attachment2:Destroy()
	end)
end

local v15 = {}
local v16 = {}
starterEgg.OnClientEvent:Connect(function(p, value, p2)
	if typeof(p) == "Vector3" then
		v15[value or "Starter"] = p
		v16[value or "Starter"] = p2
	end
end)

local function CarryingTutorialEgg(p: string)
	local v17 = v16[p]

	if not v17 then
		return false
	end

	for _, child in basket:GetChildren() do
		if child:GetAttribute("Egg") == v17 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PointAtEgg(p: string, p2: string, flag3: boolean?, color: Color3?)
	task.spawn(function()
		while not (flag or v15[p]) do
			task.wait(0.25)
		end

		local v17 = v15[p]

		if v17 and not flag then
			if flag3 == false then
				if color then
					FlashBeam(v17 + createVector(0, 3, 0), color, 1, 1, nil) -- equivalent call inferred; original call site unknown
				end
			else
				ShowBeam(v17 + createVector(0, 3, 0))
			end

			local function fn2()
				return v15[p]
			end

			TrackDistanceTo(fn2, p2) -- equivalent call inferred; original call site unknown
		end
	end)
end

local visibilityByGuiObject = {}

local function HideHudButtons()
	for _, guiObject in v do
		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		visibilityByGuiObject[guiObject] = guiObject.Visible
		guiObject.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreHudButtons()
	for k, visible in visibilityByGuiObject do
		if k.Parent then
			k.Visible = visible
		end
	end

	table.clear(visibilityByGuiObject)
end

local target = nil
local expiry = nil

local function RadarRunning()
	if expiry ~= nil and expiry > workspace:GetServerTimeNow() then
		return true
	end

	local runningRadars = localPlayer:GetAttribute("RunningRadars")
	return type(runningRadars) == "string" and string.find(runningRadars, "Advanced Radar", 1, true) ~= nil
end

local radarState = game2:FindFirstChild("RadarState")

if radarState then
	radarState.OnClientEvent:Connect(function(items)
		if typeof(items) ~= "table" then
			return
		end

		local v17 = false

		for _, item in items do
			if item.Name ~= "Advanced Radar" then
				continue
			end

			v17 = true
			expiry = tonumber(item.Expiry)

			if typeof(item.Target) == "Vector3" then
				target = item.Target
			end
		end

		if not v17 then
			expiry = nil
		end
	end)
end

local function RunTutorial()
	parent.Enabled = true
	parent:SetAttribute("TutorialActive", true)
	localPlayer:SetAttribute("TutorialActive", true)
	print("[Onboarding] starting")
	HideHudButtons()
	StartFloating()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UsingGamepad()
		if string.sub(UserInputService:GetLastInputType().Name, 1, 7) == "Gamepad" then
			return true
		end

		return UserInputService.GamepadEnabled and not (UserInputService.MouseEnabled or UserInputService.TouchEnabled)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ActionWordNow()
		if UsingGamepad() then
			return "Press"
		end

		if UserInputService.TouchEnabled and not UserInputService.MouseEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
			return "Tap"
		end

		return "Click"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function PlotEggCount()
		local myPlot = GetMyPlot()
		local eggs = myPlot and myPlot:FindFirstChild("Eggs")
		return eggs and #eggs:GetChildren() or 0
	end

	local stalls = workspace:FindFirstChild("Stalls")
	local gears2 = stalls and stalls:FindFirstChild("Gears")
	local rick = gears2 and gears2:FindFirstChild("Rick")
	local v17 = rick and rick:GetPivot().Position + createVector(0, 4, 0)
	local resumeHatch = tutorial:WaitForChild("ResumeHatch")

	while true do
		local success, result = pcall(function()
			return resumeHatch:InvokeServer()
		end)

		if not success then
			instruction.Text = "Loading Your Tutorial..."
			instruction.TextTransparency = 0
			local uIStroke2 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke2 then
				uIStroke2.Transparency = 0
			end

			instruction.Visible = true
			local parent3 = instruction.Parent

			if parent3 and parent3:IsA("GuiObject") then
				parent3.Visible = true
			end

			task.wait(1)
		end

		if not (success or flag) then
			continue
		end

		if flag then
			break
		end

		if not result then
			instruction.Text = "Preparing Your Snail..."
			instruction.TextTransparency = 0
			local uIStroke2 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke2 then
				uIStroke2.Transparency = 0
			end

			instruction.Visible = true
			local parent3 = instruction.Parent

			if parent3 and parent3:IsA("GuiObject") then
				parent3.Visible = true
			end

			ReportStep(1) -- equivalent call inferred; original call site unknown
			local v18 = nil
			local v19 = nil
			WaitUntil(function()
				local visible = ride.Visible
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				local v20 = false

				for _, tool in backpack and backpack:GetChildren() or {} do
					if not (tool:IsA("Tool") and tool:GetAttribute("PetKey") == "TUTORIAL_Snail") then
						continue
					end

					v20 = true
					break
				end

				local text = visible and "Ride Pet To Go Faster" or v20 and "Equip Your Snail" or "Preparing Your Snail..."

				if text ~= v19 then
					v19 = text
					SetInstruction(text) -- equivalent call inferred; original call site unknown
				end

				v18 = visible
				return visible
			end)

			if flag then
				break
			end

			HighlightButton(ride) -- equivalent call inferred; original call site unknown
			WaitUntil(function()
				local visible = ride.Visible

				if visible == v18 then
					return localPlayer:GetAttribute("IsRiding") == true
				end

				v18 = visible
				SetInstruction(visible and "Ride Pet To Go Faster" or "Equip Your Snail") -- equivalent call inferred; original call site unknown
				return localPlayer:GetAttribute("IsRiding") == true
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			ReportStep(5) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			instruction.Text = "Go To Gear Shop"
			instruction.TextTransparency = 0
			local uIStroke3 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke3 then
				uIStroke3.Transparency = 0
			end

			instruction.Visible = true
			local parent4 = instruction.Parent

			if parent4 and parent4:IsA("GuiObject") then
				parent4.Visible = true
			end

			local gears3 = stalls:FindFirstChild("Gears")
			local rick2 = gears3 and gears3:FindFirstChild("Rick")
			local v21 = gears3 and StallCenter(gears3)
			v17 = rick2 and rick2:GetPivot().Position + createVector(0, 4, 0) or v21

			if v17 then
				ShowBeam(v17)

				local function fn2()
					return v17
				end

				StopDistance() -- equivalent call inferred; original call site unknown
				instruction.RichText = true
				local v22 = nil
				local v23 = "#5BE05B"
				local total3 = 0
				local v26 = "Go To Gear Shop"
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if flag then
						return
					end

					local v27 = fn2()
					local rootPosition = RootPosition() -- equivalent call inferred; original call site unknown

					if not (v27 and rootPosition) then
						return
					end

					local magnitude = ((v27 - rootPosition) * createVector(1, 0, 1)).Magnitude
					total3 += dt

					if total3 >= 0.25 then
						if v22 then
							local v29 = magnitude - v22

							if math.abs(v29) >= 0.75 then
								v23 = v29 < 0 and "#5BE05B" or "#FF6B6B"
							end
						end

						v22 = magnitude
						total3 = 0
					end

					instruction.Text = string.format(
						"%s  <font color=\"%s\">%dm</font> Away",
						v26,
						v23,
						(math.max(math.floor(magnitude + 0.5), 0))
					)
					instruction.Visible = true
				end)
				AddCleanup(StopDistance) -- equivalent call inferred; original call site unknown
			end

			WaitUntil(function()
				if ShopOpenOnGears() then
					return true
				end

				local rootPosition = RootPosition() -- equivalent call inferred; original call site unknown

				if rootPosition and v17 then
					return ((v17 - rootPosition) * createVector(1, 0, 1)).Magnitude <= 25
				end

				return false
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			StopDistance() -- equivalent call inferred; original call site unknown
			ReportStep(6) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			instruction.Text = "Open Rick's Shop"
			instruction.TextTransparency = 0
			local uIStroke4 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke4 then
				uIStroke4.Transparency = 0
			end

			instruction.Visible = true
			local parent5 = instruction.Parent

			if parent5 and parent5:IsA("GuiObject") then
				parent5.Visible = true
			end

			if v17 then
				ShowBeam(v17)
			end

			WaitUntil(ShopOpenOnGears)
			RunCleanup() -- equivalent call inferred; original call site unknown
			ReportStep(7) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			instruction.Text = "Buy Advanced Radar"
			instruction.TextTransparency = 0
			local uIStroke5 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke5 then
				uIStroke5.Transparency = 0
			end

			instruction.Visible = true
			local parent6 = instruction.Parent

			if parent6 and parent6:IsA("GuiObject") then
				parent6.Visible = true
			end

			local v22 = true
			table.insert(v2, function()
				v22 = false
			end)
			task.spawn(function()
				local v23 = nil
				local v24 = nil

				while v22 and not flag do
					local advancedRadar = ShopOpenOnGears() and gears:FindFirstChild("Advanced Radar") or nil

					if advancedRadar ~= v23 then
						if v24 then
							v24()
							v24 = nil
						end

						if advancedRadar and advancedRadar:IsA("GuiObject") then
							v4.Show(advancedRadar)
							local cashPayment = advancedRadar:FindFirstChild("CashPayment")
							local cashPaymentFrame = cashPayment and cashPayment:FindFirstChild("Frame")
							local dollar = cashPaymentFrame and cashPaymentFrame:FindFirstChild("Dollar")

							if dollar and dollar:IsA("GuiObject") then
								v24 = ShowTapHintOnGui(dollar)
							end
						else
							v4.Hide()
						end

						v23 = advancedRadar
					end

					task.wait(0.25)
				end
			end)
			AddCleanup(v4.Hide) -- equivalent call inferred; original call site unknown
			WaitUntil(function()
				return FindTool(function(p)
					return p.Name == "Advanced Radar"
				end) ~= nil
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			UIController.close(shop)
			ReportStep(8) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			if not RadarRunning() then
				instruction.Text = "Use Radar To Find Rarer Eggs"
				instruction.TextTransparency = 0
				local uIStroke6 = instruction:FindFirstChildOfClass("UIStroke")

				if uIStroke6 then
					uIStroke6.Transparency = 0
				end

				instruction.Visible = true
				local parent7 = instruction.Parent

				if parent7 and parent7:IsA("GuiObject") then
					parent7.Visible = true
				end

				WaitUntil(function()
					return useRadar.Visible or RadarRunning()
				end)

				if flag then
					break
				end

				if not RadarRunning() then
					HighlightButton(useRadar) -- equivalent call inferred; original call site unknown
					WaitUntil(RadarRunning)
					RunCleanup() -- equivalent call inferred; original call site unknown
				end
			end

			ReportStep(9) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			instruction.Text = "Find Rare Egg"
			instruction.TextTransparency = 0
			local uIStroke6 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke6 then
				uIStroke6.Transparency = 0
			end

			instruction.Visible = true
			local parent7 = instruction.Parent

			if parent7 and parent7:IsA("GuiObject") then
				parent7.Visible = true
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function RareEggFound()
				return localPlayer:GetAttribute("TutorialRareEggFound") == true
			end

			if localPlayer:GetAttribute("TutorialRareEggFound") ~= true then
				PointAtEgg("Rare", "Find Rare Egg", false, nil) -- equivalent call inferred; original call site unknown
			end

			WaitUntil(function()
				return CarryingTutorialEgg("Rare") or RareEggFound()
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			StopDistance() -- equivalent call inferred; original call site unknown
			ReportStep(10) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			instruction.Text = "Bring Back Egg To Plot"
			instruction.TextTransparency = 0
			local uIStroke7 = instruction:FindFirstChildOfClass("UIStroke")

			if uIStroke7 then
				uIStroke7.Transparency = 0
			end

			instruction.Visible = true
			local parent8 = instruction.Parent

			if parent8 and parent8:IsA("GuiObject") then
				parent8.Visible = true
			end

			local myPlot = GetMyPlot()
			local baseplate = myPlot and myPlot:FindFirstChild("Baseplate")

			if baseplate then
				ShowBeam(baseplate.Position + createVector(0, 4, 0))

				local function fn2()
					local myPlot2 = GetMyPlot()
					local baseplate2 = myPlot2 and myPlot2:FindFirstChild("Baseplate")
					return baseplate2 and baseplate2.Position or nil
				end

				StopDistance() -- equivalent call inferred; original call site unknown
				instruction.RichText = true
				local v24 = nil
				local v25 = "#5BE05B"
				local total3 = 0
				local v28 = "Bring Back Egg To Plot"
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if flag then
						return
					end

					local v29 = fn2()
					local rootPosition = RootPosition() -- equivalent call inferred; original call site unknown

					if not (v29 and rootPosition) then
						return
					end

					local magnitude = ((v29 - rootPosition) * createVector(1, 0, 1)).Magnitude
					total3 += dt

					if total3 >= 0.25 then
						if v24 then
							local v31 = magnitude - v24

							if math.abs(v31) >= 0.75 then
								v25 = v31 < 0 and "#5BE05B" or "#FF6B6B"
							end
						end

						v24 = magnitude
						total3 = 0
					end

					instruction.Text = string.format(
						"%s  <font color=\"%s\">%dm</font> Away",
						v28,
						v25,
						(math.max(math.floor(magnitude + 0.5), 0))
					)
					instruction.Visible = true
				end)
				AddCleanup(StopDistance) -- equivalent call inferred; original call site unknown
			end

			WaitUntil(function()
				return not CarryingTutorialEgg("Rare")
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			StopDistance() -- equivalent call inferred; original call site unknown
			ReportStep(11) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			local noNest = localPlayer:GetAttribute("NoNest") == true

			local function TutorialPlacedEgg()
				local myPlot2 = GetMyPlot()
				local eggs = myPlot2 and myPlot2:FindFirstChild("Eggs")
				local tutorialRareEggName = localPlayer:GetAttribute("TutorialRareEggName")

				if eggs and tutorialRareEggName then
					for _, model in eggs:GetChildren() do
						if model:IsA("Model") and model.Name == tutorialRareEggName then
							return model
						end
					end
				end

				return nil
			end

			local TutorialPlacedEgg2 = TutorialPlacedEgg

			local function PlacementBlocked()
				if TutorialPlacedEgg2() then
					return false
				end

				if noNest then
					return PlotEggCount() >= 10
				else
					local myPlot2 = GetMyPlot()
					local nests = myPlot2 and myPlot2:FindFirstChild("Nests")
					local _1 = nests and nests:FindFirstChild("1")
					return _1 ~= nil and _1:GetAttribute("Occupied") == true
				end
			end

			if PlacementBlocked() then
				instruction.Text = "Hatch One Egg To Make Room"
				instruction.TextTransparency = 0
				local uIStroke8 = instruction:FindFirstChildOfClass("UIStroke")

				if uIStroke8 then
					uIStroke8.Transparency = 0
				end

				instruction.Visible = true
				local parent9 = instruction.Parent

				if parent9 and parent9:IsA("GuiObject") then
					parent9.Visible = true
				end

				ReportStep(11.5) -- equivalent call inferred; original call site unknown
				local myPlot2 = GetMyPlot()
				local eggs = myPlot2 and myPlot2:FindFirstChild("Eggs")
				local nests = myPlot2 and myPlot2:FindFirstChild("Nests")
				local eggsModel

				if noNest then
					eggsModel = eggs and eggs:FindFirstChildWhichIsA("Model")
				else
					eggsModel = nests and nests:FindFirstChild("1")
				end

				if eggsModel then
					ShowBeam(eggsModel:GetPivot().Position + createVector(0, 4, 0))
				end

				local PlacementBlocked2 = PlacementBlocked
				WaitUntil(function()
					return not PlacementBlocked2()
				end)
				RunCleanup() -- equivalent call inferred; original call site unknown
			end

			if flag then
				break
			end

			local v25 = noNest

			local function LabelNestStep()
				if v25 then
					if UsingGamepad() then
						SetInstruction(string.format(
							"Press %s To Plant Egg On Plot",
							GamepadGlyphs.Text(Enum.KeyCode.ButtonX)
						)) -- equivalent call inferred; original call site unknown
					else
						SetInstruction(ActionWordNow() .. " Ground To Plant Egg") -- equivalent call inferred; original call site unknown
					end
				else
					instruction.Text = "Place Egg In Nest"
					instruction.TextTransparency = 0
					local uIStroke8 = instruction:FindFirstChildOfClass("UIStroke")

					if uIStroke8 then
						uIStroke8.Transparency = 0
					end

					instruction.Visible = true
					local parent9 = instruction.Parent

					if parent9 and parent9:IsA("GuiObject") then
						parent9.Visible = true
					end
				end
			end

			LabelNestStep()
			local connection = UserInputService.LastInputTypeChanged:Connect(LabelNestStep)
			table.insert(v2, function()
				connection:Disconnect()
			end)
			local plotEggCount = PlotEggCount() -- equivalent call inferred; original call site unknown

			-- equivalent calls inferred from this helper; original call sites unknown
			local function HasEggTool()
				return FindTool(function(p)
					return Eggs[p.Name] ~= nil
				end) ~= nil
			end

			local v27 = noNest
			task.spawn(function()
				while true do
					local myPlot2 = GetMyPlot()

					if not myPlot2 then
						task.wait(0.5)
					end

					if not (myPlot2 or flag) then
						continue
					end

					if flag then
						break
					end

					if v27 then
						local baseplate2 = myPlot2 and myPlot2:FindFirstChild("Baseplate")

						if baseplate2 then
							ShowTapHintAt(baseplate2.Position + Vector3.new(0, baseplate2.Size.Y / 2 + 1, 0), 7, true)
						end

						break
					else
						local nests = myPlot2 and myPlot2:FindFirstChild("Nests")
						local _1 = nests and nests:FindFirstChild("1")

						if _1 then
							ShowBeam(_1:GetPivot().Position + createVector(0, 4, 0))
						end

						break
					end
				end
			end)
			local TutorialPlacedEgg3 = TutorialPlacedEgg
			WaitUntil(function()
				if TutorialPlacedEgg3() == nil then
					local plotEggCount2 = PlotEggCount() -- equivalent call inferred; original call site unknown

					if plotEggCount < plotEggCount2 then
						return true
					else
						local eggTool = HasEggTool() -- equivalent call inferred; original call site unknown
						return not eggTool
					end
				else
					return true
				end
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			ReportStep(12) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			if localPlayer:GetAttribute("IsRiding") == true then
				instruction.Text = "Get Off Your Pet"
				instruction.TextTransparency = 0
				local uIStroke8 = instruction:FindFirstChildOfClass("UIStroke")

				if uIStroke8 then
					uIStroke8.Transparency = 0
				end

				instruction.Visible = true
				local parent9 = instruction.Parent

				if parent9 and parent9:IsA("GuiObject") then
					parent9.Visible = true
				end

				local dismount = actionsHolder:FindFirstChild("Dismount")

				if dismount and dismount:IsA("GuiObject") then
					HighlightButton(dismount) -- equivalent call inferred; original call site unknown
				end

				WaitUntil(function()
					return localPlayer:GetAttribute("IsRiding") ~= true
				end)
				RunCleanup() -- equivalent call inferred; original call site unknown
			end

			ReportStep(13) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			local function LabelPlaceStep()
				if UsingGamepad() then
					SetInstruction(string.format(
						"Press %s To Place Pet On Plot",
						GamepadGlyphs.Text(Enum.KeyCode.ButtonR2)
					)) -- equivalent call inferred; original call site unknown
				else
					SetInstruction(ActionWordNow() .. " To Place Pet On Plot") -- equivalent call inferred; original call site unknown
				end
			end

			LabelPlaceStep()
			local connection2 = UserInputService.LastInputTypeChanged:Connect(LabelPlaceStep)
			table.insert(v2, function()
				connection2:Disconnect()
			end)
			local plotPetCount = PlotPetCount() -- equivalent call inferred; original call site unknown

			fn = function()
				return (FindTool(function(instance)
					return instance:HasTag("Pet")
				end))
			end

			task.spawn(function()
				while true do
					local myPlot2 = GetMyPlot()

					if not myPlot2 then
						task.wait(0.25)
					end

					if not (myPlot2 or flag) then
						continue
					end

					local baseplate2 = myPlot2 and myPlot2:FindFirstChild("Baseplate")

					if not baseplate2 or flag then
						break
					end

					local position = baseplate2.Position + Vector3.new(0, baseplate2.Size.Y / 2 + 4, 0)
					local part = Instance.new("Part")
					part.Name = "TutorialTapHintAnchor"
					part.Anchored = true
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.Transparency = 1
					part.Size = createVector(1, 1, 1)
					part.Position = position
					part.Parent = workspace
					local parent9, v33 = BuildTapBillboard(part, part, 7)
					local v34 = nil
					table.insert(v2, function()
						v33:Cancel()

						if v34 then
							v34:Cancel()
						end

						parent9:Destroy()
						part:Destroy()
					end)
					break
				end
			end)
			WaitUntil(function()
				local plotPetCount2 = PlotPetCount() -- equivalent call inferred; original call site unknown

				if plotPetCount < plotPetCount2 then
					return true
				end

				local myPlot2 = GetMyPlot()
				local pets = myPlot2 and myPlot2:FindFirstChild("Pets")
				return (pets and #pets:GetChildren() or 0) > 0 and fn ~= nil and fn() == nil
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			ReportStep(14) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			local AutoCollect = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("AutoCollect"))
			local Passes = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("Passes"))

			if AutoCollect.Enabled() or Passes.Has(localPlayer, "AutoCollect") then
				instruction.Text = "Your Pet Earns Cash For You"
				instruction.TextTransparency = 0
				local uIStroke8 = instruction:FindFirstChildOfClass("UIStroke")

				if uIStroke8 then
					uIStroke8.Transparency = 0
				end

				instruction.Visible = true
				local parent9 = instruction.Parent

				if parent9 and parent9:IsA("GuiObject") then
					parent9.Visible = true
				end
			else
				instruction.Text = "Touch Pet To Collect Cash"
				instruction.TextTransparency = 0
				local uIStroke8 = instruction:FindFirstChildOfClass("UIStroke")

				if uIStroke8 then
					uIStroke8.Transparency = 0
				end

				instruction.Visible = true
				local parent9 = instruction.Parent

				if parent9 and parent9:IsA("GuiObject") then
					parent9.Visible = true
				end

				task.spawn(function()
					while true do
						local position = PlacedPetPosition(nil) -- equivalent call inferred; original call site unknown

						if not position then
							task.wait(0.25)
						end

						if not (position or flag) then
							continue
						end

						if position and not flag then
							ShowBeam(position, PlacedPetPosition)
						end

						break
					end
				end)
			end

			local v31 = cash.Value
			WaitUntil(function()
				return v31 < cash.Value
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			ReportStep(15) -- equivalent call inferred; original call site unknown

			if flag then
				break
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function LabelLuckStep()
				if UsingGamepad() then
					SetInstruction(string.format(
						"Aim At Upgrade Button, Press %s",
						GamepadGlyphs.Text(Enum.KeyCode.ButtonR2)
					)) -- equivalent call inferred; original call site unknown
				else
					instruction.Text = "Upgrade Luck"
					instruction.TextTransparency = 0
					local uIStroke8 = instruction:FindFirstChildOfClass("UIStroke")

					if uIStroke8 then
						uIStroke8.Transparency = 0
					end

					instruction.Visible = true
					local parent9 = instruction.Parent

					if parent9 and parent9:IsA("GuiObject") then
						parent9.Visible = true
					end
				end
			end

			LabelLuckStep() -- equivalent call inferred; original call site unknown
			local connection3 = UserInputService.LastInputTypeChanged:Connect(LabelLuckStep)
			table.insert(v2, function()
				connection3:Disconnect()
			end)
			local value2 = hatchUpgrades.Value
			task.spawn(function()
				while true do
					local myPlot2 = GetMyPlot()

					if not myPlot2 then
						task.wait(0.5)
					end

					if not (myPlot2 or flag) then
						continue
					end

					local hatchUpgrade = myPlot2 and myPlot2:FindFirstChild("HatchUpgrade")
					local screen = hatchUpgrade and hatchUpgrade:FindFirstChild("Screen")

					if not hatchUpgrade or flag then
						break
					end

					local v33 = hatchUpgrade:GetPivot().Position + createVector(0, 4, 0)
					local v34 = os.clock() + 10

					while true do
						for _, surfaceGui in playerGui:GetChildren() do
							if not (surfaceGui:IsA("SurfaceGui") and surfaceGui.Adornee == screen) then
								continue
							end

							local purchase = surfaceGui:FindFirstChild("Purchase")
							v33 = purchase and SurfaceButtonPosition(surfaceGui, purchase) or v33
							break
						end

						if v33 == hatchUpgrade:GetPivot().Position + createVector(0, 4, 0) then
							task.wait(0.25)
						end

						if not (v33 ~= hatchUpgrade:GetPivot().Position + createVector(0, 4, 0) or v34 < os.clock() or flag) then
							continue
						end

						if not flag then
							ShowBeam(v33)
						end

						return
					end
				end
			end)
			WaitUntil(function()
				return value2 < hatchUpgrades.Value
			end)
			RunCleanup() -- equivalent call inferred; original call site unknown
			ReportStep(16) -- equivalent call inferred; original call site unknown
		end

		if flag then
			break
		end

		instruction.Text = "Hatch Rare Egg For Faster Pet"
		instruction.TextTransparency = 0
		local uIStroke2 = instruction:FindFirstChildOfClass("UIStroke")

		if uIStroke2 then
			uIStroke2.Transparency = 0
		end

		instruction.Visible = true
		local parent3 = instruction.Parent

		if parent3 and parent3:IsA("GuiObject") then
			parent3.Visible = true
		end

		local tutorialFinalEggKey = nil
		WaitUntil(function()
			tutorialFinalEggKey = localPlayer:GetAttribute("TutorialFinalEggKey")
			return localPlayer:GetAttribute("TutorialFinalEggResolved") == true
		end)

		if flag then
			break
		end

		local function FindFinalEgg()
			local myPlot = GetMyPlot()
			local eggs = myPlot and myPlot:FindFirstChild("Eggs")

			if eggs then
				for _, child in eggs:GetChildren() do
					if child:GetAttribute("EggKey") == tutorialFinalEggKey then
						return child
					end
				end
			end

			return nil
		end

		local FindFinalEgg2 = FindFinalEgg
		task.spawn(function()
			while not flag and localPlayer:GetAttribute("TutorialFinalEggHatched") ~= true do
				local finalEgg2 = FindFinalEgg2()

				if finalEgg2 then
					ShowBeam(finalEgg2:GetPivot().Position + createVector(0, 4, 0))
					break
				else
					task.wait(0.1)
				end
			end
		end)
		WaitUntil(function()
			return localPlayer:GetAttribute("TutorialFinalEggHatched") == true
		end)
		RunCleanup() -- equivalent call inferred; original call site unknown
		ReportStep(17) -- equivalent call inferred; original call site unknown
		ReportStep(18) -- equivalent call inferred; original call site unknown
		local tutorialFinalPetKey = localPlayer:GetAttribute("TutorialFinalPetKey")

		if not (v17 and typeof(tutorialFinalPetKey) == "string") then
			break
		end

		local v18 = tutorialFinalPetKey

		local function HasFinalChicken()
			for k, v19 in { localPlayer:FindFirstChildOfClass("Backpack"), localPlayer.Character } do
				if not v19 then
					continue
				end

				for i, tool in v19:GetChildren() do
					if tool:IsA("Tool") and tool:GetAttribute("PetKey") == v18 and tool:GetAttribute("PetName") == "Chicken" then
						return true
					end
				end
			end

			return false
		end

		local HasFinalChicken2 = HasFinalChicken
		task.spawn(function()
			local v19 = os.clock() + 60

			while not HasFinalChicken2() do
				task.wait(0.1)

				if not localPlayer.Parent or v19 <= os.clock() then
					return
				end
			end

			FlashBeam(v17, nil, 0, 7, HasFinalChicken2) -- equivalent call inferred; original call site unknown
		end)
		break
	end
end

local function EndTutorial()
	if flag then
		return
	end

	flag = true
	StopDistance() -- equivalent call inferred; original call site unknown
	RunCleanup() -- equivalent call inferred; original call site unknown
	RestoreHudButtons() -- equivalent call inferred; original call site unknown

	if v3 then
		v3:Cancel()
	end

	instruction.Text = ""
	instruction.TextTransparency = 0
	local uIStroke2 = instruction:FindFirstChildOfClass("UIStroke")

	if uIStroke2 then
		uIStroke2.Transparency = 0
	end

	instruction.Visible = false
	local parent3 = instruction.Parent

	if parent3 and parent3:IsA("GuiObject") then
		parent3.Visible = false
	end

	parent:SetAttribute("TutorialActive", false)
	localPlayer:SetAttribute("TutorialActive", false)
	parent.Enabled = false
	print("[Onboarding] finished")
end

task.spawn(function()
	if GameSettings.Enabled("SKIPTUTORIALONSTUDIO") then
		print("[Onboarding] skipped - SKIPTUTORIALONSTUDIO")
		return
	end

	local dataLoaded = localPlayer:WaitForChild("NoSaveData"):WaitForChild("DataLoaded")

	while dataLoaded.Value ~= true do
		dataLoaded:GetPropertyChangedSignal("Value"):Wait()
	end

	while localPlayer:GetAttribute("GameLoaded") ~= true do
		localPlayer:GetAttributeChangedSignal("GameLoaded"):Wait()
	end

	if hasFinishedTutorial.Value ~= false then
		print("[Onboarding] skipped - HasFinishedTutorial is already true")
		return
	end

	hasFinishedTutorial:GetPropertyChangedSignal("Value"):Connect(function()
		if hasFinishedTutorial.Value == true then
			EndTutorial()
		end
	end)
	RunTutorial()
end)