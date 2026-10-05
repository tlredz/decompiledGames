local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v = nil
pcall(function()
	local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
	v = SoundGroupManager
end)
local EclipseHowl = {}
EclipseHowl.__index = EclipseHowl

function EclipseHowl.new(character, options)
	local object = setmetatable({}, EclipseHowl)
	object.character = character
	object.config = options or {}
	object.howlSound = object.config.HowlSound or "Sounds.Effects.EclipseHowl"
	object.howlAnimation = object.config.HowlAnimation or "rbxassetid://77203626514357"
	object.howlDuration = object.config.HowlDuration or 2.5
	object.humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	object.humanoid = character:FindFirstChild("Humanoid")
	object:setupHowlAnimation()
	return object
end

function EclipseHowl:setupHowlAnimation()
	if not self.humanoid then
		return
	end

	local v2 = self.humanoid:FindFirstChildOfClass("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = self.humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = self.howlAnimation
	self.howlTrack = v2:LoadAnimation(animation)
	self.howlTrack.Priority = Enum.AnimationPriority.Action
end

function EclipseHowl:alertMonsters(p)
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local machineEvent = events:FindFirstChild("MachineEvent")

	if not machineEvent then
		return
	end

	machineEvent:Fire(p, nil)
end

function EclipseHowl:performHowl(p)
	if self.howlTrack then
		self.howlTrack:Play()
	end

	if self.humanoidRootPart then
		local v2 = Audio:Play(self.howlSound, {
			Name = "EclipseHowl",
			Volume = 0.7,
			PlaybackSpeed = 1,
			Parent = self.humanoidRootPart
		})

		if v2 and v then
			v.AssignSound(v2, "MonsterState")
		end
	end

	if self.character then
		self.character:SetAttribute("_Howling", true)
	end

	self:alertMonsters(p)
	task.delay(self.howlDuration, function()
		if self.character and self.character.Parent then
			self.character:SetAttribute("_Howling", false)
		end
	end)
end

function EclipseHowl.cleanup(p)
	if p.sound then
		p.sound:Destroy()
	end

	if p.character then
		p.character:SetAttribute("_Howling", false)
	end
end

return EclipseHowl