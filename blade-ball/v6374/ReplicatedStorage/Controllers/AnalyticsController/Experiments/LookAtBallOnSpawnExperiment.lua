local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Types.Analytics)
local v = require3(ReplicatedStorage2.Packages.Trove)
local localPlayer = Players.LocalPlayer
return {
	RemoteConfig = "LookAtBallOnSpawn",
	DefaultValue = false,
	Disabled = false,
	TestConfigValues = {
		[true] = 100
	},
	Configs = {
		[true] = function()
			local maid = v.new()

			local function onCharAdded(instance)
				maid:Clean()
				maid:Add(instance.AncestryChanged:Connect(function()
					if instance.Parent == workspace.Alive then
						local v2 = workspace.Map:GetChildren()[1]

						if not v2 then
							return
						end

						local BALLSPAWN = v2:FindFirstChild("BALLSPAWN")

						if not BALLSPAWN then
							return
						end

						local v3 = BALLSPAWN:GetPivot().Position - createVector(0, 2, 0)
						local currentCamera = workspace.CurrentCamera
						currentCamera.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, v3)
						task.wait(0.03333333333333333)
						currentCamera.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, v3)
					end
				end))
			end

			localPlayer.CharacterAdded:Connect(onCharAdded)

			if localPlayer.Character then
				task.defer(onCharAdded, localPlayer.Character)
			end
		end
	}
}