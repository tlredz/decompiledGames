local parent = script.Parent
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local flag = nil

repeat
	wait()
until localPlayer:FindFirstChild("DataLoaded")

local allies = localPlayer:WaitForChild("Allies")
ReplicatedStorage:WaitForChild("Chest")
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local uIGridLayout = scrollingFrame:WaitForChild("UIGridLayout")
local functionAllFrame = parent:WaitForChild("FunctionAllFrame")

function UpdateGrid()
	uIGridLayout.CellSize = UDim2.new(
		0,
		(scrollingFrame.AbsoluteSize.X - scrollingFrame.ScrollBarThickness) * 0.25,
		0,
		(scrollingFrame.AbsoluteSize.Y - scrollingFrame.ScrollBarThickness) * 0.475
	)
	scrollingFrame.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
end

scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateGrid()
end)

function Add(instance)
	if scrollingFrame:FindFirstChild(instance.Name) then
		return
	end

	local userThumbnailAsync = Players:GetUserThumbnailAsync(
		instance.UserId,
		Enum.ThumbnailType.AvatarBust,
		Enum.ThumbnailSize.Size420x420
	)
	local clone = script.PlayerLabel:Clone()
	clone.Name = instance.Name
	clone.SwordName.Text = instance.Name
	clone.PlayerImage.Image = userThumbnailAsync
	clone.LayoutOrder = 2

	if instance == localPlayer then
		clone.PlayerImage.BackgroundColor3 = Color3.fromRGB(0, 85, 0)
		clone.SwordName.Text = instance.Name .. " [You]"
		clone.TierImage.Image = "rbxassetid://111246788215240"
	end

	if instance.Name == localPlayer.Name then
		clone.LayoutOrder = 0
	end

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
		ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
			Action = "Accept",
			Target = instance.Name
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
		ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
			Action = "Deny",
			Target = instance.Name
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

		local status = clone:GetAttribute("Status") or "Enemy"

		if status == "InAlly" then
			ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
				Action = "Kick",
				Target = instance.Name
			})
			return
		end

		if status ~= "Enemy" then
			return
		end

		ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
			Action = "Invite",
			Target = instance.Name
		})
	end)
	clone.Parent = scrollingFrame
	Functions("Normal", clone)
	task.spawn(function()
		local allies2 = instance:WaitForChild("Allies", 10)
		allies2.ChildAdded:Connect(function(_)
			wait()
			Update()
		end)
		allies2.ChildRemoved:Connect(function(_)
			wait()
			Update()
		end)
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

function Functions(p, state)
	local IMAGE_ID = "rbxassetid://108104545640462"

	if state.Name == localPlayer.Name then
		return
	end

	InvisibleAllFunction(state)
	state.TierImage.Image = IMAGE_ID
	state.LayoutOrder = 2

	if p == "Invite" then
		state.InviteStatus.Visible = false
		state.KickStatus.Visible = false
		state.FunctionFrame.Accept.Visible = true
		state.PlayerImage.BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		state.TierImage.Image = IMAGE_ID
		state.FunctionFrame.Deny.Visible = true
	elseif p == "Ally" then
		state.InviteStatus.Visible = false
		state.KickStatus.Visible = true
		state.PlayerImage.BackgroundColor3 = Color3.fromRGB(0, 85, 0)
		state.TierImage.Image = "rbxassetid://111246788215240"
		state.LayoutOrder = 1
	else
		if p ~= "Normal" then
			return
		end

		state.InviteStatus.Visible = true
		state.KickStatus.Visible = false
		state.PlayerImage.BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		state.TierImage.Image = IMAGE_ID
	end
end

function Update()
	local v = ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
		Action = "Get"
	})

	if not v then
		return
	end

	for _, button in pairs(parent.ScrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		button:SetAttribute("Status", "Enemy")
		InvisibleAllFunction(button)
		Functions("Normal", button)
	end

	for childName, _ in pairs(v) do
		local child = scrollingFrame:FindFirstChild(childName)

		if not child then
			continue
		end

		child:SetAttribute("Status", nil)
		Functions("Invite", child)
	end

	for _, child in pairs(allies:GetChildren()) do
		local child2 = scrollingFrame:FindFirstChild(child.Name)

		if not child2 then
			continue
		end

		child2:SetAttribute("Status", "InAlly")
		Functions("Ally", child2)
	end
end

local v = true
local v2 = true

function AcceptAllRequest()
	if not v then
		return
	end

	v = nil

	for _, button in pairs(parent.ScrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local child = game.Players:FindFirstChild(button.Name)

		if not (child and (button:GetAttribute("Status") or "Enemy") ~= "InAlly") then
			continue
		end

		local v3 = child
		task.defer(function()
			ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
				Action = "Accept",
				Target = v3.Name
			})
		end)
	end

	task.delay(0.5, function()
		v = true
	end)
end

function InviteAll()
	if not v2 then
		return
	end

	v2 = nil

	for _, button in pairs(parent.ScrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local child = game.Players:FindFirstChild(button.Name)

		if not (child and (button:GetAttribute("Status") or "Enemy") == "Enemy") then
			continue
		end

		local v3 = child
		task.defer(function()
			ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
				Action = "Invite",
				Target = v3.Name
			})
		end)
	end

	task.delay(0.5, function()
		v2 = true
	end)
end

functionAllFrame.AcceptAll.MouseButton1Click:Connect(function()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = parent.Parent
		})
	end)
	AcceptAllRequest()
end)
functionAllFrame.AcceptAll.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = functionAllFrame.AcceptAll,
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.35, 0)
	})
end)
functionAllFrame.InviteAll.MouseButton1Click:Connect(function()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = parent.Parent
		})
	end)
	InviteAll()
end)
functionAllFrame.InviteAll.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = functionAllFrame.InviteAll,
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.35, 0)
	})
end)
functionAllFrame.Leave.MouseButton1Click:Connect(function()
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

	if localPlayer.Character and localPlayer.Character:GetAttribute("InDungeon") then
		return
	end

	ReplicatedStorage.Chest.Remotes.Functions.Ally:InvokeServer({
		Action = "Leave"
	})
end)
functionAllFrame.Leave.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = functionAllFrame.Leave,
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.35, 0)
	})
end)

for _, v3 in pairs(Players:GetPlayers()) do
	Add(v3)
end

Players.PlayerAdded:Connect(function(player)
	wait()
	Add(player)
end)
Players.PlayerRemoving:Connect(function(player)
	wait()
	Remove(player)
end)
ReplicatedStorage.Chest.Remotes.Events.AllyUpdater.OnClientEvent:Connect(function(_)
	Update()
end)
UpdateGrid()
Update()