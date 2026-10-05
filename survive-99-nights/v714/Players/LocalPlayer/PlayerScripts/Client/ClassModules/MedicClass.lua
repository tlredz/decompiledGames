local MedicClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false

function RevivePromptAdded(p)
	p.HoldDuration = 0.6
end

function EnableClass()
	if flag then
		return
	end

	flag = true
	Client.Utility.ForAllTagged("RevivePrompt", RevivePromptAdded)
end

function MedicClass.Init()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if localPlayer:GetAttribute("Class") == "Medic" then
			EnableClass()
		elseif Client.Utility.HasTalent(localPlayer, "FastRevive") then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	localPlayer:GetAttributeChangedSignal("Talent"):Connect(check)
	check() -- equivalent call inferred; original call site unknown
end

return MedicClass