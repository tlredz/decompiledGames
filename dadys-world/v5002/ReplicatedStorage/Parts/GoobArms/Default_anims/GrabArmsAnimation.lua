if not script:IsDescendantOf(workspace) then
	return
end

local ability = script:WaitForChild("Ability")
local track = script.Parent:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(ability)
track:AdjustSpeed(2)
track:Play()