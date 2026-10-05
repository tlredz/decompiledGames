local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local AreaEggResetCycle = require(ReplicatedStorage.Data.AreaEggResetCycle)
local Audio = require(ReplicatedStorage.Shared.Audio)
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local MusicDirector = require(ReplicatedStorage.Client.MusicDirector)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local warmSounds = Preload.WarmSounds
local dayTransitionSoundId = AreaEggResetCycle.DayTransitionSoundId
local v = nil
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolvePhase(serverTimeNow: number)
			if Workspace:GetAttribute("Event_AdminAbuse") == true then
				return "Day"
			end

			if AreaEggCycle.IsNightPhase(serverTimeNow) then
				return "Night"
			end

			if AreaEggCycle.IsWithinNightTransition(
				serverTimeNow,
				AreaEggResetCycle.NightLightingTransitionSeconds,
				AreaEggResetCycle.NightLightingStartDelaySeconds
			) then
				return "NightTransition"
			end

			return "Day"
		end

		local function setPhase(p: string, flag: boolean, serverTimeNow: number)
			if v == p then
				return
			end

			local v2 = v
			v = p

			if p == "NightTransition" then
				local v3 = math.max(
					AreaEggCycle.NightStartTime(serverTimeNow) + AreaEggResetCycle.NightLightingStartDelaySeconds - serverTimeNow,
					0
				)
				LightingController.SetLayer(
					"AreaEggResetNight",
					AreaEggResetCycle.NightLighting,
					AreaEggResetCycle.LightingModifierPriority,
					v3
				)
				MusicDirector.SetResetNight(false)
			elseif p == "Night" then
				if v2 ~= "NightTransition" then
					local v3 = AreaEggCycle.NightStartTime(serverTimeNow) + AreaEggResetCycle.NightLightingStartDelaySeconds
					LightingController.SetLayer(
						"AreaEggResetNight",
						AreaEggResetCycle.NightLighting,
						AreaEggResetCycle.LightingModifierPriority,
						(math.max(v3 - serverTimeNow, 0))
					)
				end

				MusicDirector.SetResetNight(true, true)
			else
				LightingController.ClearLayer(
					"AreaEggResetNight",
					(flag or v2 == nil) and 0 or AreaEggResetCycle.DayLightingTransitionSeconds
				)
				MusicDirector.SetResetNight(false)

				if not flag and dayTransitionSoundId ~= nil then
					Audio.Play(dayTransitionSoundId, SoundService)
				end
			end
		end

		local function runCycle()
			local v2 = true

			while true do
				local serverTimeNow = Workspace:GetServerTimeNow()
				local phase = resolvePhase(serverTimeNow) -- equivalent call inferred; original call site unknown
				setPhase(phase, v2, serverTimeNow)
				v2 = false
				local v3

				if phase == "Night" then
					v3 = AreaEggCycle.NextResetTime(serverTimeNow)
				elseif phase == "NightTransition" then
					v3 = AreaEggCycle.NightStartTime(serverTimeNow)
				else
					v3 = AreaEggCycle.NightTransitionStartTime(
						serverTimeNow,
						AreaEggResetCycle.NightLightingTransitionSeconds,
						AreaEggResetCycle.NightLightingStartDelaySeconds
					)
				end

				task.wait((math.clamp(v3 - Workspace:GetServerTimeNow(), 0.05, AreaEggCycle.SchedulePollSeconds)))
			end
		end

		if dayTransitionSoundId ~= nil then
			task.spawn(warmSounds, dayTransitionSoundId)
		end

		Workspace:GetAttributeChangedSignal("Event_AdminAbuse"):Connect(function()
			local serverTimeNow = Workspace:GetServerTimeNow()
			setPhase(resolvePhase(serverTimeNow), false, serverTimeNow)
		end)
		runCycle()
	end
}