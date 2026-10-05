local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
UserSettings():GetService("UserGameSettings")
local UserInputService = game:GetService("UserInputService")
local InputReplication = require(script.Parent:WaitForChild("InputReplication"))
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v = AvatarAbilitiesInterface.get(Players.LocalPlayer)
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsSAuthDirectAPIs2")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2")
local userFlag4 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceB")
local v2 = userFlag4 and "ControlState" or "PlayerControlState"
local InputSlots = {}
InputSlots.__index = InputSlots
local result = {}
local result2 = {}
local children = {}
local children2 = {}
local bindableEvent = Instance.new("BindableEvent")
local v3 = 0
local bindableEvent2 = Instance.new("BindableEvent")

local function shallow_equal(items, clone)
	if items == clone then
		return true
	end

	for k, item in pairs(items) do
		if clone[k] ~= item then
			return false
		end
	end

	for k, _ in pairs(clone) do
		if items[k] == nil then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findInSparseTable(items, p)
	for k, item in pairs(items) do
		if item == p then
			return k
		end
	end

	return nil
end

function InputSlots.GetNumOverflowSlots()
	return 3
end

function InputSlots.getOverflowScrollIndex()
	return v3
end

function InputSlots.setOverflowScrollIndex(p)
	local v4 = v3
	v3 = math.max(0, (math.min(#result2 - 3, p)))

	if v3 ~= v4 then
		bindableEvent2:Fire()
	end
end

function InputSlots.getScrollIndexChangedEvent()
	return bindableEvent2.Event
end

function InputSlots.setupSlotActions(instance, p)
	local function getAbilityAction(p2)
		if not p2 then
			return nil
		end

		local inputContexts

		if userFlag3 and not p then
			inputContexts = script.Parent.Parent:FindFirstChild("InputContexts")
		else
			inputContexts = instance:FindFirstChild("InputContexts")
		end

		if not inputContexts then
			return nil
		end

		local characterContext = inputContexts:FindFirstChild("CharacterContext")

		if characterContext then
			return (characterContext:FindFirstChild(p2 .. "Action"))
		end

		return nil
	end

	if not userFlag3 then
		RunService:BindToSimulation(function(_)
			if v:isEnabled() then
				InputReplication.FireCustomInputs(instance)
				InputReplication.SendInputToCCLCharacter(instance)
			end
		end, Enum.StepFrequency.Hz60)
	end

	local v4 = {}

	local function updateSlotMap()
		local clone = table.clone(result)
		local clone2 = table.clone(result2)
		local abilities = v:GetAbilities()
		local v5 = UserInputService.PreferredInput == Enum.PreferredInput.Touch and 7 or 11

		for k, v6 in pairs(result) do
			local k2 = findInSparseTable(abilities, v6) -- equivalent call inferred; original call site unknown

			if not k2 or v5 < k then
				result[k] = nil
			end
		end

		result2 = {}
		local abilities2 = {}

		for _, ability in ipairs(abilities) do
			-- equivalent call inferred; original call site unknown
			if not findInSparseTable(result, ability) then
				table.insert(abilities2, ability)
			end
		end

		for _, v6 in ipairs(abilities2) do
			local abilityConfig = v:GetAbilityConfig(v6)

			if not abilityConfig then
				continue
			end

			local slot = tonumber(abilityConfig.Slot)

			if not (slot > 0) then
				continue
			end

			if result[slot] or not (slot <= v5) then
				table.insert(result2, v6)
			else
				result[slot] = v6
			end
		end

		for _, v6 in ipairs(abilities2) do
			local abilityConfig = v:GetAbilityConfig(v6)

			if not (abilityConfig and tonumber(abilityConfig.Slot) == 0) then
				continue
			end

			local v7 = v4[v6]

			if v7 and v7 > 0 and v7 <= v5 and not result[v7] then
				result[v7] = v6
			else
				local v8 = -1

				for i = 1, v5 do
					if result[i] then
						continue
					end

					v8 = i
					break
				end

				if v8 == -1 then
					table.insert(result2, v6)
				else
					result[v8] = v6
					v4[v6] = v8
				end
			end
		end

		InputSlots.setOverflowScrollIndex(InputSlots.getOverflowScrollIndex())

		if not (shallow_equal(result, clone) and shallow_equal(result2, clone2)) then
			bindableEvent:Fire()
		end
	end

	v:GetAbilitiesChangedSignal():Connect(updateSlotMap)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateSlotMap)
	updateSlotMap()
	task.spawn(function()
		local function UpdateAbilityInPCS(player, p2, p3)
			local character = player.Character

			if not character then
				return
			end

			local child

			if userFlag4 then
				child = character:FindFirstChildOfClass(v2)
			else
				child = character:FindFirstChild(v2)
			end

			if not child then
				return
			end

			child:UpdateFields({
				[p2] = p3
			})
		end

		local v5

		if userFlag3 and not p then
			v5 = script.Parent.Parent:FindFirstChild("InputContexts")
		else
			v5 = instance:WaitForChild("InputContexts", 1e999)
		end

		local characterContext = v5:WaitForChild("CharacterContext")

		for i = 1, 11 do
			local child = characterContext:WaitForChild("AbilityAction" .. tostring(i))
			children[i] = child
			local v6 = i
			child.StateChanged:Connect(function(p2)
				if userFlag3 then
					if result[v6] ~= nil and result[v6] ~= "" then
						UpdateAbilityInPCS(instance, result[v6], p2)
					end
				else
					local abilityAction = getAbilityAction(result[v6])

					if abilityAction then
						if userFlag then
							local scriptableBinding = abilityAction:FindFirstChild("ScriptableBinding")

							if scriptableBinding then
								scriptableBinding:Fire(p2)
							end
						elseif userFlag2 then
							local scriptableBinding = abilityAction:FindFirstChild("ScriptableBinding")

							if not scriptableBinding then
								abilityAction:Fire(p2)
								return
							end

							local success, result3 = pcall(function()
								scriptableBinding.Type = Enum.InputBindingType.Scriptable
								scriptableBinding:Fire(p2)
							end)

							if not success then
								abilityAction:Fire(p2)
							end
						else
							abilityAction:Fire(p2)
						end
					end
				end
			end)
		end

		if userFlag3 then
			for i = 1, 3 do
				local child = characterContext:WaitForChild("OverflowAction" .. tostring(i))
				children2[i] = child
				local v6 = i
				child.StateChanged:Connect(function(p2)
					local v7 = result2[v6 + v3]

					if v7 ~= nil and v7 ~= "" then
						UpdateAbilityInPCS(instance, v7, p2)
					end
				end)
			end
		end
	end)
end

function InputSlots.GetSlotMapChangedSignal()
	return bindableEvent.Event
end

function InputSlots.GetSlotMap()
	return result
end

function InputSlots.GetAbilitiesInOverflow()
	return result2
end

function InputSlots.GetActionInSlot(p)
	return children[p]
end

function InputSlots.GetOverflowAction(p)
	return children2[p]
end

return InputSlots