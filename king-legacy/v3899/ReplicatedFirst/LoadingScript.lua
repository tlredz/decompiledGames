script.Parent:RemoveDefaultLoadingScreen()

while not game.Loaded do
	wait()
end

while not _G.PU do
	task.wait(0.03333333333333333)
end

local Lighting = game:GetService("Lighting")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
require(modules.WorldsId)
require(modules.TipsTable)
local FruitList = require(modules.FruitList)
local PeodizService = require(modules.PeodizService)
local GoldenArena = require(script:WaitForChild("GoldenArena"))
local v = {}

for k, _ in pairs(FruitList) do
	table.insert(v, k)
end

local v2 = nil
local connections = {}
local island = workspace:WaitForChild("Island")
local v3 = island:FindFirstChild("TeamCameraPart")

if not v3 then
	v3 = Instance.new("Part")
	v3.Anchored = true
	v3.Parent = island
end

local localPlayer = game.Players.LocalPlayer
localPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera
currentCamera.CameraType = Enum.CameraType.Scriptable
currentCamera.CFrame = v3.CFrame

function PreloadAsync()
	script:WaitForChild("Sounds")
	ContentProvider:PreloadAsync({
		script.Sounds.SpawnSound,
		script.Sounds.Book,
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("FruitEating"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("DoughDough"):WaitForChild("AnimationBeck"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("DodgeAnimation"):WaitForChild("Dodge1"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("DodgeAnimation"):WaitForChild("Dodge2"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("DodgeAnimation"):WaitForChild("Dodge3"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("DodgeAnimation"):WaitForChild("Dodge4"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("DodgeAnimation"):WaitForChild("Dodge5"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("GaleFist"):WaitForChild("Cutscene"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("GaleFist"):WaitForChild("Awake"),
		ReplicatedStorage.Chest:WaitForChild("Animation"):WaitForChild("Chaos Crab"):WaitForChild("Intro")
	})
end

if GoldenArena[game.PlaceId] then
	return
end

task.defer(function()
	PreloadAsync()
end)

function SetupLoadingGui()
	local clone = script:WaitForChild("LoadingGUI"):Clone()
	clone.Enabled = true
	clone.Logo.ImageTransparency = 1
	clone.Background.ImageTransparency = 1
	clone.TipsTextLabel.TextTransparency = 1
	clone.Play.Size = UDim2.new()
	clone.Frame.Size = UDim2.fromOffset(currentCamera.ViewportSize.X * 2, currentCamera.ViewportSize.Y * 2)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSize()
		local _, _ = pcall(function()
			local X = currentCamera.ViewportSize.X
			local Y = currentCamera.ViewportSize.Y
			local v4 = X * 2
			local v5 = Y * 2
			clone.Background.Size = UDim2.new(0, v4, 0, v5)

			if not v2 then
				clone.Frame.Size = UDim2.fromOffset(v4, v5)
			end
		end)
	end

	local _, _ = pcall(function()
		local X = currentCamera.ViewportSize.X
		local Y = currentCamera.ViewportSize.Y
		local v4 = X * 2
		local v5 = Y * 2
		clone.Background.Size = UDim2.new(0, v4, 0, v5)

		if not v2 then
			clone.Frame.Size = UDim2.fromOffset(v4, v5)
		end
	end)
	table.insert(connections, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		UpdateSize() -- equivalent call inferred; original call site unknown
	end))
	return clone
end

function PreloadLoadingGuiImageId(instance)
	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("ImageLabel") then
			ContentProvider:Preload(child.Image)
			children[#children + 1] = child
		elseif child:IsA("Sound") then
			ContentProvider:Preload(child.SoundId)
			children[#children + 1] = child
		end
	end

	ContentProvider:PreloadAsync(children)
	return children
end

function FreezeCharacter()
	if localPlayer.Character then
		local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
		humanoidRootPart.Anchored = true
	end
end

function SetupCharacterLoading()
	table.insert(connections, localPlayer.CharacterAdded:Connect(function(_)
		pcall(FreezeCharacter)
	end))
end

pcall(FreezeCharacter)
SetupCharacterLoading()
local parent = SetupLoadingGui()
parent.Parent = localPlayer.PlayerGui
local v5 = PreloadLoadingGuiImageId(parent)
Random.new():NextNumber(4, 7)

function HideAllGui()
	local enabledsByScreenGui = {}

	for _, screenGui in pairs(localPlayer.PlayerGui:GetChildren()) do
		if screenGui:IsA("ScreenGui") and screenGui ~= parent then
			enabledsByScreenGui[screenGui] = screenGui.Enabled
		end
	end

	for _, screenGui in pairs(localPlayer.PlayerGui:GetChildren()) do
		if screenGui:IsA("ScreenGui") and screenGui ~= parent then
			screenGui.Enabled = false
		end
	end

	table.insert(connections, localPlayer.PlayerGui.ChildAdded:Connect(function(screenGui)
		if screenGui:IsA("ScreenGui") and screenGui ~= parent and screenGui.Name ~= "TeleportFarGui" then
			enabledsByScreenGui[screenGui] = screenGui.Enabled
			screenGui.Enabled = false
		end
	end))
	return enabledsByScreenGui
end

function ShowAllGui(p)
	for _, child in pairs(localPlayer.PlayerGui:GetChildren()) do
		if p[child] then
			child.Enabled = p[child]
		end
	end
end

local v6 = HideAllGui()

function HideLoadingScreen()
	task.spawn(function()
		TweenService:Create(parent.Background, TweenInfo.new(0.1, Enum.EasingStyle.Circular), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(parent.Logo, TweenInfo.new(0.1, Enum.EasingStyle.Circular), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(parent.TipsTextLabel, TweenInfo.new(0.1, Enum.EasingStyle.Circular), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		task.spawn(function()
			wait(0.25)

			if parent:FindFirstChild("Frame") then
				v2 = true
				TweenService:Create(parent.Frame, TweenInfo.new(1, Enum.EasingStyle.Circular), {
					Size = UDim2.new()
				}):Play()
			end
		end)
	end)
end

table.insert(connections, localPlayer:GetAttributeChangedSignal("Teleporting"):Connect(function()
	if localPlayer:GetAttribute("Teleporting") ~= nil then
		parent.Play.Visible = false
	end
end))

function StartLoadingScreen()
	local TipsTable = require(ReplicatedStorage.Chest.Modules.TipsTable)
	local v7 = TipsTable[math.random(1, #TipsTable)]
	parent.TipsTextLabel.Text = "<font color=\"#00aa00\">[Tips]</font> " .. v7
	local play = parent.Play
	task.delay(2, function()
		if not localPlayer:GetAttribute("Teleporting") then
			play.Visible = true
			TweenService:Create(play, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
				Size = UDim2.new(0.211, 0, 0.107, 0)
			}):Play()
		end
	end)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "TeamBlur"
	blurEffect.Size = 15
	blurEffect.Enabled = true
	blurEffect.Parent = Lighting
	local flag = true
	table.insert(connections, play.MouseButton1Click:Connect(function()
		if not flag then
			return
		end

		flag = nil
		local soundClick = script.Sounds.SoundClick

		if soundClick.IsPlaying then
			soundClick:Stop()
		end

		soundClick:Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 20,
				WaitTime = 0.15
			}, function(_)
				if not v or #v <= 0 then
					return
				end

				local v8 = v[math.random(#v)]
				local v9 = math.random(10, 50) / 100
				local imageLabel = Instance.new("ImageLabel")
				_G.PU:Dust(imageLabel, 2)
				imageLabel.Image = FruitList[v8]
				imageLabel.Size = UDim2.new(v9, 0, v9, 0)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Rotation = 0
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Position = UDim2.new(math.random(5, 95) / 100, 0, -0.5, 0)
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.Parent = parent
				TweenService:Create(imageLabel, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					Position = UDim2.new(imageLabel.Position.X.Scale, 0, 1.5, 0),
					Rotation = math.random(-360, 360)
				}):Play()
			end)
		end)
		HideLoadingScreen()
		play.Size = UDim2.new(0.211, 0, 0.107, 0)
		TweenService:Create(play, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new()
		}):Play()
		task.delay(0.6, function()
			play.Visible = nil
		end)
		task.wait(1.05)
		parent.LoadingFrame.Visible = true
		task.defer(function()
			while true do
				local v8 = task.wait()

				if not parent.Parent or localPlayer:FindFirstChild("DataLoaded") then
					break
				end

				local imageLabel = parent.LoadingFrame.ImageLabel
				local v9 = v8 * 60
				imageLabel.Rotation += v9 * 3 % 360
			end
		end)
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EnterTheGame", {})
	end))
	table.insert(connections, play.MouseEnter:Connect(function()
		if not flag then
			return
		end

		_G.ShineGui({
			Parent = play,
			ZIndex = 5,
			CornerRadius = UDim2.new(0.1, 0)
		})
		local soundIn = script.Sounds.SoundIn

		if soundIn.IsPlaying then
			soundIn:Stop()
		end

		soundIn:Play()
		task.spawn(function()
			local lastTime = tick()
			PeodizService.HeartbeatWait({
				Time = 60
			}, function(_)
				if not flag or not play or play and not play.Parent or not play:FindFirstChild("UIStroke") then
					return true
				end

				if not play.UIStroke.Enabled then
					return true
				end

				task.spawn(function()
					if tick() - lastTime > 0.5 then
						lastTime = tick()
						local v8 = v[math.random(#v)]
						local v9 = math.random(10, 50) / 100
						local imageLabel = Instance.new("ImageLabel")
						_G.PU:Dust(imageLabel, 3)
						imageLabel.Image = FruitList[v8]
						imageLabel.Size = UDim2.new(v9, 0, v9, 0)
						imageLabel.BackgroundTransparency = 1
						imageLabel.Rotation = 0
						imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
						imageLabel.Position = UDim2.new(math.random(5, 95) / 100, 0, -0.5, 0)
						imageLabel.ScaleType = Enum.ScaleType.Fit
						imageLabel.Parent = parent
						TweenService:Create(imageLabel, TweenInfo.new(2, Enum.EasingStyle.Linear), {
							Position = UDim2.new(imageLabel.Position.X.Scale, 0, 1.5, 0),
							Rotation = math.random(-360, 360),
							ImageTransparency = 1
						}):Play()
						task.delay(1, function()
							if imageLabel and imageLabel.Parent then
								TweenService:Create(imageLabel, TweenInfo.new(0.5), {
									ImageTransparency = 1
								}):Play()
							end
						end)
					end
				end)
				local _ = task.wait() * 60
				play.Rotation = math.sin(tick() * 10) * 3
				play.UIStroke.Thickness = math.sin(tick() * 5) * 4
			end)
			play.Rotation = 0
		end)
		play.Size = UDim2.new(0.211, 0, 0.107, 0)
		play.UIStroke.Enabled = true
		TweenService:Create(play, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.26375, 0, 0.13375, 0)
		}):Play()
	end))
	table.insert(connections, play.MouseLeave:Connect(function()
		if not flag then
			return
		end

		play.UIStroke.Enabled = nil
		play.Rotation = 0
		TweenService:Create(play, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = UDim2.new(0.211, 0, 0.107, 0)
		}):Play()
	end))
	TweenService:Create(parent.Logo, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(parent.Background, TweenInfo.new(2, Enum.EasingStyle.Circular), {
		ImageTransparency = 0.95
	}):Play()
	TweenService:Create(
		parent.Background,
		TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 10, true, 0),
		{
			Position = UDim2.new(1, 0, 1, 0)
		}
	):Play()
	TweenService:Create(parent.TipsTextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		TextTransparency = 0
	}):Play()
	local uIGradient = parent.Logo.UIGradient
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local now = 0
	local now2 = 0

	while true do
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = v3.CFrame

		if flag then
			if tick() - now > 0.9 then
				now = tick()
				TweenService:Create(
					parent.Logo,
					TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = UDim2.new(0.5, 0, 0.5, 0)
					}
				):Play()
				local clone = script.ClickFrame:Clone()
				clone.Size = UDim2.new()
				clone.Parent = parent
				_G.PU:Dust(clone, 0.75)
				TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
					Size = UDim2.new(1, 0, 1, 0),
					ImageTransparency = 1
				}):Play()
				task.delay(0.7, function()
					if not parent:IsDescendantOf(localPlayer.PlayerGui) then
						return
					end

					TweenService:Create(
						parent.Logo,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = UDim2.new(0.425, 0, 0.425, 0)
						}
					):Play()
				end)
			end

			if tick() - now2 > 1.5 then
				now2 = tick()
				uIGradient.Offset = Vector2.new(1.5, 0)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(uIGradient, TweenInfo.new(1.5, Enum.EasingStyle.Circular), {
					Offset = Vector2.new(-1, 0)
				}):Play()
			end
		end

		if localPlayer:FindFirstChild("DataLoaded") then
			task.wait(0.1)
			local clone = ReplicatedStorage.Chest.Gui.TeleportFarGui:Clone()
			_G.PU:Dust(clone, 5)
			clone.Parent = localPlayer.PlayerGui
			task.delay(1.25, function()
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = localPlayer.Character

				if character then
					pcall(function()
						currentCamera.CameraSubject = character:WaitForChild("Humanoid")
					end)
					pcall(function()
						local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
						humanoidRootPart.Anchored = false
					end)
				end

				blurEffect:Destroy()
			end)
			break
		else
			task.wait()
		end
	end
end

StartLoadingScreen()
ShowAllGui(v6)

for _, connection in pairs(connections) do
	if connection.Connected then
		connection:Disconnect()
	end
end

parent:Destroy()
v3:Destroy()
table.clear(v5)
table.clear(v)