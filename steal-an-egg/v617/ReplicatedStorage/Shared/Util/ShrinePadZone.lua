local v = {
	ContainsPoint = function(instance, vector: Vector3, value: number?)
		if not instance.Anchored or instance.CFrame.UpVector.Y < 0.95 then
			return false
		end

		local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector)
		local v2 = value or 0.35
		return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 + v2 and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2 + v2 and pointToObjectSpace.Y >= -instance.Size.Y / 2 - 0.5 and pointToObjectSpace.Y <= instance.Size.Y / 2 + 12
	end
}

function v.ContainsCharacter(instance, instance2)
	if not instance2 then
		return false
	end

	local humanoid = instance2:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return false
	end

	if humanoid.Sit or humanoid.PlatformStand or not v.ContainsPoint(instance, humanoidRootPart.Position) or math.abs(humanoidRootPart.AssemblyLinearVelocity.Y) > 5 then
		return false
	end

	local v2 = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
	local leftLeg = instance2:FindFirstChild("Left Leg")

	if leftLeg and leftLeg:IsA("BasePart") then
		v2 += leftLeg.Size.Y
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { instance2 }
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position,
		Vector3.new(0, -math.min(v2 + 1.5, 12), 0),
		raycastParams
	)

	if not raycastResult or raycastResult.Normal.Y < 0.5 then
		return false
	end

	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(raycastResult.Position)
	return pointToObjectSpace.Y >= -instance.Size.Y / 2 - 1.5 and pointToObjectSpace.Y <= instance.Size.Y / 2 + 1.5
end

return table.freeze(v)