return function(object, _, _)
	object:CreateSound("rbxassetid://124941279780653", 1, 1.25 + 0.1 * math.random(), true, 5):SetAttribute(
		"DontClearSound",
		true
	)
	object:CreateSound("rbxassetid://125852790214228", 1, 1.25 + 0.1 * math.random(), true, 5):SetAttribute(
		"DontClearSound",
		true
	)
	object:CreateSound("rbxassetid://124261472912756", 1, 1.25 + 0.1 * math.random(), true, 5):SetAttribute(
		"DontClearSound",
		true
	)
	object:CreateSound("rbxassetid://135836738518083", 1, 1.5, true, 10):SetAttribute("DontClearSound", true)
	object:CreateSound("rbxassetid://77437496658218", 1, 1, true, 10):SetAttribute("DontClearSound", true)
end