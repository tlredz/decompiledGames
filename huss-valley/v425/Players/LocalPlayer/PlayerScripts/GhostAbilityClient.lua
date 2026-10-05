local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ghostAbilityEvent = chickenOrHero.Weapons:WaitForChild("GhostAbilityEvent")
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local ValleyTheme = require(chickenOrHero.Presentation.ValleyTheme)
local ControlGate = require(chickenOrHero.Movement.ControlGate)
local session = chickenOrHero.Game.Session
local screen = ValleyPanels.screen(localPlayer, "GhostAbilityHUD", 35)
local button = ValleyPanels.button(screen, "Ghost", "", 0, 0, 156, 80)
ValleyTheme.button(button, Color3.fromRGB(74, 175, 166))
button.AnchorPoint = Vector2.new(1, 0.5)
button.Visible = false
local text = ValleyPanels.text(button, "Label", "GHOST", 12, 13, 132, 27, 18, ValleyTheme.Paper)
text.TextXAlignment = Enum.TextXAlignment.Center
text.Font = Enum.Font.GothamBold
local text2 = ValleyPanels.text(button, "Hint", "R / FADE", 12, 45, 132, 19, 11, Color3.fromRGB(167, 245, 229))
text2.TextXAlignment = Enum.TextXAlignment.Center
local v = ValleyPanels.make("Frame", button, "Track", {
	Position = UDim2.fromOffset(12, 69),
	Size = UDim2.fromOffset(132, 4),
	BackgroundColor3 = Color3.fromRGB(29, 75, 73),
	BorderSizePixel = 0
})
ValleyPanels.corner(v, 4)
local v2 = ValleyPanels.make("Frame", v, "Fill", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(152, 243, 225),
	BorderSizePixel = 0
})
ValleyPanels.corner(v2, 4)
local uIScale = Instance.new("UIScale")
uIScale.Parent = button
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function on(activated, request)
	table.insert(connections, activated:Connect(request))
end

local function available()
	return localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("EquippedKnife") == "GhostScythe" and localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("RunState") == "Active" and (localPlayer:GetAttribute("GameRole") == "Runner" or localPlayer:GetAttribute("GameRole") == "Catcher") and not (session:GetAttribute("GlobalPaused") or session:GetAttribute("MapChanging"))
end

local now = -1e999

local function request()
	if not available() or ControlGate.reason(localPlayer) or os.clock() - now < 0.5 then
		return
	end

	if (localPlayer:GetAttribute("GhostAbilityReadyAt") or 0) > workspace:GetServerTimeNow() then
		return
	end

	now = os.clock()
	ghostAbilityEvent:FireServer("Activate")
end

on(button.Activated, request) -- equivalent call inferred; original call site unknown
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and (input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.ButtonL1) then
		request()
	end
end))

local function cue(playerByUserId)
	local character = playerByUserId.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://8408521761"
	sound.Volume = 0.35
	sound.RollOffMaxDistance = 100
	sound.Parent = humanoidRootPart
	sound:Play()
	Debris:AddItem(sound, 3)
	local part = Instance.new("Part")
	part.Name = "GhostScythePulse"
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(155, 255, 230)
	part.Transparency = 0.55
	part.Size = createVector(2, 3, 2)
	part.CFrame = CFrame.new(humanoidRootPart.Position)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = workspace
	TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
		Size = createVector(9, 9, 9),
		Transparency = 1
	}):Play()
	Debris:AddItem(part, 0.5)
end

table.insert(connections, ghostAbilityEvent.OnClientEvent:Connect(function(p, value)
	local playerByUserId = p == "Activated" and type(value) == "number" and Players:GetPlayerByUserId(value)

	if playerByUserId then
		cue(playerByUserId)
	end
end))
local total = 0
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
	local v3 = math.max(0, (math.ceil((localPlayer:GetAttribute("GhostAbilityReadyAt") or 0) - serverTimeNow)))
	local v4 = serverTimeNow < (localPlayer:GetAttribute("GhostImmuneUntil") or 0)
	text.Text = v4 and "GHOSTED" or not (v3 > 0) and "GHOST" or string.format("%d:%02d", math.floor(v3 / 60), v3 % 60) or "GHOST"
	text2.Text = v4 and "IMMUNE · 2 SECONDS" or v3 > 0 and "RECHARGING" or UserInputService.TouchEnabled and "TAP TO FADE" or UserInputService.GamepadEnabled and "L1 / FADE" or "R / FADE"
	button.BackgroundTransparency = v3 > 0 and 0.5 or 0.15
	v2.Size = UDim2.fromScale(math.clamp(1 - v3 / 45, 0, 1), 1)
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end
end)