local CloneLocalWorkspaceToReplicatedStorageModule = {}
CloneLocalWorkspaceToReplicatedStorageModule.__index = CloneLocalWorkspaceToReplicatedStorageModule

function CloneLocalWorkspaceToReplicatedStorageModule.CloneLocal(_, name)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")

	for _, child in pairs(studioLiteFolder:GetChildren()) do
		if not (child.ClassName == "Folder" and (child:FindFirstChild("Workspace") or #child:GetChildren() == 0)) then
			continue
		end

		child:Destroy()
	end

	local folder = Instance.new("Folder", studioLiteFolder)
	folder.Name = name
	local folder2 = Instance.new("Folder", folder)
	folder2.Name = "Lighting"
	folder2:SetAttribute("Ambient", game.Lighting.Ambient)
	folder2:SetAttribute("Brightness", game.Lighting.Brightness)
	folder2:SetAttribute("ColorShift_Top", game.Lighting.ColorShift_Top)
	folder2:SetAttribute("ColorShift_Bottom", game.Lighting.ColorShift_Bottom)
	folder2:SetAttribute("EnvironmentDiffuseScale", game.Lighting.EnvironmentDiffuseScale)
	folder2:SetAttribute("EnvironmentSpecularScale", game.Lighting.EnvironmentSpecularScale)
	folder2:SetAttribute("GlobalShadows", game.Lighting.GlobalShadows)
	folder2:SetAttribute("OutdoorAmbient", game.Lighting.OutdoorAmbient)
	folder2:SetAttribute("ShadowSoftness", game.Lighting.ShadowSoftness)
	folder2:SetAttribute("Archivable", game.Lighting.Archivable)
	folder2:SetAttribute("ClockTime", game.Lighting.ClockTime)
	folder2:SetAttribute("TimeOfDay", game.Lighting.TimeOfDay)
	folder2:SetAttribute("ExposureCompensation", game.Lighting.ExposureCompensation)
	folder2:SetAttribute("FogColor", game.Lighting.FogColor)
	folder2:SetAttribute("FogEnd", game.Lighting.FogEnd)
	folder2:SetAttribute("FogStart", game.Lighting.FogStart)
	folder2:SetAttribute("SL_Technology", game.Lighting:GetAttribute("SL_Technology"))

	for _, child in pairs(game.Lighting:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = folder.Lighting
	end

	for _, child in pairs(_G.sss:GetChildren()) do
		if not folder:FindFirstChild("ServerScriptService") then
			local folder_2 = Instance.new("Folder", folder)
			folder_2.Name = "ServerScriptService"
		end

		local clone_2 = child:Clone()
		clone_2.Parent = folder.ServerScriptService
	end

	for _, child in pairs(_G.ss:GetChildren()) do
		if not folder:FindFirstChild("ServerStorage") then
			local folder_3 = Instance.new("Folder", folder)
			folder_3.Name = "ServerStorage"
		end

		local clone_3 = child:Clone()
		clone_3.Parent = folder.ServerStorage
	end

	for _, child in pairs(game.StarterGui:GetChildren()) do
		if child.Name == "StudioGui" then
			continue
		end

		if not folder:FindFirstChild("StarterGui") then
			local folder_4 = Instance.new("Folder", folder)
			folder_4.Name = "StarterGui"
		end

		local clone_4 = child:Clone()
		clone_4.Parent = folder.StarterGui
	end

	for _, child in pairs(game.StarterPack:GetChildren()) do
		if not folder:FindFirstChild("StarterPack") then
			local folder_5 = Instance.new("Folder", folder)
			folder_5.Name = "StarterPack"
		end

		local clone_5 = child:Clone()
		clone_5.Parent = folder.StarterPack
	end

	local folder3 = Instance.new("Folder", folder)
	folder3.Name = "StarterPlayer"
	folder3:SetAttribute("HealthDisplayDistance", game.StarterPlayer.HealthDisplayDistance)
	folder3:SetAttribute("NameDisplayDistance", game.StarterPlayer.NameDisplayDistance)
	folder3:SetAttribute("CameraMode", game.StarterPlayer.CameraMode)
	folder3:SetAttribute("CameraMinZoomDistance", game.StarterPlayer.CameraMinZoomDistance)
	folder3:SetAttribute("CameraMaxZoomDistance", game.StarterPlayer.CameraMaxZoomDistance)
	folder3:SetAttribute("CharacterMaxSlopeAngle", game.StarterPlayer.CharacterMaxSlopeAngle)
	folder3:SetAttribute("CharacterWalkSpeed", game.StarterPlayer.CharacterWalkSpeed)
	folder3:SetAttribute("LoadCharacterAppearance", game.StarterPlayer.LoadCharacterAppearance)
	folder3:SetAttribute("CharacterJumpHeight", game.StarterPlayer.CharacterJumpHeight)
	folder3:SetAttribute("CharacterUseJumpPower", game.StarterPlayer.CharacterUseJumpPower)
	folder3:SetAttribute("AutoJumpEnabled", game.StarterPlayer.AutoJumpEnabled)

	for _, child in pairs(game.StarterPlayer:GetChildren()) do
		if not (child.ClassName ~= "StarterCharacterScripts" and child.ClassName ~= "StarterPlayerScripts") then
			continue
		end

		local clone_6 = child:Clone()
		clone_6.Parent = folder.StarterPlayer
	end

	for _, child in pairs(game.StarterPlayer.StarterCharacterScripts:GetChildren()) do
		if child.Name == "ClientActionEventLocal" then
			continue
		end

		if not folder:FindFirstChild("StarterPlayer") then
			local folder_6 = Instance.new("Folder", folder)
			folder_6.Name = "StarterPlayer"
		end

		if not folder.StarterPlayer:FindFirstChild("StarterCharacterScripts") then
			local folder_7 = Instance.new("Folder", folder.StarterPlayer)
			folder_7.Name = "StarterCharacterScripts"
		end

		local clone_7 = child:Clone()
		clone_7.Parent = folder.StarterPlayer.StarterCharacterScripts
	end

	for _, child in pairs(game.StarterPlayer.StarterPlayerScripts:GetChildren()) do
		if not (child.Name ~= "FlyCameraLocal" and child.Name ~= "BubbleChat" and child.Name ~= "ChatScript" and child.Name ~= "TouchGui") then
			continue
		end

		if not (child.Name ~= "PlayerScriptsLoader" and child.Name ~= "RbxCharacterSounds" and child.Name ~= "PlayerModule") then
			continue
		end

		if not folder:FindFirstChild("StarterPlayer") then
			local folder_8 = Instance.new("Folder", folder)
			folder_8.Name = "StarterPlayer"
		end

		if not folder.StarterPlayer:FindFirstChild("StarterPlayerScripts") then
			local folder_9 = Instance.new("Folder", folder.StarterPlayer)
			folder_9.Name = "StarterPlayerScripts"
		end

		local clone_8 = child:Clone()
		clone_8.Parent = folder.StarterPlayer.StarterPlayerScripts
	end

	local folder_10 = Instance.new("Folder", folder)
	folder_10.Name = "Teams"

	for _, child in pairs(game.Teams:GetChildren()) do
		local clone_9 = child:Clone()
		clone_9.Parent = folder.Teams
	end

	local folder4 = Instance.new("Folder")
	folder4.Name = "Workspace"

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

		child.Parent = folder4
	end

	local clone_10 = folder4:Clone()
	clone_10.Parent = folder

	for _, child in pairs(folder4:GetChildren()) do
		child.Parent = workspace
	end

	for _, child in pairs(game.ReplicatedStorage:GetChildren()) do
		if not (child.Name ~= "FlyCameraFocus" and child.Name ~= "DefaultChatSystemChatEvents" and child.Name ~= "StudioLiteFolder" and child.Name ~= "ClientAction") then
			continue
		end

		if not folder:FindFirstChild("ReplicatedStorage") then
			local folder_11 = Instance.new("Folder", folder)
			folder_11.Name = "ReplicatedStorage"
		end

		local clone_11 = child:Clone()
		clone_11.Parent = folder.ReplicatedStorage
	end

	for _, children in pairs(folder:GetDescendants()) do
		local sL_ObjectProps = children:GetAttribute("SL_ObjectProps")

		if not sL_ObjectProps then
			continue
		end

		for _, v in pairs(sL_ObjectProps:split(",")) do
			if not children[v] then
				continue
			end

			local fullName = children[v]:GetFullName()
			local parts = fullName:split(".")
			local child = folder

			for _, part in pairs(parts) do
				local v2 = part
				local success, _ = pcall(function()
					child = child:FindFirstChild(v2)
				end)

				if success then
					continue
				end

				warn(
					"Trouble with object property path. Obj:",
					children.Name,
					"Property:,",
					v,
					"pathStr:",
					fullName,
					"n:",
					part
				)
				child = nil
				break
			end

			if child then
				children[v] = child
			end
		end
	end

	return folder
end

return CloneLocalWorkspaceToReplicatedStorageModule