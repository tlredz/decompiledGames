local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local MeshRockModule = require(game.ReplicatedStorage.Util.MeshRockModule)
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

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
	TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, charge, p, p2)
	local clone = charge:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local scale = player.Scale
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	if player.Status then
		local effect = createEffect(humanoidRootPart.CFrame, script.charge, "ChargeDestruct" .. character.Name) -- equivalent call inferred; original call site unknown
		Sound:Play("DestructStart", humanoidRootPart.Position)
		TweenService:Create(effect.Part, v[3], {
			Size = effect.Part.Size * 0
		}):Play()

		for _, descendant in pairs(effect:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				ScaleParticle({
					Emitter = descendant,
					Scale = 0,
					Time = 5,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			elseif descendant:IsA("PointLight") then
				TweenService:Create(descendant, v[3], {
					Range = 0,
					Brightness = 0
				}):Play()
			end
		end

		local now = tick()
		local v3 = nil

		while true do
			if tick() - now > 0.15 and not v3 then
				v3 = Sound:Play("DestructLoop", humanoidRootPart.Position)
			elseif tick() - now > 3.9 and v3 then
				Sound:FadeOut(v3, 0.5)
				v3 = nil
				now = 1e999
			end

			effect.CFrame = humanoidRootPart.CFrame
			wait()

			if not (humanoid.Health <= 0 or not player.Status:IsDescendantOf(workspace)) then
				continue
			end

			if v3 then
				Sound:FadeOut(v3, 0.25)
			end

			for _, emitter in pairs(effect:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			Debris:AddItem(effect, 1)
			return
		end
	else
		Sound:Play("DestructBoom", humanoidRootPart.Position)
		local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
		local part, v2, v3 = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })

		if part then
			Sound:Play("DestructDebris", humanoidRootPart.Position)
		end

		local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 2, 0)
		local clone = script.eff:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 2)
		local scale2 = scale * 2

		for _, child in pairs(clone.Attachment:GetChildren()) do
			local speed = child.Speed
			child.Speed = NumberRange.new(speed.Min * scale2, speed.Max * scale2)
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 1.25, lifetime.Max * 1.25)

			if child.Name == "fire" then
				ScaleParticle({
					Emitter = child,
					Scale = scale2 * 1.25,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			else
				ScaleParticle({
					Emitter = child,
					Scale = scale2,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			end

			if child.Name == "sm2" then
				if part then
					child.Color = ColorSequence.new(part.Color)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			else
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		for i = 1, 2 do
			local cFrame = clone.CFrame
			local clone2 = script.Shockwave:Clone()
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame
			clone2.Parent = _WorldOrigin
			clone2.Size *= scale2 * 0.75
			Debris:AddItem(clone2, 0.5)

			if i == 1 then
				clone2.CFrame = clone.CFrame * CFrame.new(0, 12, 0)
				TweenService:Create(clone2, v[2], {
					CFrame = clone2.CFrame * CFrame.new(0, -8, 0),
					Size = Vector3.new(clone2.Size.Z * 3, 0, clone2.Size.X * 3),
					Transparency = 1
				}):Play()
			else
				clone2.Size *= 0.75
				clone2.CFrame *= CFrame.new(0, 23, 0)
				TweenService:Create(clone2, v[2], {
					CFrame = clone2.CFrame * CFrame.new(0, -8, 0),
					Size = Vector3.new(clone2.Size.X * 3, 0, clone2.Size.Z * 3),
					Transparency = 1
				}):Play()
			end
		end

		if part then
			local cFrame = CFrame.new(v2, v2 + v3 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				math.random(-10, 10) / 10 * 3.141592653589793,
				0
			)
			local clone2 = script.Scar:Clone()
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame
			clone2.Parent = _WorldOrigin
			clone2.Size *= scale2

			for _, child in pairs(clone2:GetChildren()) do
				TweenService:Create(child, v[1], {
					Transparency = 1
				}):Play()
			end

			Debris:AddItem(clone2, 2.1)
		end

		MeshRockModule({
			Cframe = humanoidRootPart.CFrame,
			Amount = 15,
			Iteration = 14 * scale2,
			Max = 3.25 * scale2,
			FirstDuration = 0.1,
			RocksLength = 1.2 + scale2 * 0.3
		})
	end
end