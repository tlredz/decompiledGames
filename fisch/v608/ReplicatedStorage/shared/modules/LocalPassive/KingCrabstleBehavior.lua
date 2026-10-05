game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local KingCrabstleBehavior = {}
KingCrabstleBehavior.__index = KingCrabstleBehavior
KingCrabstleBehavior.MorphSpear = true

function KingCrabstleBehavior:Morph(_, object2)
	self.lastPull = 0
	self.pullCount = 0
	self.pullActive = false
	self.progressValue = object2:CreateModifier("progress", "add")
	self.random = object2:GetRandom(6)
	object2.OnFishMove:Connect(function()
		self:Update()
	end)
end

function KingCrabstleBehavior:CreateClaw(parent, p: number, imageColor: Color3)
	local v = p < 0 and "clawLeft" or "clawRight"
	local image = script:FindFirstChild(v)

	if not (image and image:IsA("ImageLabel")) then
		return nil
	end

	local clone = image:Clone()
	clone.Name = p < 0 and "CrabstleClawLeft" or "CrabstleClawRight"
	clone.BackgroundTransparency = 1
	clone.ImageColor3 = imageColor
	clone.ZIndex = 9

	if p < 0 then
		clone.Position = UDim2.fromScale(-0.3, 0.5)
	else
		clone.Position = UDim2.fromScale(1.3, 0.5)
	end

	clone.Parent = parent
	return clone
end

function KingCrabstleBehavior:Pull()
	local current = self.current
	local config = self.config
	self.pullCount += 1
	self.lastPull = Workspace:GetServerTimeNow()
	self.pullActive = true
	local v = math.random() < 0.5
	local v2 = v and -1 or 1
	local claw = self:CreateClaw(current.reel_playerbar, v and -1 or 1, config.PullColor)

	if claw then
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local uDim = v and UDim2.fromScale(0, 0.5) or UDim2.fromScale(1, 0.5)
		current.logicTweens:Create(claw, tweenInfo, {
			Position = uDim
		}):Play()
	end

	current.logicTweens:Create(
		current.reel_progress.bar,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
		{
			BackgroundColor3 = config.PullColor
		}
	):Play()
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.krakenhit, current.reel, true)
	local total = 0
	local v3 = config.PullProgressLoss / config.PullDuration
	local connection = nil
	connection = self.reelTrove:Add(current.OnLogicStep:Connect(function(p)
		if not (current.active and self.pullActive) then
			connection:Disconnect()
			return
		end

		total += p

		if current.core.rod then
			current.core.rod:ApplyImpulse(v2 * config.PullForce * p)
		end

		self.progressValue.Value -= v3 * p

		if total >= config.PullDuration then
			connection:Disconnect()
		end
	end))
	current:DelayLogic(config.PullDuration, function()
		self.pullActive = false

		if claw and claw.Parent then
			local uDim = v and UDim2.fromScale(-0.3, 0.5) or UDim2.fromScale(1.3, 0.5)
			local v4 = current.logicTweens:Create(
				claw,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Position = uDim,
					ImageTransparency = 1
				}
			)
			v4.Completed:Once(function()
				claw:Destroy()
			end)
			v4:Play()
		end
	end)
end

function KingCrabstleBehavior:Update()
	if not self.current.active then
		return
	end

	local current = self.current
	local config = self.config
	local serverTimeNow = Workspace:GetServerTimeNow()

	if self.pullActive then
		return
	end

	if self.lastPull + config.PullCooldown <= serverTimeNow and current.progress >= (config.PullMinimumProgress or 0) and math.max(
		config.PullBaseChance * (1 - self.pullCount * 0.1),
		config.PullBaseChance * 0.5
	) > self.random:NextNumber(0, 100) then
		self:Pull()
	end
end

setmetatable(KingCrabstleBehavior, module)
return KingCrabstleBehavior