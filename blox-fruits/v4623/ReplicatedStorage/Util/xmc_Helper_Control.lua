local RunService = game:GetService("RunService")
local EasingFunctions = require(script.EasingFunctions)

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
	local v = math.lerp(range.Min, range2.Min, p)
	return NumberRange.new(v, v)
end

local v = {
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
local v2 = 0
local v3 = {}
return {
	TweenProperty = function(self, p2: string, targetValue2, p4: number, easingStyle: string, easingDirection: string?, p6: number?, p7: number?)
		local v4 = v[typeof(targetValue2)] or t_Discrete

		if v3[self] == nil then
			v3[self] = {}
		end

		local v5 = v3[self][p2]
		local targetValue

		if v5 == nil then
			targetValue = self[p2]
		else
			targetValue = v5.TargetValue
		end

		self[p2] = v4(self[p2], targetValue, 1)
		local id = v2
		v2 = (v2 + 1) % 4294967296
		v3[self][p2] = {
			Id = id,
			StartValue = targetValue,
			TargetValue = targetValue2,
			EasingStyle = easingStyle,
			EasingDirection = easingDirection
		}

		if not (p4 <= 0) then
			task.spawn(function()
				local v7 = v3[self] and v3[self][p2]

				if v7 == nil or v7.Id ~= id then
					return
				end

				local easingFunction = EasingFunctions[easingStyle .. (easingDirection or "")]
				local startValue = v7.StartValue
				local total = 0

				while true do
					total += RunService.RenderStepped:Wait()
					local v8 = v3[self] and v3[self][p2]

					if v8 == nil or v8.Id ~= id then
						break
					end

					local v9 = math.clamp(total / p4, 0, 1)
					self[p2] = v4(startValue, targetValue2, (easingFunction(v9, p6, p7)))

					if not (v9 >= 1) then
						continue
					end

					if v3[self] and v3[self][p2] and v3[self][p2].Id == id then
						v3[self][p2] = nil

						if next(v3[self]) == nil then
							v3[self] = nil
						end
					end

					break
				end
			end)
			return
		end

		self[p2] = targetValue2

		if v3[self] and v3[self][p2] and v3[self][p2].Id == id then
			v3[self][p2] = nil

			if next(v3[self]) == nil then
				v3[self] = nil
			end
		end
	end
}