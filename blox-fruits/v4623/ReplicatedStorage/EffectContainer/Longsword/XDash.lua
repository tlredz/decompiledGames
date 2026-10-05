local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Longsword").X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	return part
end

local function adjustDuration(p, p2)
	local v = p - p2
	return v, p2 - (p - v)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp
	local origin = data.origin
	local fireDir = data.fireDir
	local targetPos = data.targetPos
	local duration = data.duration
	local indicator = data.Indicator
	local v = math.max(0, Util.MasterClock:GetTime() - data.ClockTime)

	if not indicator or (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local v2 = duration - v
	local _ = v - (duration - v2)
	local parent = hrp.Parent

	if data.player == game.Players.LocalPlayer then
		origin = hrp.Position
	end

	local cframe = CFrame.lookAt(origin, origin + fireDir)
	Util.Sound:Play("SpikeSpinStart", hrp)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	destroyAfter(folder, 10)
	local clone = X.Phase1.StartImpact:Clone()
	clone.CFrame = cframe * CFrame.new(0, 0, hrp.Size.Z)
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	local clone2 = X.Phase1.Dash:Clone()
	clone2.CFrame = cframe
	clone2.Parent = folder
	clone2.Weld.Part0 = hrp

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local lastTime = tick()

	if v2 > 0 then
		repeat
			local v4 = math.min(1, (tick() - lastTime) / v2)
			local v5 = origin + (targetPos - origin) * v4
			local ray, _, _ = Util.Ray(origin, (v5 - origin) * 1.01, { parent })
			RunService.Heartbeat:Wait()
		until ray or not indicator or not indicator:IsDescendantOf(workspace) or not indicator:GetAttribute("Traveling") or v4 == 1
	end

	local position = indicator:GetAttribute("Position")

	if position then
		hrp.CFrame = CFrame.new(createVector(0, 0, 0), fireDir) + position
	end

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.delay(0.7, function()
		clone2:Destroy()
	end)
end