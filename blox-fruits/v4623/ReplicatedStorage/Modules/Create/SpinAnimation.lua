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
						local v3

						if v2.Direction == "Left" then
							v3 = -dt
						else
							v3 = dt
						end

						k.Rotation += v3 * v2.Speed
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

return function(instance, p)
	if v[instance] then
		v[instance].Cleanup()
	end

	local rotation = instance.Rotation

	if instance:GetAttribute("_OriginalRot") == nil then
		instance:SetAttribute("_OriginalRot", rotation)
	else
		rotation = instance:GetAttribute("_OriginalRot")
	end

	local function fn()
		v[instance] = nil
		instance.Rotation = rotation
	end

	v[instance] = {
		Speed = not (p and p.Speed) and 8 or p.Speed,
		Direction = not (p and p.Direction) and "Right" or p.Direction,
		Cleanup = fn
	}
	task.defer(tryStartLoop)
	return fn
end