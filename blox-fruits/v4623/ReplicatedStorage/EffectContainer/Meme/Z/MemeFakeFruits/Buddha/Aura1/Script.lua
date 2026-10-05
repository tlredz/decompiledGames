local parent = script.Parent.Parent
local animation = parent.Animation
local track = parent.AnimationController.Animator:LoadAnimation(animation)
track:Play()
local particle_2 = script.Parent.Attachment.Particle_2
track:GetMarkerReachedSignal("AWAKE"):Connect(function()
	if parent:IsDescendantOf(workspace) then
		particle_2:Emit(1)
	end
end)