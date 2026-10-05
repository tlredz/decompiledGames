local createVector = vector.create
local Players = game:GetService("Players")
local leaderboards = workspace.Meta.Leaderboards
local v = {}
local flag = false

local function playAnimation(instance)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://78794943616887"
	local track = animator:LoadAnimation(animation)
	track:Play()
	track.Looped = true
end

local function processAvatarQueueItem(userId, podiumSpawn)
	for _, model in pairs(podiumSpawn:GetChildren()) do
		if model:IsA("Model") then
			model:Destroy()
		end
	end

	if not userId then
		return
	end

	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescription(
			Players:GetHumanoidDescriptionFromUserId(userId),
			Enum.HumanoidRigType.R6
		)
	end)

	if not success then
		return
	end

	result.Parent = podiumSpawn
	result.HumanoidRootPart.Anchored = true
	result:SetPrimaryPartCFrame(podiumSpawn.CFrame + createVector(0, 1.8, 0))
	local humanoid = result:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

local function ensureAvatarWorker()
	if flag then
		return
	end

	flag = true

	while true do
		local v2 = table.remove(v, 1)

		if not v2 then
			break
		end

		processAvatarQueueItem(v2.UserId, v2.PodiumSpawn)
		task.wait(1)
	end

	flag = false
end

local function hookPodium(part)
	local displayUserId = part:GetAttribute("DisplayUserId")
	table.insert(v, {
		UserId = displayUserId,
		PodiumSpawn = part
	})
	task.spawn(ensureAvatarWorker)
	part:GetAttributeChangedSignal("DisplayUserId"):Connect(function()
		local displayUserId2 = part:GetAttribute("DisplayUserId")
		table.insert(v, {
			UserId = displayUserId2,
			PodiumSpawn = part
		})
		task.spawn(ensureAvatarWorker)
	end)
end

return {
	Priority = 5,
	Run = function()
		for _, part in ipairs(leaderboards:GetDescendants()) do
			if part.Name:match("^PodiumSpawn") and part:IsA("BasePart") then
				hookPodium(part)
			end
		end
	end
}