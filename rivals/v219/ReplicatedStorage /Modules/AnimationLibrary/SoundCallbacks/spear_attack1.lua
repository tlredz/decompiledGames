local v = { "rbxassetid://117634080761694", "rbxassetid://119713534712313", "rbxassetid://105025971160103" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 0.9 + 0.2 * math.random(), 0.95 + 0.1 * math.random(), true, 10)
end