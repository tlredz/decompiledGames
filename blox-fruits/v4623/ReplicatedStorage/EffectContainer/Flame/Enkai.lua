local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local enkai = FX:WaitForChild("FlameEffects").Enkai
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = {
	TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
local rocksModule = Util.RocksModule
return function(data)
	local ID = data.ID
	local char = data.char
	local root = data.root
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local fliesFor = data.fliesFor
	local isImpact = data.isImpact
	local impactPos = data.impactPos
	local charge = data.charge
	local power = data.power
	local nerfed = data.nerfed

	if humanoid == nil or root == nil then
		return
	end

	local position = root.Position
	local currentCamera = Workspace.CurrentCamera

	if isImpact then
		local clientPart = data.projectilePart:WaitForChild("clientPart", 0.5)

		if not clientPart then
			warn("no clientPart found")
			return
		end

		local child = clientPart:FindFirstChild("EnkaiBall" .. ID)

		if not (child ~= nil and child:FindFirstChild("WeldConstraint")) then
			return
		end

		child.WeldConstraint:Destroy()
		child.Anchored = true
		child.Transparency = 1
		child.Position = impactPos
		Util.Sound:Play("Mera_EnteiExplosion", impactPos, nil, nerfed and 1.15 or 0.85)

		if (child.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 + 75 * power then
			Util.CameraShaker:ShakeOnce(19, 14, 0, 3.5)
			local clone = enkai.Blur:Clone()
			clone.Parent = game.Lighting
			TweenService:Create(clone, v[3], {
				Size = 10
			}):Play()
			task.delay(1, function()
				TweenService:Create(clone, v[4], {
					Size = 0
				}):Play()
				destroyAfter(clone, 1.1)
			end)
		end

		local raycastResult = Workspace:Raycast(
			child.Position + createVector(0, 5, 0),
			createVector(-0, -40, -0),
			raycastParams
		)
		local v2 = (1.25 + power * 0.75) * 0.75

		if not nerfed then
			v2 *= 2
		end

		if raycastResult then
			local effect = createEffect(
				CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				enkai.Scar
			) -- equivalent call inferred; original call site unknown
			effect.Size *= 2.15 * v2 * createVector(1, 0, 1)
			effect.Size += createVector(0, 1, 0)
			task.delay(2, function()
				for _, child2 in ipairs(effect:GetChildren()) do
					TweenService:Create(child2, v[2], {
						Transparency = 1
					}):Play()
				end

				destroyAfter(effect, 1.26)
			end)
		end

		local effect = createEffect(CFrame.new(child.Position) * CFrame.new(0, 0.5, 0), enkai.Explosion) -- equivalent call inferred; original call site unknown
		local descendants = effect:GetDescendants()

		for _, emitter in ipairs(descendants) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if nerfed and emitter.Name ~= "fire" then
				emitter.Enabled = false
			else
				local v4 = 1.5

				if emitter.Name == "fire" then
					v4 = 0.9 + power * 0.15
				else
					emitter.Rate *= 0.5
				end

				if v4 ~= 1 then
					scaleParticle({
						Emitter = emitter,
						Scale = v2 * v4,
						Time = 0
					})
				end
			end
		end

		destroyAfter(effect, 2.5)

		if not nerfed then
			local effect2 = createEffect(child.CFrame * CFrame.new(0, 15, 0), enkai.wind) -- equivalent call inferred; original call site unknown
			TweenService:Create(effect2, v[5], {
				Transparency = 1,
				Size = effect2.Size * 3 * v2,
				CFrame = effect2.CFrame * CFrame.Angles(0, 1.57, 0)
			}):Play()
			destroyAfter(effect2, 1)
		end

		local effect2 = createEffect(child.CFrame, enkai.Sphere) -- equivalent call inferred; original call site unknown
		effect2.Size *= 4 * v2
		scaleParticle({
			Emitter = effect2.Attachment.Wave,
			Scale = 7 * v2 * (nerfed and 1 or 2),
			Time = 1,
			EasingStyle = Enum.EasingStyle.Exponential,
			EasingDirection = Enum.EasingDirection.Out
		})

		for _, child2 in ipairs(child.Attachment:GetChildren()) do
			child2.Enabled = false
			child2:Clear()
		end

		task.spawn(function()
			TweenService:Create(
				effect2,
				TweenInfo.new(nerfed and 1 or 1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = effect2.Size * 1.55
				}
			):Play()
			local emitters = {}

			for _, emitter in ipairs(descendants) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter.Name == "fire" then
					scaleParticle({
						Emitter = effect2.Attachment.Wave,
						Scale = 1.6,
						Time = 1.15,
						EasingStyle = Enum.EasingStyle.Linear,
						EasingDirection = Enum.EasingDirection.Out
					})
					table.insert(emitters, emitter)
				elseif nerfed then
					emitter.Enabled = false
				else
					table.insert(emitters, emitter)
				end
			end

			local v4 = nerfed and 1 or 1.5
			local lastTime = tick()

			while tick() - lastTime < v4 do
				if 15 + effect2.Size.X * 0.5 > (Workspace.CurrentCamera.CFrame.p - effect.Position).Magnitude then
					for _, v5 in pairs(emitters) do
						v5:Clear()
						v5.Enabled = false
					end

					effect2.Attachment.Wave:Clear()
					effect2.Attachment.Wave.Enabled = false
				else
					for _, v5 in pairs(emitters) do
						v5.Enabled = true
					end

					effect2.Attachment.Wave.Enabled = true
				end

				task.wait()
			end

			for _, emitter in ipairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			effect2.Attachment.Wave.Enabled = false
			task.wait(0.15)
			TweenService:Create(effect2, v[5], {
				Size = effect2.Size * 0
			}):Play()
			destroyAfter(effect2, 1.5)
		end)
		rocksModule.Ground(
			child.Position,
			70 * v2,
			createVector(8.75, 13.75, 8.75) * v2,
			{ Workspace.Map },
			17,
			false,
			2,
			true
		)
	elseif charge then
		if (position - currentCamera.CFrame.Position).Magnitude > 1500 then
			return
		end

		if not nerfed then
			local effect = createEffect(
				CFrame.new(root.Position) * CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, -1.57),
				enkai.Charge,
				"EnkaiCharge" .. ID
			) -- equivalent call inferred; original call site unknown

			for _, child in ipairs(effect.Emit:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		local effect = createEffect(CFrame.new(root.Position), enkai.Ball, "EnkaiBall" .. ID) -- equivalent call inferred; original call site unknown
		TweenService:Create(effect, v[1], {
			Position = effect.Position + Vector3.new(0, nerfed and 20 or 50, 0)
		}):Play()
		local tween = TweenService:Create(effect.Mesh, TweenInfo.new(1.25), {
			Scale = createVector(17.5, 17.5, 17.5) * (nerfed and 0.75 or 1.5)
		})
		tween:Play()
		Util.Sound:Play("Mera_EnteiSpawn", effect)
		local children = effect.Attachment:GetChildren()
		local v3 = {}

		for _, emitter in ipairs(children) do
			local scale = emitter.Name == "EMIT" and 1 or 2

			if nerfed then
				if emitter.Name == "specs" or emitter.Name == "Haze" or emitter.Name == "Crecenst" or emitter.Name == "InnerFire" or emitter.Name == "Main Effect" then
					emitter.Enabled = false
				end
			else
				scale *= 1.5
			end

			scaleParticle({
				Emitter = emitter,
				Scale = scale,
				Time = 0
			})
			v3[emitter] = scaleParticle({
				Emitter = emitter,
				Scale = scale * 1.5,
				Time = 1.25,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})

			if _G.FastMode then
				emitter.Rate /= 1.5
			else
				emitter.Rate *= 1.25
			end

			emitter:Emit((math.ceil(emitter.Rate / 5)))
		end

		task.delay(0.15, function()
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(100000000000, 100000000000, 100000000000)
			bodyVelocity.Velocity = createVector(0, 30, 0)
			bodyVelocity.Parent = effect
			effect.Anchored = false
			local v4 = 1
			local connection = nil
			connection = heartbeatLoopFor2(1, function(p)
				v4 = 1 + p / 0.75

				if effect == nil or effect.Parent == nil then
					connection:Disconnect()
					connection = nil

					for _, v5 in pairs(v3) do
						v5()
					end

					tween:Pause()
				elseif effect:FindFirstChild("Finished") then
					connection:Disconnect()
					connection = nil
					bodyVelocity:Destroy()

					for _, v5 in pairs(v3) do
						v5()
					end

					tween:Pause()
				elseif v4 >= 2 then
					bodyVelocity.Velocity = createVector(0, 0, 0)
				end
			end)
		end)
	else
		local clientPart = data.projectilePart:WaitForChild("clientPart", 0.5)

		if not clientPart then
			warn("no clientPart found")
			return
		end

		local folder = _WorldOrigin:FindFirstChild("EnkaiCharge" .. ID)
		local folder2 = _WorldOrigin:FindFirstChild("EnkaiBall" .. ID)

		if folder2 then
			local vector3Value = Instance.new("Vector3Value")
			vector3Value.Name = "Finished"
			vector3Value.Parent = folder2

			for _, child in ipairs(folder2.Attachment:GetChildren()) do
				if child.Name == "EMIT" then
					child:Emit(1)
				end
			end

			local bodyVelocity = folder2:FindFirstChildOfClass("BodyVelocity")

			if bodyVelocity then
				bodyVelocity:Destroy()
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = folder2
			weldConstraint.Part1 = clientPart
			weldConstraint.Parent = folder2
			folder2.Parent = clientPart
			task.delay(fliesFor, function()
				for _, effect in ipairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end

				TweenService:Create(folder2, TweenInfo.new(0.95), {
					Size = createVector(0, 0, 0)
				}):Play()
			end)
			destroyAfter(folder2, fliesFor + 1)
			task.wait(0.1)

			if folder then
				for _, emitter in ipairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				destroyAfter(folder, 1)
			end
		end
	end
end