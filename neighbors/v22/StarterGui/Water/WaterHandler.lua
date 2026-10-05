local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local CameraShaker = require(script.CameraShaker)
local localPlayer = Players.LocalPlayer
local sounds = script:WaitForChild("Sounds")
localPlayer:GetMouse()
local waterBlur = Lighting:FindFirstChild("WaterBlur") or Instance.new("BlurEffect")
waterBlur.Name = "WaterBlur"
waterBlur.Size = 0
waterBlur.Enabled = true
waterBlur.Parent = Lighting
local v = nil
local v2 = 0
local track = nil
local track2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandomNumber(p: number, p2: number)
	return Random.new():NextNumber(p, p2)
end

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandomPosition()
	local v3 = math.random() * 2 * 3.141592653589793
	local randomNumber = getRandomNumber(0, 0.4) -- equivalent call inferred; original call site unknown
	local v4 = randomNumber * math.cos(v3)
	local v5 = randomNumber * math.sin(v3)
	return UDim2.new(0.5 + v4, 0, 0.5 + v5, 0)
end

v = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	currentCamera.CFrame *= p
	local v3 = RunService.Heartbeat:Wait()
	local v4 = waterBlur
	local size = waterBlur.Size
	local v5 = v2 * 1
	local v6 = v3 * 15
	v4.Size = size + (v5 - size) * v6
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if v2 <= 0 then
		if track then
			track:Stop()
			track:Destroy()
			track = nil
		end

		if track2 then
			track2:Stop()
			track2:Destroy()
			track2 = nil
		end

		if v._running then
			waterBlur.Size = 0
			v:Stop()
		end
	else
		if not humanoid then
			return
		end

		if not track and script:FindFirstChild("Idle") then
			track = humanoid:LoadAnimation(script.Idle)
		end

		if not track2 and script:FindFirstChild("Run") then
			track2 = humanoid:LoadAnimation(script.Run)
		end

		if humanoid.MoveDirection.Magnitude > 0 then
			if track and track.IsPlaying then
				track:Stop()
			end

			if track2 and not track2.IsPlaying then
				track2:Play()
			end
		else
			if track and not track.IsPlaying then
				track:Play()
			end

			if track2 and track2.IsPlaying then
				track2:Stop()
			end
		end
	end
end)

local function playRandomSpitSound()
	local children = sounds:GetChildren()
	local clone = children[math.random(1, #children)]:Clone()
	clone.Parent = workspace
	clone:Play()
	clone.Ended:Connect(function()
		task.wait(1)
		clone:Destroy()
	end)
end

local function createSpitSplatterEffect()
	local clone = script.Sample:Clone()
	local randomNumber = getRandomNumber(0.4, 0.8) -- equivalent call inferred; original call site unknown
	clone.ImageTransparency = 0.3
	clone.Rotation = math.random() * 360
	clone.Size = UDim2.fromScale(0, 0)
	clone.Position = getRandomPosition()
	clone.Parent = script.Parent
	v2 += 1
	TweenService:Create(clone, TweenInfo.new(0.2), {
		Size = UDim2.fromScale(randomNumber, randomNumber)
	}):Play()
	task.delay(Random.new():NextNumber(0.5, 1.5), function()
		task.delay(Random.new():NextNumber(1, 2), function()
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(Random.new():NextNumber(0.5, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					ImageTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				clone:Destroy()
				v2 -= 1
			end)
		end)
		local v3 = Random.new():NextNumber(0.5, 1.5) * (math.random(1, 2) == 1 and -1 or 1)
		local v4 = -Random.new():NextNumber(60, 100)
		local randomNumber2 = getRandomNumber(-20, 20) -- equivalent call inferred; original call site unknown
		local total = 0
		local total2 = -70
		local lastTime = os.clock()
		task.spawn(function()
			while clone.Parent do
				local v5 = os.clock() - lastTime
				local v6 = RunService.Heartbeat:Wait()
				total += randomNumber2 * v6
				total2 += v4 * v6
				local position = clone.Position
				local v7 = math.sin(v3 * v5) * 0
				clone.Position = UDim2.new(position.X.Scale, v7, position.Y.Scale, position.Y.Offset) + UDim2.new(
					0,
					0,
					0,
					-total2 * v6
				)
				clone.Rotation += total * v6
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function triggerSplatter()
	for _ = 1, math.random(1, 3) do
		createSpitSplatterEffect()
	end
end

Network:listen("Water", function()
	playRandomSpitSound()
	triggerSplatter() -- equivalent call inferred; original call site unknown

	if not v._running then
		v:Start()
	end

	v:Shake(v.Presets.Bump)
end)
script.AncestryChanged:Connect(function(_, parent)
	if not parent then
		waterBlur:Destroy()
	end
end)