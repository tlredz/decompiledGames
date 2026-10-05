local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RankIcon"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local duelHistoryRageQuitSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelHistoryRageQuitSlot")
local duelHistoryHeadshotSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelHistoryHeadshotSlot")
local duelHistoryDuelerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelHistoryDuelerSlot")
local duelHistoryEmptySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelHistoryEmptySlot")
local duelHistorySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelHistorySlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._duel_history_slots = {}
	self._generate_hash = 0
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	task.spawn(self._Generate, self)
end

function object:_SetupELOEventLog(p, visible)
	p.Visible = visible

	if not visible then
		return
	end

	local v = RankIcon.new(visible.CurrentELO, nil, visible.CurrentLeaderboardRanking or 1e999)
	v:SetLabelFromELOEvent(visible.ELOIncrement, visible.CurrentELO, visible.DuelsPlayed)
	v:SetParent(p)
end

function object:_Generate()
	for _, _duel_history_slot in pairs(self._duel_history_slots) do
		_duel_history_slot:Destroy()
	end

	self._duel_history_slots = {}
	self._generate_hash += 1
	local _generate_hash = self._generate_hash
	local v = {}

	for _, v2 in pairs(PlayerDataController:Get("LoggedELOEvents")) do
		if v2.LogID then
			v[v2.LogID] = v2
		end
	end

	for k, v2 in pairs(PlayerDataController:Get("DuelHistory")) do
		if _generate_hash ~= self._generate_hash then
			return
		end

		local v3 = v[v2.LogID]

		if v2.IsRageQuit then
			local clone = duelHistoryRageQuitSlot:Clone()
			clone.LayoutOrder = k
			clone.Parent = self.Container
			table.insert(self._duel_history_slots, clone)
			self:_SetupELOEventLog(clone.RankContainer, v3)
			wait(0.03)
		else
			local flag = false

			for _, dueler in pairs(v2.Duelers) do
				if dueler.UserID ~= Players.LocalPlayer.UserId then
					continue
				end

				flag = true
				break
			end

			if flag then
				local clone = duelHistorySlot:Clone()
				clone.LayoutOrder = k
				clone.Map.Image = not (v2.Map and DuelLibrary.Maps[v2.Map]) and "" or DuelLibrary.Maps[v2.Map].Image or ""
				clone.Container.QueueName.Text = v2.QueueName and DuelLibrary.MatchmakingQueues[v2.QueueName] and DuelLibrary.MatchmakingQueues[v2.QueueName].DisplayName or v2.QueueName or ""
				clone.Container.Score.Text = ""
				clone.Container.EDATitle.Visible = false
				clone.Container.EDA.Visible = false
				self:_SetupELOEventLog(clone.Container.RankContainer, v3)

				for i = 1, v2.NumTeams do
					clone.Container.Score.Text ..= v2.Scores[i] .. (i == v2.NumTeams and "" or " • ")
				end

				local isRankedQueue = SeasonLibrary:IsRankedQueue(v2.QueueName)
				local clonesByUserID = {}

				for k2, dueler in pairs(v2.Duelers) do
					local teamColor = DuelLibrary:GetTeamColor(dueler.TeamIndex and DuelLibrary.Teams[dueler.TeamIndex] and DuelLibrary.Teams[dueler.TeamIndex].TeamID)

					if dueler.UserID == Players.LocalPlayer.UserId then
						local v5 = v2.WinningTeamIndex and v2.WinningTeamIndex == dueler.TeamIndex
						clone.Container.Background.ImageColor3 = v5 and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(
							255,
							50,
							50
						)
						clone.Container.Title.Text = v5 and "VICTORY" or "DEFEAT"
						clone.Container.EDA.Text = (dueler.Eliminations or "?") .. " • " .. (dueler.Deaths or "?") .. " • " .. (dueler.Assists or "?")
						clone.Container.EDA.Visible = not clone.Container.RankContainer.Visible
						clone.Container.EDATitle.Visible = clone.Container.EDA.Visible
					end

					local clone2 = duelHistoryHeadshotSlot:Clone()
					clone2.Picture.Image = not dueler.UserID and "rbxassetid://18623501726" or string.format(
						CONSTANTS.HEADSHOT_IMAGE,
						dueler.UserID
					)
					clone2.Picture.ImageColor3 = not dueler.UserID and Color3.fromRGB(0, 0, 0) or clone2.Picture.ImageColor3
					clone2.Picture.ImageTransparency = not dueler.UserID and 0.5 or clone2.Picture.ImageTransparency
					clone2.Picture.Size = not dueler.UserID and UDim2.new(0.75, 0, 0.75, 0) or clone2.Picture.Size
					clone2.Background.BackgroundColor3 = teamColor
					clone2.LayoutOrder = dueler.TeamIndex * 1000 + k2
					clone2.Parent = clone.Container.Headshots
					local clone3 = duelHistoryDuelerSlot:Clone()
					clone3.Player.Image = not dueler.UserID and "rbxassetid://18623501726" or string.format(
						CONSTANTS.HEADSHOT_IMAGE,
						dueler.UserID
					)
					clone3.DisplayName.Text = "• • •"
					clone3.Username.Text = "@• • •"
					clone3.Damage.Text = not dueler.Damage and "" or Utility:PrettyNumber((math.floor(dueler.Damage + 0.5))) or ""
					clone3.Eliminations.Text = dueler.Eliminations or ""
					clone3.Deaths.Text = dueler.Deaths or ""
					clone3.Assists.Text = dueler.Assists or ""
					clone3.MVPText.Visible = dueler.IsMVP
					clone3.MVPIcon.Visible = dueler.IsMVP
					clone3.BackgroundColor3 = teamColor
					clone3.LayoutOrder = k2
					clone3.Parent = clone.Container.Duelers

					if dueler.UserID then
						clonesByUserID[tostring(dueler.UserID)] = clone3
					end

					if isRankedQueue then
						RankIcon.new(dueler.DisplayELO, nil, dueler.DisplayELOLeaderboardRanking or 1e999):SetParent(clone3.Rank)
					end
				end

				clone.Parent = self.Container
				table.insert(self._duel_history_slots, clone)
				local flag2 = false
				local visible = false
				local v8 = ButtonEffect:Add(clone, nil, {
					HoverRatio = 1.025,
					ReleaseRatio = 1.025
				})
				local v9 = v2
				clone.MouseButton1Click:Connect(function()
					visible = not visible
					local uDim = visible and UDim2.new(
						1,
						0,
						(#clone.Container.Duelers:GetChildren() - 3) * 0.07500000000000001 + 0.2475,
						0
					) or UDim2.new(1, 0, 0.2, 0)
					v8.UpdateOriginalSize(uDim)
					clone.Size = uDim
					clone.Container.Duelers.Visible = visible

					if flag2 then
						return
					end

					flag2 = true
					local userIDs = {}

					for k2, dueler in pairs(v9.Duelers) do
						if dueler.UserID then
							table.insert(userIDs, dueler.UserID)
						end
					end

					local userInfos = ComplianceController:GetUserInfos(userIDs)

					for k2, v11 in pairs(clonesByUserID) do
						local userInfo = userInfos[k2]

						if not userInfo then
							continue
						end

						v11.Username.Text = userInfo.Username == userInfo.DisplayName and "" or "@" .. userInfo.Username
						v11.DisplayName.Text = userInfo.DisplayName
						v11.DisplayName.Position = v11.Username.Text == "" and UDim2.new(0.1, 0, 0.5, 0) or UDim2.new(
							0.1,
							0,
							0.35,
							0
						)
					end
				end)
				wait(0.03)
			end
		end
	end

	for _ = #self._duel_history_slots + 1, 6 do
		if _generate_hash ~= self._generate_hash then
			break
		end

		local clone = duelHistoryEmptySlot:Clone()
		clone.LayoutOrder = 99999
		clone.Parent = self.Container
		table.insert(self._duel_history_slots, clone)
		wait(0.03)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	ButtonEffect:Add(self.CloseButton)
end

return object._new()