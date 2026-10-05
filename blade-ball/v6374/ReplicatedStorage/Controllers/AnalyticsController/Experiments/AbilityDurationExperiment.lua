local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Types.Analytics)
require3(ReplicatedStorage2.ServerInfo)
local v = require3(ReplicatedStorage2.Packages.Trove)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
local v2 = require3(ReplicatedStorage2.Shared.AbilityUtils)
local localPlayer = Players.LocalPlayer
local v3 = { "Rapture", "Raging Deflection", "Calming Deflection" }
return {
	RemoteConfig = "ShowAbilityDuration",
	DefaultValue = true,
	TestConfigValues = {
		[true] = 100
	},
	Configs = {
		[true] = function()
			local duration = localPlayer.PlayerGui.Hotbar.Ability.Duration
			local fill = duration.Fill
			duration.Visible = false
			local maid = v.new()
			local maid2 = maid:Extend()

			local function updateBar()
				local abilityDurationStart = localPlayer:GetAttribute("AbilityDurationStart") or 0
				local abilityDuration = localPlayer:GetAttribute("AbilityDuration") or 0

				if abilityDurationStart == 0 or abilityDuration == 0 then
					duration.Visible = false
					maid2:Clean()
				else
					local v4 = math.clamp((workspace:GetServerTimeNow() - abilityDurationStart) / abilityDuration, 0, 1)
					fill.UIGradient.Offset = Vector2.new(0, v4)
					duration.Visible = v4 < 1
				end
			end

			local function updateTimer()
				maid2:Clean()
				local abilityDurationStart = localPlayer:GetAttribute("AbilityDurationStart") or 0
				local abilityDuration = localPlayer:GetAttribute("AbilityDuration") or 0
				math.clamp((workspace:GetServerTimeNow() - abilityDurationStart) / abilityDuration, 0, 1)

				if abilityDurationStart == 0 or abilityDuration == 0 then
					duration.Visible = false
					return
				end

				local equippedAbility = v2.getEquippedAbility(Players.LocalPlayer)

				if equippedAbility and table.find(v3, equippedAbility.Name) then
					duration.Visible = false
					return
				end

				duration.Visible = true
				maid2:Add(RunService.RenderStepped:Connect(updateBar))
			end

			localPlayer:GetAttributeChangedSignal("AbilityDurationStart"):Connect(updateTimer)
			localPlayer:GetAttributeChangedSignal("AbilityDuration"):Connect(updateTimer)
			updateTimer()

			local function onCharAdded(instance)
				maid:Clean()
				duration.Visible = false
				maid:Add(instance.AncestryChanged:Connect(function()
					if instance.Parent == workspace.Dead then
						duration.Visible = false
						maid2:Clean()
					end
				end))
			end

			localPlayer.CharacterAdded:Connect(onCharAdded)

			if localPlayer.Character then
				task.spawn(onCharAdded, localPlayer.Character)
			end
		end
	}
}