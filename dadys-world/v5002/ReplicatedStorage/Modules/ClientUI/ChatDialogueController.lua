local createVector = vector.create
local ChatDialogueController = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function ChatDialogueController.CreateTextDialogue(instance, text, duration, quad, out, _)
	local playerTextBox = ReplicatedStorage.Parts.PlayerTextBox

	local function CreateDialogueBox(instance2, humanoidRootPart)
		local clone = playerTextBox:Clone()
		clone.Parent = humanoidRootPart
		instance2:FindFirstChild("Head")

		if not quad then
			quad = Enum.EasingStyle.Quad
		end

		if not out then
			out = Enum.EasingDirection.Out
		end

		local tweenInfo = TweenInfo.new(0.25, quad, out, 0, false)
		local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		clone.Frame.DialogueBox.Text = text
		clone.Enabled = true
		Debris:AddItem(clone, duration + 1)
		clone.StudsOffsetWorldSpace = createVector(0, 4, 0)
		clone.Frame.SpeechBubble.BackgroundTransparency = 1
		clone.Frame.SpeechBubbleBG.BackgroundTransparency = 1
		clone.Frame.DialogueBox.TextTransparency = 1
		clone.Frame.DialogueBox.TextStrokeTransparency = 1
		TweenService:Create(clone.Frame.SpeechBubble, tweenInfo2, {
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(clone.Frame.SpeechBubbleBG, tweenInfo2, {
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(clone.Frame.DialogueBox, tweenInfo2, {
			TextTransparency = 0,
			TextStrokeTransparency = 0
		}):Play()

		if humanoidRootPart:FindFirstChild("TextBox") then
			TweenService:Create(clone, tweenInfo, {
				StudsOffsetWorldSpace = createVector(0, 6.6, 0)
			}):Play()
		else
			TweenService:Create(clone, tweenInfo, {
				StudsOffsetWorldSpace = createVector(0, 5, 0)
			}):Play()
		end

		local childAddedConnection = humanoidRootPart.ChildAdded:Connect(function(child)
			if child.Name == "TextBox" then
				TweenService:Create(clone, tweenInfo, {
					StudsOffsetWorldSpace = createVector(0, 6.6, 0)
				}):Play()
			end
		end)
		local childRemovedConnection = humanoidRootPart.ChildRemoved:Connect(function(child)
			if child.Name == "TextBox" then
				TweenService:Create(clone, tweenInfo, {
					StudsOffsetWorldSpace = createVector(0, 5, 0)
				}):Play()
			end
		end)
		task.delay(duration, function()
			if clone and clone.Parent ~= nil then
				local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
				TweenService:Create(clone.Frame.SpeechBubble, tweenInfo3, {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone.Frame.SpeechBubbleBG, tweenInfo3, {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone.Frame.DialogueBox, tweenInfo3, {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				childAddedConnection:Disconnect()
				childRemovedConnection:Disconnect()
			end
		end)
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if instance and humanoidRootPart then
		if humanoidRootPart:FindFirstChild("PlayerTextBox") then
			humanoidRootPart:FindFirstChild("PlayerTextBox"):Destroy()
		end

		CreateDialogueBox(instance, humanoidRootPart)
	end
end

function ChatDialogueController.CreatePlayerDialogue(p, _)
	if not (p ~= nil and p.TextSource ~= nil) then
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(p.TextSource.UserId)

	if playerByUserId and playerByUserId.Character then
		local v = playerByUserId.Character:GetExtentsSize().Y / 2 + 1
		local head = playerByUserId.Character:FindFirstChild("Head")
		local hat = playerByUserId.Character:FindFirstChild("Hat") or playerByUserId.Character:FindFirstChild("Cap")

		if head then
			v = head.Size.Y / 2 + 1
		end

		if hat then
			v += 0.5
		end

		ChatDialogueController.CreateTextDialogue(playerByUserId.Character, p.Text, 10, nil, nil, v, true)
	end
end

return ChatDialogueController