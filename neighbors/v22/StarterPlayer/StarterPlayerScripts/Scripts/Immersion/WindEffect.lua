local localPlayer = game.Players.LocalPlayer
local WindLines = require(script.WindLines)
WindLines:Init({
	Direction = vector.create(0.6, 0, 0.3),
	Speed = 20,
	Lifetime = 1.5,
	SpawnRate = 2
})

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	if workspace:GetAttribute("Night") and localPlayer:GetAttribute("State") ~= 3 then
		WindLines.Enabled = true
	else
		WindLines.Enabled = false
	end
end

workspace:GetAttributeChangedSignal("Night"):connect(update)
localPlayer:GetAttributeChangedSignal("State"):connect(update)
update() -- equivalent call inferred; original call site unknown