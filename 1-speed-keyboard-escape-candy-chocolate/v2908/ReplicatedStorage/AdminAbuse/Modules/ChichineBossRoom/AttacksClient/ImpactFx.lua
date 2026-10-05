local createVector = vector.create
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebris = require(script.Parent.ClientDebris)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local v = nil

local function getThunderHitTemplate()
	if v and v.Parent then
		return v
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local luckymatBossRoom = adminAbuse and adminAbuse:FindFirstChild("LuckymatBossRoom")
	local VFX = luckymatBossRoom and luckymatBossRoom:FindFirstChild("VFX")
	local thunderHit = VFX and (VFX:FindFirstChild("ThunderHit") or VFX:FindFirstChild("HitParticles") or VFX:FindFirstChild("Thunder"))

	if not thunderHit then
		local child = ReplicatedStorage:FindFirstChild(EventsConfig.Lightning.LightningFolder)
		thunderHit = child and child:FindFirstChild("HitParticles")
	end

	v = thunderHit
	return thunderHit
end

local function thunderHitAt(vector2: Vector3, value: number?)
	local thunderHitTemplate = getThunderHitTemplate()

	if not thunderHitTemplate then
		return
	end

	local v2 = value or 1
	local clone = thunderHitTemplate:Clone()

	if clone:IsA("BasePart") then
		clone.Size *= v2
		clone.CFrame = CFrame.new(vector2)
	elseif clone:IsA("Model") then
		clone:ScaleTo(v2)
		clone:PivotTo(CFrame.new(vector2))
	elseif clone:IsA("Attachment") then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.new(vector2)
		part.Parent = workspace
		clone.Parent = part
		clone = part
	end

	clone.Parent = workspace
	Debris:AddItem(clone, 3)
	task.delay(0.35, function()
		if clone and clone.Parent then
			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
					descendant.Enabled = false
				end
			end
		end
	end)
end

local function playSpatialSound(vector2: Vector3, soundId: string, volume: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(vector2)
	part.Parent = workspace
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.RollOffMinDistance = 20
	sound.RollOffMaxDistance = 700
	sound.Parent = part
	sound:Play()
	sound.Ended:Once(function()
		pcall(function()
			part:Destroy()
		end)
	end)
	Debris:AddItem(part, 12)
end

local function screenShakeNearby(p: number, p2: number, p3: number, p4: number)
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local magnitude = (humanoidRootPart.Position - Vector3.new(p, p2, p3)).Magnitude

	if p4 * 3 < magnitude then
		return
	end

	local v2 = math.clamp(1 - magnitude / (p4 * 3), 0.1, 1) * 0.6
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local total = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		total += dt

		if total >= 0.4 then
			renderSteppedConnection:Disconnect()
			return
		end

		local v3 = v2 * (1 - total / 0.4)
		currentCamera.CFrame *= CFrame.new((math.random() * 2 - 1) * v3, (math.random() * 2 - 1) * v3, 0)
	end)
end

local ImpactFx = {}

function ImpactFx.sounds(p: number, p2: number, p3: number)
	local vector2 = Vector3.new(p, p2, p3)
	playSpatialSound(vector2, "rbxassetid://135676461695962", 1)
	playSpatialSound(vector2, "rbxassetid://139520673393967", 0.65)
end

function ImpactFx.shake(p: number, p2: number, p3: number, p4: number)
	screenShakeNearby(p, p2, p3, p4)
end

function ImpactFx.explosion(p: number, p2: number, p3: number, p4: number, color: Color3?)
	local vector2 = Vector3.new(p, p2, p3)
	local v2 = p4 * 1.3
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(2, 2, 2)
	part.CFrame = CFrame.new(p, p2, p3)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color or Color3.fromRGB(255, 80, 30)
	part.Transparency = 0
	part.Parent = ClientDebris()
	TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(v2, v2, v2)
	}):Play()
	task.delay(0.2, function()
		if not part.Parent then
			return
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		})
		tween.Completed:Once(function()
			tween:Destroy()
			pcall(function()
				part:Destroy()
			end)
		end)
		tween:Play()
	end)
	thunderHitAt(vector2, 5)
	playSpatialSound(vector2, "rbxassetid://135676461695962", 1)
	playSpatialSound(vector2, "rbxassetid://139520673393967", 0.65)
	screenShakeNearby(p, p2, p3, p4 * 2.5)
end

return ImpactFx