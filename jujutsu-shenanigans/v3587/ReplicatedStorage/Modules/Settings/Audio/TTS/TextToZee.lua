local TextToZee = {}
game:GetService("Debris")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TTS = ReplicatedStorage.Remotes.TTS

function syllable(childName, parent, data, value)
	if not (parent and childName) then
		return
	end

	local octave = (data.Pitch or 1) * (value or 1)
	local speed = data.Speed or 1
	local volume = data.Volume or 1
	local v2

	if #childName == 3 then
		v2 = string.sub(childName, 3, 3)
		childName = string.sub(childName, 1, 2)
	end

	local child = (script.Voices:FindFirstChild(data.Voice or "TTZ") or script.Voices.TTZ):FindFirstChild(childName)

	if child then
		local v3 = child.TimeLength == 0 and 0.1 or child.TimeLength or 0.1

		if v2 == "1" then
			volume += 0.25
			speed += 0.1
			octave += 0.05
		elseif v2 == "2" then
			volume += 0.1
			speed += 0.05
		elseif v2 == "0" then
			volume -= 0.1
			speed -= 0.075
		end

		local clone = child:Clone()
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Octave = octave
		pitchShiftSoundEffect.Parent = clone
		clone.SoundGroup = game.SoundService.Voice
		clone.PlaybackSpeed *= speed
		clone.Volume *= volume
		clone.Parent = parent
		clone:Play()
		task.delay(v3, function()
			clone:Destroy()
		end)
		local now = tick()
		local playbackLoudness = 0

		while not (clone.PlaybackLoudness < playbackLoudness) do
			playbackLoudness = clone.PlaybackLoudness
			RunService.RenderStepped:Wait()
			local now2 = tick()

			if now + v3 < now2 or not clone.Parent then
				break
			end
		end
	elseif childName == " " then
		task.wait(0.05 / speed)
	elseif childName == "." or childName == "!" or childName == "?" then
		task.wait(0.7 / speed)
	elseif childName == "," then
		task.wait(0.5 / speed)
	else
		task.wait(0.3 / speed)
	end
end

local v = {}

function TextToZee.TTS(p, p2, p3)
	local v2 = TTS:InvokeServer(p, p3.Accent)

	if not v2 then
		return
	end

	local now = tick()
	v[p2] = now

	for _, v3 in v2 do
		if v[p2] ~= now then
			break
		end

		for _, v4 in v3 do
			syllable(v4[1], p2, p3, v4[2])
		end
	end

	if v[p2] == now then
		v[p2] = nil
	end
end

return TextToZee