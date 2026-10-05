local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://14798231537"

local function playIdleAnimation(p)
	pcall(function()
		if not p.Right.Anchor.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.Anchor.AnimationController:LoadAnimation(animation):Play()
		end
	end)
end

return {
	Equip = {
		AnimationSequence = {
			{
				Animate = playIdleAnimation
			}
		},
		ApplyEndState = function(_) end
	},
	Unequip = {
		AnimationSequence = {
			{
				Animate = playIdleAnimation
			}
		}
	}
}