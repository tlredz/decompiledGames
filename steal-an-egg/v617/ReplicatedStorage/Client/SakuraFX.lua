local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Sakura = require(ReplicatedStorage.Data.Sakura)
local Audio = require(ReplicatedStorage.Shared.Audio)
local sakura = ReplicatedStorage.Assets.VFX:WaitForChild("Sakura")

local function spawnAnchor(position: Vector3, p: number)
	local part = Instance.new("Part")
	part.Name = "SakuraFXHost"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1) * p
	part.Position = position
	part.Parent = Workspace
	Debris:AddItem(part, 6)
	return part
end

local function cue(p: string, p2, value: number?, value2: number?, value3: number?, looped: boolean?)
	local sound = Sakura.Sounds[p]
	assert(sound ~= nil, (`no sound id catalogued under Sakura.Sounds.{p}`))
	return Audio.Play(sound, p2, {
		PlaybackSpeed = value2 or 1,
		Volume = value or 1,
		MaxDistance = value3 or 120,
		Looped = looped
	})
end

local SakuraFX = {}

function SakuraFX.EmitBurst(childName: string, position: Vector3, p: number, value: number?)
	local child = sakura:FindFirstChild(childName)
	assert(child ~= nil, (`no burst prefab named {childName} under Assets.VFX.Sakura`))
	local part = Instance.new("Part")
	part.Name = "SakuraFXHost"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1) * (value or 4)
	part.Position = position
	part.Parent = Workspace
	Debris:AddItem(part, 6)

	for _, emitter in child:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		clone.Enabled = false
		clone.Parent = part
		clone:Emit((math.max(1, (math.floor(p * math.max(emitter.Rate, 1) / 20)))))
	end

	return part
end

function SakuraFX.PlayCue(p: string, p2, p3: number?, p4: number?, p5: number?)
	return cue(p, p2, p3, p4, p5)
end

function SakuraFX.PlayLooped(p: string, p2, p3: number?, p4: number?)
	return cue(p, p2, p3, p4, nil, true)
end

return SakuraFX