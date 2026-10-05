local FishmenBubbleMotion = {
	RISE_HEIGHT = 200
}

function FishmenBubbleMotion.getCFrame(data, p: number)
	local v = math.max(0, p - data.startClock)
	local v2 = data.riseSpeed * v
	local v3 = math.clamp(v2 / FishmenBubbleMotion.RISE_HEIGHT, 0, 1)
	local v4 = v3 * 0.55 + 0.45
	local v5 = (math.sin(v * data.freqX + data.phaseX) * data.ampX + math.sin(v * data.freqX * 2.3 + data.phaseX) * data.ampX * 0.35) * v4
	local v6 = (math.sin(v * data.freqZ + data.phaseZ) * data.ampZ + math.sin(v * data.freqZ * 1.9 + data.phaseZ * 1.3) * data.ampZ * 0.35) * v4
	local v7 = data.spiralDir * v * data.spiralFreq + data.spiralPhase
	local v8 = data.spiralRadius * v3
	return CFrame.new(data.base + Vector3.new(v5 + math.cos(v7) * v8, v2, v6 + math.sin(v7) * v8))
end

function FishmenBubbleMotion.write(instance, data)
	instance:SetAttribute("BubbleDriftBase", data.base)
	instance:SetAttribute("BubbleDriftRiseSpeed", data.riseSpeed)
	instance:SetAttribute("BubbleDriftSwayX", (Vector3.new(data.ampX, data.freqX, data.phaseX)))
	instance:SetAttribute("BubbleDriftSwayZ", (Vector3.new(data.ampZ, data.freqZ, data.phaseZ)))
	instance:SetAttribute("BubbleDriftSpiral", (Vector3.new(data.spiralRadius, data.spiralFreq, data.spiralPhase)))
	instance:SetAttribute("BubbleDriftDirection", data.spiralDir)
	instance:SetAttribute("BubbleDriftStartedAt", data.startClock)
end

function FishmenBubbleMotion.read(instance)
	local bubbleDriftBase = instance:GetAttribute("BubbleDriftBase")
	local bubbleDriftRiseSpeed = instance:GetAttribute("BubbleDriftRiseSpeed")
	local bubbleDriftSwayX = instance:GetAttribute("BubbleDriftSwayX")
	local bubbleDriftSwayZ = instance:GetAttribute("BubbleDriftSwayZ")
	local bubbleDriftSpiral = instance:GetAttribute("BubbleDriftSpiral")
	local bubbleDriftDirection = instance:GetAttribute("BubbleDriftDirection")
	local bubbleDriftStartedAt = instance:GetAttribute("BubbleDriftStartedAt")

	if typeof(bubbleDriftBase) == "Vector3" and typeof(bubbleDriftRiseSpeed) == "number" and typeof(bubbleDriftSwayX) == "Vector3" and typeof(bubbleDriftSwayZ) == "Vector3" and typeof(bubbleDriftSpiral) == "Vector3" and typeof(bubbleDriftDirection) == "number" and typeof(bubbleDriftStartedAt) == "number" then
		return {
			base = bubbleDriftBase,
			startClock = bubbleDriftStartedAt,
			riseSpeed = bubbleDriftRiseSpeed,
			ampX = bubbleDriftSwayX.X,
			freqX = bubbleDriftSwayX.Y,
			phaseX = bubbleDriftSwayX.Z,
			ampZ = bubbleDriftSwayZ.X,
			freqZ = bubbleDriftSwayZ.Y,
			phaseZ = bubbleDriftSwayZ.Z,
			spiralRadius = bubbleDriftSpiral.X,
			spiralFreq = bubbleDriftSpiral.Y,
			spiralPhase = bubbleDriftSpiral.Z,
			spiralDir = bubbleDriftDirection
		}
	end

	return nil
end

return FishmenBubbleMotion