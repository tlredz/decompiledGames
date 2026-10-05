local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local iceBird = FX:WaitForChild("IceEffects").IceBird
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
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
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.65, Enum.EasingStyle.Sine),
	TweenInfo.new(1, Enum.EasingStyle.Exponential)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

return function(data)
	local char = data.char
	local root = data.root
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local clientPart = data.projectilePart:WaitForChild("clientPart", 0.5)

	if not clientPart then
		warn("no clientPart found")
		return
	end

	local fliesFor = data.fliesFor
	local isImpact = data.isImpact
	local impactPos = data.impactPos

	if humanoid == nil or root == nil then
		return
	end

	local position = root.Position

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	if isImpact then
		local birdieModel = clientPart:FindFirstChild("BirdieModel")

		if birdieModel == nil then
			return
		end

		local birdie = birdieModel.Birdie
		local weld = birdie:FindFirstChild("Weld")

		if weld then
			weld:Destroy()
		end

		birdie.Anchored = true
		birdie.Position = impactPos

		if (birdie.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(11, 10, 0.01, 0.5)
			local clone = iceBird.ColorCorrection:Clone()
			clone.Parent = game.Lighting
			destroyAfter(clone, 1)
			TweenService:Create(clone, v[4], {
				Brightness = 0,
				TintColor = Color3.new(1, 1, 1)
			}):Play()
		end

		birdie.Transparency = 1
		destroyAfter(birdie, 1)
		Util.Sound:Play("Ice_pheasant_break", birdie.Position)
		Util.Sound:Play("Ice_pheasant_hit", birdie.Position)

		for _, effect in ipairs(birdie:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = false
		end

		local effect = createEffect(birdie.CFrame, iceBird.Sphere) -- equivalent call inferred; original call site unknown
		destroyAfter(effect, 1)
		TweenService:Create(effect, v[3], {
			Transparency = 1,
			Size = effect.Size * 6
		}):Play()
		local effect2 = createEffect(birdie.CFrame, iceBird.Explode) -- equivalent call inferred; original call site unknown
		destroyAfter(effect2, 1.5)

		for _, child in ipairs(effect2.Attachment:GetChildren()) do
			local speed = child.Speed
			child.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
			scaleParticle({
				Emitter = child,
				Scale = 2,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Sine,
				EasingDirection = Enum.EasingDirection.Out
			})
			child:Emit(child:GetAttribute("EmitCount"))
		end

		for _ = 1, 7 do
			local effect3 = createEffect(
				birdie.CFrame * CFrame.new(0, math.random(-3, 3), 0),
				iceBird["IceDebris" .. math.random(1, 2)]
			) -- equivalent call inferred; original call site unknown
			effect3.Size *= random:NextNumber(0.6, 2)
			destroyAfter(effect3, 2)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
			bodyVelocity.Velocity = Vector3.new(math.random(-27, 27), math.random(24, 36), (math.random(-27, 27))) * 1.5
			bodyVelocity.Parent = effect3
			destroyAfter(bodyVelocity, 0.2)
			TweenService:Create(effect3, v[2], {
				Transparency = 1
			}):Play()
		end
	else
		if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 75 then
			Util.CameraShaker:ShakeOnce(6, 10, 0.01, 0.35)
		end

		local model = Instance.new("Model")
		model.Name = "BirdieModel"
		model.Parent = clientPart
		local effect = createEffect(clientPart.CFrame, iceBird.Birdie) -- equivalent call inferred; original call site unknown
		effect.Parent = model
		local weld = Instance.new("Weld")
		weld.Part0 = effect
		weld.Part1 = clientPart
		weld.Parent = effect
		local _ = root.CFrame
		Util.Sound:Play("Ice_pheasant_spawn", effect.Position)
		Util.Anims:Get(effect, "IceBirdieFlapping"):Play()
		local effect2 = createEffect(root.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.57, 0, 0), iceBird.release) -- equivalent call inferred; original call site unknown
		destroyAfter(effect2, 1)

		for _, child in pairs(effect2.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.delay(fliesFor, function()
			if effect.Transparency == 1 then
				return
			end

			effect.Transparency = 1
			Util.Sound:Play("IceBirdie9922433267", clientPart)

			for _, effect3 in ipairs(effect:GetDescendants()) do
				if effect3:IsA("ParticleEmitter") then
					if effect3.Parent.Name == "Release" then
						local speed = effect3.Speed
						effect3.Speed = NumberRange.new(speed.Min * 1.25, speed.Max * 1.25)
						effect3:Emit(effect3:GetAttribute("EmitCount"))
					else
						effect3.Enabled = false
					end
				end

				if effect3:IsA("Trail") or effect3:IsA("Beam") then
					effect3.Enabled = false
				end
			end

			if (effect.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 125 then
				Util.CameraShaker:ShakeOnce(6, 10, 0.01, 0.35)
			end

			Util.Sound:Play("Ice_pheasant_break", effect.Position)

			for _ = 1, 6 do
				local effect3 = createEffect(
					effect.CFrame * CFrame.new(0, math.random(-3, 3), 0),
					iceBird["IceDebris" .. math.random(1, 2)]
				) -- equivalent call inferred; original call site unknown
				effect3.Size *= random:NextNumber(0.5, 1.75)
				destroyAfter(effect3, 2)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
				bodyVelocity.Velocity = Vector3.new(math.random(-27, 27), math.random(24, 36), (math.random(-27, 27))) * 1.5
				bodyVelocity.Parent = effect3
				destroyAfter(bodyVelocity, 0.2)
				TweenService:Create(effect3, v[2], {
					Transparency = 1
				}):Play()
			end

			destroyAfter(effect, 1)
		end)
	end
end