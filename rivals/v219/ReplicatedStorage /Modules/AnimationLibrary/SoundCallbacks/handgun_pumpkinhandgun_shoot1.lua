local v = { "rbxassetid://13110197302", "rbxassetid://13110197220" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 0.75, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://72347347286562", 1, 1 + 0.2 * math.random(), true, 5)
end