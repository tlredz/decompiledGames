local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ContactCatchConfig = require(chickenOrHero.Game:WaitForChild("ContactCatchConfig"))
local CombatPrediction = require(chickenOrHero.Game:WaitForChild("CombatPrediction"))
CombatPrediction.start()
local ControlGate = require(chickenOrHero.Movement.ControlGate)
local TouchActionButton = require(chickenOrHero.Presentation.TouchActionButton)
local TouchCombatLayout = require(chickenOrHero.Presentation:WaitForChild("TouchCombatLayout"))
local meleeEvent = chickenOrHero.Game:WaitForChild("MeleeEvent")
local meleeInputMode = chickenOrHero.Game:WaitForChild("MeleeInputMode")

-- equivalent calls inferred from this helper; original call sites unknown
local function reportInput()
	meleeInputMode:FireServer(UserInputService.PreferredInput == Enum.PreferredInput.Touch)
end

local preferredInputChangedConnection = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(reportInput)
reportInput() -- equivalent call inferred; original call site unknown
script.Destroying:Connect(function()
	preferredInputChangedConnection:Disconnect()
end)
local HUD = localPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD")
local catchButton = HUD:WaitForChild("CatchButton")
local clone = catchButton:Clone()
clone.Name = "MeleeButton"
clone.Visible = false
clone.Label.Text = "MELEE"
clone.Parent = HUD

for _, v in { clone, catchButton, HUD:FindFirstChild("BoostButton") } do
	if not v then
		continue
	end

	for _, uISizeConstraint in v:GetChildren() do
		if uISizeConstraint:IsA("UISizeConstraint") then
			uISizeConstraint:Destroy()
		end
	end
end

local v = ContactCatchConfig.Windup + ContactCatchConfig.ActiveDuration + ContactCatchConfig.Recovery
local v2 = 0
local v3 = nil
local v4 = 0

local function available()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local enabled = ContactCatchConfig.Enabled

	if not enabled then
		return enabled
	end

	if localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("GameRole") == "Catcher" and localPlayer:GetAttribute("RunState") == "Active" then
		if humanoid then
			if humanoid.Health > 0 then
				enabled = not humanoid.Sit and not humanoid.PlatformStand and humanoidRootPart and not humanoidRootPart.Anchored and not (character:GetAttribute("MovementLocked") or character:GetAttribute("Ragdolled")) and not (character:GetAttribute("TackleActive") or ControlGate.reason(localPlayer) or chickenOrHero.Game.Session:GetAttribute("GlobalPaused") or chickenOrHero.Game.Session:GetAttribute("MapChanging")) and (not character:GetAttribute("DaggerEquipped") or character:GetAttribute("DaggerState") == "Held")
			else
				enabled = false
			end
		else
			enabled = humanoid
		end
	else
		enabled = false
	end

	return enabled
end

local function remaining()
	local character = localPlayer.Character
	local reachStartedAt = character and character:GetAttribute("ReachStartedAt")
	return (math.max(
		0,
		v2 - workspace:GetServerTimeNow(),
		CombatPrediction.meleeRemaining(),
		type(reachStartedAt) ~= "number" and 0 or reachStartedAt + v - workspace:GetServerTimeNow() or 0
	))
end

local function dispatch()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v5 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

	if v5.Magnitude < 0.01 then
		return
	end

	local unit = v5.Unit
	local serverTimeNow = workspace:GetServerTimeNow()
	local HttpService = game:GetService("HttpService")
	local GUID = HttpService:GenerateGUID(false)
	v3 = GUID
	v2 = serverTimeNow + 0.5
	v4 = 0
	meleeEvent:FireServer({
		id = GUID,
		at = serverTimeNow,
		direction = unit,
		position = humanoidRootPart.Position
	})
	CombatPrediction.begin({
		id = GUID,
		kind = "Melee",
		character = character,
		predicted = true,
		startedAt = serverTimeNow,
		starts = serverTimeNow + ContactCatchConfig.Windup,
		ends = serverTimeNow + ContactCatchConfig.Windup + ContactCatchConfig.ActiveDuration,
		direction = unit,
		box = CombatPrediction.meleeBox(character)
	})
end

local function request()
	if not available() then
		return
	end

	if remaining() <= 0 then
		dispatch()
	elseif remaining() <= 0.18 then
		v4 = workspace:GetServerTimeNow() + 0.18
	end
end

local onClientEventConnection = meleeEvent.OnClientEvent:Connect(function(p, p2, p3)
	CombatPrediction.reconcile(p, p2, p3)

	if p ~= v3 then
		return
	end

	v3 = nil
	v2 = 0

	if p2 then
		v4 = 0
	end
end)
local characterAddedConnection = localPlayer.CharacterAdded:Connect(function()
	v3 = nil
	v2 = 0
	v4 = 0
end)
local connection = TouchActionButton.bind(clone, request)
local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and (not gameProcessed or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) then
		if not available() then
			return
		end

		if remaining() <= 0 then
			dispatch()
		elseif remaining() <= 0.18 then
			v4 = workspace:GetServerTimeNow() + 0.18
		end
	end
end)
ContextActionService:BindAction("CoHMelee", function(_, p)
	if UserInputService:GetFocusedTextBox() or not available() then
		return Enum.ContextActionResult.Pass
	end

	if p ~= Enum.UserInputState.Begin or not available() then
		return Enum.ContextActionResult.Sink
	end

	if remaining() <= 0 then
		dispatch()
	elseif remaining() <= 0.18 then
		v4 = workspace:GetServerTimeNow() + 0.18
	end

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.ButtonL2)
local v5 = {
	position = catchButton.Position,
	size = catchButton.Size,
	anchor = catchButton.AnchorPoint
}
local boostButton = HUD:FindFirstChild("BoostButton")
local v6 = boostButton and {
	position = boostButton.Position,
	size = boostButton.Size,
	anchor = boostButton.AnchorPoint
}
local renderSteppedConnection = RunService.RenderStepped:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	if v3 and v2 <= serverTimeNow then
		v3 = nil
		v2 = 0
	end

	if v4 > 0 then
		if v4 < serverTimeNow or not available() then
			v4 = 0
		elseif remaining() <= 0 then
			dispatch()
		end
	end

	TouchActionButton.update(clone, available(), remaining(), "MELEE")

	if UserInputService.TouchEnabled then
		TouchCombatLayout.place("Melee", clone)
		TouchCombatLayout.place("Catch", catchButton)

		if boostButton then
			TouchCombatLayout.place("Catch", boostButton)
		end
	else
		catchButton.Position = v5.position
		catchButton.Size = v5.size
		catchButton.AnchorPoint = v5.anchor

		if boostButton then
			boostButton.Position = v6.position
			boostButton.Size = v6.size
			boostButton.AnchorPoint = v6.anchor
		end
	end
end)
script.Destroying:Connect(function()
	ContextActionService:UnbindAction("CoHMelee")
	connection:Disconnect()
	inputBeganConnection:Disconnect()
	onClientEventConnection:Disconnect()
	characterAddedConnection:Disconnect()
	renderSteppedConnection:Disconnect()
	clone:Destroy()
	catchButton.Position = v5.position
	catchButton.Size = v5.size
	catchButton.AnchorPoint = v5.anchor

	if boostButton then
		boostButton.Position = v6.position
		boostButton.Size = v6.size
		boostButton.AnchorPoint = v6.anchor
	end
end)