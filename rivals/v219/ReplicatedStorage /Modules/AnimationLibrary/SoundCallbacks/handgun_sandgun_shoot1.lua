local v = { "rbxassetid://13110197302", "rbxassetid://13110197220" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://87740786635301", 0.375 + 0.25 * math.random(), 0.9 + 0.4 * math.random(), true, 5)
end