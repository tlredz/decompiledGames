local v = { "rbxassetid://13110197302", "rbxassetid://13110197220" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://76996559479025", 1, 1, true, 5)
end