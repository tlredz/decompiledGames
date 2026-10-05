local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function raycastResult(p, p2, options, p3, p4)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = options or {}
	raycastParams.FilterType = p3 or Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = p4 or true
	return workspace:Raycast(p or Vector3.new(), p2 or Vector3.new(), raycastParams)
end

return function(data)
	local start = data.Start
	local goal = data.Goal
	local mod = data.Mod
	local mod2 = data.Mod2
	local object = data.Object
	local speed = data.Speed
	local maxDistance = data.MaxDistance
	local filter = data.Filter
	local afterClass = data.AfterClass
	local updateClass = data.UpdateClass
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

	local magnitude = (goal - start).Magnitude

	if maxDistance < magnitude then
		goal = (goal - start).Unit * maxDistance
		magnitude = maxDistance
	end

	local numberValue = Instance.new("NumberValue")
	local heartbeatConnection = nil
	local v = magnitude / speed
	TweenService:Create(numberValue, TweenInfo.new(v, Enum.EasingStyle.Quad), {
		Value = 1
	}):Play()
	task.delay(v + 0.016666666666666666, function()
		heartbeatConnection:Disconnect()
		hitProjectile() -- equivalent call inferred; original call site unknown
	end)
	heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		local value = numberValue.Value
		local v6 = (1 - value) ^ 3 * start + 3 * (1 - value) ^ 2 * value * mod + 3 * (1 - value) * value ^ 2 * mod2 + value ^ 3 * goal
		local v7 = value + 0.01
		local v12 = (1 - v7) ^ 3 * start + 3 * (1 - v7) ^ 2 * v7 * mod + 3 * (1 - v7) * v7 ^ 2 * mod2 + v7 ^ 3 * goal

		if updateClass then
			updateClass(CFrame.lookAt(v6, v12))
		else
			object.CFrame = CFrame.new(v6, v12)
		end

		local v13 = raycastResult(v6, (v12 - v6).Unit * object.Size.Y / 2, filter or {})

		if v13 and afterClass then
			heartbeatConnection:Disconnect()
			flag = true
			task.spawn(afterClass, v13)
		elseif maxDistance < (object.Position - start).Magnitude then
			hitProjectile() -- equivalent call inferred; original call site unknown
			heartbeatConnection:Disconnect()
		end
	end)
	return heartbeatConnection, numberValue
end