local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local monsterCollisionDust = ReplicatedStorage:WaitForChild("Events"):WaitForChild("MonsterCollisionDust")
local v = 0
local colorSequence = ColorSequence.new(Color3.fromRGB(168, 150, 128), Color3.fromRGB(120, 108, 92))
monsterCollisionDust.OnClientEvent:Connect(function(position, p)
	if typeof(position) ~= "Vector3" or v >= 12 then
		return
	end

	local v2 = math.clamp(tonumber(p) or 1, 0.4, 3)
	v += 1
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Color = colorSequence
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6 * v2),
		NumberSequenceKeypoint.new(1, 1.6 * v2)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.7)
	particleEmitter.Speed = NumberRange.new(2, 5)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Rate = 0
	particleEmitter.Parent = part
	part.Parent = Workspace
	particleEmitter:Emit((math.clamp(math.floor(6 * v2), 4, 14)))
	Debris:AddItem(part, 1.2)
	task.delay(1.2, function()
		v -= 1
	end)
end)