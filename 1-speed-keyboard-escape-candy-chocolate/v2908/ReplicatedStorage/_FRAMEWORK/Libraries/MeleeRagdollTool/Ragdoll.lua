local createVector = vector.create
require(script.Parent.Types)
local v = {}

local function restoreAfterTrip(p: number, userId: number, object, object2)
	if v[userId] ~= p then
		return
	end

	v[userId] = nil

	if object.Parent and object.Health > 0 then
		object.PlatformStand = false
		object:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if object2.Parent then
		object2.AssemblyAngularVelocity = createVector(0, 0, 0)
		pcall(function()
			object2:SetNetworkOwnershipAuto()
		end)
	end
end

return {
	apply = function(p, instance, object, object2, data)
		local v2 = object.Position - instance.Position
		local vector2 = Vector3.new(v2.X, 0, v2.Z)
		local unit

		if vector2.Magnitude > 0 then
			unit = vector2.Unit
		else
			unit = instance.CFrame.LookVector
		end

		local v3 = 1 + math.random()
		local v4 = 0.7 + math.random() * 0.6
		local userId = p.UserId
		local v5 = (v[userId] or 0) + 1
		v[userId] = v5
		object:SetNetworkOwner(nil)
		object2.PlatformStand = true
		object2:ChangeState(Enum.HumanoidStateType.Physics)
		object.AssemblyLinearVelocity = unit * (data.horizontalSpeed * v3) + Vector3.new(0, data.verticalSpeed * v3, 0)
		object.AssemblyAngularVelocity = Vector3.new(
			(math.random() * 2 - 1) * data.angularSpeed,
			(math.random() * 2 - 1) * data.angularSpeed,
			(math.random() * 2 - 1) * data.angularSpeed
		) * v4
		task.delay(data.tripDurationSeconds, function()
			restoreAfterTrip(v5, userId, object2, object)
		end)
	end
}