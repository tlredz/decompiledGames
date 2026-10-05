local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local AbilityEffectRegistry = {}
local RunService = game:GetService("RunService")

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local Global = require(game.ReplicatedStorage.Global)

	function Global.isPlayerBusyWithAbilities(player, p)
		if player.Character and player.Character.Busy.Value then
			warn({ "busy - generic" })
			player.Character.Humanoid.Sit = false
			player.Character.Humanoid.Jump = true
			return true
		else
			for k, v in pairs(AbilityEffectRegistry) do
				local busy = v.Busy

				if not (busy and busy(player, p)) then
					continue
				end

				warn((`busy with {k}`))
				return true
			end
		end
	end
end

for _, moduleScript in pairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	AbilityEffectRegistry[name] = module
end

return AbilityEffectRegistry