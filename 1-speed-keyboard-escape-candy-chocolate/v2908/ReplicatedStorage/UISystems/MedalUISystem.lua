local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local MedalQuest = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("MedalQuest"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local AuraRemotes = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("AuraRemotes"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local flag = false
local color = Color3.fromRGB(60, 200, 80)
local color2 = Color3.fromRGB(100, 100, 100)

local function getTagged(tag)
	for _, v in ipairs(CollectionService:GetTagged(tag)) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sanitizeName(name)
	if type(name) ~= "string" then
		return (tostring(name or ""))
	end

	local v = name:gsub("https?://[^%s<>&\"]+", ""):gsub("[Mm]edal%.tv", "Medal")
	return v:match("^%s*(.-)%s*$") or v
end

local function buildRequirementsText(quests)
	print(quests)

	if not quests or #quests == 0 then
		return "<font color='#aaaaaa'>No active Medal quest.</font>"
	end

	local v = quests[1]
	local v2 = {}

	if v.requirements then
		for i, requirement in ipairs(v.requirements) do
			local v3 = requirement.completed and "#00c850" or "#ff4444"
			local v4 = requirement.completed and "✓" or "✗"
			local v5 = MedalQuest.REQUIREMENTS and MedalQuest.REQUIREMENTS[i]

			if not v5 then
				local name = requirement.name

				if type(name) == "string" then
					local v6 = name:gsub("https?://[^%s<>&\"]+", ""):gsub("[Mm]edal%.tv", "Medal")
					v5 = v6:match("^%s*(.-)%s*$") or v6
				else
					v5 = tostring(name or "")
				end
			end

			local v6 = (requirement.completed or not (requirement.requiredCount > 1)) and "" or string.format(
				" <font color='#aaaaaa'>(%d/%d)</font>",
				requirement.completedCount,
				requirement.requiredCount
			)
			table.insert(v2, string.format("<font color='%s'><b>%s</b> %s</font>%s", v3, v4, v5, v6))
		end
	else
		local v3 = v.completed and "#00c850" or "#ff4444"
		local v4 = v.completed and "✓" or "✗"
		local v6 = sanitizeName(v.name) -- equivalent call inferred; original call site unknown
		table.insert(v2, string.format("<font color='%s'><b>%s</b> %s</font>", v3, v4, v6))
	end

	return table.concat(v2, "\n")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setClaimButton(p, completed)
	if not p then
		return
	end

	p.BackgroundColor3 = completed and color or color2
	p.Active = completed
end

local function refreshUI()
	local tagged = getTagged("MedalRequirements")
	local tagged2 = getTagged("MedalQuestClaimButton")
	local ownedAuras = ClientState:Get().OwnedAuras or {}

	if table.find(ownedAuras, "MedalAura") then
		if tagged then
			tagged.Text = "<font color='#00c850'><b>✓ Medal Aura already obtained!</b></font>"
		end

		setClaimButton(tagged2, false) -- equivalent call inferred; original call site unknown
	else
		if tagged then
			tagged.Text = "<font color='#aaaaaa'>Loading...</font>"
		end

		setClaimButton(tagged2, false) -- equivalent call inferred; original call site unknown
		local v = remotes.GetMedalQuestData:InvokeServer()

		if v then
			if v.hasMedalUser then
				local v2 = v.quests and v.quests[1]

				if v2 then
					if tagged then
						tagged.Text = buildRequirementsText(v.quests)
					end

					setClaimButton(tagged2, v2.completed) -- equivalent call inferred; original call site unknown
				elseif tagged then
					tagged.Text = "<font color='#aaaaaa'>No Medal quest found.</font>"
				end
			elseif tagged then
				tagged.Text = [[
<font color='#ffaa00'>Medal account not linked.
Visit Medal to connect your Roblox account.</font>]]
			end
		elseif tagged then
			tagged.Text = [[
<font color='#ff4444'>Unable to contact Medal.
Enable HTTP in Game Settings &gt; Security.</font>]]
		end
	end
end

local MedalUISystem = {}

function MedalUISystem.InitLogic(_)
	if flag then
		return
	end

	flag = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectClose(instance)
		if instance:GetAttribute("_MedalCloseConnected") then
			return
		end

		instance:SetAttribute("_MedalCloseConnected", true)
		instance.MouseButton1Click:Connect(function()
			local tagged = getTagged("MedalQuestModal")

			if tagged and ClientState.ActiveModal ~= tagged then
				tagged.Visible = false
			else
				ClientState:CloseCurrentModal()
			end
		end)
	end

	for _, v in ipairs(CollectionService:GetTagged("MedalQuestCloseButton")) do
		connectClose(v) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("MedalQuestCloseButton"):Connect(connectClose)

	local function connectClaim(instance)
		if instance:GetAttribute("_MedalClaimConnected") then
			return
		end

		instance:SetAttribute("_MedalClaimConnected", true)
		setClaimButton(instance, false) -- equivalent call inferred; original call site unknown
		instance.MouseButton1Click:Connect(function()
			if not instance.Active then
				return
			end

			setClaimButton(instance, false) -- equivalent call inferred; original call site unknown
			local v2, v3, v4 = AuraRemotes.BuyAura:request("MedalAura", "Medal"):await()

			if not v2 then
				v4 = v3
				v3 = false
			end

			if v3 then
				local ownedAuras = ClientState:Get().OwnedAuras or {}

				if not table.find(ownedAuras, "MedalAura") then
					table.insert(ownedAuras, "MedalAura")
					ClientState:Update({
						OwnedAuras = ownedAuras
					})
				end
			else
				warn("[MedalUISystem] Claim failed:", (tostring(v4)))
				local tagged = getTagged("MedalRequirements")

				if tagged then
					tagged.Text = string.format("<font color='#ff4444'>Claim failed: %s</font>", (tostring(v4)))
				end
			end

			refreshUI()
		end)
	end

	for _, v in ipairs(CollectionService:GetTagged("MedalQuestClaimButton")) do
		connectClaim(v)
	end

	CollectionService:GetInstanceAddedSignal("MedalQuestClaimButton"):Connect(connectClaim)
end

function MedalUISystem.Open(_)
	task.spawn(refreshUI)
end

function MedalUISystem.OnClose(_) end

return MedalUISystem