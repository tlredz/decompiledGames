local SoundService = game:GetService("SoundService")
local Common = require(script.Parent.Common)
local Interpolate = require(script.Parent.Interpolate)

local function resolveNumberAttribute(value, p: number, object)
	if typeof(value) == "number" then
		return value
	end

	if typeof(value) == "NumberRange" then
		return object:NextNumber(value.Min, value.Max)
	end

	return p
end

local VFXUtils = {}

function VFXUtils.emitAttachment(folder, p: number?, flag: boolean?, p2)
	local v = p2 or Common.GetRandom()

	for _, v2 in folder:QueryDescendants("ParticleEmitter") do
		if v2.Enabled then
			continue
		end

		local emitDelay = v2:GetAttribute("EmitDelay")

		if typeof(emitDelay) ~= "number" then
			emitDelay = typeof(emitDelay) ~= "NumberRange" and 0 or v:NextNumber(emitDelay.Min, emitDelay.Max)
		end

		local v3 = v2

		local function emit()
			if v3.Parent == nil then
				return
			end

			local emitDuration = v3:GetAttribute("EmitDuration")
			local v4 = v

			if typeof(emitDuration) ~= "number" then
				emitDuration = typeof(emitDuration) ~= "NumberRange" and 0 or v4:NextNumber(
					emitDuration.Min,
					emitDuration.Max
				)
			end

			if emitDuration > 0 then
				v3.Enabled = true
				task.delay(emitDuration, function()
					if v3.Parent then
						v3.Enabled = false
					end
				end)
			else
				local emitCount = p

				if not emitCount then
					emitCount = v3:GetAttribute("EmitCount")
					local v5 = v

					if typeof(emitCount) ~= "number" then
						emitCount = typeof(emitCount) ~= "NumberRange" and 1 or v5:NextNumber(
							emitCount.Min,
							emitCount.Max
						)
					end
				end

				v3:Emit((math.round(emitCount)))
				v3.Enabled = false
			end
		end

		if emitDelay > 0 then
			task.delay(emitDelay, emit)
		else
			emit()
		end
	end

	if flag == false then
		return
	end

	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		local delay = sound:GetAttribute("Delay")

		if typeof(delay) ~= "number" then
			delay = typeof(delay) ~= "NumberRange" and 0 or v:NextNumber(delay.Min, delay.Max)
		end

		local soundGroup = sound:GetAttribute("SoundGroup")

		if typeof(soundGroup) == "string" and soundGroup ~= "" then
			local soundGroup2 = SoundService:FindFirstChild(soundGroup)

			if soundGroup2 ~= nil and soundGroup2:IsA("SoundGroup") then
				sound.SoundGroup = soundGroup2
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local v2 = sound

		local function play()
			if v2.Parent == nil then
				return
			end

			v2:Stop()
			v2.TimePosition = 0
			v2:Play()
		end

		if delay > 0 then
			task.delay(delay, play)
		else
			play() -- equivalent call inferred; original call site unknown
		end
	end
end

function VFXUtils.scaleNumberSequence(sequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function VFXUtils.getNumberSequenceValueAtTime(sequence, p: number)
	local keypoints = sequence.Keypoints

	if #keypoints == 0 then
		return 0
	end

	if #keypoints == 1 then
		return keypoints[1].Value
	end

	local keypoint = keypoints[1]
	local keypoint2 = keypoints[#keypoints]

	for i = 2, #keypoints do
		if not (p < keypoints[i].Time) then
			continue
		end

		keypoint = keypoints[i - 1]
		keypoint2 = keypoints[i]
		break
	end

	local v = keypoint2.Time - keypoint.Time

	if v == 0 then
		return keypoint2.Value
	end

	local v2 = (p - keypoint.Time) / v
	return Interpolate.lerp(keypoint.Value, keypoint2.Value, v2)
end

return VFXUtils