local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Teams = game:GetService("Teams")
local roundKillCount = Players.LocalPlayer.PlayerGui.RoundKillCount
local _ = roundKillCount.TagModeCurrentLeader
require3(ReplicatedStorage2.Shared.FastUtils)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local _ = v2.Client
local remoteEvent = v:RemoteEvent("TagMode/OnPlayerLeft")
local remoteEvent2 = v:RemoteEvent("TagMode/MatchEnded")
local TagModeController = {
	matchTrove = v3.new()
}

local function GetTeamByTeamId(teamId)
	for _, child in Teams:GetChildren() do
		if child:GetAttribute("TeamId") == teamId then
			return child
		end
	end
end

local function GetTeamAmount()
	local count = 0

	for _, child in Teams:GetChildren() do
		if child:GetAttribute("TeamId") then
			count += 1
		end
	end

	return count
end

function TagModeController:UpdateRoundKillCount()
	roundKillCount.Enabled = true
	self.matchTrove:Add(function()
		roundKillCount.Enabled = false
	end)
	roundKillCount.YourTeam.Visible = false
	self.matchTrove:Add(function()
		roundKillCount.YourTeam.Visible = true
	end)
	local children = workspace.Alive:GetChildren()
	local teamColorsByTeamId = {}

	for _, child in Teams:GetChildren() do
		if child:GetAttribute("TeamId") then
			teamColorsByTeamId[child:GetAttribute("TeamId")] = child.TeamColor
		end
	end

	print(teamColorsByTeamId, children)

	if not (teamColorsByTeamId and children) then
		return
	end

	for _, frame in roundKillCount.Grid:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v4 = false

		for _, v6 in children do
			if v6.Name ~= frame.Name then
				continue
			end

			v4 = true
			break
		end

		if not v4 then
			frame:Destroy()
		end
	end

	for _, v4 in children do
		self:CreatePlayerFrame(v4)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTeamsLeft()
		roundKillCount.TeamsLeft.Text = "TEAMS LEFT: " .. tostring((GetTeamAmount()))
	end

	updateTeamsLeft() -- equivalent call inferred; original call site unknown
	self.matchTrove:Connect(Teams.ChildRemoved, updateTeamsLeft)
end

function TagModeController:CreatePlayerFrame(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	local teamId = instance:GetAttribute("TeamId")
	local teamByTeamId = GetTeamByTeamId(teamId)

	if not (teamId and teamByTeamId) then
		return
	end

	local clone = roundKillCount.Grid:FindFirstChild(instance.Name)

	if not clone then
		clone = self.matchTrove:Clone(roundKillCount.Grid.UIGridLayout.Player_Tag)
		clone.Name = instance.Name
		clone.Content.PlayerIcon.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={playerFromCharacter.UserId}&w=150&h=150`
		clone.Dead.PlayerIcon.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={playerFromCharacter.UserId}&w=150&h=150`
		clone.Parent = roundKillCount.Grid
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTeam()
		teamId = instance:GetAttribute("TeamId")
		teamByTeamId = GetTeamByTeamId(teamId)

		if teamId and teamByTeamId then
			clone.Content.PlayerIcon.ImageColor3 = teamByTeamId.TeamColor.Color
			clone.LayoutOrder = teamId
		end
	end

	updateTeam() -- equivalent call inferred; original call site unknown
	self.matchTrove:Connect(instance:GetAttributeChangedSignal("TeamId"), updateTeam)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLeader()
		if instance:GetAttribute("Leader") then
			clone.Content.Crown.Visible = true
		else
			clone.Content.Crown.Visible = false
		end
	end

	updateLeader() -- equivalent call inferred; original call site unknown
	self.matchTrove:Connect(instance:GetAttributeChangedSignal("Leader"), updateLeader)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateKills()
		clone.Content.Score.Text = tostring(instance:GetAttribute("TotalKills") or 0)
	end

	updateKills() -- equivalent call inferred; original call site unknown
	self.matchTrove:Connect(instance:GetAttributeChangedSignal("TotalKills"), updateKills)
end

function TagModeController:Start()
	workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(function()
		workspace:GetAttribute("CurrentlySelectedMode")
	end)

	local function checkGameActive()
		if not workspace:GetAttribute("GameActive") then
			self.matchTrove:Clean()
			return
		end

		if workspace:GetAttribute("CurrentlySelectedMode") ~= "Tag" then
			self.matchTrove:Clean()
			return
		end

		self.matchTrove:Connect(workspace.Alive.ChildAdded, function(p)
			self:CreatePlayerFrame(p)
		end)
		self:UpdateRoundKillCount()
	end

	checkGameActive()
	workspace:GetAttributeChangedSignal("GameActive"):Connect(checkGameActive)
	remoteEvent2.OnClientEvent:Connect(function()
		roundKillCount.Enabled = false
		roundKillCount.YourTeam.Visible = true
		self.matchTrove:Clean()
	end)
	remoteEvent.OnClientEvent:Connect(function(childName)
		if not childName then
			return
		end

		local child = roundKillCount.Grid:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end)
end

return TagModeController