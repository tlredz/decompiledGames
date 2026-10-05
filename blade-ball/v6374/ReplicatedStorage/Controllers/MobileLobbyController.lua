local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.Shared.GetServerType)
local v5 = require3(ReplicatedStorage2.Shared.UniverseIds)
local v6 = require3(ReplicatedStorage2.ServerInfo)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mobileLobbyPrompt = playerGui:WaitForChild("MobileLobbyPrompt")
local lobbyJoinIssue = playerGui:WaitForChild("LobbyJoinIssue")
local remoteEvent = v3:RemoteEvent("PromptJoinMobileServer")
local remoteEvent2 = v3:RemoteEvent("AcceptJoinMobileServer")
local remoteEvent3 = v3:RemoteEvent("DeclineJoinMobileServer")
local remoteEvent4 = v3:RemoteEvent("LobbyFailedToFollow")
local remoteFunction = v3:RemoteFunction("IsInMobile")
local v7 = {
	Mobile = "You need to play on a <font color=\"rgb(255, 17, 17)\">mobile device</font> to join them",
	Pro = "You need at least <font color=\"rgb(255, 17, 17)\">50 Wins</font> to join them",
	Voice = "You need to have <font color=\"rgb(255, 17, 17)\">Voice Chat</font> to join them"
}
return {
	Start = function(_)
		local v8 = v2.Client:WaitReplion("Data")

		remoteFunction.OnClientInvoke = function()
			return v.TouchEnabled and not (v.KeyboardEnabled or v.MouseEnabled)
		end

		local function prompt()
			if v.TouchEnabled and not v.KeyboardEnabled and not v.MouseEnabled and (game.PlaceId == v5.Default.PlaceId or game.PlaceId == v5.NewPlayerLobbies.PlaceId or game.PlaceId == v5.IntermediatePlayerLobbies.PlaceId) and not v6.isMobileServer() then
				remoteEvent:FireServer()
			end
		end

		if v8:GetExpect("TotalStats.Wins") >= 1 then
			prompt()
		else
			local connection = nil
			connection = v8:OnChange("TotalStats.Wins", function(p)
				if p >= 1 then
					if connection then
						connection:Disconnect()
						connection = nil
					end

					prompt()
				end
			end)
		end

		remoteEvent.OnClientEvent:Connect(function()
			mobileLobbyPrompt.Enabled = true
			task.delay(15, function()
				if not mobileLobbyPrompt.Enabled then
					return
				end

				mobileLobbyPrompt.Enabled = false
				remoteEvent3:FireServer()
			end)
		end)
		mobileLobbyPrompt.Frame.No.Activated:Connect(function()
			mobileLobbyPrompt.Enabled = false
			remoteEvent3:FireServer()
		end)
		mobileLobbyPrompt.Frame.Yes.Activated:Connect(function()
			mobileLobbyPrompt.Enabled = true
			remoteEvent2:FireServer()
		end)
		remoteEvent4.OnClientEvent:Connect(function(p: string)
			local followUserId = localPlayer.FollowUserId

			if followUserId == 0 then
				return
			end

			local v9, v10 = v4:GetUsername(followUserId):await()

			if not (v9 and v10) then
				return
			end

			local v11 = v7[p] or "Unknown join error"
			lobbyJoinIssue.Frame.Label.Text = `<stroke color="rgb(11, 26, 78)" joins="round" thickness="3"><font color="rgb(83, 160, 255)">{v10}</font> is in a {p}-only lobby. {v11}</stroke>`
			lobbyJoinIssue.Enabled = true
		end)
		lobbyJoinIssue.Frame.Close.Activated:Connect(function()
			lobbyJoinIssue.Enabled = false
		end)
	end
}