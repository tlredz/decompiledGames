game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local rikaRig = parent:WaitForChild("RikaRig")
local rootPart = rikaRig:WaitForChild("RootPart")
local value = parent:WaitForChild("Owner").Value
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = localPlayer.Character == value
local effects = script.Parent.Effects
rootPart.CFrame = script.Parent.CFrame
local track = rikaRig.Control:LoadAnimation(script.Idle)
track:Play()
track.Priority = Enum.AnimationPriority.Idle
local sounds = ReplicatedStorage.Sounds

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(instance)
	local clone = instance:Clone()
	clone.Parent = script.Parent
	clone:Play()
	task.delay(instance.TimeLength, function()
		clone:Destroy()
	end)
	return clone
end

local track2 = rikaRig.Control:LoadAnimation(script.Spawn)
track2:Play(0)
playSound(sounds.Yuta.Rika.Summon) -- equivalent call inferred; original call site unknown

if v then
	task.delay(0.4, function()
		playSound(sounds.Yuta.Rika.SummonVL) -- equivalent call inferred; original call site unknown
	end)
end

local tracksByName = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function animLoad(animation)
	local track3 = rikaRig.Control:LoadAnimation(animation)
	track3:Play(nil, 0.01)
	tracksByName[animation.Name] = track3
	track3.Priority = Enum.AnimationPriority.Movement
end

animLoad(script:WaitForChild("F")) -- equivalent call inferred; original call site unknown
animLoad(script:WaitForChild("B")) -- equivalent call inferred; original call site unknown
animLoad(script:WaitForChild("L")) -- equivalent call inferred; original call site unknown
animLoad(script:WaitForChild("R")) -- equivalent call inferred; original call site unknown

function isRikaObstructing()
	if parent.Info:FindFirstChild("InSkill") then
		return false
	end

	if script.Parent:GetAttribute("Invisible") or v then
		return true
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if script.Parent.Info:FindFirstChild("Transparent") then
		return true
	end

	local cFrame = currentCamera.CFrame
	local cFrame2 = script.Parent.CFrame

	if (cFrame2.Position - cFrame.Position).Unit:Dot(cFrame.LookVector) > 0.7 then
		return (humanoidRootPart.Position - cFrame.Position).Magnitude > (cFrame2.Position - cFrame.Position).Magnitude
	end
end

local v2 = false
local v3 = false

function updateRikaTransparency()
	if parent:GetAttribute("Invisible") and not (v or parent.Info:FindFirstChild("InSkill")) then
		if not v2 then
			for _, descendant in rikaRig:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.LocalTransparencyModifier = 1
				elseif descendant:IsA("ParticleEmitter") then
					descendant.LocalTransparencyModifier = 1
				end
			end
		end

		v2 = true
	elseif isRikaObstructing() then
		if not v3 then
			for _, descendant in rikaRig:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.LocalTransparencyModifier = v and 0.9 or 0.7
				elseif descendant:IsA("ParticleEmitter") then
					descendant.LocalTransparencyModifier = v and 1 or 0.98
				end
			end
		end

		v3 = true
	else
		if v3 or v2 then
			for _, descendant in rikaRig:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("ParticleEmitter") then
					descendant.LocalTransparencyModifier = 0
				end
			end
		end

		v3 = false
		v2 = false
	end
end

local renderSteppedConnection = nil
local RunService = game:GetService("RunService")
renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	if script.Parent:GetAttribute("Dead") then
		renderSteppedConnection:Disconnect()
		return
	end

	if v then
		script.Parent:GetAttribute("Move")
	end

	local position = rootPart.Position

	if script.Parent.Info:FindFirstChild("SnapPosition") then
		rootPart.CFrame = script.Parent.CFrame
	else
		rootPart.CFrame = rootPart.CFrame:Lerp(script.Parent.CFrame, 7 * dt)
	end

	local v4 = (rootPart.Position - position) * 4
	local vectorToObjectSpace = rootPart.CFrame:VectorToObjectSpace(v4)
	tracksByName.F:AdjustWeight((math.clamp(-vectorToObjectSpace.Z * 1, 0.01, 1)))
	tracksByName.B:AdjustWeight((math.clamp(vectorToObjectSpace.Z * 1, 0.01, 1)))
	tracksByName.L:AdjustWeight((math.clamp(-vectorToObjectSpace.X * 1, 0.01, 1)))
	tracksByName.R:AdjustWeight((math.clamp(vectorToObjectSpace.X * 1, 0.01, 1)))
	updateRikaTransparency()
end)
script.Parent:GetAttributeChangedSignal("Dead"):Once(function()
	local clone = playSound(sounds.Yuta.Rika.Desummon) -- equivalent call inferred; original call site unknown
	local volume = clone.Volume
	track2:Play()
	track2:AdjustSpeed(-1.2)
	track2.TimePosition = track2.Length - 0.2
	local lastTime = tick()

	repeat
		task.wait()
		local v5 = 1 - math.clamp((tick() - lastTime) / 0.5, 0, 0.99)
		rikaRig:ScaleTo(v5)
		clone.Volume = volume * v5
	until tick() - lastTime > 0.5

	rikaRig:Destroy()
end)
local CameraShaker = require(ReplicatedStorage.Modules.CameraShaker)
local v4 = {
	UltimateStart = function(p)
		if p == "Zero" then
			playSound(sounds.Yuta.Rika.UltimateZero.Start) -- equivalent call inferred; original call site unknown
			playSound(sounds.Yuta.Rika.UltimateZero.Voiceline) -- equivalent call inferred; original call site unknown
		else
			playSound(sounds.Yuta.Rika.Ultimate.Start) -- equivalent call inferred; original call site unknown
		end
	end,
	Break = function()
		playSound(sounds.Yuta.Rika.Ultimate.Break) -- equivalent call inferred; original call site unknown
	end,
	StartScream = function(p)
		rikaRig.Head.Mouth.Out.Enabled = true
		local v5

		if v then
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			v5 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
		end

		repeat
			task.wait(0.2)
		until not p.Parent

		if v5 then
			v5:StartFadeOut(1)
		end

		rikaRig.Head.Mouth.Out.Enabled = false
	end,
	Teleport = function(p)
		rootPart.CFrame = p or script.Parent.CFrame
	end
}
effects.OnClientEvent:Connect(function(p, ...)
	local v5 = v4[p]

	if v5 then
		v5(...)
	end
end)

if v then
	local remote = script:WaitForChild("Remote")
	local humanoid = value:WaitForChild("Humanoid")
	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		remote:FireServer(humanoid.MoveDirection)
	end)
end