local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local CycleController = require(controllers.CycleController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Synchronizer = require(packages.Synchronizer)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local utils = ReplicatedStorage:WaitForChild("Utils")
local StringUtils = require(utils.StringUtils)
local remoteEvent = Net:RemoteEvent("SoundService/PlayClientSound")
local v = {}
local sounds = workspace:WaitForChild("Sounds")
local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)
local localPlayer = Players.LocalPlayer
local SoundController = {
	PlaySound = function(self, sound, position: Vector3?, flag: boolean?)
		local v2 = flag ~= false
		local v3 = nil

		if typeof(sound) == "Instance" and sound:IsA("Sound") then
			v3 = sound
		elseif typeof(sound) == "string" then
			v3 = v[sound]

			if not (v3 and v3.Parent) then
				v[sound] = StringUtils:ReadPath(ReplicatedStorage, sound)
				v3 = v[sound]
			end
		end

		if not v3 then
			return warn((`Sound not found for {sound}`))
		end

		if position then
			local part = Instance.new("Part")
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.Anchored = true
			part.Parent = workspace
			part.Transparency = 1
			part.Position = position
			local clone = v3:Clone()
			local soundId = clone:GetAttribute("SoundId")

			if soundId then
				clone:SetAttribute("SoundId", nil)
				clone.SoundId = soundId
			end

			clone.Parent = part
			local v4

			if v2 then
				local lastTime = os.clock()
				v4 = clone

				while not (clone.IsLoaded or os.clock() - lastTime >= 2) do
					task.wait()
				end

				if clone.IsLoaded then
					clone:Play()
				else
					part:Destroy()
				end
			else
				clone:Play()
				v4 = clone
			end

			clone.Ended:Once(function()
				part:Destroy()
			end)
			return v4
		else
			local clone = v3:Clone()
			local soundId = clone:GetAttribute("SoundId")

			if soundId then
				clone:SetAttribute("SoundId", nil)
				clone.SoundId = soundId
			end

			clone.Parent = workspace
			local v4

			if v2 then
				local lastTime = os.clock()
				v4 = clone

				while not (clone.IsLoaded or os.clock() - lastTime >= 2) do
					task.wait()
				end

				if clone.IsLoaded then
					clone:Play()
				else
					clone:Destroy()
				end
			else
				clone:Play()
				v4 = clone
			end

			clone.Ended:Once(function()
				clone:Destroy()
			end)
			return v4
		end
	end
}
local v2 = 1

local function updateEventMusicVolume()
	local volume = ReplicatedStorage:GetAttribute("KarkerkarKurkurEvent") and 0 or 1

	if v2 == volume then
		return
	end

	v2 = volume
	CreateTween(SoundService.Cutscene.WorkspaceSounds.EventMusic, TweenInfo.new(1), {
		Volume = volume
	})
end

function SoundController:UpdateOST()
	updateEventMusicVolume()
	local laserCity

	if not (ReplicatedStorage:GetAttribute("ConcertEvent") or ReplicatedStorage:GetAttribute("RapConcertEvent") or ReplicatedStorage:GetAttribute("BrazilEvent")) then
		if ReplicatedStorage:GetAttribute("LaserCityEvent") then
			laserCity = sounds:FindFirstChild("Laser City")
		elseif not (ReplicatedStorage:GetAttribute("LanceEvent") or ReplicatedStorage:GetAttribute("MexicoEvent") or ReplicatedStorage:GetAttribute("SpainEvent") or ReplicatedStorage:GetAttribute("AyMiGatitoEvent") or ReplicatedStorage:GetAttribute("RipMyGrannyEvent")) then
			if ReplicatedStorage:GetAttribute("IndonesiaEventPart2") then
				laserCity = sounds.IndonesiaEventPart2
			elseif not (ReplicatedStorage:GetAttribute("IndonesiaEvent") or ReplicatedStorage:GetAttribute("KarkerkarKurkurEvent")) then
				if ReplicatedStorage:GetAttribute("BeeSwarmEvent") then
					laserCity = sounds.Bee
				elseif ReplicatedStorage:GetAttribute("2026EventSound") then
					laserCity = sounds["2026"]
				elseif ReplicatedStorage:GetAttribute("RainingBurgersEvent") then
					laserCity = sounds.RainingBurgers
				elseif ReplicatedStorage:GetAttribute("CrabRave") then
					laserCity = sounds.CrabRave
				elseif ReplicatedStorage:GetAttribute("RainingTacosEvent") then
					laserCity = sounds.RainingTacos
				elseif ReplicatedStorage:GetAttribute("4thOfJulyEvent") then
					laserCity = sounds["4thOfJuly"]
				elseif not ReplicatedStorage:GetAttribute("1YearEvent") then
					if ReplicatedStorage:GetAttribute("10BVisitsEvent") then
						laserCity = sounds["10B"]
					elseif ReplicatedStorage:GetAttribute("NyanCatsEvent") then
						laserCity = sounds.NyanCats
					elseif ReplicatedStorage:GetAttribute("SammyniSpyderiniEvent") then
						laserCity = sounds["Sammyni Spyderini"]
					elseif ReplicatedStorage:GetAttribute("MatteoEvent") or ReplicatedStorage:GetAttribute("LosMatteosEvent") then
						laserCity = sounds.Matteo
					elseif ReplicatedStorage:GetAttribute("UFOEvent") then
						laserCity = sounds.UFO
					elseif ReplicatedStorage:GetAttribute("MeowlEvent") then
						laserCity = sounds.Meowl
					elseif ReplicatedStorage:GetAttribute("SkibidiEvent") then
						laserCity = sounds.Skibidi
					elseif ReplicatedStorage:GetAttribute("JohnPorkEvent") then
						laserCity = sounds["John Pork"]
					elseif ReplicatedStorage:GetAttribute("TrickOrTreatEvent") then
						laserCity = sounds["Trick or Treat"]
					elseif ReplicatedStorage:GetAttribute("ValentinesEvent") then
						laserCity = sounds.Valentines
					elseif ReplicatedStorage:GetAttribute("YinYangEvent") then
						laserCity = sounds.YinYang
					elseif ReplicatedStorage:GetAttribute("GalaxyEvent") then
						laserCity = sounds.Galaxy
					elseif ReplicatedStorage:GetAttribute("MoltenEvent") then
						laserCity = sounds.Night
					elseif ReplicatedStorage:GetAttribute("CandyEvent") then
						laserCity = sounds.Candy
					elseif ReplicatedStorage:GetAttribute("BloodmoonEvent") then
						laserCity = sounds.Bloodmoon
					elseif ReplicatedStorage:GetAttribute("RainbowEvent") then
						laserCity = sounds.Rainbow
					elseif ReplicatedStorage:GetAttribute("BombardiroCrocodiloEvent") then
						laserCity = sounds["Bombardiro Crocodilo"]
					elseif CycleController:IsNight() or ReplicatedStorage:GetAttribute("LaVaccaEvent") then
						laserCity = sounds.Night
					else
						laserCity = sounds.Day
					end
				end
			end
		end
	end

	for _, child in sounds:GetChildren() do
		if child.Name:match("^Ambience_") or child == sounds.LaVacca or child == sounds.Molten or child == sounds["Bombardiro Crocodilo Ambience"] then
			continue
		end

		if not (child ~= sounds.Concert and child ~= sounds.RapConcert and child ~= sounds.BrazilEvent and child ~= sounds.MexicoEvent) then
			continue
		end

		if not (child ~= sounds.SpainEvent and child ~= sounds.IndonesiaEvent and child ~= sounds.AyMiGatito and child ~= sounds.RipMyGranny) then
			continue
		end

		local defaultVolume = child:GetAttribute("DefaultVolume")

		if not defaultVolume then
			child:SetAttribute("DefaultVolume", child.Volume)
			defaultVolume = child.Volume
		end

		if child == laserCity then
			if not child.IsPlaying then
				child.Volume = 0
				TweenService:Create(child, tweenInfo, {
					Volume = defaultVolume
				}):Play()
				child:Play()
			end
		elseif child.IsPlaying then
			local tween = TweenService:Create(child, tweenInfo, {
				Volume = 0
			})
			local v3 = child
			tween.Completed:Once(function()
				v3:Stop()
			end)
			tween:Play()
		end
	end

	if ReplicatedStorage:GetAttribute("MoltenEvent") == true then
		if not sounds.Molten.IsPlaying then
			sounds.Molten:Play()
		end
	elseif sounds.Molten.IsPlaying then
		sounds.Molten:Stop()
	end

	if ReplicatedStorage:GetAttribute("BombardiroCrocodiloEventSoundTrack") == true then
		if not sounds["Bombardiro Crocodilo Ambience"].IsPlaying then
			sounds["Bombardiro Crocodilo Ambience"]:Play()
		end
	elseif sounds["Bombardiro Crocodilo Ambience"].IsPlaying then
		sounds["Bombardiro Crocodilo Ambience"]:Stop()
	end

	if ReplicatedStorage:GetAttribute("Effect_Space") == true then
		if not sounds.LaVacca.IsPlaying then
			sounds.LaVacca:Play()
		end
	elseif sounds.LaVacca.IsPlaying then
		sounds.LaVacca:Stop()
	end

	if ReplicatedStorage:GetAttribute("GlitchEvent") == true then
		if not sounds.Glitch.IsPlaying then
			sounds.Glitch:Play()
			TweenService:Create(sounds.Glitch, tweenInfo, {
				Volume = 0.1
			}):Play()
		end
	elseif sounds.Glitch.IsPlaying and sounds.Glitch.Volume > 0.0001 then
		local tween = TweenService:Create(sounds.Glitch, tweenInfo, {
			Volume = 0
		})
		tween:Play()
		tween.Completed:Once(function()
			if sounds.Glitch.IsPlaying and sounds.Glitch.Volume <= 0.0001 then
				sounds.Glitch:Stop()
			end
		end)
	end
end

function SoundController:UpdateAmbience()
	local v3 = {
		Rain = sounds:FindFirstChild("Ambience_Rain"),
		Snow = sounds:FindFirstChild("Ambience_Snow"),
		Starfall = sounds:FindFirstChild("Ambience_Starfall"),
		Water = sounds:FindFirstChild("Ambience_Water"),
		Strawberry = sounds:FindFirstChild("Ambience_Strawberry"),
		Extinct = sounds:FindFirstChild("Ambience_Extinct"),
		["Witching Hour"] = sounds:FindFirstChild("Ambience_Witching Hour"),
		Indonesia = sounds:FindFirstChild("Ambience_IndonesiaEvent"),
		Radioactive = sounds:FindFirstChild("Ambience_Radioactive"),
		Cursed = sounds:FindFirstChild("Ambience_Cursed"),
		Divine = sounds:FindFirstChild("Ambience_Divine"),
		Cyber = sounds:FindFirstChild("Ambience_Cyber"),
		Phantom = sounds:FindFirstChild("Ambience_Phantom"),
		Crystal = sounds:FindFirstChild("Ambience_Crystal"),
		Eclipse = sounds:FindFirstChild("Ambience_Eclipse"),
		JobJobJobSahur = sounds:FindFirstChild("Ambience_JobJobJobSahur"),
		MoneyMoneyPuggy = sounds:FindFirstChild("Ambience_MoneyMoneyPuggy"),
		StPatricks = sounds:FindFirstChild("Ambience_StPatricks"),
		Eid = sounds:FindFirstChild("Ambience_Eid"),
		Easter = sounds:FindFirstChild("Ambience_Easter"),
		EggCity = sounds:FindFirstChild("Ambience_EggCity"),
		BackroomsInside = sounds:FindFirstChild("Ambience_BackroomsInside")
	}
	local backroomsInside = nil

	if localPlayer and localPlayer:GetAttribute("BackroomsCaveInside") then
		backroomsInside = v3.BackroomsInside
	elseif not (ReplicatedStorage:GetAttribute("LanceEvent") or ReplicatedStorage:GetAttribute("RipMyGrannyEvent")) then
		if ReplicatedStorage:GetAttribute("IndonesiaEventAmbience") then
			backroomsInside = v3.Indonesia
		elseif ReplicatedStorage:GetAttribute("RadioactiveEvent") then
			backroomsInside = v3.Radioactive
		elseif ReplicatedStorage:GetAttribute("CursedEvent") then
			backroomsInside = v3.Cursed
		elseif ReplicatedStorage:GetAttribute("DivineEvent") then
			backroomsInside = v3.Divine
		elseif ReplicatedStorage:GetAttribute("CyberEvent") then
			backroomsInside = v3.Cyber
		elseif ReplicatedStorage:GetAttribute("EclipseEvent") then
			backroomsInside = v3.Eclipse
		elseif ReplicatedStorage:GetAttribute("PhantomEvent") then
			backroomsInside = v3.Phantom
		elseif ReplicatedStorage:GetAttribute("CrystalEvent") then
			backroomsInside = v3.Crystal
		elseif ReplicatedStorage:GetAttribute("Starfall") then
			backroomsInside = v3.Starfall
		elseif ReplicatedStorage:GetAttribute("Rain") or ReplicatedStorage:GetAttribute("LosMatteosEvent") then
			backroomsInside = v3.Rain
		elseif ReplicatedStorage:GetAttribute("WaterEvent") then
			backroomsInside = v3.Water
		elseif ReplicatedStorage:GetAttribute("Snow") then
			backroomsInside = v3.Snow
		elseif ReplicatedStorage:GetAttribute("StrawberryEvent") then
			backroomsInside = v3.Strawberry
		elseif ReplicatedStorage:GetAttribute("MoneyMoneyPuggyEvent") then
			backroomsInside = v3.MoneyMoneyPuggy
		elseif ReplicatedStorage:GetAttribute("JobJobJobSahurEvent") then
			backroomsInside = v3.JobJobJobSahur
		elseif ReplicatedStorage:GetAttribute("EidEvent") then
			backroomsInside = v3.Eid
		elseif ReplicatedStorage:GetAttribute("StPatricksEvent") then
			backroomsInside = v3.StPatricks
		elseif ReplicatedStorage:GetAttribute("EggCityEvent") then
			backroomsInside = v3.EggCity
		elseif ReplicatedStorage:GetAttribute("EasterEvent") then
			backroomsInside = v3.Easter
		elseif ReplicatedStorage:GetAttribute("ExtinctEvent") then
			backroomsInside = v3.Extinct
		elseif ReplicatedStorage:GetAttribute("GraveyardEvent") then
			backroomsInside = v3["Witching Hour"]
		elseif ReplicatedStorage:GetAttribute("WitchingHourEvent") then
			backroomsInside = v3["Witching Hour"]
		end
	end

	for _, v4 in pairs(v3) do
		if not v4 then
			continue
		end

		local defaultVolume = v4:GetAttribute("DefaultVolume")

		if not defaultVolume then
			v4:SetAttribute("DefaultVolume", v4.Volume)
			defaultVolume = v4.Volume
		end

		if v4 == backroomsInside then
			if not v4.IsPlaying then
				v4.Volume = 0
				v4:Play()
				TweenService:Create(v4, tweenInfo, {
					Volume = defaultVolume
				}):Play()
			end
		elseif v4.IsPlaying then
			local tween = TweenService:Create(v4, tweenInfo, {
				Volume = 0
			})
			local v5 = v4
			tween.Completed:Once(function()
				v5:Stop()
			end)
			tween:Play()
		end
	end
end

function SoundController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(...)
		SoundController:PlaySound(...)
	end)
	task.spawn(function()
		while task.wait(4) do
			SoundController:UpdateOST()
			SoundController:UpdateAmbience()
		end
	end)
	ReplicatedStorage:GetAttributeChangedSignal("BeeSwarmEvent"):Connect(function()
		SoundController:UpdateOST()
	end)

	if localPlayer then
		localPlayer:GetAttributeChangedSignal("BackroomsCaveInside"):Connect(function()
			SoundController:UpdateAmbience()
		end)
	end

	Synchronizer:WaitAndCall(localPlayer, function(object)
		object:OnChanged("Settings.Music", function(flag: boolean)
			local workspaceSounds = SoundService:WaitForChild("Cutscene"):WaitForChild("WorkspaceSounds")
			workspaceSounds.Volume = flag and 1 or 0
		end, true)
		object:OnChanged("Settings.Sound Effects", function(flag: boolean)
			local soundEffects = SoundService:WaitForChild("Sound Effects")
			soundEffects.Volume = flag and 1 or 0
		end, true)
		object:OnChanged("Settings.Sound Effects", function(flag: boolean)
			local toolsSounds = SoundService:WaitForChild("ToolsSounds")
			toolsSounds.Volume = flag and 1 or 0
		end, true)
	end)
end

return SoundController