local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./SettingsController")
local module2 = require("./HudController")
local remoteFunction = Net:RemoteFunction("LureShake/Start")
local remoteEvent = Net:RemoteEvent("LureShake/Stop")
local remoteEvent2 = Net:RemoteEvent("LureShake/Shake")
local sfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx")
local customshakes = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("customshakes")
local LureShakeController = {
	Trove = Trove.new()
}
local random = Random.new()
local v = { Enum.KeyCode.Return, Enum.KeyCode.ButtonA }
local v2 = { Enum.KeyCode.ButtonB, Enum.KeyCode.Backspace }

-- equivalent calls inferred from this helper; original call sites unknown
local function isChatActive()
	local success, core = pcall(StarterGui.GetCore, StarterGui, "ChatActive")
	return success and core
end

local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function removeSelection()
	if GuiService.SelectedObject ~= nil then
		v3 = true
		GuiService.SelectedObject = nil
	end

	if GamepadService.GamepadCursorEnabled then
		GamepadService:DisableGamepadCursor()
	end
end

function LureShakeController:GetRandomPosition(p, point: Vector2)
	local number = random:NextNumber(0, 1)
	local number2 = random:NextNumber(0, 1)
	local chatWindowConfiguration = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
	local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

	if not (chatWindowConfiguration and chatInputBarConfiguration and chatWindowConfiguration.Enabled) then
		return UDim2.fromScale(number, number2)
	end

	if not isChatActive() then
		return UDim2.fromScale(number, number2)
	end

	local absolutePosition = p.AbsolutePosition
	local v4 = absolutePosition + p.AbsoluteSize
	local absolutePosition2 = chatWindowConfiguration.AbsolutePosition
	local _ = absolutePosition2 - point / 2
	local v5 = chatWindowConfiguration.AbsoluteSize + chatInputBarConfiguration.AbsoluteSize * Vector2.yAxis + point / 2
	local v6 = math.map(absolutePosition2.X + v5.X, absolutePosition.X, v4.X, 0, 1)
	local v7 = math.map(absolutePosition2.Y + v5.Y, absolutePosition.Y, v4.Y, 0, 1)

	if number < v6 and number2 < v7 then
		number = v6
	end

	return UDim2.fromScale(number, number2)
end

function LureShakeController:Cancel()
	LureShakeController.Trove:Clean()
	remoteEvent:FireServer()
end

function LureShakeController:StartMinigame(data)
	local random2 = Random.new(data.seed)
	local initialTimer = data.initialTimer
	local v4 = initialTimer
	local scale = 1 * (not data and 1 or data.ShakeScale or 1)
	local v6 = 0.25 / scale
	local tweenInfo = TweenInfo.new(v6, Enum.EasingStyle.Quint)
	local trove = LureShakeController.Trove
	trove:Clean()
	local clone = script.shakeui:Clone()
	local v7 = customshakes:FindFirstChild(data.ButtonName or "default") or customshakes.default
	local clickSound = v7:FindFirstChild("clickSound") or sfx.ui.popclick
	local clone2 = v7:Clone()
	clone2.UIScale.Scale = scale
	clone2.Parent = clone.safezone
	clone.Enabled = false
	clone.Parent = module2:GetPlayerGui()
	local absoluteSize = clone2.AbsoluteSize
	local lastTime = tick()
	clone2.UIScale.Scale = 0
	clone2.Position = LureShakeController:GetRandomPosition(clone.safezone, absoluteSize)
	clone.Enabled = true
	removeSelection() -- equivalent call inferred; original call site unknown
	trove:Connect(GuiService:GetPropertyChangedSignal("SelectedObject"), removeSelection)
	trove:Connect(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"), removeSelection)
	trove:Add(clone)

	if module:GetSettingValue("showShakeProgress") then
		local clone3 = script.shakeProgress:Clone()
		clone3.UIScale.Scale = 0
		clone3.Parent = clone.safezone
		TweenService:Create(clone3.UIScale, TweenInfo.new(0.35, Enum.EasingStyle.Circular), {
			Scale = 1
		}):Play()
		trove:Add(RunService.Heartbeat:Connect(function(dt)
			v4 -= dt
			local v8 = math.clamp(1 - v4 / initialTimer, 0, 1)
			clone3.Bar.Size = UDim2.fromScale(v8, 1)
		end))
	end

	local function onShake()
		if v6 < tick() - lastTime then
			lastTime = tick()
			remoteEvent2:FireServer()
			local v9 = random2:NextNumber(0.5, 1.5) * data.ShakePower
			v4 -= v9
			local position = clone2.Position
			clone2.UIScale.Scale = scale * 0.6
			TweenService:Create(clone2, tweenInfo, {
				Position = LureShakeController:GetRandomPosition(clone.safezone, absoluteSize)
			}):Play()
			TweenService:Create(clone2.UIScale, tweenInfo, {
				Scale = scale
			}):Play()
			local shakeProgress = clone.safezone:FindFirstChild("shakeProgress")

			if shakeProgress then
				shakeProgress.UIScale.Scale = 0.85
				TweenService:Create(shakeProgress.UIScale, TweenInfo.new(1, Enum.EasingStyle.Quint), {
					Scale = 1
				}):Play()
			end

			fx:PlaySound(clickSound, clone, true, "FishingSound", localPlayer)
			task.spawn(function()
				local clone3 = script.ripple:Clone()
				clone3.Position = position
				clone3.UIScale.Scale = scale
				clone3.Parent = clone.safezone
				local tween = TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					ImageTransparency = 1
				})
				TweenService:Create(clone3.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
					Scale = scale * 2
				}):Play()
				tween:Play()
				tween.Completed:Wait()
				clone3:Destroy()
			end)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateStroke()
		clone2.consoleStroke.Enabled = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad or v3
	end

	updateStroke() -- equivalent call inferred; original call site unknown
	trove:Connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), updateStroke)
	trove:Connect(GuiService:GetPropertyChangedSignal("SelectedObject"), updateStroke)
	trove:Connect(clone2.Activated, onShake)
	local v8 = clone2.consoleStroke:FindFirstChild("UIGradient") ~= nil
	trove:Connect(RunService.RenderStepped, function(p)
		if clone2.consoleStroke.Enabled and v8 then
			clone2.consoleStroke.UIGradient.Rotation += p * 180
		end
	end)

	local function clickCallback(_, p, _)
		if p ~= Enum.UserInputState.Begin or UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		v3 = true
		onShake()
		updateStroke() -- equivalent call inferred; original call site unknown
		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"LureShakeClick",
		clickCallback,
		false,
		Enum.ContextActionPriority.High.Value + 5000,
		table.unpack(v)
	)

	local function cancelCallback(_, p, _)
		if p ~= Enum.UserInputState.Begin or UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		LureShakeController:Cancel()
		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"LureShakeCancel",
		cancelCallback,
		false,
		Enum.ContextActionPriority.Low.Value + 1,
		table.unpack(v2)
	)
	trove:Add(function()
		ContextActionService:UnbindAction("LureShakeClick")
		ContextActionService:UnbindAction("LureShakeCancel")
	end)
	TweenService:Create(clone2.UIScale, tweenInfo, {
		Scale = scale
	}):Play()
end

function LureShakeController.Start(_)
	local chatInputBarConfiguration = TextChatService:WaitForChild("ChatInputBarConfiguration")

	remoteFunction.OnClientInvoke = function(p)
		if module:GetSettingValue("toggleShakeChat") then
			TextChatService.ChatWindowConfiguration.Enabled = false
			chatInputBarConfiguration.Enabled = false
		end

		LureShakeController:StartMinigame(p)
	end

	remoteEvent.OnClientEvent:Connect(function()
		LureShakeController.Trove:Clean()

		if module:GetSettingValue("toggleShakeChat") then
			TextChatService.ChatWindowConfiguration.Enabled = true
			chatInputBarConfiguration.Enabled = chatInputBarConfiguration.TargetTextChannel.Name ~= "Events" and chatInputBarConfiguration.TargetTextChannel.Name ~= "Catches"
		end
	end)
end

return LureShakeController