local v = {
	23,
	27,
	30,
	36,
	41,
	47,
	49,
	54,
	67
}
return function(object, p, p2)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.5, true, 10)

	for k, v2 in pairs(v) do
		object:CreateSound("rbxassetid://14241444681", 1, 1 + 0.25 * math.random(), true, 10)
		object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random() + 0.25, true, 5)

		if not object:_AnimationWait(script.Name, p2, (v2 - (v[k - 1] or 0)) / 60 / p) then
			return
		end
	end

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end