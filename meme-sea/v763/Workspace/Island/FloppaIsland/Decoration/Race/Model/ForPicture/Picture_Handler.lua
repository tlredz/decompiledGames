local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local decal = parent.Decal
local decal_TH = parent.Decal_TH

-- equivalent calls inferred from this helper; original call sites unknown
local function Language_Changed()
	if localPlayer:GetAttribute("TH") then
		decal.Transparency = 1
		decal_TH.Transparency = 0
	else
		decal_TH.Transparency = 1
		decal.Transparency = 0
	end
end

Language_Changed() -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("TH"):Connect(Language_Changed)