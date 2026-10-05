return function(object, _, _)
	object:CreateSound("rbxasset://sounds//paintball.wav", 0.5, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://74462162324970", 1, 1 + 0.1 * math.random(), true, 5)
end