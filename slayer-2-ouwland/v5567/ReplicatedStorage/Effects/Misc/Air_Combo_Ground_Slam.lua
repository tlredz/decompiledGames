local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.RespectCanCollide = true
raycastParams.FilterType = Enum.RaycastFilterType.Include
local CraterExtension = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Craters"):WaitForChild("CraterExtension"))
local currentCamera = workspace.CurrentCamera
game:GetService("TweenService")
TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
return function(cFrame, flag: boolean?)
	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude <= 200 then
		local v = cFrame * CFrame.new(0, 5, 0).Position
		local v2 = cFrame.upVector * -15
		workspace:Raycast(v, v2, raycastParams)
		local folder = Instance.new("Folder", workspace.Debree)
		folder.Name = "eff_folder"
		DebrisModule:AddItem(folder, 4)
		local v3 = cFrame.Position + cFrame.upVector * 5
		local v4 = cFrame.upVector * -25
		local raycastResult = workspace:Raycast(v3, v4, raycastParams)

		if raycastResult and raycastResult.Instance then
			cFrame = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			local clone = script.FF:Clone()

			if not flag == true then
				clone.Sound:Play()
			end

			clone.Parent = folder
			clone.CFrame = cFrame
			vfxUtility.EmitAll(clone, {
				Color = raycastResult.Instance.Color
			})
			vfxUtility.ShootRocks(raycastResult, cFrame, folder, 7)
		end

		local clone = script.asdpp:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		vfxUtility.EmitAll(clone)

		if not flag == true then
			clone.Sound:Play()
		end

		if not flag == true then
			Cam_Shaker(cFrame.Position, "medium_shake_preset")
		end

		CraterExtension.Cascade(cFrame, 5.5, createVector(1.5, 2, 2), nil, 3, false, 2)
	end
end