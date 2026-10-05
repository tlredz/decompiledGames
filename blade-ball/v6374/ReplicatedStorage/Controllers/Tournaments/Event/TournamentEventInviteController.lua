local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Statable)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Packages.Observers)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v6 = require3("./TournamentEventController")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remoteFunction = v:RemoteFunction("JoinTournamentEventParty")
v:RemoteFunction("LeaveTournamentEventParty")
local remoteFunction2 = v:RemoteFunction("SendTournamentEventInvite")
local remoteEvent = v:RemoteEvent("TournamentEventInviteNotification")
local TournamentEventInviteController = {}

function TournamentEventInviteController.Prompt(_)
	v2:Open("TournamentEventInvite")
end

function TournamentEventInviteController.Start(_)
	local invite = playerGui:WaitForChild("TournamentEvent").MainFrame.Frame.Views.Invite
	local players = invite.Players
	invite.Close.Activated:Connect(function()
		v6.CurrentPage:Set("Play")
	end)
	players.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		players.CanvasSize = UDim2.fromOffset(0, players.UIListLayout.AbsoluteContentSize.Y + 10)
	end)
	v3.observePlayer(function(player)
		if player == localPlayer then
			return function() end
		end

		local clone = players.UIListLayout.Player:Clone()
		clone.Username.Text = `{player.DisplayName} (@{player.Name})`
		clone.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=100&h=100`
		clone.Name = player.Name
		clone.Parent = players
		local inTournamentEventPartyChangedConnection = player:GetAttributeChangedSignal("InTournamentEventParty"):Connect(function()
			clone.Visible = not player:GetAttribute("InTournamentEventParty")
		end)
		local activatedConnection = clone.Invite.Activated:Connect(function()
			local v7, v8 = remoteFunction2:InvokeServer(player)

			if not v7 then
				if v8 then
					v5:SendNotification(v8)
				end

				ReplicatedStorage2.Misc.error:Play()
			end
		end)
		return function()
			clone:Destroy()
			activatedConnection:Disconnect()
			inTournamentEventPartyChangedConnection:Disconnect()
		end
	end)
	local tournamentEventPartyInvite = playerGui:WaitForChild("TournamentEventPartyInvite")
	local v7 = nil
	tournamentEventPartyInvite.Main.DeclineButton.Activated:Connect(function()
		if v7 then
			remoteEvent:FireServer(false)
			v7 = nil
		end

		tournamentEventPartyInvite.Enabled = false
	end)
	tournamentEventPartyInvite.Main.ReadyButton.Activated:Connect(function()
		if v7 then
			local v8, v9 = remoteFunction:InvokeServer(v7)

			if v8 then
				v7 = nil
			else
				v4.Sounds:Play("error")
				v5:SendNotification(v9 or "Failed to accept invite!")
				return
			end
		end

		tournamentEventPartyInvite.Enabled = false
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		v7 = p
		tournamentEventPartyInvite.Main.Invite.Text = `@{p} Invited You to a Tournament Event!`
		tournamentEventPartyInvite.Enabled = true
	end)
end

return TournamentEventInviteController