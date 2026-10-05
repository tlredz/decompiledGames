local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://102742789963001"

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