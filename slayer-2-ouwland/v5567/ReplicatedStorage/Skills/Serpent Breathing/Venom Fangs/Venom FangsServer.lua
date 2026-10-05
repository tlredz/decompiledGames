local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local VenomFangsServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local ImpactSounds = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Utility"):WaitForChild("ImpactSounds"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local AIM_RADIUS = Config.AIM_RADIUS
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = table.find
local _ = table.remove
local _ = Vector3.new
local _ = tick
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
local value = AppliedTicks.ByName.Venom.Value
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local _ = table.find
local _ = table.remove

function VenomFangsServer.Hold(player, _, p)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")
	p.startpos = humanoidRootPart.Position
	EffectsEvent.ToAllInRange(player, "VenomFangs_effs", player.Character, "Start")
end

local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

function VenomFangsServer.UnHold(player, p, p2)
	if player.Character == nil then
		return
	end

	local v2 = VenomFangsServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil or p == nil then
		return
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CAST_LOCK_DUR)
	local position = humanoidRootPart.Position
	local maximizeRayServer, _, _, _ = RaycastHelper.MaximizeRayServer(
		character,
		position,
		p,
		AIM_RADIUS,
		true,
		5,
		7,
		3
	)
	local unit = (maximizeRayServer - position).unit
	EffectsEvent.ToAllInRange(
		player,
		"VenomFangs_effs",
		player.Character,
		"Teleport",
		p2.startpos,
		maximizeRayServer,
		unit
	)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	local v4, v5 = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	v4:Connect(function()
		VenomFangsServer.Cancel(player)
		VenomFangsServer.Id[player.UserId] = -1
		v3:Destroy()
	end)
	task.wait(Config.TELEPORT_DUR)
	boolValue:Destroy()

	if VenomFangsServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "VenomFangs_effs", player.Character, "Slash")
	local getvaluesfolder2 = Utility.getvaluesfolder(character)
	local cframe = CFrame.lookAlong(maximizeRayServer, unit)
	local modelInRegion = Utility.GetModelInRegion(
		cframe * Config.SLASH_HITBOX_OFFSET,
		Config.SLASH_HITBOX_SIZE,
		nil,
		nil
	)
	local v6 = nil
	local flag = false

	for _, v7 in pairs(modelInRegion) do
		if VenomFangsServer.Id[player.UserId] ~= v2 then
			return
		end

		if not (v7 ~= character and v7:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart2 = v7:FindFirstChild("HumanoidRootPart")
		v7:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v7)
		local getvaluesfolder3 = Utility.getvaluesfolder(v7)

		if v.Both(getvaluesfolder3, {
			pv = getvaluesfolder2,
			name = "Choosing_1"
		}) == true then
			continue
		end

		if check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, v7)
		elseif check_victim == true or check_victim == "Blocking" then
			if check_victim == "Blocking" then
				Combat_Util.Block(script, character, v7, Config.SLASH_BLOCK_BREAK)
			else
				Combat_Util.Damage(script, character, v7, {
					Base = Config.SLASH_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, getvaluesfolder3, Config.SLASH_STUN)
				Combat_Util.Add_air_combo_bp(humanoidRootPart2, humanoidRootPart, nil, humanoidRootPart.Position)
				v6 = v6 or v7
				flag = true
			end
		end
	end

	if v6 ~= nil then
		ImpactSounds.Play(character, script.Parent.Name, v6)
	end

	if flag then
		EffectsEvent.ToAllInRange(player, "VenomFangs_effs", player.Character, "Success")
		script.Parent.Name:gsub(" ", "")
		Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, nil, humanoidRootPart.Position)
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "iframe"
		boolValue2.Parent = getvaluesfolder2
		DebrisModule:AddItem(boolValue2, Config.IFRAME_DUR)
		v3:Destroy()
		v3 = Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.FOLLOWUP_LOCK_DUR)
		task.delay(Config.FOLLOWUP_AT, function()
			if VenomFangsServer.Id[player.UserId] ~= v2 or character == nil or not character:IsDescendantOf(workspace) then
				return
			end

			humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(script.VenomFangsAttacker):Play()
			task.wait(Config.FOLLOWUP_HIT_AT)

			if VenomFangsServer.Id[player.UserId] ~= v2 then
				return
			end

			local lookVector = humanoidRootPart.CFrame.LookVector
			local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

			if vector.Magnitude > 0.001 then
				lookVector = vector.Unit
			end

			local v7 = lookVector * Config.FOLLOWUP_KNOCKBACK
			local v8 = nil

			for _, v9 in pairs(modelInRegion) do
				if VenomFangsServer.Id[player.UserId] ~= v2 then
					return
				end

				if not (v9 ~= character and v9:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")
				local check_victim, _ = Checker.check_victim(script, character, v9)
				local getvaluesfolder3 = Utility.getvaluesfolder(v9)

				if v.Both(getvaluesfolder3, {
					pv = getvaluesfolder2,
					name = "Choosing_1"
				}) == true then
					continue
				end

				if check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v9)
				elseif check_victim == true or check_victim == "Blocking" then
					if check_victim == "Blocking" then
						Combat_Util.Block(script, character, v9, Config.FOLLOWUP_BLOCK_BREAK)
					else
						Combat_Util.Damage(script, character, v9, {
							Base = Config.FOLLOWUP_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, getvaluesfolder3, Config.FOLLOWUP_STUN)
						Combat_Util.Knockback(script, character, humanoidRootPart2, v7, Config.FOLLOWUP_KNOCKBACK_DUR)
						Combat_Util.RagDoll(script, character, getvaluesfolder3, Config.FOLLOWUP_RAGDOLL)
						local v10 = Utility.AddValue(
							getvaluesfolder3,
							value,
							Config.VENOM_DURATION,
							"ObjectValue",
							character
						)
						v10:SetAttribute("Skill", script.Parent.Name)
						v10:SetAttribute("PercentHealth", Config.VENOM_MAX_HEALTH_RATIO)
						v8 = v8 or v9
					end
				end
			end

			if v8 ~= nil then
				ImpactSounds.Play(character, script.Parent.Name, v8)
			end

			v5()
		end)
	end
end

function VenomFangsServer.Cancel(player)
	if player.Character == nil then
		return
	end

	player.Character:SetAttribute("OriginalPositionForSkill", nil)
	EffectsEvent.ToAllInRange(player, "VenomFangs_effs", player.Character, "Cancel")
end

return VenomFangsServer