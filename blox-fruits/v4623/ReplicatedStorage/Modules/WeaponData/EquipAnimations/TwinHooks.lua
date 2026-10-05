local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://70853683091834"

local function playAnimation(p)
	pcall(function()
		if not p.Right.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.AnimationController:LoadAnimation(animation):Play()
		end
	end)
	pcall(function()
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