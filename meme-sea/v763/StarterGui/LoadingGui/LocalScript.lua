if script.Parent.Enabled == false then
	script.Parent.Enabled = true
end

local ReplicatedFirst = game:GetService("ReplicatedFirst")
ReplicatedFirst:RemoveDefaultLoadingScreen()
game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerData = localPlayer:WaitForChild("PlayerData", 15)
local loadingGui = localPlayer:WaitForChild("PlayerGui", 15):WaitForChild("LoadingGui", 15)
local lastTeam = playerData:FindFirstChild("LastTeam")
local playerDummy = workspace:WaitForChild("PlayerDummy")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local robloxPrompt = require(ReplicatedStorage.Modules:WaitForChild("robloxPrompt"))
local SetText = require(ReplicatedStorage.ModuleScript:WaitForChild("SetText"))
local playBackground = script.Parent:WaitForChild("PlayBackground")
local teamChoose = otherEvent.MainEvents:WaitForChild("TeamChoose")
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local freeMoney = otherEvent.SecretEvents:WaitForChild("FreeMoney")
local v = "Floppa"
local v2 = true
local renderSteppedConnection = nil
local v3 = false
local lastTime = tick()
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

if UserInputService.TouchEnabled == true == true then
	local uIStroke = playBackground.Play.Buttonlabel:FindFirstChild("UIStroke")
	local uIStroke2 = playBackground.Setting.Buttonlabel:FindFirstChild("UIStroke")
	local uIStroke3 = playBackground.Leave.Buttonlabel:FindFirstChild("UIStroke")

	if uIStroke then
		uIStroke.Thickness = 1
	end

	if uIStroke2 then
		uIStroke2.Thickness = 1
	end

	if uIStroke3 then
		uIStroke3.Thickness = 1
	end
end

local function StartGame()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	local lastTime2 = tick()

	repeat
		task.wait(0.1)
	until tick() - lastTime2 >= 1

	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = nil
	end

	loadingGui.Enabled = false

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
		workspace.CurrentCamera.CameraSubject = localPlayer.Character:FindFirstChild("Humanoid")
	end

	local loader = playerDummy:FindFirstChild("Loader")

	if loader then
		task.wait(3)

		if loader and loader.Parent then
			loader:Destroy()
		end
	end
end

local function FakeLoading()
	local v4 = 1

	while v3 == false and v3 ~= true do
		local v5 = v4 > 3 and 1 or v4
		playBackground.Load.Text = `Loading Data{string.rep(".", v5)}`
		v4 = v5 + 1
		task.wait(0.5)
	end
end

local function Setup_Team()
	if lastTeam.Value == "Cheems" then
		v = "Cheem"
		playBackground.Floppa.Select.UIStroke.Color = Color3.fromRGB(225, 225, 225)
		playBackground.Floppa.Select.Textlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		playBackground.Floppa.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
		playBackground.Cheem.Select.UIStroke.Color = Color3.fromRGB(174, 225, 255)
		playBackground.Cheem.Select.Textlabel.TextColor3 = Color3.fromRGB(174, 225, 255)
		playBackground.Cheem.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(68, 87, 99)
	else
		v = "Floppa"
		playBackground.Cheem.Select.UIStroke.Color = Color3.fromRGB(225, 225, 225)
		playBackground.Cheem.Select.Textlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		playBackground.Cheem.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
		playBackground.Floppa.Select.UIStroke.Color = Color3.fromRGB(255, 88, 88)
		playBackground.Floppa.Select.Textlabel.TextColor3 = Color3.fromRGB(255, 88, 88)
		playBackground.Floppa.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(100, 35, 35)
	end
end

task.spawn(FakeLoading)
renderSteppedConnection = RunService.RenderStepped:Connect(function()
	if loadingGui.Enabled == true then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.CFrame = workspace.CameraFolder.MenuCamera.CFrame
	end
end)
task.spawn(function()
	repeat
		wait(1)
	until localPlayer:GetAttribute("LoadedData")

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	Setup_Team()
	v3 = true
	playBackground.Load.Visible = false
	playBackground.Play.Visible = true
	playBackground.Setting.Visible = true
	playBackground.Leave.Visible = true
	playBackground.Cheem.Visible = true
	playBackground.Floppa.Visible = true
	playBackground.Teamlabel.Visible = true
	playBackground.MemeSeaLogo.Visible = true
end)
playBackground.Leave.Activated:Connect(function()
	if v2 == true then
		if localPlayer:GetAttribute("TH") then
			robloxPrompt.newConfirmationPrompt({
				title = "Meme Sea",
				image = "rbxassetid://13610434589",
				message = "คุณแน่ใจหรือไม่ว่าต้องการออกจากเกมนี้?",
				confirmtext = "ออก",
				canceltext = "ไม่ออก",
				canOverride = true
			}, function(p)
				if p == true then
					freeMoney:FireServer("Exit", "ลาก่อน :(")
				end
			end)
		else
			robloxPrompt.newConfirmationPrompt({
				title = "Meme Sea",
				image = "rbxassetid://13610434589",
				message = "Are you sure you want to leave the game?",
				confirmtext = "Leave",
				canceltext = "Don't Leave",
				canOverride = true
			}, function(p)
				if p == true then
					freeMoney:FireServer("Exit", "Good bye :(")
				end
			end)
		end
	end
end)
playBackground.Setting.Activated:Connect(function()
	if v2 == true then
		guiEvent:Fire({
			MenuName = "Settings",
			Action = "Open"
		})
	end
end)
playBackground.Play.Activated:Connect(function()
	if v == "Floppa" and localPlayer.PlayerGui.robloxPrompt:FindFirstChild("prompt") == nil then
		if v2 == true then
			v2 = false
			guiEvent:Fire({
				MenuName = "Menu",
				Action = "Close"
			})
			teamChoose:FireServer("Floppa")
			StartGame()
		end
	elseif v == "Cheem" and localPlayer.PlayerGui.robloxPrompt:FindFirstChild("prompt") == nil then
		if v2 == true then
			v2 = false
			guiEvent:Fire({
				MenuName = "Menu",
				Action = "Close"
			})
			teamChoose:FireServer("Cheems")
			StartGame()
		end
	elseif v == "None" then
		if localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[คุณยังไม่ได้เลือกทีม!]",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[No team selected!]",
				MessageColor = "Red"
			})
		end
	end
end)
playBackground.Floppa.Select.Activated:Connect(function()
	if tick() - lastTime >= 0.2 then
		if v == "Floppa" then
			lastTime = tick()
			ReplicatedStorage.Sound_Effect.Meow:Play()
			local rotation = playBackground.Floppa:GetAttribute("Rotation") == "Right" and -10 or 10
			local rotation2 = playBackground.Floppa:GetAttribute("Rotation") == "Right" and 10 or -10
			local tween = TweenService:Create(playBackground.Floppa, tweenInfo, {
				Rotation = rotation
			})
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(playBackground.Floppa, tweenInfo, {
				Rotation = rotation2
			})
			tween2:Play()
			tween2.Completed:Wait()
			TweenService:Create(playBackground.Floppa, tweenInfo, {
				Rotation = 0
			}):Play()

			if playBackground.Floppa:GetAttribute("Rotation") == "Right" then
				playBackground.Floppa:SetAttribute("Rotation", "Left")
			elseif playBackground.Floppa:GetAttribute("Rotation") == "Left" then
				playBackground.Floppa:SetAttribute("Rotation", "Right")
			end
		else
			lastTime = tick()
			v = "Floppa"
			ReplicatedStorage.Sound_Effect.Meow:Play()
			playBackground.Cheem.Select.UIStroke.Color = Color3.fromRGB(225, 225, 225)
			playBackground.Cheem.Select.Textlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			playBackground.Cheem.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
			playBackground.Floppa.Select.UIStroke.Color = Color3.fromRGB(255, 88, 88)
			playBackground.Floppa.Select.Textlabel.TextColor3 = Color3.fromRGB(255, 88, 88)
			playBackground.Floppa.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(100, 35, 35)
		end
	end
end)
playBackground.Cheem.Select.Activated:Connect(function()
	if tick() - lastTime >= 0.2 then
		if v == "Cheem" then
			lastTime = tick()
			ReplicatedStorage.Sound_Effect.Honk:Play()
			local rotation = playBackground.Cheem:GetAttribute("Rotation") == "Right" and -10 or 10
			local rotation2 = playBackground.Cheem:GetAttribute("Rotation") == "Right" and 10 or -10
			local tween = TweenService:Create(playBackground.Cheem, tweenInfo, {
				Rotation = rotation
			})
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(playBackground.Cheem, tweenInfo, {
				Rotation = rotation2
			})
			tween2:Play()
			tween2.Completed:Wait()
			TweenService:Create(playBackground.Cheem, tweenInfo, {
				Rotation = 0
			}):Play()

			if playBackground.Cheem:GetAttribute("Rotation") == "Right" then
				playBackground.Cheem:SetAttribute("Rotation", "Left")
			elseif playBackground.Cheem:GetAttribute("Rotation") == "Left" then
				playBackground.Cheem:SetAttribute("Rotation", "Right")
			end
		else
			lastTime = tick()
			v = "Cheem"
			ReplicatedStorage.Sound_Effect.Honk:Play()
			playBackground.Floppa.Select.UIStroke.Color = Color3.fromRGB(225, 225, 225)
			playBackground.Floppa.Select.Textlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			playBackground.Floppa.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
			playBackground.Cheem.Select.UIStroke.Color = Color3.fromRGB(174, 225, 255)
			playBackground.Cheem.Select.Textlabel.TextColor3 = Color3.fromRGB(174, 225, 255)
			playBackground.Cheem.Select.Textlabel.TextStrokeColor3 = Color3.fromRGB(68, 87, 99)
		end
	end
end)