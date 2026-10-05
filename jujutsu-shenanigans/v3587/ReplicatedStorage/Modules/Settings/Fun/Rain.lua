local createVector = vector.create
local Rain = {
	Btn = 1,
	SortOrder = 4,
	Desc = "rain everywhere"
}
local clone = nil
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local RunService = game:GetService("RunService")
game:GetService("TweenService")

function Rain.Callback(p)
	if p == true then
		clone = game.ReplicatedStorage.Utils.Misc.Rain:Clone()
		clone.Parent = workspace.Effects
		clone.RainSFX.SoundGroup = game.SoundService.Effect
		clone.RainSFX:Play()
		local steppedConnection = nil
		steppedConnection = RunService.Stepped:Connect(function()
			if not clone then
				steppedConnection:Disconnect()
				return
			end

			local cFrame = workspace.CurrentCamera.CFrame
			clone.Position = cFrame.Position + createVector(0, 10, 0)
			local raycastResult = workspace:Raycast(cFrame.Position, createVector(0, 40, 0), raycastParams)
			workspace:Raycast(cFrame.Position - cFrame.LookVector * 5, createVector(0, 40, 0), raycastParams)
			workspace:Raycast(cFrame.Position + cFrame.LookVector * 5, createVector(0, 40, 0), raycastParams)

			if raycastResult then
				clone.Rain.Enabled = false
				clone.RainSFX.Muffle.Enabled = true
			else
				clone.Rain.Enabled = true
				clone.RainSFX.Muffle.Enabled = false
				local raycastResult2 = workspace:Raycast(
					clone.Position + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50)),
					createVector(0, -50, 0),
					raycastParams
				)

				if raycastResult2 then
					clone.Attachment.WorldCFrame = CFrame.new(
						raycastResult2.Position,
						raycastResult2.Position + raycastResult2.Normal
					) * CFrame.Angles(0, 1.5707963267948966, 0)
					clone.Attachment.Splash:Emit(1)
				end
			end
		end)
	elseif clone then
		clone:Destroy()
		clone = nil
	end
end

return Rain