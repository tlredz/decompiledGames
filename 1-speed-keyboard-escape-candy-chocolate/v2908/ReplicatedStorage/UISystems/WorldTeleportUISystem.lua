local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local WorldTeleportCatalog = require(ReplicatedStorage.Config:WaitForChild("WorldTeleportCatalog"))
local requestWorldTeleport = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestWorldTeleport")
local WorldTeleportUISystem = {}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local tPWorldRow = ReplicatedStorage.Templates.TPWorldRow
local tPGalaxyHeader = ReplicatedStorage.Templates.TPGalaxyHeader
local uDim = UDim2.new(0.8, 0, 0.02, 0)
local uDim2 = UDim2.new(0.8, 0, 0.1, 0)
local v = {}
local v2 = nil

local function getTagged(tag: string)
	for _, v3 in ipairs(CollectionService:GetTagged(tag)) do
		if v3:IsDescendantOf(playerGui) then
			return v3
		end
	end

	return nil
end

local function clearRows(parent)
	for k, v3 in pairs(v) do
		if v3 and v3.Parent then
			v3:Destroy()
		end

		v[k] = nil
	end

	for _, guiObject in ipairs(parent:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and (guiObject:GetAttribute("WorldTeleportRow") or guiObject:GetAttribute("WorldTeleportHeader"))) then
			continue
		end

		guiObject:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRevealUI(instance, name: string?)
	if name then
		instance:SetAttribute("Name", name)
		CollectionService:AddTag(instance, "RevealUI")
		instance.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createHeaderPad(parent, layoutOrder: number, revealName: string?, size: UDim2)
	local frame = Instance.new("Frame")
	frame.Name = "GalaxyHeaderPad"
	frame.LayoutOrder = layoutOrder
	frame.Size = size
	frame.BackgroundTransparency = 1
	frame:SetAttribute("WorldTeleportHeader", true)
	applyRevealUI(frame, revealName) -- equivalent call inferred; original call site unknown
	frame.Parent = parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createGalaxyHeader(parent, text: string, layoutOrder: number, revealName: string?)
	local clone = tPGalaxyHeader:Clone()
	clone.LayoutOrder = layoutOrder
	clone.Label.Text = text
	clone:SetAttribute("WorldTeleportHeader", true)
	applyRevealUI(clone, revealName) -- equivalent call inferred; original call site unknown
	clone.Parent = parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatWorldTitle(data)
	if data.name then
		return data.name
	end

	local galaxyWorldIndex = data.galaxyWorldIndex

	if data.entryLevel > 0 then
		return ("World %d - Lvl %d"):format(galaxyWorldIndex, data.entryLevel)
	end

	return ("World %d"):format(galaxyWorldIndex)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGateLevel(galaxyIndex: number)
	if v2 then
		return v2[galaxyIndex]
	end

	return ClientState:Get().Level
end

local function applyRowState(state, data, p: number)
	local title = state.Title
	local text = formatWorldTitle(data) -- equivalent call inferred; original call site unknown
	title.Text = text
	state.BackgroundColor3 = data.color

	if data.icon then
		state.Icon.Image = data.icon
	end

	if data.isCurrent then
		state.Current.Visible = true
		state.Teleport.Visible = false
		state.Locked.Visible = false
	elseif data.hasPlace and data.entryLevel <= p then
		state.Current.Visible = false
		state.Teleport.Visible = true
		state.Locked.Visible = false
	else
		state.Current.Visible = false
		state.Teleport.Visible = false
		state.Locked.Visible = true
	end
end

local function buildWorldRows(scrollingFrame)
	tPWorldRow.Visible = false
	clearRows(scrollingFrame)
	local hasAdminAccess = localPlayer:GetAttribute("HasAdminAccess") == true
	local count = 0

	for _, v3 in ipairs(WorldTeleportCatalog.getEntries()) do
		if v3.kind == "header" then
			if count > 0 then
				count += 1
				createHeaderPad(scrollingFrame, count, v3.revealName, uDim) -- equivalent call inferred; original call site unknown
			end

			count += 1
			createGalaxyHeader(scrollingFrame, v3.text, count, v3.revealName) -- equivalent call inferred; original call site unknown
		elseif v3.kind == "spacer" then
			count += 1
			createHeaderPad(scrollingFrame, count, nil, uDim2) -- equivalent call inferred; original call site unknown
		elseif not v3.devOnly or hasAdminAccess then
			local clone = tPWorldRow:Clone()
			clone.Name = not v3.index and "WorldRow_Teaser" or "WorldRow_" .. v3.index
			clone:SetAttribute("WorldTeleportRow", true)
			clone.Visible = true
			applyRevealUI(clone, v3.revealName) -- equivalent call inferred; original call site unknown
			count += 1
			clone.LayoutOrder = count
			clone.Parent = scrollingFrame
			local gateLevel = getGateLevel(v3.galaxyIndex) -- equivalent call inferred; original call site unknown
			applyRowState(clone, v3, gateLevel)

			if v3.hasPlace and not v3.isCurrent then
				local gateLevel2 = getGateLevel(v3.galaxyIndex) -- equivalent call inferred; original call site unknown

				if v3.entryLevel <= gateLevel2 then
					local v5 = v3.index
					clone.Teleport.MouseButton1Click:Connect(function()
						requestWorldTeleport:FireServer(v5)
						ClientState:CloseCurrentModal()
					end)
				end
			end

			if v3.index then
				v[v3.index] = clone
			end
		end
	end
end

function WorldTeleportUISystem:Populate()
	local tagged = getTagged("WorldTeleportModal")

	if tagged then
		buildWorldRows(tagged.ScrollingFrame)
	end
end

function WorldTeleportUISystem:Open(p)
	v2 = p
	local tagged = getTagged("WorldTeleportModal")

	if tagged then
		self:Populate()
		ClientState:ToggleModal(tagged, WorldTeleportUISystem)
	end
end

function WorldTeleportUISystem:Refresh()
	local tagged = getTagged("WorldTeleportModal")

	if ClientState.ActiveModal and ClientState.ActiveModal == tagged then
		self:Populate()
	end
end

return WorldTeleportUISystem