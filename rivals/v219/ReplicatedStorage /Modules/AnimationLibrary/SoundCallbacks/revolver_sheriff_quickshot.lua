local v = { "rbxassetid://137835445333923" }
local v2 = { "rbxassetid://111635700014206", "rbxassetid://71082815960227", "rbxassetid://102452124576950" }
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 1, 1.25 + 0.25 * math.random(), true, 10)
	object:CreateSound(v2[math.random(#v2)], 1, 0.95 + 0.1 * math.random(), true, 10)
end