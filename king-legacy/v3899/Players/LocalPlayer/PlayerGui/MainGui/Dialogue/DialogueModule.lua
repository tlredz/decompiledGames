local DialogueModule = {}
local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ChatDialogue = require(ReplicatedStorage.Chest.Modules.ChatDialogue)
local RichText = require(ReplicatedStorage.Chest.Modules.RichText)
local parent = script.Parent
local continueLabel = parent.ContinueLabel
local textFrame = parent.TextFrame
local TweenService = game:GetService("TweenService")
local tween = TweenService:Create(parent, TweenInfo.new(0.4), {
	Size = UDim2.new(0.8, 0, 0.25, 0),
	ImageTransparency = 0
})
local tween2 = TweenService:Create(parent, TweenInfo.new(0.4), {
	ImageTransparency = 1,
	Size = UDim2.new(0, 0, 0, 0)
})
local tween3 = TweenService:Create(parent, TweenInfo.new(0.4), {
	Position = UDim2.new(0.5, 0, 0.53, 0)
})
local callbacks = {}
local connections = {}
local v = nil
local flag = nil
local flag2 = nil
local v2 = nil
local v3 = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Touch] = true
}
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	local userInputType = input.UserInputType

	if (UserInputService.GamepadEnabled or not gameProcessed) and v3[userInputType] then
		v = true
	end
end)

function HideButton()
	task.spawn(function()
		for _, button in pairs(parent:GetChildren()) do
			if button:IsA("ImageButton") then
				TweenService:Create(button, TweenInfo.new(0.1), {
					Size = UDim2.new()
				}):Play()
			end
		end
	end)
end

function ShowButton(items)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local v4 = nil

	for _, connection in pairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	for _, item in pairs(items) do
		local buttonType = item.ButtonType

		if not (buttonType and parent:FindFirstChild(buttonType)) then
			continue
		end

		parent[buttonType].Size = UDim2.new(0.35, 0, 0, 0)
		TweenService:Create(parent[buttonType], TweenInfo.new(0.1), {
			Size = UDim2.new(0.35, 0, 0.35, 0)
		}):Play()
		parent[buttonType].Visible = true

		if item.ButtonText then
			parent[buttonType].Text.Text = item.ButtonText
		end

		local v5 = item
		table.insert(connections, parent[buttonType].MouseButton1Click:Connect(function()
			v4 = v5
		end))
	end

	repeat
		wait(0.1)
	until v4 or humanoid.Health <= 0

	if humanoid.Health <= 0 then
		return
	end

	local action = v4.Action or "None"

	if action == "NextDialogue" then
		return BeginChat(v4.Dialogues)
	end

	if action == "QuestAccepted" then
		local questData = v4.QuestData
		local successQuest

		if questData then
			if localPlayer.PlayerStats.lvl.Value >= questData.LevelNeed then
				successQuest = questData.SuccessQuest
				ReplicatedStorage.Chest.Remotes.Functions.Quest:InvokeServer("take", v4.QuestName)
			else
				successQuest = questData.LevelLow
			end
		else
			successQuest = {}
		end

		BeginChat({
			{
				Chat = successQuest
			}
		})
		CloseChat()
		return true
	elseif action == "Cancel" or action == "Close" then
		CloseChat()
	elseif action == "Kill" then
		localPlayer.Character.Humanoid.Health = 0
	elseif action == "QuestSpawnBoss" then
		local questData = v4.QuestData

		if questData then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, questData)
		end
	elseif action == "RemoveDFPower" then
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action)
		local chat

		if _G.CheckDoingClient(localPlayer) then
			chat = v4.EndChatDoingSkill
		else
			chat = v4.EndChat
		end

		BeginChat({
			{
				Chat = chat
			}
		})
		CloseChat()
	elseif action == "Fisher Frank" then
		local questProgressData = v4.QuestProgressData

		if questProgressData then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, questProgressData)
		end

		CloseChat()
	elseif action == "Whirlseer" then
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action)
		CloseChat()
	elseif action == "AddQuestProgress" then
		local questProgressData = v4.QuestProgressData

		if questProgressData then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, questProgressData)
		end

		if v4.EndChat then
			if typeof(v4.EndChat) == "string" then
				BeginChat({
					{
						Chat = v4.EndChat
					}
				})
			else
				BeginChat(v4.EndChat())
			end
		end

		CloseChat()
	elseif action == "Bloodmoon Twins Quest Chapter 4" or action == "Bloodmoon Twins Quest Final Chapter" then
		task.spawn(function()
			ReplicatedStorage.Chest.Remotes.Functions.ThirdSeaQuests:InvokeServer("BeginTorchQuest")
		end)
		CloseChat()
	elseif action == "Buy Bloodmoon Twins" or action == "Buy Kioru V2" then
		local buttonData = v4.ButtonData
		local textSuccess

		if buttonData then
			if localPlayer.PlayerStats.beli.Value >= buttonData.Price then
				textSuccess = buttonData.TextSuccess
				ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, buttonData)
			else
				textSuccess = buttonData.TextNoMoney
			end
		else
			textSuccess = {}
		end

		BeginChat({
			{
				Chat = textSuccess
			}
		})
		CloseChat()
		return true
	elseif action == "Blessing Passive" then
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, {})
		BeginChat({
			{
				Chat = "..."
			}
		})
		CloseChat()
		return true
	elseif action == "OpenCraftUI" then
		local buttonData = v4.ButtonData
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, {
			CraftWith = buttonData.CraftWith
		})
		return true
	elseif action == "Sea Beast Puzzle" then
		local buttonData = v4.ButtonData
		local text1 = {}
		local v5 = _G.CheckQuestProgressClient(localPlayer, "Sea Beast Puzzle")

		if buttonData then
			if v5 then
				if v5 == 1 then
					task.spawn(function()
						ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, buttonData)
					end)
				elseif v5 == 2 then
					text1 = buttonData.Text1
					task.spawn(function()
						ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, buttonData)
					end)
				end
			elseif _G.CheckMaterialClient(localPlayer, "Sea Artifact", 100) then
				text1 = buttonData.Text1
				task.spawn(function()
					ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, buttonData)
				end)
			else
				text1 = buttonData.Text2
			end
		end

		BeginChat({
			{
				Chat = text1
			}
		})
		CloseChat()
		return true
	elseif action == "SpecialShopGui" then
		CloseChat()
		local buttonData = v4.ButtonData

		if buttonData then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, buttonData)
		end
	elseif action == "EquipGaleFist" then
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, "EquipGaleFist")
	else
		if action == "Return" then
			return nil, true
		end

		if action == "UnequipFish" then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, {})
		elseif action == "CollectFish" then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(action, {})

			if v4.EndChat then
				if typeof(v4.EndChat) == "string" then
					BeginChat({
						{
							Chat = v4.EndChat
						}
					})
				else
					BeginChat(v4.EndChat())
				end
			end

			CloseChat()
			return true
		else
			CloseChat()
		end
	end
end

function OpenChat()
	for _, child in pairs(textFrame:GetChildren()) do
		child:Destroy()
	end

	parent.Position = UDim2.fromScale(0.5, 0.58)
	parent.Visible = true
	tween:Play()
	task.wait(tween.TweenInfo.Time)
	tween3:Play()
end

function CloseChat(_)
	_G.NPCTalk = false

	if flag2 then
		return
	end

	flag2 = true
	tween2:Play()
	HideButton()

	if v2 then
		v2:Hide()
	end

	task.wait(tween2.TweenInfo.Time)
	parent.Visible = nil
	flag = nil
end

function BeginChat(callback, p, p2)
	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	if not p2 then
		table.insert(callbacks, callback)
	end

	if type(callback) == "function" then
		callback = callback()
	end

	for k, v6 in pairs(callback) do
		if p and k < p then
			continue
		end

		HideButton()
		v = nil
		continueLabel.Visible = nil
		local chat = v6.Chat

		if v6.ChatTH and localPlayer.PlayerStats.Language.Value == "TH" then
			chat = v6.ChatTH
		end

		local v7 = RichText:New(textFrame, chat, {
			Font = Enum.Font.SourceSansSemibold
		})
		v7:Animate(false)
		v2 = v7

		if not v6.Buttons then
			continueLabel.Visible = true

			while wait() and not (v or humanoid.Health <= 0) do
				continueLabel.TextTransparency = math.abs((math.sin(tick() / 1.3333)))
			end
		end

		v = nil
		continueLabel.Visible = nil

		if humanoid.Health <= 0 then
			break
		end

		if not v6.Buttons then
			continue
		end

		local v8, v9 = ShowButton(v6.Buttons)

		if v9 and callbacks[#callbacks - 1] then
			local v10 = callbacks[#callbacks - 1]
			table.remove(callbacks, #callbacks)
			return (BeginChat(v10, nil, true))
		elseif not v8 then
			return nil
		end
	end

	return true
end

function DialogueModule.Init(nPCName)
	if not nPCName then
		return
	end

	local v4 = ChatDialogue[nPCName]

	if not v4 or flag then
		return
	end

	flag2 = nil
	flag = true
	local child = workspace.AllNPC:FindFirstChild(nPCName)

	if child and child:GetAttribute("NPCName") then
		nPCName = child:GetAttribute("NPCName")
	end

	parent.LevelRequire.Text = nPCName
	OpenChat()
	BeginChat(v4)
	CloseChat()
end

return DialogueModule