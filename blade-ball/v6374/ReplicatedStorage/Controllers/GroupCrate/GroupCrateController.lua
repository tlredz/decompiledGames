local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local GroupService = game:GetService("GroupService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.UseNewLobby)
local remoteEvent = v2:RemoteEvent("RedeemGroupCrate")
local remoteEvent2 = v2:RemoteEvent("GroupErrorNotification")
local announcer = nil
local groupError = nil
local GroupCrateController = {
	Start = function(_)
		announcer = playerGui:WaitForChild("announcer")
		groupError = announcer:WaitForChild("GroupError")
		remoteEvent2.OnClientEvent:Connect(onGroupNotification)
		task.spawn(function()
			if v.isDungeonsLobbyServer() then
				return
			end

			workspace:WaitForChild("Spawn", 1000000)
			workspace:WaitForChild("Spawn"):WaitForChild("GroupCrate"):WaitForChild("Lock"):WaitForChild("ProximityPrompt").Triggered:Connect(function(player)
				if player == Players.LocalPlayer then
					remoteEvent:FireServer()
				end
			end)
		end)

		if v.isLTMServer() then
			groupError.Position -= UDim2.fromScale(0, 0.1)
		end
	end
}

function onGroupNotification(value: string)
	local clone = groupError:Clone()
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local v3 = { TweenService:Create(clone, tweenInfo, {
			TextTransparency = 0
		}), TweenService:Create(clone.UIStroke, tweenInfo, {
			Transparency = 0
		}), TweenService:Create(clone.ImageLabel, tweenInfo, {
			ImageTransparency = 0.5
		}) }

	if value == "2" then
		ReplicatedStorage2.Misc.click:Play()
		clone.Text = "YOU HAVE ALREADY CLAIMED THIS REWARD!"
	elseif value == "1" then
		ReplicatedStorage2.Misc.click:Play()
		task.spawn(function()
			GroupService:PromptJoinAsync(12836673)
		end)
	elseif value == "3" then
		ReplicatedStorage2.Misc.reward:Play()
		clone.TextColor3 = Color3.new(0.101961, 1, 0)
		clone.Text = "YOU HAVE CLAIMED YOUR REWARD!"
	elseif not tonumber(value) then
		ReplicatedStorage2.Misc.click:Play()
		clone.Text = value:upper()
	end

	clone.Parent = announcer
	task.spawn(playGroupAnimation, v3)
	task.delay(3.5, function()
		clone:Destroy()
	end)
end

function playGroupAnimation(list)
	for _, v3 in ipairs(list) do
		v3:Play()
	end

	task.wait(0.25)

	for _, v3 in ipairs(list) do
		v3:Pause()
	end

	task.wait(2.75)

	for _, v3 in ipairs(list) do
		v3:Play()
	end
end

return GroupCrateController