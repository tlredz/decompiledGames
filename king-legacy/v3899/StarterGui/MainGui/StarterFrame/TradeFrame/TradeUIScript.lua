local parent = script.Parent
local flag = nil
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("Chest")
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local uIGridLayout = scrollingFrame:WaitForChild("UIGridLayout")

function UpdateGrid()
	uIGridLayout.CellSize = UDim2.new(
		0,
		(scrollingFrame.AbsoluteSize.X - scrollingFrame.ScrollBarThickness) * 0.25,
		0,
		(scrollingFrame.AbsoluteSize.Y - scrollingFrame.ScrollBarThickness) * 0.428
	)
	scrollingFrame.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
end

scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateGrid()
end)

function Add(p)
	if scrollingFrame:FindFirstChild(p.Name) then
		return
	end

	local userThumbnailAsync = Players:GetUserThumbnailAsync(
		p.UserId,
		Enum.ThumbnailType.AvatarBust,
		Enum.ThumbnailSize.Size420x420
	)
	local clone = script.PlayerLabel:Clone()
	clone.Name = p.Name
	clone.SwordName.Text = p.Name
	clone.PlayerImage.Image = userThumbnailAsync
	clone.LayoutOrder = 2

	if p.Name == localPlayer.Name then
		clone.LayoutOrder = 0
		clone.SwordName.Text = p.Name .. " (You)"
	end

	clone.Parent = scrollingFrame
	clone.FunctionFrame.Accept.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		task.delay(0.1, function()
			flag = nil
		end)
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true,
				Parent = parent.Parent
			})
		end)
		game.ReplicatedStorage.Chest.Remotes.Functions.TradeRequester:InvokeServer("Accept", {
			TargetName = p.Name
		})
	end)
	clone.FunctionFrame.Deny.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		task.delay(0.1, function()
			flag = nil
		end)
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true,
				Parent = parent.Parent
			})
		end)
		game.ReplicatedStorage.Chest.Remotes.Functions.TradeRequester:InvokeServer("Deny", {
			TargetName = p.Name
		})
	end)
	clone.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		task.delay(0.1, function()
			flag = nil
		end)
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true,
				Parent = parent.Parent
			})
		end)
		local playerImage = clone:FindFirstChild("PlayerImage")

		if playerImage then
			playerImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				playerImage,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB()
				}
			):Play()
		end

		game.ReplicatedStorage.Chest.Remotes.Functions.TradeRequester:InvokeServer("Invite", {
			TargetName = p.Name
		})
	end)
end

function Remove(p)
	local child = scrollingFrame:FindFirstChild(p.Name)

	if not child then
		return
	end

	child:Destroy()
end

function InvisibleAllFunction(p)
	for _, button in pairs(p.FunctionFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button.Visible = nil
		end
	end
end

function Update()
	local v = ReplicatedStorage.Chest.Remotes.Functions.TradeRequester:InvokeServer("Get")

	for _, button in pairs(parent.ScrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			InvisibleAllFunction(button)
		end
	end

	for childName, _ in pairs(v) do
		local child = scrollingFrame:FindFirstChild(childName)

		if not child then
			continue
		end

		child.FunctionFrame.Accept.Visible = true
		child.FunctionFrame.Deny.Visible = true
	end
end

Players.PlayerAdded:Connect(function(player)
	wait()
	Add(player)
end)
Players.PlayerRemoving:Connect(function(player)
	wait()
	Remove(player)
end)

for _, v in pairs(Players:GetPlayers()) do
	Add(v)
end

UpdateGrid()
ReplicatedStorage.Chest.Remotes.Events.TradeUpdater.OnClientEvent:Connect(function()
	Update()
end)
Update()