local v = { "rbxassetid://13677205703", "rbxassetid://13677205578", "rbxassetid://13677205647" }
return function(object, p, p2)
	object:CreateSound(v[math.random(#v)], 3, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://17803360572", 1, 3 + 0.3 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682183816", 0.5, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://17803360572", 1, 2 + 0.2 * math.random(), true, 10)
end