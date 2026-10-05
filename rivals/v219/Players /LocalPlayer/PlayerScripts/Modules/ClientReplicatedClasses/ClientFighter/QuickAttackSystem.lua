local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local QuickAttackSystem = {}
QuickAttackSystem.__index = QuickAttackSystem

function QuickAttackSystem.new(clientFighter)
	local self = setmetatable({}, QuickAttackSystem)
	self.ClientFighter = clientFighter
	self._quick_attack_down_starts = {}
	self._is_quick_attacking = false
	self._keep_quick_attack = false
	self._quick_attack_hash = 0
	self._quick_attack_cooldown = 0
	self._quick_attack_original_item = nil
	self._quick_attack_target_item = nil
	self._quick_attack_inputs = nil
	self._quick_attack_keep_window = 0
	self._dont_skip_equip_animation_from_quick_attacks = 0
	self:_Init()
	return self
end

function QuickAttackSystem:IsEquippingLocked(p2)
	return self._quick_attack_target_item and self._quick_attack_target_item:Get("ObjectID") ~= p2
end

function QuickAttackSystem:GetQuickAttackIndex(p2)
	return self.ClientFighter:Get("OverrideQuickAttacks") and self.ClientFighter:Get("OverrideQuickAttacks")[p2] or ItemLibrary.QUICK_ATTACK_ITEM_INDEX_DEFAULTS[p2]
end

function QuickAttackSystem.ShouldSkipEquipAnimation(_, object)
	return object:Get("QuickAttackQueued") or object:Get("SkipEquipAnimation")
end

function QuickAttackSystem:InputDown(p)
	self._quick_attack_down_starts[p] = tick()

	if self.ClientFighter:AreItemsLocked() or tick() < self._quick_attack_cooldown then
		return
	end

	local quickAttackIndex = self:GetQuickAttackIndex(p)
	local item = self.ClientFighter.Items[quickAttackIndex]
	local equippedItem = self.ClientFighter.EquippedItem

	if not (equippedItem and item) then
		return
	end

	local v = PlayerDataController:GetSetting("Easy Quick Attack") and item:CanEasyQuickAttack() and item.Info.QuickAttackInputsEasy ~= nil
	local quickAttackInputsEasy = v and item.Info.QuickAttackInputsEasy

	if not quickAttackInputsEasy then
		if item:CanQuickAttack() then
			quickAttackInputsEasy = item.Info.QuickAttackInputs or nil
		else
			quickAttackInputsEasy = nil
		end
	end

	if equippedItem == item or not quickAttackInputsEasy then
		item:PlayEquipFailedEffect()
		return
	end

	self._is_quick_attacking = true
	self._keep_quick_attack = PlayerDataController:GetSetting("Keep Quick Attack Enabled")
	self._quick_attack_hash += 1
	self._quick_attack_keep_window = tick() + (not self._keep_quick_attack and 1e999 or PlayerDataController:GetSetting("Keep Quick Attack Window"))
	self._quick_attack_cooldown = 1e999
	self._quick_attack_original_item = equippedItem
	self._quick_attack_target_item = item
	self._quick_attack_inputs = quickAttackInputsEasy
	ReplicatedStorage.Remotes.Replication.Fighter.RegisterQuickAttack:FireServer(p, v)
	item:SetReplicate("QuickAttackQueued", true)
	self.ClientFighter:EquipItem(table.find(self.ClientFighter.Items, item), true)
	task.defer(function()
		local _quick_attack_hash = self._quick_attack_hash
		wait(ItemLibrary.QUICK_ATTACK_TIMEOUT)

		if _quick_attack_hash == self._quick_attack_hash then
			self:_Cancel(false)
		end
	end)
end

function QuickAttackSystem:InputUp(p)
	if not self._quick_attack_down_starts[p] then
		return
	end

	if (not PlayerDataController:GetSetting("Keep Quick Attack Enabled") and 1e999 or PlayerDataController:GetSetting("Keep Quick Attack Window")) > tick() - self._quick_attack_down_starts[p] and tick() < self._quick_attack_keep_window then
		self._keep_quick_attack = false
	end
end

function QuickAttackSystem:OnReEquip()
	for _, item in pairs(self.ClientFighter.Items) do
		item:SetReplicate("SkipEquipAnimation", nil)
	end

	self._dont_skip_equip_animation_from_quick_attacks = tick() + 1
end

function QuickAttackSystem:Clear()
	self._is_quick_attacking = false
	self._keep_quick_attack = false
	self._quick_attack_hash += 1
	self._quick_attack_cooldown = tick() + 0
	self._quick_attack_original_item = nil
	self._quick_attack_target_item = nil
	self._quick_attack_inputs = nil
end

function QuickAttackSystem.Destroy(_) end

function QuickAttackSystem:_Cancel(_keep_quick_attack)
	if _keep_quick_attack == nil then
		_keep_quick_attack = self._keep_quick_attack
	end

	if not self._quick_attack_original_item then
		return
	end

	if self._quick_attack_target_item then
		self._quick_attack_target_item:SetReplicate("QuickAttackQueued", nil)
	end

	if not _keep_quick_attack then
		if tick() > self._dont_skip_equip_animation_from_quick_attacks then
			self._quick_attack_original_item:SetReplicate("SkipEquipAnimation", true)
		end

		self.ClientFighter:EquipItem(table.find(self.ClientFighter.Items, self._quick_attack_original_item), true)
	end

	self:Clear()
end

function QuickAttackSystem:_TryQuickAttackInputs(object)
	if not self._quick_attack_inputs then
		return false
	end

	for _, _quick_attack_input in pairs(self._quick_attack_inputs) do
		if not object:Input(_quick_attack_input) then
			return false
		end

		wait(0.05)
	end

	return true
end

function QuickAttackSystem:_OnEquip(object2)
	if not object2 then
		return
	end

	if object2:Get("SkipEquipAnimation") then
		object2:SetReplicate("SkipEquipAnimation", nil)
	end

	if object2:Get("QuickAttackQueued") and self.ClientFighter.IsLocalPlayer then
		task.defer(function()
			local _quick_attack_hash = self._quick_attack_hash
			local v = false
			local bindableEvent = Instance.new("BindableEvent")
			BetterDebris:AddItem(bindableEvent, ItemLibrary.QUICK_ATTACK_TIMEOUT)
			task.spawn(function()
				local v2, v3
				local controlFlowState = 6

				while true do
					if controlFlowState == 0 then
						controlFlowState = 2
						continue
					end

					if controlFlowState == 1 then
						controlFlowState = 2
						continue
					end

					if controlFlowState == 2 then
						v3 = object2.ServerInputWorkDone:Wait()

						if self._quick_attack_hash == _quick_attack_hash then
							controlFlowState = 5
						else
							controlFlowState = 4
						end

						continue
					elseif controlFlowState == 3 then
						v = true
						bindableEvent:Fire()
						task.defer(bindableEvent.Destroy, bindableEvent)
						break
					else
						if controlFlowState == 4 then
							break
						end

						if controlFlowState == 5 then
							if v3 == v2 then
								controlFlowState = 3
							else
								controlFlowState = 0
							end
						else
							if controlFlowState ~= 6 then
								break
							end

							v2 = self._quick_attack_inputs and self._quick_attack_inputs[#self._quick_attack_inputs]

							if v2 then
								controlFlowState = 1
							else
								controlFlowState = 3
							end
						end

						continue
					end
				end
			end)
			local _TryQuickAttackInputs = self:_TryQuickAttackInputs(object2)

			if self._quick_attack_hash ~= _quick_attack_hash then
				return
			end

			if _TryQuickAttackInputs then
				if not v then
					bindableEvent.Event:Wait()
				end

				while self._keep_quick_attack and tick() < self._quick_attack_keep_window do
					RunService.Heartbeat:Wait()

					if self._quick_attack_hash ~= _quick_attack_hash then
						return
					end
				end

				self:_Cancel(nil)
			else
				self:_Cancel(false)
			end
		end)
	end
end

function QuickAttackSystem:_Init()
	self.ClientFighter.EquippedItemChanged:Connect(function(p)
		self:_OnEquip(p)
	end)
end

return QuickAttackSystem