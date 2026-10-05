local UserInputService = game:GetService("UserInputService")
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Component = require(game.ReplicatedStorage.Modules.Component)
local CombatController = require(game.ReplicatedStorage.Controllers.CombatController)
local GetPlayer = require(game.ReplicatedStorage.Modules.Player.GetPlayer)
local CombatUtil = require(game.ReplicatedStorage.Modules.CombatUtil)
local MobileCombatInput = require(game.ReplicatedStorage.Modules.MobileCombatInput)
local OnlyLocalPlayer = require(game.ReplicatedStorage.Modules.Extensions.OnlyLocalPlayer)
local IsNewCombatSystemEnabled = require(game.ReplicatedStorage.Modules.Extensions.IsNewCombatSystemEnabled)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "WeaponTool",
	Extensions = { OnlyLocalPlayer, IsNewCombatSystemEnabled }
})

function v:Construct()
	local instance = self.Instance
	local weaponName = CombatUtil:GetWeaponName(instance)
	self.weaponName = weaponName
	self.weaponData = CombatUtil:GetWeaponData(weaponName)
	self.weaponType = self.weaponData.WeaponType
	self.player = GetPlayer(instance)
	self.trove = Trove.new()
	instance:SetAttribute("LocalShotsLeft", self.weaponData.MagSize)
	instance:SetAttribute("LocalTotalShots", 0)

	if self.weaponData.ShootStyle == "Gatling" then
		self.isGatling = true
		instance:SetAttribute("Overheat", 0)
		instance:SetAttribute("LocalOverheat", 0)
	end
end

function v.Start(data)
	local instance = data.Instance

	local function activated(input)
		if data.weaponData.WeaponType == "Melee" then
			CombatController:Attack(instance)
			return
		end

		local equippedWeapon = localPlayer.Character and localPlayer.Character:FindFirstChild("EquippedWeapon")

		if equippedWeapon and CombatUtil:GetPureWeaponName(equippedWeapon:GetAttribute("WeaponName")) == CombatUtil:GetPureWeaponName(data.weaponName) then
			CombatController:Attack(instance, input)
		end
	end

	local v2 = {}
	data.trove:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local v3 = instance.Parent == localPlayer.Character

		if gameProcessed or not v3 or MobileCombatInput.isGuiTouch(input) then
			return
		end

		local userInputType = input.UserInputType
		local v4 = input.KeyCode == Enum.KeyCode.ButtonR2

		if userInputType == Enum.UserInputType.Touch or userInputType == Enum.UserInputType.MouseButton1 or v4 then
			if input.UserInputType == Enum.UserInputType.Touch then
				local v5 = next(v2) ~= nil
				v2[input] = true

				if v5 or MobileCombatInput.isM1Blocked() then
					return
				end
			end

			activated(input)
		end
	end))
	data.trove:Add(UserInputService.InputEnded:Connect(function(input)
		v2[input] = nil
	end))

	if not data.player.Character:IsDescendantOf(workspace) then
		repeat
			task.wait()
		until data.player.Character:IsDescendantOf(workspace)
	end

	CombatUtil:ToggleLoadMovesetAnims(data.player.Character.Humanoid, data.weaponData, true)
	data.trove:Add(function()
		local humanoid = data.player.Character and data.player.Character:FindFirstChild("Humanoid")

		if humanoid then
			CombatUtil:ToggleLoadMovesetAnims(humanoid, data.weaponData, false)
		end
	end)
end

function v.Stop(p)
	p.trove:Destroy()
end

return v