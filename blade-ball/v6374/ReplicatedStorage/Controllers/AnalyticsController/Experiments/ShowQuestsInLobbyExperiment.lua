local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Types.Analytics)
require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local remoteEvent = v3:RemoteEvent("ShowedQuestsLobby")
return {
	RemoteConfig = "ShowQuestsInLobby",
	DefaultValue = false,
	TestConfigValues = {
		[false] = 100
	},
	Configs = {
		[true] = function(player)
			if not v.isNewPlayerLobbyServer() or v2.Client:WaitReplion("Data"):Get("Dive.ShowedQuestsInLobby") then
				return
			end

			player:WaitForChild("PlayerGui"):WaitForChild("NewDailyQuests")
			local count = 0
			local ancestryChangedConnection = nil
			local dead = workspace:WaitForChild("Dead")
			local characterChangedConnection = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setEvent(character)
				if ancestryChangedConnection then
					ancestryChangedConnection:Disconnect()
				end

				ancestryChangedConnection = character.AncestryChanged:Connect(function(_, parent)
					if count >= 3 then
						if characterChangedConnection then
							characterChangedConnection:Disconnect()
						end

						if ancestryChangedConnection then
							ancestryChangedConnection:Disconnect()
						end

						v4:Close("DailyQuests")
						remoteEvent:FireServer()
					else
						if parent ~= dead then
							v4:Close("DailyQuests")
							return
						end

						count += 1
						v4:Open("DailyQuests")
					end
				end)
			end

			local function getCharacter()
				if player.Character then
					setEvent(player.Character) -- equivalent call inferred; original call site unknown
				end
			end

			characterChangedConnection = player:GetPropertyChangedSignal("Character"):Connect(getCharacter)

			if player.Character then
				local character = player.Character

				if ancestryChangedConnection then
					ancestryChangedConnection:Disconnect()
				end

				ancestryChangedConnection = character.AncestryChanged:Connect(function(_, parent)
					if count >= 3 then
						if characterChangedConnection then
							characterChangedConnection:Disconnect()
						end

						if ancestryChangedConnection then
							ancestryChangedConnection:Disconnect()
						end

						v4:Close("DailyQuests")
						remoteEvent:FireServer()
					else
						if parent ~= dead then
							v4:Close("DailyQuests")
							return
						end

						count += 1
						v4:Open("DailyQuests")
					end
				end)
			end
		end
	}
}