local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local debris = Util.Debris

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies }
local v = {
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Linear),
	TweenInfo.new(0.35, Enum.EasingStyle.Quint),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Quad),
	TweenInfo.new(0.1, Enum.EasingStyle.Sine),
	TweenInfo.new(0.4, Enum.EasingStyle.Quart),
	TweenInfo.new(0.6, Enum.EasingStyle.Quad)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone.Parent = p2 or _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
		clone.Parent = p2 or _WorldOrigin
	end

	return clone
end

return function(player)
	local WAIT_INTERVAL = 0.15
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 600 then
		return
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 1.57, 0)
	local slash = script.Slash
	local clone = slash:Clone()
	clone.Name = clone.Name

	if slash:IsA("Model") then
		clone.Parent = _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
	end

	debris:AddItem(clone, 2)
	local ray = Ray.new(humanoidRootPart.Position, createVector(0, -5, 0))
	local part, _, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })

	if part then
		local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		local dust = script.Dust
		local clone2 = dust:Clone()
		clone2.Name = clone2.Name

		if dust:IsA("Model") then
			clone2.Parent = _WorldOrigin
			clone2.PrimaryPart.CFrame = cFrame2
		else
			clone2.CFrame = cFrame2
			clone2.Parent = _WorldOrigin
		end

		debris:AddItem(clone2, 1.5)
		task.delay(0.5, function()
			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end

	Util.Sound:Play("IronMaceX", humanoidRootPart)
	task.wait(WAIT_INTERVAL)
	task.wait(WAIT_INTERVAL)
	task.wait(WAIT_INTERVAL)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(0.1)
	local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 1, -1) * CFrame.Angles(0, 1.57, 0)
	local slash2 = script.Slash2
	local clone2 = slash2:Clone()
	clone2.Name = clone2.Name

	if slash2:IsA("Model") then
		clone2.Parent = _WorldOrigin
		clone2.PrimaryPart.CFrame = cFrame3
	else
		clone2.CFrame = cFrame3
		clone2.Parent = _WorldOrigin
	end

	debris:AddItem(clone2, 1)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.075)

	if character == game.Players.LocalPlayer.Character then
		Util.CameraShaker:ShakeOnce(10, 8, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 5))
		local clone3 = script.Blur:Clone()
		clone3.Parent = game.Lighting
		TweenService:Create(clone3, v[1], {
			Size = 12
		}):Play()
		debris:AddItem(clone3, 1)
	end

	local cFrame4 = humanoidRootPart.CFrame * CFrame.new(0, 3, -9) * CFrame.Angles(0, 0, 1.57)
	local middleShock = script.MiddleShock
	local clone3 = middleShock:Clone()
	clone3.Name = clone3.Name

	if middleShock:IsA("Model") then
		clone3.Parent = _WorldOrigin
		clone3.PrimaryPart.CFrame = cFrame4
	else
		clone3.CFrame = cFrame4
		clone3.Parent = _WorldOrigin
	end

	debris:AddItem(clone3, 1)
	TweenService:Create(clone3, v[3], {
		CFrame = clone3.CFrame * CFrame.new(15, 0, 0)
	}):Play()
	TweenService:Create(clone3.Mesh, v[4], {
		Scale = clone3.Mesh.Scale * createVector(8.1, 0, 0) * 1.5
	}):Play()
	local cFrame5 = humanoidRootPart.CFrame * CFrame.new(0, -1, -9) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		1.57
	)
	local shockwave = script.Shockwave
	local clone4 = shockwave:Clone()
	clone4.Name = clone4.Name

	if shockwave:IsA("Model") then
		clone4.Parent = _WorldOrigin
		clone4.PrimaryPart.CFrame = cFrame5
	else
		clone4.CFrame = cFrame5
		clone4.Parent = _WorldOrigin
	end

	debris:AddItem(clone4, 1)
	TweenService:Create(clone4, v[5], {
		CFrame = clone4.CFrame * CFrame.new(-2, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone4.Mesh, v[6], {
		Scale = createVector(0.3, 1.2, 1.2)
	}):Play()
	TweenService:Create(clone4.Decal, v[6], {
		Transparency = 1
	}):Play()
	local cFrame6 = humanoidRootPart.CFrame * CFrame.new(0, 1.5, -9) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		1.5707963267948966
	)
	local shockwave2 = script.Shockwave2
	local clone5 = shockwave2:Clone()
	clone5.Name = clone5.Name

	if shockwave2:IsA("Model") then
		clone5.Parent = _WorldOrigin
		clone5.PrimaryPart.CFrame = cFrame6
	else
		clone5.CFrame = cFrame6
		clone5.Parent = _WorldOrigin
	end

	debris:AddItem(clone5, 1)
	TweenService:Create(clone5, v[7], {
		CFrame = clone5.CFrame * CFrame.new(-3.7, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone5.Mesh, v[8], {
		Scale = createVector(0, 0.90000004, 0.90000004)
	}):Play()
	TweenService:Create(clone5.Decal, v[9], {
		Transparency = 1
	}):Play()
	local raycastResult = workspace:Raycast(
		(humanoidRootPart.CFrame * CFrame.new(0, 0, -9)).Position,
		createVector(0, -10, 0),
		raycastParams
	)

	if raycastResult then
		local cFrame2 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local scar = script.Scar
		local clone6 = scar:Clone()
		clone6.Name = clone6.Name

		if scar:IsA("Model") then
			clone6.Parent = _WorldOrigin
			clone6.PrimaryPart.CFrame = cFrame2
		else
			clone6.CFrame = cFrame2
			clone6.Parent = _WorldOrigin
		end

		for _, child in pairs(clone6:GetChildren()) do
			TweenService:Create(child, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end

		debris:AddItem(clone6, 2)
	end

	local cFrame7 = humanoidRootPart.CFrame * CFrame.new(0, -1, -9)
	local explosion = script.Explosion
	local clone6 = explosion:Clone()
	clone6.Name = clone6.Name

	if explosion:IsA("Model") then
		clone6.Parent = _WorldOrigin
		clone6.PrimaryPart.CFrame = cFrame7
	else
		clone6.CFrame = cFrame7
		clone6.Parent = _WorldOrigin
	end

	debris:AddItem(clone6, 2)

	for _, child in pairs(clone6.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	Util.CraterModule({
		Cframe = humanoidRootPart.CFrame * CFrame.new(0, 0, -9),
		Size = 4.8,
		Ammount = 6.75,
		Despawn = 1.5,
		Distance = 10.8
	})
end