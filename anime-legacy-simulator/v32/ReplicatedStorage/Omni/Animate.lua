local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Characters = require(script.Parent.Utils.Characters)
local isServer = RunService:IsServer()
local v = {}
local v2 = {
	_LoadAnimation = function(self, flag: boolean, state, flag2: boolean?)
		if typeof(state) ~= "table" or (not state.Animation or typeof(state.Animation) ~= "Instance" or not state.Animation:IsA("Animation")) then
			return
		end

		if typeof(state.Priority) ~= "EnumItem" then
			state.Priority = Enum.AnimationPriority.Movement
		end

		if flag then
			local packAnimation = self.PackAnimations[state.Animation.Name]

			if packAnimation then
				return packAnimation
			end
		else
			for _, loadedAnimation in self.LoadedAnimations do
				if loadedAnimation.Object == state.Animation then
					return loadedAnimation.Track
				end
			end
		end

		local track = self.Animator:LoadAnimation(state.Animation)
		track.Priority = state.Priority
		track.Looped = state.Looped == true

		if flag2 then
			return track
		end

		local v3 = {
			Object = state.Animation,
			Track = track
		}

		if flag then
			self.PackAnimations[state.Animation.Name] = track
			return track
		end

		table.insert(self.LoadedAnimations, v3)
		return track
	end,
	_CheckBaseState = function(self)
		if not self.CurrentState or self.CurrentState == "Idle" or self.CurrentState == "Walk" then
			if self.IsPlayer then
				if self.Humanoid.MoveDirection.Magnitude > 0 then
					self.CurrentState = "Walk"
				else
					self.CurrentState = "Idle"
				end
			elseif self.HRP.AssemblyLinearVelocity.Magnitude > 1 then
				self.CurrentState = "Walk"
			else
				self.CurrentState = "Idle"
			end
		end
	end,
	StartFall = function(self)
		if self.FallThread then
			return
		end

		self.FallThread = task.spawn(function()
			if self.PlayingAnimation and self.PlayingAnimation.State == "Jump" then
				while self.PlayingAnimation and not (os.clock() >= self.PlayingAnimation.EndTime) do
					task.wait()
				end
			end

			self:AddForcedState("Fall", "Fall")
		end)
	end,
	EndFall = function(self)
		self.CurrentState = nil
		self:_CheckBaseState()

		if self.FallThread then
			task.cancel(self.FallThread)
			self.FallThread = nil
		end

		self:RemoveForcedState("Fall")

		if self:HasPersistentState() then
			return
		end

		self:PlayPackAnimation("Land")
	end,
	Refresh = function(self, flag: boolean?)
		local now = os.clock()
		local currentState = self:GetCurrentState()
		local v3 = flag == true
		local v4 = not v3 and (not self.PlayingAnimation or self.PlayingAnimation.State ~= currentState) or v3

		if v4 and self.PlayingAnimation and self.PlayingAnimation.State == currentState then
			local stateTrack = self:GetStateTrack(currentState)

			if stateTrack == self.PlayingAnimation.Track and stateTrack.IsPlaying then
				v4 = false
			end
		end

		if v4 then
			self:StopPackAnimations()
			self.PlayingAnimation = nil
			local stateTrack = self:GetStateTrack(currentState)

			if stateTrack then
				self.PlayingAnimation = {
					State = currentState,
					Track = stateTrack,
					EndTime = now + stateTrack.Length
				}
				stateTrack:Play()
			end
		end
	end,
	GetCurrentState = function(self)
		local currentState = self.CurrentState
		local priority = nil
		local v3 = nil

		for _, forcedState in self.ForcedStates do
			if not (not priority or priority < forcedState.Priority) then
				continue
			end

			currentState = forcedState.State
			priority = forcedState.Priority
		end

		for _, customStateName in self.CustomStateNames do
			if customStateName.State == currentState and (not v3 or customStateName.Priority > v3.Priority) then
				v3 = {
					Priority = customStateName.Priority,
					Name = customStateName.Name
				}
			end
		end

		if v3 then
			currentState = v3.Name
		end

		return currentState
	end,
	GetStateTrack = function(self, p2: string)
		local track = self.PackAnimations[p2]
		local priority = 0

		for _, customStateTrack in self.CustomStateTracks do
			if not (customStateTrack.State == p2 and priority < customStateTrack.Priority) then
				continue
			end

			track = customStateTrack.Track
			priority = customStateTrack.Priority
		end

		return track
	end,
	LoadAnimation = function(self, p)
		return self:_LoadAnimation(false, p)
	end,
	PlayAnimation = function(self, p)
		if typeof(p) ~= "table" then
			return
		end

		local oneShotAnimation = self.OneShotAnimations[p.Animation]

		if oneShotAnimation then
			oneShotAnimation:Play()
			oneShotAnimation.TimePosition = 0
			return oneShotAnimation
		else
			local _LoadAnimation = self:_LoadAnimation(false, p, true)

			if not _LoadAnimation then
				return
			end

			self.OneShotAnimations[p.Animation] = _LoadAnimation
			_LoadAnimation:Play()
			return _LoadAnimation
		end
	end,
	PlayPackAnimation = function(self, p: string)
		local stateTrack = self:GetStateTrack(p)

		if not stateTrack then
			return
		end

		stateTrack:Play()
		return stateTrack
	end,
	ResetPlayingAnimation = function(self)
		if not self.PlayingAnimation then
			return
		end

		self.PlayingAnimation.Track:Stop()
		self.PlayingAnimation = nil
	end,
	StopPackAnimations = function(self)
		for _, customStateTrack in self.CustomStateTracks do
			customStateTrack.Track:Stop()
		end

		for _, packAnimation in self.PackAnimations do
			packAnimation:Stop()
		end
	end,
	ClearAnimations = function(self)
		for _, packAnimation in self.PackAnimations do
			packAnimation:Stop()
			packAnimation:Destroy()
		end

		for _, loadedAnimation in self.LoadedAnimations do
			loadedAnimation.Track:Stop()
			loadedAnimation.Track:Destroy()
		end

		for _, oneShotAnimation in self.OneShotAnimations do
			oneShotAnimation:Stop()
			oneShotAnimation:Destroy()
		end

		self.PlayingAnimation = nil
		self.CurrentAnimationPack = nil
		table.clear(self.PackAnimations)
		table.clear(self.LoadedAnimations)
		table.clear(self.OneShotAnimations)
		table.clear(self.CustomStateTracks)
	end,
	LoadAnimationPack = function(self, currentAnimationPack: string)
		if not (typeof(currentAnimationPack) == "string" and currentAnimationPack ~= self.CurrentAnimationPack) then
			return
		end

		local allCharacterAnimations = Characters.GetAllCharacterAnimations(currentAnimationPack)

		if not allCharacterAnimations then
			return
		end

		self:ClearAnimations()
		self.CurrentAnimationPack = currentAnimationPack

		for _, allCharacterAnimation in allCharacterAnimations do
			local priority = allCharacterAnimation:GetAttribute("Priority")
			self:_LoadAnimation(true, {
				Animation = allCharacterAnimation,
				Looped = allCharacterAnimation:GetAttribute("Looped") == true,
				Priority = priority and Enum.AnimationPriority[priority]
			})
		end
	end,
	AddCustomStateName = function(self, identifier: string, value2: string, value3: string, value4: number?)
		if not (typeof(identifier) == "string" and typeof(value2) == "string" and typeof(value3) == "string") then
			return
		end

		local priority = typeof(value4) ~= "number" and 1 or value4
		self:RemoveCustomStateName(identifier, value2)
		table.insert(self.CustomStateNames, {
			Identifier = identifier,
			State = value2,
			Name = value3,
			Priority = priority
		})
	end,
	RemoveCustomStateName = function(self, value: string, value2: string)
		if not (typeof(value) == "string" and typeof(value2) == "string") then
			return
		end

		local v3 = nil

		for k, customStateName in self.CustomStateNames do
			if not (customStateName.Identifier == value and customStateName.State == value2) then
				continue
			end

			v3 = k
			break
		end

		if v3 then
			table.remove(self.CustomStateNames, v3)
		end
	end,
	AddForcedState = function(self, value: string, value2: string, value3: number?, flag: boolean?)
		if not (typeof(value) == "string" and typeof(value2) == "string") then
			return
		end

		local priority = typeof(value3) ~= "number" and 1 or value3
		self.ForcedStates[value] = {
			State = value2,
			Priority = priority,
			Persistent = flag == true
		}
		self:Refresh(true)
	end,
	HasPersistentState = function(self)
		for _, forcedState in self.ForcedStates do
			if forcedState.Persistent then
				return true
			end
		end

		return false
	end,
	RemoveForcedState = function(self, value: string)
		if typeof(value) ~= "string" then
			return
		end

		self.ForcedStates[value] = nil
		self:Refresh(true)
	end,
	AddCustomAnimationForState = function(self, value: string, value2: string, animation, value3: number?)
		if not (typeof(value) == "string" and typeof(value2) == "string") then
			return
		end

		local priority = typeof(value3) ~= "number" and 1 or value3
		local track = self:LoadAnimation(animation)

		if not track then
			return
		end

		self.CustomStateTracks[value .. value2] = {
			State = value2,
			Track = track,
			Priority = priority
		}
		self:Refresh(true)
	end,
	RemoveCustomAnimationForState = function(self, value: string, value2: string)
		if not (typeof(value) == "string" and typeof(value2) == "string") then
			return
		end

		local customStateTrack = self.CustomStateTracks[value .. value2]

		if not customStateTrack then
			return
		end

		customStateTrack.Track:Stop()
		self.CustomStateTracks[value .. value2] = nil
		self:Refresh(true)
	end,
	Destroy = function(self)
		self:ClearAnimations()
		v[self.Character] = nil
	end
}
RunService.PreRender:Connect(function()
	for _, v3 in v do
		v3:_CheckBaseState()
		v3:Refresh()
	end
end)
local Animate = {}

function Animate.New(model)
	if isServer or not (model and model:IsA("Model")) then
		return
	end

	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local object = setmetatable({}, {
		__index = v2
	})
	object.Character = model
	object.HRP = humanoidRootPart
	object.Humanoid = humanoid
	object.Animator = animator
	object.IsPlayer = Players:GetPlayerFromCharacter(model) ~= nil
	object.Connections = {}
	object.ForcedStates = {}
	object.CustomStateNames = {}
	object.CustomStateTracks = {}
	object.PackAnimations = {}
	object.LoadedAnimations = {}
	object.OneShotAnimations = {}
	object.Connections.States = humanoid.StateChanged:Connect(function(_, p)
		if p == Enum.HumanoidStateType.Freefall then
			object:StartFall()
		elseif p == Enum.HumanoidStateType.Landed then
			object:EndFall()
		elseif p == Enum.HumanoidStateType.Jumping then
			object.CurrentState = "Jump"
		end
	end)
	object.Connections.Destroy = model.AncestryChanged:Connect(function(_, parent)
		if not (model and parent) then
			object:Destroy()
		end
	end)
	v[model] = object
	return object
end

function Animate.Get(model)
	if isServer then
		return
	end

	if model and model:IsA("Model") then
		return v[model]
	end
end

return Animate