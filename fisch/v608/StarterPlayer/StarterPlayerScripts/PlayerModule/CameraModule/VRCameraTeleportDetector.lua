local VRCameraTeleportDetector = {
	JUMP_STUDS = 4,
	SETTLED_STUDS = 1,
	DEBOUNCE_SECONDS = 0.25
}

function VRCameraTeleportDetector.shouldRecenter(p: number?, p2: number, p3: number?, p4: number)
	if p2 <= VRCameraTeleportDetector.JUMP_STUDS then
		return false
	end

	if p == nil or not (VRCameraTeleportDetector.SETTLED_STUDS <= p) then
		return p3 == nil or not (p4 - p3 < VRCameraTeleportDetector.DEBOUNCE_SECONDS)
	end

	return false
end

return VRCameraTeleportDetector