game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local AnimationController = {}
AnimationController.LoadedAnimations = {}

function AnimationController:ParseAnimationClass(animator)
	if animator and not animator:IsA("Animator") then
		if isStudio then
			warn((`[AnimationController] Using deprecated Animator class: {animator.ClassName}, traceback:\n{debug.traceback()}`))
		end

		animator = animator:FindFirstChildWhichIsA("Animator") or animator
	end

	assert(
		animator and (animator:IsA("Animator") or animator:IsA("Humanoid") or animator:IsA("AnimationController")),
		(`Invalid LoadAnimation, expected Animator, Humanoid or AnimationController got {animator == nil and "nil" or animator.ClassName}`)
	)
	return animator
end

function AnimationController:IsAnimationLoaded(p, p2)
	local loadedAnimationTracks = self:GetLoadedAnimationTracks((self:ParseAnimationClass(p)))

	for _, loadedAnimationTrack in loadedAnimationTracks do
		if loadedAnimationTrack:HasTag(p2.AnimationId) then
			return true, loadedAnimationTrack
		end
	end

	return false
end

function AnimationController:LoadAnimation(p, animation, flag: boolean?)
	local animator = self:ParseAnimationClass(p)

	if flag then
		local isAnimationLoaded, v = self:IsAnimationLoaded(animator, animation)

		if isAnimationLoaded and v then
			return v
		end
	end

	local loadedAnimationTracks = self:GetLoadedAnimationTracks(animator)
	local track = animator:LoadAnimation(animation)

	for k, v in animation:GetAttributes() do
		track:SetAttribute(k, v)
	end

	track:AddTag(animation.AnimationId)
	table.insert(loadedAnimationTracks, track)
	self:EvictStaleTracks(loadedAnimationTracks)
	return track
end

function AnimationController:EvictStaleTracks(list)
	local v = 1

	while #list > 48 and v <= #list do
		local v2 = list[v]

		if v2.IsPlaying then
			v += 1
		else
			table.remove(list, v)
			v2:Destroy()
		end
	end
end

function AnimationController:StopAndForget(p, instance)
	local animationClass = self:ParseAnimationClass(p)
	local loadedAnimation = self.LoadedAnimations[animationClass]
	local index = loadedAnimation and table.find(loadedAnimation, instance)

	if index then
		table.remove(loadedAnimation, index)
	end

	instance:Stop(0)
	instance:Destroy()
end

function AnimationController:GetLoadedAnimationTracks(p)
	local animationClass = self:ParseAnimationClass(p)
	local loadedAnimation = self.LoadedAnimations[animationClass]

	if not loadedAnimation then
		loadedAnimation = {}
		self.LoadedAnimations[animationClass] = loadedAnimation
		animationClass.AncestryChanged:Connect(function(_, parent)
			if not parent then
				for _, v in loadedAnimation do
					v:Stop(0)
					v:Destroy()
				end

				self.LoadedAnimations[animationClass] = nil
			end
		end)
	end

	return loadedAnimation
end

function AnimationController:GetPlayingAnimationTracks(p)
	return self:ParseAnimationClass(p):GetPlayingAnimationTracks()
end

return AnimationController