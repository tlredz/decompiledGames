local parent = script.Parent.Parent.Parent
local AnimationCommandStrip = require(parent.AnimationCommandStrip)

local function GetAnimationController(instance)
	local animationController = instance:FindFirstChildOfClass("AnimationController")

	if animationController and animationController.Parent == instance then
		return animationController
	end

	return nil
end

return AnimationCommandStrip.Create({
	Type = "CutsceneAnimation",
	DisplayName = "Cutscene Animation",
	Supports = function(model)
		local animationController

		if model:IsA("Model") then
			animationController = model:FindFirstChildOfClass("AnimationController")

			if not animationController or animationController.Parent ~= model then
				animationController = nil
			end
		end

		return animationController ~= nil and animationController:FindFirstChildOfClass("Animator") ~= nil
	end,
	ResolveAnimator = function(instance)
		local animationController = instance:FindFirstChildOfClass("AnimationController")

		if not animationController or animationController.Parent ~= instance then
			animationController = nil
		end

		if animationController then
			return (animationController:FindFirstChildOfClass("Animator"))
		end

		return nil
	end,
	ResolveRig = function(p)
		return p
	end
})