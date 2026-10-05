local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local remoteEvent = Net:RemoteEvent("MarianasAwakening/TrenchDrop")
local flag = false

local function playFade()
	CutsceneController:FadeToggle(0.15, true)
	task.wait(0.65)
	CutsceneController:FadeToggle(0.5, false)
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function()
			if flag then
				return
			end

			flag = true
			local success, result = pcall(playFade)

			if not success then
				warn((`[ObsidianTrench]: {result}`))
			end

			flag = false
		end)
	end
}