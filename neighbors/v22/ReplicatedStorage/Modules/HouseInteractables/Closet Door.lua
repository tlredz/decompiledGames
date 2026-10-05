local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1)
return function(p)
	local v = BaseInteractable.new()
	local v2 = v:Replace(p, script.Example)
	local v3 = {
		RightDoorJointClose = {
			Joint = v2.Doors.RightDoor["Door SlabFarR"]["Door SlabRC"],
			Offset = CFrame.Angles(2.9670597283903604, 0, 0)
		},
		RightDoorJointFar = {
			Joint = v2.Doors.Root["Door SlabFarR"],
			Offset = CFrame.Angles(-1.5707963267948966, 0, 0)
		},
		LeftDoorJointClose = {
			Joint = v2.Doors.LeftDoor["Door SlabFarL"]["Door SlabLC"],
			Offset = CFrame.Angles(-2.9670597283903604, 0, 0)
		},
		LeftDoorJointFar = {
			Joint = v2.Doors.Root["Door SlabFarL"],
			Offset = CFrame.Angles(1.5707963267948966, 0, 0)
		}
	}
	local v4 = {}

	for k, v5 in v3 do
		v4[k] = {
			C0 = v5.Joint.C0,
			C1 = v5.Joint.C1
		}
	end

	function v.Run(p2)
		local state = p2.State
		v2.Doors.Root.Sound:Play()

		if state then
			for k, v5 in v3 do
				local C0 = v4[k].C0 * v5.Offset
				TweenService:Create(v5.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		else
			for k, v5 in v3 do
				local C0 = v4[k].C0
				TweenService:Create(v5.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		end
	end

	return v
end