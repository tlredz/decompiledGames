local GameLostUI = {}
local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local deadFrame = Client.Interface.DeadFrame
local gameLostFrame = Client.Interface.GameLostFrame
local partyDeadFrame = Client.Interface.PartyDeadFrame
local v = 0
local v2 = 0
local v3 = nil
game:GetService("RunService")

function CharacterAdded(_)
	gameLostFrame.Visible = false
	deadFrame.Visible = false
	partyDeadFrame.Visible = false
	v += 1
end

function OnDied()
	local v4 = v + 1
	v = v4

	if game.ReplicatedStorage:GetAttribute("GameMode") == "UpdateParty" then
		partyDeadFrame.Visible = true
	elseif localPlayer:GetAttribute("Playtester") then
		deadFrame.Visible = true
		deadFrame.PurchaseRespawnButton.Visible = false
		deadFrame.RespawningLabel.Visible = true
	else
		if #game.Players:GetChildren() == 1 then
			deadFrame.Visible = false
			return
		end

		if workspace:GetAttribute("GameLost") then
			deadFrame.Visible = false
			return
		end

		deadFrame.Visible = true
		deadFrame.PurchaseRespawnButton.Visible = true

		for i = Client.GlobalSettings.SelfReviveTime, 0, -1 do
			if v ~= v4 then
				break
			end

			deadFrame.PurchaseRespawnButton.TextLabel.Text = "Self-Revive (" .. i .. ")"
			wait(1)
		end

		if v == v4 then
			deadFrame.PurchaseRespawnButton.Visible = false
		end
	end
end

localPlayer:GetAttributeChangedSignal("DeathTime"):Connect(function()
	if localPlayer:GetAttribute("DeathTime") then
		OnDied()
	end
end)
deadFrame.PurchaseRespawnButton.MouseButton1Click:Connect(function()
	Client.Events.RequestSelfRevive:FireServer()
end)
gameLostFrame.ReviveEveryoneButton.MouseButton1Click:Connect(function()
	Client.Events.RequestReviveAll:FireServer()
end)
workspace:GetAttributeChangedSignal("GameEndCountdown"):Connect(function()
	local gameEndCountdown = workspace:GetAttribute("GameEndCountdown")
	gameLostFrame.TimeRemaining.Text = "RETURNING IN " .. (gameEndCountdown or "30") .. " SECONDS"
end)

function ShowGameLost()
	gameLostFrame.Visible = true
	deadFrame.Visible = false
	local v4 = time()
	v2 = v4
	task.spawn(function()
		for i = 3, 1, -1 do
			if v2 ~= v4 then
				break
			end

			v3 = i
			UpdatePlayAgain()
			task.wait(1)
		end

		if v2 == v4 then
			v3 = nil
			UpdatePlayAgain()
		end
	end)
end

function ResumeGameFromLost()
	gameLostFrame.Visible = false
	deadFrame.Visible = false
	partyDeadFrame.Visible = false
	v2 = nil
end

gameLostFrame.PlayAgainButton.MouseButton1Click:Connect(function()
	if not v3 then
		Client.Events.AcceptPlayAgain:FireServer()
	end
end)

function UpdatePlayAgain(_)
	local wantToPlayAgain = workspace:GetAttribute("WantToPlayAgain") or 0
	local totalPlayers = workspace:GetAttribute("TotalPlayers") or 1

	if v3 then
		gameLostFrame.PlayAgainButton.BackgroundTransparency = 0.3
		gameLostFrame.PlayAgainButton.BackgroundColor3 = Color3.fromRGB(108, 108, 108)
	else
		gameLostFrame.PlayAgainButton.BackgroundTransparency = 0
		gameLostFrame.PlayAgainButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end

	if v3 then
		gameLostFrame.PlayAgainButton.TextLabel.Text = "PLAY AGAIN WITH SAME TEAM (" .. v3 .. ")"
	else
		gameLostFrame.PlayAgainButton.TextLabel.Text = "PLAY AGAIN WITH SAME TEAM (" .. wantToPlayAgain .. "/" .. totalPlayers .. ")"
	end
end

workspace:GetAttributeChangedSignal("TotalPlayers"):Connect(function()
	UpdatePlayAgain()
end)
workspace:GetAttributeChangedSignal("WantToPlayAgain"):Connect(function()
	UpdatePlayAgain()
end)
workspace:GetAttributeChangedSignal("GameLost"):Connect(function()
	if localPlayer:GetAttribute("Playtester") then
		return
	end

	if workspace:GetAttribute("GameLost") then
		ShowGameLost()
	else
		ResumeGameFromLost()
	end
end)

function GameLostUI.Init()
	localPlayer.CharacterAdded:Connect(CharacterAdded)

	if localPlayer.Character then
		CharacterAdded(localPlayer.Character)
	end
end

return GameLostUI