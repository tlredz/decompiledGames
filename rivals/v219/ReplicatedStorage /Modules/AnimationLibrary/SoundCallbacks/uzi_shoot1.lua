local v = { "rbxassetid://16526185100", "rbxassetid://16526184479", "rbxassetid://16526184730" }
return function(object, _, _)
	object:CreateSound("rbxassetid://16397424081", 0.2, 4 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://16526184265", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound(v[math.random(#v)], 1.25, 0.75 + 0.5 * math.random(), true, 5)
end