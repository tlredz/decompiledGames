local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local v = {
	Loading = true,
	InProgress = true,
	RoundEnd = true
}
local RoundDeferral = {}
local localPlayer = Players.LocalPlayer
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function roundState()
	return localPlayer:GetAttribute("MurderMysteryRoundState") or "Waiting"
end

local function recompute(flag: boolean?)
	local v3 = roundState() -- equivalent call inferred; original call site unknown

	if flag == nil then
		if localPlayer:GetAttribute("MurderMysteryRole") == nil then
			flag = false
		else
			flag = v3 ~= "Waiting"
		end
	end

	v2 = flag
end

function RoundDeferral.HoldsBack(flag: boolean?)
	return flag == true and v2 and v[roundState()] == true
end

function RoundDeferral.TakeAdmissible(list)
	for k, v3 in list do
		if not RoundDeferral.HoldsBack(v3.config.DelayInRound) then
			return table.remove(list, k)
		end
	end

	return nil
end

local v3 = roundState() -- equivalent call inferred; original call site unknown
v2 = localPlayer:GetAttribute("MurderMysteryRole") ~= nil and v3 ~= "Waiting"
localPlayer:GetAttributeChangedSignal("MurderMysteryRoundState"):Connect(function()
	local v5

	if roundState() == "Waiting" then
		v5 = false
	end

	local v6 = roundState() -- equivalent call inferred; original call site unknown

	if v5 == nil then
		if localPlayer:GetAttribute("MurderMysteryRole") == nil then
			v5 = false
		else
			v5 = v6 ~= "Waiting"
		end
	end

	v2 = v5
end)
localPlayer:GetAttributeChangedSignal("MurderMysteryRole"):Connect(function()
	local v5 = roundState() -- equivalent call inferred; original call site unknown
	v2 = localPlayer:GetAttribute("MurderMysteryRole") ~= nil and v5 ~= "Waiting"
end)
Remotes.Whodunnit.RoundShifted.OnClientEvent:Connect(function(p)
	if typeof(p) == "table" then
		local isParticipant = p.isParticipant

		if typeof(isParticipant) ~= "boolean" then
			isParticipant = nil
		end

		local v5 = roundState() -- equivalent call inferred; original call site unknown

		if isParticipant == nil then
			if localPlayer:GetAttribute("MurderMysteryRole") == nil then
				isParticipant = false
			else
				isParticipant = v5 ~= "Waiting"
			end
		end

		v2 = isParticipant
	end
end)
return RoundDeferral