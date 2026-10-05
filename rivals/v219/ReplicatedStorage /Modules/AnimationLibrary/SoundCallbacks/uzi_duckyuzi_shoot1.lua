local v = { "rbxassetid://16526185100", "rbxassetid://16526184479", "rbxassetid://16526184730" }
local v2 = { "rbxassetid://82734275723667", "rbxassetid://94668708681028", "rbxassetid://114970794949077" }
return function(object, _, _)
	object:CreateSound("rbxassetid://16397424081", 0.2, 4 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://16526184265", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound(v[math.random(#v)], 1.25, 0.75 + 0.5 * math.random(), true, 5)
	object:CreateSound(v2[math.random(#v2)], 1, 0.95 + 0.1 * math.random(), true, 5)
end