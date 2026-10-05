local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Tabs = require(ReplicatedStorage.Client.Tabs)
local MessageTyper = require(ReplicatedStorage.Client.UI.MessageTyper)
local talk_UI = ReplicatedStorage.Assets.UI.Npcs.Talk_UI
local localPlayer = Players.LocalPlayer
return {
	new = function()
		local v = {}
		local v2 = nil

		local function display()
			local line = v2.Lines[v2.Index]
			local size = talk_UI.Size
			v2.Bubble.Size = UDim2.new(
				size.X.Scale,
				size.X.Offset,
				size.Y.Scale * (#line > 45 and 2 or 1),
				size.Y.Offset
			)
			v2.NextAt = os.clock() + (utf8.len(line) or #line) * 0.03 + math.max(1.3, #line * 0.025)
			v2.Typer:Type(line, v2.Label.TextColor3)
		end

		function v.Close(flag: boolean?)
			local v3 = v2
			v2 = nil

			if not v3 then
				return
			end

			v3.Typer:Halt()
			v3.Bubble:Destroy()
			v3.Anchor:Destroy()

			if v3.Prompt.Parent then
				v3.Prompt.Enabled = v3.Enabled and flag ~= false
			end
		end

		function v.Start(instance, prompt, finished)
			v.Close()
			local primaryPart = instance.PrimaryPart

			if not primaryPart then
				return
			end

			local boundingBox, v3 = instance:GetBoundingBox()
			local attachment = Instance.new("Attachment")
			attachment.Name = "ScrambleDialoguePoint"
			attachment.Position = primaryPart.CFrame:PointToObjectSpace(boundingBox.Position + Vector3.new(
				0,
				v3.Y / 2,
				0
			))
			attachment.Parent = primaryPart
			local clone = talk_UI:Clone()
			clone.Name = "ScrambleDialogue"
			clone.Adornee = attachment
			clone.MaxDistance = 45
			clone.Enabled = true
			clone.Parent = localPlayer.PlayerGui
			local textLabel = clone.TextLabel
			textLabel.Text = ""
			v2 = {
				Model = instance,
				Character = localPlayer.Character,
				Prompt = prompt,
				Enabled = prompt.Enabled,
				Anchor = attachment,
				Bubble = clone,
				Label = textLabel,
				Typer = MessageTyper.new(textLabel, nil, 0.03, false),
				Index = 1,
				NextAt = 0,
				Finished = finished,
				Lines = {
					"SHHH! Don't tell him I'm here!",
					"I stole this when I escaped his lab...",
					"But it broke on the way out.",
					"I lost two of the parts... and his drones took the other three.",
					"Help me fix it and whatever's inside is yours."
				}
			}
			prompt.Enabled = false
			display()
		end

		function v.IsPlaying(p)
			return v2 ~= nil and (p == nil or v2.Model == p)
		end

		function v.Tick(flag: boolean)
			if not v2 then
				return
			end

			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not flag or character ~= v2.Character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 or not v2.Model:IsDescendantOf(workspace) or not v2.Prompt.Parent or (humanoidRootPart.Position - v2.Anchor.WorldPosition).Magnitude > v2.Prompt.MaxActivationDistance + 8 then
				v.Close(flag)
			elseif os.clock() >= v2.NextAt then
				if v2.Index < #v2.Lines then
					v2.Index += 1
					display()
				else
					local finished = v2.Finished
					v.Close()
					finished()
				end
			end
		end

		local activatedConnection = Tabs.Activated:Connect(function()
			v.Close()
		end)

		function v.Destroy()
			v.Close()
			activatedConnection:Disconnect()
		end

		return v
	end
}