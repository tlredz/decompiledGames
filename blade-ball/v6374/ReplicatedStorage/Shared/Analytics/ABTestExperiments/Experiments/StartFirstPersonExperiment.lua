local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.Analytics.ABTestExperiments.ABTestTypes)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
return {
	RemoteConfig = "Start1stPerson",
	Disabled = true,
	DefaultState = false,
	States = {
		[true] = {
			Client = function(player, _)
				if (v.Client:WaitReplion("Data"):Get({ "TotalStats", "Matches" }) or 0) >= 1 then
					return
				end

				local maid = v2.new()

				local function charAdded(instance)
					maid:Add(instance.AncestryChanged:Connect(function()
						if instance.Parent ~= workspace.Alive then
							return
						end

						local cameraMaxZoomDistance = player.CameraMaxZoomDistance
						player.CameraMaxZoomDistance = player.CameraMinZoomDistance
						task.wait()
						player.CameraMaxZoomDistance = cameraMaxZoomDistance
						maid:Destroy()
					end))
				end

				maid:Add(player.CharacterAdded:Connect(charAdded))

				if player.Character then
					task.spawn(charAdded, player.Character)
				end
			end
		}
	}
}