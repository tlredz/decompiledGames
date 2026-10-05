local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Shared.LTM)
local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v3 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v4 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
require3(ReplicatedStorage2.Shared.FastUtils)
local regionalTournamentMatch = v.isRegionalTournamentMatch()
local playerGui = Players.LocalPlayer.PlayerGui
local roundStateUpdated = ReplicatedStorage2.Remotes.RoundStateUpdated
local roundEnded = ReplicatedStorage2.Remotes.RoundEnded
local roundPoints = playerGui:WaitForChild("RoundPoints")
local grid = roundPoints.Grid
local countdown = roundPoints.Countdown
local player = grid.UIGridLayout.Player
player.Visible = false
local v5 = {}
local roundEndTime = nil
local v6 = {}
local RoundPointsController = {}

function RoundPointsController.Start(_)
	local function RefreshCounterVisibility()
		roundPoints.Enabled = #workspace.Alive:GetChildren() > 0 and not v4.IsUICovered.CurrentState or regionalTournamentMatch
	end

	local function CharacterAdded(character)
		local playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not playerFromCharacter then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function characterStateUpdated()
			local _isDead = RoundPointsController:_isDead(character)
			SetTileDeadState(playerFromCharacter, _isDead)
		end

		character:GetAttributeChangedSignal("Dead"):Once(characterStateUpdated)
		characterStateUpdated() -- equivalent call inferred; original call site unknown
	end

	local function CharacterDead(character)
		local playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not playerFromCharacter then
			return
		end

		SetTileDeadState(playerFromCharacter, true)
	end

	local function OnRoundStateUpdated(data)
		local participants = data.participants

		if not participants then
			return
		end

		local points = data.points

		if not points then
			return
		end

		roundEndTime = data.roundEndTime
		local v7 = {}

		for k, point in points do
			local playerByUserId = Players:GetPlayerByUserId(k)

			if playerByUserId and playerByUserId:IsDescendantOf(Players) then
				table.insert(v7, {
					Score = GetScore(playerByUserId, point),
					Points = point,
					Player = playerByUserId
				})
			end
		end

		table.sort(v7, function(a, b)
			return a.Score > b.Score
		end)
		v5 = v7

		for _, player2 in participants do
			if not (typeof(player2) == "Instance" and player2:IsA("Player")) then
				continue
			end

			local v8 = points[tostring(player2.UserId)] or 0
			local v9 = nil
			local v10 = nil

			for i, v12 in ipairs(v7) do
				if v12.Player ~= player2 then
					continue
				end

				v10 = v12
				v9 = i
				break
			end

			if v9 and v10 then
				xpcall(DrawPlayer, warn, player2, v8, v10, v9)
			end
		end
	end

	local function OnRoundEnded()
		table.clear(v5)
		roundEndTime = nil
		task.delay(5, function()
			for _, v7 in v6 do
				v7:Destroy()
			end

			table.clear(v6)
		end)
		task.delay(5, RefreshCounterVisibility)
	end

	v2.Every(1, function()
		local gameActive = workspace:GetAttribute("GameActive") == true

		if roundEndTime and gameActive then
			local serverTimeNow = workspace:GetServerTimeNow()
			local v7 = math.max(roundEndTime - serverTimeNow, 0)
			countdown.Text = `TIME LEFT: {SecondsToString(v7)}`

			if v7 > 0 then
				countdown.Visible = true
			elseif countdown.Visible and v7 == 0 then
				task.wait(1)
				countdown.Visible = false
			end
		else
			countdown.Visible = false
			roundEndTime = nil
		end
	end)
	roundStateUpdated.OnClientEvent:Connect(OnRoundStateUpdated)
	roundEnded.OnClientEvent:Connect(OnRoundEnded)
	Players.PlayerRemoving:Connect(function(player2)
		local v7 = v6[player2]

		if v7 then
			v7:Destroy()
			v6[player2] = nil
		end

		for i, v8 in ipairs(v5) do
			if v8.Player ~= player2 then
				continue
			end

			table.remove(v5, i)
			break
		end
	end)
	workspace.Alive.ChildAdded:Connect(CharacterAdded)

	for _, child in ipairs(workspace.Alive:GetChildren()) do
		task.spawn(CharacterAdded, child)
	end

	workspace.Alive.ChildAdded:Connect(RefreshCounterVisibility)
	v4.IsUICoveredState:Connect(RefreshCounterVisibility)
	task.spawn(RefreshCounterVisibility)

	local function OnDeviceChanged()
		if v3:IsMobile() then
			roundPoints.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
			roundPoints.IgnoreGuiInset = false
			roundPoints.Countdown.Position = UDim2.fromScale(0.5, 0.01)
			roundPoints.Grid.Position = UDim2.fromScale(0.5, 0.01)
		else
			roundPoints.ScreenInsets = Enum.ScreenInsets.None
			roundPoints.IgnoreGuiInset = true
			roundPoints.Countdown.Position = UDim2.fromScale(0.5, 0.05)
			roundPoints.Grid.Position = UDim2.fromScale(0.5, 0.05)
		end

		roundPoints.UIPadding.PaddingTop = UDim.new(0.01, 0)
		roundPoints.UIPadding.PaddingBottom = UDim.new(0.01, 0)
	end

	v3:Observe(OnDeviceChanged)
end

function RoundPointsController:_isDead(instance)
	if not instance or instance:IsDescendantOf(workspace.Dead) or instance:GetAttribute("Dead") then
		return true
	end

	return false
end

function SecondsToString(p: number)
	math.floor(p / 86400)
	math.floor(p % 86400 / 3600)
	local v7 = math.floor(p % 3600 / 60)
	local v8 = math.floor(p % 60)
	return string.format("%02d:%02d", v7, v8)
end

function SetTileDeadState(p, playerDead: boolean)
	local v7 = v6[p]

	if v7 then
		v7:SetAttribute("PlayerDead", playerDead)
	end
end

function GetAvatarHeadShot(p: number)
	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	if success then
		return result
	end

	return (`rbxthumb://type=AvatarHeadShot&id={p}&w=100&h=100`)
end

function GetScore(p, p2: number)
	return p2 * 100000 + (string.len(p.Name) + string.len(p.DisplayName))
end

function DrawPlayer(p, p2: number, p3, p4: number)
	local layoutOrder = p3.Score * -1 - (100 - p4)
	local clone = v6[p]

	if not clone then
		clone = player:Clone()
		v6[p] = clone
		clone.Content.PlayerIcon.Thumbnail.Image = GetAvatarHeadShot(p.UserId)
		clone.Content.Score.Visible = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tileUpdated()
			local visible = clone:GetAttribute("PlayerDead") and true or false
			clone.Dead.Visible = visible
			clone.Content.Score.Visible = not visible
		end

		local playerDeadChangedConnection = clone:GetAttributeChangedSignal("PlayerDead"):Connect(tileUpdated)
		tileUpdated() -- equivalent call inferred; original call site unknown
		clone.Destroying:Once(function()
			playerDeadChangedConnection:Disconnect()
		end)
		clone.Parent = grid
	end

	clone.Content.Score.Text = tostring(p2)
	clone.LayoutOrder = layoutOrder

	if #v5 >= 7 then
		clone.Visible = p4 <= 7
	else
		clone.Visible = true
	end

	clone.Content.Tickets.Visible = false
end

return RoundPointsController