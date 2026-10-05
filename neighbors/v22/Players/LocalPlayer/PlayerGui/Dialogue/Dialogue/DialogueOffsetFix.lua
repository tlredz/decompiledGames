local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local BUTTONS = localPlayer.PlayerGui:WaitForChild("MainMenu"):WaitForChild("ConnectedFrame"):WaitForChild("BUTTONS")

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	parent.AnchorPoint = Vector2.new(0.5, 0)
	parent.Position = UDim2.new(0.5, 0, 0, BUTTONS.AbsolutePosition.Y - 75)
end

BUTTONS:GetPropertyChangedSignal("AbsolutePosition"):connect(update)
update() -- equivalent call inferred; original call site unknown