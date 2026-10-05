local ControlGate = require(script.Parent:WaitForChild("ControlGate"))
local BoostInput = {}
local now = nil
local v = nil

function BoostInput.request(p)
	now = os.clock()
	v = p == true
end

function BoostInput.clear()
	now = nil
	v = nil
end

function BoostInput.consume()
	local v2 = now
	local v3 = v
	BoostInput.clear()
	return v2 ~= nil and os.clock() - v2 <= 0.15, v3 == true
end

function BoostInput.available(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return player:GetAttribute("GameRole") ~= "Catcher" and humanoid ~= nil and humanoid.Health > 0 and humanoidRootPart ~= nil and not (humanoidRootPart.Anchored or humanoid.Sit or humanoid.PlatformStand) and not (character:GetAttribute("MovementLocked") or character:GetAttribute("TackleActive")) and ControlGate.movementReason(player) == nil
end

function BoostInput.control()
	local preferredInput = game.UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Touch then
		return "Tap DASH"
	end

	if preferredInput == Enum.PreferredInput.Gamepad then
		return "RT / R2"
	end

	return "Space"
end

return BoostInput