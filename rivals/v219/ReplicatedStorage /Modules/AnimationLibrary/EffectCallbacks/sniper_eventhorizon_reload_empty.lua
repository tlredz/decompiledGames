return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.38 / p) then
		return
	end

	object:PlayReloadStartParticles()

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:PlayReloadFinishParticles()
end