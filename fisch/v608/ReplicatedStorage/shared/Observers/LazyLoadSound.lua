local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.packages.Observers)
local Trove = require(ReplicatedStorage.packages.Trove)

local function lazyLoad(sound, maid)
	if sound.SoundId ~= "rbxassetid://131891729961185" then
		return
	end

	local soundId = sound:GetAttribute("SoundId")

	if soundId then
		local timePosition = sound.TimePosition
		sound.SoundId = soundId
		maid:Add(task.spawn(function()
			while sound.IsPlaying and not sound.IsLoaded do
				task.wait()
			end

			sound.TimePosition = timePosition
		end))
	elseif RunService:IsStudio() then
		warn((`LazyLoadSound {sound:GetFullName()} is missing its SoundId attribute somehow`))
	end
end

return Observers.observeTag("LazyLoadSound", function(sound)
	if not sound:IsA("Sound") then
		return nil
	end

	if RunService:IsServer() and sound.SoundId ~= "rbxassetid://131891729961185" then
		sound:SetAttribute("SoundId", sound.SoundId)
		sound.SoundId = "rbxassetid://131891729961185"
	end

	local maid = Trove.new()
	maid:Connect(sound.Played, function()
		lazyLoad(sound, maid)
	end)

	if sound.IsPlaying then
		lazyLoad(sound, maid)
	end

	maid:Add(function()
		if sound.Parent and not sound:HasTag("LazyLoadSound") then
			lazyLoad(sound, maid)
		end
	end)
	return maid:WrapClean()
end)