local RockPaperScissors = {}
local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("SoundService")
local Network = require(ReplicatedStorage.Modules.Network)
require(ReplicatedStorage.Modules.UI)
local rockPaperScissors = script.Parent:FindFirstAncestorOfClass("ScreenGui"):WaitForChild("Activities"):WaitForChild("RockPaperScissors")

function RockPaperScissors:Start()
	self.Signals = {}
	self.LockedIn = false

	for _, button in rockPaperScissors:GetDescendants() do
		if not button:IsA("TextButton") then
			continue
		end

		local v = button
		table.insert(self.Signals, button.MouseButton1Click:Connect(function()
			if self.LockedIn then
				return
			end

			self.LockedIn = true
			Network:fire("RockPaperScissorsChoice", v.Parent.Name)

			for i, frame in rockPaperScissors:GetChildren() do
				if frame:IsA("Frame") and frame.Name ~= v.Parent.Name then
					frame.Visible = false
				else
					v.Interactable = false
				end
			end
		end))
	end
end

function RockPaperScissors.Stop(_)
	task.wait(0.5)
	script.RoundEnd:Play()
end

function RockPaperScissors.RegisterPlayer(_, _) end

function RockPaperScissors:DestroyPlayer(player)
	if player.Character ~= localPlayer.Character then
		return
	end

	self.LockedIn = false

	for _, frame in rockPaperScissors:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Visible = true
		frame.Button.Interactable = true
	end
end

Network:listen("RockPaperScissorsUi", function()
	if localPlayer.Character:GetAttribute("InActivity") == "RockPaperScissors" then
		RockPaperScissors.LockedIn = false

		for _, frame in rockPaperScissors:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			frame.Visible = true
			frame.Button.Interactable = true
		end

		script.Round:Play()
	end
end)
return RockPaperScissors