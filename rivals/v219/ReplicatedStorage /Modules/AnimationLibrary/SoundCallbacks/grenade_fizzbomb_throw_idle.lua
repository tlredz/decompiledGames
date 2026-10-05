return function(object, p, p2)
	while object.Animator:IsAnimationHashValid(script.Name, p2) do
		if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
			break
		end

		object:CreateSound("rbxassetid://130511754869111", 1, 1 + 0.1 * math.random(), true, 10)
		object:CreateSound("rbxassetid://119684878895970", 1, 1 + 0.1 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
			break
		end

		object:CreateSound("rbxassetid://130511754869111", 1, 1 + 0.1 * math.random(), true, 10)
		object:CreateSound("rbxassetid://119684878895970", 1, 1 + 0.1 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
			break
		end

		object:CreateSound("rbxassetid://130511754869111", 1, 1 + 0.1 * math.random(), true, 10)
		object:CreateSound("rbxassetid://119684878895970", 1, 1 + 0.1 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
			break
		end

		object:CreateSound("rbxassetid://130511754869111", 1, 1 + 0.1 * math.random(), true, 10)
		object:CreateSound("rbxassetid://119684878895970", 1, 1 + 0.1 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
			break
		end

		object:CreateSound("rbxassetid://130511754869111", 1, 1 + 0.1 * math.random(), true, 10)
		object:CreateSound("rbxassetid://119684878895970", 1, 1 + 0.1 * math.random(), true, 10)
	end
end