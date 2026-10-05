local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local lastTime = nil
local v = nil
local geographicLatitude = Lighting.GeographicLatitude
local localPlayer = Players.LocalPlayer
local v2 = nil
local CycleController = {
	IsNight = function(_)
		return workspace:GetServerTimeNow() % 1800 >= 900
	end,
	IsDay = function(_)
		return workspace:GetServerTimeNow() % 1800 < 900
	end,
	Update = function(self)
		lastTime = os.clock()
		local v3 = true
		local crystalEvent = ReplicatedStorage:GetAttribute("CrystalEvent") == true
		local eclipseEvent = ReplicatedStorage:GetAttribute("EclipseEvent") == true
		Lighting.GeographicLatitude = (crystalEvent or eclipseEvent) and 210 or geographicLatitude
		local state

		if v2 then
			local v4 = v2:Get("Overrides")[1]

			if v4 then
				state = v4.state
			end
		end

		local v4 = ReplicatedStorage:GetAttribute("BloodmoonEvent") and 20 or state
		local v5 = ReplicatedStorage:GetAttribute("CandyEvent") and 14 or v4
		local v6 = ReplicatedStorage:GetAttribute("SummerHourEvent") and 14 or v5

		if ReplicatedStorage:GetAttribute("GalaxyEvent") or ReplicatedStorage:GetAttribute("YinYangEvent") or ReplicatedStorage:GetAttribute("RadioactiveEvent") or ReplicatedStorage:GetAttribute("UFOEvent") or ReplicatedStorage:GetAttribute("StrawberryEvent") or ReplicatedStorage:GetAttribute("WitchingHourEvent") or ReplicatedStorage:GetAttribute("WinterHourEvent") or ReplicatedStorage:GetAttribute("GingerbreadTownEvent") or ReplicatedStorage:GetAttribute("SkibidiEvent") or ReplicatedStorage:GetAttribute("AyMiGatitoEvent") then
			v3 = false
			v6 = 11
		end

		if ReplicatedStorage:GetAttribute("TrickOrTreatEvent") or ReplicatedStorage:GetAttribute("GraveyardEvent") then
			v3 = false
			v6 = 5
		end

		local v7 = (ReplicatedStorage:GetAttribute("Effect_Space") or ReplicatedStorage:GetAttribute("NyanCatsEvent") or ReplicatedStorage:GetAttribute("1YearEvent") or ReplicatedStorage:GetAttribute("10BVisitsEvent") or ReplicatedStorage:GetAttribute("GlitchEvent") or ReplicatedStorage:GetAttribute("MoltenEvent") or ReplicatedStorage:GetAttribute("BombardiroCrocodiloEvent") or ReplicatedStorage:GetAttribute("Starfall") or ReplicatedStorage:GetAttribute("LosMatteosEventNightTime") or ReplicatedStorage:GetAttribute("SammyniSpyderiniEvent") or ReplicatedStorage:GetAttribute("MeowlEvent") or ReplicatedStorage:GetAttribute("CursedEvent") or ReplicatedStorage:GetAttribute("CyberEvent") or ReplicatedStorage:GetAttribute("PhantomEvent") or ReplicatedStorage:GetAttribute("ValentinesEvent") or ReplicatedStorage:GetAttribute("RipMyGrannyEvent")) and 0 or v6
		local v8 = ReplicatedStorage:GetAttribute("ChicleteiraBicicleteiraEvent") and 6 or (crystalEvent or eclipseEvent) and 12 or v7
		local v9 = ReplicatedStorage:GetAttribute("WaterEvent") and 14.5 or v8
		local clockTimeOverride = ReplicatedStorage:GetAttribute("CrabRave") and 14 or v9

		if ReplicatedStorage:GetAttribute("2026Event") or ReplicatedStorage:GetAttribute("ConcertEvent") or ReplicatedStorage:GetAttribute("RapConcertEvent") or ReplicatedStorage:GetAttribute("BrazilEvent") or ReplicatedStorage:GetAttribute("4thOfJulyEvent") then
			clockTimeOverride = 0
			v3 = false
		end

		if ReplicatedStorage:GetAttribute("LanceEvent") then
			clockTimeOverride = 4
			v3 = false
		end

		if ReplicatedStorage:GetAttribute("NorthPoleEventActive") and localPlayer:GetAttribute("InNorthPole") then
			clockTimeOverride = 11
			v3 = false
		end

		local v10 = not clockTimeOverride

		if not clockTimeOverride then
			local v11 = workspace:GetServerTimeNow() % 1800

			if v11 < 900 then
				clockTimeOverride = 6 + v11 / 900 * 12
			else
				clockTimeOverride = 18 + (v11 - 900) / 900 * 12

				if clockTimeOverride >= 24 then
					clockTimeOverride -= 24
				end
			end

			if ReplicatedStorage:GetAttribute("ClockTimeOverride") then
				clockTimeOverride = ReplicatedStorage:GetAttribute("ClockTimeOverride")
			end
		end

		if math.abs(clockTimeOverride - Lighting.ClockTime) > 1 and v10 ~= v then
			TweenService:Create(Lighting, TweenInfo.new(5), {
				ClockTime = clockTimeOverride
			}):Play()
			TweenService:Create(Lighting.SunRays, TweenInfo.new(1), {
				Intensity = v3 and 0.071 or 0
			})
		else
			Lighting.ClockTime = clockTimeOverride
			Lighting.SunRays.Intensity = v3 and 0.071 or 0
		end

		v = v10
	end
}

function CycleController.Start(_)
	task.spawn(function()
		while true do
			if not lastTime or os.clock() - lastTime >= 5 then
				CycleController:Update()
			end

			task.wait(1)
		end
	end)
	v2 = Synchronizer:Wait("Cycle")
	v2:OnArrayInserted("Overrides", function()
		CycleController:Update()
	end)
	v2:OnArrayRemoved("Overrides", function()
		CycleController:Update()
	end)
end

return CycleController