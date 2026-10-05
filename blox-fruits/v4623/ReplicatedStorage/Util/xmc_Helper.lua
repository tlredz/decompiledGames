local RunService = game:GetService("RunService")
local EasingFunctions = require(script.EasingFunctions)
local v = 0
local v2 = {}

local function t_Discrete(p, p2, p3)
	if p3 == 1 then
		return p2
	end

	return p
end

local function t_Number(p: number, p2: number, p3: number)
	return (math.lerp(p, p2, p3))
end

local function t_Lerp(object, p, p2: number)
	return object:lerp(p, p2)
end

local function t_ColorSeqLerp(sequence, sequence2, p: number)
	local value = sequence.Keypoints[1].Value
	local value2 = sequence2.Keypoints[1].Value
	return ColorSequence.new(value:Lerp(value2, p))
end

local function t_NumberSeqLerp(sequence, sequence2, p: number)
	local value = sequence.Keypoints[1].Value
	local value2 = sequence2.Keypoints[1].Value
	return NumberSequence.new((math.lerp(value, value2, p)))
end

local function t_NumberRangeLerp(range: NumberRange, range2: NumberRange, p)
	local v3 = math.lerp(range.Min, range2.Min, p)
	return NumberRange.new(v3, v3)
end

local v3 = {
	number = t_Number,
	string = t_Discrete,
	Instance = t_Discrete,
	boolean = t_Discrete,
	EnumItem = t_Discrete,
	CFrame = t_Lerp,
	Color3 = t_Lerp,
	Vector2 = t_Lerp,
	Vector3 = t_Lerp,
	ColorSequence = t_ColorSeqLerp,
	NumberSequence = t_NumberSeqLerp,
	NumberRange = t_NumberRangeLerp
}
return {
	TweenProperty = function(self, p2: string, targetValue, p4: number, easingStyle: string, easingDirection: string?, p6: number?, p7: number?)
		local id = v
		v = (v + 1) % 4294967296

		if v2[self] and v2[self][p2] then
			self[p2] = v3[typeof(targetValue)](self[p2], v2[self][p2].TargetValue, 1)
		end

		if v2[self] == nil then
			v2[self] = {}
		end

		v2[self][p2] = {
			Id = id,
			TargetValue = targetValue,
			EasingStyle = easingStyle,
			EasingDirection = easingDirection
		}
		task.spawn(function()
			if v2[self] == nil or v2[self][p2] == nil or v2[self][p2].Id ~= id then
				self[p2] = targetValue
				return
			end

			local v5 = p4
			local v6 = v3[typeof(targetValue)]
			local easingFunction = EasingFunctions[easingStyle .. (easingDirection or "")]
			local v7 = nil
			local v8 = false

			while true do
				local v9 = RunService.RenderStepped:Wait()

				if v2[self] == nil or v2[self][p2] == nil or v2[self][p2].Id ~= id then
					self[p2] = targetValue
					break
				end

				if v7 == nil then
					v7 = self[p2]
				end

				v5 = math.max(v5 - v9, 0)
				self[p2] = v6(v7, targetValue, easingFunction(1 - v5 / p4, p6, p7))

				if v5 ~= 0 then
					continue
				end

				v8 = true
				break
			end

			if v8 and v2[self] and v2[self][p2] and v2[self][p2].Id == id then
				v2[self][p2] = nil

				if next(v2[self]) == nil then
					v2[self] = nil
				end
			end
		end)
	end
}