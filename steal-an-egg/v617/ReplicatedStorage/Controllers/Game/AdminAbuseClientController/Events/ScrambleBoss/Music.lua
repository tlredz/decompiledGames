local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local MusicDirector = require(ReplicatedStorage.Client.MusicDirector)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local music = ReplicatedStorage.Assets.Sounds:WaitForChild("ScrambleBoss"):WaitForChild("Music")
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function trackFor(instance)
	local phase = instance:GetAttribute("Phase") or "Waiting"

	if phase == "Defeated" then
		return nil
	end

	if phase == "Ball" or phase == "Human" or phase == "Final" then
		return "PhaseThree"
	end

	if instance:GetAttribute("PhaseTwo") then
		return "PhaseTwo"
	end

	return "PhaseOne"
end

return {
	new = function(maid, instance, object)
		local volumesByName = {}
		local clonesByName = {}
		local v = {}
		local v2 = false
		local v3 = false
		local v4 = nil

		for _, sound in music:GetChildren() do
			if not sound:IsA("Sound") then
				continue
			end

			local clone = sound:Clone()
			volumesByName[clone.Name] = clone.Volume
			clone.Volume = 0
			clone.Parent = SoundService
			clonesByName[clone.Name] = clone
		end

		local function fade(object2, volume: number, tweenInfo3)
			local v5 = v[object2]

			if v5 then
				v5:Cancel()
			end

			if volume > 0 and not object2.IsPlaying then
				object2.TimePosition = 0
				object2:Play()
			end

			local tween = TweenService:Create(object2, tweenInfo3, {
				Volume = volume
			})
			v[object2] = tween
			tween.Completed:Once(function(p2)
				if v[object2] == tween then
					v[object2] = nil
				end

				if p2 == Enum.PlaybackState.Completed and volume <= 0 then
					object2:Stop()
				end
			end)
			tween:Play()
		end

		local function apply()
			local v5 = object:InArena()

			if v5 ~= v2 then
				v2 = v5
				MusicDirector.SetEventMusic(v2)
			end

			local v6

			if v3 and v2 then
				local v7 = instance
				local phase = v7:GetAttribute("Phase") or "Waiting"

				if phase ~= "Defeated" then
					v6 = (phase == "Ball" or phase == "Human" or phase == "Final") and "PhaseThree" or v7:GetAttribute("PhaseTwo") and "PhaseTwo" or "PhaseOne"
				end
			end

			if v6 == v4 then
				return
			end

			local v7 = v4
			v4 = v6
			local v8 = instance:GetAttribute("Phase") == "Defeated"

			for k, v9 in clonesByName do
				if k == v6 then
					fade(v9, volumesByName[k], tweenInfo)
				elseif k == v7 then
					local v12

					if v8 then
						v12 = tweenInfo2
					else
						v12 = tweenInfo
					end

					fade(v9, 0, v12)
				end
			end
		end

		maid:Add(Preferences.Observe("Music", function(flag: boolean?)
			v3 = flag ~= false
			apply()
		end))
		maid:Connect(RunService.Heartbeat, apply)
		maid:Add(function()
			for _, v5 in clonesByName do
				local v6 = v[v5]

				if v6 then
					v6:Cancel()
				end

				TweenService:Create(v5, tweenInfo, {
					Volume = 0
				}):Play()
				Debris:AddItem(v5, tweenInfo.Time)
			end

			if v2 then
				MusicDirector.SetEventMusic(false)
			end
		end)
		apply()
	end
}