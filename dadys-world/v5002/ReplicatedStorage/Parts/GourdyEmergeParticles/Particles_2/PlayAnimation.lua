local parent = script.Parent

if not parent then
	return
end

local humanoid = parent:FindFirstChildOfClass("Humanoid") or parent:FindFirstChildOfClass("AnimationController")

if not humanoid then
	warn("[AnimationScript] No Humanoid or AnimationController found!")
	return
end

local v = humanoid:FindFirstChildOfClass("Animator")

if not v then
	v = Instance.new("Animator")
	v.Name = "Animator"
	v.Parent = humanoid
end

local animation = script:FindFirstChildOfClass("Animation")
local v2 = "Script"

if not animation then
	local animations = parent:FindFirstChild("Animations")

	if animations then
		animation = animations:FindFirstChild("Idle")

		if animation then
			v2 = "Animations.Idle"
		else
			for _, animation2 in animations:GetChildren() do
				if not animation2:IsA("Animation") then
					continue
				end

				v2 = "Animations." .. animation2.Name
				animation = animation2
				break
			end
		end
	end
end

if not animation then
	warn("[AnimationScript] No Animation found in script or Animations folder!")
	return
end

for _, v3 in v:GetPlayingAnimationTracks() do
	v3:Stop()
end

local track = v:LoadAnimation(animation)
track.Looped = true
track:Play()
print((`[AnimationScript] Playing animation '{animation.Name}' from: {v2}`))