local localPlayer = game.Players.LocalPlayer
localPlayer:GetMouse()
local _ = localPlayer.PlayerGui
local parent = script.Parent
local buso = parent.Buso
local dash = parent.Dash
local hao = parent.Hao
local ken = parent.Ken
local run = parent.Run
local soruButton = parent.SoruButton
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local kenEvent = ReplicatedStorage.Chest.Remotes.Functions:WaitForChild("KenEvent")
local armament = ReplicatedStorage.Chest.Remotes.Events:WaitForChild("Armament")
ReplicatedStorage.Chest.Remotes.Events:WaitForChild("ButtonR3")

repeat
	wait()
until localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("HumanoidRootPart")

local v = true
local flag = true
local v2 = true
local v3 = true
local character = localPlayer.Character
local humanoid = character.Humanoid
local humanoidRootPart = character.HumanoidRootPart

function UpdateSize()
	local uIGridLayout = parent.UIGridLayout
	uIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	uIGridLayout.CellSize = UDim2.new(0, (parent.AbsoluteSize.X - 0) / 2, 0, (parent.AbsoluteSize.Y - 0) / 3)
end

UpdateSize()
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateSize()
end)

function SixMainButtonState(p)
	if p == "Hide" then
		for _, button in pairs(parent:GetChildren()) do
			if not (button:IsA("ImageButton") and button:GetAttribute("Button") == "Main" and button.Visible) then
				continue
			end

			game.TweenService:Create(button, TweenInfo.new(0.25), {
				ImageTransparency = 0.85
			}):Play()
		end
	else
		if p ~= "Show" then
			return
		end

		for _, button in pairs(parent:GetChildren()) do
			if not (button:IsA("ImageButton") and button:GetAttribute("Button") == "Main" and button.Visible) then
				continue
			end

			button.ImageTransparency = 0
		end
	end
end

function SixMainButtonClick(button)
	SixMainButtonState("Show")
	task.spawn(function()
		if button:IsA("ImageButton") and button:GetAttribute("Button") == "Main" and button.Visible then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Name = button.Name .. " Illusion"
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Size = UDim2.fromScale(1.5, 1.5)
			imageLabel.Image = button.Image
			imageLabel.BackgroundTransparency = 1
			imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
			imageLabel.Parent = button
			_G.PU:Dust(imageLabel, 0.25)
			game.TweenService:Create(imageLabel, TweenInfo.new(0.25), {
				ImageTransparency = 1,
				Size = UDim2.fromScale(1, 1)
			}):Play()
		end
	end)
end

function HideUI()
	local now = tick()
	local v4 = nil
	local v5 = nil
	local v6 = nil
	humanoid.Running:Connect(function(p)
		if p > 0 then
			if not v4 then
				v4 = true
				SixMainButtonState("Show")
			end

			v5 = true
		else
			v5 = nil

			if not v6 then
				v6 = true
				now = tick()
				PeodizService.HeartbeatWait({
					Time = 2,
					WaitTime = 0.5
				}, function()
					if not v5 then
						return
					end

					v6 = nil
					return true
				end)

				if v4 and not v5 then
					v4 = nil
					SixMainButtonState("Hide")
				end

				v6 = nil
			end
		end
	end)
end

localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	v = true
	flag = true
	v2 = true
	v3 = true
	ken.ImageColor3 = Color3.fromRGB(255, 255, 255)
	buso.ImageColor3 = Color3.fromRGB(255, 255, 255)
	spawn(function()
		if _G.IsMobile then
			HideUI()
		end
	end)
end)

if UserInputService.TouchEnabled then
	character:SetAttribute("Device", "Mobile")
	parent.Visible = true
	_G.IsMobile = true
	HideUI()
end

local currentCamera = workspace.CurrentCamera

function _G.IsInSticks(p)
	local X = p.Position.X
	local Y = p.Position.Y
	local v4 = currentCamera.ViewportSize.X / 2.4
	local v5 = currentCamera.ViewportSize.Y / 3.4

	if X < v4 and v5 < Y then
		return true
	end
end

local name = nil
wait(1)
spawn(function()
	repeat
		wait()
	until localPlayer:FindFirstChild("DataLoaded")

	if localPlayer.PlayerStats.BusoShopValue.Value == "BusoHaki" then
		buso.LockedFrame.Visible = nil
	end

	if localPlayer.PlayerStats.KenShopValue.Value then
		ken.LockedFrame.Visible = nil
	end

	if localPlayer.PlayerStats.HAOHAKI.Value == "HAOYOUHAVEIT" or localPlayer.PlayerStats.haogamepass.Value == "HAOYOUHAVEIT" then
		hao.Visible = true
	end

	if localPlayer.PlayerStats.Soru.Value == "Soru" then
		soruButton.LockedFrame.Visible = nil
	end

	pcall(function()
		localPlayer.PlayerStats.BusoShopValue.Changed:Connect(function()
			if localPlayer.PlayerStats.BusoShopValue.Value == "BusoHaki" then
				buso.LockedFrame.Visible = nil
			end
		end)
		localPlayer.PlayerStats.KenShopValue.Changed:Connect(function()
			if localPlayer.PlayerStats.KenShopValue.Value == "KenHaki" then
				ken.LockedFrame.Visible = nil
			end
		end)
		localPlayer.PlayerStats.haogamepass.Changed:Connect(function()
			if localPlayer.PlayerStats.HAOHAKI.Value == "HAOYOUHAVEIT" or localPlayer.PlayerStats.haogamepass.Value == "HAOYOUHAVEIT" then
				hao.Visible = true
			end
		end)
		localPlayer.PlayerStats.Soru.Changed:Connect(function()
			if localPlayer.PlayerStats.Soru.Value == "Soru" then
				soruButton.LockedFrame.Visible = nil
			end
		end)
	end)
end)
buso.MouseButton1Click:Connect(function()
	if humanoid.Sit or humanoid.WalkSpeed == 0 or (_G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer)) then
		return
	end

	spawn(function()
		if v and localPlayer.PlayerStats.BusoShopValue.Value == "BusoHaki" and not _G.AntiMobSkill() then
			SixMainButtonClick(buso)

			if buso.ImageColor3 == Color3.fromRGB(255, 255, 255) then
				buso.ImageColor3 = Color3.fromRGB(0, 255, 0)
			else
				buso.ImageColor3 = Color3.fromRGB(255, 255, 255)
			end

			armament:FireServer()
			spawn(function()
				v = false
				wait(1)
				v = true
			end)
		end
	end)
end)
buso.MouseButton1Down:Connect(function()
	TweenService:Create(buso, TweenInfo.new(0.1), {
		Size = UDim2.new(0.05636363636363636, 0, 0.09090909090909091, 0)
	}):Play()
end)
buso.MouseButton1Up:Connect(function()
	TweenService:Create(buso, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
buso.MouseLeave:Connect(function()
	TweenService:Create(buso, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
dash.MouseButton1Click:Connect(function()
	if not _G.Dash or (humanoid.Sit or humanoid.WalkSpeed == 0) then
		return
	end

	if _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) then
		return
	end

	if flag then
		SixMainButtonClick(dash)
		flag = false
		_G.Dash(character)
		wait(0.05)
		flag = true
	end
end)
dash.MouseButton1Down:Connect(function()
	TweenService:Create(dash, TweenInfo.new(0.1), {
		Size = UDim2.new(0.05636363636363636, 0, 0.09090909090909091, 0)
	}):Play()
end)
dash.MouseButton1Up:Connect(function()
	TweenService:Create(dash, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
dash.MouseLeave:Connect(function()
	TweenService:Create(dash, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
hao.MouseButton1Click:Connect(function(p)
	if humanoid.Sit or humanoid.WalkSpeed == 0 or p then
		return
	end

	if _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) then
		return
	end

	if (localPlayer.PlayerStats.HAOHAKI.Value == "HAOYOUHAVEIT" or localPlayer.PlayerStats.haogamepass.Value == "HAOYOUHAVEIT") and _G.ConquerorDB then
		SixMainButtonClick(hao)
		_G.ConquerorCooldown(localPlayer)
		ReplicatedStorage.Chest.Remotes.Events.Conqueror:FireServer()
	end
end)
hao.MouseButton1Down:Connect(function()
	TweenService:Create(hao, TweenInfo.new(0.1), {
		Size = UDim2.new(0.05636363636363636, 0, 0.09090909090909091, 0)
	}):Play()
end)
hao.MouseButton1Up:Connect(function()
	TweenService:Create(hao, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
hao.MouseLeave:Connect(function()
	TweenService:Create(hao, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
ken.MouseButton1Click:Connect(function(p)
	if humanoid.Sit or humanoid.WalkSpeed == 0 or p then
		return
	end

	if _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) then
		return
	end

	if localPlayer.PlayerStats.KenShopValue.Value == "KenHaki" then
		if not v3 then
			return
		end

		v3 = nil
		SixMainButtonClick(ken)
		task.spawn(function()
			if kenEvent:InvokeServer() then
				ken.ImageColor3 = Color3.fromRGB(0, 255, 0)
				_G.KenHaki("Open")
			else
				ken.ImageColor3 = Color3.fromRGB(255, 255, 255)
				_G.KenHaki("Close")
			end
		end)
		spawn(function()
			wait(1)
			v3 = true
		end)
	end
end)
ken.MouseButton1Down:Connect(function()
	TweenService:Create(ken, TweenInfo.new(0.1), {
		Size = UDim2.new(0.05636363636363636, 0, 0.09090909090909091, 0)
	}):Play()
end)
ken.MouseButton1Up:Connect(function()
	TweenService:Create(ken, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
ken.MouseLeave:Connect(function()
	TweenService:Create(ken, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
run.MouseButton1Click:Connect(function()
	if humanoid.Sit or humanoid.WalkSpeed == 0 or (_G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer)) then
		return
	end

	SixMainButtonClick(run)

	if not _G.Run then
		run.ImageColor3 = Color3.fromRGB(0, 255, 0)
	end

	if _G.Run then
		run.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end

	_G.Run = not _G.Run
end)
run.MouseButton1Down:Connect(function()
	TweenService:Create(run, TweenInfo.new(0.1), {
		Size = UDim2.new(0.05636363636363636, 0, 0.09090909090909091, 0)
	}):Play()
end)
run.MouseButton1Up:Connect(function()
	TweenService:Create(run, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
run.MouseLeave:Connect(function()
	TweenService:Create(run, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
soruButton.MouseButton1Click:Connect(function()
	if humanoid.Sit or humanoid.WalkSpeed == 0 or (_G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer)) then
		return
	end

	SixMainButtonClick(soruButton)

	if name == soruButton.Name then
		name = nil
		soruButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
	else
		name = soruButton.Name
		soruButton.ImageColor3 = Color3.fromRGB(0, 255, 0)
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or humanoid.Health <= 0 or humanoid.WalkSpeed == 0 or humanoid.Sit or _G.IsInSticks(input) then
		return
	end

	if _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Begin and name == "SoruButton" then
		name = nil
		soruButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
		_G.TeleportSoru()
	end
end)
soruButton.MouseButton1Down:Connect(function()
	TweenService:Create(soruButton, TweenInfo.new(0.1), {
		Size = UDim2.new(0.05636363636363636, 0, 0.09090909090909091, 0)
	}):Play()
end)
soruButton.MouseButton1Up:Connect(function()
	TweenService:Create(soruButton, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
soruButton.MouseLeave:Connect(function()
	TweenService:Create(soruButton, TweenInfo.new(0.1), {
		Size = UDim2.new(0.062, 0, 0.1, 0)
	}):Play()
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		if UserInputService.TouchEnabled then
			parent.Visible = true
		else
			parent.Visible = false
		end
	end
end)