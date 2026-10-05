local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService2 = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function emberBlob(value, p, p2, p3)
	local v = value or 3
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, v)
	part.CanCollide = false
	part.Anchored = true
	part.Size = createVector(2, 2, 5)
	part.Color = Color3.fromRGB(188, 155, 93)
	part.Material = Enum.Material.Neon
	part.CFrame = p3.CFrame
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = part

	for k, v2 in pairs(p3) do
		part[k] = v2
	end

	part.Parent = _WorldOrigin
	local tween = TweenService:Create(
		part,
		TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0, 0, 0),
			Color = Color3.fromRGB(255, 85, 0)
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	local lastTime = tick()
	spawn(function()
		tween:Play()
		local v2 = 1

		while tick() - lastTime < v do
			local _ = (tick() - lastTime) / v
			part.CFrame = part.CFrame * CFrame.new(0, 0, -p2) * CFrame.Angles(
				math.rad(p * math.cos(v2 / 5 + math.random(-15, 15) / 10)),
				0,
				0
			)
			v2 += 1
			RunService.RenderStepped:Wait()
		end

		if part then
			part:Destroy()
		end
	end)
end

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local clone = FX:WaitForChild("DragonEffects").DragonExplosion:Clone()

for k, _ in pairs({
	Main = 1.2,
	BlackMain = 1.2,
	WindRings = 0.16666666666666666,
	Smoke = 0.5,
	Rocks = 0.16666666666666666,
	Bits = 0.4,
	Bubble = 0.16666666666666666
}) do
	ScaleParticle(clone[k], 10)
end

local function explosionEffect(p, p2)
	Util.Sound:Play("ShortExplosion2", p, nil, 1 + math.random(-20, 20) / 100, 1)
	local clone2 = clone:Clone()
	Util.Debris:AddItem(clone2, 3)
	clone2.CFrame = CFrame.new(p, p + ((p2 == nil or not p2) and createVector(0, 1, 0) or p2)) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
	clone2.Parent = workspace._WorldOrigin

	for k, v in pairs({
		Main = 1.2,
		BlackMain = 1.2,
		WindRings = 0.16666666666666666,
		Smoke = 0.5,
		Rocks = 0.16666666666666666,
		Bits = 0.4,
		Bubble = 0.16666666666666666
	}) do
		clone2[k]:Emit(v * 6)
	end
end

return function(data)
	local stage = data.Stage
	local cFrame = data.CFrame
	local char = data.Char

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 750 then
		return
	end

	if stage == 1 then
		local _ = data.MouseP
		local timestamp = data.Timestamp
		local distance = data.Distance
		local lifetime = data.Lifetime
		local v = masterClock:GetTime() - timestamp
		local _ = cFrame.lookVector
		local v2 = math.random(2, 3)
		local v3 = math.random(6, 12)
		local v4 = { math.random(-55, -25), math.random(25, 55) }
		local v5 = { math.random(-55, -25), math.random(25, 55) }
		local v6 = { math.random(-55, -25), math.random(25, 55) }
		emberBlob(math.random(4, 5) / 10, 12, 2, {
			CFrame = cFrame * CFrame.Angles(
				math.rad(v4[math.random(1, #v4)]),
				math.rad(v5[math.random(1, #v5)]),
				(math.rad(v6[math.random(1, #v6)]))
			),
			Color = Color3.fromRGB(188, 155, 93),
			Size = Vector3.new(v2, v2, v3)
		})
		local clone2 = FX:WaitForChild("DragonEffects").DragonRainProjectile:Clone()
		Util.Debris:AddItem(clone2, lifetime + 1)
		local root = clone2.Root
		local _ = clone2.Firenet2
		local _ = clone2.Firenet1
		clone2:SetPrimaryPartCFrame(cFrame)
		clone2.Parent = _WorldOrigin
		local parent = Util.Sound:Play("FlamePop", root.Position, nil, 1 + math.random(-10, 10) / 100, 0.8)
		local chorusSoundEffect = Instance.new("ChorusSoundEffect")
		chorusSoundEffect.Parent = parent
		parent.TimePosition = 0.2
		local lastTime = tick()
		local v8 = lifetime - v
		local _ = root.CFrame

		while tick() - lastTime < v8 do
			local _ = (tick() - lastTime) / v8
			local v9 = (tick() - lastTime) / 100 / (v8 / 100)
			local cFrame2 = root.CFrame
			clone2:SetPrimaryPartCFrame(cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v9))
			local magnitude = (cFrame2.p - root.Position).Magnitude
			local ray, v10, v11 = Util.Ray(cFrame2.p, cFrame2.lookVector.Unit * magnitude, { char }, false)

			if ray then
				Util.Debris:AddItem(clone2, 1)

				for _, part in pairs(clone2:GetChildren()) do
					if part:IsA("BasePart") then
						part.Transparency = 1
					end
				end

				explosionEffect(v10, v11 or nil)
				break
			else
				RunService2.RenderStepped:Wait()
			end
		end

		if clone2 then
			clone2:Destroy()
		end
	elseif stage == 2 then
		explosionEffect(cFrame.p)
	end
end