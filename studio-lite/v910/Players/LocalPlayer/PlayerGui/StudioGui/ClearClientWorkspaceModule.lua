local ClearClientWorkspaceModule = {}
ClearClientWorkspaceModule.__index = ClearClientWorkspaceModule

function ClearClientWorkspaceModule.ClearWorkspace(_)
	for _, child in pairs(workspace:GetChildren()) do
		if not (child.ClassName ~= "Camera" and child.ClassName ~= "Terrain" and child ~= game.Players.LocalPlayer.Character and child.Name:sub(
			1,
			24
		) ~= "ExplorerSelectionChanged") then
			continue
		end

		if child.Name == "FlyCameraFocus" then
			continue
		end

		child:Destroy()
	end

	for _, child in pairs(game.ReplicatedStorage:GetChildren()) do
		if child.Name ~= "FlyCameraFocus" and child.Name ~= "DefaultChatSystemChatEvents" and child.Name ~= "StudioLiteFolder" and child.Name ~= "ClientAction" then
			child:Destroy()
		end
	end

	game.Lighting:ClearAllChildren()
	game.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
	game.Lighting.Brightness = 3
	game.Lighting.ColorShift_Top = Color3.new(0, 0, 0)
	game.Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
	game.Lighting.EnvironmentDiffuseScale = 1
	game.Lighting.EnvironmentSpecularScale = 1
	game.Lighting.GlobalShadows = true
	game.Lighting.OutdoorAmbient = game.Lighting.Ambient
	game.Lighting.ShadowSoftness = 0.2
	game.Lighting.Archivable = true
	game.Lighting.ClockTime = 14.5
	game.Lighting.TimeOfDay = "14:30:00"
	game.Lighting.ExposureCompensation = 0
	game.Lighting.FogColor = Color3.fromRGB(192, 192, 192)
	game.Lighting.FogEnd = 100000
	game.Lighting.FogStart = 0
	game.Lighting:SetAttribute("SL_Technology", "Enum.Technology.Future")
	game.Players.LocalPlayer.PlayerGui.StudioGui.SLWorkspaceFrame:ClearAllChildren()

	for _, child in pairs(_G.sss:GetChildren()) do
		child:Destroy()
	end

	for _, child in pairs(_G.ss:GetChildren()) do
		child:Destroy()
	end

	for _, child in pairs(game.StarterGui:GetChildren()) do
		if child.Name ~= "StudioGui" then
			child:Destroy()
		end
	end

	for _, child in pairs(game.StarterPack:GetChildren()) do
		child:Destroy()
	end

	game.StarterPlayer.HealthDisplayDistance = 100
	game.StarterPlayer.NameDisplayDistance = 100
	game.StarterPlayer.CameraMode = Enum.CameraMode.Classic
	game.StarterPlayer.CameraMinZoomDistance = 0.5
	game.StarterPlayer.CameraMaxZoomDistance = 128
	game.StarterPlayer.CharacterMaxSlopeAngle = 89
	game.StarterPlayer.CharacterWalkSpeed = 16
	game.StarterPlayer.LoadCharacterAppearance = true
	game.StarterPlayer.CharacterJumpHeight = 7.2
	game.StarterPlayer.CharacterUseJumpPower = false
	game.StarterPlayer.AutoJumpEnabled = true

	for _, child in pairs(game.StarterPlayer:GetChildren()) do
		if child.Name ~= "StarterCharacterScripts" and child.Name ~= "StarterPlayerScripts" then
			child:Destroy()
		end
	end

	for _, child in pairs(game.StarterPlayer.StarterCharacterScripts:GetChildren()) do
		if child.Name ~= "ClientActionEventLocal" then
			child:Destroy()
		end
	end

	for _, child in pairs(game.StarterPlayer.StarterPlayerScripts:GetChildren()) do
		if not (child.Name ~= "FlyCameraLocal" and child.Name ~= "BubbleChat" and child.Name ~= "ChatScript" and child.Name ~= "TouchGui") then
			continue
		end

		if not (child.Name ~= "PlayerScriptsLoader" and child.Name ~= "RbxCharacterSounds" and child.Name ~= "PlayerModule") then
			continue
		end

		child:Destroy()
	end

	game.Teams:ClearAllChildren()
end

return ClearClientWorkspaceModule