local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local CurrencyDisplayController = {}

local function resolvePlayerIchorCount()
	if GameContext.playerIchorCount then
		return GameContext.playerIchorCount
	end

	local quickLinks = GameContext.Gui.SelectionFrame:FindFirstChild("QuickLinks")
	local uI_Elements = quickLinks and quickLinks:FindFirstChild("UI_Elements")

	if uI_Elements then
		GameContext.playerIchorCount = uI_Elements:FindFirstChild("PlayerIchorCount")
	end

	return GameContext.playerIchorCount
end

local function isCharacterAlive()
	local character = GameContext.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

function CurrencyDisplayController.setupIchor(instance)
	local gui = GameContext.Gui
	local coin = instance:WaitForChild("Coin")
	local margin = gui:WaitForChild("CurrencyFrames"):WaitForChild("IchorFrame"):WaitForChild("Margin")
	local uDim = UDim2.new(-1, 0, 0, 0)
	local uDim2 = UDim2.new(0, 0, 0, 0)
	margin.TextLabel.Text = tostring(coin.Value)
	margin.Position = uDim

	if GameContext.playerIchorCount then
		local _ = GameContext.playerIchorCount
	else
		local quickLinks = GameContext.Gui.SelectionFrame:FindFirstChild("QuickLinks")
		local uI_Elements = quickLinks and quickLinks:FindFirstChild("UI_Elements")

		if uI_Elements then
			GameContext.playerIchorCount = uI_Elements:FindFirstChild("PlayerIchorCount")
		end

		local _ = GameContext.playerIchorCount
	end

	if GameContext.playerIchorCount then
		GameContext.playerIchorCount.Text = tostring(coin.Value)
	end

	local value = coin.Value
	GameContext.ichorchanged = coin.Changed:Connect(function(p)
		local character = GameContext.Character
		local v

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid == nil then
				v = false
			else
				v = humanoid.Health > 0
			end
		else
			v = false
		end

		if not v then
			return
		end

		local v2 = math.round(p - value)
		value = p

		if v2 > 0 then
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			gui.IchorEarnedFrame.TextLabel.Text = "+" .. v2
			margin.Parent.Visible = true
			margin.Position = uDim
			gui.IchorEarnedFrame.Position = UDim2.new(0.479, 0, 0.659, 0)
			gui.IchorEarnedFrame.Size = UDim2.new(0.042, 0, 0.035, 0)
			gui.IchorEarnedFrame.Visible = true
			TweenService:Create(gui.IchorEarnedFrame, tweenInfo, {
				Position = UDim2.new(0.451, 0, 0.636, 0),
				Size = UDim2.new(0.098, 0, 0.082, 0)
			}):Play()
			TweenService:Create(margin, tweenInfo2, {
				Position = uDim2
			}):Play()
			Audio:PlayOne("Sounds.UI.Money.MoneyPopup")
			task.wait(0.75)
			local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			local uDim3 = UDim2.fromScale(
				margin.AbsolutePosition.X / margin.Parent.Parent.Parent.AbsoluteSize.X,
				margin.AbsolutePosition.Y / margin.Parent.Parent.Parent.AbsoluteSize.Y
			)
			local tween = TweenService:Create(gui.IchorEarnedFrame, tweenInfo3, {
				Position = uDim3
			})
			tween:Play()
			tween.Completed:Wait()
			gui.IchorEarnedFrame.Visible = false
			Audio:PlayOne("Sounds.UI.Money.MoneyCollected")
			margin.ParticleEmitter.Enabled = true
			margin.Position = uDim2 + UDim2.new(0, 0, -0.075, 0)
			local tween2 = TweenService:Create(margin, tweenInfo, {
				Position = uDim2
			})
			tween2:Play()
			margin.TextLabel.Text = coin.Value
			task.wait(0.15)
			margin.ParticleEmitter.Enabled = false
			tween2.Completed:Wait()
			local tween3 = TweenService:Create(margin, tweenInfo2, {
				Position = uDim
			})
			tween3:Play()
			tween3.Completed:Wait()
			margin.Parent.Visible = false
		else
			margin.TextLabel.Text = coin.Value
		end

		if GameContext.playerIchorCount then
			local _ = GameContext.playerIchorCount
		else
			local quickLinks = GameContext.Gui.SelectionFrame:FindFirstChild("QuickLinks")
			local uI_Elements = quickLinks and quickLinks:FindFirstChild("UI_Elements")

			if uI_Elements then
				GameContext.playerIchorCount = uI_Elements:FindFirstChild("PlayerIchorCount")
			end

			local _ = GameContext.playerIchorCount
		end

		if GameContext.playerIchorCount then
			GameContext.playerIchorCount.Text = tostring(coin.Value)
			local particleEmitter = GameContext.playerIchorCount:FindFirstChild("ParticleEmitter")

			if particleEmitter then
				particleEmitter.Enabled = true
				task.spawn(function()
					task.wait(0.15)

					if particleEmitter then
						particleEmitter.Enabled = false
					end
				end)
			end
		end
	end)
end

function CurrencyDisplayController.setupToken(instance)
	local gui = GameContext.Gui
	local tokens = instance:GetAttribute("Tokens") or 0
	local tokenFrame = gui:FindFirstChild("TokenFrame")

	if not tokenFrame then
		GameContext.tokenchanged = instance:GetAttributeChangedSignal("Tokens"):Connect(function() end)
		return
	end

	tokenFrame.TextLabel.Text = tostring(tokens)
	GameContext.tokenchanged = instance:GetAttributeChangedSignal("Tokens"):Connect(function()
		local character = GameContext.Character
		local v

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid == nil then
				v = false
			else
				v = humanoid.Health > 0
			end
		else
			v = false
		end

		if not v then
			return
		end

		local tokens2 = instance:GetAttribute("Tokens") or 0
		tokenFrame.TextLabel.Text = tostring(tokens2)
	end)
end

function CurrencyDisplayController.setupAll(p)
	CurrencyDisplayController.setupIchor(p)
	CurrencyDisplayController.setupToken(p)
end

return CurrencyDisplayController