return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://114830743588818", 0.5, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://114830743588818", 0.5, 1.1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://114830743588818", 0.5, 1.2 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://135828654526098", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 3.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://78252768764835", 1, 1, true, 10)
	object:CreateSound("rbxassetid://92760487729234", 1, 1.5, true, 10)
end