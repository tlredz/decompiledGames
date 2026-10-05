local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
return function(data)
	local victimCharacter = data.VictimCharacter
	local bossRoot = data.BossRoot
	local duration = data.Duration
	local offset = data.Offset or CFrame.identity
	local lateral = data.Lateral or 0

	if typeof(victimCharacter) ~= "Instance" or typeof(bossRoot) ~= "Instance" or (typeof(duration) ~= "number" or duration <= 0) then
		return
	end

	local humanoidRootPart = victimCharacter:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local v

	if character == nil then
		v = false
	else
		v = humanoidRootPart == character:FindFirstChild("HumanoidRootPart")
	end

	local v2

	if v and not victimCharacter:FindFirstChild("AntiMover") then
		humanoidRootPart.Anchored = true
		v2 = true
	else
		v2 = false
	end

	local lastTime = tick()

	while tick() - lastTime < duration and bossRoot.Parent and humanoidRootPart.Parent do
		humanoidRootPart.CFrame = CFrame.new(bossRoot.Position, bossRoot.Position + bossRoot.CFrame.LookVector) * offset * CFrame.new(
			lateral,
			0,
			0
		)
		RunService.PreSimulation:Wait()
	end

	if v2 and humanoidRootPart.Parent then
		humanoidRootPart.Anchored = false
	end
end