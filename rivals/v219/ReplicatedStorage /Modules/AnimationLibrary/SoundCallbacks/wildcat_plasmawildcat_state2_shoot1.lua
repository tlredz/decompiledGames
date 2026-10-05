local v = { "rbxassetid://72815891526849", "rbxassetid://134260292117186" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 0.75, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://101461115963186", 1.2, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://137470456653256", 1.2, 1.1 + 0.1 * math.random(), true, 5)
end