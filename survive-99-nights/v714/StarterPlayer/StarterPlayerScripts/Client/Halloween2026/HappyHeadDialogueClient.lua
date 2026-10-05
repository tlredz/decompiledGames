local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HappyHeadDialogueClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local halloweenDialogueFrame = Client.Interface.HalloweenDialogueFrame
local size = halloweenDialogueFrame.Responses.Size
local scale = halloweenDialogueFrame.Responses.Option1.Size.Y.Scale
local scale2 = halloweenDialogueFrame.Responses.UIListLayout.Padding.Scale
local thickness = halloweenDialogueFrame.Responses.UIStroke.Thickness
local v = nil
local v2 = {}
local v3 = false
local v4 = false
local count = 0

function HappyHeadDialogueClient.SetDialogue(p)
	if p then
		count += 1
		local v5 = count
		v3 = false
		v4 = false
		halloweenDialogueFrame.LastMessage.TextLabel.Text = p.Message
		halloweenDialogueFrame.Responses.Visible = false
		halloweenDialogueFrame.Visible = true
		local textLabel = halloweenDialogueFrame.LastMessage.TextLabel
		local message = p.Message
		local v6 = utf8.len(message)
		textLabel.MaxVisibleGraphemes = 0
		wait(0.2)
		ReplicatedStorage.Core.Sounds.HalloweenTyping:Play()

		for i = 1, v6 do
			if v4 or count ~= v5 then
				break
			end

			textLabel.MaxVisibleGraphemes = i
			local v7 = utf8.offset(message, i)

			if v7 then
				if string.sub(message, v7, v7) == "." then
					task.wait(0.2)
				else
					task.wait(0.02)
				end
			else
				task.wait(0.02)
			end
		end

		if count ~= v5 then
			return
		end

		textLabel.MaxVisibleGraphemes = -1
		v2 = {}
		local count2 = 0

		for i = 1, 3 do
			local respons = halloweenDialogueFrame.Responses["Option" .. i]
			local v7 = p.Responses and p.Responses[i]

			if v7 then
				respons.TextLabel.Text = v7.Response
				respons.CutsceneIcon.Visible = v7.Cutscene ~= nil
				respons.Visible = true
				v2[i] = v7
				count2 += 1
			else
				respons.Visible = false
			end
		end

		FitResponses(count2)
		ReplicatedStorage.Core.Sounds.HalloweenTyping:Stop()

		if count2 == 0 then
			task.delay(5.5, function()
				if count == v5 and halloweenDialogueFrame.Visible then
					Close()
				end
			end)
			return
		end

		local v7 = time() + 0.65

		while not v4 and time() < v7 do
			task.wait()
		end

		if count ~= v5 then
			return
		end

		halloweenDialogueFrame.Responses.Visible = true
		v3 = true
	else
		print("ARRAY DOES NOT EXIST")
		Close()
	end
end

function FitResponses(p)
	local v5 = 1 - (3 - math.max(p, 1)) * (scale + scale2)
	local responses = halloweenDialogueFrame.Responses
	responses.Size = UDim2.new(size.X, UDim.new(size.Y.Scale * v5, size.Y.Offset))
	responses.UIListLayout.Padding = UDim.new(scale2 / v5, 0)
	responses.UIStroke.Thickness = thickness / v5

	for i = 1, 3 do
		local respons = responses["Option" .. i]
		respons.Size = UDim2.new(respons.Size.X, UDim.new(scale / v5, 0))
	end
end

function OnButtonClick(p)
	local v5 = v2[p]

	if not v5 then
		return
	end

	if v5.Node then
		local v6 = v[v5.Node]

		if v6 then
			HappyHeadDialogueClient.SetDialogue(v6)
		else
			print("DIALOGUE DOES NOT CONTAIN DATA FOR NODE", v5.Node)
		end
	elseif v5.Event then
		Client.Events[v5.Event]:Fire()
		Close()
	elseif v5.Cutscene then
		Client.Events.RunCutscene:Fire(v5.Cutscene, {
			ForceCutscene = true
		})
		Close()
	end
end

function Close()
	halloweenDialogueFrame.Visible = false
	Client.FloatingHappyHeadClient.HideHead(0.75)
end

function LoadButtons()
	for i = 1, 3 do
		local respons = halloweenDialogueFrame.Responses["Option" .. i]
		TweenService:Create(
			respons.CutsceneIcon,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				ImageTransparency = 0.8
			}
		):Play()
		local v5 = i
		respons.MouseButton1Click:Connect(function()
			if not v3 then
				return
			end

			OnButtonClick(v5)
		end)
	end

	halloweenDialogueFrame.CloseButton.MouseButton1Click:Connect(function()
		Close()
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v4 = true
		end
	end)
end

function HappyHeadDialogueClient.OpenDialogue(p, p2)
	local rebuildHappyState = workspace:GetAttribute("RebuildHappyState")

	if rebuildHappyState == 3 then
		if localPlayer:GetAttribute("PickedUpRamHappyHead") then
			Client.FloatingHappyHeadClient.ShowHead()
		end
	elseif rebuildHappyState ~= 2 and rebuildHappyState ~= 4 and localPlayer:GetAttribute("HelpingHappyHalloween") then
		Client.FloatingHappyHeadClient.ShowHead()
	end

	local databas = Client.Databases[p]

	if databas then
		v = databas
		HappyHeadDialogueClient.SetDialogue(p2 and databas[p2] or databas.Root)
	end
end

Client.Events.StartDialogue:Connect(function(p, p2)
	HappyHeadDialogueClient.OpenDialogue(p, p2)
end)

function LoadHalloweenGuy()
	local halloweenGuy = halloweenDialogueFrame:WaitForChild("Icon"):WaitForChild("ViewportFrame"):WaitForChild("WorldModel"):WaitForChild("HalloweenGuy")
	halloweenGuy:WaitForChild("NPC"):WaitForChild("Animator"):LoadAnimation(halloweenGuy:WaitForChild("Animations"):WaitForChild("Idle")):Play()
end

function LoadHeadBob()
	local halloweenGuy = halloweenDialogueFrame:WaitForChild("Icon"):WaitForChild("ViewportFrame"):WaitForChild("WorldModel"):WaitForChild("HalloweenGuy")
	local pivot = halloweenGuy:GetPivot()
	RunService.RenderStepped:Connect(function()
		if not halloweenDialogueFrame.Visible then
			return
		end

		halloweenGuy:PivotTo(pivot + Vector3.new(0, math.sin(os.clock() * 1.5) * 0.12, 0))
	end)
end

function UpdateIcon()
	local rebuildHappyState = workspace:GetAttribute("RebuildHappyState")
	local v5

	if rebuildHappyState == nil then
		v5 = false
	else
		v5 = rebuildHappyState >= 4
	end

	local icon = halloweenDialogueFrame.Icon
	icon.ImageTransparency = v5 and 0 or 1
	icon.ViewportFrame.Visible = not v5
end

function HappyHeadDialogueClient.Init()
	LoadButtons()
	task.spawn(LoadHeadBob)
	UpdateIcon()
	workspace:GetAttributeChangedSignal("RebuildHappyState"):Connect(UpdateIcon)
end

return HappyHeadDialogueClient