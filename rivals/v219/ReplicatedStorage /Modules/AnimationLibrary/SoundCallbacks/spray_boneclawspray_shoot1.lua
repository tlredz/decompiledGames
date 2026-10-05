return function(object, _, _)
	object:CreateSound("rbxassetid://100354903585817", 0.75, 0.75 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://104731232227748", 0.75, 1.5 + 0.25 * math.random(), true, 10)
end