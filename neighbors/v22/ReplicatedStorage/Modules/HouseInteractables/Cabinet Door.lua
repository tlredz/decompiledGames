local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1)
return function(p)
	local v = BaseInteractable.new()
	local v2 = v:Replace(p, script.Example)
	local v3 = {
		Door = {
			Joint = v2.Door.Hinge.Door,
			Offset = CFrame.Angles(0, 1.8325957145940461, 0)
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
		if p2.State then
			v2.Door.Hinge.OpenCupboard:Play()

			for k, v5 in v3 do
				local C0 = v4[k].C0 * v5.Offset
				local tween = TweenService:Create(v5.Joint, tweenInfo, {
					C0 = C0
				})
				tween:Play()
				tween.Completed:Once(function()
					v2.Door.Click.CFrame = v2.Door.Door.CFrame
				end)
			end
		else
			for k, v5 in v3 do
				local C0 = v4[k].C0
				local tween = TweenService:Create(v5.Joint, tweenInfo, {
					C0 = C0
				})
				tween:Play()
				tween.Completed:Once(function()
					v2.Door.Click.CFrame = v2.Door.Door.CFrame
					v2.Door.Hinge.CloseCupboard:Play()
				end)
			end
		end
	end

	local _ = { v2.Door.Click }
	return v
end