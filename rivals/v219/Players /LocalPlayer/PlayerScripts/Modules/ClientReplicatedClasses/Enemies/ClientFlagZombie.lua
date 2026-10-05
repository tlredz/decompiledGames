local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
local flagZombieEmpoweredEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc.FlagZombieEmpoweredEffect
local zombieFlag = Players.LocalPlayer.PlayerScripts.Assets.Misc.ZombieFlag
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self._dropped_flags = {}
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p == "DropFlagEffect" then
		if not object2:IsRendered() then
			return
		end

		local v, v2 = ...
		local clone = zombieFlag:Clone()
		clone:PivotTo(CFrame.new(v) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0))
		clone.Parent = workspace
		BetterDebris:AddItem(clone, 30)

		for _, emitter in pairs(clone.Effect:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Utility:ScaleParticleEmitter(emitter, v2 / 25)
			end
		end

		task.spawn(function()
			for _ = 1, 3 do
				Utility:PlayParticles(clone)
				wait(0.25)
			end
		end)
		Utility:CreateSound("rbxassetid://98975031346830", 1, 0.9 + 0.2 * math.random(), clone.PrimaryPart, true, 10)
		local pivot = clone:GetPivot()
		local cframe = CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		local scale = clone:GetScale()
		local v3 = scale * 0.5
		local effect = clone.Effect
		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			local v4 = 1 - (1 - p2 / 100) ^ 3
			clone:ScaleTo(v3 + (scale - v3) * v4)
			clone:PivotTo(pivot * CFrame.Angles(0, 0 + 9.42477796076938 * v4, 0) * cframe:Lerp(CFrame.identity, v4))
			effect.CFrame = CFrame.new(effect.Position)
		end)
		wait(15)
		Utility:RenderstepForLoop(0, 100, 1, function(p2)
			local localTransparencyModifier = (p2 / 100) ^ 3

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = localTransparencyModifier
				end
			end
		end)
		clone:Destroy()
	else
		if p ~= "EmpowerOtherEntityEffect" then
			ClientEnemy.ReplicateFromServer(object2, p, ...)
			return
		end

		if not object2:IsRendered() then
			return
		end

		local v, v2 = ...

		if not v then
			return
		end

		wait(1 * math.random())
		Utility:CreateSound(
			"rbxassetid://104302486797762",
			0.5 + 0.5 * math.random(),
			0.75 + 0.5 * math.random(),
			v,
			true,
			10
		)
		local clone = flagZombieEmpoweredEffect:Clone()
		clone.CFrame = v.CFrame * CFrame.new(0, -2, 0)
		clone.Parent = v
		BetterDebris:AddItem(clone, v2 + 10)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = v
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone
		wait(v2)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		wait(3)
		clone:Destroy()
	end
end

function object:Destroy()
	for _, _dropped_flag in pairs(self._dropped_flags) do
		_dropped_flag:Destroy()
	end

	ClientEnemy.Destroy(self)
end

function object:_Init() end

return object