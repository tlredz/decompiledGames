local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Replion = require(ReplicatedStorage.Packages.Replion)
local RankData = require(ReplicatedStorage.Shared.RankData)
local RankedSeasonData = require(ReplicatedStorage.Shared.RankedSeasonData)
local Net = require(ReplicatedStorage.Packages.Net)
local PlayerUtility = require(ReplicatedStorage.Shared.PlayerUtility)
local v = nil
task.defer(function()
	v = Net:RemoteEvent("PlayerWantsRematch")
end)
local v2 = nil
local v3 = Replion.Client:WaitReplion("RankedMatch")
local v4 = Replion.Client:WaitReplion("Data")
local flag = false
local flag2 = false
local v5 = {
	Mobile = {
		Exit = parent:WaitForChild("MobileExitButton"),
		Play = parent:WaitForChild("MobilePlayButton")
	},
	Desktop = {
		Exit = parent:WaitForChild("ExitButton"),
		Play = parent:WaitForChild("PlayButton")
	}
}

local function initButtons()
	for _, v6 in { v5.Mobile.Exit, v5.Desktop.Exit, parent:WaitForChild("CloseButton") } do
		local v7 = v6
		v6.Activated:Connect(function()
			v7.Active = false
			ReplicatedStorage.Remotes.ReturnToLobby:FireServer()
		end)
	end

	for _, v6 in v5 do
		local play = v6.Play
		play.Activated:Connect(function()
			play.Active = false

			if v3:Get("Mode") == "Duo" then
				v:FireServer()
			else
				ReplicatedStorage.Remotes.ReturnToLobby:FireServer(nil, {
					AutoQueue = true,
					AutoQueueMode = v3:Get("Mode") == "Duel" and "Duel" or nil
				})
			end
		end)
	end

	v3:OnChange("Rematch", function(p)
		if not v2 then
			return
		end

		local v6 = p[`Rematch{v2}`]

		if v6 then
			local v7 = #v6

			for _, v8 in v5 do
				local play = v8.Play
				local container = play:FindFirstChild("Container")

				for _, image in container:GetChildren() do
					if image:IsA("ImageLabel") then
						image:Destroy()
					end
				end

				local text = play:FindFirstChild("Main"):FindFirstChild("Text")
				text.Text = `Ready Up ({math.clamp(v7, 0, 2)}/2)`

				for _, v9 in v6 do
					local clone = script.RematchTemplate:Clone()
					clone.Image = `rbxthumb://type=AvatarHeadShot&id={v9}&w=100&h=100`
					clone.Parent = container
				end
			end
		end
	end)
	localPlayer:GetAttributeChangedSignal("DuoTeleport"):Connect(function()
		local WAIT_INTERVAL = 1

		if localPlayer:GetAttribute("DuoTeleport") == true then
			for _, v6 in v5 do
				local text = v6.Play:FindFirstChild("Main"):FindFirstChild("Text")
				text.Text = 3
				task.wait(WAIT_INTERVAL)
				text.Text = 2
				task.wait(WAIT_INTERVAL)
				text.Text = 1
				task.wait(WAIT_INTERVAL)
				text.Text = 0
				task.wait(WAIT_INTERVAL)
			end
		end
	end)
end

initButtons()

-- equivalent calls inferred from this helper; original call sites unknown
local function setJumpButton(instance)
	instance:AddTag("MobileJumpButton")

	if flag then
		instance.Visible = false
		instance.Active = false
	end
end

local function checkTouchGui(instance)
	if not instance then
		return
	end

	local jumpButton = instance:FindFirstChild("JumpButton", true)

	if jumpButton then
		setJumpButton(jumpButton) -- equivalent call inferred; original call site unknown
	else
		instance.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "JumpButton" then
				setJumpButton(descendant) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

playerGui.ChildAdded:Connect(function(child)
	if child.Name == "TouchGui" then
		checkTouchGui(child)
	elseif child.Name == "Hotbar" then
		child:AddTag("DisableDuringVictoryScreen")
	end
end)
local hotbar = playerGui:FindFirstChild("Hotbar")

if hotbar then
	hotbar:AddTag("DisableDuringVictoryScreen")
end

checkTouchGui(playerGui:FindFirstChild("TouchGui"))
local flag3 = true

local function updateBar()
	local rankedType = RankedSeasonData.GetRankedType()
	local formatted = `Season{RankedSeasonData.GetCurrentSeason(rankedType)}`
	local v6 = (v4:Get({ "Elo", rankedType, formatted }) or {})[v3:Get("Mode")] or 0
	local rank = RankData.GetRank(v6)
	local nextRank = RankData.GetNextRank(v6)
	local v7

	if not nextRank then
		nextRank = rank
		v7 = 1
	end

	local minimumElo = nextRank.MinimumElo

	if v7 ~= 1 then
		local v8 = minimumElo - rank.MinimumElo
		v7 = (v6 - rank.MinimumElo) / v8
	end

	local progressBar = parent.ProgressBar
	progressBar.NextRank.Image = nextRank.Icon
	progressBar.NextRank.Title.Text = nextRank.Name
	progressBar.NextRank.Title.TextColor3 = nextRank.TextColor
	progressBar.CurrentRank.Image = rank.Icon
	progressBar.CurrentRank.Title.Text = rank.Name
	progressBar.CurrentRank.Title.TextColor3 = rank.TextColor
	progressBar.Elo.Text = `{v6}/{minimumElo}`
	local uDim = UDim2.new(v7, 0, 1, 0)

	if flag3 then
		progressBar.BarFrame.Bar.Size = uDim
		flag3 = false
	else
		TweenService:Create(progressBar.BarFrame.Bar, TweenInfo.new(0.25), {
			Size = uDim
		}):Play()
	end

	print("ELO UPDATED!")
	print("MY ELO:", v4:Get({ "Elo", rankedType, formatted }))
end

CollectionService:GetInstanceAddedSignal("DisableDuringVictoryScreen"):Connect(function(folder)
	if flag2 then
		folder.Enabled = false

		for _, button in folder:GetDescendants() do
			if button:IsA("GuiButton") then
				button.Visible = false
			end
		end
	end
end)
CollectionService:GetInstanceAddedSignal("MobileJumpButton"):Connect(function(p)
	if flag then
		p.Visible = false
		p.Active = false
	end
end)

local function getPlayerTeam()
	local placements = v3:Get("Placements")

	for k, placement in placements do
		if table.find(placement.Players, localPlayer.UserId) then
			return k
		end
	end

	return nil
end

local function updateVisibility()
	if not v3:Get("GameEnded") then
		parent.Enabled = false
		return
	end

	v2 = getPlayerTeam()
	flag2 = true

	if playerGui:FindFirstChild("Hotbar") then
		local UIStateController = require(ReplicatedStorage.Controllers.UI.UIStateController)
		UIStateController.HideHotbar:SetTag("VictoryScreen", true)
	end

	for _, folder in CollectionService:GetTagged("DisableDuringVictoryScreen") do
		folder.Enabled = false

		for _, button in folder:GetDescendants() do
			if button:IsA("GuiButton") then
				button.Visible = false
			end
		end
	end

	flag = true

	for _, v6 in CollectionService:GetTagged("MobileJumpButton") do
		v6.Visible = false
		v6.Active = false
	end

	local visible = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

	for _, v7 in v5.Mobile do
		v7.Visible = visible
	end

	for _, v7 in v5.Desktop do
		v7.Visible = not visible
	end

	if v3:Get("Mode") == "Duo" then
		local text = v5.Desktop.Play.Main:FindFirstChild("Text")
		text.Text = "Ready Up (0/2)"
		local text_2 = v5.Mobile.Play.Main:FindFirstChild("Text")
		text_2.Text = "Ready Up (0/2)"
	end

	local expect = v3:GetExpect("Placements")

	while not expect do
		expect = v3:Get("Placements")
		task.wait(0.1)
	end

	for i = 1, 3 do
		local v7 = expect[i]
		local child = parent:FindFirstChild("Player" .. i)

		if not child then
			continue
		end

		if v7 then
			local v8 = #v7.Players > 1
			local total = 0
			local v9 = v8 and "Team" or ""
			local v10 = v8 and "" or "Team"

			for k in v7.Players do
				total += v7.InitialElos[k] or 0
			end

			local v11 = math.round(total / #v7.Players)
			local playerPortrait1 = child:WaitForChild("PlayerPortrait1")
			playerPortrait1.Visible = false
			local playerPortrait2 = child:WaitForChild("PlayerPortrait2")
			playerPortrait2.Visible = false
			local text = ""

			for k, player in v7.Players do
				local v13, v14 = PlayerUtility:GetUsername(player):await()
				local child2 = child:FindFirstChild("PlayerPortrait" .. k)

				if child2 then
					child2.Visible = true
					local playerIcon = child2:WaitForChild("PlayerIcon")
					playerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={player}&w=150&h=150`
				end

				if k == 2 then
					text ..= " & "
				end

				text ..= not v13 and "[???]" or v14
			end

			local waitForChild = child:WaitForChild("Elo" .. v9)
			waitForChild.Text = "ELO " .. v11
			local waitForChild_2 = child:WaitForChild("Elo" .. v9)
			waitForChild_2.Visible = true
			local waitForChild_3 = child:WaitForChild("Elo" .. v10)
			waitForChild_3.Visible = false
			local waitForChild_4 = child.Header:WaitForChild("DisplayName" .. v9)
			waitForChild_4.Text = text
			local waitForChild_5 = child.Header:WaitForChild("DisplayName" .. v9)
			waitForChild_5.Visible = true
			local waitForChild_6 = child.Header:WaitForChild("DisplayName" .. v10)
			waitForChild_6.Visible = false
			local rankIcon = child:WaitForChild("RankIcon")
			rankIcon.Image = RankData.GetRank(v11).Icon
		else
			child.Visible = false
		end
	end

	if expect and expect[1] then
		for _, _ in expect[1] do

		end

		for _, _ in expect[1].Players do

		end
	end

	local v7 = expect and expect[1]
	local visible2 = v7 and table.find(v7.Players, localPlayer.UserId) ~= nil
	parent.WinTitle.Visible = visible2
	parent.LossTitle.Visible = not visible2
	local canceled = v3:Get("Canceled")
	parent.CanceledTitle.Visible = canceled == true

	if canceled then
		parent.WinTitle.Visible = false
		parent.LossTitle.Visible = false
		local child = parent:FindFirstChild("Player" .. 1)

		if child then
			child.Visible = false
		end

		local child2 = parent:FindFirstChild("Player" .. 2)

		if child2 then
			child2.Visible = false
		end

		local child3 = parent:FindFirstChild("Player" .. 3)

		if child3 then
			child3.Visible = false
		end
	end

	updateBar()
	parent.Enabled = true
end

v4:OnDescendantChange("Elo", updateBar)
v3:OnChange("GameEnded", updateVisibility)
v3:OnChange("Canceled", updateVisibility)
updateVisibility()