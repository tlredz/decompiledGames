local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Situations = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Situations)
local localPlayer = Players.LocalPlayer

for _, v in { "Situation", "SecondarySituation" } do
	local v2 = nil
	-- equivalent calls inferred from this helper; original call sites unknown
	local v3 = v

	local function upd()
		local attribute = localPlayer:GetAttribute(v3)

		if attribute == v2 then
			return
		end

		local v4 = v2
		v2 = attribute
		Situations.Swap(localPlayer, v4, attribute)
	end

	localPlayer:GetAttributeChangedSignal(v):Connect(upd)
	upd() -- equivalent call inferred; original call site unknown
end