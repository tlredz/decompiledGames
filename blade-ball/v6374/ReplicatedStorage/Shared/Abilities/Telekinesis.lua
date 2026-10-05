local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Debris")
game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3("@game/ReplicatedStorage/Types/Templates")
local v2 = {}

function captureBall(instance, character)
	if v2[instance] and v2[instance].controller == character then
		return
	end

	if v2[instance] then
		releaseBall(instance)
	end

	v2[instance] = {
		controller = character,
		velocityMappingId = instance.AddCustomVelocityMapping:Invoke(script.TelekinesisSimMapping),
		accelerationMappingId = instance.AddCustomAccelerationMapping:Invoke(script.TelekinesisSimMapping)
	}
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local clone

	if playerFromCharacter and playerFromCharacter.Upgrades.Telekinesis.Value == 2 then
		clone = ReplicatedStorage2.Misc.MaxTelekinesis2:Clone()
	else
		clone = ReplicatedStorage2.Misc.Telekinesis2:Clone()
	end

	local at2 = clone.At2
	at2.Parent = instance.Body
	clone.Position = instance:GetPivot().Position

	for _, child in pairs(at2:GetChildren()) do
		local v3 = child
		task.spawn(function()
			task.wait(2)
			v3.Enabled = false
		end)
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 4)
	v2[instance].at2 = at2
end

function releaseBall(p)
	if not v2[p] then
		return
	end

	local v3 = v2[p]
	p.RemoveCustomVelocityMapping:Invoke(v3.velocityMappingId)
	p.RemoveCustomAccelerationMapping:Invoke(v3.accelerationMappingId)
	v2[p] = nil
	v3.at2.SHOCK:Emit(2)
	v3.at2.blus:Emit(50)
	task.delay(5, function()
		v3.at2:Destroy()
	end)
end

function getPointingAt(instance, items)
	local characterCollider = instance:FindFirstChild("CharacterCollider")

	if not characterCollider then
		return
	end

	local value = characterCollider.Pointer.Value
	local v3 = nil
	local v4 = nil

	for _, item in items do
		local dot = value.Direction.Unit:Dot((item:GetPivot().Position - value.Origin).Unit)

		if not (v3 == nil or dot < v4) then
			continue
		end

		v4 = dot
		v3 = item
	end

	return v3
end

local Telekinesis = {}
Telekinesis.iconId = "rbxassetid://14520967276"
Telekinesis.cooldown = 23
Telekinesis.cooldownReductionPerUpgrade = 2.875

function Telekinesis.canBeUsed(p)
	if v.GetCharacterTargetBall(p.character) then
		return true
	end

	return false
end

function Telekinesis.validateArguments(p, _)
	assert(typeof(p) == "table", "Bad arguments")
	assert(typeof(p.targetCharacter) == "Instance", "Bad targetCharacter")
	assert(p.targetCharacter.Parent == workspace.Alive, "Not an alive character")
end

function Telekinesis.localOwnerActivation(p)
	return {
		targetCharacter = v.GetCharacterTargetCharacter(p.character)
	}
end

function Telekinesis.serverActivationAsync(p, _, p2)
	if not p2.targetCharacter then
		return
	end

	local children = workspace.Balls:GetChildren()

	for _, v3 in next, children, nil do
		captureBall(v3, p.character)
		v3.TargetCharacter:Invoke(nil)
	end

	task.wait(1.8)

	for _, v3 in next, children, nil do
		v3.TargetCharacter:Invoke(p2.targetCharacter)
		releaseBall(v3)
		v3.SetSpeed:Invoke(v3.GetSpeed:Invoke() + 40 + 34 * (p.upgradeLevel / 2))
	end
end

return Telekinesis