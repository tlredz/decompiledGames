local track = script.Parent.AnimationController:LoadAnimation(script.Parent.Parent.Camera)

for _ = 1, 5 do
	track:Play(0)
	track:Stop(0)
	wait(0.5)
end

script:Destroy()