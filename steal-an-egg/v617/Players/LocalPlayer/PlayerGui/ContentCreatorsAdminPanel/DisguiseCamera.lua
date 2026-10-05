local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local PlayerModule = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule"))
		local cameras = PlayerModule:GetCameras()
		local v = nil
		local zero = Vector2.zero
		local v2 = 0
		local zoom = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restore()
			if not v then
				return
			end

			if v.Humanoid.Parent then
				v.Humanoid.CameraOffset = v.Offset
			end

			localPlayer.CameraMaxZoomDistance = v.MaxZoom
			zoom = v.Zoom
			v = nil
		end

		RunService:BindToRenderStep("CreatorDisguiseCamera", Enum.RenderPriority.Camera.Value - 1, function()
			local currentCamera = workspace.CurrentCamera
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local creatorGuardDisguise = character and character:FindFirstChild("CreatorGuardDisguise")

			if not humanoid or humanoid.Health <= 0 or not (creatorGuardDisguise and creatorGuardDisguise:IsA("Model")) then
				creatorGuardDisguise = nil
			end

			if v and (v.Model ~= creatorGuardDisguise or v.Humanoid ~= humanoid) and v then
				if v.Humanoid.Parent then
					v.Humanoid.CameraOffset = v.Offset
				end

				localPlayer.CameraMaxZoomDistance = v.MaxZoom
				zoom = v.Zoom
				v = nil
			end

			if not currentCamera or currentCamera.CameraType ~= Enum.CameraType.Custom or currentCamera.CameraSubject ~= humanoid then
				return
			end

			if zoom then
				cameras:SetCameraToSubjectDistance(zoom)
				zoom = nil
			end

			if not (creatorGuardDisguise and humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return
			end

			local creatorCameraFocus = creatorGuardDisguise:GetAttribute("CreatorCameraFocus")
			local creatorCameraSize = creatorGuardDisguise:GetAttribute("CreatorCameraSize")

			if typeof(creatorCameraFocus) ~= "Vector3" or typeof(creatorCameraSize) ~= "Vector3" then
				return
			end

			if not v then
				local cameraSubjectPosition = cameras:GetCameraSubjectPosition()

				if not cameraSubjectPosition then
					return
				end

				v = {
					Model = creatorGuardDisguise,
					Humanoid = humanoid,
					Offset = humanoid.CameraOffset,
					Zoom = cameras:GetCameraToSubjectDistance() or (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude,
					MaxZoom = localPlayer.CameraMaxZoomDistance
				}
				humanoid.CameraOffset += creatorCameraFocus - humanoidRootPart.CFrame:PointToObjectSpace(cameraSubjectPosition)
				zero = Vector2.zero
			end

			if currentCamera.ViewportSize.X <= 0 or currentCamera.ViewportSize.Y <= 0 then
				return
			end

			if zero ~= currentCamera.ViewportSize or v2 ~= currentCamera.FieldOfView then
				local viewportSize = currentCamera.ViewportSize
				local fieldOfView = currentCamera.FieldOfView
				zero = viewportSize
				v2 = fieldOfView
				local v3 = zero.X / math.max(zero.Y, 1)
				local v4 = math.atan(math.tan(math.rad(v2) / 2) * math.min(v3, 1))
				local v5 = math.max(6, creatorCameraSize.Magnitude * 0.55 / math.sin(v4))
				localPlayer.CameraMaxZoomDistance = math.max(v.MaxZoom, v5 * 1.5)
				cameras:SetCameraToSubjectDistance((math.max(v.Zoom, v5)))
			end
		end)
		return function()
			RunService:UnbindFromRenderStep("CreatorDisguiseCamera")
			restore() -- equivalent call inferred; original call site unknown

			if zoom then
				cameras:SetCameraToSubjectDistance(zoom)
			end
		end
	end
}