local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateUI = remotes:WaitForChild("UpdateUI")
local markNewBadgeGroupSeen = remotes:WaitForChild("MarkNewBadgeGroupSeen")
local NewBadgeSystem = {
	Mode = table.freeze({
		Leaf = "Leaf",
		Summary = "Summary"
	}),
	Trigger = table.freeze({
		ScrollIntoView = "ScrollIntoView",
		OnOpen = "OnOpen",
		OnClick = "OnClick"
	})
}
local mode = NewBadgeSystem.Mode
local trigger = NewBadgeSystem.Trigger
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local heartbeatConnection = nil

local function isEffectivelyVisible(parent)
	while parent and parent ~= playerGui do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent == playerGui
end

local function findAncestorOfType(instance, className)
	local parent = instance.Parent

	while parent and parent ~= playerGui do
		if parent:IsA(className) then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function overlaps(p, p2, p3, p4)
	return p.X + p2.X > p3.X and p.X < p3.X + p4.X and p.Y + p2.Y > p3.Y and p.Y < p3.Y + p4.Y
end

local function markSeen(p)
	v[p] = true
end

local v5 = {
	[trigger.OnOpen] = {
		Poll = function(p)
			return (isEffectivelyVisible(p.instance))
		end
	},
	[trigger.ScrollIntoView] = {
		Setup = function(state)
			state.scrollingFrame = findAncestorOfType(state.instance, "ScrollingFrame")

			if not state.scrollingFrame then
				warn("[NewBadgeSystem] ScrollIntoView badge has no ancestor ScrollingFrame: " .. state.instance:GetFullName())
			end
		end,
		Poll = function(p)
			local v6

			if p.scrollingFrame == nil then
				return false
			else
				v6 = isEffectivelyVisible(p.instance)

				if v6 then
					return (overlaps(
						p.instance.AbsolutePosition,
						p.instance.AbsoluteSize,
						p.scrollingFrame.AbsolutePosition,
						p.scrollingFrame.AbsoluteSize
					))
				end
			end

			return v6
		end
	},
	[trigger.OnClick] = {
		Setup = function(p)
			local instance = p.instance:IsA("GuiButton") and p.instance or findAncestorOfType(p.instance, "GuiButton")

			if instance then
				instance.Activated:Connect(function()
					local instance2 = p.instance
					v[instance2] = true
				end)
			else
				warn("[NewBadgeSystem] OnClick badge has no ancestor GuiButton: " .. p.instance:GetFullName())
			end
		end
	}
}

local function hideGroupImmediately(p)
	for _, v6 in v2 do
		if v6.group ~= p then
			continue
		end

		local instance = v6.instance
		v[instance] = true
		v6.instance.Visible = false
	end

	for _, v6 in v3 do
		if v6.group == p then
			v6.instance.Visible = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPersistedGroup(seenNewBadgeGroup)
	if not v4[seenNewBadgeGroup] then
		v4[seenNewBadgeGroup] = true
		hideGroupImmediately(seenNewBadgeGroup)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function persistSeenGroup(group)
	if not v4[group] then
		v4[group] = true
		markNewBadgeGroupSeen:FireServer(group)
	end
end

updateUI.OnClientEvent:Connect(function(p)
	if p and p.SeenNewBadgeGroups then
		for _, seenNewBadgeGroup in p.SeenNewBadgeGroups do
			applyPersistedGroup(seenNewBadgeGroup) -- equivalent call inferred; original call site unknown
		end
	end
end)

local function isGroupFullySeen(group)
	local v6 = true
	local v7 = false

	for _, v8 in v2 do
		if v8.group ~= group then
			continue
		end

		v7 = true

		if not v[v8.instance] then
			v6 = false
		end
	end

	return v6 and v7, v7
end

local function commitSeenBadges()
	for _, v6 in v2 do
		if v[v6.instance] then
			v6.instance.Visible = false
		end
	end

	for _, v6 in v3 do
		local groupFullySeen, v7 = isGroupFullySeen(v6.group)

		if v7 then
			if groupFullySeen then
				v6.instance.Visible = false
				persistSeenGroup(v6.group) -- equivalent call inferred; original call site unknown
			end
		else
			warn(("[NewBadgeSystem] Summary badge's NewBadgeGroup '%s' matches no Leaf badge - check for a typo/case mismatch: %s"):format(
				tostring(v6.group),
				v6.instance:GetFullName()
			))
		end
	end
end

local function pollLeafBadges()
	for _, v6 in v2 do
		if v[v6.instance] then
			continue
		end

		local poll = v5[v6.trigger].Poll

		if not (poll and poll(v6)) then
			continue
		end

		local instance = v6.instance
		v[instance] = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startPolling()
	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(pollLeafBadges)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPolling()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function registerLeafBadge(instance, newBadgeGroup)
	local newBadgeTrigger = instance:GetAttribute("NewBadgeTrigger") or trigger.OnOpen
	local v6 = v5[newBadgeTrigger]

	if not v6 then
		warn(("[NewBadgeSystem] Unknown NewBadgeTrigger '%s': %s"):format(
			tostring(newBadgeTrigger),
			instance:GetFullName()
		))
		return
	end

	local v7 = {
		instance = instance,
		group = newBadgeGroup,
		trigger = newBadgeTrigger,
		scrollingFrame = nil
	}
	table.insert(v2, v7)

	if v6.Setup then
		v6.Setup(v7)
	end

	if ClientState.ActiveModal and v6.Poll and v6.Poll(v7) then
		v[instance] = true
	end
end

local function registerBadge(instance)
	if not instance:IsDescendantOf(playerGui) then
		return
	end

	local newBadgeGroup = instance:GetAttribute("NewBadgeGroup")

	if not newBadgeGroup then
		warn("[NewBadgeSystem] NewBadge is missing NewBadgeGroup: " .. instance:GetFullName())
		return
	end

	if instance:GetAttribute("NewBadgeMode") == mode.Summary then
		table.insert(v3, {
			instance = instance,
			group = newBadgeGroup
		})
	else
		registerLeafBadge(instance, newBadgeGroup)
	end

	if v4[newBadgeGroup] then
		v[instance] = true
		instance.Visible = false
	end
end

for _, v6 in CollectionService:GetTagged("NewBadge") do
	registerBadge(v6)
end

CollectionService:GetInstanceAddedSignal("NewBadge"):Connect(registerBadge)
ClientState:RegisterModalListener(function(p)
	if p then
		startPolling() -- equivalent call inferred; original call site unknown
		pollLeafBadges()
	else
		stopPolling() -- equivalent call inferred; original call site unknown
		commitSeenBadges()
	end
end)
return NewBadgeSystem