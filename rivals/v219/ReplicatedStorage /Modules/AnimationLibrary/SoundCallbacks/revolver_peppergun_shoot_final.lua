local v = { "rbxassetid://116197718267373", "rbxassetid://70565429278087", "rbxassetid://134615455726492" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 1, 1 + 0.1 * math.random(), true, 10)
end