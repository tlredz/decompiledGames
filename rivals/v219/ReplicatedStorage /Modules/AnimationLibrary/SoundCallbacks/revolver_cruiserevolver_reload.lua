return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://134815282110155", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	for i = 1, 7 do
		object:CreateSound("rbxassetid://134815282110155", 1, i * 0.05 + 1, true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.1285714285714286 / p) then
			break
		end
	end
end