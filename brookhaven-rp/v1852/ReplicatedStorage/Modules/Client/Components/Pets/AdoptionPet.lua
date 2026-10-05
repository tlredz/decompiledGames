local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PetConstants = require(ReplicatedStorage.Modules.Shared.Pets.PetConstants)
local PetUtil = require(ReplicatedStorage.Modules.Shared.Pets.PetUtil)
local PetsConfig = require(ReplicatedStorage.Modules.Shared.DB.Pets.PetsConfig)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local v = Component.new({
	Tag = PetConstants.ADOPTION_PET_TAG
})
local v2 = { "IdleAnim", "SitAnim", "LayAnim" }

function v:Construct()
	self._Janitor = Janitor.new()
	self._ready = false
	self._idleTracks = {}
	self._currentTrack = nil
	self._nextSwitch = 0
	self._barkTrack = nil
	self._nextBark = 0
end

function v:_ResolveEntry()
	return PetsConfig.GetConfig()[self.Instance.Name]
end

function v:_SetupClickInteraction(p)
	local instance = self.Instance
	local parent = PetUtil.GetPetHitboxPart(instance) or PetUtil.GetPetRootPart(instance)

	if parent == nil then
		warn((`AdoptionPet: no clickable part found for "{instance.Name}"`))
		return
	end

	local v4 = parent:FindFirstChildWhichIsA("ClickDetector")

	if v4 == nil then
		v4 = Instance.new("ClickDetector")
		v4.Name = "AdoptionPetClickDetector"
		v4.MaxActivationDistance = PetConstants.CLICK_ACTIVATION_DISTANCE
		v4.Parent = parent
		self._Janitor:Add(v4)
	end

	self._Janitor:Add(v4.MouseClick:Connect(function()
		self:_OnClicked(p)
	end))
end

function v:_OnClicked(p)
	local name = self.Instance.Name
	local requiredGamepass = PetsConfig.GetRequiredGamepass(p)

	if requiredGamepass ~= nil and not UnlockableController.IsFeatureUnlocked(name, requiredGamepass) then
		GamepassController.Show(
			requiredGamepass,
			p.Icon,
			"pet",
			nil,
			AdFeatures.Pets()[name],
			nil,
			"Adoption Centre",
			name,
			function()
				if self.Instance.Parent == nil then
					return
				end

				self:_OnClicked(p)
			end
		)
		return
	end

	local attribute = self.Instance:GetAttribute(PetConstants.ATTR_PET_NAME)
	local fireServer = Remotes.fireServer

	if typeof(attribute) ~= "string" then
		attribute = nil
	end

	fireServer("Pet_Equip", name, attribute)
end

function v:_LoadTracks()
	local instance = self.Instance
	local animator = PetUtil.GetAnimator(instance)
	local animationsFolder = PetUtil.GetAnimationsFolder(instance)

	if animator == nil or animationsFolder == nil then
		warn((`AdoptionPet: no animator/Animations for "{instance.Name}"`))
		return
	end

	local function load(childName: string, looped: boolean, priority)
		local animation = animationsFolder:FindFirstChild(childName)

		if animation == nil or not animation:IsA("Animation") then
			return nil
		end

		local track = animator:LoadAnimation(animation)
		track.Looped = looped
		track.Priority = priority
		self._Janitor:Add(track, "Stop")
		return track
	end

	for _, v3 in v2 do
		if self._idleTracks[v3] == nil then
			self._idleTracks[v3] = load(v3, true, Enum.AnimationPriority.Movement)
		end
	end

	if self._barkTrack == nil then
		self._barkTrack = load(PetConstants.BARK_ANIM_NAME, false, Enum.AnimationPriority.Action)
	end
end

function v:_PlayTrack(currentTrack)
	if currentTrack == self._currentTrack then
		return
	end

	if self._currentTrack ~= nil then
		self._currentTrack:Stop(1)
	end

	self._currentTrack = currentTrack

	if currentTrack ~= nil and not currentTrack.IsPlaying then
		currentTrack:Play(1)
	end
end

function v:_PlayRandomIdle()
	local _idleTracks = {}

	for _, v3 in v2 do
		local _idleTrack = self._idleTracks[v3]

		if _idleTrack ~= nil and _idleTrack ~= self._currentTrack then
			table.insert(_idleTracks, _idleTrack)
		end
	end

	if #_idleTracks == 0 then
		for _, _idleTrack in self._idleTracks do
			table.insert(_idleTracks, _idleTrack)
		end
	end

	if #_idleTracks > 0 then
		self:_PlayTrack(_idleTracks[math.random(1, #_idleTracks)])
	end

	self._nextSwitch = os.clock() + 5 + math.random() * 10
end

function v:_ScheduleNextBark()
	self._nextBark = os.clock() + PetConstants.BARK_MIN_INTERVAL + math.random() * (PetConstants.BARK_MAX_INTERVAL - PetConstants.BARK_MIN_INTERVAL)
end

function v:_PlayBark()
	self:_ScheduleNextBark()
	local _barkTrack = self._barkTrack

	if _barkTrack == nil or _barkTrack.IsPlaying then
		return
	end

	_barkTrack:Play(PetConstants.ANIM_BLEND_TIME)
	PetUtil.PlayPetSound(self.Instance, PetConstants.BARK_SOUND_NAME)
end

function v:HeartbeatUpdate()
	if not self._ready then
		return
	end

	if os.clock() >= self._nextSwitch then
		self:_PlayRandomIdle()
	end

	if os.clock() >= self._nextBark then
		self:_PlayBark()
	end
end

function v:Start()
	local instance = self.Instance
	local _ResolveEntry = self:_ResolveEntry()

	if _ResolveEntry == nil then
		warn((`AdoptionPet: no PetsConfig entry for "{instance.Name}"`))
		return
	end

	local petRootPart = PetUtil.GetPetRootPart(instance)

	if petRootPart ~= nil then
		petRootPart.Anchored = true
	end

	self:_SetupClickInteraction(_ResolveEntry)
	self:_LoadTracks()

	if next(self._idleTracks) ~= nil then
		self:_PlayRandomIdle()
	end

	self:_ScheduleNextBark()
	self._ready = next(self._idleTracks) ~= nil or self._barkTrack ~= nil
end

function v:Stop()
	self._Janitor:Destroy()
end

return v