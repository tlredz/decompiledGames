local localPlayer = game.Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	script.Parent.Visible = localPlayer:GetAttribute("PartyId") == localPlayer.UserId
end

update() -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("PartyId"):Connect(update)