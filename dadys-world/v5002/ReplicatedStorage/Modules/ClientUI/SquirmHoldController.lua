local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage2.SharedUtils.InputService)
local SquirmHoldController = {}
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = {}
local holdDuration = 4
local flag2 = false
local v7 = nil
local lastTime = nil
local renderSteppedConnection = nil
local v8 = false
local flag3 = false
local flag4 = false
local anchorPoint = nil
local position = nil
local fn

local function canStartHold()
	if not v3 then
		return false, nil
	end

	if not workspace.CurrentRoom:FindFirstChildOfClass("Model") or workspace.Info.FloorActive.Value ~= true then
		return false, "Can't use in elevator!"
	end

	local decoding = v and v:FindFirstChild("Decoding")

	if decoding and decoding.Value ~= nil then
		return false, "Can't use while extracting!"
	end

	return true, nil
end

local function fn2()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	lastTime = nil
	flag2 = false
	v7 = nil
	flag4 = true

	if v2 and v2.Ability1 then
		local cooldownFrame = v2.Ability1:FindFirstChild("CooldownFrame")

		if cooldownFrame then
			cooldownFrame.AnchorPoint = anchorPoint or Vector2.new(0, 0)
			cooldownFrame.Position = position or UDim2.new(0, 0, 0, 0)
			cooldownFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			cooldownFrame.Size = UDim2.new(1, 0, 0, 0)
			local abilities = v and v:FindFirstChild("Abilities")
			local ability1 = abilities and abilities:FindFirstChild("Ability1")
			local currentCooldown = ability1 and ability1:FindFirstChild("CurrentCooldown")

			if currentCooldown and currentCooldown.Value > 0 then
				local cooldown = ability1:FindFirstChild("Cooldown")
				local v9 = math.clamp(currentCooldown.Value / (cooldown and cooldown.Value or 80), 0, 1)
				cooldownFrame.Size = UDim2.new(1, 0, v9, 0)
				cooldownFrame.Visible = true
			else
				cooldownFrame.Visible = false
			end
		end

		local cooldownText = v2.Ability1:FindFirstChild("CooldownText")

		if cooldownText then
			local abilities = v and v:FindFirstChild("Abilities")
			local ability1 = abilities and abilities:FindFirstChild("Ability1")
			local currentCooldown = ability1 and ability1:FindFirstChild("CurrentCooldown")

			if currentCooldown and currentCooldown.Value > 0 then
				cooldownText.Visible = true
				cooldownText.Text = string.format("%.1f", currentCooldown.Value)
			else
				cooldownText.Visible = false
			end
		end
	end

	fn()
end

local function fn3()
	if not (v2 and v2:FindFirstChild("Ability1")) then
		return
	end

	local ability1 = v2.Ability1
	local v9 = ability1:FindFirstChild("HoldReadyText")

	if not v9 then
		v9 = Instance.new("TextLabel")
		v9.Name = "HoldReadyText"
		v9.Size = UDim2.new(1, 0, 0.4, 0)
		v9.Position = UDim2.new(0, 0, -0.45, 0)
		v9.BackgroundTransparency = 1
		v9.Text = "HOLD!"
		v9.TextColor3 = Color3.fromRGB(100, 255, 100)
		v9.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		v9.TextStrokeTransparency = 0
		v9.Font = Enum.Font.GothamBold
		v9.TextScaled = true
		v9.ZIndex = 11
		v9.Active = false
		v9.Parent = ability1
	end

	v9.TextTransparency = 0
end

fn = function()
	if not (v2 and v2:FindFirstChild("Ability1")) then
		return
	end

	local holdReadyText = v2.Ability1:FindFirstChild("HoldReadyText")

	if holdReadyText then
		holdReadyText.TextTransparency = 1
	end
end

function SquirmHoldController.init(_, p, p2, p3, p4, p5)
	if flag then
		SquirmHoldController.cleanup()
	end

	v = p
	v2 = p2
	v3 = p3
	v4 = p4
	v5 = p5
	holdDuration = p3.HoldDuration or 4

	if v2 and v2.Ability1 and v2.Ability1:FindFirstChild("CooldownFrame") then
		anchorPoint = v2.Ability1.CooldownFrame.AnchorPoint
		position = v2.Ability1.CooldownFrame.Position
	end

	table.insert(v6, v:GetAttributeChangedSignal("HoldAbilityActive"):Connect(function()
		local holdAbilityActive = v:GetAttribute("HoldAbilityActive")
		v8 = holdAbilityActive
		flag3 = false

		if holdAbilityActive then
			if not renderSteppedConnection and v2 and v2.Ability1 then
				fn3()
				local cooldownFrame = v2.Ability1:FindFirstChild("CooldownFrame")

				if cooldownFrame then
					cooldownFrame.AnchorPoint = Vector2.new(0, 1)
					cooldownFrame.Position = UDim2.new(0, 0, 1, 0)
					cooldownFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
					cooldownFrame.Visible = true
				end

				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					if not v8 then
						fn2()
					elseif cooldownFrame then
						local holdAbilityStart = v:GetAttribute("HoldAbilityStart")
						local holdAbilityDuration = v:GetAttribute("HoldAbilityDuration") or holdDuration

						if holdAbilityStart then
							local v9 = math.clamp(
								(workspace.DistributedGameTime - holdAbilityStart) / holdAbilityDuration,
								0,
								1
							)
							cooldownFrame.Size = UDim2.new(1, 0, v9, 0)
						end
					end
				end)
			end
		else
			v8 = false
			fn2()
		end
	end))
	table.insert(v6, v:GetAttributeChangedSignal("HoldAbilityCancelled"):Connect(function()
		if v:GetAttribute("HoldAbilityCancelled") then
			fn2()
		end
	end))
	table.insert(v6, v:GetAttributeChangedSignal("HoldAbilityFailReason"):Connect(function()
		local holdAbilityFailReason = v:GetAttribute("HoldAbilityFailReason")

		if holdAbilityFailReason ~= nil then
			flag3 = false
			fn2()

			if v4 and holdAbilityFailReason ~= "" then
				v4(holdAbilityFailReason, 2)
			end
		end
	end))
	local floorActive = workspace.Info:FindFirstChild("FloorActive")

	if floorActive then
		table.insert(v6, floorActive.Changed:Connect(function()
			if floorActive.Value ~= true then
				v8 = false
				flag3 = false
				fn2()
			end
		end))
	end

	table.insert(v6, InputService:OnAction("UseAbility", function()
		if v.Parent ~= workspace.InGamePlayers or InputService:IsTyping() then
			return
		end

		local TextChatService = game:GetService("TextChatService")
		local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

		if chatInputBarConfiguration and chatInputBarConfiguration.IsFocused then
			return
		end

		SquirmHoldController.onButtonPressed("keyboard")
	end))
	table.insert(v6, InputService:OnActionReleased("UseAbility", function()
		SquirmHoldController.onButtonReleased("keyboard")
	end))
	table.insert(v6, InputService.GameplayInterrupted:Connect(function()
		SquirmHoldController.onButtonReleased(v7)
	end))
	table.insert(v6, v2.Ability1.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			SquirmHoldController.onButtonPressed("gui")
		end
	end))
	table.insert(v6, v2.Ability1.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			SquirmHoldController.onButtonReleased("gui")
		end
	end))
	flag = true
end

function SquirmHoldController.onButtonPressed(p)
	if flag2 or v8 or flag3 then
		return false
	end

	local flag5, v9

	if v3 then
		if workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true then
			local decoding = v and v:FindFirstChild("Decoding")

			if decoding and decoding.Value ~= nil then
				flag5 = false
				v9 = "Can't use while extracting!"
			else
				flag5 = true
			end
		else
			flag5 = false
			v9 = "Can't use in elevator!"
		end
	else
		flag5 = false
	end

	if flag5 then
		flag2 = true
		v7 = p
		flag3 = true
		flag4 = false
		lastTime = tick()
		fn3()
		local cooldownFrame = v2.Ability1:FindFirstChild("CooldownFrame")

		if cooldownFrame then
			cooldownFrame.AnchorPoint = Vector2.new(0, 1)
			cooldownFrame.Position = UDim2.new(0, 0, 1, 0)
			cooldownFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
			cooldownFrame.Size = UDim2.new(1, 0, 0, 0)
			cooldownFrame.Visible = true
		end

		local cooldownText = v2.Ability1:FindFirstChild("CooldownText")

		if cooldownText then
			cooldownText.Visible = false
		end

		if v5 and v and v.PrimaryPart then
			v5(v, v.PrimaryPart.CFrame, nil, nil, v3)
		end

		if flag4 then
			flag3 = false
			return true
		end

		if renderSteppedConnection then
			return true
		end

		local lastTime2 = tick()
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not (flag2 or v8 or flag3) then
				fn2()
			elseif flag3 and not v8 and tick() - lastTime2 > 0.25 then
				flag3 = false
				fn2()
			elseif cooldownFrame and lastTime then
				local v10 = math.clamp((tick() - lastTime) / holdDuration, 0, 1)
				cooldownFrame.Size = UDim2.new(1, 0, v10, 0)
			end
		end)
		return true
	else
		if v9 and v4 then
			v4(v9, 2)
		end

		return false
	end
end

function SquirmHoldController.onButtonReleased(p)
	if v7 and p ~= v7 then
		return false
	end

	local v9 = flag2
	local v10 = flag3
	local v11 = v8
	flag2 = false
	fn2()
	local v12 = v9 and (v11 or v10)

	if not v12 then
		return v12
	end

	flag3 = false
	local events = ReplicatedStorage:FindFirstChild("Events")
	local squirmAbilityCancel = events and events:FindFirstChild("SquirmAbilityCancel")

	if squirmAbilityCancel then
		squirmAbilityCancel:FireServer()
	end

	if v11 and v4 then
		v4("Keep holding!", 1)
	end

	return v12
end

function SquirmHoldController.isHoldActive()
	return flag2 or v8
end

function SquirmHoldController.cleanup()
	flag2 = false
	v7 = nil
	v8 = false
	flag3 = false
	fn2()
	local holdReadyText = v2 and v2:FindFirstChild("Ability1") and v2.Ability1:FindFirstChild("HoldReadyText")

	if holdReadyText then
		holdReadyText:Destroy()
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
end

return SquirmHoldController