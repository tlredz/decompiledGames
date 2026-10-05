local v = { "rbxassetid://13677205703", "rbxassetid://13677205578", "rbxassetid://13677205647" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 3, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.75, 1.5 + 0.25 * math.random(), true, 5)
end