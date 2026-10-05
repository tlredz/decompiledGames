local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local flag = false
return {
	bind = function(p)
		if flag then
			return
		end

		flag = true
		local localPlayer = Players.LocalPlayer
		local character = localPlayer.Character
		local cFrame = nil
		localPlayer.CharacterAdded:Connect(function(character2)
			character = character2
			cFrame = nil
		end)
		localPlayer.CharacterRemoving:Connect(function(character2)
			if character == character2 then
				character = nil
			end

			cFrame = nil
		end)
		RunService:BindToRenderStep("CameraRespawnRecovery", Enum.RenderPriority.Camera.Value - 1, function()
			local v2 = character
			local currentCamera = workspace.CurrentCamera

			if not v2 or v2 ~= localPlayer.Character or not (currentCamera and localPlayer.Team) then
				return
			end

			if p.hasActiveControllers(currentCamera) then
				return
			end

			local humanoid = v2:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.RootPart and humanoid.Health > 0 then
				character = nil
				cFrame = nil
				currentCamera.CameraSubject = humanoid
				currentCamera.CameraType = Enum.CameraType.Custom
			else
				if not cFrame then
					local nextSpawn = localPlayer:FindFirstChild("NextSpawn")
					local v3

					if nextSpawn and nextSpawn:IsA("CFrameValue") and nextSpawn.Value ~= CFrame.identity then
						v3 = nextSpawn.Value
					else
						v3 = currentCamera.CFrame
					end

					cFrame = v3
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CFrame = cFrame
			end
		end)
	end
}