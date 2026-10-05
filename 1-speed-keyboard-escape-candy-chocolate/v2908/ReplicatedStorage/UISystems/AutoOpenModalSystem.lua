local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local AutoOpenModalConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("AutoOpenModalConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateUI = remotes:WaitForChild("UpdateUI")
local markAutoOpenModalSeen = remotes:WaitForChild("MarkAutoOpenModalSeen")
local AutoOpenModalSystem = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local clone = table.clone(AutoOpenModalConfig.OpenOnJoin)
table.sort(clone, function(a, b)
	return a.Priority > b.Priority
end)
local v = {}
local v2 = {}
local v3 = false
local v4 = false

local function getModal(modalTag: string)
	for _, guiObject in ipairs(CollectionService:GetTagged(modalTag)) do
		if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
			return guiObject
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findDef(p: string)
	for _, v5 in ipairs(clone) do
		if v5.Id == p then
			return v5
		end
	end

	return nil
end

local function syncSeenArrayToClientState()
	local seenAutoOpenModals = {}

	for k in pairs(v2) do
		table.insert(seenAutoOpenModals, k)
	end

	local get = ClientState:Get()
	get.SeenAutoOpenModals = seenAutoOpenModals
end

local function applySeenList(seenAutoOpenModals)
	if type(seenAutoOpenModals) == "table" then
		v3 = true

		for _, v5 in ipairs(seenAutoOpenModals) do
			if type(v5) == "string" then
				v2[v5] = true
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isEligible(p)
	local v5 = p.EventKey == nil or Config.GetEventDataKey() == p.EventKey
	local v6 = p.World == nil or Config.WORLD == p.World
	return v5 and v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markSeen(p: string)
	if not v2[p] then
		v2[p] = true
		syncSeenArrayToClientState()
		markAutoOpenModalSeen:FireServer(p)
	end
end

function AutoOpenModalSystem.IsSeen(p: string)
	return v2[p] == true
end

function AutoOpenModalSystem.HasSeenData()
	return v3
end

function AutoOpenModalSystem.MarkSeen(p: string)
	markSeen(p) -- equivalent call inferred; original call site unknown
end

function AutoOpenModalSystem.Bind(p: string, p2)
	v[p] = p2
	AutoOpenModalSystem.TryAutoOpen()
end

local function getTopEligibleDef()
	for _, v5 in ipairs(clone) do
		if not v2[v5.Id] and isEligible(v5) then
			return v5
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openAfterLoading(topEligibleDef)
	task.spawn(function()
		while playerGui:FindFirstChild("Loading") do
			task.wait(0.2)
		end

		task.wait(0.3)
		local modal = getModal(topEligibleDef.ModalTag)

		if modal then
			markSeen(topEligibleDef.Id) -- equivalent call inferred; original call site unknown
			local v5 = v[topEligibleDef.Id]

			if v5 and v5.openWithContent then
				v5.openWithContent()
			else
				ClientState:ToggleModal(modal, v5)
			end
		else
			v4 = false
			AutoOpenModalSystem.TryAutoOpen()
		end
	end)
end

function AutoOpenModalSystem.TryAutoOpen()
	if v4 or not v3 then
		return
	end

	local topEligibleDef = getTopEligibleDef()

	if not topEligibleDef then
		v4 = true
	elseif getModal(topEligibleDef.ModalTag) and (not topEligibleDef.WaitForOpenWithContent or v[topEligibleDef.Id]) then
		v4 = true
		openAfterLoading(topEligibleDef) -- equivalent call inferred; original call site unknown
	end
end

function AutoOpenModalSystem.Open(p: string)
	local def = findDef(p) -- equivalent call inferred; original call site unknown
	local v5 = def and getModal(def.ModalTag)

	if def and v5 then
		markSeen(p) -- equivalent call inferred; original call site unknown
		local v6 = v[p]

		if v6 and v6.openWithContent then
			v6.openWithContent()
		elseif ClientState.ActiveModal ~= v5 then
			ClientState:ToggleModal(v5, v6)
		end
	end
end

updateUI.OnClientEvent:Connect(function(p)
	if p and p.SeenAutoOpenModals ~= nil then
		applySeenList(p.SeenAutoOpenModals)
		AutoOpenModalSystem.TryAutoOpen()
	end
end)

for _, v5 in ipairs(clone) do
	CollectionService:GetInstanceAddedSignal(v5.ModalTag):Connect(function(instance)
		if instance:IsDescendantOf(playerGui) then
			AutoOpenModalSystem.TryAutoOpen()
		end
	end)
end

return AutoOpenModalSystem