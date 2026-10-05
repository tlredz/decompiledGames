local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

require(game.ReplicatedStorage.Controllers.AnalyticsController)
local Replion = require(game.ReplicatedStorage.Packages.Replion)
local ServerInfo = require(game.ReplicatedStorage.ServerInfo)
require(game.ReplicatedStorage.Common.SettingsInfo)
local DeviceListener = require(game.ReplicatedStorage.ClientGameModules.DeviceListener)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
Inventory = Inventory.Client
require(ReplicatedStorage.Shared.AbilityUtils)
Replion.Client:WaitReplion("Data")
local uIGradient = script.Parent:WaitForChild("SecondAbility"):WaitForChild("UIGradient")
local secondAbility = script.Parent:WaitForChild("SecondAbility")
local ready = secondAbility:WaitForChild("ready")
local counts = ready:WaitForChild("counts")
local dashButton = Players.LocalPlayer.PlayerGui.MobileDashButton.TouchControlFrame.DashButton

local function onAbilityChanged(p)
	if p == "Blink" or p == "Dribble" or p == "Dragon Spirit" or p == "Water Dragon" or p == "Bounty" or p == "Guardian Angel" or p == "Nab" or p == "Necromancer" or p == "Tsunami" then
		counts.Visible = true
	else
		counts.Visible = false
	end

	ready.Visible = true
end

local function UpdateBlockButtons()
	local _ = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not (UserInputService.GamepadEnabled or GuiService:IsTenFootInterface()) or DeviceListener:IsMobile()
end

DeviceListener:Observe(UpdateBlockButtons)
local v = nil
local v2 = nil
local v3 = nil
local v4 = math.random()

local function visualcd(p, p2, duration, p3)
	if ServerInfo.isLTMServer() then
		local LTM = require(ReplicatedStorage2.Shared.LTM)

		if LTM.getPriorityLTM().getGameMode() == "Flying" then
			return
		end
	end

	if p then
		return
	end

	if p2 then
		local v5 = math.random()
		v4 = v5
		uIGradient.Offset = Vector2.new(0, -0.5)

		if p3 then
			uIGradient.Offset = Vector2.new(0, -0.5):Lerp(Vector2.new(0, 0.5), duration)
		else
			local v6 = {
				Offset = Vector2.new(0, 0.5)
			}
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

			if v and v.PlaybackState == Enum.PlaybackState.Playing then
				v:Cancel()
			end

			v = TweenService:Create(uIGradient, tweenInfo, v6)
			v:Play()
			v.Completed:Once(function()
				v:Destroy()
			end)
			dashButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end

		task.spawn(function()
			local v6 = false
			local v7 = duration > 14.5

			if v7 then
				task.wait(14.5)
				v6 = game.Players.LocalPlayer.Character.Parent == workspace.Dead and not game.Players.LocalPlayer:GetAttribute("LobbyParry") or false
			end

			if v6 then
				return
			end

			if v7 then
				if duration < 10000 then
					task.wait(duration - 14.5)
				end
			elseif duration < 10000 then
				task.wait(duration)
			end

			if game.Players.LocalPlayer.Character.Parent == workspace.Dead and not game.Players.LocalPlayer:GetAttribute("LobbyParry") then
				return
			end

			if duration < 10000 and v4 == v5 then
				Lighting.cc1.Enabled = false
				Lighting.cc2.Enabled = false

				if not p3 then
					ReplicatedStorage2.Misc.AbilityReadyNew:Play()
				end

				if v2 and v2.PlaybackState == Enum.PlaybackState.Playing then
					v2:Cancel()
				end

				if v3 and v3.PlaybackState == Enum.PlaybackState.Playing then
					v3:Cancel()
				end

				local ready2 = secondAbility.ready
				ready2.ImageTransparency = 1
				ready2.Visible = true
				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
				v2 = TweenService:Create(ready2, tweenInfo, {
					ImageTransparency = 0
				})
				v2:Play()
				v2.Completed:Once(function()
					v2:Destroy()
				end)
				dashButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				v3 = TweenService:Create(dashButton, tweenInfo, {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				})
				v3:Play()
				v3.Completed:Once(function()
					v3:Destroy()
				end)
			end
		end)
	else
		if v then
			v:Cancel()
		end

		uIGradient.Offset = Vector2.new(0, 0.5)
		dashButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end

ReplicatedStorage2.Remotes.SecondaryVisualCD.OnClientEvent:Connect(visualcd)
ReplicatedStorage2.Remotes.SecondaryVisualBindableCD.Event:Connect(visualcd)
task.defer(function()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAbility()
		counts.Visible = false
		ready.Visible = true
	end

	updateAbility() -- equivalent call inferred; original call site unknown
end)