game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage2.SharedUtils.InputService)
local GingerMeterController = require(ReplicatedStorage.Modules.ClientUI.GingerMeterController)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local tower = TowerLUT:GetTower("Ginger")
local module = require(tower)
local GingerPromptController = {}
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = {}
local flag2 = false
local v7 = nil
local v8 = nil
local v9 = nil
local flag3 = false
local v10 = nil
local lastTime = nil
local renderSteppedConnection = nil
local v11 = false
local v12 = nil
local flag4 = false
local v13 = false
local gingerHealChannel = nil
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function isGingerHealPrompt(p)
	if p then
		return p.Name == "GingerHealPrompt"
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPromptOnSelf(p)
	if not p then
		return false
	end

	local parent = p.Parent and p.Parent.Parent
	return parent and parent == v2
end

local function getDynamicTapeCost()
	local count = 0
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in ipairs(inGamePlayers:GetChildren()) do
			if TowerLUT:GetEffectiveTower(child) == tower then
				count += 1
			end
		end
	end

	return not (count > 1) and 100 or (count - 1) * 50 + 100
end

local function canUseAbility()
	if v2 then
		local abilities = v2:FindFirstChild("Abilities")
		local ability1 = abilities and abilities:FindFirstChild("Ability1")

		if ability1 then
			local currentCooldown = ability1:FindFirstChild("CurrentCooldown")

			if currentCooldown and currentCooldown.Value > 0 then
				return false, "That Ability is on Cooldown!"
			end
		end
	end

	local child = v and workspace.Info.PlayerStats:FindFirstChild(v.Name)

	if not child then
		return true, nil
	end

	local survivalPoints = child:FindFirstChild("SurvivalPoints")
	local dynamicTapeCost = getDynamicTapeCost()

	if survivalPoints and survivalPoints.Value < dynamicTapeCost then
		return false, "Not enough Tapes! (Need " .. dynamicTapeCost .. ")"
	end

	return true, nil
end

local function fn2()
	if flag2 or not (v3 and v3:FindFirstChild("Ability1")) then
		return
	end

	flag2 = true
	local ability1 = v3.Ability1
	local v14 = ability1:FindFirstChild("HoldReadyText")

	if not v14 then
		v14 = Instance.new("TextLabel")
		v14.Name = "HoldReadyText"
		v14.Size = UDim2.new(1, 0, 0.4, 0)
		v14.Position = UDim2.new(0, 0, -0.45, 0)
		v14.BackgroundTransparency = 1
		v14.Text = "HOLD!"
		v14.TextColor3 = Color3.fromRGB(100, 255, 100)
		v14.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		v14.TextStrokeTransparency = 0
		v14.Font = Enum.Font.GothamBold
		v14.TextScaled = true
		v14.ZIndex = 11
		v14.Parent = ability1
	end

	v14.TextTransparency = 0
	local parent = ability1:FindFirstChild("ReadyPulse")

	if not parent then
		parent = Instance.new("Frame")
		parent.Name = "ReadyPulse"
		parent.Size = UDim2.new(1, 0, 1, 0)
		parent.Position = UDim2.new(0, 0, 0, 0)
		parent.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		parent.BackgroundTransparency = 0.8
		parent.BorderSizePixel = 0
		parent.ZIndex = 10
		parent.Parent = ability1
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.15, 0)
		uICorner.Parent = parent
	end

	parent.Visible = true
	parent.BackgroundTransparency = 0.8
	v7 = TweenService:Create(parent, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		BackgroundTransparency = 0.4
	})
	v7:Play()
end

local function fn3()
	flag2 = false

	if v7 then
		v7:Cancel()
		v7 = nil
	end

	if v3 and v3:FindFirstChild("Ability1") then
		local ability1 = v3.Ability1
		local holdReadyText = ability1:FindFirstChild("HoldReadyText")

		if holdReadyText then
			holdReadyText.TextTransparency = 1
		end

		local readyPulse = ability1:FindFirstChild("ReadyPulse")

		if readyPulse then
			readyPulse.Visible = false
		end
	end
end

local function fn4(parent)
	if v8 then
		fn()
	end

	v9 = parent
	local targetBeam = ReplicatedStorage.Parts.RenderParts.Ginger:FindFirstChild("targetBeam")
	local playerRadius = v4 and v4.PlayerRadius or module.HealRange
	v8 = GingerMeterController.create(parent, targetBeam, playerRadius)

	if v8 and v8.billboard then
		local textLabel = v8.billboard:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Text = "HOLD!"
		end

		GingerMeterController.start(v8, 3)
	end

	local cooldownFrame = v3 and v3:FindFirstChild("Ability1") and v3.Ability1:FindFirstChild("CooldownFrame")

	if cooldownFrame then
		cooldownFrame.AnchorPoint = Vector2.new(0, 1)
		cooldownFrame.Position = UDim2.new(0, 0, 1, 0)
		cooldownFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		cooldownFrame.Size = UDim2.new(1, 0, 0, 0)
		cooldownFrame.Visible = true
	end
end

fn = function()
	if v8 then
		local v14 = v8
		v8 = nil
		v9 = nil
		pcall(function()
			GingerMeterController.cancel(v14)
		end)
	end

	local cooldownFrame = v3 and v3:FindFirstChild("Ability1") and v3.Ability1:FindFirstChild("CooldownFrame")

	if cooldownFrame then
		cooldownFrame.AnchorPoint = Vector2.new(0, 0)
		cooldownFrame.Position = UDim2.new(0, 0, 0, 0)
		cooldownFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cooldownFrame.Visible = false
	end
end

local function fn5()
	if v8 then
		local v14 = v8
		v8 = nil
		v9 = nil
		task.delay(1, function()
			pcall(function()
				GingerMeterController.cancel(v14)
			end)
		end)
	end

	local cooldownFrame = v3 and v3:FindFirstChild("Ability1") and v3.Ability1:FindFirstChild("CooldownFrame")

	if cooldownFrame then
		cooldownFrame.AnchorPoint = Vector2.new(0, 0)
		cooldownFrame.Position = UDim2.new(0, 0, 0, 0)
		cooldownFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end

local function fn6()
	if not (v2 and v2.PrimaryPart) then
		return nil
	end

	local position = v2.PrimaryPart.Position
	local playerRadius = v4 and v4.PlayerRadius or module.HealRange
	local v14 = nil
	local v15 = playerRadius + 1
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if not inGamePlayers then
		return nil
	end

	for _, child in pairs(inGamePlayers:GetChildren()) do
		if child == v2 then
			continue
		end

		local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			continue
		end

		local gingerHealPrompt = humanoidRootPart:FindFirstChild("GingerHealPrompt")

		if not (gingerHealPrompt and gingerHealPrompt:IsA("ProximityPrompt") and gingerHealPrompt.Enabled) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - position).Magnitude

		if not (magnitude <= playerRadius and magnitude < v15) then
			continue
		end

		v14 = gingerHealPrompt
		v15 = magnitude
	end

	return v14
end

function GingerPromptController.init(p, p2, p3, p4, p5)
	if flag then
		GingerPromptController.cleanup()
	end

	v = p
	v2 = p2
	v3 = p3
	v4 = p4
	v5 = p5
	local events = ReplicatedStorage:FindFirstChild("Events")
	gingerHealChannel = events and events:FindFirstChild("GingerHealChannel")
	table.insert(v6, ProximityPromptService.PromptShown:Connect(function(p6)
		-- equivalent call inferred; original call site unknown
		if not isGingerHealPrompt(p6) then
			return
		end

		-- equivalent call inferred; original call site unknown
		if isPromptOnSelf(p6) then
			p6.Enabled = false
			return
		end

		v13 = true
		local v14, _ = canUseAbility()

		if v14 and not flag3 then
			fn2()
		end
	end))
	table.insert(v6, ProximityPromptService.PromptHidden:Connect(function(p6)
		-- equivalent call inferred; original call site unknown
		if not isGingerHealPrompt(p6) then
			return
		end

		-- equivalent call inferred; original call site unknown
		if isPromptOnSelf(p6) then
			return
		end

		v13 = false
		fn3()
	end))

	local function updatePulseState()
		if not v13 or flag3 then
			return
		end

		local v14 = canUseAbility()

		if v14 and not flag2 then
			fn2()
		elseif not v14 and flag2 then
			fn3()
		end
	end

	local abilities = v2 and v2:FindFirstChild("Abilities")

	if abilities then
		local ability1 = abilities:FindFirstChild("Ability1")
		local currentCooldown = ability1 and ability1:FindFirstChild("CurrentCooldown")

		if currentCooldown then
			table.insert(v6, currentCooldown.Changed:Connect(function()
				task.defer(updatePulseState)
			end))
		end
	end

	local child = workspace.Info.PlayerStats:FindFirstChild(v.Name)
	local survivalPoints = child and child:FindFirstChild("SurvivalPoints")

	if survivalPoints then
		table.insert(v6, survivalPoints.Changed:Connect(function()
			task.defer(updatePulseState)
		end))
	end

	table.insert(v6, ProximityPromptService.PromptButtonHoldBegan:Connect(function(p6)
		-- equivalent call inferred; original call site unknown
		if not isGingerHealPrompt(p6) or flag3 or v12 and p6 ~= v12 then
			return
		end

		local parent = p6.Parent
		local parent2 = parent and parent.Parent

		-- equivalent call inferred; original call site unknown
		if isPromptOnSelf(p6) then
			return
		end

		local v14, v15 = canUseAbility()

		if v14 then
			flag3 = true
			lastTime = tick()
			v11 = false
			fn3()
			fn4(parent2)

			if gingerHealChannel then
				gingerHealChannel:FireServer("HealChannelStarted", parent2)
			end

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not (flag3 and lastTime) then
					return
				end

				local humanoidRootPart = v9 and v2 and v2.PrimaryPart and v9:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local playerRadius = v4 and v4.PlayerRadius or module.HealRange
					local magnitude = (v2.PrimaryPart.Position - humanoidRootPart.Position).Magnitude

					if playerRadius + 2 < magnitude then
						if renderSteppedConnection then
							renderSteppedConnection:Disconnect()
							renderSteppedConnection = nil
						end

						flag3 = false
						lastTime = nil
						fn()

						if gingerHealChannel then
							gingerHealChannel:FireServer("HealChannelCancelled")
						end

						if v5 then
							v5("Target moved out of range!", 2)
						end

						return
					end
				end

				local v16 = math.clamp((tick() - lastTime) / 3, 0, 1)
				local cooldownFrame = v3 and v3:FindFirstChild("Ability1") and v3.Ability1:FindFirstChild("CooldownFrame")

				if cooldownFrame then
					cooldownFrame.Size = UDim2.new(1, 0, v16, 0)
				end

				if v16 >= 1 and not v11 and v9 then
					v11 = true
					local v17 = v9

					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end

					flag3 = false
					v10 = nil
					lastTime = nil
					v12 = nil
					local cooldownFrame2 = v3 and v3:FindFirstChild("Ability1") and v3.Ability1:FindFirstChild("CooldownFrame")

					if cooldownFrame2 then
						cooldownFrame2.Size = UDim2.new(1, 0, 1, 0)
					end

					fn5()

					if gingerHealChannel then
						print("[GingerPromptController] Manual hold complete, requesting heal on", v17.Name)
						gingerHealChannel:FireServer("MobileHealComplete", v17)
					end
				end
			end)
		elseif v5 and v15 then
			v5(v15, 2)
		end
	end))
	table.insert(v6, ProximityPromptService.PromptButtonHoldEnded:Connect(function(p6)
		-- equivalent call inferred; original call site unknown
		if not isGingerHealPrompt(p6) or v12 and p6 ~= v12 then
			return
		end

		-- equivalent call inferred; original call site unknown
		if isPromptOnSelf(p6) then
			return
		end

		local actionState = InputService:GetActionState("UseAbility")

		if (actionState or flag4) and not v11 and flag3 and lastTime then
			print(
				"[GingerPromptController] Prompt hold ended by Roblox, input still held - continuing manually (key:",
				actionState,
				"button:",
				flag4,
				")"
			)
			return
		end

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		flag3 = false
		v10 = nil
		lastTime = nil
		task.defer(function()
			if not v11 then
				fn()

				if gingerHealChannel then
					gingerHealChannel:FireServer("HealChannelCancelled")
				end

				task.delay(0.05, function()
					if canUseAbility() and v13 then
						fn2()
					end
				end)
			end
		end)
	end))
	table.insert(v6, ProximityPromptService.PromptTriggered:Connect(function(player)
		-- equivalent call inferred; original call site unknown
		if not isGingerHealPrompt(player) or v12 and player ~= v12 then
			return
		end

		-- equivalent call inferred; original call site unknown
		if isPromptOnSelf(player) then
			warn("[GingerPromptController] PromptTriggered for SELF (should not happen!)")
			return
		end

		v11 = true

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		flag3 = false
		v10 = nil
		lastTime = nil
		v12 = nil
		local cooldownFrame = v3 and v3:FindFirstChild("Ability1") and v3.Ability1:FindFirstChild("CooldownFrame")

		if cooldownFrame then
			cooldownFrame.Size = UDim2.new(1, 0, 1, 0)
		end

		fn5()
	end))

	if gingerHealChannel then
		table.insert(v6, gingerHealChannel.OnClientEvent:Connect(function(p6, p7)
			if p6 == "HealFailed" then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end

				flag3 = false
				v10 = nil
				lastTime = nil

				if v12 then
					v12:InputHoldEnd()
					v12 = nil
				end

				fn()

				if v5 and p7 then
					v5(p7, 2)
				end
			elseif p6 == "HealComplete" and v2 then
				Audio:Play("Sounds.Toon.Ginger.PromptBeep", {
					PlaybackSpeed = 1.5,
					Volume = 1,
					Parent = v2:FindFirstChild("HumanoidRootPart") or v2
				})
			end
		end))
	end

	local function tryStartHold(p6)
		if flag3 then
			return false
		end

		local v14, v15 = canUseAbility()

		if v14 then
			if workspace.CurrentRoom:FindFirstChildOfClass("Model") then
				local floorActive = workspace.Info:FindFirstChild("FloorActive")

				if floorActive and floorActive.Value == true then
					local v16 = fn6()

					if v16 then
						v10 = p6
						v12 = v16
						v16:InputHoldBegin()
						return true
					else
						if v5 then
							v5("No injured Toon in range!", 2)
						end

						return false
					end
				end
			end

			if v5 then
				v5("Can't use that Ability in the Elevator!", 2)
			end
		elseif v5 and v15 then
			v5(v15, 2)
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryEndHold()
		if v12 then
			v12:InputHoldEnd()
			v12 = nil
		end
	end

	local function cancelHoldAndCleanup()
		tryEndHold() -- equivalent call inferred; original call site unknown

		if flag3 and not v11 then
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			flag3 = false
			lastTime = nil
			v10 = nil
			fn()

			if gingerHealChannel then
				gingerHealChannel:FireServer("HealChannelCancelled")
			end

			if canUseAbility() and v13 then
				fn2()
			end
		end
	end

	table.insert(v6, InputService:OnAction("UseAbility", function()
		if InputService:IsTyping() then
			return
		end

		tryStartHold("keyboard")
	end))
	table.insert(v6, InputService:OnActionReleased("UseAbility", function()
		if v10 and v10 ~= "keyboard" then
			return
		end

		cancelHoldAndCleanup()
	end))
	table.insert(v6, InputService.GameplayInterrupted:Connect(cancelHoldAndCleanup))

	if v3 and v3:FindFirstChild("Ability1") then
		local ability1 = v3.Ability1
		table.insert(v6, ability1.MouseButton1Down:Connect(function()
			if tryStartHold("gui") then
				flag4 = true
			end
		end))
		table.insert(v6, ability1.MouseButton1Up:Connect(function()
			if flag4 then
				flag4 = false

				if v10 and v10 ~= "gui" then
					return
				else
					cancelHoldAndCleanup()
				end
			end
		end))
		table.insert(v6, ability1.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			if tryStartHold("gui") then
				flag4 = true
			end
		end))
		table.insert(v6, ability1.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			if flag4 then
				flag4 = false

				if v10 and v10 ~= "gui" then
					return
				else
					cancelHoldAndCleanup()
				end
			end
		end))
	end

	flag = true
end

function GingerPromptController.cleanup()
	fn3()
	fn()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	flag3 = false
	v10 = nil
	lastTime = nil
	v11 = false
	flag4 = false
	v13 = false

	if v12 then
		v12:InputHoldEnd()
		v12 = nil
	end

	if v3 and v3:FindFirstChild("Ability1") then
		local holdReadyText = v3.Ability1:FindFirstChild("HoldReadyText")

		if holdReadyText then
			holdReadyText:Destroy()
		end

		local readyPulse = v3.Ability1:FindFirstChild("ReadyPulse")

		if readyPulse then
			readyPulse:Destroy()
		end
	end

	for _, connection in ipairs(v6) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end

	v6 = {}
	flag = false
	v = nil
	v2 = nil
	v3 = nil
	v4 = nil
	v5 = nil
	v9 = nil
end

function GingerPromptController.isChanneling()
	return flag3
end

function GingerPromptController.getCurrentTarget()
	return v9
end

return GingerPromptController