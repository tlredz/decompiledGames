local Players = game:GetService("Players")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2")

if userFlag then
	local class = {}
	class.__index = class
	local v = {}
	Players.PlayerRemoving:Connect(function(player)
		wait(1)
		local v2 = v[player.UserId]

		if v2 then
			v2:destroy()
			v[player.UserId] = nil
		end
	end)

	function class._new(player)
		local object = setmetatable({}, class)
		object._player = player
		object._data = {}
		object._abilityManagerActor = nil
		object._inputMap = {}
		object._character = nil
		object._humanoid = nil
		object._enabledChangedEvent = Instance.new("BindableEvent")
		object._abilitiesChangedEvent = Instance.new("BindableEvent")
		object._evaluateStateMachineChangedConnection = nil
		object._abilityChangedEvents = {}
		object._abilityChangedConnections = {}

		if userFlag2 then
			task.spawn(function()
				object._characterAddedConnection = player.CharacterAdded:Connect(function(character)
					object:_onCharacterAdded(character)
				end)
			end)
		else
			object._characterAddedConnection = player.CharacterAdded:Connect(function(character)
				object:_onCharacterAdded(character)
			end)
		end

		if player.Character then
			object:_onCharacterAdded(player.Character)
		end

		return object
	end

	local v2 = nil

	function class._avatarAbilities()
		if v2 then
			return v2
		end

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local packages = ReplicatedStorage:FindFirstChild("Packages")
		local avatarAbilities

		if packages then
			avatarAbilities = packages:FindFirstChild("AvatarAbilities")
		end

		local v3

		if avatarAbilities then
			v3 = require(avatarAbilities)
		end

		v2 = v3

		if not v2 then
			local module = require("@rbx/AvatarAbilities")
			v2 = module
		end

		return v2
	end

	function class.get(p)
		if not p or p.UserId == 0 then
			return nil
		end

		local v3 = v[p.UserId]

		if not v3 then
			v3 = class._new(p)
			v[p.UserId] = v3
		end

		return v3
	end

	function class:_hookUpAbilityChangedEvent(p, p2)
		local v3 = self._inputMap[p]

		if #v3 < 1 then
			return
		end

		local v4 = v3[1]

		if not v4 then
			return
		end

		local syncedState = v4:FindFirstChild("SyncedState")

		if not syncedState then
			return
		end

		if not self._abilityChangedConnections[p2] then
			self._abilityChangedConnections[p2] = {}
		end

		if self._abilityChangedConnections[p2][p] then
			self._abilityChangedConnections[p2][p]:Disconnect()
			self._abilityChangedConnections[p2][p] = nil
		end

		self._abilityChangedConnections[p2][p] = syncedState:GetAttributeChangedSignal(p2):Connect(function()
			self._abilityChangedEvents[p2][p]:Fire()
		end)
	end

	function class:_onCharacterAdded(character)
		self._abilityManagerActor = nil
		self._humanoid = nil
		self._character = character

		if self._evaluateStateMachineChangedConnection then
			self._evaluateStateMachineChangedConnection:Disconnect()
			self._evaluateStateMachineChangedConnection = nil
		end

		if self._character then
			task.spawn(function()
				self._abilityManagerActor = self._character:WaitForChild("AbilityManagerActor", 5)

				if self._abilityManagerActor then
					self._data = {}
					self._humanoid = self._character:FindFirstChildOfClass("Humanoid")

					while not self._humanoid do
						self._character.ChildAdded:Wait()
						self._humanoid = self._character:FindFirstChildOfClass("Humanoid")
					end

					if self._evaluateStateMachineChangedConnection then
						self._evaluateStateMachineChangedConnection:Disconnect()
						self._evaluateStateMachineChangedConnection = nil
					end

					local function enabledChanged()
						if self:isEnabled() then
							local v3 = self
							local v4 = self
							local maintainedInputMap, inputMapCleanup, v6 = self._avatarAbilities().createMaintainedInputMap(self._character)
							v3._inputMap = maintainedInputMap
							v4._inputMapCleanup = inputMapCleanup

							if self._inputMapChangedConnection then
								self._inputMapChangedConnection:Disconnect()
								self._inputMapChangedConnection = nil
							end

							self._inputMapChangedConnection = v6:Connect(function(_)
								self._abilitiesChangedEvent:Fire()
							end)
							self._abilitiesChangedEvent:Fire()

							for k, _abilityChangedEvent in self._abilityChangedEvents do
								for k2, v7 in _abilityChangedEvent do
									v7:Fire()
									self:_hookUpAbilityChangedEvent(k2, k)
								end
							end
						end

						self._enabledChangedEvent:Fire()
					end

					self._evaluateStateMachineChangedConnection = self._humanoid:GetPropertyChangedSignal("EvaluateStateMachine"):Connect(function()
						enabledChanged()
					end)
					enabledChanged()
				end
			end)
		end
	end

	function class:isEnabled()
		return self._abilityManagerActor ~= nil and self._humanoid and not self._humanoid.EvaluateStateMachine
	end

	function class:GetEnabledChangedSignal()
		return self._enabledChangedEvent.Event
	end

	function class:SendInput(p, p2)
		if not self:isEnabled() then
			return
		end

		if p2 ~= self._data[p] then
			self._data[p] = p2
			self._avatarAbilities().setAbilityManagerCommand(self._character, p, p2)
		end
	end

	function class:GetAbilityAttribute(p2, attributeName, p3)
		local v3 = self._inputMap[p2]

		if #v3 < 1 then
			return p3
		end

		local v4 = v3[1]

		if not v4 then
			return p3
		end

		local syncedState = v4:FindFirstChild("SyncedState")

		if not syncedState then
			return p3
		end

		local attribute = syncedState:GetAttribute(attributeName)

		if attribute == nil then
			return p3
		end

		return attribute
	end

	function class:GetAbilityAttributeChangedSignal(p, p2)
		if not self._abilityChangedEvents[p2] then
			self._abilityChangedEvents[p2] = {}
		end

		if self._abilityChangedEvents[p2][p] then
			return self._abilityChangedEvents[p2][p].Event
		end

		local bindableEvent = Instance.new("BindableEvent")
		self._abilityChangedEvents[p2][p] = bindableEvent
		self:_hookUpAbilityChangedEvent(p, p2)
		return bindableEvent.Event
	end

	function class:GetAbilityEnabled(p)
		return self:GetAbilityAttribute(p, "Enabled", false)
	end

	function class:GetAbilityEnabledChangedSignal(p)
		return self:GetAbilityAttributeChangedSignal(p, "Enabled")
	end

	function class:GetAbilitySuspended(p)
		return self:GetAbilityAttribute(p, "Suspended", false)
	end

	function class:GetAbilitySuspendedChangedSignal(p)
		return self:GetAbilityAttributeChangedSignal(p, "Suspended")
	end

	function class:GetAbilityActive(p)
		return self:GetAbilityAttribute(p, "Active", false)
	end

	function class:GetAbilityActiveChangedSignal(p)
		return self:GetAbilityAttributeChangedSignal(p, "Active")
	end

	function class:GetAbilityValid(p)
		return self:GetAbilityAttribute(p, "IsValid", true)
	end

	function class:GetAbilityValidChangedSignal(p)
		return self:GetAbilityAttributeChangedSignal(p, "IsValid")
	end

	function class:GetAbilities()
		local result = {}

		for k, _ in self._inputMap do
			table.insert(result, k)
		end

		return result
	end

	function class:GetAbilitiesChangedSignal()
		return self._abilitiesChangedEvent.Event
	end

	function class:GetAbilityConfig(p2)
		local v3 = {
			Slot = -1
		}
		local v4 = self._inputMap[p2]

		if #v4 < 1 then
			return v3
		end

		local v5 = v4[1]

		if not v5 then
			return v3
		end

		local actionSlot = v5:GetAttribute("ActionSlot")

		if actionSlot then
			return {
				Slot = tonumber(actionSlot),
				ButtonAssetId = v5:GetAttribute("CustomIcon"),
				ButtonPressedAssetId = v5:GetAttribute("CustomIconActive"),
				ButtonInvalidAssetId = v5:GetAttribute("CustomIconInvalid")
			}
		end

		return v3
	end

	function class:destroy()
		if self._characterAddedConnection then
			self._characterAddedConnection:Disconnect()
			self._characterAddedConnection = nil
		end

		if self._evaluateStateMachineChangedConnection then
			self._evaluateStateMachineChangedConnection:Disconnect()
			self._evaluateStateMachineChangedConnection = nil
		end

		for _, _abilityChangedConnection in self._abilityChangedConnections do
			for _, connection in _abilityChangedConnection do
				connection:Disconnect()
			end
		end

		self._abilityChangedConnections = {}
	end

	return class
else
	local Players2 = game:GetService("Players")
	local abilityManagerActor = nil
	local humanoid = nil
	local bindableEvent = Instance.new("BindableEvent")
	local evaluateStateMachineChangedConnection = nil
	local flag = false

	local function characterAdded(character)
		abilityManagerActor = nil
		humanoid = nil

		if evaluateStateMachineChangedConnection then
			evaluateStateMachineChangedConnection:Disconnect()
			evaluateStateMachineChangedConnection = nil
		end

		if character then
			abilityManagerActor = character:FindFirstChild("AbilityManagerActor")
			humanoid = character:FindFirstChildOfClass("Humanoid")

			while not humanoid do
				character.ChildAdded:wait()
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			bindableEvent:Fire()
			evaluateStateMachineChangedConnection = humanoid:GetPropertyChangedSignal("EvaluateStateMachine"):Connect(function()
				bindableEvent:Fire()
			end)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lazyInit()
		if flag then
			return
		end

		flag = true
		local localPlayer = Players2.LocalPlayer

		if localPlayer then
			localPlayer.characterAdded:Connect(characterAdded)

			if localPlayer.Character then
				characterAdded(localPlayer.Character)
			end
		end
	end

	return {
		isEnabled = function()
			lazyInit() -- equivalent call inferred; original call site unknown
			return abilityManagerActor ~= nil and humanoid and not humanoid.EvaluateStateMachine
		end,
		GetEnabledChangedSignal = function()
			lazyInit() -- equivalent call inferred; original call site unknown
			return bindableEvent.Event
		end
	}
end