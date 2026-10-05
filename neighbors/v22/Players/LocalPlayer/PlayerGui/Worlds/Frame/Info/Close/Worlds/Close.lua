local menu = script.Parent.Parent.Parent:FindFirstChild("Menu")

if not menu then
	return
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	script.Parent.Visible = menu.Visible
end

update() -- equivalent call inferred; original call site unknown
menu:GetPropertyChangedSignal("Visible"):Connect(update)