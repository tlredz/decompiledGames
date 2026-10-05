local parent = script.Parent.Parent
local _ = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
local RankIconsEmpty = require(game.ReplicatedStorage.RankIconsEmpty)
local leaderboard = parent.Leaderboard
local list = parent.Leaderboard.List
local trade = game.ReplicatedStorage.Trade
local LevelModule = require(game.ReplicatedStorage.Modules.LevelModule)
local v = {
	[0] = "",
	[1] = "I",
	[2] = "II",
	[3] = "III",
	[4] = "IV",
	[5] = "V",
	[6] = "VI",
	[7] = "VII",
	[8] = "VIII",
	[9] = "IX",
	[10] = "X"
}
local ContextActionService = game:GetService("ContextActionService")
local _ = script.Parent.Parent
local names = {}

local function SetSelectionGroup(p)
	for _, v2 in pairs(names) do
		local GuiService2 = game:GetService("GuiService")
		GuiService2:RemoveSelectionGroup(v2)
	end

	if p then
		local GuiService2 = game:GetService("GuiService")
		GuiService2:AddSelectionParent(p.Name, p)
		table.insert(names, p.Name)
	end
end

local getLevel = LevelModule.GetLevel

function UpdateLevel()
	local newXP = ProfileData.NewXP
	local xPBar = list.Parent.XP.XPBar
	xPBar.Parent.Level.Text = "Level " .. getLevel(newXP)
	local progressToNextLevel = LevelModule.GetProgressToNextLevel(newXP)
	xPBar.Size = UDim2.new(progressToNextLevel, xPBar.Size.X.Offset, xPBar.Size.Y.Scale, xPBar.Size.Y.Offset)
end

UpdateLevel()
local v2 = {}

local function GetSelfFrame()
	for _, child in pairs(list:GetChildren()) do
		if child.Container.PlayerName.Text == game.Players.LocalPlayer.Name then
			return child
		end
	end
end

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage3:WaitForChild("Database"):WaitForChild("Sync"))

function UpdateLeaderboard()
	local nameTags = Sync.NameTags
	local v3 = {}

	for _, player in pairs(game.Players:GetPlayers()) do
		if not v2[player.Name] then
			local level, v6, elite = game.ReplicatedStorage.Remotes.Extras.GetPlayerLevel:InvokeServer(player)
			v2[player.Name] = {}
			v2[player.Name].Level = level
			v2[player.Name].Prestige = v6 or 0
			v2[player.Name].Elite = elite
		end

		table.insert(v3, {
			Player = player,
			LD = v2[player.Name]
		})
	end

	table.sort(v3, function(a, b)
		if a.Elite and not b.Elite then
			return true
		end

		return not (b.Elite and not a.Elite) and a.LD.Prestige * 100 + a.LD.Level > b.LD.Prestige * 100 + b.LD.Level
	end)
	local name = false
	local GuiService2 = game:GetService("GuiService")

	if GuiService2.SelectedObject then
		local GuiService3 = game:GetService("GuiService")

		if GuiService3.SelectedObject.Parent == list then
			local GuiService4 = game:GetService("GuiService")
			name = GuiService4.SelectedObject.Name
		end
	end

	list:ClearAllChildren()

	for k, v4 in pairs(v3) do
		local player = v4.Player

		if player == nil then
			continue
		end

		local clone = script:WaitForChild("Player"):Clone()
		clone.Name = "Player" .. k
		clone.Position = UDim2.new(0, 0, (k - 1) * 0.05, 0)
		local v5 = v2[player.Name]
		clone.Container.RankIcon.Image = RankIconsEmpty[v5.Level]
		clone.Container.Prestige.Text = v[v5.Prestige]
		clone.Container.RankIcon.Level.Text = v5.Level
		local v6

		if v5.Elite then
			clone.Container.PlayerName.TextColor3 = Color3.new(
				0.9098039215686274,
				0.16470588235294117,
				0.16470588235294117
			)
			v6 = "[ELITE] "
		else
			v6 = ""
		end

		local objectValue = Instance.new("ObjectValue", clone)
		objectValue.Name = "PlayerObj"
		objectValue.Value = player
		clone.Container.PlayerName.Text = v6 .. player.Name
		local inputBeganConnection = nil

		if player ~= game.Players.LocalPlayer then
			local v7 = clone
			local v8 = player
			clone.Container.Button.SelectionGained:connect(function()
				if parent.Leaderboard.Trade.Request.Visible then
					return
				end

				v7.Container.Response.Visible = true
				local UserInputService = game:GetService("UserInputService")
				inputBeganConnection = UserInputService.InputBegan:connect(function(p)
					if p.KeyCode == Enum.KeyCode.DPadLeft and not parent.Chat.Control.Visible then
						local v9 = trade.SendRequest:InvokeServer(v8)
						print("IsBusy", v9)

						if not v9 then
							_G.ShowRequest(v8.Name, false)
							v7.Container.Response.Visible = false
						end
					elseif p.KeyCode == Enum.KeyCode.DPadRight and not parent.Chat.Control.Visible then
						_G.Examine(game.ReplicatedStorage.Remotes.Extras.GetFullInventory:InvokeServer(v8), v8.Name)
					end
				end)
			end)
			local v9 = clone
			clone.Container.Button.SelectionLost:connect(function()
				v9.Container.Response.Visible = false

				if inputBeganConnection then
					inputBeganConnection:disconnect()
				end
			end)
			local v10 = clone
			clone.Container.Response.Changed:connect(function()
				if v10.Container.Response.Visible == false and inputBeganConnection then
					inputBeganConnection:disconnect()
				end
			end)
		end

		local nameTag = nameTags[tostring(player.userId)]

		if nameTag then
			clone.Container.PlayerName.TextColor3 = nameTag
		end

		clone.Parent = list
	end

	if name then
		SetSelectionGroup(leaderboard)
		local GuiService3 = game:GetService("GuiService")
		GuiService3.SelectedObject = list:FindFirstChild(name) or GetSelfFrame() and GetSelfFrame().Container.Button or list.Player1.Container.Button
	end

	wait(2)
end

UpdateLeaderboard()
local v3 = "PlayerList"
GuiService.AutoSelectGuiEnabled = false

local function fn()
	if v3 == "PlayerList" then
		v3 = "Trade"
		leaderboard.Trade.Visible = true
		leaderboard.Title.Title.Text = "Trading"
		list.Position = UDim2.new(1, -5, 0.15, 20)
		SetSelectionGroup(leaderboard)
		local GuiService2 = game:GetService("GuiService")
		GuiService2.SelectedObject = GetSelfFrame() and GetSelfFrame().Container.Button or list.Player1.Container.Button
		local buttonB = Enum.KeyCode.ButtonB

		local function fn2()
			ContextActionService:UnbindAction("CloseLeaderTrade")
			v3 = "PlayerList"
			leaderboard.Trade.Visible = false
			list.Visible = true
			list.Position = UDim2.new(1, -5, 0.1, 10)
			SetSelectionGroup(nil)
			local GuiService3 = game:GetService("GuiService")
			GuiService3.SelectedObject = nil
		end

		ContextActionService:BindAction("CloseLeaderTrade", function(_, p)
			if p == Enum.UserInputState.Begin and not _G.PauseBinds then
				fn2()
			end
		end, false, buttonB)
	elseif v3 == "Trade" then
		ContextActionService:UnbindAction("CloseLeaderTrade")
		v3 = "Closed"
		SetSelectionGroup(nil)
		local GuiService2 = game:GetService("GuiService")
		GuiService2.SelectedObject = nil
		list.Visible = false
		leaderboard.Trade.Visible = false
		leaderboard.Title.Title.Text = "Player List"
	elseif v3 == "Closed" then
		v3 = "PlayerList"
		list.Visible = true
		list.Position = UDim2.new(1, -5, 0.1, 10)
	end
end

ContextActionService:BindAction("ShowLeaderboard", function(_, p)
	if p == Enum.UserInputState.Begin and not _G.PauseBinds then
		fn()
	end
end, false, Enum.KeyCode.ButtonSelect)
remotes:WaitForChild("Inventory"):WaitForChild("ProfileDataChanged").Event:Connect(function(p, _)
	if p == "NewXP" then
		UpdateLevel()
	end
end)