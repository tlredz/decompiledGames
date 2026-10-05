return function(object, _, _)
	object:CreateSound("rbxassetid://18431054958", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://130350823905316", 1, 1.25 + 0.25 * math.random(), true, 5)
	object:CreateSound("rbxassetid://115102837847414", 1, 1 + 0.2 * math.random(), true, 5)
end