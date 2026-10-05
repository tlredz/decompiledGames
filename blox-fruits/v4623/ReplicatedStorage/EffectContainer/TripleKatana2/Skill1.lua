local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skill1 = FX:WaitForChild("TripleKatana").Skill1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local parent = _WorldOrigin
	local skill = skill1
	local dir = data.dir
	local index = data.index

	if index == 1 then
		local clone = skill.Start:Clone()
		clone.CFrame = dir
		clone.Parent = parent
		destroyAfter(clone, 4)
	end

	local projectileRange = data.projectileRange
	local projectileFliesFor = data.projectileFliesFor
	Util.Sound:Play("KiBlastFireShort", hrp)
	local clone = skill.Slash:Clone()
	local clone2, v3

	if index == 1 then
		clone.CFrame = dir * CFrame.Angles(0, 0, 1.3962634015954636)
		clone2 = skill.Slash1:Clone()
		clone2.CFrame = dir * CFrame.new(-4, 0, -2)
		TweenService:Create(clone2.Attachment, TweenInfo.new(0.2), {
			Position = createVector(10, 0, 0)
		}):Play()
	elseif index == 2 then
		clone.CFrame = dir * CFrame.Angles(0, 0, -0.08726646259971647)
		clone2 = skill.Slash2:Clone()
		clone2.CFrame = dir * CFrame.new(0, 0, -2)
		TweenService:Create(clone2.Attachment, TweenInfo.new(0.2), {
			Position = createVector(0, 10, 0)
		}):Play()
	else
		if index == 3 then
			clone.CFrame = dir * CFrame.Angles(0, 0, 1.3962634015954636)
			clone2 = skill.Slash1:Clone()
			clone2.CFrame = dir * CFrame.new(-4, -1, -2)
		else
			clone.CFrame = dir * CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, 1.3962634015954636)
			clone2 = skill.Slash1:Clone()
			clone2.CFrame = dir * CFrame.new(-4, 2, -2)
		end

		TweenService:Create(clone2.Attachment, TweenInfo.new(0.2), {
			Position = createVector(10, 0, 0)
		}):Play()
	end

	v3 = TweenService:Create(
		clone,
		TweenInfo.new(projectileFliesFor, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -projectileRange) * CFrame.Angles(0, 0, -0.17453292519943295)
		}
	)
	clone.Parent = parent
	destroyAfter(clone, 5)

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
		elseif effect:IsA("Beam") then
			local tween = TweenService:Create(
				effect,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Width0 = effect.Width0,
					Width1 = effect.Width1
				}
			)
			effect.Width0 = 0
			effect.Width1 = 0
			tween:Play()
		end
	end

	local clone3 = skill.Start:Clone()
	clone3.CFrame = dir * CFrame.new(0, 1.5, 0) * CFrame.new(0, 3, 0)
	clone3.Parent = parent
	destroyAfter(clone3, 4)
	clone2.Parent = parent
	destroyAfter(clone2, 2)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	v3:Play()
	coroutine.wrap(function()
		v3.Completed:Wait()

		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.05), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		local clone4 = skill.End:Clone()
		clone4.CFrame = clone.CFrame
		clone4.Parent = parent
		destroyAfter(clone4, 3)

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
end