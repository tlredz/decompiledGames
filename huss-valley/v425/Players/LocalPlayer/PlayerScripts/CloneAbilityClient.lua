local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local CloneAbilityConfig = require(chickenOrHero.Weapons:WaitForChild("CloneAbilityConfig"))
local cloneAbilityEvent = chickenOrHero.Weapons:WaitForChild("CloneAbilityEvent")
local CloneSplitEffects = require(chickenOrHero.Weapons:WaitForChild("CloneSplitEffects"))
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local ValleyTheme = require(chickenOrHero.Presentation.ValleyTheme)
local ControlGate = require(chickenOrHero.Movement.ControlGate)
local HudNavigation = require(chickenOrHero.Presentation.HudNavigation)
local session = chickenOrHero.Game.Session
local screen = ValleyPanels.screen(localPlayer, "KnifeAbilityHUD", 35)
local button = ValleyPanels.button(screen, "Clone", "", 0, 0, 156, 80)
ValleyTheme.button(button, ValleyTheme.Blue)
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -24, 0.43, 0)
button.Visible = false
local text = ValleyPanels.text(button, "Label", "CLONE", 49, 13, 100, 22, 15, ValleyTheme.Paper)
text.TextXAlignment = Enum.TextXAlignment.Center
local text2 = ValleyPanels.text(button, "Hint", "R  /  2 COPIES", 49, 39, 100, 18, 10, ValleyTheme.Blue)
text2.TextXAlignment = Enum.TextXAlignment.Center
text.Font = Enum.Font.GothamBold
text2.Font = Enum.Font.GothamBold
local v = ValleyPanels.make("UIGradient", button, "Shimmer", {
	Rotation = 25,
	Color = ColorSequence.new(Color3.fromRGB(59, 96, 112), Color3.fromRGB(21, 35, 49))
})

for i = 1, 3 do
	local v2 = (i - 1) * 9 + 9
	local v3 = ValleyPanels.make("Frame", button, "CloneHead" .. i, {
		Position = UDim2.fromOffset(v2, 22 - (i == 2 and 4 or 0)),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = ValleyTheme.Blue,
		BackgroundTransparency = i == 2 and 0 or 0.4,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v3, 5)
	local v4 = ValleyPanels.make("Frame", button, "CloneBody" .. i, {
		Position = UDim2.fromOffset(v2 - 2, 33 - (i == 2 and 4 or 0)),
		Size = UDim2.fromOffset(14, 20),
		BackgroundColor3 = ValleyTheme.Blue,
		BackgroundTransparency = i == 2 and 0 or 0.4,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v4, 4)
end

local v2 = ValleyPanels.make("Frame", button, "Track", {
	Position = UDim2.fromOffset(12, 69),
	Size = UDim2.fromOffset(132, 4),
	BackgroundColor3 = Color3.fromRGB(40, 65, 79),
	BorderSizePixel = 0
})
ValleyPanels.corner(v2, 4)
local v3 = ValleyPanels.make("Frame", v2, "Fill", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = ValleyTheme.Blue,
	BorderSizePixel = 0
})
ValleyPanels.corner(v3, 4)
local uIScale = Instance.new("UIScale")
uIScale.Parent = button

local function pop()
	TweenService:Create(button, TweenInfo.new(0.09), {
		Rotation = 3
	}):Play()
	task.delay(0.09, function()
		if button.Parent then
			TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
				Rotation = 0
			}):Play()
		end
	end)
end

local now = -1e999
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function on(activated, request)
	table.insert(connections, activated:Connect(request))
end

local function available()
	local enabled = CloneAbilityConfig.Enabled

	if enabled then
		if localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("EquippedKnife") == CloneAbilityConfig.Skin and localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("RunState") == "Active" and (localPlayer:GetAttribute("GameRole") == "Runner" or localPlayer:GetAttribute("GameRole") == "Catcher") then
			enabled = not (session:GetAttribute("GlobalPaused") or session:GetAttribute("MapChanging"))
		else
			enabled = false
		end
	end

	return enabled
end

local function request()
	if not available() or ControlGate.reason(localPlayer) or os.clock() - now < 0.5 then
		return
	end

	if (localPlayer:GetAttribute("CloneAbilityReadyAt") or 0) > workspace:GetServerTimeNow() then
		return
	end

	now = os.clock()
	pop()
	cloneAbilityEvent:FireServer("Activate")
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		CloneSplitEffects.play(humanoidRootPart.Position)
	end
end

on(button.Activated, request) -- equivalent call inferred; original call site unknown
table.insert(connections, button.MouseEnter:Connect(function()
	TweenService:Create(v, TweenInfo.new(0.2), {
		Rotation = 70
	}):Play()
end))
table.insert(connections, button.MouseLeave:Connect(function()
	TweenService:Create(v, TweenInfo.new(0.2), {
		Rotation = 25
	}):Play()
end))
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and (input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.ButtonL1) then
		request()
	end
end))

local function pulse(position)
	if typeof(position) ~= "Vector3" then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera or (currentCamera.CFrame.Position - position).Magnitude > 110 then
		return
	end

	local part = Instance.new("Part")
	part.Name = "ClonePulse"
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(2, 4, 2)
	part.CFrame = CFrame.new(position)
	part.Material = Enum.Material.Neon
	part.Color = ValleyTheme.Blue
	part.Transparency = 0.65
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = workspace
	TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
		Size = createVector(6, 6, 6),
		Transparency = 1
	}):Play()
	Debris:AddItem(part, 0.45)
end

table.insert(connections, cloneAbilityEvent.OnClientEvent:Connect(function(p, value)
	if p == "Notice" and type(value) == "string" then
		HudNavigation.Notice:Fire(value)
	elseif p == "Split" and type(value) == "table" then
		if value.ownerId ~= localPlayer.UserId or os.clock() - now > 1 then
			CloneSplitEffects.play(value.position)
		end
	elseif p == "Dissolve" and type(value) == "table" then
		pulse(value.position)
	end
end))
local total = 0
local v4 = false
table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	button.Visible = available() and not ControlGate.reason(localPlayer)
	local absoluteSize = screen.AbsoluteSize
	uIScale.Scale = math.clamp(math.min(absoluteSize.X / 1000, absoluteSize.Y / 650), 0.58, 1)
	button.Position = UDim2.new(1, -24, 0.5, -140 * uIScale.Scale)

	if not button.Visible then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v5 = math.max(0, (math.ceil((localPlayer:GetAttribute("CloneAbilityReadyAt") or 0) - serverTimeNow)))
	local v6 = serverTimeNow < (localPlayer:GetAttribute("CloneAbilityActiveUntil") or 0)
	text.Text = v6 and "CLONES OUT" or not (v5 > 0) and "CLONE" or string.format(
		"%d:%02d",
		math.floor(v5 / 60),
		v5 % 60
	) or "CLONE"
	text2.Text = v6 and "TWO OF A KIND" or v5 > 0 and "RECHARGING" or UserInputService.TouchEnabled and "TAP TO SPLIT" or UserInputService.GamepadEnabled and "L1  /  2 COPIES" or "R  /  2 COPIES"
	button.BackgroundTransparency = v5 > 0 and 0.5 or 0.15
	v3.Size = UDim2.fromScale(math.clamp(1 - v5 / (CloneAbilityConfig.Cooldown or 45), 0, 1), 1)
	v3.BackgroundColor3 = v6 and ValleyTheme.Paper or ValleyTheme.Blue
	local v7 = v5 == 0

	if v7 and not v4 then
		pop()
	end

	v4 = v7
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	screen:Destroy()
end)