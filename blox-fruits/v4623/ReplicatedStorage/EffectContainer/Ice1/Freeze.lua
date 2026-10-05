local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local freeze = FX:WaitForChild("IceEffects").Freeze
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = { TweenInfo.new(0.2, Enum.EasingStyle.Linear) }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, cube, p)
	local clone = cube:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

return function(state)
	local char = state.char
	local root = state.root

	if char:FindFirstChildOfClass("Humanoid") == nil or root == nil or (root.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	state.duration = state.duration or 0.8
	local effect = createEffect(root.CFrame, freeze.Cube) -- equivalent call inferred; original call site unknown
	effect.Size *= root.Size.Y / 2
	effect.Weld.Part0 = root
	destroyAfter(effect, state.duration)
	Util.Sound:Play("Ice_freeze", root.Position)
	task.delay(state.duration * 0.8, function()
		effect.Material = Enum.Material.Neon
		effect.Color = Color3.new(1, 1, 1)
		TweenService:Create(effect, v[1], {
			Transparency = 1,
			Size = effect.Size * 1.25
		}):Play()
		Util.Sound:Play("Ice_unfreeze", root.Position)
	end)

	for _, child in ipairs(freeze.Particles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = char:FindFirstChild("UpperTorso") or root
		clone:Emit(clone:GetAttribute("EmitCount"))
		local speed = clone.Speed
		local v2 = root.Size.Y / 1.5
		clone.Speed = NumberRange.new(speed.Min * v2, speed.Max * v2)
		scaleParticle({
			Emitter = clone,
			Scale = root.Size.Y / 2,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Sine,
			EasingDirection = Enum.EasingDirection.Out
		})
		destroyAfter(clone, state.duration * 0.75)
	end
end