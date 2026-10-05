local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TouchActionButton = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("TouchActionButton"))
local localPlayer = game.Players.LocalPlayer
local BoostInput = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero").Movement:WaitForChild("BoostInput"))
local boostButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("BoostButton")

local function request(p)
	if not BoostInput.available(localPlayer) then
		return false
	end

	BoostInput.request(p)
	return true
end

ContextActionService:BindAction("CoHBoost", function(_, p)
	if not BoostInput.available(localPlayer) then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin and BoostInput.available(localPlayer) then
		BoostInput.request(nil)
	end

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonR2)
local connection = TouchActionButton.bind(boostButton, request)
local total = 0
local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total < 0.08 then
		return
	end

	total = 0
	local available = BoostInput.available(localPlayer)
	local character = localPlayer.Character
	local v = math.max(0, (character and character:GetAttribute("DashCooldownUntil") or 0) - os.clock())
	TouchActionButton.update(boostButton, available, v, "DASH")
end)
script.Destroying:Connect(function()
	BoostInput.clear()
	ContextActionService:UnbindAction("CoHBoost")
	connection:Disconnect()
	renderSteppedConnection:Disconnect()
	boostButton.Visible = false
end)