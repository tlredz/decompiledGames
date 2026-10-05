local createVector = vector.create
NumberSequence.new(10)
NumberRange.new(0.8)
local _ = {
	None = 0,
	Whitelist = 1,
	Blacklist = 2,
	Function = 3
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = false
local sound = Instance.new("Sound")
sound.Name = "RainSound"
sound.SoundId = "rbxassetid://123824490114701"
sound.Looped = true
sound.Archivable = false
local part = Instance.new("Part")
part.Transparency = 1
part.Anchored = true
part.CanCollide = false
part.Locked = false
part.Archivable = false
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
part.Name = "__RainEmitter"
part.Size = createVector(100, 40, 100)
part.Archivable = false
local particleEmitter = Instance.new("ParticleEmitter")
particleEmitter.Name = "RainStraight"
particleEmitter.LightEmission = 0.05
particleEmitter.LightInfluence = 0.9
particleEmitter.Size = NumberSequence.new(10)
particleEmitter.Texture = "rbxassetid://5261101916"
particleEmitter.Transparency = NumberSequence.new(0.7)
particleEmitter.LockedToPart = true
particleEmitter.Enabled = false
particleEmitter.Lifetime = NumberRange.new(0.8)
particleEmitter.Rate = 300
particleEmitter.Speed = NumberRange.new(20)
particleEmitter.EmissionDirection = Enum.NormalId.Bottom
particleEmitter.Parent = part
part.CFrame = CFrame.new(0, -40, 0)
part.Parent = workspace.CurrentCamera
local particleEmitter2 = Instance.new("ParticleEmitter")
particleEmitter2.Name = "SnowStraight"
particleEmitter2.LightEmission = 0.05
particleEmitter2.LightInfluence = 0.9
particleEmitter2.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.2, 0.0974),
	NumberSequenceKeypoint.new(1, 0.2, 0.0974)
})
particleEmitter2.Texture = "rbxassetid://123241244768612"
particleEmitter2.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.1, 0.4),
	NumberSequenceKeypoint.new(0.5, 0.5),
	NumberSequenceKeypoint.new(0.85, 0.76),
	NumberSequenceKeypoint.new(1, 1)
})
particleEmitter2.LockedToPart = false
particleEmitter2.Enabled = false
particleEmitter2.Lifetime = NumberRange.new(15)
particleEmitter2.Rate = 200
particleEmitter2.Speed = NumberRange.new(6)
particleEmitter2.EmissionDirection = Enum.NormalId.Bottom
particleEmitter2.Parent = part
local v2 = { part }
local v3 = ({
	[0] = function(p, p2)
		return workspace:FindPartOnRayWithIgnoreList(
			p,
			p2 and { part, Players.LocalPlayer and Players.LocalPlayer.Character } or v2
		)
	end,
	[2] = function(p)
		return workspace:FindPartOnRayWithIgnoreList(p, nil)
	end,
	[1] = function(p)
		return workspace:FindPartOnRayWithWhitelist(p, nil)
	end,
	[3] = function(ray)
		local v4 = ray.Origin + ray.Direction

		while ray.Direction.magnitude > 0.001 do
			local part2, v5, v6, v7 = workspace:FindPartOnRayWithIgnoreList(ray, v2)

			if part2 and not (nil)(part2) then
				local v8 = v5 + ray.Direction.Unit * 0.001
				ray = Ray.new(v8, v4 - v8)
			else
				return part2, v5, v6, v7
			end
		end
	end
})[0]

local function connectLoop()
	while v == true do
		wait(0.1)
		local v4, _ = v3(Ray.new(workspace.CurrentCamera.CFrame.p, createVector(-0, 50, -0)), true)

		if v4 then
			part.RainStraight.Enabled = false
			sound.Volume = 0.2
		else
			sound.Volume = 0.4
			local v5 = math.abs((workspace.CurrentCamera.CFrame.lookVector:Dot(createVector(0, -1, 0))))
			local p = workspace.CurrentCamera.CFrame.p
			local cross = workspace.CurrentCamera.CFrame.lookVector:Cross(createVector(-0, 1, -0))
			local unit = cross.magnitude > 0.001 and cross.unit or createVector(-0, 1, -0)
			local unit2 = (createVector(0, -1, 0)):Cross(unit).unit
			wait()
			part.CFrame = CFrame.new(p.x, p.y, p.z, unit.x, -0, unit2.x, unit.y, 1, unit2.y, unit.z, -0, unit2.z) + (1 - v5) * workspace.CurrentCamera.CFrame.lookVector * part.Size.Z / 3 - v5 * createVector(
				0,
				-1,
				0
			) * 20
			part.RainStraight.Enabled = true
		end
	end
end

local function connectLoopSnow()
	while v == true do
		wait(0.1)
		local v4, _ = v3(Ray.new(workspace.CurrentCamera.CFrame.p, createVector(-0, 50, -0)), true)

		if v4 then
			part.SnowStraight.Enabled = false
			sound.Volume = 0.2
		else
			sound.Volume = 0.4
			local v5 = math.abs((workspace.CurrentCamera.CFrame.lookVector:Dot(createVector(0, -1, 0))))
			local p = workspace.CurrentCamera.CFrame.p
			local cross = workspace.CurrentCamera.CFrame.lookVector:Cross(createVector(-0, 1, -0))
			local unit = cross.magnitude > 0.001 and cross.unit or createVector(-0, 1, -0)
			local unit2 = (createVector(0, -1, 0)):Cross(unit).unit
			wait()
			part.CFrame = CFrame.new(p.x, p.y, p.z, unit.x, -0, unit2.x, unit.y, 1, unit2.y, unit.z, -0, unit2.z) + (1 - v5) * workspace.CurrentCamera.CFrame.lookVector * part.Size.Z / 3 - v5 * createVector(
				0,
				-1,
				0
			) * 20
			part.SnowStraight.Enabled = true
		end
	end
end

local Rain = {}

function Rain.Enable(_)
	if RunService:IsRunning() then
		sound.Parent = game:GetService("SoundService")
	end

	if workspace.WorkspaceCom.WeatherControls.WeatherDescription.Value ~= "Snow" and not sound.Playing then
		sound:Play()
	end

	v = true
	wait(0.5)
	connectLoop()
end

function Rain.EnableSnow(_)
	v = true
	wait(0.5)
	connectLoopSnow()
end

function Rain.Disable(_)
	v = false
	wait(0.5)
	part.RainStraight.Enabled = false
	part.SnowStraight.Enabled = false
	part.CFrame = CFrame.new(0, -40, 0)

	for _ = 1, 40 do
		sound.Volume -= 0.05
		wait(0.1)

		if sound.Volume <= 0 then
			break
		end
	end

	sound:Stop()
	part.RainStraight.Enabled = false
	part.SnowStraight.Enabled = false
	part.CFrame = CFrame.new(0, -40, 0)
end

return Rain