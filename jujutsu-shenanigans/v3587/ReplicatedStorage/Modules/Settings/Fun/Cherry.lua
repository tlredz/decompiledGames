local createVector = vector.create
local clone = nil
local RunService = game:GetService("RunService")
return {
	Btn = 1,
	SortOrder = 5,
	Desc = "pink everywhere",
	Callback = function(p)
		if p == true then
			clone = game.ReplicatedStorage.Utils.Misc.Rain:Clone()
			clone.Rain.Enabled = false
			clone.Blossom.Enabled = true
			clone.Parent = workspace.Effects
			local blossomCC = clone.Blossom.BlossomCC
			blossomCC.Parent = game.Lighting
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if clone then
					clone.Position = workspace.CurrentCamera.CFrame.Position + createVector(0, 30, 0)
					return
				end

				steppedConnection:Disconnect()
				blossomCC:Destroy()
			end)
		else
			if not clone then
				return
			end

			clone:Destroy()
			clone = nil
		end
	end
}