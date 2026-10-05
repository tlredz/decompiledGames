local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function parabolic(value, value2, value3)
	local v = value or 0
	local v2 = value3 or 1
	return 4 * ((value2 or 0) / v2) * (-v ^ 2 / v2 + v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ballisticTrajectory(initPos: Vector3, goalPos: Vector3, maxHeightOffset: number, p: number)
	local v = initPos + (goalPos - initPos) * p
	local v2 = p * (goalPos - initPos).Magnitude or 0
	local magnitude = (goalPos - initPos).Magnitude or 1
	return v + createVector(0, 1, 0) * (4 * ((maxHeightOffset or 0) / magnitude) * (-v2 ^ 2 / magnitude + v2))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("Longsword").Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function adjustDuration(p, p2)
	local v = p - p2
	return v, p2 - (p - v)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp
	local humanoid = hrp.Parent:FindFirstChildOfClass("Humanoid")
	local indicator = data.Indicator

	if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude > 800 then
		return
	end

	local initPos = data.initPos
	local goalPos = data.goalPos
	local maxHeightOffset = data.maxHeightOffset
	local duration = data.Duration
	local v = math.max(0, Util.MasterClock:GetTime() - data.ClockTime)
	local _ = data.player == game.Players.LocalPlayer
	Util.Sound:Play("RubberRocketFling", hrp, 10, nil, 0.66)
	local clone = Z.LeapTrail:Clone()
	clone.CFrame = hrp.CFrame
	clone.Parent = _WorldOrigin
	clone.Weld.Part0 = hrp
	Util.Debris:AddItem(clone, 7)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local v2 = tick() - v

	if duration > 0 then
		local v3 = initPos

		while true do
			local lastTime = tick()
			local v4 = math.min(1, (lastTime - v2) / duration)
			local v6 = ballisticTrajectory(initPos, goalPos, maxHeightOffset, v4 + 0.022222222222222223) -- equivalent call inferred; original call site unknown

			if (v6 - v3).Magnitude < 0.01 then
				v6 += hrp.CFrame.LookVector * 0.01
			end

			if workspace:Raycast(v3, v6 - v3, raycastParams) or not (indicator and indicator:IsDescendantOf(workspace)) then
				break
			end

			local cFrame = CFrame.new(createVector(0, 0, 0), v6 - v3) + v6

			if hrp.Anchored == false then
				hrp.CFrame = cFrame
			end

			if v4 == 1 then
				break
			end

			RunService.Heartbeat:Wait()
			local _ = tick() - lastTime
			v3 = v6
		end
	end

	if hrp.Anchored == false then
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + hrp.CFrame.LookVector * createVector(1, 0, 1))
	end

	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end
end