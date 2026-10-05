local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local v = {}

local function release(state)
	if not (state.active and state.ball.Parent) then
		return
	end

	table.remove(v, table.find(v, state))
	state.active = false
	state.ball.RemoveCustomVelocityMapping:Invoke(state.velocityMappingId)
	state.ball.RemoveCustomAccelerationMapping:Invoke(state.accelerationMappingId)
	state.ball.SetSpeed:Invoke(state.ball.GetSpeed:Invoke() + 20 + state.upgradeLevel * 17 / 2)
	local clone = script.SHYANNER:Clone()
	clone.Parent = state.ball.PrimaryPart
	clone:Play()
	Debris:AddItem(clone, 3)

	for _, child in state.shatterEffect:GetChildren(), nil, nil do
		child:Emit((tonumber(child.Name)))
	end

	for _, child in state.freezeEffect:GetChildren(), nil, nil do
		child.Enabled = false
	end
end

if RunService:IsServer() then
	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		child.Parried.Event:Connect(function()
			for _, v2 in table.clone(v) do
				if v2.ball == child then
					release(v2)
				end
			end
		end)
		child.AddCustomCollisionResponse:Invoke(script.FreezeCollisionResponse, -5)
	end)

	function script.FreezeCollisionResponse.OnInvoke(_, _, p)
		for _, v2 in v do
			if v2.ball == p and v2.active then
				return "CancelAndInvalidate"
			end
		end

		return "Continue"
	end
end

local Freeze = {}
Freeze.cooldown = 35
Freeze.cooldownReductionPerUpgrade = 7
Freeze.iconId = "rbxassetid://14852741510"

function Freeze.validateArguments(p)
	assert(typeof(p) == "table", "Bad arguments")
	assert(typeof(p.affectedBalls) == "table", "Bad affectedBalls")

	for _, affectedBall in p.affectedBalls do
		assert(typeof(affectedBall) == "Instance", "Bad ball")
	end
end

function Freeze.localOwnerActivation(_)
	local v2 = {
		affectedBalls = {}
	}

	for _, child in workspace.Balls:GetChildren() do
		table.insert(v2.affectedBalls, child)
	end

	return v2
end

function Freeze.serverActivationAsync(p, _, p2)
	local clone = script.IceCharge:Clone()
	clone.Parent = p.character:FindFirstChild("Torso")
	clone:Emit(35)
	Debris:AddItem(clone, 3)
	local v2 = {}

	for _, affectedBall in p2.affectedBalls do
		if affectedBall.Parent ~= workspace.Balls then
			continue
		end

		local clone2

		if p.upgradeLevel >= 2 then
			clone2 = script.MaxFreezeFX:Clone()
		else
			clone2 = script.FreezeFX:Clone()
		end

		clone2.Parent = workspace.Runtime
		Debris:AddItem(clone, 8.5)
		local shotternus = clone2.Shotternus
		local shatters = clone2.Shatters
		shotternus.Parent = affectedBall.PrimaryPart
		shatters.Parent = affectedBall.PrimaryPart
		Debris:AddItem(shotternus, 8.5)
		Debris:AddItem(shatters, 8.5)
		local clone3 = script.FREEZER:Clone()
		clone3.Parent = affectedBall.PrimaryPart
		clone3:Play()
		Debris:AddItem(clone3, 5)
		local v3 = {
			velocityMappingId = affectedBall.AddCustomVelocityMapping:Invoke(script.FreezeSimMapping, 100),
			accelerationMappingId = affectedBall.AddCustomAccelerationMapping:Invoke(script.FreezeSimMapping, 100),
			ball = affectedBall,
			controller = p.character,
			active = true,
			upgradeLevel = p.upgradeLevel,
			freezeEffect = shotternus,
			shatterEffect = shatters
		}
		table.insert(v, v3)
		table.insert(v2, v3)
	end

	task.wait(5.5)

	for _, v3 in v2 do
		release(v3)
	end
end

return Freeze