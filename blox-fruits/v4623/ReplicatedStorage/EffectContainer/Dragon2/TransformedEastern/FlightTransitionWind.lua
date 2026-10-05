local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraShakeAt(position: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

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
	destroyAfter(part, 14)
	return part
end

local WindBall = require(script:WaitForChild("WindBall"))
return function(data)
	local _ = data.player
	local hrp = data.hrp
	local dragonPart = data.dragonPart
	local lookVector = data.lookVector

	if hrp == nil or hrp.Parent == nil or dragonPart == nil or dragonPart.Parent == nil then
		warn("Missing hrp or dragonPart, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	cameraShakeAt(dragonPart.Position, 240, 4, 8, 0.1, 0.4) -- equivalent call inferred; original call site unknown
	local clone = FX:WaitForChild("WindBalls").WindBall:Clone()
	clone.Size *= 0.7
	clone.CFrame = CFrame.new(dragonPart.Position)
	clone.Parent = Workspace._WorldOrigin
	destroyAfter(clone, 7)
	WindBall(clone, FX:WaitForChild("WindBalls").WindBallFX, 0.25, clone.CFrame.Position, lookVector * 80, 0)
	local clone2 = FX:WaitForChild("Dragon2").TransformedEastern.FlightTransitionWind.LandImpact:Clone()
	clone2.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone2.Parent = Workspace._WorldOrigin

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
end