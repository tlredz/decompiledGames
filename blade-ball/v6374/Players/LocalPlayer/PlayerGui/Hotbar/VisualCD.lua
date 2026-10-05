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
local SettingsInfo = require(game.ReplicatedStorage.Common.SettingsInfo)
local DeviceListener = require(game.ReplicatedStorage.ClientGameModules.DeviceListener)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
Inventory = Inventory.Client
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local v = Replion.Client:WaitReplion("Data")
local uIGradient = script.Parent:WaitForChild("Block"):WaitForChild("UIGradient")
local uIGradient2 = script.Parent:WaitForChild("Ability"):WaitForChild("UIGradient")
local ability = script.Parent:WaitForChild("Ability")
local block = script.Parent:WaitForChild("Block")
local ready = ability:WaitForChild("ready")
local counts = ready:WaitForChild("counts")
task.delay(3, function()
	if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
		local _ = not GuiService:IsTenFootInterface()
	end

	local _ = not ServerInfo.isElementalServer()
end)
pcall(function()
	game.StarterGui:SetCore("ResetButtonCallback", false)
end)
pcall(function()
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

local function onAbilityChanged(p)
	if p == "Blink" or p == "Dribble" or p == "Dragon Spirit" or p == "Water Dragon" or p == "Bounty" or p == "Guardian Angel" or p == "Nab" or p == "Necromancer" or p == "Tsunami" then
		counts.Visible = true
	else
		counts.Visible = false
	end

	ready.Visible = true
end

local function UpdateBlockButtons()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not (UserInputService.GamepadEnabled or GuiService:IsTenFootInterface()) or DeviceListener:IsMobile() then
		ability.SlashOfDualityCDs.Position = UDim2.fromScale(-0.1, 0.1)
		ability.SlashOfDualityCDs.AnchorPoint = Vector2.new(1, 0)
		ability.DurationOld.Position = UDim2.new(0.534, 0, 1.25, -3)

		for _, descendant in pairs(script.Parent.Parent:GetDescendants()) do
			if descendant.Name == "hoversets" then
				descendant:Destroy()
			end
		end

		for _, button in pairs(script.Parent:GetDescendants()) do
			if not button:IsA("ImageButton") then
				continue
			end

			local name = button.Name

			if name == "HotkeyFrame" then
				button:Destroy()
			end

			for _, guiObject in pairs(script.Parent.Parent:WaitForChild("mobileRefs"):GetChildren()) do
				if not (guiObject.Name == name and guiObject:IsA("GuiObject")) then
					continue
				end

				if button:FindFirstChildOfClass("UIAspectRatioConstraint") then
					button:FindFirstChildOfClass("UIAspectRatioConstraint"):Destroy()
				end

				button.Position = guiObject.Position
			end
		end

		local hUD = script.Parent.Parent:WaitForChild("HUD")
		hUD.Boosts.Position = script.Parent.Parent.mobileRefs.Boosts.Position
		script.Parent.Ability.ready.counts.Position = UDim2.fromScale(0, 0.987)
		local _ = DeviceListener.Device == "Phone"
		local _ = DeviceListener.Device == "Tablet"

		for _, v3 in { block, ability } do
			local name = v3.Name
			-- equivalent calls inferred from this helper; original call sites unknown
			local v5 = {
				"Settings",
				"Misc",
				name .. "ButtonScale",
				"Current"
			}
			local v6 = v3

			local function reflectScale()
				local v7 = v:Get(v5) or 1
				v6.UIScale.Scale = math.clamp(v7, 1, 2)
			end

			reflectScale() -- equivalent call inferred; original call site unknown
			v:OnDescendantChange("Settings", reflectScale)
			local v8 = {
				"Settings",
				"Misc",
				name .. "ButtonPosition",
				"Current"
			}
			local v9 = v3

			local function reflectPosition()
				local v11 = v:Get(v8)

				if v11 and v11.X and v11.Y then
					v9.Position = UDim2.fromScale(v11.X, v11.Y)
					return
				end

				local default = SettingsInfo.Misc[name .. "ButtonPosition"].Default
				v9.Position = UDim2.fromScale(default.X, default.Y)
			end

			reflectPosition()
			v:OnDescendantChange("Settings", reflectPosition)
		end
	end

	if ServerInfo.isTradingPlazaServer() then
		local toggleTradingSign = script.Parent.ToggleTradingSign
		local anchorPoint = block.AnchorPoint
		local position = block.Position

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local visible = toggleTradingSign.Visible
			block.AnchorPoint = visible and anchorPoint or Vector2.new(0.5, 0)
			block.Position = visible and position or UDim2.fromScale(0.5, 0.803)
			toggleTradingSign.AnchorPoint = ability.AnchorPoint
			toggleTradingSign.Position = ability.Position
		end

		toggleTradingSign:GetPropertyChangedSignal("Visible"):Connect(update)
		ability:GetPropertyChangedSignal("Position"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

DeviceListener:Observe(UpdateBlockButtons)
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = math.random()

local function visualcd(p, p2, duration, p3)
	if ServerInfo.isLTMServer() then
		local LTM = require(ReplicatedStorage2.Shared.LTM)

		if LTM.getPriorityLTM().getGameMode() == "Flying" then
			return
		end
	end

	if p then
		if p2 then
			uIGradient.Offset = Vector2.new(0, -0.5)

			if duration < 0.5 then
				duration = math.min(duration + 0.1, 0.5)
			end

			local v6 = {
				Offset = Vector2.new(0, 0.5)
			}
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

			if v2 and v2.PlaybackState == Enum.PlaybackState.Playing then
				v2:Cancel()
			end

			v2 = TweenService:Create(uIGradient, tweenInfo, v6)
			v2:Play()
		else
			if v2 then
				v2:Cancel()
			end

			uIGradient.Offset = Vector2.new(0, 0.5)
		end
	elseif p2 then
		local v6 = math.random()
		v5 = v6
		uIGradient2.Offset = Vector2.new(0, -0.5)

		if p3 then
			uIGradient2.Offset = Vector2.new(0, -0.5):Lerp(Vector2.new(0, 0.5), duration)
		else
			local v7 = {
				Offset = Vector2.new(0, 0.5)
			}
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

			if v3 and v3.PlaybackState == Enum.PlaybackState.Playing then
				v3:Cancel()
			end

			v3 = TweenService:Create(uIGradient2, tweenInfo, v7)
			v3:Play()
			v3.Completed:Once(function()
				v3:Destroy()
			end)
		end

		task.spawn(function()
			local v7 = false
			local v8 = duration > 14.5

			if v8 then
				task.wait(14.5)
				local character = game.Players.LocalPlayer.Character

				if not character or character.Parent == workspace.Dead then
					v7 = not game.Players.LocalPlayer:GetAttribute("LobbyParry") or false
				end
			end

			if v7 then
				return
			end

			if v8 then
				if duration < 10000 then
					task.wait(duration - 14.5)
				end
			elseif duration < 10000 then
				task.wait(duration)
			end

			local character = game.Players.LocalPlayer.Character

			if (not character or character.Parent == workspace.Dead) and not game.Players.LocalPlayer:GetAttribute("LobbyParry") then
				return
			end

			if duration < 10000 and v5 == v6 then
				Lighting.cc1.Enabled = false
				Lighting.cc2.Enabled = false

				if not p3 then
					ReplicatedStorage2.Misc.AbilityReadyNew:Play()
				end

				if v4 and v4.PlaybackState == Enum.PlaybackState.Playing then
					v4:Cancel()
				end

				local ready2 = script.Parent.Ability.ready
				ready2.ImageTransparency = 1
				ready2.Visible = true
				v4 = TweenService:Create(
					ready2,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
					{
						ImageTransparency = 0
					}
				)
				v4:Play()
			end
		end)
	else
		if v3 then
			v3:Cancel()
		end

		uIGradient2.Offset = Vector2.new(0, 0.5)
	end
end

ReplicatedStorage2.Remotes.VisualCD.OnClientEvent:Connect(visualcd)
ReplicatedStorage2.Remotes.VisualBindableCD.Event:Connect(visualcd)
task.defer(function()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAbility()
		local equippedAbility = AbilityUtils.getEquippedAbility(Players.LocalPlayer)

		if equippedAbility then
			local name = equippedAbility.Name

			if name == "Blink" or name == "Dribble" or name == "Dragon Spirit" or name == "Water Dragon" or name == "Bounty" or name == "Guardian Angel" or name == "Nab" or name == "Necromancer" or name == "Tsunami" then
				counts.Visible = true
				ready.Visible = true
			else
				counts.Visible = false
				ready.Visible = true
			end
		end
	end

	AbilityUtils.onEquip(Players.LocalPlayer, updateAbility)
	updateAbility() -- equivalent call inferred; original call site unknown
end)
local v6 = 1
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	local UseBall2 = require(ReplicatedStorage2.Shared.UseBall2)

	if not UseBall2() then
		return
	end

	local Abilities = require(game.ReplicatedStorage.Shared.Abilities)
	local character = game.Players.LocalPlayer.Character

	if not character then
		return
	end

	local v7 = 1 - Abilities.getCooldown(character).currentCooldownRemainingAlpha
	visualcd(false, true, v7, true)

	if v7 == 1 and v6 ~= 1 and character and character.Parent == workspace.Alive then
		ReplicatedStorage2.Misc.AbilityReadyNew:Play()
	end

	v6 = v7
end)