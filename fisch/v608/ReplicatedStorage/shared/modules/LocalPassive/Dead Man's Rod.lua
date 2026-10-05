local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("ReelController"):WaitForChild("Types"))
local module = require("./PassiveHandler")
local tentacleModel = script:WaitForChild("TentacleModel")
local spawnVFX = script:WaitForChild("SpawnVFX")
local v = nil
local v2 = nil
local flag = false

local function getRemoteEvents()
	if not v then
		v = Net:RemoteEvent("DeadMansRodTentacleVFX", -1)
	end

	if not v2 then
		v2 = Net:RemoteEvent("DeadMansRodTentacleRequest", -1)
	end

	return v, v2
end

local function spawnTentacleVFX(position: Vector3)
	local clone = tentacleModel:Clone()
	Vector3.new(math.random(-5, 5), math.random(-3, 0), math.random(-5, 5))
	clone:PivotTo(CFrame.new(position) * CFrame.new(0, -10, 0))
	clone.Parent = workspace
	TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(position) * CFrame.new(0, 10, 0)
	}):Play()
	local animationController = clone.AnimationController
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://88781187323832"
	local track = animationController:LoadAnimation(animation)
	track:Play()
	track.Looped = false
	task.delay(0.5, function()
		local clone2 = spawnVFX:Clone()
		clone2.CFrame = CFrame.new(position)
		clone2.Anchored = true
		clone2.CanCollide = false
		clone2.CanQuery = false
		clone2.CanTouch = false
		clone2.Parent = workspace
		local clone3 = script.WaterSplash:Clone()
		clone3.Parent = clone2

		for _, emitter in clone2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		clone3:Play()
		task.delay(clone3.TimeLength, function()
			clone2:Destroy()
		end)
	end)
	track.Stopped:Once(function()
		local tween = TweenService:Create(
			clone.PrimaryPart,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				CFrame = CFrame.new(position) * CFrame.new(0, -10, 0),
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupVFXListener()
	if flag then
		return
	end

	flag = true

	if not v then
		v = Net:RemoteEvent("DeadMansRodTentacleVFX", -1)
	end

	if not v2 then
		v2 = Net:RemoteEvent("DeadMansRodTentacleRequest", -1)
	end

	v.OnClientEvent:Connect(function(vector: Vector3)
		spawnTentacleVFX(vector)
	end)
end

local DeadManSRod = {
	Morph = function(p, p2, object)
		if not object.rod then
			warn("Dead Mans Rod passive canceled: No active rod tool!")
			return
		end

		local bobber = object.rod:FindFirstChild("bobber")
		local config = p.config
		setupVFXListener() -- equivalent call inferred; original call site unknown
		task.spawn(function()
			object:WaitUntilReady()

			if not v then
				v = Net:RemoteEvent("DeadMansRodTentacleVFX", -1)
			end

			if not v2 then
				v2 = Net:RemoteEvent("DeadMansRodTentacleRequest", -1)
			end

			local v3 = v2
			local v4 = 0
			local value = bobber and (bobber:IsA("ObjectValue") and bobber.Value or bobber)

			if value then
				p.reelTrove:Add(object.OnLogicStep:Connect(function(p3)
					if object.progress < config.PROGRESS_THRESHOLD then
						return
					end

					v4 -= p3

					if v4 > 0 then
						return
					end

					local position = value.Position
					v4 += config.SPAWN_INTERVAL
					v3:FireServer(position, 1)
					spawnTentacleVFX(position)
					object:AddProgress(config.TENTACLE_HIT_PROGRESS_GAIN)
				end))
			else
				warn((`Could not find bobber part! "{p2.Name}"`))
			end
		end)
	end
}
setmetatable(DeadManSRod, module)
return DeadManSRod