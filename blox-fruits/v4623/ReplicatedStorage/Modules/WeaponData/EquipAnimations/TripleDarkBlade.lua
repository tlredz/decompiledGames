local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://15013593124"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://15013609350"

local function equipAnimation(data)
	pcall(function()
		if not data.Right.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Right.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end

		if not data.Left.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Left.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end

		if not data.Head.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Head.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end
	end)
end

local function unequipAnimation(data)
	pcall(function()
		if not data.Right.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Right.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end

		if not data.Left.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Left.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end

		if not data.Head.DarkBlade.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Head.DarkBlade.AnimationController:LoadAnimation(animation):Play()
		end

		if not data.Right.Hidden.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Right.Hidden.AnimationController:LoadAnimation(animation2):Play()
		end

		if not data.Left.Hidden.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Left.Hidden.AnimationController:LoadAnimation(animation2):Play()
		end

		if not data.Head.Hidden.AnimationController:GetPlayingAnimationTracks()[1] then
			data.Head.Hidden.AnimationController:LoadAnimation(animation2):Play()
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