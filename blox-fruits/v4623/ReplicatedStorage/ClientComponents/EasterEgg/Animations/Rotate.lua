local RunService = game:GetService("RunService")
return function(instance)
	if not instance then
		return function() end
	end

	local position = instance:GetPivot().Position
	local total = 0
	local currentCamera = workspace.CurrentCamera

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getFPSFromDistance(magnitude: number)
		return math.clamp((magnitude - 30) / 70, 0, 1) * -35 + 40
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function createFrameSkipper()
		local v = 1
		return function(p: number)
			local v2 = 40 / p
			v += 1

			if v2 <= v then
				v -= v2
				return false
			else
				return true
			end
		end
	end

	local frameSkipper = createFrameSkipper() -- equivalent call inferred; original call site unknown
	local identity = CFrame.identity
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if instance:GetAttribute("IgnoreRotationEffect") then
			return
		end

		total += dt
		local positionOverride = instance:GetAttribute("PositionOverride") or position
		local fPSFromDistance = getFPSFromDistance((currentCamera.CFrame.Position - positionOverride).Magnitude) -- equivalent call inferred; original call site unknown

		if frameSkipper(fPSFromDistance) then
			return
		end

		local v = math.sin(total * 3) * 0.13962634015954636
		local v2 = math.cos(total * 3 * 0.8) * 0.13962634015954636
		local v3 = total * 1
		local rotationOverride = instance:GetAttribute("RotationOverride") or CFrame.Angles(0, v3, 0) * CFrame.Angles(
			v,
			0,
			v2
		)

		if identity == CFrame.identity then
			identity = rotationOverride
		else
			identity = identity:Lerp(rotationOverride, dt * 15)
		end

		instance:PivotTo(CFrame.new(positionOverride) * identity)
	end)
	return function()
		heartbeatConnection:Disconnect()
	end
end