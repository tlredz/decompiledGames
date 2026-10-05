local createVector = vector.create
local VR = {}
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local v = {
	[Enum.UserCFrame.RightHand] = {},
	[Enum.UserCFrame.LeftHand] = {}
}

function VR:GetHandPosition(p)
	return VRService:GetUserCFrame(p).Position
end

function VR.GetHandVelocity(_, p)
	local v2 = v[p]
	local v3 = #v2
	local v4 = createVector(0, 0, 0)

	for k, v5 in v2 do
		if not (k > 1) then
			continue
		end

		local v6 = v2[k - 1]
		v4 += (v5.Position - v6.Position) / (v5.Time - v6.Time)
	end

	return v4 / v3
end

function VR.GetRelativeVectorToHead(_, vector2: Vector3)
	return VRService:GetUserCFrame(Enum.UserCFrame.Head):VectorToObjectSpace(vector2)
end

RunService.Heartbeat:connect(function(_)
	local now = os.clock()

	for k, list in v do
		table.insert(list, {
			Position = VR:GetHandPosition(k),
			Time = now
		})

		for k2, v2 in list do
			if now - v2.Time > 0.1 then
				table.remove(list, k2)
			end
		end
	end
end)
return VR