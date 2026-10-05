local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
return {
	Start = function(_)
		local idleReport = ReplicatedStorage:WaitForChild("events"):WaitForChild("idleReport")
		local flag = false
		localPlayer.Idled:Connect(function(p: number)
			if flag then
				return
			end

			flag = true
			idleReport:FireServer(true, p)
		end)

		local function onInput()
			if not flag then
				return
			end

			flag = false
			idleReport:FireServer(false)
		end

		UserInputService.InputBegan:Connect(onInput)
		UserInputService.InputChanged:Connect(onInput)
	end
}