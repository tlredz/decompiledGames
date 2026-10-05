local createVector = vector.create
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local remotes = ReplicatedStorage.Remotes
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")
local soundId = humanoidRootPart.Running.SoundId
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://82598234841035"
local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action
local v = false
local v2 = 0
task.spawn(function()
	ContentProvider:PreloadAsync({ animation })
end)
local v3 = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { parent }

-- equivalent calls inferred from this helper; original call sites unknown
local function checkOutdoors()
	local position = humanoidRootPart.Position
	local raycastResult = workspace:Raycast(position, createVector(0, 500, 0), raycastParams)

	if raycastResult and raycastResult.Instance then
		return CollectionService:HasTag(raycastResult.Instance, "GameBoundary")
	end

	return false
end

local function updateLoop()
	local v4 = humanoid.MoveDirection.Magnitude > 0.1
	local v5 = humanoid.FloorMaterial == Enum.Material.Ice
	local v6

	if v4 and v5 then
		local now = os.clock()

		if now - v2 > 0.25 then
			v = checkOutdoors() -- equivalent call inferred; original call site unknown
			v2 = now
		end

		v6 = v
	else
		v6 = false
	end

	if v6 then
		if not track.IsPlaying then
			track:Play(0.2)
			humanoidRootPart.Running.SoundId = "rbxassetid://9114868847"
		end

		if not v3 then
			v3 = true
			remotes.IceSkate:FireServer("IceSkating")
		end
	else
		if track.IsPlaying then
			track:Stop(0.2)
			humanoidRootPart.Running.SoundId = soundId
		end

		if v3 and not v5 and humanoid.FloorMaterial ~= Enum.Material.Air then
			v3 = false
			remotes.IceSkate:FireServer("Stopped")
		end
	end
end

RunService.Heartbeat:Connect(updateLoop)