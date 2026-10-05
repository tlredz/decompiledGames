local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://15532985167"

local function playFlagAnimation(p)
	pcall(function()
		if not p.Right.FoxLamp.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.FoxLamp.AnimationController:LoadAnimation(animation):Play()
		end
	end)
end

return {
	Equip = {
		AnimationSequence = {
			{
				Animate = playFlagAnimation
			}
		},
		ApplyEndState = function(_) end
	},
	Unequip = {
		AnimationSequence = {
			{
				Animate = playFlagAnimation
			}
		}
	}
}