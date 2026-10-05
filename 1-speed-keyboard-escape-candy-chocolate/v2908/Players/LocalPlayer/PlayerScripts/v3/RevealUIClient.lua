local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local revealUI = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RevealUI")
local RevealRegistry = require(ReplicatedStorage._FRAMEWORK.Libraries.RevealRegistry)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function setUIVisible(instance, nameRevealed)
	if instance:IsA("GuiObject") then
		instance.Visible = nameRevealed
	elseif instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") or instance:IsA("BillboardGui") then
		instance.Enabled = nameRevealed
	end
end

local function isRevealDisappear(instance)
	return instance:GetAttribute("RevealDisappear") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isNameRevealed(name)
	return RevealRegistry.isAllRevealed() or v[name] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function visibleForRevealState(instance, flag: boolean)
	if instance:GetAttribute("RevealDisappear") ~= nil then
		return not flag
	end

	return flag
end

local function getUIElementsByName(p)
	local result = {}

	for _, v2 in ipairs(CollectionService:GetTagged("RevealUI")) do
		if v2:GetAttribute("Name") == p and v2:IsDescendantOf(playerGui) then
			table.insert(result, v2)
		end
	end

	return result
end

local function applyRevealUI(value)
	for _, instance in ipairs((getUIElementsByName(value))) do
		local v2 = visibleForRevealState(instance, true) -- equivalent call inferred; original call site unknown

		if instance:IsA("GuiObject") then
			instance.Visible = v2
		elseif instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") or instance:IsA("BillboardGui") then
			instance.Enabled = v2
		end
	end
end

local function applyUnrevealUI(value)
	for _, instance in ipairs((getUIElementsByName(value))) do
		local v2 = instance:GetAttribute("RevealDisappear") ~= nil or false

		if instance:IsA("GuiObject") then
			instance.Visible = v2
		elseif instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") or instance:IsA("BillboardGui") then
			instance.Enabled = v2
		end
	end
end

local function applyAllStates()
	for _, instance in ipairs(CollectionService:GetTagged("RevealUI")) do
		if not instance:IsDescendantOf(playerGui) then
			continue
		end

		local name = instance:GetAttribute("Name")

		if not name then
			continue
		end

		local nameRevealed = isNameRevealed(name) -- equivalent call inferred; original call site unknown

		if instance:GetAttribute("RevealDisappear") ~= nil then
			nameRevealed = not nameRevealed
		end

		if instance:IsA("GuiObject") then
			instance.Visible = nameRevealed
		elseif instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") or instance:IsA("BillboardGui") then
			instance.Enabled = nameRevealed
		end
	end
end

revealUI.OnClientEvent:Connect(function(p, value)
	if p == "init" then
		if type(value) == "table" then
			v = value
		end

		applyAllStates()
	elseif p == "reveal" then
		if type(value) == "string" then
			v[value] = true
			applyRevealUI(value)
		end
	elseif p == "unreveal" and type(value) == "string" then
		v[value] = nil
		applyUnrevealUI(value)
	end
end)
CollectionService:GetInstanceAddedSignal("RevealUI"):Connect(function(instance)
	task.defer(function()
		if not instance:IsDescendantOf(playerGui) then
			return
		end

		local name = instance:GetAttribute("Name")

		if not name then
			return
		end

		local nameRevealed = isNameRevealed(name) -- equivalent call inferred; original call site unknown

		if instance:GetAttribute("RevealDisappear") ~= nil then
			nameRevealed = not nameRevealed
		end

		setUIVisible(instance, nameRevealed) -- equivalent call inferred; original call site unknown
	end)
end)