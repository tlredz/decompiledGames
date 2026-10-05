local SkillsModule = {
	serverMarginOfError = 1
}
local clock = os.clock
local skills = game.ReplicatedStorage:WaitForChild("Skills")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local AntiCheat

if isServer then
	local ServerStorage = game:GetService("ServerStorage")
	AntiCheat = require(ServerStorage.SAM.AntiCheat)
else
	AntiCheat = nil
end

local find = string.find
local lower = string.lower
task.spawn(function()
	for _, moduleScript in pairs(skills:QueryDescendants("ModuleScript:not([$Ignore])")) do
		if not (RunService:IsServer() and find(lower(moduleScript.Name), "server") or RunService:IsServer() == false and find(
			lower(moduleScript.Name),
			"server"
		) == nil) then
			continue
		end

		local v = SkillsModule
		local name = moduleScript.Name
		local module = require(moduleScript)
		v[name] = module
	end
end)
local manage_cd = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("manage_cd"))
local Skill_Info = require(ReplicatedStorage.CAM.Global.PlayerProfile.Skill_Info)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local CombatBalance = require(ReplicatedStorage.CAM.Global.CombatBalance)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local now = 0
local now2 = 0

function SkillsModule.Can_Skill(player, p)
	local SHC

	if not (player == nil or player.Character == nil) then
		SHC = player.Character:FindFirstChild("SHC") or player.Character:FindFirstChild("SHCS")
	end

	local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(player.Name)
	local skillsdisabled = child:FindFirstChild("skillsdisabled")

	if skillsdisabled ~= nil then
		if find(skillsdisabled.Value, "all") == nil then
			if find(skillsdisabled.Value, p) ~= nil then
				return
			end
		elseif find(skillsdisabled.Value, "except" .. p) == nil then
			return
		end
	end

	local filter_cd_name = manage_cd.filter_cd_name(player, p)
	local v = Skill_Info[p]
	local child2

	if player == nil or player.Character == nil or SHC == nil then
		child2 = false
	else
		child2 = SHC:FindFirstChild(filter_cd_name)
	end

	local v2

	if child2 == nil then
		v2 = true
	else
		local v3 = isServer ~= true and 0 or SkillsModule.serverMarginOfError
		local v4 = clock() - child2:GetAttribute("Started") + v3

		if v3 > 0 then
			v4 = math.round(v4)
		end

		local value = child2.Value
		v2 = typeof(value) == "number" and value <= v4 or child2
	end

	local _, v3 = Stats.GetRequirements(player, p)
	local v4 = v3 and true or false
	local sourceCheck, v5 = Stats.SourceCheck(player, p)
	local attribute = player:GetAttribute(Stats.LOADOUT_CHANGED_AT)
	local v6

	if typeof(attribute) == "number" then
		v6 = os.clock() - attribute < Stats.LOADOUT_SETTLE
	else
		v6 = false
	end

	if not sourceCheck and v5 ~= nil and AntiCheat ~= nil and not v6 then
		AntiCheat.Report(player, "Loadout", v5)
	end

	local v7

	if v == nil or v.RequiresAura == nil then
		v7 = true
	else
		v7 = child:FindFirstChild(v.RequiresAura) ~= nil

		if not v7 and not isServer and clock() - now2 > 1.5 then
			now2 = clock()
			game.ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", {
				Text = v.RequiresAura .. " is not active",
				Type = "Warn"
			})
		end
	end

	local v8

	if v == nil or v.Stamina == nil then
		v8 = true
	else
		local v9 = PlayerStatResolver.GetStat(player, "Stamina Cost Factor") or 0

		if v.Category ~= nil then
			v9 += PlayerStatResolver.GetStat(player, v.Category .. " Stamina Cost Factor") or 0
		end

		local v10 = math.max(0, v.Stamina * (1 + v9) * CombatBalance.CastKnob(player, p, "Stamina"))
		v8 = v10 <= child.Stamina.Value

		if v8 then
			if isServer and v7 and sourceCheck and v2 == true and v4 then
				child.Stamina.Value -= v10
			end
		elseif not isServer then
			game.ReplicatedStorage.Communication.CnC.NotEnoughStamina:Fire(v.Stamina / child.Stamina.MaxValue)

			if clock() - now > 1.5 then
				now = clock()
				game.ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", {
					Text = "Your stamina is too low",
					Type = "Warn"
				})
			end
		end
	end

	local v9

	if v == nil or v.RequiresModeBar ~= true then
		v9 = true
	else
		local modeBar = child:FindFirstChild("ModeBar")

		if modeBar == nil then
			v9 = false
		else
			v9 = modeBar.Value >= modeBar.MaxValue
		end

		if v9 and isServer and v2 == true and v4 and v8 and v7 and sourceCheck then
			modeBar.Value = 0
		end
	end

	return v2 == true and v4 and v8 and v9 and v7 and sourceCheck
end

return SkillsModule