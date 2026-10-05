local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local part = data.Part
	local duration = data.Duration
	local origin = data.Origin
	local size = data.Size
	part.Fire.Enabled = true
	TweenService:Create(part.Mesh, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		Scale = createVector(1, 1, 1) * size
	}):Play()
	TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		CFrame = origin + Vector3.new(0, size / 2, 0)
	}):Play()

	if (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local fireBrush = game.ReplicatedStorage.Assets.Models.FireBrush
	local clone = fireBrush:Clone()
	local clone2 = fireBrush:Clone()
	local clone3 = fireBrush:Clone()
	local clone4 = fireBrush:Clone()
	local clone5 = fireBrush:Clone()
	local clone6 = fireBrush:Clone()
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	clone3.Parent = _WorldOrigin
	clone4.Parent = _WorldOrigin
	clone5.Parent = _WorldOrigin
	clone6.Parent = _WorldOrigin
	local clone7 = game.ReplicatedStorage.Assets.Models.BallWind:Clone()
	clone7:SetPrimaryPartCFrame(part.CFrame)
	local v = {}

	for _, child in pairs(clone7:GetChildren()) do
		v[child] = child.Size / 22
	end

	clone7.Parent = workspace._WorldOrigin
	local lastTime = tick()

	while tick() - lastTime < 0.6 do
		local v2 = math.clamp((tick() - lastTime) / 0.6, 0, 1)
		local v3 = v2 * 720
		local v4 = size * 0.4 + size / 2 * (1 - (v2 * 2 - 1) ^ 2)
		clone.CFrame = origin * CFrame.Angles(0, math.rad(v3), 0) * CFrame.new(0, v2 * size, v4)
		clone2.CFrame = origin * CFrame.Angles(0, math.rad(v3 + 180), 0) * CFrame.new(
			0,
			size * 0.2 + v2 * size * 0.8,
			v4
		)
		clone3.CFrame = origin * CFrame.Angles(0, math.rad(v3 + 180), 0) * CFrame.new(
			0,
			size * 0.1 + v2 * size * 0.9,
			v4
		)
		clone4.CFrame = origin * CFrame.Angles(0, math.rad(v3), 0) * CFrame.new(0, v2 * size, v4)
		clone5.CFrame = origin * CFrame.Angles(0, math.rad(v3), 0) * CFrame.new(0, size * 0.2 + v2 * size * 0.8, v4)
		clone6.CFrame = origin * CFrame.Angles(0, math.rad(v3 + 180), 0) * CFrame.new(
			0,
			size * 0.1 + v2 * size * 0.9,
			v4
		)

		for _, child in pairs(clone7:GetChildren()) do
			child.Size = v[child] * v2 * 11
			child.Transparency = math.max(0, 1 - v2 * 2)
		end

		clone7:SetPrimaryPartCFrame(part.CFrame * CFrame.Angles(0, math.rad(v3) * 1.5, 0))
		RunService.RenderStepped:Wait()
	end

	for _, v2 in pairs({
		clone,
		clone2,
		clone3,
		clone4,
		clone5,
		clone6
	}) do
		v2.Trail.Enabled = false
		v2.Fire.Enabled = false
		local v3 = v2
		coroutine.resume(coroutine.create(function()
			wait(1)
			v3:Destroy()
		end))
	end

	local lastTime2 = tick()

	while part:IsDescendantOf(workspace) do
		local v2 = tick() - lastTime2
		clone7:SetPrimaryPartCFrame(CFrame.new(part.CFrame.p) * (clone7:GetPrimaryPartCFrame() - clone7:GetPrimaryPartCFrame().p) * CFrame.Angles(
			0,
			v2 * 8,
			0
		))
		lastTime2 = tick()
		RunService.RenderStepped:Wait()
	end

	clone7:Destroy()
end