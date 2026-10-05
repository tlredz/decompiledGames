return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://75549206431714", 1, 1.25, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 0.25, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://75549206431714", 1, 1, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 0.25, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://75549206431714", 1, 1.25, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 0.25, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://75549206431714", 1, 1.15, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 0.25, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://75549206431714", 1, 1.4, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 0.25, 0.75 + 0.25 * math.random(), true, 5)

	if not (object:_AnimationWait(script.Name, p2, 0.2 / p) and object:_AnimationWait(script.Name, p2, 0.5 / p)) then
		return
	end

	object:CreateSound("rbxassetid://75549206431714", 1, 1.25, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 2 + 0.5 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 0.25, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 0.75, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 0.75 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 0.75, 1.5 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://13483008798", 0.5, 2.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 0.5, 1.75 + 0.25 * math.random(), true, 5)
end