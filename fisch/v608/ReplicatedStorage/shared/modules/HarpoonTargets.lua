local HarpoonTargets = {}
HarpoonTargets.FOLDER_TAG = "HarpoonTargetFolder"
HarpoonTargets.HITBOX_TAG = "HarpoonTargetHitbox"
HarpoonTargets.ROAMER_HITBOX_TAG = "RoamingFishHitbox"
HarpoonTargets.UID_SEPARATOR = ":"

function HarpoonTargets.isTargetHitbox(instance)
	return instance:HasTag("RoamingFishHitbox") or instance:HasTag("HarpoonTargetHitbox")
end

function HarpoonTargets.buildUid(p: string, p2: string)
	return (`{p}:{p2}`)
end

function HarpoonTargets.getPrefix(value: string)
	local v = string.find(value, ":", 1, true)

	if v and not (v <= 1) then
		return (string.sub(value, 1, v - 1))
	end

	return nil
end

function HarpoonTargets.getSuffix(value: string)
	local v = string.find(value, ":", 1, true)

	if v and not (#value <= v) then
		return (string.sub(value, v + 1))
	end

	return nil
end

return HarpoonTargets