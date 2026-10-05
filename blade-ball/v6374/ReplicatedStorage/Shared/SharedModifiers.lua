local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local isClient = RunService:IsClient()
local v = require3(ReplicatedStorage2.Common.Utils.Utilities.String)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local SharedModifiers = {
	DEBUG = false,
	Utils = {},
	Priority = {
		ADD = 100,
		DEBUFF = 0,
		MULTIPLY = -100,
		OFFSET = -200
	}
}
local v4 = {}
local v5 = v2.new()

function SharedModifiers.new(p)
	local v6 = v.AssertAttributeName(p.Name)
	local v7 = v.AssertAttributeName((`{v6}ClientOffset`))
	local serverOffset = v.AssertAttributeName((`{v6}ServerOffset`))
	local clientValue = v.AssertAttributeName((`{v6}ClientValue`))
	local v10 = v.AssertAttributeName((`{v6}ServerValue`))
	local clone = table.clone(p)
	clone._serverOffset = serverOffset
	clone._clientOffset = v7

	if not isClient then
		v7 = serverOffset
	end

	clone._sideOffset = v7
	clone._serverValue = v10
	clone._clientValue = clientValue

	if isClient then
		v10 = clientValue
	end

	clone._sideValue = v10
	clone.Modifiers = {}
	clone.Troves = {}
	clone.OnUpdate = v2.new()
	local object = setmetatable(clone, {
		__index = SharedModifiers
	})
	v4[v6] = object
	v5:Fire()
	return object
end

function SharedModifiers:ClearAllModifiersFor(p)
	local modifier = self.Modifiers[p]

	if modifier then
		table.clear(modifier)
		self:Update(p)
		self.Modifiers[p] = nil
	end

	local trove = self.Troves[p]

	if trove then
		trove:Destroy()
		self.Troves[p] = nil
	end
end

function SharedModifiers:GetModifiersFor(instance)
	local modifier = self.Modifiers[instance]

	if modifier then
		return modifier
	end

	modifier = {}
	self.Modifiers[instance] = modifier

	if not self.Troves[instance] then
		local maid = v3.new()
		self.Troves[instance] = maid
		maid:Add(instance.Destroying:Once(function()
			self:ClearAllModifiersFor(instance)
		end))
	end

	return modifier
end

function SharedModifiers:ApplyModifiers(p, p2: number)
	local result = {
		{
			value = p2,
			modifier = nil
		}
	}

	for _, modifier in self:GetModifiersFor(p) do
		local v7

		if modifier.modifier then
			v7 = modifier.modifier(p2, result)
		end

		if v7 == nil then
			continue
		end

		if type(v7) == "number" then
			table.insert(result, {
				value = v7,
				modifier = modifier
			})
			p2 = v7
		else
			warn((`Result of modifier "{modifier.id}" is not a number, expected nil or number and got "{typeof(v7)}"`))
		end
	end

	return p2, result
end

function SharedModifiers:GetDefaultValueFor(instance, flag: boolean?)
	local attribute = instance:GetAttribute(self._sideValue) or self.DefaultValue

	if isClient and flag ~= false then
		attribute += instance:GetAttribute(self._serverOffset) or 0
	end

	return attribute
end

function SharedModifiers:Observe(onOnUpdate)
	for k in self.Modifiers do
		local modifiedValueFor = self:GetModifiedValueFor(k)
		task.spawn(onOnUpdate, k, modifiedValueFor)
	end

	return self.OnUpdate:Connect(onOnUpdate)
end

function SharedModifiers:Update(instance, flag: boolean?)
	local defaultValueFor = self:GetDefaultValueFor(instance)
	local modifiedValueFor = self:GetModifiedValueFor(instance)

	if flag then
		instance:SetAttribute(self._sideOffset, nil)
	end

	instance:SetAttribute(self._sideOffset, modifiedValueFor - defaultValueFor)
	self.OnUpdate:Fire(instance, modifiedValueFor)
	return modifiedValueFor, defaultValueFor
end

function SharedModifiers:RemoveModifierFor(p, p2: string)
	local modifiersFor = self:GetModifiersFor(p)

	for i = #modifiersFor, 1, -1 do
		if modifiersFor[i].id ~= p2 then
			continue
		end

		table.remove(modifiersFor, i)
		self:Update(p)
		return true
	end

	if #modifiersFor <= 0 then
		self:ClearAllModifiersFor(p)
	end

	return false
end

function SharedModifiers:SetModifierFor(p, id: string, modifier, priority2: number?)
	self:RemoveModifierFor(p, id)
	local modifiersFor = self:GetModifiersFor(p)
	table.insert(modifiersFor, {
		id = id,
		modifier = modifier,
		priority = priority2,
		createdAt = workspace:GetServerTimeNow()
	})
	table.sort(modifiersFor, function(a, b)
		local v6 = (a.priority or 0) > (b.priority or 0)
		local priority

		if a.priority or b.priority then
			priority = a.priority

			if priority then
				if a.priority == b.priority then
					priority = a.createdAt > b.createdAt
				else
					priority = false
				end
			end
		else
			priority = a.createdAt > b.createdAt
		end

		return v6 or priority
	end)
	self:Update(p)
	return function()
		return self:RemoveModifierFor(p, id)
	end
end

function SharedModifiers:GetModifiedValueFor(p)
	return self:ApplyModifiers(p, self:GetDefaultValueFor(p))
end

function SharedModifiers:SetDefaultValueFor(instance, p: number)
	instance:SetAttribute(self._sideValue, p)
	return self:Update(instance)
end

function SharedModifiers.Utils.MinDebuff(_, p: number)
	return function(_: number, items)
		local v6 = {}

		for _, item in items do
			if item.value and item.modifier and (item.modifier.priority or 0) == 0 then
				table.insert(v6, item.value)
			end
		end

		return (math.min(p, table.unpack(v6)))
	end
end

local v6 = {}

local function onPlayerAdded(player)
	local maid = v3.new()
	v6[player] = maid
	local maid2 = maid:Extend()

	local function onCharacterAdded(instance)
		instance:WaitForChild("Humanoid", 5)
		local torso = instance:WaitForChild("Torso", 5)
		maid2:Clean()

		for _, v7 in v4 do
			v7:SetDefaultValueFor(instance, v7.DefaultValue)

			if not isClient then
				continue
			end

			if torso then
				local v8 = v7
				maid2:Add(torso:GetPropertyChangedSignal("AssemblyMass"):Connect(function()
					v8:Update(instance)
				end))
			end

			local v8 = v7
			maid2:Add(instance:GetAttributeChangedSignal(v7._serverOffset):Connect(function()
				v8:Update(instance)
			end))
			local v9 = v7
			maid2:Add(instance:GetAttributeChangedSignal(v7._serverValue):Connect(function()
				v9:Update(instance)
			end))
		end
	end

	maid:Add(player.CharacterAdded:Connect(onCharacterAdded))

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	maid:Add(player.CharacterRemoving:Connect(function(character)
		maid2:Clean()

		for _, v7 in v4 do
			v7:ClearAllModifiersFor(character)
		end
	end))
	maid:Add(v5:Connect(function()
		if player.Character then
			task.spawn(onCharacterAdded, player.Character)
		end
	end))
end

Players.PlayerRemoving:Connect(function(player)
	for _, v7 in v4 do
		for character in v7.Modifiers do
			if Players:GetPlayerFromCharacter(character) == player then
				v7:ClearAllModifiersFor(character)
			end
		end
	end

	local v7 = v6[player]

	if v7 then
		v7:Destroy()
		v6[player] = nil
	end
end)
Players.PlayerAdded:Connect(onPlayerAdded)

for _, v7 in Players:GetPlayers() do
	task.spawn(onPlayerAdded, v7)
end

return SharedModifiers