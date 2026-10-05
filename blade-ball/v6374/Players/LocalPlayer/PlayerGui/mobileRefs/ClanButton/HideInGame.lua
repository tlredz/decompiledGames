if table.find({ "TalonMidnight", "DevSpec", "Ziruem" }, game.Players.LocalPlayer.Name) then
	return
end

local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	script.Parent.Visible = false
end