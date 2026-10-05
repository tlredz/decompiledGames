local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local ClientEntity = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc.HeadshotParticles.Attachment
local emotes = ReplicatedStorage.Modules.Emotes
local object = setmetatable({}, ClientEntity)
object.__index = object

function object.new(instance)
	local object2 = setmetatable(ClientEntity.new(instance), object)
	object2.EmoteStatusChanged = Signal.new()
	object2.Humanoid = instance.Humanoid
	object2._headshot_particles = attachment:Clone()
	object2._animation_cleanup = {}
	object2._current_emote = nil
	object2:_Init()
	return object2
end

function object:IsEmoting()
	return self._current_emote ~= nil
end

function object.IsHumanoidStateAirborne(instance, p)
	return CONSTANTS.AIRBORNE_HUMANOID_STATES[p or instance.Humanoid:GetState()]
end

function object:GetCurrentEmote()
	return self._current_emote
end

function object.GetHealth(instance)
	return instance.Humanoid and instance.Humanoid.Health or 0
end

function object.GetMaxHealth(instance)
	return instance.Humanoid and instance.Humanoid.MaxHealth or 100
end

function object:CancelEmote(p)
	local _current_emote = self._current_emote

	if not _current_emote or p and self._current_emote.ObjectID ~= p then
		return
	end

	_current_emote:Destroy()
	self._current_emote = nil
	self.EmoteStatusChanged:Fire()
end

function object:PlayEmote(p)
	self:CancelEmote()

	if not self:IsAlive() then
		return
	end

	local module = require(emotes[p.Name])
	local current_emote = module.new(self.Humanoid)
	current_emote:SetSerial(p)
	self._current_emote = current_emote
	self.EmoteStatusChanged:Fire()
	current_emote:PlayClient()
end

function object:ReplicateFromServer(p, ...)
	if p == "PlayAnimation" then
		if not self:IsRendered() then
			return
		end

		self:_PlayAnimation(...)
	elseif p == "EmotePlayed" then
		if not self:IsRendered() then
			return
		end

		self:PlayEmote(...)
	elseif p == "EmoteStopped" then
		self:CancelEmote(...)
	else
		ClientEntity.ReplicateFromServer(self, p, ...)
	end
end

function object:Destroy()
	for _, v in pairs(self._animation_cleanup) do
		v:Destroy()
	end

	self._animation_cleanup = {}
	self.EmoteStatusChanged:Destroy()
	self:CancelEmote()
	ClientEntity.Destroy(self)
end

function object:_PlayAnimation(p, ...)
	local preloadedAnimationID = PreloadController:GetPreloadedAnimationID(p) or p
	local preloadedAnimation = PreloadController:GetPreloadedAnimation(p) or self:_CreateAnimation(preloadedAnimationID)
	local track = self.Humanoid:LoadAnimation(preloadedAnimation)
	table.insert(self._animation_cleanup, track)
	track:Play(...)
end

function object:_CreateAnimation(animationId)
	assert(typeof(animationId) == "string", "Argument 1 invalid, expected a string")
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	table.insert(self._animation_cleanup, animation)
	return animation
end

function object:_Setup()
	self._headshot_particles.Parent = self.Model and self.Model:FindFirstChild("Head")

	if self.Humanoid then
		self.Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			self.HealthChanged:Fire()
		end)
		self.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			self.HealthChanged:Fire()
		end)
	end
end

function object:_Init()
	self:_Setup()
end

return object