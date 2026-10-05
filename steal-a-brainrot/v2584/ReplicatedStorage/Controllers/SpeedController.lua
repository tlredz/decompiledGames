local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local CharacterController = require(controllers.CharacterController)
local localPlayer = Players.LocalPlayer
local SpeedController = {}

function SpeedController.GetCurrentJumpHeight(_)
	local characterJumpHeight = StarterPlayer.CharacterJumpHeight
	local character, _, _ = CharacterController:GetCharacter()

	if not character then
		return 0
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		local jumpModifier = tool:GetAttribute("JumpModifier")

		if jumpModifier then
			characterJumpHeight *= jumpModifier
		end
	end

	if localPlayer:GetAttribute("Stealing") then
		characterJumpHeight *= 0.6
	end

	return (math.clamp(characterJumpHeight, 0, 1e999))
end

function SpeedController.GetCurrentWalkSpeed(_)
	local characterWalkSpeed = StarterPlayer.CharacterWalkSpeed
	local character, _, _ = CharacterController:GetCharacter()

	if not character then
		return 0
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		local speedModifier = tool:GetAttribute("SpeedModifier")

		if speedModifier then
			characterWalkSpeed *= speedModifier
		end
	end

	if localPlayer:GetAttribute("Stealing") then
		characterWalkSpeed *= 0.6
	end

	return (math.clamp(characterWalkSpeed, 0, 1e999))
end

function SpeedController.Start(_) end

return SpeedController