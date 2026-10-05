local v = { "rbxassetid://13677205703", "rbxassetid://13677205578", "rbxassetid://13677205647" }
return function(object, p, p2)
	object:CreateSound(v[math.random(#v)], 3, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.75, 1.5 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682183816", 0.5, 2 + 0.5 * math.random(), true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 1.5 + 0.25 * math.random(), true, 5)
	object:CreateSound("rbxassetid://71387264231358", 0.375, 1, true, 10)
end