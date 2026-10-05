local world = game.ReplicatedStorage:WaitForChild("world")
local luck_ServerSide = world:WaitForChild("luck_ServerSide")
local luck_Server = world:WaitForChild("luck_Server")

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckVisibility()
	local value = luck_ServerSide.Value

	if value > 0 or luck_Server.Value > 1 then
		script.Parent.length.Text = "x" .. (luck_Server.Value > 1 and luck_Server.Value or 0) + value
		script.Parent.Visible = true
	else
		script.Parent.Visible = false
	end
end

local value = luck_ServerSide.Value

if value > 0 or luck_Server.Value > 1 then
	script.Parent.length.Text = "x" .. (not (luck_Server.Value > 1) and 0 or luck_Server.Value or 0) + value
	script.Parent.Visible = true
else
	script.Parent.Visible = false
end

luck_ServerSide.Changed:Connect(function()
	CheckVisibility() -- equivalent call inferred; original call site unknown
end)
luck_Server.Changed:Connect(function()
	CheckVisibility() -- equivalent call inferred; original call site unknown
end)