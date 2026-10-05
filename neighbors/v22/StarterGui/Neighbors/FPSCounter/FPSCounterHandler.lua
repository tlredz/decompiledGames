local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local v = 1
local total = 0

if game.GameId == 12022882036 then
	RunService.RenderStepped:Connect(function(dt)
		total += dt
		v += 1

		if v == 30 then
			local v2 = 1 // (total / 30)
			total = 0
			v = 0
			script.Parent.Text = v2 .. " FPS"
		end
	end)
else
	script.Parent:Destroy()
end