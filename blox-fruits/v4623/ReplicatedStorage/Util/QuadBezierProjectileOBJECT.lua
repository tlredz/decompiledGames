local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function raycastResult(p, p2, options, p3, p4)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = options or {}
	raycastParams.FilterType = p3 or Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = p4 or true
	return workspace:Spherecast(p or Vector3.new(), 1, p2 or Vector3.new(), raycastParams)
end

return function(data)
	local start = data.Start
	local goal = data.Goal
	local mod = data.Mod
	local object = data.Object
	local speed = data.Speed
	local maxDistance = data.MaxDistance
	local filter = data.Filter
	local afterClass = data.AfterClass
	local updateClass = data.UpdateClass
	local duration = data.Duration
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hitProjectile()
		if flag then
			return
		end

		flag = true
		task.spawn(afterClass, {
			Instance = object,
			Position = object.Position,
			Normal = createVector(0, 1, 0)
		})
	end

	local magnitude = not duration and (goal.Position - start).Magnitude

	if magnitude and maxDistance < magnitude then
		goal.Position = (goal.Position - start).Unit * maxDistance
		magnitude = maxDistance
	end

	local numberValue = Instance.new("NumberValue")
	local heartbeatConnection = nil
	local v = duration or magnitude / speed
	TweenService:Create(numberValue, TweenInfo.new(v, Enum.EasingStyle.Quad), {
		Value = 1
	}):Play()
	task.delay(v + 0.016666666666666666, function()
		heartbeatConnection:Disconnect()
		hitProjectile() -- equivalent call inferred; original call site unknown
	end)
	heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		local value = numberValue.Value
		local position = goal.Position
		local v4 = (1 - value) ^ 2 * start + 2 * (1 - value) * value * mod + value ^ 2 * position
		local v5 = value + 0.01
		local position2 = goal.Position
		local v8 = (1 - v5) ^ 2 * start + 2 * (1 - v5) * v5 * mod + v5 ^ 2 * position2

		if updateClass then
			updateClass(CFrame.lookAt(v4, v8))
		else
			object.CFrame = CFrame.new(v4, v8)
		end

		local unit = (v8 - v4).Unit
		local v9 = raycastResult(v4 - unit, unit * (object.Size.Y / 2 + 2), filter or {})

		if v9 and afterClass then
			heartbeatConnection:Disconnect()
			flag = true
			task.spawn(afterClass, v9)
		elseif maxDistance < (object.Position - start).Magnitude then
			hitProjectile() -- equivalent call inferred; original call site unknown
			heartbeatConnection:Disconnect()
		end
	end)
	return heartbeatConnection, numberValue
end