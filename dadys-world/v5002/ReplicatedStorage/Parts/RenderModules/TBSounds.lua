local TweenService = game:GetService("TweenService")
local v = { "Idle_Circling_Loop", "Attack2_Gnawing_Loop", "FloppingOnFloor_Loop" }
local object = setmetatable({}, {
	__mode = "k"
})

local function findSound(instance, childName)
	if not instance then
		return nil
	end

	local sound = instance:FindFirstChild(childName, true)

	if sound and sound:IsA("Sound") then
		return sound
	end

	local v2 = object[instance]

	if not v2 then
		v2 = {}
		object[instance] = v2
	end

	if not v2[childName] then
		v2[childName] = true
		warn(("[TBSounds] Sound %q not found under %s"):format(childName, (tostring(instance))))
	end

	return nil
end

local TBSounds = {}
TBSounds.findSound = findSound

function TBSounds.playOneShot(p, p2)
	local sound = findSound(p, p2)

	if not sound then
		return
	end

	sound.Looped = false
	sound:Play()
end

function TBSounds.stop(p, p2)
	local sound = findSound(p, p2)

	if sound and sound.IsPlaying then
		sound:Stop()
	end
end

function TBSounds.setLoop(p, p2)
	if not p then
		return
	end

	for _, v2 in ipairs(v) do
		if v2 == p2 then
			local sound = findSound(p, v2)

			if sound then
				sound.Looped = true

				if not sound.IsPlaying then
					sound:Play()
				end
			end
		else
			local sound = findSound(p, v2)

			if sound and sound.IsPlaying then
				sound:Stop()
			end
		end
	end

	local sound = findSound(p, "PassiveOverlay_Loop")

	if sound then
		if p2 == nil then
			sound.Looped = true

			if not sound.IsPlaying then
				sound:Play()
			end
		elseif sound.IsPlaying then
			sound:Stop()
		end
	end
end

function TBSounds.fadeLoop(p, p2, duration, volume)
	local sound = findSound(p, p2)

	if not sound then
		return nil
	end

	local tween = TweenService:Create(sound, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = volume
	})
	tween:Play()
	return tween
end

return TBSounds