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
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = {}
local v3 = {}
local v4 = {}

local function captureBall(child, p)
	if v2[p] and v2[p][child] then
		return
	end

	v2[p][child] = child.AddCustomVelocityMapping:Invoke(script.InfinityVelocityMapping)

	if v3[child] then
		return
	end

	v3[child] = true
	local clone = script.InfinityBallFX.WEMAZOOKIEGO:Clone()
	clone.Parent = child.Body
	v4[child] = clone
	Debris:AddItem(clone, 15)
end

local function releaseBall(p, p2)
	if not (v2[p2] and v2[p2][p]) then
		return
	end

	p.RemoveCustomVelocityMapping:Invoke(v2[p2][p])
	v2[p2][p] = nil

	for _, v5 in v2 do
		if v5[p] then
			return
		end
	end

	v3[p] = nil
	v4[p]:Destroy()
	v4[p] = nil
	local clone = script.InfinityBallFX.ZOOKIEZA:Clone()
	clone.Parent = p.Body
	clone.shockwave:Emit(3)
	Debris:AddItem(clone, 2)
end

if RunService:IsServer() then
	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		local function onTarget()
			for ancestor, v5 in v2 do
				if child.TargetAttachment.Value and child.TargetAttachment.Value:IsDescendantOf(ancestor) then
					captureBall(child, ancestor)
				elseif v5[child] then
					releaseBall(child, ancestor)
				end
			end
		end

		child.TargetAttachment.Changed:Connect(onTarget)
		onTarget()
		child.AddCustomCollisionResponse:Invoke(script.InfinityCollisionResponse, -5)
	end)

	function script.InfinityCollisionResponse.OnInvoke(p, _, p2)
		if v2[p] and v2[p][p2] then
			return "CancelAndInvalidate"
		end

		return "Continue"
	end
end

return {
	cooldown = 28,
	iconId = "rbxassetid://14852765927",
	serverActivationAsync = function(p, p2)
		local flag = false
		local playerFromCharacter = Players:GetPlayerFromCharacter(p.character)

		if playerFromCharacter then
			local playerDS = require3(ServerScriptService.Game.CoreGameModules.Datastore).getPlayerDS(playerFromCharacter)
			flag = playerDS and playerDS.Data and playerDS.Data.OriginalInfinityOwner and true or false
		end

		task.spawn(function()
			v2[p.character] = {}

			for _, child in workspace.Balls:GetChildren() do
				if child.GetTargetCharacter:Invoke() == p.character then
					captureBall(child, p.character)
				end
			end

			task.wait(10)

			for k in next, v2[p.character] or {}, nil do
				releaseBall(k, p.character)
			end

			v2[p.character] = nil
			p2.clearAllCleaners()
		end)
		local part = Instance.new("Part")
		part.Name = "Parry"
		part.Transparency = 1
		part.Massless = true
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(21.875, 21.875, 21.875)
		part.CollisionGroup = "GameplayColliders"
		part.CanCollide = false
		part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
		part.RootPriority = -127
		local weld = Instance.new("Weld")
		weld.Part0 = p.rootPart
		weld.Part1 = part
		weld.Parent = part
		part.Parent = p.character
		p2.addCleaner(function()
			if v2[p.character] then
				for k in v2[p.character] do
					releaseBall(k, p.character)
				end
			end

			v2[p.character] = nil
			part:Destroy()
		end)
		local color

		if flag then
			color = Color3.fromRGB(255, 229, 124)
		else
			color = Color3.fromRGB(70, 95, 255)
		end

		v({
			cframe = p.rootPart.CFrame,
			color = color,
			diameter = 30
		})
		local clone

		if flag then
			clone = script.TrueInfinityFX:Clone()
		else
			clone = script.InfinityFX:Clone()
		end

		clone.Parent = workspace.Runtime
		Debris:AddItem(clone, 12)
		p2.addCleaner(clone)

		for _, sound in clone:GetChildren() do
			if sound.Name == "Brum" then
				sound.Parent = p.character:FindFirstChild("Torso")
			else
				sound.Parent = p.character:FindFirstChild(sound.Name)
			end

			Debris:AddItem(sound)

			if sound:IsA("Sound") then
				sound:Play()
			end

			local instance = sound
			task.delay(10, function()
				if instance:IsA("ParticleEmitter") then
					instance.Enabled = false
				elseif instance:IsA("Attachment") then
					for i, child in instance:GetChildren() do
						if child:IsA("ParticleEmitter") then
							child.Enabled = false
						elseif child:IsA("Sound") then
							TweenService:Create(
								child,
								TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Volume = 0
								}
							):Play()
						elseif child:IsA("Beam") then
							child.Enabled = false
						end
					end
				elseif instance:IsA("Sound") then
					if instance.Name == "Brum" then
						instance:Play()
					else
						TweenService:Create(
							instance,
							TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Volume = 0
							}
						):Play()
					end
				elseif instance:IsA("Beam") then
					instance.Enabled = false
				end
			end)
		end

		task.delay(10, function()
			v({
				cframe = p.rootPart.CFrame,
				color = color,
				diameter = 30
			})
		end)
	end
}