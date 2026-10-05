local v = { "rbxassetid://111073083700270", "rbxassetid://94924686270578", "rbxassetid://132703068792668" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 1.25, 0.9 + 0.2 * math.random(), true, 5)
end