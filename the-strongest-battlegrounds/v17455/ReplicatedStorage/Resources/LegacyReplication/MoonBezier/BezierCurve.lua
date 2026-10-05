local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BezierCurve = {}

local function lerp(position, position2, p: number)
	if typeof(position) == "Instance" then
		position = position.Position
	end

	if typeof(position2) == "Instance" then
		position2 = position2.Position
	end

	return position:Lerp(position2, p)
end

local lerpPoints

lerpPoints = function(list, p: number)
	local v = list[1]
	local v2 = list[2]
	local v3 = {}

	for i = 2, #list do
		table.insert(v3, lerp(v, v2, p))
		v = list[i]
		v2 = list[i + 1]
	end

	if #v3 == 1 then
		return v3[1]
	end

	return lerpPoints(v3, p)
end

function BezierCurve:Play(list, flag: boolean, data)
	local duration = data.Duration
	local easingStyle = data.EasingStyle
	local easingDirection = data.EasingDirection
	local lookAt = data.LookAt
	local lastTime = os.clock()
	local pointsInObjectSpace = data.PointsInObjectSpace
	local cFrame

	if pointsInObjectSpace then
		cFrame = self.CFrame
	else
		cFrame = nil
	end

	local thread = coroutine.running()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local value = TweenService:GetValue((os.clock() - lastTime) / duration, easingStyle, easingDirection)

		if value >= 1 then
			heartbeatConnection:Disconnect()
			local position = list[#list]

			if typeof(position) == "Instance" then
				position = position.Position
			end

			if pointsInObjectSpace then
				position = cFrame:PointToWorldSpace(position)
			end

			if lookAt then
				local position2

				if typeof(lookAt) == "Instance" then
					position2 = lookAt.Position
				elseif typeof(lookAt) == "Vector3" then
					position2 = lookAt
				else
					position2 = position
				end

				local orientation, v2, v3 = CFrame.lookAt(self.Position, position2):ToOrientation()
				self.CFrame = CFrame.new(position) * CFrame.fromOrientation(orientation, v2, v3)
			else
				self.Position = position
			end

			if flag then
				coroutine.resume(thread)
			end
		else
			local position2 = lerpPoints(list, value)

			if pointsInObjectSpace then
				position2 = cFrame:PointToWorldSpace(position2)
			end

			if lookAt then
				local position

				if typeof(lookAt) == "Instance" then
					position = lookAt.Position
				elseif typeof(lookAt) == "Vector3" then
					position = lookAt
				else
					position = position2
				end

				local orientation, v3, v4 = CFrame.lookAt(self.Position, position):ToOrientation()
				self.CFrame = CFrame.new(position2) * CFrame.fromOrientation(orientation, v3, v4)
			else
				self.Position = position2
			end
		end
	end)

	if flag then
		coroutine.yield()
	end

	return heartbeatConnection
end

return BezierCurve