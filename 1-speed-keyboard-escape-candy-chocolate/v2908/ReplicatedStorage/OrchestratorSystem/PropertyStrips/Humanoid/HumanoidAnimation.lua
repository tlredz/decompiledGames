local parent = script.Parent.Parent.Parent
local AnimationCommandStrip = require(parent.AnimationCommandStrip)
return AnimationCommandStrip.Create({
	Type = "HumanoidAnimation",
	DisplayName = "Animation",
	Supports = function(humanoid)
		return humanoid:IsA("Humanoid") and humanoid:FindFirstChildOfClass("Animator") ~= nil
	end,
	ResolveAnimator = function(instance)
		return instance:FindFirstChildOfClass("Animator")
	end,
	ResolveRig = function(p)
		return p.Parent
	end
})