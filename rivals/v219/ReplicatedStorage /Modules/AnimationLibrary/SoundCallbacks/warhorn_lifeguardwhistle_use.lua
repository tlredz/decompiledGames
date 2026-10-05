return function(object, p, p2)
	local sound = object:CreateSound("rbxassetid://72342434543613", 1, 1, true, 5, 100, 400)

	if sound then
		sound:SetAttribute("DontClearSound", true)
	end

	local sound2 = object:CreateSound("rbxassetid://94406584083681", 1, 1, true, 5, 100, 400)

	if sound2 then
		sound2:SetAttribute("DontClearSound", true)
	end

	if not object:_AnimationWait(script.Name, p2, 0.07 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.5, 1.25, true, 10)
end