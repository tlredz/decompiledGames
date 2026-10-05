local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://134935771768187"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://102742789963001"

local function playAnimation(p)
	pcall(function()
		if not p.Right.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.AnimationController:LoadAnimation(animation2):Play()
		end

		if not p.Left.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Left.AnimationController:LoadAnimation(animation):Play()
		end
	end)
end

return {
	Equip = {
		AnimationSequence = {
			{
				Animate = playAnimation
			}
		},
		ApplyEndState = function(_) end
	},
	Unequip = {
		AnimationSequence = {
			{
				Animate = playAnimation
			}
		}
	}
}