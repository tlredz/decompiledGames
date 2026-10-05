local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://15013593124"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://15013609350"

local function equipAnimation(p)
	pcall(function()
		if not p.Right.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end
	end)
end

local function unequipAnimation(p)
	pcall(function()
		if not p.Right.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end

		if not p.Right.Hidden.AnimationController:GetPlayingAnimationTracks()[1] then
			p.Right.Hidden.AnimationController:LoadAnimation(animation2):Play()
		end
	end)
end

return {
	Equip = {
		AnimationSequence = {
			{
				Animate = equipAnimation
			}
		},
		ApplyEndState = function(_) end
	},
	Unequip = {
		AnimationSequence = {
			{
				Animate = unequipAnimation
			}
		}
	}
}