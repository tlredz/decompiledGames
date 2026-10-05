local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function newNote(data)
	local arcAngle = data.ArcAngle
	local arcRadius = data.ArcRadius
	local color = data.Color or Color3.new(1, 1, 1)
	local cFrame = data.CFrame
	local duration = data.Duration or 1
	local scale = data.Scale or random:NextNumber(0.8, 1.5)
	local offsetMultiplier = data.OffsetMultiplier or random:NextNumber(1, 2)
	local angleSpeed = data.AngleSpeed or 2 + random:NextNumber(-1, 2)
	local timeOffset = data.TimeOffset or 0
	local v = random:NextInteger(1, 2) == 1 and "Y" or "Z"
	local vector2 = Vector3.new((random:NextInteger(1, 2) == 1 and 1 or -1) * random:NextNumber(0, 5) * scale, 0, 0)
	local cframe = CFrame.Angles(v == "Z" and 1.5707963267948966 or 0, v == "Y" and 1.5707963267948966 or 0, 0)
	local clone = FX:WaitForChild("SoundEffects").MusicNote:Clone()
	clone.Color = color
	clone.Size *= scale

	for _, emitter in pairs(clone:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = ColorSequence.new(color)
		Util.Misc.ScaleParticle(emitter, scale)
		emitter.Rate /= 2
	end

	local v2 = arcAngle * timeOffset / duration
	clone.CFrame = cFrame * CFrame.Angles(0, arcAngle / 2 - v2, 0) * CFrame.new(0, 0, -arcRadius)
	clone.Parent = _WorldOrigin
	local _ = 3.141592653589793 * random:NextNumber(-1, 1)
	local v3 = tick() + timeOffset
	local v4 = 0.016666666666666666

	while true do
		local lastTime = tick()
		local v5 = math.min(1, (lastTime - v3) / duration)
		local v6 = arcAngle * v5
		clone.CFrame = cFrame * CFrame.Angles(0, arcAngle / 2 - v6, 0) * CFrame.new(0, 0, -arcRadius) * CFrame.Angles(
			0,
			v == "Y" and v6 or 0,
			v == "Z" and v6 or 0
		) * CFrame.new(offsetMultiplier * vector2 * math.sin(3.141592653589793 * v5)) * cframe * CFrame.Angles(
			0,
			0,
			(math.sin(3.141592653589793 * lastTime))
		)

		if v5 == 1 then
			break
		end

		v6 += angleSpeed * 3.141592653589793 * v4
		RunService.RenderStepped:Wait()
		v4 = tick() - lastTime
	end

	local v5 = 0.5

	for _, emitter in pairs(clone:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v5 = math.min(v5, emitter.Lifetime.Min)
		emitter.Enabled = false
	end

	clone.Transparency = 1
	Util.Debris:AddItem(clone, v5)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 300 then
		return
	end

	local arcAngle = data.ArcAngle or 2.792526803190927
	local arcRadius = data.ArcRadius or 5
	local duration = data.Duration or 0.3
	local cFrame = data.CFrame
	local clone = FX:WaitForChild("SoundEffects").Swipe:Clone()
	clone.CFrame = cFrame * CFrame.Angles(0, arcAngle / 2, 0) * CFrame.new(0, 0, -arcRadius)
	local v = 60
	Color3.new(1, 1, 1)
	local color

	if data.maxTempoActive == true then
		v *= 2
		color = Color3.fromRGB(255, 190, 124)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = ColorSequence.new(color)
			end
		end
	else
		local v2 = {
			Color3.fromRGB(255, 39, 39),
			Color3.fromRGB(255, 255, 64),
			Color3.fromRGB(125, 38, 255),
			Color3.fromRGB(255, 118, 38)
		}
		color = v2[random:NextInteger(1, #v2)]
	end

	clone.Trail.Color = ColorSequence.new(color)
	clone.Particles.BigNote.Color = ColorSequence.new(color)
	clone.Parent = _WorldOrigin
	local now = tick()
	local v2 = 0

	while true do
		local now2 = tick()
		local v3 = math.min(1, (now2 - now) / duration)
		local v4 = arcAngle * v3
		clone.CFrame = cFrame * CFrame.Angles(0, arcAngle / 2 - v4, 0) * CFrame.new(0, 0, -arcRadius)
		local v5 = now2 - v2

		if 1 / v <= v5 then
			task.spawn(newNote, {
				ArcRadius = arcRadius,
				ArcAngle = arcAngle,
				Color = color,
				Scale = random:NextNumber(0.5, 1.5),
				Duration = duration * random:NextNumber(0.75, 1.5),
				CFrame = cFrame
			})
			v2 = now2
		end

		if v3 == 1 then
			local v6 = 0

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
					v6 = math.max(v6, effect.Lifetime.Max)
				elseif effect:IsA("Trail") then
					v6 = math.max(v6, effect.Lifetime)
				end
			end

			Util.Debris:AddItem(clone, v6 + 0.5)
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end