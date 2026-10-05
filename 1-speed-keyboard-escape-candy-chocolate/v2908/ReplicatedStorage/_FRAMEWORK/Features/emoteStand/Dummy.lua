local Players = game:GetService("Players")
local v = nil
local flag = false

local function prepare(folder)
	local animate = folder:FindFirstChild("Animate")

	if animate then
		animate:Destroy()
	end

	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.EvaluateStateMachine = false

		if not humanoid:FindFirstChildOfClass("Animator") then
			local animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end
end

local function getTemplate()
	while flag do
		task.wait(0.1)
	end

	if v then
		return v
	end

	flag = true

	for _, v2 in { not (Players.LocalPlayer.UserId > 0) and 1 or Players.LocalPlayer.UserId, 1 } do
		local v3 = v2
		local success, result = pcall(function()
			return Players:CreateHumanoidModelFromUserIdAsync(v3)
		end)

		if not (success and result) then
			continue
		end

		prepare(result)
		result.Archivable = true
		result.Parent = script
		v = result
		break
	end

	flag = false
	return v
end

return {
	create = function()
		local template = getTemplate()

		if template then
			return template:Clone()
		end

		return nil
	end
}