local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local function tickFor(callback, p)
	local total = 0
	return (RunService.Heartbeat:Connect(function(dt)
		total += dt

		if p <= total then
			callback(p)
		else
			callback(total)
		end
	end))
end

local controller2 = {}

function controller2.Init(instance)
	controller2.instance = instance
	controller2.readyTime = nil
	instance.Intro.Arches.Visible = true
end

function controller2.Ready(readyTime)
	controller2.readyTime = readyTime
end

function controller2.RenderProgress(p: number)
	local instance = controller2.instance
	local playButton = instance.Intro.PlayButton
	local v2 = math.clamp(p / 10, 0, 1)
	local v3 = math.clamp(
		(controller2.readyTime == nil and 0 or math.min(os.clock() - controller2.readyTime, p - 10)) / 1,
		0,
		1
	)
	local imageTransparency = TweenService:GetValue(v3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local frame = instance.Intro.Arches.Frame
	frame.Left.Inner.UIGradient.Rotation = math.clamp(v2 / 0.5, 0, 1) * 90 + 91
	frame.Right.Inner.UIGradient.Rotation = math.clamp((v2 - 0.5) / 0.5, 0, 1) * 91
	frame.Right.Inner.Visible = v2 >= 0.5
	frame.Left.Inner.ImageTransparency = imageTransparency
	frame.Right.Inner.ImageTransparency = imageTransparency
	instance.Intro.Arches.FilledBackground.ImageTransparency = imageTransparency
	playButton.Visible = v3 > 0
	playButton.Play.ImageTransparency = 1 - imageTransparency
	playButton.Play.TextLabel.TextTransparency = 1 - imageTransparency
	playButton.Play.TextLabel.UIStroke.Transparency = 1 - imageTransparency
	playButton.Play.Backdrop.TextTransparency = 1 - imageTransparency
end

local controller3 = {}

function controller3.Init(instance)
	controller3.instance = instance
	controller3.readyTime = nil
	instance.Intro.Bar.Visible = true
end

function controller3.Ready(readyTime)
	controller3.readyTime = readyTime
end

function controller3.RenderProgress(p: number)
	local instance = controller3.instance
	local frame = instance.Intro.Bar.Frame
	local playButton = instance.Intro.PlayButton
	local v3 = math.clamp(p / 10, 0, 1)
	local v4 = math.clamp(
		(controller3.readyTime == nil and 0 or math.min(os.clock() - controller3.readyTime, p - 10)) / 1,
		0,
		1
	)
	local backgroundTransparency = TweenService:GetValue(v4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	frame.Frame.Size = UDim2.fromScale(v3, 1)
	frame.BackgroundTransparency = backgroundTransparency
	frame.Frame.BackgroundTransparency = backgroundTransparency
	playButton.Visible = v4 > 0
	playButton.Play.ImageTransparency = 1 - backgroundTransparency
	playButton.Play.TextLabel.TextTransparency = 1 - backgroundTransparency
	playButton.Play.TextLabel.UIStroke.Transparency = 1 - backgroundTransparency
	playButton.Play.Backdrop.TextTransparency = 1 - backgroundTransparency
end

local function fadeOutTick(p, p2)
	local value = TweenService:GetValue(p2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	p.Intro.PlayButton.Play.ImageTransparency = value
	p.Intro.PlayButton.Play.Controller.ImageTransparency = value
	p.Intro.PlayButton.Play.TextLabel.TextTransparency = value
	p.Intro.PlayButton.Play.TextLabel.UIStroke.Transparency = value
	p.Intro.PlayButton.Play.Backdrop.TextTransparency = value

	if p.Intro.UpdatesImages.Visible then
		p.Intro.UpdatesImages.Frame.BackgroundTransparency = 0.3 + value * 0.7

		for _, guiObject in p.Intro.UpdatesImages:GetDescendants() do
			if guiObject:IsA("TextLabel") then
				guiObject.TextTransparency = value
			elseif guiObject:IsA("ImageLabel") then
				guiObject.ImageTransparency = value
			end
		end
	end

	p.Intro.Brookhaven.TextLabel.TextTransparency = value
	p.Intro.Brookhaven.TextLabel.UIStroke.Transparency = value
	p.Intro.Brookhaven.ImageLabel.ImageTransparency = value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeOut(p)
	local function fn(p2)
		fadeOutTick(p, p2)
	end

	local total = 0
	local v3 = 1
	return (RunService.Heartbeat:Connect(function(dt)
		total += dt

		if v3 <= total then
			fn(v3)
		else
			fn(total)
		end
	end))
end

local v3 = {
	ARCHES = {
		controller = controller2,
		shopVisibility = false,
		updatesImageVisibility = false
	},
	IMAGE = {
		controller = controller2,
		shopVisibility = false,
		updatesImageVisibility = true
	},
	SHOP = {
		controller = controller3,
		shopVisibility = true,
		updatesImageVisibility = false
	}
}

local function start()
	local ReplicatedFirst = game:GetService("ReplicatedFirst")
	local LoadingABTest = require(ReplicatedFirst.LoadingABTest)
	local test = LoadingABTest.GetTest()

	if test == "CONTROL" then
		return
	end

	local GameInitShared = require(ReplicatedFirst.GameInitShared)
	GameInitShared.Setup()
	GuiService.TouchControlsEnabled = false
	local EventFunnelController = require(ReplicatedFirst:WaitForChild("EventFunnelController"))
	local IntroCameraMediator = require(ReplicatedFirst:WaitForChild("IntroCameraMediator"))
	EventFunnelController.informLoadingEvent("beginIntroScript")
	local Players = game:GetService("Players")
	local updates = ReplicatedFirst:WaitForChild("Updates")
	local newUpdateArches = updates:FindFirstChild("NewUpdateArches")

	if newUpdateArches == nil then
		warn("ChangeLogController: No target change log found", "NewUpdateArches")
		updates:Destroy()
	else
		newUpdateArches.Intro.UpdatesImages.Visible = v3[test].updatesImageVisibility
		local shops = { newUpdateArches.Intro.PlayButton.Play }
		local shopVisibility = v3[test].shopVisibility

		if shopVisibility then
			newUpdateArches.Intro.PlayButton.Shop.Visible = true
			table.insert(shops, newUpdateArches.Intro.PlayButton.Shop)
		end

		local controller = v3[test].controller
		controller.Init(newUpdateArches)
		controller.RenderProgress(0)
		newUpdateArches.Name = "IntroGui"
		newUpdateArches.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		task.spawn(function()
			ContentProvider:PreloadAsync(shops)
		end)
		updates:Destroy()
		local ContextActionService = game:GetService("ContextActionService")
		local UserInputService = game:GetService("UserInputService")
		local Workspace = game:GetService("Workspace")
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local flag = true
		local character = localPlayer.Character

		if not character or character.Parent == nil then
			character = localPlayer.CharacterAdded:Wait()
		end

		local thread = task.spawn(function()
			while not pcall(function()
				game.StarterGui:SetCore("ResetButtonCallback", false)
			end) do
				task.wait()
			end
		end)
		EventFunnelController.informLoadingEvent("waitingForGui")
		local introGui = playerGui:WaitForChild("IntroGui")
		local music = introGui:WaitForChild("Music")
		local intro = introGui:WaitForChild("Intro")
		local playButton = intro:WaitForChild("PlayButton")
		EventFunnelController.informLoadingEvent("waitingForCharacter")
		local currentCamera = game.Workspace.CurrentCamera
		local humanoid = character:WaitForChild("Humanoid")
		local connections = {}
		local total = 0
		table.insert(connections, RunService.Heartbeat:Connect(function(dt)
			if not character:FindFirstChild("Head") then
				return
			end

			currentCamera.CameraType = "Scriptable"
			currentCamera.CameraSubject = character.Head
			currentCamera.CoordinateFrame = CFrame.new(character.Head.Position) * CFrame.Angles(0, total, 0) * CFrame.new(
				0,
				0,
				10
			)
			total += math.rad(dt * 30)
		end))
		EventFunnelController.informLoadingEvent("openingIntroGui")
		humanoid.JumpPower = 0
		humanoid.WalkSpeed = 0
		music:Play()

		local function LowerMusic()
			local tween = TweenService:Create(
				music,
				TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Volume = 0
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				music:Stop()
			end)
		end

		local function doPlay(flag2: boolean)
			if not flag then
				return
			end

			for _, connection in connections do
				connection:Disconnect()
			end

			ContextActionService:UnbindAction("IntroCameraPlayConsoleAction")

			if shopVisibility then
				ContextActionService:UnbindAction("IntroCameraShopConsoleAction")
			end

			EventFunnelController.informLoadingEvent("playButtonClicked")
			flag = false
			LowerMusic()
			GuiService.TouchControlsEnabled = true
			localPlayer.Character.UpperTorso.Anchored = false
			localPlayer.Character.Humanoid.JumpPower = 50
			localPlayer.Character.Humanoid.WalkSpeed = 16
			local humanoid2 = localPlayer.Character:FindFirstChild("Humanoid")

			if humanoid2 ~= nil then
				Workspace.CurrentCamera.CameraSubject = humanoid2
				Workspace.CurrentCamera.CameraType = "Custom"
			end

			if intro ~= nil then
				intro.Active = false
			end

			task.cancel(thread)
			task.spawn(function()
				while not pcall(function()
					game.StarterGui:SetCore("ResetButtonCallback", true)
				end) do
					task.wait()
				end
			end)
			local connection = nil

			if flag2 then
				fadeOutTick(introGui, 1)
			else
				connection = fadeOut(introGui)
				task.wait(0.55)
			end

			GameInitShared.ShowUI()
			task.spawn(GameInitShared.PostPlay)

			if introGui.Parent ~= nil then
				task.spawn(function()
					task.wait(2)

					if connection ~= nil then
						connection:Disconnect()
					end

					introGui:Destroy()
					introGui = nil
				end)
			end
		end

		table.insert(connections, playButton.Play.Activated:Connect(function()
			doPlay(false)
		end))
		local v4 = {}
		local v5 = {}
		table.insert(connections, RunService.RenderStepped:Connect(function(dt)
			for k, v6 in v4 do
				if v5[k] == nil then
					v5[k] = 0
				end

				local v7

				if v6 then
					v7 = dt
				else
					v7 = -dt
				end

				v5[k] = math.clamp(v5[k] + v7, 0, 0.2)
				local v8 = 1 + TweenService:GetValue(v5[k] / 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out) * 0.05
				k.Size = UDim2.fromScale(v8, v8)
			end
		end))
		local play = playButton.Play
		table.insert(connections, play.MouseEnter:Connect(function()
			v4[play] = true
		end))
		table.insert(connections, play.MouseLeave:Connect(function()
			v4[play] = false
		end))

		local function openShop()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
			local ShopTelemetrySource = require(ReplicatedStorage.Modules.Client.UI.ShopTelemetrySource)
			local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
			TelemetryController.SendClientInteraction("uiInteraction", {
				buttonName = "IntroShopButton",
				inVehicle = false
			})
			ShopTelemetrySource.Set("intro")
			PanelController.OpenPanelByContext("MainGUIHandler", "ShopAndFeatured")
		end

		if shopVisibility then
			table.insert(connections, playButton.Shop.Activated:Connect(function()
				doPlay(false)
				openShop()
			end))
			local shop = playButton.Shop
			table.insert(connections, shop.MouseEnter:Connect(function()
				v4[shop] = true
			end))
			table.insert(connections, shop.MouseLeave:Connect(function()
				v4[shop] = false
			end))
		end

		if intro ~= nil then
			intro.Active = true
		end

		if RunService:IsStudio() then
			controller.Ready(-100)
			controller.RenderProgress(11)
		else
			local renderProgress = controller.RenderProgress
			local total2 = 0
			local v6 = 11
			table.insert(connections, (RunService.Heartbeat:Connect(function(dt)
				total2 += dt

				if v6 <= total2 then
					renderProgress(v6)
				else
					renderProgress(total2)
				end
			end)))
		end

		if RunService:IsStudio() then
			local inputBeganConnection = nil
			inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.KeyCode == Enum.KeyCode.F5 then
					inputBeganConnection:Disconnect()

					if flag then
						controller.Ready(-100)
						controller.RenderProgress(11)
						doPlay(true)
					end
				end
			end)
		end

		IntroCameraMediator.setSkipIntroHandler(function()
			if flag then
				controller.Ready(-100)
				controller.RenderProgress(11)
				doPlay(true)
			end
		end)

		if not RunService:IsStudio() then
			task.wait(9.9)
			GameInitShared.SdkWait()
			controller.Ready(os.clock())
		end

		GameInitShared.CheckWeather()
		EventFunnelController.informLoadingEvent("playButtonShown")
		ContextActionService:BindActionAtPriority("IntroCameraPlayConsoleAction", function(_, p)
			if p ~= Enum.UserInputState.Begin or not flag then
				return Enum.ContextActionResult.Pass
			end

			doPlay(false)
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonA)

		if shopVisibility then
			ContextActionService:BindActionAtPriority("IntroCameraShopConsoleAction", function(_, p)
				if p ~= Enum.UserInputState.Begin or not flag then
					return Enum.ContextActionResult.Pass
				end

				doPlay(false)
				openShop()
				return Enum.ContextActionResult.Sink
			end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonY)
		end
	end
end

start()