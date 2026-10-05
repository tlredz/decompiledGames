local HitscanSingleShot = require(script.Parent.HitscanSingleShot)
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer and localPlayer:GetMouse()
local CombatUtil = require(game.ReplicatedStorage.Modules.CombatUtil)
return function(state, data)
	local Util = require(game.ReplicatedStorage.Util)
	state.ShootAttachment = "ShootAttachment1"
	state.origin = state.HRP.Position
	HitscanSingleShot(state, data)

	for _ = 1, data.NumBurstShots - 1 do
		task.wait(data.ShootInterval)

		if not (state.HRP.Parent:FindFirstChild("EquippedWeapon") and state.HRP.Parent.EquippedWeapon:GetAttribute("WeaponName") == state.WeaponModel) then
			continue
		end

		state.ShootAttachment = "ShootAttachment2"
		local tapPosition = state.TapPosition

		if tapPosition then
			state.TargetPosition = Util.GetMousePoint(tapPosition.X, tapPosition.Y)
		else
			state.TargetPosition = mouse and mouse.Hit.Position or state.TargetPosition
		end

		state.TargetPosition = CombatUtil:GetTargetPosition(state.origin, state.TargetPosition, data.Range)
		HitscanSingleShot(state, data)
	end
end