local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.ServerInfo)
local v4 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.Controllers.Tournaments.TournamentsController)
local v7 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v8 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local tournaments = playerGui:WaitForChild("Tournaments")
local mainFrame = tournaments:WaitForChild("MainFrame")
local tabs = mainFrame.Tabs

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local TournamentsUIController = {
	ScreenGui = tournaments,
	MainFrame = mainFrame,
	TabsFolder = tabs,
	SwitchView = function(self, p: string)
		for _, guiObject in tabs:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = guiObject.Name == p
			end
		end

		for _, button in tournaments.TopButtons:GetChildren() do
			if button:IsA("GuiButton") then
				button.TextLabel.TextColor3 = button.Name == p and Color3.fromRGB(255, 176, 19) or Color3.fromRGB(
					255,
					255,
					255
				)
			end
		end
	end
}
local tournamentWaiting = playerGui:WaitForChild("TournamentWaiting")
local frame = tournamentWaiting.Frame
local connection = nil

function TournamentsUIController:PromptQueue(onActivated)
	tournamentWaiting.Enabled = true
	local count = 0
	connection = v2.Thread.Every(1, function()
		count += 1
		frame.Timer.Text = string.format("%.2i:%.2i", math.floor(count / 60), count % 60)
	end)
	tournamentWaiting.Frame.Cancel.Activated:Once(onActivated)
end

function TournamentsUIController:PromptGlobal()
	self:PromptQueue(function()
		if not v6.Remotes.LeaveGlobalTournamentQueue:InvokeServer() then
			return
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		tournamentWaiting.Enabled = false
	end)
end

function TournamentsUIController.Start(object)
	object:SwitchView("Play")

	for _, button in tournaments.TopButtons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v9 = button
		button.Activated:Connect(function()
			object:SwitchView(v9.Name)
		end)
	end

	tournaments.TopButtons.Custom.Visible = not v3.isTournamentMatchServer()
	tournaments.TopButtons.Play.Visible = not v3.isTournamentMatchServer()
	tournaments.Close.Activated:Connect(function()
		v5:Close()
	end)
	localPlayer:GetAttributeChangedSignal("InTournamentQueue"):Connect(function()
		if not localPlayer:GetAttribute("InTournamentQueue") then
			if connection then
				connection:Disconnect()
				connection = nil
			end

			tournamentWaiting.Enabled = false
		end
	end)
	frame.Hide.Activated:Connect(function()
		frame.Hide.Visible = false
		tournamentWaiting.Show.Visible = true
		local uDim = UDim2.fromOffset(0, GuiService.TopbarInset.Height)

		if not v.TouchEnabled then
			uDim = UDim2.fromOffset(0, 4)
		end

		fastTween(tournamentWaiting.Show, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position = UDim2.fromScale(0.5, 0) + uDim
		}) -- equivalent call inferred; original call site unknown
		fastTween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0)
		}) -- equivalent call inferred; original call site unknown
	end)
	tournamentWaiting.Show.Activated:Connect(function()
		frame.Hide.Visible = true
		tournamentWaiting.Show.Visible = false
		fastTween(tournamentWaiting.Show, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position = UDim2.fromScale(0.5, 0.225)
		}) -- equivalent call inferred; original call site unknown
		fastTween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0) + UDim2.fromOffset(0, GuiService.TopbarInset.Height)
		}) -- equivalent call inferred; original call site unknown
	end)

	if v3.isTournamentMatchServer() then
		playerGui:WaitForChild("HUD"):WaitForChild("LeftFrame")
		local leftFrameContent = v7:GetLeftFrameContent()
		leftFrameContent.AFK.Visible = false
		leftFrameContent.Brackets.Visible = true
		leftFrameContent.Brackets.Activated:Connect(function()
			v5:Open("TournamentBrackets")
		end)
	elseif v3.isTournamentEventServer() then
		if v8.ShowBrackets then
			playerGui:WaitForChild("HUD"):WaitForChild("LeftFrame")
			local leftFrameContent = v7:GetLeftFrameContent()
			leftFrameContent.AFK.Visible = false
			leftFrameContent.Brackets.Visible = true
			leftFrameContent.Brackets.Activated:Connect(function()
				v5:Open("TournamentEventBrackets")
			end)
		end
	elseif v3.isMedalTournamentMatch() then
		playerGui:WaitForChild("HUD"):WaitForChild("LeftFrame")
		local leftFrameContent = v7:GetLeftFrameContent()
		leftFrameContent.AFK.Visible = false
		leftFrameContent.Brackets.Visible = false
		leftFrameContent.Brackets.Activated:Connect(function()
			v5:Open("TournamentEventBrackets")
		end)
	elseif v3.isTournamentLobbyServer() then
		local tournamentRoomCode = playerGui:WaitForChild("TournamentRoomCode")
		v4.observeClientReplion("TournamentLobby", function(object2)
			local function update()
				local roomCode = object2:Get("roomCode")

				if roomCode then
					tournamentRoomCode.RoomCode.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">Room Code: #<font color="rgb(255, 200, 33 )">{roomCode}</font> ({#Players:GetPlayers()}/{object2:Get("players")} Players)</stroke>`
				else
					tournamentRoomCode.RoomCode.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">{#Players:GetPlayers()}/{object2:Get("players")} Players</stroke>`
				end

				tournamentRoomCode.Enabled = true
			end

			local connection2 = v4.observeReplionPath(object2, "roomCode", update)
			local playerAddedConnection = Players.PlayerAdded:Connect(update)
			local playerRemovingConnection = Players.PlayerRemoving:Connect(update)
			return function()
				tournamentRoomCode.Enabled = false
				connection2:Disconnect()
				playerAddedConnection:Disconnect()
				playerRemovingConnection:Disconnect()
			end
		end)
	end
end

return TournamentsUIController