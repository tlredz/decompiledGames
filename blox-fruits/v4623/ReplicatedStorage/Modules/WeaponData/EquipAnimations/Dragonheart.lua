local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://129875171854093"

local function playAnimation(p)
	pcall(function()
		if not p.Right.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.AnimationController:LoadAnimation(animation):Play()
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