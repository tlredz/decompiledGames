local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("RunService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ServerInfo)
local localPlayer = Players.LocalPlayer
local rankedLeaderboard = localPlayer.PlayerGui.RankedLeaderboard
local list = rankedLeaderboard.Main.List
local template = list.ScrollingFrame.UIListLayout.Template
local v6 = {}
local v7 = {}
local RankedLeaderboardController = {}

function RankedLeaderboardController:AddPlayer(player)
	if v6[player] then
		return
	end

	local maid = v2.new()
	v6[player] = maid
	local clone = maid:Clone(template)
	clone.Name = player.UserId
	clone.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	clone.PlayerName.Text = player.DisplayName
	clone.Parent = list.ScrollingFrame

	local function updateTeam()
		if not clone.Parent then
			return
		end

		local color = player.TeamColor.Color
		local team = player.Team

		if not team or team.Name == "Playing" or team.Name == "Waiting" then
			if player == localPlayer then
				color = Color3.fromRGB(255, 220, 60)
			else
				color = Color3.fromRGB(74, 131, 253)
			end
		end

		clone.ImageColor3 = color
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePing()
		if not clone.Parent then
			return
		end

		local ping = player:GetAttribute("Ping")
		clone.PingAmount.Text = not ping and 999 or math.round(ping / 2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAbility()
		local currentlyEquippedAbility = player:GetAttribute("CurrentlyEquippedAbility")

		if currentlyEquippedAbility and clone.Parent then
			clone.AbillityImage.Vector.Image = v4.Icons:GetAbilityIcon(currentlyEquippedAbility)
		end
	end

	updatePing() -- equivalent call inferred; original call site unknown
	maid:Add(player:GetAttributeChangedSignal("Ping"):Connect(updatePing))
	updateTeam()
	maid:Add(player:GetPropertyChangedSignal("TeamColor"):Connect(updateTeam))
	updateAbility() -- equivalent call inferred; original call site unknown
	maid:Add(player:GetAttributeChangedSignal("CurrentlyEquippedAbility"):Connect(updateAbility))
	local flag = false

	local function trackCharacter(character)
		character.AncestryChanged:Connect(function()
			if character:IsDescendantOf(workspace.Dead) then
				local v8 = v7[player.UserId]
				local deaths = v8 and v8.deaths or 0

				if flag then
					deaths += 1
				end

				clone.DeathAmount.Text = deaths
				flag = false
			elseif character:IsDescendantOf(workspace.Alive) then
				flag = true
			end
		end)
		character:GetAttributeChangedSignal("KillsInRound"):Connect(function()
			local killsInRound = character:GetAttribute("KillsInRound") or 0
			local v8 = v7[player.UserId]

			if v8 then
				killsInRound += v8.kills
			end

			clone.LayoutOrder = -killsInRound
			clone.KillAmount.Text = killsInRound
		end)
	end

	maid:Add(player.CharacterAdded:Connect(trackCharacter))

	if player.Character then
		trackCharacter(player.Character)
	end
end

function RankedLeaderboardController:Start()
	if not v5.isRankedMatchServer() then
		return
	end

	v3.Client:AwaitReplion("RankedMatch", function(object2)
		object2:OnChange("Placements", function(items)
			for _, item in items do
				for _, childName in item.Players do
					local child = list.ScrollingFrame:FindFirstChild(childName)

					if not child then
						continue
					end

					local v8 = item.Kills[childName] or 0
					local v9 = item.Deaths[childName] or 0
					local v10 = v7[childName]

					if v10 then
						v10.kills = v8
						v10.deaths = v9
					else
						v7[childName] = {
							kills = v8,
							deaths = v9
						}
					end

					child.KillAmount.Text = v8
					child.DeathAmount.Text = v9
					child.LayoutOrder = -v8
				end
			end
		end)
	end)

	for _, v8 in Players:GetPlayers() do
		self:AddPlayer(v8)
	end

	Players.PlayerAdded:Connect(function(player)
		self:AddPlayer(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local v8 = v6[player]

		if v8 then
			v8:Destroy()
			v6[player] = nil
		end
	end)
	v.InputBegan:Connect(function(input)
		if input.KeyCode ~= Enum.KeyCode.Tab then
			return
		end

		rankedLeaderboard.Enabled = true
	end)
	v.InputEnded:Connect(function(input)
		if input.KeyCode ~= Enum.KeyCode.Tab then
			return
		end

		rankedLeaderboard.Enabled = false
	end)
end

return RankedLeaderboardController