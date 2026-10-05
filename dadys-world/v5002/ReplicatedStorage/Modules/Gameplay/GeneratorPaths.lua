local GeneratorPaths = {
	findSuffixed = function(instance, p, value)
		if instance then
			return instance:FindFirstChild(p .. (value or ""))
		end

		return nil
	end
}

function GeneratorPaths.getBaseMachine(p, p2)
	return GeneratorPaths.findSuffixed(p, "BaseMachine", p2)
end

function GeneratorPaths.getIchorFX(instance)
	if instance then
		return instance:FindFirstChild("IchorFX")
	end

	return nil
end

function GeneratorPaths.getTreadmillGame(p, p2)
	return GeneratorPaths.findSuffixed(p, "TreadmillGame", p2)
end

function GeneratorPaths.getCircleMinigame(p, p2)
	return GeneratorPaths.findSuffixed(p, "CircleMinigame", p2)
end

function GeneratorPaths.getBarnabyOverlay(p, p2)
	return GeneratorPaths.findSuffixed(p, "SwimmyBarnaby", p2)
end

function GeneratorPaths.getLightReference(p, p2)
	return GeneratorPaths.findSuffixed(p, "LightReference", p2)
end

function GeneratorPaths.getValveReference(p, p2)
	return GeneratorPaths.findSuffixed(p, "ValveReference", p2)
end

function GeneratorPaths.getFakeValveReference(p, p2)
	return GeneratorPaths.findSuffixed(p, "FakeValveReference", p2)
end

function GeneratorPaths.getTreadmillLightReference(p, p2)
	return GeneratorPaths.findSuffixed(p, "TreadmillLightReference", p2)
end

function GeneratorPaths.getQuickLinks(p, p2)
	return GeneratorPaths.findSuffixed(p, "QuickLinks", p2)
end

function GeneratorPaths.getDefaultLightFolder(p, p2)
	local quickLinks = GeneratorPaths.getQuickLinks(p, p2)
	return quickLinks and quickLinks:FindFirstChild("DefaultLight")
end

function GeneratorPaths.getDefaultPartsToHideFolder(p, p2)
	local quickLinks = GeneratorPaths.getQuickLinks(p, p2)
	return quickLinks and quickLinks:FindFirstChild("DefaultPartsToHide")
end

function GeneratorPaths.getCirclePartsRef(p, p2)
	local quickLinks = GeneratorPaths.getQuickLinks(p, p2)
	return quickLinks and quickLinks:FindFirstChild("CircleParts")
end

function GeneratorPaths.getTreadmillPartsRef(p, p2)
	local quickLinks = GeneratorPaths.getQuickLinks(p, p2)
	return quickLinks and quickLinks:FindFirstChild("TreadmillParts")
end

function GeneratorPaths.getStats(instance)
	if instance then
		return instance:FindFirstChild("Stats")
	end

	return nil
end

function GeneratorPaths.getCompletedValue(p)
	local stats = GeneratorPaths.getStats(p)
	return stats and stats:FindFirstChild("Completed")
end

function GeneratorPaths.getTeleportPositions(instance, p)
	if not instance then
		return nil
	end

	if p == "treadmill" then
		return instance:FindFirstChild("TreadmillTeleportPositions") or instance:FindFirstChild("TeleportPositions")
	end

	return instance:FindFirstChild("TeleportPositions")
end

function GeneratorPaths.getDrip(instance)
	if instance then
		return instance:FindFirstChild("Drip")
	end

	return nil
end

function GeneratorPaths.getDripParticle(p)
	local drip = GeneratorPaths.getDrip(p)
	local attachment = drip and drip:FindFirstChild("Attachment")
	return attachment and attachment:FindFirstChild("DripParticle")
end

function GeneratorPaths.getIchorFull(instance)
	if instance then
		return instance:FindFirstChild("IchorFull")
	end

	return nil
end

function GeneratorPaths.resolveSlotLight(instance, value, p)
	if not instance then
		return nil
	end

	local v = value or ""

	if p then
		local treadmillLightReference = GeneratorPaths.getTreadmillLightReference(instance, v)
		local value2 = treadmillLightReference and treadmillLightReference.Value

		if value2 then
			return value2
		end

		local treadmillGame = GeneratorPaths.getTreadmillGame(instance, v)
		return treadmillGame and treadmillGame:FindFirstChild("TreadmillLight")
	else
		local lightReference = GeneratorPaths.getLightReference(instance, v)
		local value2 = lightReference and lightReference.Value

		if value2 then
			return value2
		end

		local baseMachine = GeneratorPaths.getBaseMachine(instance, v)
		return baseMachine and baseMachine:FindFirstChild("Light") or instance:FindFirstChild("Light" .. v)
	end
end

return GeneratorPaths