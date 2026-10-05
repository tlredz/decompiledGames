local Sounds = {
	__components = nil,
	__loadOrder = 0,
	__maid = nil,
	__state = nil,
	state = nil,
	soundDebounce = {}
}
Sounds.__index = Sounds
local v = {
	InitiateThrow = {
		Looped = false,
		Sounds = {
			"rbxassetid://91286566615487",
			"rbxassetid://125634559467335",
			"rbxassetid://91209074269481",
			"rbxassetid://116438108393074",
			"rbxassetid://111912333612746",
			"rbxassetid://112205516812769"
		}
	},
	Cast = {
		Looped = false,
		Sounds = {
			"rbxassetid://87614372231264",
			"rbxassetid://97090411771240",
			"rbxassetid://101485239235449",
			"rbxassetid://94578828746250",
			"rbxassetid://116719876411971",
			"rbxassetid://74176975295844"
		}
	},
	PerfectCast = {
		Looped = false,
		Sounds = {
			"rbxassetid://130456819756831",
			"rbxassetid://108192635006380",
			"rbxassetid://138678174438070",
			"rbxassetid://88307988083182",
			"rbxassetid://138708922900267",
			"rbxassetid://92475716800801",
			"rbxassetid://116043841768237"
		}
	},
	LandInWater = {
		Looped = false,
		RollOff = { 15, 100 },
		Adornee = "BobAttach",
		Sounds = { "rbxassetid://80189787905056", "rbxassetid://93975222575740", "rbxassetid://77204418935299" }
	},
	LineInWaterWaitingLoop = {
		Looped = true,
		RollOff = { 15, 100 },
		Adornee = "BobAttach",
		Sounds = { "rbxassetid://84553184497069" }
	},
	FishOnLine = {
		Looped = false,
		Sounds = { "rbxassetid://78532153214128" }
	},
	ActivateSkill = {
		Looped = false,
		Sounds = { "rbxassetid://85558339004089" }
	},
	OpenChest = {
		Looped = false,
		Sounds = { "rbxassetid://99460489607067" }
	},
	FishHoldShimmerLoop = {
		Looped = false,
		StartVolume = 0.5,
		Sounds = { "rbxassetid://104231540217697" }
	},
	CatchFailure = {
		Looped = false,
		Sounds = {
			"rbxassetid://120121293003420",
			"rbxassetid://108732314840184",
			"rbxassetid://129328094775415",
			"rbxassetid://138598113151849",
			"rbxassetid://121570417331499"
		}
	},
	CatchSuccess = {
		Looped = false,
		Sounds = {
			"rbxassetid://111186282656828",
			"rbxassetid://123123900243410",
			"rbxassetid://130081858230504",
			"rbxassetid://98543742295519",
			"rbxassetid://79020974230276"
		}
	},
	ReelInLarge = {
		Looped = false,
		Adornee = "BobAttach",
		Sounds = {
			"rbxassetid://106870180522484",
			"rbxassetid://118648601431867",
			"rbxassetid://136287496772781",
			"rbxassetid://119577468187241",
			"rbxassetid://76825758604389",
			"rbxassetid://92043386941381",
			"rbxassetid://140128337299858"
		}
	},
	ReelInMedium = {
		Looped = false,
		Adornee = "BobAttach",
		Sounds = {
			"rbxassetid://73275237140657",
			"rbxassetid://133283608443440",
			"rbxassetid://107247633686954",
			"rbxassetid://106578159530366",
			"rbxassetid://114728582261387"
		}
	},
	ReelInSmall = {
		Looped = false,
		Adornee = "BobAttach",
		Sounds = {
			"rbxassetid://136553046480954",
			"rbxassetid://118068594629759",
			"rbxassetid://74549286026863",
			"rbxassetid://79199676332918",
			"rbxassetid://110473665426725",
			"rbxassetid://140039791550782"
		}
	},
	ReelingHoveringFishOut = {
		Looped = true,
		RollOff = { 15, 100 },
		StartVolume = 0,
		Volume = 1,
		Sounds = { "rbxassetid://84751855992196" }
	},
	ReelingHoveringFishIn = {
		Looped = true,
		RollOff = { 15, 100 },
		StartVolume = 0,
		Volume = 1,
		Sounds = { "rbxassetid://110686302845624" }
	},
	TreasureChestAppears = {
		Looped = false,
		Sounds = {
			"rbxassetid://139662869203416",
			"rbxassetid://110593355239794",
			"rbxassetid://99133171817504",
			"rbxassetid://119688425965826",
			"rbxassetid://119321184699189",
			"rbxassetid://97741721578289"
		}
	}
}

function Sounds:CanPlay(p2: string)
	return (self.soundDebounce[p2] or 0) < tick()
end

function Sounds:PlayIfNotPlaying(p)
	if not self.CurrentSounds[p] then
		self:PlayRandom(p)
	end
end

function Sounds:GetCurrentPrimaryPart()
	local rod = self.__components:Get("RodController"):GetRod()

	if rod then
		return rod.PrimaryPart
	end

	return nil
end

function Sounds:PlayRandom(name: string)
	if not self:CanPlay(name) then
		return
	end

	self.soundDebounce[name] = tick() + 0.5
	self:StopSound(name)
	local v2 = assert(v[name])
	local sounds = v2.Sounds
	local rod = self.__components:Get("RodController"):GetRod()

	if rod then
		local sound = Instance.new("Sound", rod.PrimaryPart)
		sound.Name = name
		local selected = v2.selected or 1
		v2.selected = selected + 1 > #sounds and 1 or selected + 1
		sound.SoundId = sounds[selected]
		sound.Volume = 1

		if v2.Looped then
			sound.Looped = true
		end

		if v2.RollOff then
			sound.RollOffMinDistance = v2.RollOff[1]
			sound.RollOffMaxDistance = v2.RollOff[2]
		end

		if v2.Adornee then
			sound.Parent = rod:FindFirstChild(v2.Adornee, true)
		end

		if v2.StartVolume then
			sound.Volume = v2.StartVolume
		end

		sound.Destroying:Connect(function()
			if self.CurrentSounds[name] == sound then
				self.CurrentSounds[name] = nil
			end
		end)
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		sound:Play()
		self.CurrentSounds[name] = sound
	end
end

local TweenService = game:GetService("TweenService")

function Sounds.FadeIn(p, p2: string, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local currentSound = p.CurrentSounds[p2]

	if currentSound then
		if p.CurrentTweens[currentSound] and p.CurrentTweens[currentSound].Name ~= "In" then
			p.CurrentTweens[currentSound]:Cancel()
			p.CurrentTweens[currentSound] = nil
		end

		local tween = TweenService:Create(currentSound, tweenInfo, {
			Volume = 1
		})
		tween.Name = "In"
		tween.Completed:Connect(function()
			if p.CurrentTweens[currentSound] == tween then
				p.CurrentTweens[currentSound] = nil
			end
		end)
		p.CurrentTweens[currentSound] = tween
		tween:Play()
	end
end

function Sounds.FadeOut(p, p2: string, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local currentSound = p.CurrentSounds[p2]

	if currentSound then
		if p.CurrentTweens[currentSound] and p.CurrentTweens[currentSound].Name ~= "Out" then
			p.CurrentTweens[currentSound]:Cancel()
			p.CurrentTweens[currentSound] = nil
		end

		local tween = TweenService:Create(currentSound, tweenInfo, {
			Volume = 0
		})
		tween.Name = "Out"
		tween.Completed:Connect(function()
			if p.CurrentTweens[currentSound] == tween then
				p.CurrentTweens[currentSound] = nil
			end
		end)
		p.CurrentTweens[currentSound] = tween
		tween:Play()
	end
end

function Sounds:StopSound(childName: string, duration: number?)
	assert(v[childName])
	local rod = self.__components:Get("RodController"):GetRod()

	if self.CurrentSounds[childName] then
		if duration then
			task.spawn(function()
				local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
				local currentSound = self.CurrentSounds[childName]
				self.CurrentSounds[childName] = nil

				if currentSound then
					local tween = TweenService:Create(currentSound, tweenInfo, {
						Volume = 0
					})
					tween:Play()
					tween.Completed:Wait()
					currentSound:Stop()
					currentSound:Destroy()
				end

				if rod.PrimaryPart and rod.PrimaryPart:FindFirstChild(childName) then
					rod.PrimaryPart:FindFirstChild(childName):Destroy()
				end
			end)
			return
		end

		self.CurrentSounds[childName]:Stop()
		self.CurrentSounds[childName]:Destroy()
		self.CurrentSounds[childName] = nil

		if rod.PrimaryPart and rod.PrimaryPart:FindFirstChild(childName) then
			rod.PrimaryPart:FindFirstChild(childName):Destroy()
		end
	end
end

function Sounds:StopAll(instance)
	if instance and instance.PrimaryPart then
		for _, sound in instance.PrimaryPart:GetChildren() do
			if not sound:IsA("Sound") then
				continue
			end

			sound:Stop()
			sound:Destroy()
		end
	end

	for k, currentSound in self.CurrentSounds do
		currentSound:Stop()
		currentSound:Destroy()
		self.CurrentSounds[k] = nil
	end
end

function Sounds.Construct(p)
	local object = setmetatable(p, Sounds)
	object.soundDebounce = {}
	object.CurrentSounds = {}
	object.CurrentTweens = {}
	local rodController = object.__components:Get("RodController")

	function object.__maid.StopAll()
		pcall(function()
			object:StopAll(rodController:GetRod())
		end)
	end

	if not object.observer then
		object.__maid.ConnectAbilityPower = game.ReplicatedStorage.JobsReplicated.AbilityActivated.Event:Connect(function()
			object:PlayRandom("ActivateSkill")
		end)
	end

	return object
end

function Sounds.Setup() end

return Sounds