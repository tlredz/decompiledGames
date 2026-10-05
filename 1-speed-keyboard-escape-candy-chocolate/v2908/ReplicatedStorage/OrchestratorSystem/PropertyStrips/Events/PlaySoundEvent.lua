local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent.OrchestratorState)
local v = nil

local function GetSoundManager()
	if not v then
		local SoundManager = require(ReplicatedStorage.SoundManager)
		v = SoundManager
	end

	return v
end

local function ValidateCommand(value)
	if type(value) ~= "table" then
		return false, "Play Sound events must contain a command table."
	end

	if type(value.SoundName) ~= "string" or value.SoundName == "" then
		return false, "Sound name must be a non-empty string."
	end

	if #value.SoundName > 100 then
		return false, "Sound name cannot exceed 100 bytes."
	end

	return true, nil
end

local PlaySoundEvent = {}
PlaySoundEvent.Type = "PlaySoundEvent"
PlaySoundEvent.DisplayName = "Play Sound"
PlaySoundEvent.GlobalEvent = true
PlaySoundEvent.CreateInitialKeyframe = false
PlaySoundEvent.HasKeyframeEasing = false
PlaySoundEvent.EditableProperties = {
	{
		Path = { "Value", "SoundName" },
		DisplayName = "Sound Name",
		ValueType = "string",
		Default = "CLICK"
	}
}

function PlaySoundEvent.Supports(p)
	return p == game
end

function PlaySoundEvent.ValidateKeyframe(p)
	return ValidateCommand(p.Value)
end

function PlaySoundEvent.Capture(_)
	return {
		SoundName = "CLICK"
	}
end

function PlaySoundEvent.Evaluate(data)
	if not RunService:IsRunning() or data.IsServer or data.IsSeeking or data.TimePosition <= data.PreviousTimePosition then
		return
	end

	for _, keyframe in data.Strip.Keyframes do
		local v2

		if keyframe.Time <= data.TimePosition then
			if keyframe.Time > data.PreviousTimePosition then
				v2 = true
			elseif keyframe.Time == 0 then
				v2 = data.PreviousTimePosition == 0
			else
				v2 = false
			end
		else
			v2 = false
		end

		if not v2 then
			continue
		end

		local value = keyframe.Value

		if not v then
			local SoundManager = require(ReplicatedStorage.SoundManager)
			v = SoundManager
		end

		v:Play(value.SoundName)
	end
end

return PlaySoundEvent