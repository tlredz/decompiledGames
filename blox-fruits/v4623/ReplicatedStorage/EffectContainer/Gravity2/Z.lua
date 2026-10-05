local createVector = vector.create
game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
local _ = workspace._WorldOrigin

for _, emitter in pairs(script.Grass:GetChildren()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Time = 0,
			Scale = 1.75
		})
	end
end

for _, emitter in pairs(script.gravitypush:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Time = 0,
			Scale = 1.75
		})
	end
end

for _, emitter in pairs(script.Part:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Time = 0,
			Scale = 1.75
		})
	end
end

return function(player)
	local character = player.Character
	local cFrame = player.CFrame
	local humanoidRootPart = character.HumanoidRootPart

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	local clone = script.gravitypush:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 0, -5)
	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	if character == game.Players.LocalPlayer.Character then
		Effect.new("ShakeCam"):replicate({
			3,
			20,
			0.1,
			1,
			createVector(1, 1, 1),
			createVector(1, 1, 4)
		})
	end

	Util.Sound:Play("GravityZ", humanoidRootPart)
	clone.Orientation += createVector(0, 90, -90)
	Debris:AddItem(clone, 3)
	resume(create(function()
		for _ = 1, 2 do
			local clone2 = script.Ring1:Clone()
			clone2.CFrame = cFrame
			clone2.Orientation += createVector(0, -90, 90)
			clone2.Parent = _WorldOrigin
			Debris:AddItem(clone2, 3)
			TweenService:Create(clone2, tweenInfo3, {
				Size = createVector(35, 0.679, 35),
				Transparency = 1
			}):Play()
			wait(0.2)
		end
	end))
	resume(create(function()
		for _ = 1, 2 do
			local clone2 = script.Shockwave1:Clone()
			clone2.CFrame = cFrame
			clone2.Orientation += createVector(90, -90, 0)
			clone2.Parent = _WorldOrigin
			Debris:AddItem(clone2, 3)
			TweenService:Create(clone2, tweenInfo, {
				Size = createVector(31.698, 21.021, 20.245),
				Transparency = 1
			}):Play()
			wait(0.2)
		end
	end))
	resume(create(function()
		for _ = 1, 2 do
			local clone2 = script.shockwave2:Clone()
			clone2.CFrame = cFrame * CFrame.new(0, 0, -1)
			clone2.Orientation += createVector(90, 0, 0)
			clone2.Parent = _WorldOrigin
			Debris:AddItem(clone2, 3)
			TweenService:Create(clone2, tweenInfo, {
				Size = createVector(31.698, 9.607, 31.698),
				Transparency = 1
			}):Play()
			wait(0.2)
		end
	end))
	local total = 3
	local total2 = 0.005
	local position2 = cFrame * createVector(0, 0, -90)
	local clone2 = script.Part:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	TweenService:Create(clone2, tweenInfo2, {
		Position = position2
	}):Play()
	Debris:AddItem(clone2, 3)
	local raycastResult = workspace:Raycast(
		clone2.CFrame * CFrame.new(0, -2.5, 0).Position,
		createVector(0, -15, 0),
		raycastParams
	)

	if raycastResult then
		local instance = raycastResult.Instance
		local position = raycastResult.Position
		local clone3 = script.Grass:Clone()
		clone3.CFrame = CFrame.new(position)
		clone3.Orientation = humanoidRootPart.Orientation + createVector(0, 180, 0)
		clone3.Grass2.Color = ColorSequence.new(instance.Color)
		clone3.Smoke.Color = ColorSequence.new(instance.Color)
		clone3.Parent = _WorldOrigin
		Debris:AddItem(clone3, 3)
		task.delay(0.4, function()
			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end

	coroutine.wrap(function()
		for i = 1, 11 do
			local raycastResult2 = workspace:Raycast(
				clone2.CFrame * CFrame.new(-14 - i, 0, 0).Position,
				createVector(0, -15, 0),
				raycastParams
			)
			local raycastResult3 = workspace:Raycast(
				clone2.CFrame * CFrame.new(i + 14, 0, 0).Position,
				createVector(0, -15, 0),
				raycastParams
			)

			if raycastResult2 then
				local instance = raycastResult2.Instance
				local position = raycastResult2.Position
				local part = Instance.new("Part")
				part.CFrame = CFrame.new(position) * CFrame.Angles(
					math.random(-5, 5),
					math.random(-5, 5),
					math.random(-5, 5)
				)
				part.Material = instance.Material
				part.Color = instance.Color
				part.Size = Vector3.new()
				part.CanCollide = false
				part.Anchored = true
				part.Parent = _WorldOrigin
				TweenService:Create(part, TweenInfo.new(0.3), {
					Size = createVector(2.162, 4.62, 11.558)
				}):Play()
				coroutine.wrap(function()
					wait(2)
					local tween = TweenService:Create(part, TweenInfo.new(0.3), {
						Size = Vector3.new()
					})
					tween:Play()
					tween:Destroy()
					Debris:AddItem(part, 0.35)
				end)()
			end

			if raycastResult3 then
				local instance = raycastResult3.Instance
				local position = raycastResult3.Position
				local part = Instance.new("Part")
				part.CFrame = CFrame.new(position) * CFrame.Angles(
					math.random(-5, 5),
					math.random(-5, 5),
					math.random(-5, 5)
				)
				part.Material = instance.Material
				part.Color = instance.Color
				part.Size = Vector3.new()
				part.CanCollide = false
				part.Anchored = true
				part.Parent = _WorldOrigin
				TweenService:Create(part, TweenInfo.new(0.3), {
					Size = createVector(2.162, 4.62, 11.558)
				}):Play()
				coroutine.wrap(function()
					wait(2)
					TweenService:Create(part, TweenInfo.new(0.3), {
						Size = Vector3.new()
					}):Play()
					wait(0.35)
					part:Destroy()
				end)()
			end

			total += 2.5
			task.wait(total2)
			total2 += 0.004
		end
	end)()
end