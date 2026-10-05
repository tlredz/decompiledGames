local parent = script.Parent
local settingsList = parent:WaitForChild("SettingsContainer"):WaitForChild("SettingsList")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
remotes:WaitForChild("Extras"):WaitForChild("GetServerSettings"):InvokeServer()
local visible = remotes:WaitForChild("CustomGames"):WaitForChild("CanStartDuels"):InvokeServer()
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("WindowService"))

-- equivalent calls inferred from this helper; original call sites unknown
local function onOptionEnabled(name: string)
	if name == "DuelMode" then
		settingsList.Duel.Visible = true
	else
		settingsList.Duel.Visible = false
	end
end

local function bindOptionFrame(p)
	for _, frame in p.Options:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v2 = frame
		frame.Button.Activated:Connect(function()
			if p.Name == "GameMode" then
				remotes.Extras.ChangeServerSetting:FireServer(v2.Name, true)
			else
				remotes.Extras.ChangeServerSetting:FireServer(p.Name, v2.Name)
			end

			for i, frame2 in p.Options:GetChildren() do
				if frame2:IsA("Frame") then
					frame2.Button.Style = frame2 == v2 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
				end
			end

			onOptionEnabled(v2.Name) -- equivalent call inferred; original call site unknown
		end)
	end
end

bindOptionFrame(settingsList:WaitForChild("GameMode"))
bindOptionFrame(settingsList:WaitForChild("RoundTimerOverride"))
parent:WaitForChild("Title"):WaitForChild("Close"):WaitForChild("Button").Activated:Connect(function()
	parent.Visible = false
end)
settingsList:WaitForChild("Duel"):WaitForChild("DuelSetup"):WaitForChild("Button").Activated:Connect(function()
	WindowService:ToggleFrame("DuelSetup")
end)
local duelMode = settingsList:WaitForChild("GameMode"):WaitForChild("Options"):WaitForChild("DuelMode")
duelMode.Visible = visible
WindowService:RegisterFrame(parent, "PrivateServer")