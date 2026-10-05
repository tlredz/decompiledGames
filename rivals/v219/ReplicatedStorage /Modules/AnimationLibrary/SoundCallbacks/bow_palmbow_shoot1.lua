local v = { "rbxassetid://13677205703", "rbxassetid://13677205578", "rbxassetid://13677205647" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 3, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://113094896439924", 1.5, 1, true, 10)
end