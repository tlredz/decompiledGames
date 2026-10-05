local v = { "rbxassetid://13677205703", "rbxassetid://13677205578", "rbxassetid://13677205647" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 3, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://17803360572", 1, 3 + 0.3 * math.random(), true, 10)
end