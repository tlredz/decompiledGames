local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(CAM.Global.Utility)
local PlayerProfile = require(CAM.Global.PlayerProfile)
local manage_cd = require(CAM.Global.Subsets.Gameplay.manage_cd)
local Config = require(script.Parent.Config)
local name = script.Parent.Name

local function iconTag(p: string)
	local v = PlayerProfile.skill_info[p]
	local icon = v ~= nil and v.Icon or nil
	local v2 = typeof(icon) == "string" and string.match(icon, "%d+") or nil

	if v2 == nil then
		return ""
	end

	return (`[#]<img={v2}> `)
end

local function resettableStamps(p, instance)
	local SHCS = instance:FindFirstChild("SHCS")

	if SHCS == nil then
		return {}
	end

	local v = {
		[manage_cd.filter_cd_name(p, name)] = true
	}

	for _, v2 in Config.IGNORED do
		v[v2] = true
	end

	local numberValues = {}

	for _, numberValue in SHCS:GetChildren() do
		if not numberValue:IsA("NumberValue") or v[numberValue.Name] then
			continue
		end

		table.insert(numberValues, numberValue)
	end

	return numberValues
end

return {
	Activate = function(p, p2, _)
		if p == nil or p2 == nil then
			return
		end

		local v = resettableStamps(p, p2)
		local v2 = {}

		for _ = 1, math.min(Config.RESET_COUNT, #v) do
			local v3 = table.remove(v, math.random(1, #v))
			local name2 = v3.Name
			v3:Destroy()
			EffectsEvent.ToClient(p, "reset_skill_cooldown", name2, true)
			local v4 = PlayerProfile.skill_info[name2]
			local icon

			if v4 ~= nil then
				icon = v4.Icon or nil
			end

			local v5

			if typeof(icon) == "string" then
				v5 = string.match(icon, "%d+") or nil
			end

			table.insert(v2, (v5 == nil and "" or `[#]<img={v5}> `) .. Utility.NameTag(name2))
		end

		if #v2 > 0 then
			SignalEvent.ToClient(p, "Notify", {
				Text = `Cooldown reset: {table.concat(v2, ", ")}.`
			})
		else
			SignalEvent.ToClient(p, "Notify", {
				Text = "No cooldowns to reset.",
				Type = "Warn"
			})
		end
	end
}