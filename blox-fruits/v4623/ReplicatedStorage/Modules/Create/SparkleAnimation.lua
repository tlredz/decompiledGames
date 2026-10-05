local v = {}
local heartbeatConnection = nil

local function tryStartLoop()
	if not heartbeatConnection then
		local total = 0
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			if next(v) then
				total = 0

				for k, v2 in pairs(v) do
					if k.Parent then
						local elapsed = v2.Elapsed
						v2.Elapsed += dt
						local midpoint = (math.sin(elapsed * v2.Speed * 3.141592653589793 * 2) + 1) / 2
						v2.UIGradient.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(midpoint, 1),
							NumberSequenceKeypoint.new(1, 0)
						})
					else
						v2.Cleanup()
					end
				end
			elseif total >= 0.5 then
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			else
				total += dt
			end
		end)
	end
end

return function(parent, value: number?)
	if v[parent] then
		v[parent].Cleanup()
	end

	local v2 = parent:FindFirstChildOfClass("UIGradient")

	if v2 == nil then
		v2 = Instance.new("UIGradient")
		v2.Name = "SparkleUIGradient"
		v2.Parent = parent
	end

	local imageTransparency = parent.ImageTransparency

	if parent:GetAttribute("_OriginalImageTransparency") == nil then
		parent:SetAttribute("_OriginalImageTransparency", imageTransparency)
	else
		imageTransparency = parent:GetAttribute("_OriginalImageTransparency")
	end

	local function fn()
		v[parent] = nil
		parent.ImageTransparency = imageTransparency
	end

	v[parent] = {
		UIGradient = assert(v2),
		Elapsed = 0,
		Speed = value or 0.5,
		Cleanup = fn
	}
	task.defer(tryStartLoop)
	return fn
end