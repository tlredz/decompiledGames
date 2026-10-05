local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local Network = require(ReplicatedStorage.SharedUtils.Network)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local VoteIcon = require(ReplicatedStorage.SharedUtils.VoteIcon)
local GuiAnimations = require(ReplicatedStorage.Modules.UI.GuiAnimations)
local teleport = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Teleport")
local transitionEvent = ReplicatedStorage:WaitForChild("TransitionEvent")
local bottomFrame = parent:WaitForChild("BottomFrame")
local leaveLobby = bottomFrame:WaitForChild("LeaveLobby")
local matchmakeSolo = bottomFrame:WaitForChild("MatchmakeSolo")
local matchmakeGroup = bottomFrame:WaitForChild("MatchmakeGroup")
local bottomText = matchmakeSolo:WaitForChild("BottomText")
local bottomText2 = matchmakeGroup:WaitForChild("BottomText")
local party = matchmakeGroup:WaitForChild("Party")
local template = party:WaitForChild("Template")
template.Visible = false
GuiAnimations.SetupButtonAnimationsSimple(leaveLobby)
GuiAnimations.SetupButtonAnimationsSimple(matchmakeSolo)
GuiAnimations.SetupButtonAnimationsSimple(matchmakeGroup)
local color = Color3.new(0.2, 0.2, 0.2)
local color2 = Color3.fromRGB(0, 71, 11)
local color3 = Color3.fromRGB(0, 0, 0)
local v = {
	[leaveLobby] = leaveLobby:WaitForChild("Display"):WaitForChild("Background"),
	[matchmakeSolo] = matchmakeSolo:WaitForChild("Display"):WaitForChild("Background"),
	[matchmakeGroup] = matchmakeGroup:WaitForChild("Display"):WaitForChild("Background")
}
local v2 = v[matchmakeGroup]
local backgroundColor3s = {}

for k, v3 in v do
	backgroundColor3s[k] = v3.BackgroundColor3
end

local backgroundTransparency = v2.BackgroundTransparency
local tween = TweenService:Create(v2, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	BackgroundTransparency = 0,
	BackgroundColor3 = Color3.fromRGB(0, 141, 21)
})
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function playGroupGlow()
	if flag then
		return
	end

	flag = true
	tween:Cancel()
	v2.BackgroundTransparency = backgroundTransparency
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGroupGlow()
	if not flag then
		return
	end

	flag = false
	tween:Cancel()
	v2.BackgroundTransparency = backgroundTransparency
end

local flag2 = false
local flag3 = false
local v3 = false
local v4 = false
local flag4 = false
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function setButtonDisabled(p, p2)
	p.Interactable = not p2
	v[p].BackgroundColor3 = p2 and color or backgroundColor3s[p]
end

local function refreshButtons()
	if flag4 then
		local v5 = flag3 and matchmakeGroup or matchmakeSolo
		leaveLobby.Visible = leaveLobby == v5
		matchmakeSolo.Visible = false
		matchmakeGroup.Visible = matchmakeGroup == v5
		setButtonDisabled(v5, true) -- equivalent call inferred; original call site unknown

		if v3 or flag3 then
			matchmakeGroup.TextLabel.Text = "Matchmaking..."
			v2.BackgroundColor3 = color2
			playGroupGlow() -- equivalent call inferred; original call site unknown
		else
			matchmakeGroup.TextLabel.Text = "Join Matchmaking"
			v2.BackgroundColor3 = color3
			stopGroupGlow() -- equivalent call inferred; original call site unknown
		end
	else
		leaveLobby.Visible = true
		matchmakeGroup.Visible = true

		if v4 or flag2 or flag3 then
			setButtonDisabled(leaveLobby, true) -- equivalent call inferred; original call site unknown
			setButtonDisabled(matchmakeSolo, true) -- equivalent call inferred; original call site unknown
			setButtonDisabled(matchmakeGroup, true) -- equivalent call inferred; original call site unknown
		elseif v3 then
			setButtonDisabled(leaveLobby, true) -- equivalent call inferred; original call site unknown
			setButtonDisabled(matchmakeSolo, true) -- equivalent call inferred; original call site unknown
			setButtonDisabled(matchmakeGroup, false) -- equivalent call inferred; original call site unknown
		else
			setButtonDisabled(leaveLobby, false) -- equivalent call inferred; original call site unknown
			setButtonDisabled(matchmakeSolo, false) -- equivalent call inferred; original call site unknown
			setButtonDisabled(matchmakeGroup, false) -- equivalent call inferred; original call site unknown
		end

		if v3 or flag3 then
			matchmakeGroup.TextLabel.Text = "Matchmaking..."
			v2.BackgroundColor3 = color2
			playGroupGlow() -- equivalent call inferred; original call site unknown
		else
			matchmakeGroup.TextLabel.Text = "Join Matchmaking"
			v2.BackgroundColor3 = color3
			stopGroupGlow() -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatStatus(p, p2, p3)
	if p3 and p3 > 0 then
		return string.format("%d/%d (%ds)", p, p2, p3)
	end

	return string.format("%d/%d", p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function searchTarget()
	if flag3 then
		return bottomText2
	end

	if flag2 then
		return bottomText
	end

	return nil
end

local function stopSearchCountdown()
	count += 1
end

local function startSearchCountdown(p, p2, p3, p4)
	count += 1
	local v5 = count
	local text = formatStatus(p2, p3, p4) -- equivalent call inferred; original call site unknown
	p.Text = text

	if p4 and p4 > 0 then
		task.spawn(function()
			local v7 = p4

			while v7 > 0 do
				task.wait(1)

				if v5 ~= count then
					break
				end

				v7 -= 1
				local target = searchTarget() -- equivalent call inferred; original call site unknown

				if target ~= p then
					continue
				end

				local v9 = p
				local text2 = formatStatus(p2, p3, v7) -- equivalent call inferred; original call site unknown
				v9.Text = text2
			end
		end)
	end
end

local function clearPartyIcons()
	for _, frame in ipairs(party:GetChildren()) do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end
end

local function renderParty(members)
	clearPartyIcons()

	for _, v5 in ipairs(members) do
		local clone = template:Clone()
		clone.Name = "PartyMember"
		clone.Visible = true

		if v5.Toon then
			local v6 = v5
			local v7 = clone
			pcall(function()
				local tower = TowerLUT:GetTower(v6.Toon)

				if tower then
					local module = require(tower)
					v7.Holder.ItemImage.Image = module.VoteIcon
					VoteIcon.Apply(v7.Holder.ItemImage, module)
				end
			end)
		end

		clone.Parent = party
	end
end

leaveLobby.Activated:Connect(function()
	if not leaveLobby.Interactable then
		return
	end

	v4 = true
	refreshButtons()
	teleport:FireServer()
	task.delay(8, function()
		v4 = false
		refreshButtons()
	end)
end)
local v5 = false
matchmakeSolo.Activated:Connect(function()
	if not matchmakeSolo.Interactable or v5 then
		return
	end

	v5 = true
	flag2 = true
	bottomText.Text = "Searching..."
	refreshButtons()
	Network:Post("SpectateMatchmakeSolo")
	task.delay(1, function()
		v5 = false
	end)
end)
local v6 = false
matchmakeGroup.Activated:Connect(function()
	if not matchmakeGroup.Interactable or v6 then
		return
	end

	v6 = true
	Network:Post("SpectateMatchmakeGroupToggle")
	task.delay(0.4, function()
		v6 = false
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function resetMatchmakingState()
	count += 1
	flag2 = false
	flag3 = false
	flag4 = false
	bottomText.Text = ""
	bottomText2.Text = ""
	refreshButtons()
end

Network:AddAction("SpectateMatchmakeReject", function()
	resetMatchmakingState() -- equivalent call inferred; original call site unknown
end)
transitionEvent.OnClientEvent:Connect(function(p)
	if p then
		resetMatchmakingState() -- equivalent call inferred; original call site unknown
	end
end)
Network:AddAction("SpectateParty", function(data)
	if typeof(data) ~= "table" then
		return
	end

	local members = data.Members or {}
	local maxPlayers = data.MaxPlayers or 8
	local v7 = false

	for _, member in ipairs(members) do
		if member.UserId ~= localPlayer.UserId then
			continue
		end

		v7 = true
		break
	end

	if data.Locked and v7 then
		flag3 = true
		flag4 = true
	end

	v3 = v7 and not data.Locked
	renderParty(members)

	if data.Active and not data.Locked then
		local v9 = bottomText2
		local text = formatStatus(#members, maxPlayers, data.TimeLeft) -- equivalent call inferred; original call site unknown
		v9.Text = text
	elseif not flag3 then
		bottomText2.Text = ""
	end

	refreshButtons()
end)
Network:AddAction("MatchmakingUpdate", function(data)
	if data == nil then
		resetMatchmakingState() -- equivalent call inferred; original call site unknown
	else
		if typeof(data) ~= "table" then
			return
		end

		if flag2 and not flag4 then
			flag4 = true
			refreshButtons()
		end

		local target = searchTarget() -- equivalent call inferred; original call site unknown

		if not target then
			return
		end

		if data.UserIDs then
			local count2 = #data.UserIDs
			local maxPlayers = data.MaxPlayers or 8
			local countdown = data.Countdown
			count += 1
			local v8 = count
			local text = formatStatus(count2, maxPlayers, countdown) -- equivalent call inferred; original call site unknown
			target.Text = text

			if countdown and countdown > 0 then
				task.spawn(function()
					local v10 = countdown

					while v10 > 0 do
						task.wait(1)

						if v8 ~= count then
							break
						end

						v10 -= 1
						local target2 = searchTarget() -- equivalent call inferred; original call site unknown

						if target2 ~= target then
							continue
						end

						local v12 = target
						local text2 = formatStatus(count2, maxPlayers, v10) -- equivalent call inferred; original call site unknown
						v12.Text = text2
					end
				end)
			end
		else
			count += 1
			target.Text = "Searching..."
		end
	end
end)
refreshButtons()