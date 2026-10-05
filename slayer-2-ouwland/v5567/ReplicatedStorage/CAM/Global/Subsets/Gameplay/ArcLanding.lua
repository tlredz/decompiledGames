local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return {
	Resolve = function(player)
		local v = (player.Goal - player.From) * createVector(1, 0, 1)
		local goal

		if v.Magnitude < 0.01 then
			goal = player.Goal
		else
			local unit = v.Unit
			local v2 = math.min(v.Magnitude, player.Range)

			if player.Target ~= nil then
				v2 = math.max(v2 - 5, 0)
			end

			local raycastResult = workspace:Raycast(player.From, unit * v2, RaycastHelper.Crater)

			if raycastResult ~= nil then
				v2 = math.max(raycastResult.Distance - 5, 0)
			end

			goal = player.From + unit * v2
		end

		if player.Target ~= nil then
			return (Vector3.new(goal.X, player.Goal.Y, goal.Z))
		end

		local vector2 = Vector3.new(goal.X, player.Goal.Y + 5, goal.Z)
		local raycastResult = workspace:Raycast(vector2, createVector(0, -30, 0), RaycastHelper.Crater)

		if raycastResult == nil then
			return nil
		end

		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
		local v2 = (humanoid == nil and 2 or humanoid.HipHeight) + ((humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart")) and 1 or humanoidRootPart.Size.Y / 2)
		return raycastResult.Position + Vector3.new(0, v2, 0)
	end
}