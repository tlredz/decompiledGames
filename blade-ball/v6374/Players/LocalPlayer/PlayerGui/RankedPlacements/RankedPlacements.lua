game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local StarterGui = game:GetService("StarterGui")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local localPlayer = Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
local PlayerUtility = require(ReplicatedStorage.Shared.PlayerUtility)
local RankData = require(ReplicatedStorage.Shared.RankData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local v = Replion.Client:WaitReplion("RankedMatch")
Replion.Client:WaitReplion("Data")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local parent = script.Parent
local main = parent:WaitForChild("Main")
local scrollingFrame = main:WaitForChild("ScrollingFrame")
local template = scrollingFrame:WaitForChild("UIListLayout"):WaitForChild("Template")
local round = main:WaitForChild("Round")
local v2 = {
	{
		Image = "rbxassetid://14920938960",
		ImageColor = Color3.fromRGB(255, 255, 255),
		TextColor = Color3.fromRGB(79, 41, 10)
	},
	{
		Image = "rbxassetid://14921037945",
		ImageColor = Color3.fromRGB(255, 255, 255),
		TextColor = Color3.fromRGB(44, 44, 44)
	},
	{
		Image = "rbxassetid://14920938960",
		ImageColor = Color3.fromRGB(227, 152, 102),
		TextColor = Color3.fromRGB(83, 37, 0)
	},
	{
		Image = "rbxassetid://14921037945",
		ImageColor = Color3.fromRGB(158, 221, 255),
		TextColor = Color3.fromRGB(14, 19, 65)
	}
}

local function updateUI()
	local header = ServerInfo:GetRankType() == "NoAbility" and main:FindFirstChild("Header")

	if header then
		header.Text = "Match Placements (No Ability)"
	end

	round.Text = `Round {v:Get("RoundNum") or 100}/{v:Get("TotalRounds") or 100}`
	local v3 = {}

	for k, v4 in v:Get("Placements") or {} do
		table.sort(v4.Players, function(a, b)
			return tonumber(a) > tonumber(b)
		end)
		local name = ""

		for _, player in v4.Players do
			name ..= tostring(player)
		end

		v3[name] = true
		local player = v4.Players[1]
		local clone = scrollingFrame:FindFirstChild(name)

		if not clone then
			clone = template:Clone()
			clone.Name = name
			local content = clone.Content
			local team = content.Team
			team.PlayerPortrait1.ImageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={v4.Players[1]}&w=150&h=150`
			local v6 = player
			content.Add.Activated:Connect(function()
				local playerByUserId = Players:GetPlayerByUserId(v6)

				if not playerByUserId then
					return
				end

				local success, result = pcall(function()
					StarterGui:SetCore("PromptSendFriendRequest", playerByUserId)
				end)
			end)

			if #v4.Players > 1 then
				team.PlayerPortrait2.ImageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={v4.Players[2]}&w=150&h=150`
				content.Add.Visible = false
			else
				team.PlayerPortrait2.Visible = false
			end

			local text = ""

			for k2, player2 in v4.Players do
				if k2 > 1 then
					text ..= " & "
				end

				local _, v8 = PlayerUtility:GetUsername(player2):await()

				if v8 then
					text ..= v8
				end
			end

			team.Username.Text = text
			local total = 0

			for _, initialElo in v4.InitialElos do
				total += initialElo
			end

			local halfTotal = total / 2
			content.RankIcon.Image = RankData.GetRank(halfTotal).Icon
			clone.Parent = scrollingFrame
		end

		clone.LayoutOrder = k
		local content = clone.Content
		content.Points.Text = v4.Score
		local add = content.Add
		add.Visible = tonumber(player) ~= localPlayer.UserId and k <= 3 and #v4.Players == 1
		local placementsSorted = v:Get("PlacementsSorted")
		local v7 = not placementsSorted and 4 or k
		local v9 = v2[math.min(v7, #v2)]
		content.Placement.Image = v9.Image
		content.Placement.ImageColor3 = v9.ImageColor
		content.Placement.TextLabel.TextColor3 = v9.TextColor
		content.Placement.TextLabel.Text = not placementsSorted and "-" or v7
	end

	for _, frame in scrollingFrame:GetChildren() do
		if not frame:IsA("Frame") or v3[frame.Name] then
			continue
		end

		frame:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleUI(enabled: boolean)
	parent.Enabled = enabled

	if enabled and not main.Visible then
		updateUI()
	end

	main.Visible = true
end

main:WaitForChild("CloseButton").Activated:Connect(function()
	toggleUI(false) -- equivalent call inferred; original call site unknown
end)
remotes:WaitForChild("ShowRankedPlacements").OnClientEvent:Connect(function(flag: boolean?)
	if flag == false then
		parent.Enabled = false
	else
		parent.Enabled = true

		if not main.Visible then
			updateUI()
		end
	end

	main.Visible = true
end)
v:OnChange("Placements", updateUI)
v:OnChange("RoundNum", updateUI)
v:OnChange("PlacementsSorted", updateUI)
updateUI()