local createVector = vector.create
local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.RocksModule)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local flyingKick = FX:WaitForChild("Phoenix1").FlyingKick

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.27, Enum.EasingStyle.Sine),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine),
	TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local humanoidRootPart = player.Character.HumanoidRootPart
	local cFrame = player.CFrame
	local time = player.Time
	local _ = player.Length

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	Util.Sound:Play("PhoenixKickStart", humanoidRootPart)
	local dash = flyingKick.Dash
	local clone = dash:Clone()
	clone.Name = clone.Name

	if dash:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = _WorldOrigin
	local _ = clone.EndDash
	local dash2 = clone.Dash
	dash2:GetDescendants()
	dash2.Weld:Destroy()
	dash2.Anchored = true
	Debris:AddItem(clone, time + 2)

	for _, emitter in pairs(dash2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local speed = emitter.Speed
		emitter.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
		local acceleration = emitter.Acceleration
		emitter.Acceleration = Vector3.new(acceleration.X * 4, acceleration.Y * 4, acceleration.Z * 4)
		emitter.Rate *= 2
	end

	local cFrame3 = cFrame * CFrame.Angles(0, 1.57, 1.57)
	local color1 = flyingKick.Color1
	local clone2 = color1:Clone()
	clone2.Name = clone2.Name

	if color1:IsA("Model") then
		clone2:SetPrimaryPartCFrame(cFrame3)
	else
		clone2.CFrame = cFrame3
	end

	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 0.5)
	TweenService:Create(clone2, v[1], {
		Size = clone2.Size * 5,
		CFrame = clone2.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, 3.14, 0),
		Transparency = 1
	}):Play()
	local flag = true
	resume(create(function()
		local cFrame2 = humanoidRootPart.CFrame
		local dust = flyingKick.Dust
		local clone3 = dust:Clone()
		clone3.Name = clone3.Name

		if dust:IsA("Model") then
			clone3:SetPrimaryPartCFrame(cFrame2)
		else
			clone3.CFrame = cFrame2
		end

		clone3.Parent = _WorldOrigin

		while flag do
			local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
			local part, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })

			if part then
				clone3.Smoke.Color = ColorSequence.new(part.Color)
				clone3.Rocks.Color = ColorSequence.new(part.Color)
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 1.57, 0)
				clone3.Smoke.Enabled = true
				clone3.Rocks.Enabled = true
			else
				clone3.Smoke.Enabled = false
				clone3.Rocks.Enabled = false
			end

			dash2.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + cFrame.LookVector)
			task.wait()
		end

		for _, child in pairs(clone3:GetChildren()) do
			child.Enabled = false
		end

		Debris:AddItem(clone3, 2)
	end))
	task.delay(0.025, function()
		for i = 1, 6, 5 do
			local cFrame2 = cFrame * CFrame.new(0, 1, i * -5) * CFrame.Angles(0, 1.57, 1.57)
			local shockwave = flyingKick.Shockwave
			local clone3 = shockwave:Clone()
			clone3.Name = clone3.Name

			if shockwave:IsA("Model") then
				clone3:SetPrimaryPartCFrame(cFrame2)
			else
				clone3.CFrame = cFrame2
			end

			clone3.Parent = _WorldOrigin
			Debris:AddItem(clone3, 0.5)

			if i == 1 then
				TweenService:Create(clone3, v[2], {
					CFrame = clone3.CFrame * CFrame.new(0, -10, 0),
					Size = Vector3.new(clone3.Size.X * 4, 0, clone3.Size.Z * 4),
					Transparency = 1
				}):Play()
			else
				TweenService:Create(clone3, v[2], {
					CFrame = clone3.CFrame * CFrame.new(0, -10, 0),
					Size = Vector3.new(clone3.Size.X * 2.5, 0, clone3.Size.Z * 2.5),
					Transparency = 1
				}):Play()
			end
		end
	end)
	task.wait(time)
	flag = false

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Beam") then
			TweenService:Create(effect, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end
end