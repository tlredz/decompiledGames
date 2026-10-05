local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
require(ReplicatedStorage.Shared.ThreadSafeTargetingHelper)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local Utils = require(ReplicatedStorage.Common.Utils)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
require(ReplicatedStorage.Shared.Abilities)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
local v = false
local thread = nil
local thread2 = nil
local thread3 = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local remoteEvent = Net:RemoteEvent("SlashesOfFuryActivate")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
require(ReplicatedStorage.Shared.Abilities[script.Name])
local v6 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v7 = v6:Get({ "AbilityUpgrades", script.Name })
	local icon = attributes.Icon

	for i = 1, v7 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v6:OnChange({ "AbilityUpgrades", script.Name }, updateIcon)
local v7 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getRank()
	if v7 then
		return v7
	end

	local success, rankInGroup = pcall(localPlayer.GetRankInGroup, localPlayer, game.CreatorId)

	if success then
		v7 = rankInGroup
	end

	return v7 or 0
end

local function ability2()
	if v or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	if #workspace.Balls:GetChildren() < 1 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	if ServerInfo.isTestGame() then
		local rank = getRank() -- equivalent call inferred; original call site unknown

		if rank < Utils.FFlag.GetInstantFFlag("SlashesOfFuryMinGroupRank", 4) then
			ReplicatedStorage.Misc.error:Play()
			NotificationController:SendNotification("This ability is currently disabled!")
			return
		end
	end

	v = true
	remoteEvent:FireServer()
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2()
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)
character:GetAttributeChangedSignal("FuryCatch"):Connect(function()
	if not character:GetAttribute("FuryCatch") and v5 then
		v5:Destroy()
		v5 = nil
	end
end)
require(ReplicatedStorage.Controllers.VFXController)
Net:Connect("SlashesOfFuryEnd", function(p)
	if not v then
		return
	end

	local v8 = p - workspace:GetServerTimeNow()
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, v8)
	thread = task.delay(v8, function()
		v = false
		thread = nil
	end)
end)
Net:Connect("SlashesOfFuryParry", function(p: number, duration: number, player, p2: number)
	local v8 = tostring(p)

	if v5 then
		v5:Destroy()
		v5 = nil
	end

	if thread2 then
		Utils.Thread.SafeCancel(thread2)
		thread2 = nil
	end

	if v2 then
		v2:Cancel()
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		v3:Cancel()
		v3:Destroy()
		v3 = nil
	end

	if thread3 then
		Utils.Thread.SafeCancel(thread3)
		thread3 = nil
	end

	if v4 then
		v4:Cancel()
		v4:Destroy()
		v4 = nil
	end

	if player and player.Character and player ~= localPlayer then
		local highlight = Instance.new("Highlight")
		highlight.Name = "FuryHighlight"
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.75
		highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		highlight.Parent = player.Character
		v5 = highlight
	end

	local parent = nil

	for _, child in workspace.Balls:GetChildren() do
		if child:GetAttribute("realBall") or child.Name ~= v8 then
			continue
		end

		parent = child
		break
	end

	if parent then
		local comboCounter = parent:FindFirstChild("ComboCounter")

		if not comboCounter then
			comboCounter = ReplicatedStorage.Assets.ComboCounter:Clone()
			comboCounter.Parent = parent
		end

		comboCounter.TextLabel.UIScale.Scale = 1.2
		comboCounter.TextLabel.Text = `{p2}`
		comboCounter.TextLabel.TextColor3 = Color3.new(1, 1, 1):Lerp(
			Color3.fromHSV((1 - math.min(p2 / 35, 1)) * 0.166666, 1, 1),
			(math.min(p2 / 5, 1))
		)
		comboCounter.StudsOffset = createVector(0, 4, 0)
		v2 = FastUtils.fastTween(
			comboCounter.TextLabel.UIScale,
			TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Scale = 0.6
			}
		):Play()
		v3 = FastUtils.fastTween(
			comboCounter,
			TweenInfo.new(0.6666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				StudsOffset = createVector(0, 3, 0)
			}
		):Play()
		thread2 = task.delay(duration, function()
			comboCounter:Destroy()
		end)
	end

	local furyTimer = localPlayer.PlayerGui:FindFirstChild("FuryTimer")

	if not furyTimer then
		return
	end

	furyTimer.Enabled = true
	furyTimer.Selection.ProgressBar.Fill.Size = UDim2.fromScale(1, 1)
	v4 = FastUtils.fastTween(
		furyTimer.Selection.ProgressBar.Fill,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{
			Size = UDim2.fromScale(0, 1)
		}
	)
	thread3 = task.delay(duration, function()
		print("ended")
		furyTimer.Enabled = false
	end)
end)