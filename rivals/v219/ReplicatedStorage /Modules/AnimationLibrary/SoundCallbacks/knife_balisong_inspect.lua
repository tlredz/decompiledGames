return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1.25 + 0.25 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1.25 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://106430462780583", 1, 1.5 + 0.2 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.8 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://115912967875581", 1.25, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 0.5, 1.5 + 0.2 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.8 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://113941779770778", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
end