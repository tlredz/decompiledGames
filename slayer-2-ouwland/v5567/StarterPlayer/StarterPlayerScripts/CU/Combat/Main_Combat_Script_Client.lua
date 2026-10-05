local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Combat_Package"):WaitForChild("Normal"):WaitForChild("Swing_Sounds")
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Run_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Run_Handler"))
local clock = os.clock
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local v = nil
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local swings = game.ReplicatedStorage:WaitForChild("Effects"):WaitForChild("Swings")
local MainCombatScriptClient = {
	CanAirCombo = true,
	UpdraftRequested = false
}
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)

function MainCombatScriptClient.Do(p: number, p2, p3: string, p4: string)
	local max = p2.Max or 5
	local animations = game.ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Animations")
	local v3 = animations:FindFirstChild(p3 .. "_Combat_Anims") or animations:FindFirstChild("Combat_Combat_Anims")
	local v4

	if p4 == nil then
		v4 = v3
	else
		v4 = animations:FindFirstChild(p4 .. "_Combat_Anims") or v3
	end

	local function findRunHit(flag: boolean)
		local run_Hit

		if not flag then
			run_Hit = v4:FindFirstChild("Run_Hit") or v3 ~= nil and v3:FindFirstChild("Run_Hit") or nil
		end

		if run_Hit == nil then
			local combat_Combat_Anims = animations:FindFirstChild("Combat_Combat_Anims")
			run_Hit = combat_Combat_Anims ~= nil and combat_Combat_Anims:FindFirstChild("Run_Hit") or nil
		end

		return run_Hit
	end

	if v ~= nil then
		v:Stop()
		v = nil
	end

	local combovalue = p.Value
	local character = game.Players.LocalPlayer.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	Combat_presets.stop_extra_anims(humanoid, { "Swing_6", "Swing_7" })
	local v5 = humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil or humanoid.FloorMaterial == Enum.Material.Air or humanoid.FloorMaterial == nil

	if v5 == true and humanoidRootPart:FindFirstChild("air_combo_bp") == nil and humanoid.Jump and humanoidRootPart.AssemblyLinearVelocity.Y > 0.25 then
		v5 = false
	end

	local v6

	if Run_Handler.Is_Running and humanoid.MoveDirection.Magnitude > 0 or Checker.Dashing == true then
		v6 = combovalue == 1
	else
		v6 = false
	end

	local v7

	if MainCombatScriptClient.CanAirCombo then
		v7 = InputHandler.IsDown("Jump") or MainCombatScriptClient.UpdraftRequested == true
	elseif v5 then
		if p.Value == 5 then
			v7 = InputHandler.IsDown("Jump") or MainCombatScriptClient.UpdraftRequested == true
		else
			v7 = false
		end
	else
		v7 = v5
	end

	local v8 = not v5 and v7 == true and combovalue < max and combovalue >= 1 and 6 or combovalue
	local v9 = v5 == true and v7 == false and v8 == max and 7 or v8
	local v10 = Combat_presets.runHitPreset(p2, v6 and v9 == 1)
	local v11 = v10 ~= p2
	local v12 = (v6 ~= true or v10.run_swing_remove_on_first == nil) and 0 or v10.run_swing_remove_on_first

	if v7 then
		MainCombatScriptClient.CanAirCombo = false
		MainCombatScriptClient.UpdraftRequested = false
	end

	local delay_before_swing = v10.delay_before_swing
	local v13 = delay_before_swing ~= nil and delay_before_swing[v9] or v10.default_before_swing or Combat_presets.Default_Swing_Wait or 0
	local flag = false
	ManuelCancel.new(character, v13):Connect(function()
		flag = true
	end)
	task.delay(v13, function()
		if flag then
			return
		end

		local v14

		if not (p4 == nil or not swings:FindFirstChild(p4 .. "_Swings")) then
			v14 = p4
		end

		game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire(
			(v11 and "Combat" or v14 or p3) .. "_Swings",
			character,
			v9,
			v6
		)
		local delay_before_hit = v10.delay_before_hit
		local attackSpeedMult = Combat_presets.attackSpeedMult(game.Players.LocalPlayer)
		local v15 = ((delay_before_hit ~= nil and delay_before_hit[v9] or v10.default_before_hit or v13) - v12 - v13) / attackSpeedMult
		SignalEvent.ToServer("Combat_Service", p3, combovalue, v6, v15, v7, v14)
		task.wait(v15)

		if Checker.check(game.Players.LocalPlayer, "combat") == true then
			Cam_Shaker(humanoidRootPart.Position, "punch_shake")
		end
	end)

	if v6 == true then
		Combat_presets.lastRunHit = clock()
	else
		Combat_presets.Last_Punched = clock()
	end

	Combat_presets.Last_Punched_Jump = clock()
	local v14 = v9 < 6 and v6 == true and findRunHit(v11) or v4:FindFirstChild("Swing_" .. v9)
	local track = nil

	if character and character:FindFirstChild("Accessories") and character.Accessories:FindFirstChild("CustomRig") then
		local animController = character.Accessories.CustomRig:FindFirstChild("AnimController")

		if animController then
			track = animController.Animator:LoadAnimation(v14)
		end
	else
		track = humanoid.Animator:LoadAnimation(v14)
	end

	if v9 == max then
		v = track
	end

	track:Play()
	local animSpeed = v10.AnimSpeed

	if animSpeed then
		local v15 = v6 and -1 or v9
		local v16 = (p4 ~= nil and animSpeed[p4 .. tostring(v15)] or animSpeed[v15] or animSpeed.Default or 1) * Combat_presets.attackSpeedMult(game.Players.LocalPlayer)

		if v16 then
			track:AdjustSpeed(v16)
		end
	end

	return {
		combovalue = combovalue
	}
end

return MainCombatScriptClient