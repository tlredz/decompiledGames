local MoonBezier = {}
MoonBezier.__index = MoonBezier
local BezierCurve = require(script:WaitForChild("BezierCurve"))
local Utility = require(script:WaitForChild("Utility"))

function MoonBezier.Setup(p, p2, duration, easingStyle, easingDirection, p6)
	local v = {
		Min = {
			X = 5,
			Y = 5,
			Z = 5
		},
		Max = {
			X = 10,
			Y = 10,
			Z = 10
		}
	}
	local v2 = {
		Duration = duration,
		EasingStyle = easingStyle,
		EasingDirection = easingDirection,
		LookAt = true
	}

	local function createBezier(p7, clone)
		local position = clone.Position
		local position2 = p7.Position
		local min = v.Min
		local max = v.Max
		local v3 = Utility.GetRandomNumber(min.X, max.X, true) * Utility.GetRandomSign()
		local v4 = Utility.GetRandomNumber(min.Y, max.Y, true) * Utility.GetRandomSign()
		local v5 = Utility.GetRandomNumber(min.Z, max.Z, true) * Utility.GetRandomSign()
		local randomNumber = Utility.GetRandomNumber(1, 2, true)
		local cframe = CFrame.Angles(CFrame.lookAt(clone.Position, position2):ToEulerAnglesXYZ())
		local v6 = CFrame.new(position:Lerp(position2, randomNumber)) * cframe * CFrame.new(v3, v4, v5)
		BezierCurve.Play(clone, { position, v6.Position, position2 }, false, v2)
		clone.Transparency = 1
		Utility.DelayDestruction(duration + 1, clone)
	end

	for _ = 1, p2 do
		local clone = script:WaitForChild("Trail"):Clone()
		clone.Position = p.Position + Vector3.new(math.random(-p6, p6), math.random(-p6, p6), math.random(-p6, p6))
		clone.Parent = workspace.Thrown
		createBezier(p, clone)
		task.wait(0.03)
	end
end

return MoonBezier