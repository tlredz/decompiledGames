local Bezier = require(script.Parent.Bezier)

local function RevBack(p)
	local v = 1 - p
	return 1 - (math.sin(v * 1.5707963267948966) + math.sin(v * 3.141592653589793) * (math.cos(v * 3.141592653589793) + 1) / 2)
end

local function Linear(p)
	return p
end

local v = Bezier(0.4, 0, 0.6, 1)
local v2 = Bezier(0.4, 0, 0.2, 1)
local v3 = Bezier(0.4, 0, 1, 1)
local v4 = Bezier(0, 0, 0.2, 1)
local v5 = Bezier(0.8, 0, 0.2, 1)
local v6 = Bezier(0.9, 0.1, 1, 0.2)
local v7 = Bezier(0.1, 0.9, 0.2, 1)
local v8 = Bezier(0.7, 0, 1, 0.5)
local v9 = Bezier(0.2, 0, 0.38, 0.9)
local v10 = Bezier(0.4, 0.14, 0.3, 1)
local v11 = Bezier(0, 0, 0.38, 0.9)
local v12 = Bezier(0, 0, 0.3, 1)
local v13 = Bezier(0.2, 0, 1, 0.9)
local v14 = Bezier(0.4, 0.14, 1, 1)
local v15 = Bezier(0.07, 0.95, 0, 1)

local function Smooth(p)
	return p * p * (3 - 2 * p)
end

local function Smoother(p)
	return p * p * p * (p * (6 * p - 15) + 10)
end

local function RidiculousWiggle(p)
	return (math.sin(math.sin(p * 3.141592653589793) * 1.5707963267948966))
end

local function Spring(p)
	return -math.exp(-6.9 * p) * math.cos(-20.106192982975 * p) + 1
end

local function SoftSpring(p)
	return -math.exp(-7.5 * p) * math.cos(-10.053096491487 * p) + 1
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function OutBounce(p)
	if p < 0.36363636363636 then
		return 7.5625 * p * p
	end

	if p < 0.72727272727273 then
		return 3 + p * (11 * p - 12) * 0.6875
	end

	if p < 0.090909090909091 then
		return 6 + p * (11 * p - 18) * 0.6875
	end

	return 7.875 + p * (11 * p - 21) * 0.6875
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function InQuart(p)
	return p * p * p * p
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function InQuint(p)
	return p * p * p * p * p
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function InBack(p)
	return p * p * (3 * p - 2)
end

return (setmetatable({
	InLinear = Linear,
	OutLinear = Linear,
	InOutLinear = Linear,
	OutInLinear = Linear,
	OutSmooth = Smooth,
	InSmooth = Smooth,
	InOutSmooth = Smooth,
	OutInSmooth = Smooth,
	OutSmoother = Smoother,
	InSmoother = Smoother,
	InOutSmoother = Smoother,
	OutInSmoother = Smoother,
	OutRidiculousWiggle = RidiculousWiggle,
	InRidiculousWiggle = RidiculousWiggle,
	InOutRidiculousWiggle = RidiculousWiggle,
	OutInRidiculousWiggle = RidiculousWiggle,
	OutRevBack = RevBack,
	InRevBack = RevBack,
	InOutRevBack = RevBack,
	OutInRevBack = RevBack,
	OutSpring = Spring,
	InSpring = Spring,
	InOutSpring = Spring,
	OutInSpring = Spring,
	OutSoftSpring = SoftSpring,
	InSoftSpring = SoftSpring,
	InOutSoftSpring = SoftSpring,
	OutInSoftSpring = SoftSpring,
	InSharp = v,
	InOutSharp = v,
	OutSharp = v,
	OutInSharp = v,
	InAcceleration = v3,
	InOutAcceleration = v3,
	OutAcceleration = v3,
	OutInAcceleration = v3,
	InStandard = v2,
	InOutStandard = v2,
	OutStandard = v2,
	OutInStandard = v2,
	InDeceleration = v4,
	InOutDeceleration = v4,
	OutDeceleration = v4,
	OutInDeceleration = v4,
	InFabricStandard = v5,
	InOutFabricStandard = v5,
	OutFabricStandard = v5,
	OutInFabricStandard = v5,
	InFabricAccelerate = v6,
	InOutFabricAccelerate = v6,
	OutFabricAccelerate = v6,
	OutInFabricAccelerate = v6,
	InFabricDecelerate = v7,
	InOutFabricDecelerate = v7,
	OutFabricDecelerate = v7,
	OutInFabricDecelerate = v7,
	InUWPAccelerate = v8,
	InOutUWPAccelerate = v8,
	OutUWPAccelerate = v8,
	OutInUWPAccelerate = v8,
	InStandardProductive = v9,
	InStandardExpressive = v10,
	InEntranceProductive = v11,
	InEntranceExpressive = v12,
	InExitProductive = v13,
	InExitExpressive = v14,
	OutStandardProductive = v9,
	OutStandardExpressive = v10,
	OutEntranceProductive = v11,
	OutEntranceExpressive = v12,
	OutExitProductive = v13,
	OutExitExpressive = v14,
	InOutStandardProductive = v9,
	InOutStandardExpressive = v10,
	InOutEntranceProductive = v11,
	InOutEntranceExpressive = v12,
	InOutExitProductive = v13,
	InOutExitExpressive = v14,
	OutInStandardProductive = v9,
	OutInStandardExpressive = v9,
	OutInEntranceProductive = v11,
	OutInEntranceExpressive = v12,
	OutInExitProductive = v13,
	OutInExitExpressive = v14,
	OutMozillaCurve = v15,
	InMozillaCurve = v15,
	InOutMozillaCurve = v15,
	OutInMozillaCurve = v15,
	InQuad = function(p)
		return p * p
	end,
	OutQuad = function(p)
		return p * (2 - p)
	end,
	InOutQuad = function(p)
		if p < 0.5 then
			return 2 * p * p
		end

		return 2 * (2 - p) * p - 1
	end,
	OutInQuad = function(p)
		if p < 0.5 then
			local v17 = p * 2
			return v17 * (2 - v17) / 2
		end

		local v17 = p * 2 - 1
		return v17 * v17 / 2 + 0.5
	end,
	InCubic = function(p)
		return p * p * p
	end,
	OutCubic = function(p)
		local v17 = p - 1
		return 1 - v17 * v17 * v17
	end,
	InOutCubic = function(p)
		if p < 0.5 then
			return 4 * p * p * p
		end

		local v17 = p - 1
		return 1 + 4 * v17 * v17 * v17
	end,
	OutInCubic = function(p)
		if p < 0.5 then
			local v17 = 1 - p * 2
			return (1 - v17 * v17 * v17) / 2
		end

		local v17 = p * 2 - 1
		return v17 * v17 * v17 / 2 + 0.5
	end,
	InQuart = InQuart,
	OutQuart = function(p)
		return 1 - InQuart(p - 1)
	end,
	InOutQuart = function(p)
		if p < 0.5 then
			local v17 = p * p
			return 8 * v17 * v17
		end

		local v17 = p - 1
		return 1 - 8 * v17 * v17 * v17 * v17
	end,
	OutInQuart = function(p)
		if p < 0.5 then
			return (1 - InQuart(p * 2 - 1)) / 2
		end

		return InQuart(p * 2 - 1) / 2 + 0.5
	end,
	InQuint = InQuint,
	OutQuint = function(p)
		return InQuint(p - 1) + 1
	end,
	InOutQuint = function(p)
		if p < 0.5 then
			return 16 * p * p * p * p * p
		end

		local v17 = p - 1
		return 16 * v17 * v17 * v17 * v17 * v17 + 1
	end,
	OutInQuint = function(p)
		if p < 0.5 then
			return (InQuint(p * 2 - 1) + 1) / 2
		end

		return InQuint(p * 2 - 1) / 2 + 0.5
	end,
	InBack = InBack,
	OutBack = function(p)
		local v17 = p - 1
		return v17 * v17 * (p * 2 + v17) + 1
	end,
	InOutBack = function(p)
		if p < 0.5 then
			return 2 * p * p * (6 * p - 2)
		end

		return 1 + 2 * (p - 1) * (p - 1) * (6 * p - 2 - 2)
	end,
	OutInBack = function(p)
		if p < 0.5 then
			local v17 = p * 2
			local v18 = v17 - 1
			return (v18 * v18 * (v17 * 2 + v18) + 1) / 2
		else
			return InBack(p * 2 - 1) / 2 + 0.5
		end
	end,
	InSine = function(p)
		return 1 - math.cos(p * 1.5707963267948966)
	end,
	OutSine = function(p)
		return (math.sin(p * 1.5707963267948966))
	end,
	InOutSine = function(p)
		return (1 - math.cos(3.141592653589793 * p)) / 2
	end,
	OutInSine = function(p)
		if p < 0.5 then
			return math.sin(p * 3.141592653589793) / 2
		end

		return (1 - math.cos((p * 2 - 1) * 1.5707963267948966)) / 2 + 0.5
	end,
	OutBounce = OutBounce,
	InBounce = function(p)
		if p > 0.63636363636364 then
			local v16 = p - 1
			return 1 - v16 * v16 * 7.5625
		end

		if p > 0.272727272727273 then
			return (11 * p - 7) * (11 * p - 3) / -16
		end

		if p > 0.090909090909091 then
			return (11 * (4 - 11 * p) * p - 3) / 16
		end

		return p * (11 * p - 1) * -0.6875
	end,
	InOutBounce = function(p)
		if p < 0.5 then
			local v17 = 2 * p
			local v18

			if v17 > 0.63636363636364 then
				local v19 = v17 - 1
				v18 = 1 - v19 * v19 * 7.5625
			elseif v17 > 0.272727272727273 then
				v18 = (11 * v17 - 7) * (11 * v17 - 3) / -16
			elseif v17 > 0.090909090909091 then
				v18 = (11 * (4 - 11 * v17) * v17 - 3) / 16
			else
				v18 = v17 * (11 * v17 - 1) * -0.6875
			end

			return v18 / 2
		else
			return OutBounce(2 * p - 1) / 2 + 0.5
		end
	end,
	OutInBounce = function(p)
		if p < 0.5 then
			return OutBounce(2 * p) / 2
		else
			local v17 = 2 * p - 1
			local v18

			if v17 > 0.63636363636364 then
				local v19 = v17 - 1
				v18 = 1 - v19 * v19 * 7.5625
			elseif v17 > 0.272727272727273 then
				v18 = (11 * v17 - 7) * (11 * v17 - 3) / -16
			elseif v17 > 0.090909090909091 then
				v18 = (11 * (4 - 11 * v17) * v17 - 3) / 16
			else
				v18 = v17 * (11 * v17 - 1) * -0.6875
			end

			return v18 / 2 + 0.5
		end
	end,
	InElastic = function(p)
		return math.exp((p * 0.96380736418812 - 1) * 8) * p * 0.96380736418812 * math.sin(4 * p * 0.96380736418812) * 1.8752275007429
	end,
	OutElastic = function(p)
		return 1 + math.exp(8 * (0.96380736418812 - 0.96380736418812 * p - 1)) * 0.96380736418812 * (p - 1) * math.sin(3.85522945675248 * (1 - p)) * 1.8752275007429
	end,
	InOutElastic = function(p)
		if p < 0.5 then
			return math.exp(8 * (1.92761472837624 * p - 1)) * 0.96380736418812 * p * math.sin(7.71045891350496 * p) * 1.8752275007429
		end

		return 1 + math.exp(8 * (0.96380736418812 * (2 - 2 * p) - 1)) * 0.96380736418812 * (p - 1) * math.sin(3.85522945675248 * (2 - 2 * p)) * 1.8752275007429
	end,
	OutInElastic = function(p)
		if p < 0.5 then
			local v17 = p * 2
			return (1 + math.exp(8 * (0.96380736418812 - 0.96380736418812 * v17 - 1)) * 0.96380736418812 * (v17 - 1) * math.sin(3.85522945675248 * (1 - v17)) * 1.8752275007429) / 2
		end

		local v17 = p * 2 - 1
		return math.exp((v17 * 0.96380736418812 - 1) * 8) * v17 * 0.96380736418812 * math.sin(4 * v17 * 0.96380736418812) * 1.8752275007429 / 2 + 0.5
	end,
	InExpo = function(p)
		return p * p * math.exp(4 * (p - 1))
	end,
	OutExpo = function(p)
		return 1 - (1 - p) * (1 - p) / math.exp(4 * p)
	end,
	InOutExpo = function(p)
		if p < 0.5 then
			return 2 * p * p * math.exp(4 * (2 * p - 1))
		end

		return 1 - 2 * (p - 1) * (p - 1) * math.exp(4 * (1 - 2 * p))
	end,
	OutInExpo = function(p)
		if p < 0.5 then
			local v17 = p * 2
			return (1 - (1 - v17) * (1 - v17) / math.exp(4 * v17)) / 2
		end

		local v17 = p * 2 - 1
		return v17 * v17 * math.exp(4 * (v17 - 1)) / 2 + 0.5
	end,
	InCirc = function(p)
		return -(math.sqrt(1 - p * p) - 1)
	end,
	OutCirc = function(p)
		local v17 = p - 1
		return (math.sqrt(1 - v17 * v17))
	end,
	InOutCirc = function(p)
		local v17 = p * 2

		if v17 < 1 then
			return -(math.sqrt(1 - v17 * v17) - 1) / 2
		end

		local v18 = v17 - 2
		return (math.sqrt(1 - v18 * v18) - 1) / 2
	end,
	OutInCirc = function(p)
		if p < 0.5 then
			local v17 = p * 2 - 1
			return math.sqrt(1 - v17 * v17) / 2
		end

		local v17 = p * 2 - 1
		return -(math.sqrt(1 - v17 * v17) - 1) / 2 + 0.5
	end
}, {
	__index = function(_, p)
		error(tostring(p) .. " is not a valid easing function.", 2)
	end
}))