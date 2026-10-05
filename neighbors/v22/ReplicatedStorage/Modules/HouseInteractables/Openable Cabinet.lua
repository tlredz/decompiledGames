local createVector = vector.create
local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(1)
return function(parent)
	local v = BaseInteractable.new()
	local v2 = {
		LeftHinge = {
			Joint = parent.Root.HingeL,
			Offset = CFrame.Angles(0, -2.0943951023931953, 0)
		},
		RightHinge = {
			Joint = parent.Root.HingeR,
			Offset = CFrame.Angles(0, 2.0943951023931953, 0)
		}
	}
	local v3 = {}

	for k, v4 in v2 do
		v3[k] = {
			C0 = v4.Joint.C0,
			C1 = v4.Joint.C1
		}
	end

	function v.Run(p)
		if p.State then
			for k, v4 in v2 do
				local C0 = v3[k].C0 * v4.Offset
				TweenService:Create(v4.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		else
			for k, v4 in v2 do
				local C0 = v3[k].C0
				TweenService:Create(v4.Joint, tweenInfo, {
					C0 = C0
				}):Play()
			end
		end
	end

	local part = Instance.new("Part")
	part.Transparency = 1
	part.CFrame = parent:GetPivot()
	part.Anchored = true
	part.CanCollide = false
	part.Parent = parent
	part.Size = parent.Right.Door.Size * 2.4 - createVector(0, 1, 0)
	part.Name = "ClickPart"

	for _, parent2 in { part } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent2
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end