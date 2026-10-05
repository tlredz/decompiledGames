local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local BoatTween = require(game.ReplicatedStorage.Util.BoatTween)
local CraterModule = require(game.ReplicatedStorage.Util.CraterModule)
local FX = require(game.ReplicatedStorage.FX)
local airShot = FX:WaitForChild("DeathStep2").ModeBlue.AirShot
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Util = require(game.ReplicatedStorage.Util)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

for _, emitter in pairs(airShot.Explosion:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Scale = 1.4,
			Time = 0
		})
	end
end

return function(player)
	local humanoidRootPart = player.Character.HumanoidRootPart
	local v2 = player.CFrame * Vector3.new(0, 0, -player.Length)

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 900 then
		return
	end

	local cFrame = CFrame.new(humanoidRootPart.Position, v2) * CFrame.new(0, 1, -15) * CFrame.Angles(0, 1.57, 1.57)
	local clone = airShot.Shockwave:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	TweenService:Create(clone, v[1], {
		Size = Vector3.new(clone.Size.X * 3, 0, clone.Size.Z * 3),
		CFrame = clone.CFrame * CFrame.new(0, 20, 0),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone, 1)
	local cFrame2 = CFrame.lookAt(humanoidRootPart.Position, v2) * CFrame.new(0, 0, -13)
	local clone2 = airShot.release:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame2
	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)

	for _, emitter in pairs(clone2.Particles:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			local speed = emitter.Speed
			emitter.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			BoatTween:Create(emitter, {
				Time = 0.4,
				EasingStyle = "Sine",
				EasingDirection = "In",
				StepType = "Heartbeat",
				Goal = {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				}
			}):Play()
		end
	end

	Sound:Play("WindFire", humanoidRootPart.Position)
	local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.57, 0, 0)
	local clone3 = airShot.Shot:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame3
	clone3.Parent = _WorldOrigin
	Debris:AddItem(clone3, 1.5)
	local bodyVelocity = Instance.new("BodyVelocity", clone3)
	bodyVelocity.MaxForce = createVector(500000, 500000, 500000)
	bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, v2).lookVector * 999
	local v6 = player.Length / 999
	local raycastResult = workspace:Raycast(
		player.CFrame.p,
		player.CFrame.LookVector * (player.Length + 1),
		raycastParams
	)
	task.wait(v6)
	clone3.Anchored = true
	clone3.CFrame = player.CFrame * CFrame.new(0, 0, -player.Length)
	bodyVelocity:Destroy()
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 and (humanoidRootPart2.Position - v2).magnitude <= 50 then
			Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion)
		end
	end

	for _, descendant in pairs(clone3:GetDescendants()) do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
			continue
		end

		descendant:Destroy()
	end

	local cFrame4 = CFrame.new(clone3.Position) * CFrame.new(0, 2, 0)
	local clone4 = airShot.Explosion:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame4
	clone4.Parent = _WorldOrigin
	Debris:AddItem(clone4, 2)

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.ZOffset += 1
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	Sound:Play("BlackLegGround", v2, nil, 1, 1)
	Sound:Play("BlackLegIgnite2", v2, nil, 1.5, 1)

	if raycastResult then
		local cframe = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local cFrame5 = cframe * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone5 = airShot.Dust:Clone()
		clone5.Name = clone5.Name
		clone5.CFrame = cFrame5
		clone5.Parent = _WorldOrigin
		clone5.Attachment.Smoke.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone5.Attachment.Smoke:Emit(9)
		Debris:AddItem(clone5, 1.26)
		CraterModule({
			Cframe = cframe,
			Size = 7,
			Ammount = 7,
			Despawn = 3,
			Distance = 20
		})
	end
end