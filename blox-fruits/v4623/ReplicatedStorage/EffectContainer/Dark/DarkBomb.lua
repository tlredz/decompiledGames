local createVector = vector.create
game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local map = workspace:WaitForChild("Map")
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local darkBomb = FX:WaitForChild("Dark").DarkBomb
local sound = Util.Sound
local scaleParticle = Util.ScaleParticle
local rocksModule = Util.RocksModule
local debris = Util.Debris
local _ = Util.CameraShaker

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
	TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
	TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cframe, detect, p, ball)
	local clone = detect:Clone()
	clone.Parent = ball or _WorldOrigin
	clone.Name = p or clone.Name
	clone.CFrame = cframe
	return clone
end

local v2 = {}
return function(data)
	if data.Stage == 1 then
		local cFrame = data.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 1000 then
			return
		end

		if data.Owner == game.Players.LocalPlayer then
			Effect.new("Dark.Gradient"):replicate({
				Toggle = true,
				Transparency = 0.35,
				Duration = 0.75
			})
		end

		local ray = Ray.new((cFrame * CFrame.new(0, 0, -1)).Position, createVector(0, -2, 0))
		local _, _ = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })
		local cFrame2 = cFrame * CFrame.new(0, -2, 0)
		local clone = darkBomb.Charging2:Clone()
		clone.Parent = _WorldOrigin
		clone.Name = "DarkBombCharge"
		clone.CFrame = cFrame2
		clone.Twirl:Emit(clone.Twirl:GetAttribute("EmitCount"))
		local cFrame3 = cFrame * CFrame.new(0, 7, 0)
		local clone2 = darkBomb.DarkBomb:Clone()
		clone2.Parent = _WorldOrigin
		clone2.Name = "DarkBomb"
		clone2.CFrame = cFrame3
		TweenService:Create(clone2, v[1], {
			Position = clone2.Position + createVector(0, 20, 0)
		}):Play()
		v2[data.EffectId] = {
			CFrame = cFrame,
			Ball = clone2,
			Charge = clone,
			CurrentStage = 1
		}
		sound:Play("DarkDarkBombSpawn", clone2, nil, 1)
	else
		if not v2[data.EffectId] then
			return
		end

		local _ = v2[data.EffectId].CFrame
		local ball = v2[data.EffectId].Ball
		local charge = v2[data.EffectId].Charge

		if data.Stage == -1 and v2[data.EffectId].CurrentStage > 1 then
			return
		end

		v2[data.EffectId].CurrentStage = data.Stage

		if data.Stage == -1 then
			if data.Owner == game.Players.LocalPlayer then
				Effect.new("Dark.Gradient"):replicate({
					Toggle = false,
					Duration = 0.3
				})
			end

			if charge then
				for _, emitter in pairs(charge:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.TimeScale = 1
					emitter.Enabled = false
				end

				debris:AddItem(charge, 1)
			end

			if ball then
				ball:SetAttribute("Hitted", true)
				local v3 = 0

				for _, emitter in pairs(ball:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v3 = math.max(v3, emitter.Lifetime.Max)
					scaleParticle({
						Emitter = emitter,
						Scale = 0,
						Time = 2,
						EasingStyle = Enum.EasingStyle.Sine,
						EasingDirection = Enum.EasingDirection.Out
					})
					emitter.Enabled = false
				end

				debris:AddItem(ball, v3, function()
					v2[data.EffectId] = nil
				end)
			end
		elseif data.Stage == 2 then
			if charge then
				for _, emitter in pairs(charge:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.TimeScale = 1
					emitter.Enabled = false
				end

				debris:AddItem(charge, 1)
			end

			local effect = createEffect(CFrame.new(ball.Position, data.CFrame.p), darkBomb.Detect, nil, ball) -- equivalent call inferred; original call site unknown
			effect.Size *= 0.5
			effect.Weld.Part0 = ball
			local cFrame3 = (CFrame.new(Vector3.new(), data.CFrame.LookVector) + ball.Position) * CFrame.new(0, 1, -5) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			local clone = darkBomb.Shockwave:Clone()
			clone.Parent = _WorldOrigin
			clone.Name = clone.Name
			clone.CFrame = cFrame3
			TweenService:Create(clone, v[2], {
				Size = Vector3.new(clone.Size.X * 2, 0, clone.Size.Z * 2),
				CFrame = clone.CFrame * CFrame.new(0, 10, 0),
				Transparency = 1
			}):Play()
			debris:AddItem(clone, 1)
			local cFrame4 = CFrame.new(ball.Position, data.CFrame.p) * CFrame.new(0, 1, -5)
			local clone2 = darkBomb.Departure:Clone()
			clone2.Parent = _WorldOrigin
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame4

			for _, child in pairs(clone2:GetChildren()) do
				local speed = child.Speed
				child.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
				local lifetime = child.Lifetime
				child.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
				child.Rate *= 2
				child.Enabled = true
			end

			task.delay(0.25, function()
				for _, child in pairs(clone2:GetChildren()) do
					child.Enabled = false
				end

				debris:AddItem(clone2, 1)
			end)

			if data.Owner == game.Players.LocalPlayer then
				Effect.new("Dark.Gradient"):replicate({
					Toggle = false,
					Duration = 0.5
				})
			end

			local magnitude = (workspace.CurrentCamera.CFrame.p - ball.Position).Magnitude
			Effect.new("ShakeCam"):replicate({
				Preset = "Bump2",
				Power = math.clamp(1 - magnitude / 300, 0, 1)
			})
			local speed = data.Speed
			local lifetime = data.Lifetime
			local cFrame = data.CFrame
			local cFrame2 = ball.CFrame
			Util.Debris:AddItem(ball, 2 + lifetime)
			v2[data.EffectId].Sound = sound:Play("DarkDarkBombWindup", ball, nil, 0.5)
			local vector2 = Vector3.new()
			Util.DistributedLoop:add(function(p, p2)
				if not ball or not ball:IsDescendantOf(workspace) or lifetime < p or ball:GetAttribute("Hitted") then
					return true
				end

				local v5 = math.min(1, p / 0.5)
				vector2 += cFrame.LookVector * speed * p2
				ball.CFrame = cFrame2:Lerp(cFrame, v5) + vector2
			end)
		elseif data.Stage == 3 then
			ball:SetAttribute("Hitted", true)

			if v2[data.EffectId].Sound then
				sound:FadeOut(v2[data.EffectId].Sound, 0.75)
				v2[data.EffectId].Sound = nil
			end

			for _, emitter in pairs(ball:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				scaleParticle({
					Emitter = emitter,
					Scale = 0,
					Time = 2,
					EasingStyle = Enum.EasingStyle.Sine,
					EasingDirection = Enum.EasingDirection.Out
				})
				emitter.Enabled = false
			end

			local cFrame = data.CFrame
			local cFrame2 = cFrame * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			local clone = darkBomb.Explosion:Clone()
			clone.Parent = _WorldOrigin
			clone.Name = clone.Name
			clone.CFrame = cFrame2
			local children = clone.Implode:GetChildren()

			for _, v4 in pairs(children) do
				if v4.Name ~= "SpiralThingy" then
					v4.Enabled = true
				end
			end

			TweenService:Create(ball, v[1], {
				CFrame = cFrame
			}):Play()
			sound:Play("DarkDarkBombWindup", ball, nil, 1)
			task.wait(1.5)

			for _, v4 in pairs(children) do
				if v4.Name == "SpiralThingy" then
					v4:Emit(7)
				else
					v4.Enabled = false
				end
			end

			task.wait(0.8)
			sound:Play("DarkDarkBombExplosion", cFrame, nil, 0.7)

			if data.Hit then
				local v4 = cFrame * CFrame.new(0, -0.175, 0)
				local cFrame3 = v4 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
				local clone2 = darkBomb.Scar:Clone()
				clone2.Parent = _WorldOrigin
				clone2.Name = clone2.Name
				clone2.CFrame = cFrame3
				TweenService:Create(clone2.Decal, v[5], {
					Transparency = 1
				}):Play()
				debris:AddItem(clone2, 2.25)

				for _ = 1, 2 do
					local cFrame4 = v4 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
					local clone3 = darkBomb.Shockwave2:Clone()
					clone3.Parent = _WorldOrigin
					clone3.Name = clone3.Name
					clone3.CFrame = cFrame4
					clone3.Size = Vector3.new(clone3.Size.X, clone3.Size.Y * 1.5, clone3.Size.Z)
					TweenService:Create(clone3, v[6], {
						Size = Vector3.new(clone3.Size.X * 3.25, clone3.Size.Y, clone3.Size.Z * 3.25),
						Transparency = 1,
						CFrame = clone3.CFrame * CFrame.Angles(0, 3.14, 0)
					}):Play()
					debris:AddItem(clone3, 1)
				end
			end

			for _, child in pairs(clone.Attachment:GetChildren()) do
				local lifetime = child.Lifetime
				child.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
				child:Emit(child:GetAttribute("EmitCount"))
			end

			debris:AddItem(clone, 2.5)
			local clone2 = darkBomb.Sphere:Clone()
			clone2.Parent = _WorldOrigin
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame
			TweenService:Create(clone2, v[2], {
				Size = clone2.Size * 5,
				Transparency = 1
			}):Play()
			debris:AddItem(clone2, 1)

			if (currentCamera.CFrame.p - data.CFrame.p).Magnitude < 300 then
				Effect.new("Dark.Gradient"):replicate({
					Transparency = 0.175,
					Toggle = true,
					Duration = 0.5
				})
				task.delay(0.9, function()
					Effect.new("Dark.Gradient"):replicate({
						Toggle = false,
						Duration = 0.3
					})
				end)
				local magnitude = (currentCamera.CFrame.p - data.CFrame.p).Magnitude
				Effect.new("ShakeCam"):replicate({
					Preset = "Explosion",
					Power = math.clamp(1 - magnitude / 300, 0, 1)
				})
			end

			rocksModule.Ground(clone.Position, 45, createVector(6, 7, 6), { map }, 15, false, 2.25)
		end

		if data.Stage == -1 or data.Stage == 3 then
			v2[data.EffectId] = nil
		end
	end
end