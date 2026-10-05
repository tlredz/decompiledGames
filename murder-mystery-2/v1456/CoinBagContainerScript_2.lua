local container = script.Parent.Container
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local coinCollected = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinCollected")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local coinsStarted = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinsStarted")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

local function PlayBagFullAnimation(bagName: string)
	local clone = script.FullBagNotification:Clone()
	clone.Text = string.upper(bagName) .. " FULL!"
	clone.Position = UDim2.new(0.5, 0, 1.15, 0)
	clone.Rotation = -3
	clone.Visible = true
	clone.Parent = script.Parent
	game.Debris:AddItem(clone, 3)
	TweenService:Create(clone, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.8, 0)
	}):Play()
	task.wait(0.5)
	TweenService:Create(clone, tweenInfo2, {
		Rotation = 3
	}):Play()
	task.wait(1.5)
	TweenService:Create(clone, tweenInfo3, {
		Position = UDim2.new(0.5, 0, 1.15, 0)
	}):Play()
end

local function onCoinCollected(childName: string, text: number, p: number, _)
	local child = container:FindFirstChild(childName)

	if not child then
		return
	end

	local v = p <= text
	child.CurrencyFrame.Icon.Coins.Text = text

	if v then
		child.EmptyBagIcon.Visible = false
		child.FullBagIcon.Visible = true
		child.Full.Visible = true
		PlayBagFullAnimation(child:GetAttribute("BagName"))
	end
end

local function onCoinsStarted(p)
	local children = container:GetChildren()

	for _, frame in pairs(children) do
		if frame:IsA("Frame") then
			frame.Visible = p[frame.Name] ~= nil
		end
	end
end

for _, frame in pairs(container:GetChildren()) do
	if frame:IsA("Frame") then
		frame.Visible = false
	end
end

coinCollected.OnClientEvent:Connect(onCoinCollected)
coinsStarted.OnClientEvent:Connect(onCoinsStarted)