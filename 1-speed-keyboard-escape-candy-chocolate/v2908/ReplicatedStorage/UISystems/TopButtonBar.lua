local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage.ClientState)
local RelicsPlayerClient = require(ReplicatedStorage.UISystems.RelicsPlayerClient)
return {
	Init = function(_)
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local topButtons = playerGui:WaitForChild("SpeedGameUI", 60).Frames.TopButtons
		RelicsPlayerClient.Init()

		local function toggleTikfinityModal()
			for _, v in CollectionService:GetTagged("TikfinityModal") do
				if not v:IsDescendantOf(playerGui) then
					continue
				end

				ClientState:ToggleModal(v)
				break
			end
		end

		local object = setmetatable({}, {
			__mode = "k"
		})

		local function connectTikfinityOpenButton(button)
			if not button:IsA("GuiButton") or button.Name ~= "TikfinityButton" or (object[button] or not button:IsDescendantOf(playerGui)) then
				return
			end

			object[button] = true
			button.Visible = true
			button.Active = true
			button.Interactable = true
			local parent = button.Parent

			while parent and parent ~= playerGui do
				if parent:IsA("GuiObject") and parent.Name == "TikfinityButton" then
					parent.Visible = true
				end

				parent = parent.Parent
			end

			button.MouseButton1Down:Connect(toggleTikfinityModal)
		end

		for _, descendant in playerGui:GetDescendants() do
			connectTikfinityOpenButton(descendant)
		end

		playerGui.DescendantAdded:Connect(connectTikfinityOpenButton)
		topButtons.EmotesButton.EmotesButton.MouseButton1Down:Connect(RelicsPlayerClient.ToggleEquipWheel)
		topButtons.AudioPlayerButton.AudioPlayerButton.MouseButton1Down:Connect(RelicsPlayerClient.ToggleWindowState)
	end
}