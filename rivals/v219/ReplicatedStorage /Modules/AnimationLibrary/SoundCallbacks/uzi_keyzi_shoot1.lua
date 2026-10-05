local v = { "rbxassetid://16526185100", "rbxassetid://16526184479", "rbxassetid://16526184730" }
return function(object, _, _)
	object:CreateSound("rbxassetid://16397424081", 0.2, 4 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://16526184265", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound(v[math.random(#v)], 0.75, 1.25 + 0.75 * math.random(), true, 5)
	object:CreateSound(v[math.random(#v)], 0.75, 2.5 + 1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://90757583550672", 0.5, 2.5 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 1, 1 + 0.1 * math.random(), true, 5)
end