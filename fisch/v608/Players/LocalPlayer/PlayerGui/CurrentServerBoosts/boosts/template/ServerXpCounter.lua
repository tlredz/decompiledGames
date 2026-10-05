local xp_Server = game.ReplicatedStorage:WaitForChild("world"):WaitForChild("xp_Server")

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckVisibility()
	if xp_Server.Value > 1 then
		script.Parent.length.Text = "x" .. (xp_Server.Value > 1 and xp_Server.Value or 0)
		script.Parent.Visible = true
	else
		script.Parent.Visible = false
	end
end

if xp_Server.Value > 1 then
	script.Parent.length.Text = "x" .. (not (xp_Server.Value > 1) and 0 or xp_Server.Value or 0)
	script.Parent.Visible = true
else
	script.Parent.Visible = false
end

xp_Server.Changed:Connect(function()
	CheckVisibility() -- equivalent call inferred; original call site unknown
end)