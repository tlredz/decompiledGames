local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
game:GetService("Debris")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Replion = require(ReplicatedStorage.Packages.Replion)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
Inventory = Inventory.Client
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
require(ReplicatedStorage.Packages.Trove)
local v = false
local mouseButton2 = Enum.UserInputType.MouseButton2
local playerGui = localPlayer:WaitForChild("PlayerGui")
local vector = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local qiAbilityMeter = playerGui.QiAbilityMeter
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""
local v2 = {
	[0] = Color3.new(1, 1, 1),
	[1] = Color3.new(0.490196, 0.882353, 1),
	[2] = Color3.new(1, 0.494118, 0.611765),
	[3] = Color3.new(1, 0.258824, 0.270588)
}
local thread = nil
local v3 = false

local function ability(p, p2)
	if v3 or v or localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false then
		if p2 then
			ReplicatedStorage3.Remotes.PlrAdrenalined:FireServer(p)
		end
	else
		ReplicatedStorage3.Remotes.PlrAdrenalined:FireServer(p)

		if p or not localPlayer.Character:GetAttribute("ChargingAdrenaline") then
			if p then
				if thread then
					coroutine.close(thread)
					thread = nil
				end

				local v4 = 1 / (10 - (localPlayer.Upgrades["Qi-Charge"].Value or 0))
				local adrenalineChargeProgress = character:GetAttribute("AdrenalineChargeProgress") or 0
				thread = task.spawn(function()
					qiAbilityMeter.Bg.Position = UDim2.fromScale(0.5, 0.78)
					qiAbilityMeter.Bg:TweenPosition(
						UDim2.fromScale(0.5, 0.75),
						Enum.EasingDirection.InOut,
						Enum.EasingStyle.Sine,
						0.25,
						true
					)
					local adrenaline = character:GetAttribute("Adrenaline")

					while true do
						local adrenaline2 = character:GetAttribute("Adrenaline")

						if adrenaline2 ~= adrenaline then
							adrenalineChargeProgress = character:GetAttribute("AdrenalineChargeProgress") or 0
							adrenaline = adrenaline2
						end

						qiAbilityMeter.Bg.TextLabel.Text = `{adrenalineChargeProgress * 1000 // 10}%`
						qiAbilityMeter.Bg.Fill.Meter.Offset = Vector2.new(-1 + adrenalineChargeProgress, 0)
						qiAbilityMeter.Bg.FillGlow.Meter.Offset = Vector2.new(-1 + adrenalineChargeProgress, 0)
						qiAbilityMeter.Bg.FillGlow.ImageTransparency = 1 - 0.75 * (adrenaline2 or 0) / 3
						qiAbilityMeter.Bg.FillGlow.ImageColor3 = v2[adrenaline2 or 0]
						local v5 = (adrenalineChargeProgress - 0.85) / 0.15

						if v5 > 0 then
							qiAbilityMeter.Bg.Position = UDim2.new(
								0.5,
								v5 * (math.random() - 0.5) * 20,
								0.75,
								v5 * (math.random() - 0.5) * 20
							)
						end

						local v6 = task.wait()
						adrenalineChargeProgress = math.clamp(adrenalineChargeProgress + v6 * v4, 0, 1)
					end
				end)
			end
		else
			if thread then
				coroutine.close(thread)
				thread = nil
			end

			v3 = true
			task.wait(0.05)
			v3 = false
		end

		v = false
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability(true)
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") and not v3 and not v and localPlayer.Character.Parent == workspace.Alive then
		if localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false then
			return
		end

		ReplicatedStorage3.Remotes.PlrAdrenalined:FireServer(false)

		if localPlayer.Character:GetAttribute("ChargingAdrenaline") then
			if thread then
				coroutine.close(thread)
				thread = nil
			end

			v3 = true
			task.wait(0.05)
			v3 = false
		end

		v = false
	end
end)
local v4 = false
ReplicatedStorage3.Remotes.AbilityButtonPress.Event:Connect(function()
	v4 = not v4
	ability(v4)
end)
ReplicatedStorage3.Remotes.DashFired.Event:Connect(function()
	task.spawn(function() end)
end)
ReplicatedStorage3.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false
end)
ReplicatedStorage3.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)
localPlayer.Character:GetAttributeChangedSignal("ChargingAdrenaline"):Connect(function()
	qiAbilityMeter.Bg.Visible = localPlayer.Character:GetAttribute("ChargingAdrenaline") and true or false
end)
qiAbilityMeter.Bg.Visible = localPlayer.Character:GetAttribute("ChargingAdrenaline") and true or false
qiAbilityMeter.Enabled = character.Parent == workspace.Alive
Replion.Client:WaitReplion("Data")
local v5 = nil
v5 = AbilityUtils.onEquip(localPlayer, function(p, _)
	if not p or p.Name ~= "Qi-Charge" then
		v5:Destroy()
		qiAbilityMeter.Enabled = false
	end
end)
character.AncestryChanged:Connect(function()
	qiAbilityMeter.Enabled = character.Parent == workspace.Alive

	if character.Parent ~= workspace.Alive and not v3 and not v and localPlayer.Character.Parent == workspace.Alive then
		if localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false then
			return
		end

		ReplicatedStorage3.Remotes.PlrAdrenalined:FireServer(false)

		if localPlayer.Character:GetAttribute("ChargingAdrenaline") then
			if thread then
				coroutine.close(thread)
				thread = nil
			end

			v3 = true
			task.wait(0.05)
			v3 = false
		end

		v = false
	end
end)