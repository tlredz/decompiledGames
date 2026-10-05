local RunService = game:GetService("RunService")
return function(instance)
	local bones = {}
	local v = 0
	local collectBones

	collectBones = function(bone)
		local bone2 = bone:FindFirstChildWhichIsA("Bone")

		if not bone2 then
			return
		end

		bones[#bones + 1] = bone2
		v = #bones
		collectBones(bone2)
	end

	local bone = instance:FindFirstChildWhichIsA("Bone")

	if bone then
		bones[#bones + 1] = bone
		v = #bones
		collectBones(bone)
	end

	local v2 = nil
	local cframe = CFrame.new()
	local v3 = nil
	local cframe2 = CFrame.new()

	local function adjust()
		if not (v2 and v3) then
			return
		end

		local position = (v2.CFrame * cframe).Position
		local position2 = v3.Position
		local lerped = position2:Lerp(position, 1 / v)
		local v4 = position2

		for i = 1, v do
			local v5 = bones[i]
			v5.WorldCFrame = CFrame.lookAt(v4, lerped) * CFrame.Angles(0, 3.141592653589793, 0) * cframe2
			v4 = lerped
			lerped = v <= i + 1 and lerped - v5.WorldCFrame.LookVector or position2:Lerp(position, (i + 1) / v)
		end
	end

	local heartbeatConnection = nil
	return function(p, p2, p3, p4)
		v3 = p or v3
		v2 = p2 or v2
		cframe = p3 or cframe
		cframe2 = p4 or cframe2

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if instance.Parent then
				adjust()
			else
				heartbeatConnection:Disconnect()
			end
		end)
		return heartbeatConnection
	end
end