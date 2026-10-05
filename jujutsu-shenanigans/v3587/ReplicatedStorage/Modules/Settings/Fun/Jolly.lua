local createVector = vector.create
local clone = nil
local position = nil
local RunService = game:GetService("RunService")
return {
	Btn = 1,
	SortOrder = 6,
	Desc = "snow everywhere",
	Callback = function(p)
		if p == true and _G.LocalSettings.Darkness == true then
			_G.LocalSettings.Darkness = false
			_G.SettingUpdate.Darkness:Fire()
		end

		if p == true then
			clone = game.ReplicatedStorage.Utils.Misc.Rain:Clone()
			clone.Rain.Enabled = false
			clone.Snow.Enabled = true
			clone.Parent = workspace.Effects
			game.Lighting.FogEnd = 500
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if not clone then
					steppedConnection:Disconnect()
					return
				end

				local v = workspace.CurrentCamera.CFrame.Position - (position or workspace.CurrentCamera.CFrame.Position)
				position = workspace.CurrentCamera.CFrame.Position
				clone.Position = workspace.CurrentCamera.CFrame.Position + v / dt * 2 + createVector(0, 30, 0)
			end)
		else
			if not clone then
				return
			end

			clone:Destroy()
			clone = nil
			position = nil
			local config = game.Lighting.Config
			game.Lighting.FogEnd = config:GetAttribute("FogEnd")
		end
	end
}