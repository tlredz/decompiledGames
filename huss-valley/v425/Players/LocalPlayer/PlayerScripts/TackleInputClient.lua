local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ControlGate = require(chickenOrHero:WaitForChild("Movement"):WaitForChild("ControlGate"))
local TacklePrediction = require(chickenOrHero:WaitForChild("Game"):WaitForChild("TacklePrediction"))
local TouchActionButton = require(chickenOrHero:WaitForChild("Presentation"):WaitForChild("TouchActionButton"))
local catchButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("CatchButton")

local function available()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return localPlayer:GetAttribute("GameRole") == "Catcher" and localPlayer:GetAttribute("RunState") == "Active" and humanoid ~= nil and humanoid.Health > 0 and not humanoid.Sit and not (humanoid.PlatformStand or character:GetAttribute("MovementLocked")) and ControlGate.reason(localPlayer) == nil
end

local function remaining()
	return TacklePrediction.remaining()
end

local function request()
	if not available() or TacklePrediction.remaining() > 0.02 then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and not (humanoidRootPart.Anchored or character:GetAttribute("TackleActive")) then
		TacklePrediction.request()
	end
end

ContextActionService:BindAction("CoHTackle", function(_, p)
	if not available() then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin then
		request()
	end

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Space, Enum.KeyCode.E, Enum.KeyCode.ButtonR2)
local connection = TouchActionButton.bind(catchButton, request)
local total = 0
local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total < 0.08 then
		return
	end

	total = 0
	TouchActionButton.update(catchButton, available(), TacklePrediction.remaining(), "CATCH")
end)
script.Destroying:Connect(function()
	ContextActionService:UnbindAction("CoHTackle")
	connection:Disconnect()
	renderSteppedConnection:Disconnect()
	catchButton.Visible = false
end)