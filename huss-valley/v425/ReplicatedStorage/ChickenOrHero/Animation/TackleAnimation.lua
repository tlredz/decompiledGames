local AnimationConfig = require(script.Parent.AnimationConfig)
local DaggerConfig = require(script.Parent.Parent.Weapons.DaggerConfig)
local TackleAnimation = {}
local v = {}

function TackleAnimation.release(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil

	for _, connection in v2.connections do
		connection:Disconnect()
	end

	for _, track in v2.tracks do
		track.track:Destroy()
		track.asset:Destroy()
	end
end

local function loadTrack(instance, p)
	if not AnimationConfig.Enabled then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local publishedId = AnimationConfig.PublishedIds[p]

	if not animator or humanoid.RigType ~= Enum.HumanoidRigType.R6 or not publishedId or publishedId == "" then
		return
	end

	local v2 = v[instance]

	if v2 and v2.animator ~= animator then
		TackleAnimation.release(instance)
		v2 = nil
	end

	if not v2 then
		v2 = {
			animator = animator,
			tracks = {},
			connections = {}
		}
		v[instance] = v2
		table.insert(v2.connections, instance.Destroying:Connect(function()
			TackleAnimation.release(instance)
		end))
		table.insert(v2.connections, humanoid.Died:Connect(function()
			TackleAnimation.stop(instance)
		end))
	end

	if v2.tracks[p] then
		return v2.tracks[p].track
	end

	local animation = Instance.new("Animation")
	animation.Name = "CoH_" .. p
	animation.AnimationId = publishedId
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if success then
		result.Name = animation.Name
		result.Looped = false
		result.Priority = Enum.AnimationPriority.Action3
		v2.tracks[p] = {
			track = result,
			asset = animation
		}
		return result
	else
		animation:Destroy()
		warn("Chicken or Hero: could not load catch animation: " .. tostring(result))
	end
end

function TackleAnimation.prepare(p)
	return loadTrack(p, AnimationConfig.Tackle.Clip)
end

function TackleAnimation.stop(p)
	local v2 = v[p]

	if v2 then
		v2.token = (v2.token or 0) + 1

		for _, track in v2.tracks do
			if track.track.IsPlaying then
				track.track:Stop(AnimationConfig.Tackle.FadeOut)
			end
		end
	end
end

function TackleAnimation.play(p, p2, p3)
	local v2 = loadTrack(p, p2 or AnimationConfig.Tackle.Clip)

	if not v2 then
		return false
	end

	TackleAnimation.stop(p)
	local length = v2.Length > 0 and v2.Length or AnimationConfig.Tackle.ClipLength

	if p2 == "DaggerDive" then
		p3 = math.min(p3, DaggerConfig.DiveDuration) or p3
	end

	v2:Play(AnimationConfig.Tackle.FadeIn, 1, length / math.max(p3, 0.05))
	v2.TimePosition = 0

	if p2 == "DaggerDive" then
		local v3 = v[p]
		local token = v3.token
		task.delay(math.max(0.05, p3 - 0.02), function()
			if v[p] ~= v3 or v3.token ~= token or not v2.IsPlaying then
				return
			end

			if v2.Length > 0 then
				v2.TimePosition = math.max(0, v2.Length - 0.002)
			end

			v2:AdjustSpeed(0)
			v2:Stop(DaggerConfig.DiveFadeOut)
		end)
	end

	return true
end

return TackleAnimation