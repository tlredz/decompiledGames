local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("ServerScriptService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3(script.Parent["Wind Cloak"])
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local SuperJump = {}
SuperJump.cooldown = 8
SuperJump.cooldownReductionPerUpgrade = 1
SuperJump.iconId = "rbxassetid://14021421360"

function SuperJump.canBeUsed(p)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = "Players"

	if workspace:Spherecast(p.character:GetPivot().Position, 1.25, createVector(0, 20, 0), raycastParams) then
		return false
	end

	return true
end

function SuperJump.localOwnerActivation(data)
	data.animator:LoadAnimation(script.SuperJumpAnimation):Play()
	data.rootPart.AssemblyLinearVelocity = createVector(0, 1, 0) * (200 + data.upgradeLevel * 25)

	if RunService:IsClient() then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
			{
				FieldOfView = workspace.CurrentCamera.FieldOfView * 1.2
			}
		):Play()
	end

	return nil
end

function SuperJump.anyClientActivationAsync(p)
	local clone = ReplicatedStorage2.Misc.SuperJump:Clone()
	clone.Parent = workspace.Runtime
	clone.CFrame = p.rootPart.CFrame
	clone.Parent = p.rootPart
	clone.WeldConstraint.Part1 = p.rootPart
	clone.Jump:Play()

	if p.upgradeLevel >= 2 then
		clone.Wind.PlaybackSpeed = 1
		clone.OniCharge:Play()
	end

	clone.Wind:Play()
	Debris:AddItem(clone, 4)
	local color = Color3.new(1, 1, 1)

	if p.upgradeLevel >= 2 then
		color = Color3.new(0, 1, 1)
	end

	for i = 1, 5 do
		v({
			cframe = p.rootPart.CFrame,
			diameter = i == 1 and 30 or 15,
			color = color,
			orientation = "Vertical"
		})
		task.wait(0.1)
	end
end

function SuperJump.serverActivationAsync(_) end

return SuperJump