local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")
local parent = script.Parent
local nearShareTextLabel = parent.Parent:WaitForChild("NearShareTextLabel")
local parent2 = parent.Parent.Parent
parent2:WaitForChild("Frame1")
parent2:WaitForChild("Frame2")
parent2:WaitForChild("Frame3")
parent2:WaitForChild("Frame4")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function DialogYesNo(text)
	_G.DialogAnswer = "?"
	local dialogYesNoFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogYesNoFrame")
	local yesNoTextLabel = dialogYesNoFrame:WaitForChild("YesNoTextLabel")
	yesNoTextLabel.Text = text
	dialogYesNoFrame.Visible = true

	while _G.DialogAnswer == "?" do
		task.wait(0.2)
	end
end

local Debris = game:GetService("Debris")
parent.Activated:Connect(function()
	DialogYesNo("Delete this game?  " .. parent2:WaitForChild("Frame1"):WaitForChild("GameTitleTextLabel").Text)

	if _G.DialogAnswer == "Yes" then
		local v = tonumber((parent2.Name:match("%a*(%d+)")))

		if v and v > 0 and v < 200 then
			parent.Visible = false
			nearShareTextLabel.Text = "Deleting..."

			for _, descendant in pairs(parent2:GetDescendants()) do
				if descendant.ClassName == "TextButton" then
					descendant.Visible = false
				end
			end

			Debris:AddItem(parent2, 1.5)
			serverFunctions:InvokeServer("Delete", v)
		else
			warn("Delete game failed. Slot#", v)
		end
	end
end)