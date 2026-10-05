local RunService = game:GetService("RunService")
return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	local sound = object:CreateSound("rbxassetid://135262581066376", 1, 1, true, 10)

	while object.Animator:IsAnimationHashValid(script.Name, p2) do
		RunService.RenderStepped:Wait()
	end

	if sound then
		sound:Destroy()
	end
end