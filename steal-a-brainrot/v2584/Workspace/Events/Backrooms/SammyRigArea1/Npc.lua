local animator = script.Parent.AnimationController.Animator
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://118917391193529"
local track = animator:LoadAnimation(animation)
track:Play()
track.Looped = true