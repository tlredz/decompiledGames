local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ExclusionProjectile = require(ReplicatedStorage.Modules.Client.Components.Tools.Projectiles.ExclusionProjectile)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local PhysicsUtil = require(ReplicatedStorage.Modules.Shared.Utils.PhysicsUtil)
local VisualEffectsUtil = require(ReplicatedStorage.Modules.Shared.Utils.VisualEffectsUtil)
local TearGasLauncherConstants = require(ReplicatedStorage.Modules.Shared.Tools.TearGasLauncherConstants)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "TearGasLauncher",
	Extensions = { OnlyRunOnPlayerHotbar }
})
local v2 = {}
local v3 = 0
local v4 = false
local heartbeatConnection = nil
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://" .. TearGasLauncherConstants.SWAT_ANIMATION_ID
local track = nil
local v5 = nil

local function isLocalCharacterInAnyCloud()
	local character = localPlayer.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local now = os.clock()

	for _, v6 in v2 do
		if now < v6.expiresAt and (humanoidRootPart.Position - v6.position).Magnitude <= TearGasLauncherConstants.GAS_RADIUS then
			return true
		end
	end

	return false
end

local function playLocalSwatReaction()
	if TearGasLauncherConstants.SWAT_ANIMATION_ID == "" then
		return
	end

	local character = localPlayer.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if track == nil or v5 ~= humanoid then
		if track ~= nil then
			track:Destroy()
		end

		track = humanoid:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = false
		v5 = humanoid
	end

	track:Stop(0)
	track:Play()
	task.delay(TearGasLauncherConstants.REACTION_DURATION, function()
		if track ~= nil then
			track:Stop(0.15)
		end

		v4 = false
		v3 = os.clock() + TearGasLauncherConstants.REACTION_IMMUNITY
	end)
end

local function stepCloudWatcher()
	local now = os.clock()

	for i = #v2, 1, -1 do
		if v2[i].expiresAt <= now then
			table.remove(v2, i)
		end
	end

	if #v2 == 0 then
		if heartbeatConnection ~= nil then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	else
		if v4 or now < v3 or not isLocalCharacterInAnyCloud() then
			return
		end

		v4 = true
		playLocalSwatReaction()
	end
end

local function registerGasCloud(position: Vector3)
	table.insert(v2, {
		position = position,
		expiresAt = os.clock() + TearGasLauncherConstants.GAS_DURATION
	})

	if heartbeatConnection == nil then
		heartbeatConnection = RunService.Heartbeat:Connect(stepCloudWatcher)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._isFiring = false
	self._isReloading = false
	self._clientAmmo = TearGasLauncherConstants.DRUM_CAPACITY
	self._idleTrack = nil
	self._shootTrack = nil
	self._reloadTrack = nil
	self._raycastParams = RaycastParams.new()
	self._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self._raycastParams.RespectCanCollide = true
	self._raycastParams.CollisionGroup = "Default"
end

function v:_GetHandle()
	return (self.Instance:FindFirstChild("Handle"))
end

function v:_GetSpawnPosition()
	local _GetHandle = self:_GetHandle()
	local barrel = _GetHandle:FindFirstChild("Barrel")

	if barrel == nil then
		return _GetHandle.Position
	end

	return barrel.WorldPosition
end

function v:_PlaySound(instance, childName: string)
	instance:FindFirstChild(childName):Play()
end

function v:_SetMunitionVisible(flag: boolean)
	local munition = self.Instance:FindFirstChild("Munition", true)

	if munition == nil then
		return
	end

	munition.Transparency = flag and 0 or 1
end

function v:_ConnectMunitionMarkers(object2, maid)
	maid:Add(object2:GetMarkerReachedSignal("MunHide"):Connect(function()
		self:_SetMunitionVisible(false)
	end))
	maid:Add(object2:GetMarkerReachedSignal("MunAppear"):Connect(function()
		self:_SetMunitionVisible(true)
	end))
	maid:Add(object2.Stopped:Connect(function()
		self:_SetMunitionVisible(true)
	end))
end

function v:_EmitMuzzleFlash()
	local muzzleFlash = self:_GetHandle():FindFirstChild("MuzzleFlash")
	VisualEffectsUtil.ForParticles(muzzleFlash, function(emitter)
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 3)
		end
	end)
end

function v:_LoadTracks(animator)
	if self._idleTrack ~= nil then
		self._idleTrack:Stop(0)
		self._idleTrack:Destroy()
		self._idleTrack = nil
	end

	if self._shootTrack ~= nil then
		self._shootTrack:Stop(0)
		self._shootTrack:Destroy()
		self._shootTrack = nil
	end

	if self._reloadTrack ~= nil then
		self._reloadTrack:Stop(0)
		self._reloadTrack:Destroy()
		self._reloadTrack = nil
	end

	self._idleTrack = animator:LoadAnimation((self.Instance:FindFirstChild("IdleAnim")))
	self._idleTrack.Priority = Enum.AnimationPriority.Idle
	self._idleTrack.Looped = true
	self._Janitor:Add(self._idleTrack)
	self._idleTrack:Play()
	self._shootTrack = animator:LoadAnimation((self.Instance:FindFirstChild("ShootAnim")))
	self._Janitor:Add(self._shootTrack)
	self._reloadTrack = animator:LoadAnimation((self.Instance:FindFirstChild("ReloadAnim")))
	self._Janitor:Add(self._reloadTrack)
	self:_ConnectMunitionMarkers(self._reloadTrack, self._equipJanitor)
end

function v:_SyncAmmoFromAttribute()
	local attribute = self.Instance:GetAttribute(TearGasLauncherConstants.AMMO_ATTRIBUTE)

	if typeof(attribute) == "number" then
		self._clientAmmo = attribute
	end
end

function v:_GetAimTarget(p)
	local mouse = localPlayer:GetMouse()
	local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, p)

	if raycastResult == nil then
		return mouse.UnitRay.Origin + mouse.UnitRay.Direction * 1000
	end

	return raycastResult.Position
end

function v:_SimulateProjectile(vector: Vector3, vector2: Vector3, p: number, flag: boolean, player)
	local clone = self.Instance:FindFirstChild("Projectile"):Clone()
	local weldConstraint = clone:FindFirstChildOfClass("WeldConstraint")

	if weldConstraint ~= nil then
		weldConstraint:Destroy()
	end

	clone.Transparency = 0
	clone.Anchored = false
	clone.CanCollide = false
	clone.Parent = workspace
	ExclusionProjectile.track(clone, self.Instance.Name)
	VisualEffectsUtil.ForParticles(clone, function(p2)
		p2.Enabled = true
	end)
	local characters = { self.Instance }

	if player == nil or player.Character == nil then
		if localPlayer.Character ~= nil then
			table.insert(characters, localPlayer.Character)
		end
	else
		table.insert(characters, player.Character)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.RespectCanCollide = true
	raycastParams.CollisionGroup = "Default"
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if clone.Parent == nil or clone.Anchored then
			if heartbeatConnection2 ~= nil then
				heartbeatConnection2:Disconnect()
			end
		else
			local assemblyLinearVelocity = clone.AssemblyLinearVelocity

			if assemblyLinearVelocity.Magnitude < 0.05 then
				return
			end

			clone.CFrame = CFrame.lookAt(clone.Position, clone.Position - assemblyLinearVelocity.Unit)
		end
	end)
	PhysicsUtil.NewSimulation(
		clone,
		vector,
		vector2,
		TearGasLauncherConstants.PROJECTILE_SPEED,
		p,
		raycastParams,
		function(raycastResult: RaycastResult?, _: Vector3)
			if heartbeatConnection2 ~= nil then
				heartbeatConnection2:Disconnect()
				heartbeatConnection2 = nil
			end

			VisualEffectsUtil.ForParticles(clone, function(emitter)
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end)
			self:_PlaySound(clone, "Impact")

			if raycastResult ~= nil then
				clone.CFrame = CFrame.new(raycastResult.Position)
			end

			clone.Anchored = true

			if flag then
				local v6

				if raycastResult == nil then
					v6 = clone.Position
				else
					v6 = raycastResult.Position
				end

				Remotes.fireServerComponent(self.Instance, "Impact", v6)
			end
		end
	)
end

function v:_SpawnGasCloud(position: Vector3)
	local clone = self.Instance:FindFirstChild("GasCloud"):Clone()
	local weldConstraint = clone:FindFirstChild("WeldConstraint")

	if weldConstraint ~= nil then
		weldConstraint:Destroy()
	end

	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Transparency = 1
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	VisualEffectsUtil.ForParticles(clone, function(emitter)
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end)
	local gasHiss = clone:FindFirstChild("GasHiss")

	if gasHiss ~= nil then
		gasHiss.Looped = true
		gasHiss:Play()
	end

	registerGasCloud(position)
	task.delay(TearGasLauncherConstants.GAS_DURATION, function()
		VisualEffectsUtil.ForParticles(clone, function(emitter)
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end)

		if gasHiss ~= nil then
			gasHiss:Stop()
		end
	end)
	Debris:AddItem(clone, TearGasLauncherConstants.GAS_DURATION + 1)
end

function v:_Fire()
	if self._isFiring or self._isReloading then
		return
	end

	self:_SyncAmmoFromAttribute()

	if self._clientAmmo <= 0 then
		self:_BeginReload()
		return
	end

	self._isFiring = true
	self._clientAmmo -= 1
	self:_PlaySound(self:_GetHandle(), "Shoot")
	self:_EmitMuzzleFlash()

	if self._shootTrack ~= nil then
		self._shootTrack:Stop(0)
		self._shootTrack:Play()
	end

	self._raycastParams.FilterDescendantsInstances = { self.Instance, localPlayer.Character }
	local _GetSpawnPosition = self:_GetSpawnPosition()
	local _GetAimTarget = self:_GetAimTarget(self._raycastParams)
	local serverTimeNow = workspace:GetServerTimeNow()
	Remotes.fireServerComponent(self.Instance, "Fire", _GetSpawnPosition, _GetAimTarget, serverTimeNow)
	self:_SimulateProjectile(_GetSpawnPosition, _GetAimTarget, serverTimeNow, true, localPlayer)
	task.delay(0.1, function()
		self:_SyncAmmoFromAttribute()
	end)
	task.delay(TearGasLauncherConstants.FIRE_COOLDOWN, function()
		self._isFiring = false
	end)

	if self._clientAmmo <= 0 then
		task.defer(function()
			self:_BeginReload()
		end)
	end
end

function v:_BeginReload()
	if self._isReloading then
		return
	end

	self:_SyncAmmoFromAttribute()

	if self._clientAmmo >= TearGasLauncherConstants.DRUM_CAPACITY then
		return
	end

	self._isReloading = true
	self:_PlaySound(self:_GetHandle(), "Reload")

	if self._reloadTrack ~= nil then
		self._reloadTrack:Stop(0)
		self._reloadTrack:Play()
	end

	Remotes.fireServerComponent(self.Instance, "Reload")
	task.delay(TearGasLauncherConstants.RELOAD_DURATION, function()
		self._isReloading = false
		self:_SyncAmmoFromAttribute()

		if self._clientAmmo < TearGasLauncherConstants.DRUM_CAPACITY then
			self._clientAmmo = TearGasLauncherConstants.DRUM_CAPACITY
		end
	end)
end

function v:_PlayObserverReload()
	self:_PlaySound(self:_GetHandle(), "Reload")
	local track2 = self.Instance.Parent:FindFirstChildOfClass("Humanoid"):LoadAnimation((self.Instance:FindFirstChild("ReloadAnim")))
	local v6 = Janitor.new()
	self:_ConnectMunitionMarkers(track2, v6)
	track2:Play()
	task.delay(TearGasLauncherConstants.RELOAD_DURATION, function()
		track2:Stop()
		track2:Destroy()
		v6:Destroy()
		self:_SetMunitionVisible(true)
	end)
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal(TearGasLauncherConstants.AMMO_ATTRIBUTE):Connect(function()
		self:_SyncAmmoFromAttribute()
	end))
	self._Janitor:Add(instance.Equipped:Connect(function()
		local parent = self.Instance.Parent

		if Players:GetPlayerFromCharacter(parent) ~= localPlayer then
			return
		end

		self:_LoadTracks((parent:FindFirstChildOfClass("Humanoid")))
		self:_SyncAmmoFromAttribute()
		self._equipJanitor:Add(instance.Activated:Connect(function()
			self:_Fire()
		end))
		self._equipJanitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or input.KeyCode ~= Enum.KeyCode.R then
				return
			end

			self:_BeginReload()
		end))
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		if self._idleTrack ~= nil then
			self._idleTrack:Stop(0)
		end

		if self._reloadTrack ~= nil then
			self._reloadTrack:Stop(0)
		end

		if self._shootTrack ~= nil then
			self._shootTrack:Stop(0)
		end

		self._isReloading = false
		self._equipJanitor:Cleanup()
		self:_SetMunitionVisible(true)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"Fired",
		function(p, vector: Vector3, vector2: Vector3, p2: number)
			self:_PlaySound(self:_GetHandle(), "Shoot")
			self:_EmitMuzzleFlash()
			self:_SimulateProjectile(vector, vector2, p2, false, p)
		end
	))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "SpawnGasCloud", function(vector: Vector3)
		self:_SpawnGasCloud(vector)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "Reloaded", function()
		local parent = self.Instance.Parent

		if parent == nil or not parent:IsA("Model") or Players:GetPlayerFromCharacter(parent) == localPlayer then
			return
		end

		self:_PlayObserverReload()
	end))
end

function v:Stop()
	self._equipJanitor:Destroy()
	self._Janitor:Destroy()
end

return v