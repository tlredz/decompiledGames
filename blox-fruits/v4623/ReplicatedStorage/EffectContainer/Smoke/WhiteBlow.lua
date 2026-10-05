local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	if player.Pre then
		local character = player.Character
		local humanoid = character.Humanoid
		local humanoidRootPart = character.HumanoidRootPart

		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 300 then
			return
		end

		Sound:Play("SmokeCharge", humanoidRootPart.Position)
		local clones = {}

		for _, emitter in pairs(script:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			table.insert(clones, clone)
			clone.Enabled = true
			clone.Parent = character.RightLowerArm
		end

		repeat
			wait()
		until not player.Holding or not player.Holding:IsDescendantOf(workspace) or humanoid.Health <= 0 or not player.Holding.Value

		for _, emitter in pairs(clones) do
			if emitter == nil then
				continue
			end

			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
				Debris:AddItem(emitter, 1)
			else
				emitter:Destroy()
			end
		end
	elseif player.Explode then
		local cFrame = player.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.p).magnitude > 700 then
			return
		end

		Sound:Play("SmokeBallExplode", cFrame)

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude < 70 * (player.Scale or 1) then
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ShakeCam"):replicate({
				5 * (player.Scale or 1),
				10 * (player.Scale or 1),
				0,
				1.5 * (player.Scale or 1),
				createVector(0.25, 0.25, 0.25),
				createVector(4, 1, 1)
			})
			local clone = script.Blur:Clone()
			clone.Parent = game.Lighting
			TweenService:Create(clone, v[1], {
				Size = 10 * (player.Scale or 1)
			}):Play()
			Debris:AddItem(clone, 1)
		end

		local folder = _WorldOrigin:FindFirstChild("SmokeBlast" .. player.ID)

		if folder then
			folder.Anchored = true

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
					descendant.Enabled = false
				elseif descendant:IsA("PointLight") or descendant:IsA("Sound") then
					descendant:Destroy()
				end
			end
		end

		local clone = script.explosion:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 6)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				if player.Scale then
					ScaleParticle({
						Emitter = descendant,
						Scale = player.Scale,
						Time = 0,
						EasingStyle = Enum.EasingStyle.Linear,
						EasingDirection = Enum.EasingDirection.Out
					})
				end

				descendant:Emit(descendant:GetAttribute("EmitCount"))
			elseif descendant:IsA("BasePart") then
				descendant.Size *= player.Scale or 1
			end
		end

		if not player.NoArea then
			local clone2 = script.SmokeArea:Clone()
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame
			clone2.Parent = _WorldOrigin
			Debris:AddItem(clone2, 4)
			task.wait(2.4)

			for _, child in pairs(clone2:GetChildren()) do
				child.Enabled = false
			end
		end
	else
		if not player.Part then
			return
		end

		local v2 = workspace:GetServerTimeNow() - player.Timestamp
		local cFrame = player.CFrame
		local duration = player.Duration or 1.5
		local length = player.Length or 400
		local v3 = duration - v2

		if v3 < 0.1 or (workspace.CurrentCamera.CFrame.Position - cFrame.p).magnitude > 700 then
			return
		end

		Sound:Play("SmokeBallAppear", cFrame)
		local cFrame2 = CFrame.new((cFrame * CFrame.new(0, 0, -3)).p, cFrame.p + cFrame.LookVector) * CFrame.Angles(
			1.57,
			0,
			0
		)
		local clone = script.Ball:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin

		if player.Scale then
			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					ScaleParticle({
						Emitter = descendant,
						Scale = player.Scale,
						Time = 0,
						EasingStyle = Enum.EasingStyle.Linear,
						EasingDirection = Enum.EasingDirection.Out
					})
					descendant.Rate *= player.Scale
				elseif descendant:IsA("PointLight") then
					descendant.Range *= player.Scale
				end
			end
		end

		clone.Name = "SmokeBlast" .. player.ID
		Debris:AddItem(clone, 5)
		local bodyVelocity = Instance.new("BodyVelocity", clone)
		bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
		bodyVelocity.Velocity = cFrame.LookVector * (length / v3)
		task.wait(v3)
		clone.Anchored = true

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = false
			elseif descendant:IsA("PointLight") or descendant:IsA("Sound") then
				descendant:Destroy()
			end
		end
	end
end