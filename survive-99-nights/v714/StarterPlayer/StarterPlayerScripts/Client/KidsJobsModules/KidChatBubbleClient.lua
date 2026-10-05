local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TextChatService = game:GetService("TextChatService")

function TextChatService.OnBubbleAdded(_, instance)
	local instanceModel = instance and instance:FindFirstAncestorWhichIsA("Model")

	if not (instanceModel and instanceModel:GetAttribute("KidId")) then
		return
	end

	local bubbleChatMessageProperties = Instance.new("BubbleChatMessageProperties")
	bubbleChatMessageProperties.TextColor3 = Color3.fromRGB(255, 66, 53)
	bubbleChatMessageProperties.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubbleChatMessageProperties.FontFace = Font.fromEnum(Enum.Font.PermanentMarker)
	bubbleChatMessageProperties.TextSize = 30
	return bubbleChatMessageProperties
end

function GetBubbleAdornee(instance)
	local bubbleAdornee = instance:FindFirstChild("BubbleAdornee")

	if bubbleAdornee then
		return bubbleAdornee
	end

	local part = Instance.new("Part")
	part.Name = "BubbleAdornee"
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CFrame = instance.CFrame * CFrame.new(0, 1.5, 0)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part
	weldConstraint.Part1 = instance
	weldConstraint.Parent = part
	part.Parent = instance
	return part
end

function KidChatMessage(instance, p: string, _)
	if not (instance and instance.Parent) then
		return
	end

	local head = instance:FindFirstChild("Head")

	if not head then
		return
	end

	TextChatService:DisplayBubble(GetBubbleAdornee(head), p)
end

Client.Events.KidChatMessage:Connect(function(p, p2: string)
	KidChatMessage(p, p2)
end)
return {}