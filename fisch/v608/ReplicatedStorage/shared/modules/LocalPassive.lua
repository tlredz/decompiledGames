local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Signal = require(ReplicatedStorage.packages.Signal)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
require(ReplicatedStorage.shared.modules.fishing)
require(ReplicatedStorage.shared.modules.library.rods.enchants)
local bait = require(ReplicatedStorage.shared.modules.library.bait)
local apply_op = require(ReplicatedStorage.shared.utils.GeneralUtils.apply_op)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local remoteEvent = Net:RemoteEvent("LocalPassives/Update")
local _ = Players.LocalPlayer
local LocalPassive = {
	Sources = {},
	PassivesChanged = Signal.new(),
	_Overrides = {},
	_Custom = {}
}
local class = {}
class.__index = class

function class:SetActivePassives(items, flag: boolean?)
	local _Override = LocalPassive._Overrides[self.Name]

	if _Override then
		local clone = table.clone(_Override)

		for k in _Override do
			if not items[k] then
				clone[k] = nil
			end
		end

		items = GeneralUtils.applyTable(items, clone, false)
	end

	for k, activePassive in self.ActivePassives do
		if items[k] and not flag then
			activePassive.config = items[k]

			if activePassive.ApplyConfig then
				activePassive:ApplyConfig(items[k])
			end
		else
			activePassive:Destroy()
			self.ActivePassives[k] = nil
		end
	end

	for k, item in items do
		if self.ActivePassives[k] then
			continue
		end

		local passiveName = k:split("//")[1]
		local child = script:FindFirstChild(passiveName)

		if child then
			local env = {
				SourceName = self.Name,
				PassiveName = passiveName,
				PassiveNameFull = k
			}
			local module = require(child)
			local v3 = module:new(item, env)

			if v3 then
				v3.env = env
			end

			self.ActivePassives[k] = v3
		else
			warn((`yo "{passiveName}" passive dont exist lil bruh`))
		end
	end

	LocalPassive.PassivesChanged:Fire()
end

function class:Reload()
	local copies = {}

	for k, activePassive in self.ActivePassives do
		copies[k] = GeneralUtils.copy(activePassive.config, true) or {}
	end

	self:SetActivePassives(copies, true)
end

function class:Destroy()
	self:SetActivePassives({})
	LocalPassive.Sources[self.Name] = nil
end

function LocalPassive:GetSource(name: string)
	if self.Sources[name] then
		return self.Sources[name]
	end

	local object = setmetatable({
		Name = name,
		ActivePassives = {}
	}, class)
	self.Sources[name] = object
	return object
end

function LocalPassive._DEBUG_AddCustomPassive(_, p: string, p2)
	local v = p
	local count = 0

	while LocalPassive._Custom[v] ~= nil do
		count += 1
		v = `{p}//{count}`
	end

	LocalPassive._Custom[v] = p2
	LocalPassive:GetSource("Custom"):SetActivePassives(LocalPassive._Custom, true)
end

function LocalPassive._DEBUG_RemovePassive(_, p: string, p2: string)
	if p == "Custom" then
		LocalPassive._Custom[p2] = nil
		LocalPassive:GetSource("Custom"):SetActivePassives(LocalPassive._Custom, true)
	else
		if not LocalPassive._Overrides[p] then
			LocalPassive._Overrides[p] = {}
		end

		LocalPassive._Overrides[p][p2] = apply_op.DELETE
		LocalPassive:GetSource(p):Reload()
	end
end

function LocalPassive.GetActivePassives(_, list, list2)
	local activePassives = {}

	for _, source in LocalPassive.Sources do
		if list and table.find(list, source.Name) or not (not list2 or table.find(list2, source.Name)) then
			continue
		end

		for _, activePassive in source.ActivePassives do
			table.insert(activePassives, activePassive)
		end
	end

	return activePassives
end

function LocalPassive:Start()
	if self.Started then
		return
	end

	self.Started = true
	local source = LocalPassive:GetSource("FishingRod")
	local source2 = LocalPassive:GetSource("Enchantment")
	local source3 = LocalPassive:GetSource("SecondaryEnchantment")

	local function updateRodBasedPassives(data)
		source:SetActivePassives(data.rod or {}, true)
		source2:SetActivePassives(data.enchant or {})
		source3:SetActivePassives(data.secEnchant or {})

		for i = 1, 3 do
			LocalPassive:GetSource((`KeeperAffix{i}`)):SetActivePassives(data.affixes[i] or {})
		end
	end

	Net:RemoteEvent("PassiveService/UpdateRodPassives", -1).OnClientEvent:Connect(updateRodBasedPassives)
	local source4 = LocalPassive:GetSource("Spear")
	local source5 = LocalPassive:GetSource("Spear_Enchantment")
	local source6 = LocalPassive:GetSource("Spear_SecondaryEnchantment")

	local function updateSpearBasedPassives(data)
		source4:SetActivePassives(data.spear or {}, true)
		source5:SetActivePassives(data.enchant or {})
		source6:SetActivePassives(data.secEnchant or {})
	end

	Net:RemoteEvent("PassiveService/UpdateSpearPassives", -1).OnClientEvent:Connect(updateSpearBasedPassives)
	local source7 = LocalPassive:GetSource("HarpoonGun")
	local source8 = LocalPassive:GetSource("HarpoonGun_Enchantment")
	local source9 = LocalPassive:GetSource("HarpoonGun_SecondaryEnchantment")

	local function updateHarpoonBasedPassives(data)
		source7:SetActivePassives(data.harpoon or {}, true)
		source8:SetActivePassives(data.enchant or {})
		source9:SetActivePassives(data.secEnchant or {})
	end

	Net:RemoteEvent("PassiveService/UpdateHarpoonPassives", -1).OnClientEvent:Connect(updateHarpoonBasedPassives)
	local source10 = LocalPassive:GetSource("Bait")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBaitPassives(value)
		local v = bait[value]
		source10:SetActivePassives(v and v.ClientFishingPassives or {})
	end

	local bait2 = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("bait")
	bait2.Changed:Connect(updateBaitPassives)
	updateBaitPassives(bait2.Value) -- equivalent call inferred; original call site unknown
	remoteEvent.OnClientEvent:Connect(function(p2, p3, p4)
		LocalPassive:GetSource(p2):SetActivePassives(p3, p4)
	end)
	Net:RemoteEvent("AccessoryService/RequestClientPassives"):FireServer()
end

return LocalPassive