local tracks = {}
local v = {
	Looped = true,
	IsPlaying = true,
	Play = function(_) end,
	Stop = function(_) end,
	AdjustSpeed = function(_) end
}
local AnimationPlayer = {}

function AnimationPlayer.playAnimation(instance, value, _, p)
	if not (instance and instance.Parent) or instance.Parent:FindFirstChild("Ragdoll") and value ~= 14840458512 then
		return v
	end

	if rawget(tracks, value) then
		return tracks[value]
	end

	if not value or p then
		return
	end

	local animationId

	if typeof(value) == "string" then
		animationId = tonumber((string.gsub(value, "rbxassetid://", ""):gsub("[^%-%d]", "")))
	else
		animationId = value
	end

	local animation = Instance.new("Animation")

	if typeof(animationId) == "string" then
		animation.AnimationId = animationId
	elseif typeof(animationId) == "number" then
		animation.AnimationId = "rbxassetid://" .. animationId
	elseif typeof(animationId) == "Instance" then
		local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
		animation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(animationId)
	end

	local animator = instance:WaitForChild("Animator", 2)

	if not (animator and animator.Parent) then
		return
	end

	local track = animator:LoadAnimation(animation)
	tracks[value] = track
	track:AdjustWeight(0.001)
	return track
end

function AnimationPlayer.GetStorage(_)
	return tracks
end

return AnimationPlayer