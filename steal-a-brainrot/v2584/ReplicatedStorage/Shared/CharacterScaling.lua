local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function GetHumanoidScalar(instance, name: string)
	local numberValue = instance:FindFirstChild(name)

	if numberValue then
		assert(numberValue:IsA("NumberValue"))
		return numberValue
	end

	local numberValue2 = Instance.new("NumberValue")
	numberValue2.Name = name
	numberValue2.Value = 1
	return numberValue2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScaleHumanoidScalar(humanoid, name: string, humanoidScale: number)
	local v = humanoid:FindFirstChild(name)

	if v then
		assert(v:IsA("NumberValue"))
	else
		v = Instance.new("NumberValue")
		v.Name = name
		v.Value = 1
	end

	local originalValue = v:GetAttribute("OriginalValue")

	if type(originalValue) ~= "number" then
		originalValue = v.Value
		v:SetAttribute("OriginalValue", originalValue)
	end

	v.Value = originalValue * humanoidScale
end

local function SetCharacterScale(instance, humanoidScale: number)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	humanoid.AutomaticScalingEnabled = true
	ScaleHumanoidScalar(humanoid, "BodyDepthScale", humanoidScale) -- equivalent call inferred; original call site unknown
	ScaleHumanoidScalar(humanoid, "BodyHeightScale", humanoidScale) -- equivalent call inferred; original call site unknown
	ScaleHumanoidScalar(humanoid, "BodyProportionScale", humanoidScale) -- equivalent call inferred; original call site unknown
	ScaleHumanoidScalar(humanoid, "BodyTypeScale", humanoidScale) -- equivalent call inferred; original call site unknown
	ScaleHumanoidScalar(humanoid, "BodyWidthScale", humanoidScale) -- equivalent call inferred; original call site unknown
	ScaleHumanoidScalar(humanoid, "HeadScale", humanoidScale) -- equivalent call inferred; original call site unknown
	instance:SetAttribute("NewHipHeight", humanoid.HipHeight)
	local tool = instance:FindFirstChildOfClass("Tool")

	if tool then
		local originalScale = tool:GetAttribute("OriginalScale")

		if type(originalScale) ~= "number" then
			originalScale = tool:GetScale()
			tool:SetAttribute("OriginalScale", originalScale)
		end

		tool:ScaleTo(originalScale * humanoidScale)
	end

	instance:SetAttribute("__HumanoidScale", humanoidScale)
end

local CharacterScaling = {}

function CharacterScaling.TweenCharacterScale(p, p2: number, p3: number, p4: number, p5: number, p6, p7, callback)
	local total = 0
	local v = 0
	local preSimulationConnection = nil
	preSimulationConnection = RunService.PreSimulation:Connect(function(dt)
		v += dt

		if v < p5 then
			return
		end

		total += p5
		v -= p5
		local value = TweenService:GetValue(math.clamp(total / p4, 0, 1), p6, p7)
		SetCharacterScale(p, math.lerp(p2, p3, value))

		if p4 <= total then
			preSimulationConnection:Disconnect()

			if callback then
				callback()
			end
		end
	end)
	return preSimulationConnection
end

function CharacterScaling.GetCharacterScale(instance)
	return instance:GetAttribute("__HumanoidScale") or 1
end

function CharacterScaling.SetToolScale(instance, p: number)
	local originalScale = instance:GetAttribute("OriginalScale")

	if type(originalScale) ~= "number" then
		originalScale = instance:GetScale()
		instance:SetAttribute("OriginalScale", originalScale)
	end

	instance:ScaleTo(originalScale * p)
end

return CharacterScaling