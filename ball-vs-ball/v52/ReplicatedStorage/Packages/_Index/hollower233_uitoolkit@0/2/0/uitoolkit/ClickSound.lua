local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Init = function()
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local random = Random.new()
		local object = setmetatable({}, {
			__mode = "k"
		})
		local firstChild = ReplicatedStorage:FindFirstChild("音效素材")
		local sound = firstChild and firstChild:FindFirstChild("通用点击音效")
		local v

		if sound and sound:IsA("Sound") then
			v = sound:Clone()
		else
			v = Instance.new("Sound")
			v.SoundId = "rbxassetid://131983841354349"
			v.Volume = 0.5
		end

		v.Name = "ClickSound"
		v.Parent = script

		local function playClickSound()
			v.PlaybackSpeed = random:NextNumber(1, 1.5)
			v.TimePosition = 0
			v:Play()
		end

		local function bindButton(button)
			if not button:IsA("GuiButton") or button.Name == "JumpButton" or object[button] then
				return
			end

			object[button] = true
			button.Activated:Connect(playClickSound)
		end

		playerGui.DescendantAdded:Connect(bindButton)

		for _, button in playerGui:GetDescendants() do
			if not button:IsA("GuiButton") or button.Name == "JumpButton" or object[button] then
				continue
			end

			object[button] = true
			button.Activated:Connect(playClickSound)
		end
	end
}