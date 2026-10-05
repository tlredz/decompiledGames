local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Shared.WeightRandom)
require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.ClientGameModules.Confetti)
local v6 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v7 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v8 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v9 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v10 = require3(ReplicatedStorage2.Shared.BossCrate)
local v11 = require3(ReplicatedStorage2.Packages.Net)
local remoteEvent = v11:RemoteEvent("BossClaimReward")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local bossUI = playerGui.BossUI
local _ = playerGui.HUD
local phaseComplete = playerGui.PhaseComplete
local bossConfetti = playerGui.BossConfetti
local deathScreen = playerGui.DeathScreen
local bossEndScreen = playerGui.BossEndScreen
local frame = bossEndScreen.Frame
local win = frame.Win
local template = frame.Rewards.List.Template
template.Parent = nil
local v12 = {}

for _, v13 in { frame.RobloxWin, frame.RobloxLoss } do
	local confetti = v13:FindFirstChild("Confetti")
	local vector = v13:FindFirstChild("Vector")
	local title = v13:FindFirstChild("Title")
	local v14 = {
		TopPosition = v13.TextGlow.Top.Top.Position,
		BtmPosition = v13.TextGlow.Btm.Btm.Position,
		VectorSize = 0,
		TitlePosition = 0,
		ConfettiPosition = 0
	}
	local vectorSize

	if vector then
		vectorSize = vector.Size
	end

	v14.VectorSize = vectorSize
	local titlePosition

	if title then
		titlePosition = title.Position
	end

	v14.TitlePosition = titlePosition
	local confettiPosition

	if confetti then
		confettiPosition = confetti.Position
	end

	v14.ConfettiPosition = confettiPosition
	v12[v13] = v14
end

local tweens = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function stopConfettiStream()
	for _, v13 in tweens do
		v13:Cancel()
	end

	table.clear(tweens)
end

local function startConfettiStream(parent)
	stopConfettiStream() -- equivalent call inferred; original call site unknown
	local confetti = parent:FindFirstChild("Confetti")
	local confettiPosition = v12[parent].ConfettiPosition

	if not (confetti and confettiPosition) then
		return
	end

	local confettiTop = parent:FindFirstChild("ConfettiTop")

	if not confettiTop then
		confettiTop = confetti:Clone()
		confettiTop.Name = "ConfettiTop"
		confettiTop.Parent = parent
	end

	local scale = confetti.Size.Y.Scale
	local tweenInfo = TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)

	for k, v13 in { confetti, confettiTop } do
		local position = confettiPosition - UDim2.fromScale(0, scale * (k - 1))
		v13.Position = position
		v13.ImageTransparency = 1
		v13.Visible = true
		local tween = TweenService:Create(v13, tweenInfo, {
			Position = position + UDim2.fromScale(0, scale)
		})
		tween:Play()
		table.insert(tweens, tween)
		TweenService:Create(v13, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSerpentFight()
	return workspace:GetAttribute("CurrentlySelectedMode") == "PVESerpentBoss"
end

local function playRobloxResult(instance, flag: boolean)
	local v13 = v12[instance]
	local textGlow = instance.TextGlow
	local top = textGlow.Top.Top
	local btm = textGlow.Btm.Btm
	local vector = instance:FindFirstChild("Vector")
	local imageLabel = instance:FindFirstChild("ImageLabel")
	local title = instance:FindFirstChild("Title")
	local skull = top:FindFirstChild("Skull")
	textGlow.ImageTransparency = 1
	top.Position = v13.TopPosition - UDim2.fromScale(0, 1)
	top.TextTransparency = 1
	top.UIStroke.Transparency = 1
	btm.Position = v13.BtmPosition + UDim2.fromScale(0, 1)
	btm.TextTransparency = 1
	btm.UIStroke.Transparency = 1

	if vector then
		vector.Size = UDim2.fromScale(0, 0)
		vector.ImageTransparency = 1
	end

	if imageLabel then
		imageLabel.ImageTransparency = 1
	end

	if title then
		title.Position = UDim2.fromScale(0.5, -0.5)
	end

	if skull then
		skull.ImageTransparency = 1
	end

	instance.Visible = true

	if title then
		TweenService:Create(title, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = v13.TitlePosition
		}):Play()
		task.wait(1.5)
	end

	if vector then
		TweenService:Create(vector, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = v13.VectorSize,
			ImageTransparency = 0
		}):Play()
		task.wait(0.5)
	end

	if flag then
		startConfettiStream(instance)
		task.spawn(function()
			for i = 1, v5.getProperParticlesToScreen() do
				v5.createParticle(
					Vector2.new(0.5, 1),
					Vector2.new(math.random(0, 180) - 90, math.random(100, 160) * (i // 6 + 1)),
					bossConfetti
				)
			end
		end)
	end

	TweenService:Create(top, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = v13.TopPosition
	}):Play()
	TweenService:Create(top.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()

	if skull then
		TweenService:Create(skull, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		}):Play()
	end

	task.wait(0.5)
	TweenService:Create(btm, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = v13.BtmPosition
	}):Play()
	TweenService:Create(btm.UIStroke, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	task.wait(0.4)
	TweenService:Create(textGlow, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = 0
	}):Play()

	if imageLabel then
		TweenService:Create(imageLabel, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		}):Play()
	end
end

local BossUIController = {}

function BossUIController:ShowResultScreen(flag: boolean, list)
	local WAIT_INTERVAL = 0.2
	local WAIT_INTERVAL_2 = 0.5
	deathScreen.Enabled = false
	local changedConnection = deathScreen.Changed:Connect(function()
		if deathScreen.Enabled then
			deathScreen.Enabled = false
		end
	end)
	local bossPhase = workspace:GetAttribute("BossPhase") or 1
	bossEndScreen.Enabled = true
	bossEndScreen.Black.BackgroundTransparency = 1
	local enabledChangedConnection = nil
	enabledChangedConnection = bossEndScreen:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not bossEndScreen.Enabled then
			if changedConnection then
				changedConnection:Disconnect()
				changedConnection = nil
			end

			if enabledChangedConnection then
				enabledChangedConnection:Disconnect()
				enabledChangedConnection = nil
			end
		end
	end)
	TweenService:Create(bossEndScreen.Black, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2
	}):Play()
	bossEndScreen.OddsFrame.Visible = false
	frame.Win.Visible = false
	frame.Lose1.Visible = false
	frame.Lose2.Visible = false
	frame.ProgressBar.Position = UDim2.fromScale(0.5, 1.2)
	frame.OddsBtn.Position = UDim2.fromScale(0.65, 1.2)
	frame.Robux.Position = UDim2.fromScale(0.35, 1.2)
	frame.Rewards.Position = UDim2.fromScale(0.5, 1.2)
	frame.Rewards.Rewards.Position = UDim2.fromScale(0.5, 0.5)
	frame.Rewards.Rewards.TextTransparency = 1
	frame.Rewards.Rewards.UIStroke.Transparency = 1
	frame.RobloxWin.Visible = false
	frame.RobloxLoss.Visible = false
	stopConfettiStream() -- equivalent call inferred; original call site unknown
	local serpentFight = isSerpentFight() -- equivalent call inferred; original call site unknown

	for _, v13 in {
		frame.ProgressBar,
		frame.Rewards,
		frame.OddsBtn,
		frame.Robux
	} do
		v13.Visible = not serpentFight
	end

	if serpentFight then
		local v14

		if flag then
			v14 = frame.RobloxWin
		else
			v14 = frame.RobloxLoss
		end

		playRobloxResult(v14, flag)
	else
		local clones = table.create(#list)

		for k, v13 in list do
			local clone = template:Clone()
			clone.Holder.Vector.Image = v13.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
			clone.Holder.TextLabel.Text = v13.DisplayName
			clone.Parent = frame.Rewards.List
			clone.Holder.Position = UDim2.fromScale(0.5, 2 - 1 / #list * k)
			clone.Holder.ImageTransparency = 1
			clone.Holder.Vector.ImageTransparency = 1
			clone.Holder.TextLabel.TextTransparency = 1
			clone.Holder.TextLabel.UIStroke.Transparency = 1
			clones[k] = clone
		end

		if flag then
			win.Title.Position = UDim2.fromScale(0.5, -0.5)
			win.TextGlow.ImageTransparency = 1
			win.TextGlow.Top.Top.TextTransparency = 1
			win.TextGlow.Top.Top.Position = UDim2.fromScale(0.5, -1)
			win.TextGlow.Top.Top.UIStroke.Transparency = 1
			win.TextGlow.Btm.Btm.Position = UDim2.fromScale(0.5, 1)
			win.TextGlow.Btm.Btm.TextTransparency = 1
			win.TextGlow.Btm.Btm.UIStroke.Transparency = 1
			win.Visible = true
			TweenService:Create(win.Title, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, -0.022)
			}):Play()
			task.wait(1.5)
			task.spawn(function()
				for i = 1, v5.getProperParticlesToScreen() do
					v5.createParticle(
						Vector2.new(0.5, 1),
						Vector2.new(math.random(0, 180) - 90, math.random(100, 160) * (i // 6 + 1)),
						bossConfetti,
						{ function()
								local square = v5.shapes.Square()
								local v13 = math.random(12, 32)
								square.Size = UDim2.fromOffset(v13, v13)
								return square
							end },
						{
							Color3.fromRGB(125, 224, 101),
							Color3.fromRGB(205, 255, 156),
							Color3.fromRGB(64, 255, 61),
							Color3.fromRGB(6, 186, 59),
							Color3.fromRGB(30, 90, 43)
						}
					)
				end
			end)
			TweenService:Create(
				win.TextGlow.Top.Top,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					TextTransparency = 0,
					Position = UDim2.fromScale(0.5, 0)
				}
			):Play()
			TweenService:Create(
				win.TextGlow.Top.Top.UIStroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			task.wait(WAIT_INTERVAL_2)
			TweenService:Create(
				win.TextGlow.Btm.Btm,
				TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					TextTransparency = 0,
					Position = UDim2.fromScale(0.5, 0)
				}
			):Play()
			TweenService:Create(
				win.TextGlow.Btm.Btm.UIStroke,
				TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			task.wait(0.4)
			TweenService:Create(win.TextGlow, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
			task.wait(WAIT_INTERVAL_2)
		else
			local lose1

			if bossPhase == 3 then
				lose1 = frame.Lose1
			else
				lose1 = frame.Lose2
			end

			lose1.Title.Position = UDim2.fromScale(0.5, -0.5)
			lose1.TextGlow.ImageTransparency = 1
			lose1.TextGlow.Top.Top.TextTransparency = 1
			local top = lose1.TextGlow.Top.Top
			local position

			if lose1 == frame.Lose1 then
				position = UDim2.fromScale(0.522, -1)
			else
				position = UDim2.fromScale(0.544, 0.403)
			end

			top.Position = position
			lose1.TextGlow.Top.Top.UIStroke.Transparency = 1
			lose1.TextGlow.Top.Top.Skull.ImageTransparency = 1
			lose1.TextGlow.Btm.Btm.Position = UDim2.fromScale(0.5, 1)
			lose1.TextGlow.Btm.Btm.TextTransparency = 1
			lose1.TextGlow.Btm.Btm.UIStroke.Transparency = 1
			lose1.Visible = true
			TweenService:Create(lose1.Title, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, -0.022)
			}):Play()
			task.wait(1.5)
			local top2 = lose1.TextGlow.Top.Top
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local position2

			if lose1 == frame.Lose1 then
				position2 = UDim2.fromScale(0.522, 0)
			else
				position2 = UDim2.fromScale(0.544, 0)
			end

			TweenService:Create(top2, tweenInfo, {
				TextTransparency = 0,
				Position = position2
			}):Play()
			TweenService:Create(
				lose1.TextGlow.Top.Top.UIStroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			TweenService:Create(
				lose1.TextGlow.Top.Top.Skull,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					ImageTransparency = 0
				}
			):Play()
			task.wait(WAIT_INTERVAL_2)
			TweenService:Create(
				lose1.TextGlow.Btm.Btm,
				TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					TextTransparency = 0,
					Position = UDim2.fromScale(0.5, 0)
				}
			):Play()
			TweenService:Create(
				lose1.TextGlow.Btm.Btm.UIStroke,
				TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			task.wait(0.4)
			TweenService:Create(lose1.TextGlow, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
			task.wait(WAIT_INTERVAL_2)
		end

		TweenService:Create(frame.ProgressBar, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.599)
		}):Play()
		local currentXP = self:GetCurrentXP()
		local nextCrate, _ = self:GetNextCrate()
		local v13 = nextCrate or v10[#v10]
		local tweenInfo = TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local numberValue = Instance.new("NumberValue")
		frame.ProgressBar.XP.Text = `0/{math.round(v13.xp)} Exp`
		local v14 = nil

		local function update()
			local value

			if numberValue then
				value = numberValue.Value
			else
				value = currentXP
			end

			local v15 = not nextCrate

			if v15 then
				local v16 = math.round(value)
				v15 = currentXP - 1 <= v16
			end

			frame.ProgressBar.XP.Text = v15 and "Max Exp" or `{math.round((math.clamp(value, 0, v13.xp)))}/{math.round(v13.xp)} Exp`

			if v15 and v14 then
				v14:Cancel()
				v14 = nil
			end
		end

		numberValue.Changed:Connect(update)
		local tween = TweenService:Create(numberValue, tweenInfo, {
			Value = currentXP
		})
		tween.Completed:Once(function()
			numberValue:Destroy()
			numberValue = nil
			update()
		end)
		v14 = tween
		tween:Play()
		local v15 = not nextCrate and 1 or math.min(currentXP / nextCrate.xp, 1)
		frame.ProgressBar.Fill.Size = UDim2.fromScale(0, 1)
		frame.ProgressBar.Fill.Visible = v15 >= 0.015
		TweenService:Create(frame.ProgressBar.Fill, tweenInfo, {
			Size = UDim2.fromScale(v15, 1)
		}):Play()
		task.wait(WAIT_INTERVAL)
		TweenService:Create(frame.Rewards, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.757)
		}):Play()
		task.wait(WAIT_INTERVAL)
		TweenService:Create(
			frame.Rewards.Rewards,
			TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				TextTransparency = #list > 0 and 0 or nil,
				Position = UDim2.fromScale(0.5, 0.073)
			}
		):Play()
		TweenService:Create(
			frame.Rewards.Rewards.UIStroke,
			TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Transparency = #list > 0 and 0 or nil
			}
		):Play()
		task.wait(WAIT_INTERVAL)

		for _, v16 in clones do
			local holder = v16.Holder
			TweenService:Create(holder, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.45),
				ImageTransparency = 0.7
			}):Play()
			TweenService:Create(holder.Vector, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(
				holder.TextLabel,
				TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					TextTransparency = 0
				}
			):Play()
			TweenService:Create(
				holder.TextLabel.UIStroke,
				TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			task.wait(WAIT_INTERVAL)
		end

		frame.Robux.Visible = false
		TweenService:Create(frame.Robux, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.35, 0.975)
		}):Play()
		frame.Robux.Label.Text = flag and "Open Crate?" or "Revive ALL?"
		local v16 = not flag and v3.Client:WaitReplion("Data")

		if v16 then
			local function updateLabel()
				local expect = v16:GetExpect("BossFight.Revives")

				if expect > 0 then
					frame.Robux.Amount:RemoveTag("ProductPriceLabel")
					frame.Robux.Amount.Text = `FREE ({expect})`
				else
					v9(frame.Robux.Amount, 3068610255, "DevProduct", ":robux:%s")
				end
			end

			v16:OnChange("BossFight.Revives", updateLabel)
			task.spawn(updateLabel)
		end

		frame.Robux.Activated:Connect(function()
			if flag then
				v11:Invoke("BossOpenCrate")
				return
			end

			local expect = v3.Client:WaitReplion("Data"):GetExpect("BossFight.Revives")

			if not v11:Invoke("BossRevive") and expect <= 0 then
				v8:PromptPurchase(3068610255, Enum.InfoType.Product)
			end
		end)
		task.wait(WAIT_INTERVAL)
		TweenService:Create(frame.OddsBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(frame.Robux.Visible and 0.65 or 0.5, 0.975)
		}):Play()
		frame.OddsBtn.Activated:Connect(function()
			bossEndScreen.OddsFrame.Visible = true
		end)
	end
end

function BossUIController:GetCurrentXP()
	return localPlayer:GetAttribute("BossXP") or 0
end

function BossUIController:GetNextCrate()
	for k, v15 in v10 do
		if not localPlayer:GetAttribute((`BossCrate{k}`)) then
			return v15, k
		end
	end

	return nil, nil
end

function BossUIController:CanClaimNext(p: number, p2, p3)
	if p3 then
		if p2 then
			if p2.xp <= p then
				p2 = not localPlayer:GetAttribute((`BossCrate{p3}`))
			else
				p2 = false
			end
		end
	else
		p2 = p3
	end

	return p2
end

function BossUIController:Start()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CutsceneWaiting"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	screenGui.Enabled = false
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	frame2.BackgroundTransparency = 1
	frame2.BorderSizePixel = 0
	frame2.Parent = screenGui
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(0.6, 0.06)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextTransparency = 1
	textLabel.Text = "Cutscene playing, it'll start soon..."
	textLabel.Parent = frame2
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2
	uIStroke.Transparency = 1
	uIStroke.Parent = textLabel
	screenGui.Parent = playerGui
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function updateCutsceneWaiting()
		local serpentCutsceneWaiting = localPlayer:GetAttribute("SerpentCutsceneWaiting") == true

		if serpentCutsceneWaiting then
			screenGui.Enabled = true
		end

		TweenService:Create(frame2, tweenInfo, {
			BackgroundTransparency = serpentCutsceneWaiting and 0.4 or 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = serpentCutsceneWaiting and 0 or 1
		}):Play()
		local tween = TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = serpentCutsceneWaiting and 0 or 1
		})
		tween:Play()

		if not serpentCutsceneWaiting then
			tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed and localPlayer:GetAttribute("SerpentCutsceneWaiting") ~= true then
					screenGui.Enabled = false
				end
			end)
		end
	end

	localPlayer:GetAttributeChangedSignal("SerpentCutsceneWaiting"):Connect(updateCutsceneWaiting)
	task.spawn(updateCutsceneWaiting)
	local progressBar = bossUI:WaitForChild("ProgressBar")
	local text = progressBar.TextLabel.Text
	local count = 0

	local function setHintTransparency(p: number, value: number?)
		local tweenInfo2 = TweenInfo.new(value or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(progressBar.TextLabel, tweenInfo2, {
			TextTransparency = p
		}):Play()
		TweenService:Create(progressBar.TextLabel.UIStroke, tweenInfo2, {
			Transparency = p
		}):Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showHint(text2: string)
		count += 1
		local v13 = count
		progressBar.TextLabel.Text = text2
		setHintTransparency(0)
		task.delay(5, function()
			if v13 == count then
				setHintTransparency(1, 1)
			end
		end)
	end

	local flag = false

	local function fadeOutParryBar()
		if flag then
			return
		end

		flag = true
		local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local descendants = progressBar:GetDescendants()
		table.insert(descendants, progressBar)

		for _, instance in descendants do
			local v13 = {}

			if instance:IsA("GuiObject") then
				v13.BackgroundTransparency = 1
			end

			if instance:IsA("TextLabel") or instance:IsA("TextButton") then
				v13.TextTransparency = 1
			elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
				v13.ImageTransparency = 1
			elseif instance:IsA("UIStroke") then
				v13.Transparency = 1
			end

			if next(v13) then
				TweenService:Create(instance, tweenInfo2, v13):Play()
			end
		end

		task.delay(tweenInfo2.Time, function()
			if flag then
				progressBar.Visible = false
			end
		end)
	end

	local function updateParries()
		local serpentParriesRequired = workspace:GetAttribute("SerpentParriesRequired") or 1
		local serpentParries = localPlayer:GetAttribute("SerpentParries") or 0
		local v13 = serpentParriesRequired <= serpentParries
		local v14 = math.min(serpentParries / serpentParriesRequired, 1)
		progressBar.XP.Text = `{math.min(serpentParries, serpentParriesRequired)}/{serpentParriesRequired} Parries`
		local text2 = v13 and "You're eligible for the badge! Now defeat the Serpent" or "Parry the ball to become eligible for the badge!"

		if progressBar.TextLabel.Text ~= text2 then
			showHint(text2) -- equivalent call inferred; original call site unknown

			if v13 then
				task.delay(5, fadeOutParryBar)
			end
		end

		progressBar.Reward.Visible = false
		progressBar.Fill:TweenSize(UDim2.fromScale(v14, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.4, true)
		progressBar.Fill.Visible = v14 >= 0.015
	end

	local function updateXP()
		if isSerpentFight() then
			updateParries()
			return
		end

		if progressBar.TextLabel.Text ~= text then
			count += 1
			progressBar.TextLabel.Text = text
			setHintTransparency(0)
		end

		progressBar.Reward.Visible = true
		local currentXP = self:GetCurrentXP()
		local nextCrate, v13 = self:GetNextCrate()

		if self:CanClaimNext(currentXP, nextCrate, v13) then
			remoteEvent:FireServer()
		end

		local v14 = not nextCrate and 1 or math.min(currentXP / nextCrate.xp, 1)
		progressBar.XP.Text = not nextCrate and "Max Exp" or `{math.round((math.clamp(currentXP, 0, nextCrate.xp)))}/{math.round(nextCrate.xp)} Exp`
		local vector = progressBar.Reward.Vector
		local image

		if nextCrate then
			image = nextCrate.icon
		else
			image = v10[#v10].icon
		end

		vector.Image = image
		progressBar.Fill:TweenSize(UDim2.fromScale(v14, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.4, true)
		progressBar.Fill.Visible = v14 >= 0.015
	end

	progressBar.Reward.Activated:Connect(function()
		updateXP()

		if self:CanClaimNext(self:GetCurrentXP(), self:GetNextCrate()) then
			remoteEvent:FireServer()
		end
	end)
	local v13 = { "BossBlizzardBreakout", "BossHolidayHeist" }

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateProgressBarVisibility()
		local currentlySelectedMode = workspace:GetAttribute("CurrentlySelectedMode")
		local v14 = progressBar
		local visible = not flag

		if visible then
			local index = currentlySelectedMode and table.find(v13, currentlySelectedMode)
			visible = not index
		end

		v14.Visible = visible
	end

	local currentlySelectedMode = workspace:GetAttribute("CurrentlySelectedMode")
	local visible2 = not flag

	if visible2 then
		local index = currentlySelectedMode and table.find(v13, currentlySelectedMode)
		visible2 = not index
	end

	progressBar.Visible = visible2
	workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(function()
		updateProgressBarVisibility() -- equivalent call inferred; original call site unknown
		updateXP()
	end)
	workspace:GetAttributeChangedSignal("SerpentParriesRequired"):Connect(updateXP)
	localPlayer.AttributeChanged:Connect(function(value: string)
		if value == "SerpentParries" then
			updateXP()
		elseif string.find(value, "Boss") then
			if string.find(value, "Crate") then
				SoundService.SFX.ChestUnlocked:Play()
			end

			updateXP()
		end
	end)
	task.spawn(updateXP)
	local v15 = {
		Centipede = bossUI.Frame,
		Serpent = bossUI.Frame,
		Snownman = bossUI.SnowmanFrame
	}

	local function updateHealth(p: string, p2: number, p3: number)
		local v16 = v15[p]

		for _, v17 in v15 do
			v17.Visible = v17 == v16
		end

		local v17 = math.floor(p3 / 3)
		local v18 = math.ceil(p2 / v17)
		local v19 = p2 % v17 / v17
		local v20 = p2 ~= 0 and p2 % v17 == 0 and 1 or v19

		for _, image in v16.BossHealth:GetChildren() do
			if not image:IsA("ImageLabel") then
				continue
			end

			local name = tonumber(image.Name)

			if name == v18 then
				image.Bar.Size = UDim2.new(v20, 0, 1, 0)
				image.Bar.Visible = true
			else
				image.Bar.Visible = not (v18 < name)
			end
		end
	end

	local function updateProgress(p: string, _: string, p2: number, p3: number, value: number?, ...)
		local v16 = v15[p]
		local bossPhase = workspace:GetAttribute("BossPhase") or 1
		local v17

		if bossPhase >= 7 then
			v17 = "Dragon"
		elseif not (bossPhase >= 4) then
			v17 = "Centipede"
		elseif workspace:GetAttribute("FireMechAlive") then
			v17 = "Fire Mech"
		else
			v17 = "Kraken"
		end

		v16.ProgressBar.Fill.Size = UDim2.new(p2 / p3, 0, 1, 0)

		if bossPhase == 6 then
			v16.ProgressBar.Label.Text = "Climb the mountain"
		elseif p2 <= 0 then
			if bossPhase <= 2 then
				v16.ProgressBar.Label.Text = "Eliminate enemies to advance"
				return
			end

			v16.ProgressBar.Circle.Label.Text = "!"
			v16.ProgressBar.Label.Text = `{v17} is Vulnerable!`
			v16.ProgressBar.Label.Size = UDim2.fromScale(1, 1.4)
		elseif (value or 0) > 0 then
			local _, v18 = ...
			v16.ProgressBar.Circle.Label.Text = `x{p2}`
			v16.ProgressBar.Label.Text = v18 and "Eliminate enemies to advance" or `Eliminate enemies to damage {v17}`
			v16.ProgressBar.Label.Size = UDim2.fromScale(1, 2.8)
		else
			v16.ProgressBar.Circle.Label.Text = `x{p2}`
			v16.ProgressBar.Label.Text = `Hits until {v17} is Vulnerable`
			v16.ProgressBar.Label.Size = UDim2.fromScale(1, 1.6)
		end
	end

	local function updateProgressNew(data)
		local v16 = assert(v15[data.EnemyType], "EnemyType not found")
		local v17 = math.clamp(data.Progress / data.ProgressTarget, 0, 1)
		v16.ProgressBar.Fill.Size = UDim2.new(v17, 0, 1, 0)
		v16.ProgressBar.Fill.Visible = v17 >= 0.02
		v16.ProgressBar.Circle.Label.Text = data.CircleText
		v16.ProgressBar.Label.Text = data.Text
		v16.ProgressBar.Label.Size = data.Size
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setShow()
		bossUI.Enabled = true

		if isSerpentFight() then
			showHint(progressBar.TextLabel.Text) -- equivalent call inferred; original call site unknown
		end

		v6(Enum.CoreGuiType.PlayerList, false)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setHide()
		v6(Enum.CoreGuiType.PlayerList, false)
		bossUI.Enabled = false
	end

	v11:Connect("UpdateBossData", function(p, ...)
		if p == "Health" then
			updateHealth(...)
		elseif p == "Progress" then
			updateProgress(...)
		elseif p == "ProgressNew" then
			updateProgressNew(...)
		elseif p == "Show" then
			setShow() -- equivalent call inferred; original call site unknown
		elseif p == "Hide" then
			setHide() -- equivalent call inferred; original call site unknown
		end
	end)
	v11:Connect("BossEndScreen", function(flag2: boolean, ...)
		if flag2 then
			self:ShowResultScreen(...)
		else
			bossEndScreen.Enabled = false
		end
	end)
	workspace:GetAttributeChangedSignal("BossPhase"):Connect(function(...)
		if (workspace:GetAttribute("BossPhase") or 0) > 1 then
			SoundService.SFX.WaveCompleted:Play()
			phaseComplete.Enabled = true
			phaseComplete.CanvasGroup.Position = UDim2.fromScale(0.5, -0.2)
			phaseComplete.CanvasGroup.UIScale.Scale = 0.2
			phaseComplete.CanvasGroup.GroupTransparency = 1
			local tween = TweenService:Create(
				phaseComplete.CanvasGroup,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					GroupTransparency = 0,
					Position = UDim2.fromScale(0.5, 0.2)
				}
			)
			tween:Play()
			TweenService:Create(
				phaseComplete.CanvasGroup.UIScale,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Scale = 1
				}
			):Play()
			tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					task.delay(0.75, function()
						local tween2 = TweenService:Create(
							phaseComplete.CanvasGroup,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								GroupTransparency = 1,
								Position = UDim2.fromScale(0.5, 0.4)
							}
						)
						tween2:Play()
						TweenService:Create(
							phaseComplete.CanvasGroup.UIScale,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								Scale = 0.8
							}
						):Play()
						tween2.Completed:Once(function(p2)
							if p2 == Enum.PlaybackState.Completed then
								phaseComplete.Enabled = false
							end
						end)
					end)
				end
			end)

			for i = 1, v5.getProperParticlesToScreen() do
				v5.createParticle(
					Vector2.new(0.5, 1),
					Vector2.new(math.random(0, 180) - 90, math.random(100, 160) * (i // 6 + 1)),
					bossConfetti
				)
			end
		end
	end)
	local frame3 = bossEndScreen.OddsFrame.Frame
	local template2 = frame3.Template
	template2.Parent = nil

	for childName, v16 in v10 do
		local child = frame3.List:FindFirstChild(childName)

		if not child then
			continue
		end

		child.Crate.Image = v16.icon
		local weights = v2.getWeights(v16.rewards)
		local v17 = {}

		for k, relativeWeight in weights.relativeWeights do
			v17[weights.options[k]] = math.floor(relativeWeight * 100 * 100) / 100
		end

		for k, layoutOrder in v17 do
			local clone = template2:Clone()
			clone.LayoutOrder = layoutOrder
			clone.Percent.Text = `{layoutOrder}%`
			clone.Vector.Image = k.Icon
			clone.Visible = true
			clone.Parent = child.Odds
		end
	end

	frame3.Close.Activated:Connect(function()
		bossEndScreen.OddsFrame.Visible = false
	end)
	local position = bossUI.ProgressBar.Position

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateHeight()
		bossUI.ProgressBar.Position = position - UDim2.fromOffset(
			0,
			not v.KeyboardEnabled and 0 or GuiService.TopbarInset.Height
		)
	end

	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(updateHeight)
	v:GetPropertyChangedSignal("KeyboardEnabled"):Connect(updateHeight)
	updateHeight() -- equivalent call inferred; original call site unknown
	v11:Connect("BossDialogue", function(...)
		v7:SendText(...)
	end)
end

return BossUIController