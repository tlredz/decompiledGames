local DialogueClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local removeTable = require(ReplicatedStorage.Modules.UtilityAlec.removeTable)
local dialogueBillboard = nil
local v = {}
local instances = {}

function RevealBillboard(p, p2, text)
	p.Text = text
	p.MaxVisibleGraphemes = 0

	if p2.BackgroundTransparency ~= 0 then
		p2.Position = UDim2.new(0, 0, 0.15, 0)
		TweenService:Create(p2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			BackgroundTransparency = 0,
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
		wait(0.65)
	end
end

function ScrollMessage(p, p2)
	local frame = p.Frame
	local textLabel = frame.TextLabel
	RevealBillboard(textLabel, frame, p2)

	for i = 1, #textLabel.ContentText do
		textLabel.MaxVisibleGraphemes = i
		local v2 = string.sub(textLabel.ContentText, i, i)

		if v2 == "." then
			task.wait(0.7)
		elseif v2 == "," then
			task.wait(0.3)
		else
			task.wait(0.03)
		end
	end
end

function DialogueClient.CreateDialogue(instance, p, backgroundColor, value)
	if not (instance and instance.PrimaryPart) then
		warn("SET A PRIMARY PART ON THE NPC")
		return
	end

	local dialogueBillboard2

	if v[instance] then
		dialogueBillboard2 = instance.PrimaryPart:FindFirstChild("DialogueBillboard")

		if not (dialogueBillboard2 and dialogueBillboard2.Parent) then
			v[instance] = {}
			dialogueBillboard2 = dialogueBillboard:Clone()
			dialogueBillboard2.Parent = instance.PrimaryPart
		end
	else
		v[instance] = {}
		dialogueBillboard2 = dialogueBillboard:Clone()
		dialogueBillboard2.Parent = instance.PrimaryPart
	end

	if backgroundColor then
		dialogueBillboard2.Frame.BackgroundColor3 = backgroundColor
	else
		dialogueBillboard2.Frame.BackgroundColor3 = Color3.fromRGB(255, 225, 0)
	end

	table.insert(v[instance], p)
	task.spawn(function()
		repeat
			wait()
		until v[instance][1] == p

		ScrollMessage(dialogueBillboard2, p)
		wait(value or 6)
		local v2 = v[instance][2]
		table.remove(v[instance], 1)

		if not v2 then
			dialogueBillboard2:Destroy()
		end
	end)
end

function DialogueClient.MessageWhenWithinProximity(instance, list, p)
	local character = localPlayer.Character
	local primaryPart = localPlayer.Character.PrimaryPart

	if not instance then
		return
	end

	if not table.find(instances, instance) then
		table.insert(instances, instance)
	end

	task.spawn(function()
		while instance and table.find(instances, instance) do
			if character and primaryPart then
				if (primaryPart.Position - instance.PrimaryPart.Position).Magnitude >= 15 then
					wait(2)
				else
					removeTable(instances, instance)

					for i = 1, #list do
						DialogueClient.CreateDialogue(instance, list[i], p)
					end
				end
			else
				wait(2)
			end
		end
	end)
end

function GetModelFromTag(tag)
	local v2

	if not tag then
		return v2
	end

	local count = 0

	repeat
		v2 = CollectionService:GetTagged(tag)[1]
		wait()
		count += 1
	until v2 or count == 200

	return v2
end

Client.Events.DialogueProximity:Connect(function(p, p2, p3)
	local v2 = GetModelFromTag(p)

	if v2 then
		DialogueClient.MessageWhenWithinProximity(v2, p2, p3)
	else
		warn("NO TARGET FOR DIALOGUE EXISTS")
	end
end)
Client.Events.DialogueInstant:Connect(function(p, p2, p3, p4)
	local v2 = GetModelFromTag(p)

	if v2 then
		DialogueClient.CreateDialogue(v2, p2, p3, p4)
	else
		warn("NO TARGET FOR DIALOGUE EXISTS")
	end
end)

function DialogueClient.Init()
	dialogueBillboard = ReplicatedStorage.Assets.Billboards.DialogueBillboard
end

return DialogueClient