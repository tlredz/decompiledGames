wait(1)
local parent = script.Parent
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
humanoidRootPart.Anchored = false
local v = nil
local count = 0

while true do
	local position = humanoidRootPart.Position

	if not v or not v.Parent or not v.Character or count > 10 then
		local v2 = 9999
		v = nil

		for _, v3 in pairs(game.Players:GetPlayers()) do
			if not (v3.Character and v3.Character:FindFirstChild("HumanoidRootPart")) then
				continue
			end

			local magnitude = (v3.Character:FindFirstChild("HumanoidRootPart").Position - position).magnitude

			if not (magnitude < v2) then
				continue
			end

			v = v3
			v2 = magnitude
			count = 0
		end
	end

	local humanoidRootPart2 = v and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 then
		local walkToPoint = humanoidRootPart2.Position + humanoidRootPart2.CFrame.RightVector * 4

		if (walkToPoint - position).magnitude > 7 then
			parent.Humanoid.WalkToPoint = walkToPoint
		end
	end

	count += 1
	task.wait(0.5)
end