local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://137398396578767"

local function playUnequipAnim(p)
	pcall(function()
		local animationController = Instance.new("AnimationController")
		animationController.Parent = p.Right

		if not animationController:GetPlayingAnimationTracks()[1] then
			animationController:LoadAnimation(animation):Play()
		end
	end)
end

return {
	Unequip = {
		AnimationSequence = {
			{
				Animate = playUnequipAnim
			}
		}
	}
}