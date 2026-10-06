local ClonePathGameToLocalWorkspaceModule = {}
ClonePathGameToLocalWorkspaceModule.__index = ClonePathGameToLocalWorkspaceModule
local StarterPlayer = game:GetService("StarterPlayer")

function ClonePathGameToLocalWorkspaceModule.Load(_, instance)
	if instance then
		local replicatedStorage = instance:FindFirstChild("ReplicatedStorage")

		if replicatedStorage then
			for _, child in pairs(replicatedStorage:Clone():GetChildren()) do
				child.Parent = game.ReplicatedStorage
			end
		end

		local lighting = instance:FindFirstChild("Lighting")

		if lighting then
			for _, child in pairs(lighting:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = game.Lighting
			end

			game.Lighting.Ambient = lighting:GetAttribute("Ambient")
			game.Lighting.Brightness = lighting:GetAttribute("Brightness")
			game.Lighting.ColorShift_Top = lighting:GetAttribute("ColorShift_Top")
			game.Lighting.ColorShift_Bottom = lighting:GetAttribute("ColorShift_Bottom")
			game.Lighting.EnvironmentDiffuseScale = lighting:GetAttribute("EnvironmentDiffuseScale")
			game.Lighting.EnvironmentSpecularScale = lighting:GetAttribute("EnvironmentSpecularScale")
			game.Lighting.GlobalShadows = lighting:GetAttribute("GlobalShadows")
			game.Lighting.OutdoorAmbient = lighting:GetAttribute("OutdoorAmbient")
			game.Lighting.ShadowSoftness = lighting:GetAttribute("ShadowSoftness")
			game.Lighting.Archivable = lighting:GetAttribute("Archivable")
			game.Lighting.ClockTime = lighting:GetAttribute("ClockTime")
			game.Lighting.TimeOfDay = lighting:GetAttribute("TimeOfDay")
			game.Lighting.ExposureCompensation = lighting:GetAttribute("ExposureCompensation")
			game.Lighting.FogColor = lighting:GetAttribute("FogColor")
			game.Lighting.FogEnd = lighting:GetAttribute("FogEnd")
			game.Lighting.FogStart = lighting:GetAttribute("FogStart")
			game.Lighting:SetAttribute("SL_Technology", lighting:GetAttribute("SL_Technology"))
		end

		local serverScriptService = instance:FindFirstChild("ServerScriptService")

		if serverScriptService then
			for _, child in pairs(serverScriptService:GetChildren()) do
				local clone_2 = child:Clone()
				clone_2.Parent = _G.sss
			end
		end

		local serverStorage = instance:FindFirstChild("ServerStorage")

		if serverStorage then
			for _, child in pairs(serverStorage:Clone():GetChildren()) do
				child.Parent = _G.ss
			end
		end

		local starterGui = instance:FindFirstChild("StarterGui")

		if starterGui then
			for _, child in pairs(starterGui:GetChildren()) do
				local clone_3 = child:Clone()
				clone_3.Parent = game.StarterGui
			end
		end

		local starterPack = instance:FindFirstChild("StarterPack")

		if starterPack then
			for _, child in pairs(starterPack:GetChildren()) do
				local clone_4 = child:Clone()
				clone_4.Parent = game.StarterPack
			end
		end

		local starterPlayer = instance:FindFirstChild("StarterPlayer")

		if starterPlayer then
			game.StarterPlayer.HealthDisplayDistance = starterPlayer:GetAttribute("HealthDisplayDistance")
			game.StarterPlayer.NameDisplayDistance = starterPlayer:GetAttribute("NameDisplayDistance")
			game.StarterPlayer.CameraMode = starterPlayer:GetAttribute("CameraMode")
			game.StarterPlayer.CameraMinZoomDistance = starterPlayer:GetAttribute("CameraMinZoomDistance")
			game.StarterPlayer.CameraMaxZoomDistance = starterPlayer:GetAttribute("CameraMaxZoomDistance")
			game.StarterPlayer.CharacterMaxSlopeAngle = starterPlayer:GetAttribute("CharacterMaxSlopeAngle")
			game.StarterPlayer.CharacterWalkSpeed = starterPlayer:GetAttribute("CharacterWalkSpeed")
			game.StarterPlayer.LoadCharacterAppearance = starterPlayer:GetAttribute("LoadCharacterAppearance")
			game.StarterPlayer.CharacterJumpHeight = starterPlayer:GetAttribute("CharacterJumpHeight")
			game.StarterPlayer.CharacterUseJumpPower = starterPlayer:GetAttribute("CharacterUseJumpPower")
			game.StarterPlayer.AutoJumpEnabled = starterPlayer:GetAttribute("AutoJumpEnabled")

			for _, child in pairs(starterPlayer:GetChildren()) do
				if child.Name == "StarterCharacterScripts" then
					for _, child2 in pairs(child:GetChildren()) do
						local clone_5 = child2:Clone()
						clone_5.Parent = StarterPlayer.StarterCharacterScripts
					end
				elseif child.Name == "StarterPlayerScripts" then
					for _, child2 in pairs(child:GetChildren()) do
						local clone_6 = child2:Clone()
						clone_6.Parent = StarterPlayer.StarterPlayerScripts
					end
				else
					local clone_7 = child:Clone()
					clone_7.Parent = StarterPlayer
				end
			end
		end

		local teams = instance:FindFirstChild("Teams")

		if teams then
			for _, child in pairs(teams:GetChildren()) do
				local clone_8 = child:Clone()
				clone_8.Parent = game.Teams
			end
		end

		local workspace2 = instance:FindFirstChild("Workspace")

		if workspace2 then
			for _, child in pairs(workspace2:Clone():GetChildren()) do
				child.Parent = workspace
			end
		else
			warn("SL_Error: " .. script.Name .. " game." .. workspace2.Name .. " not found.")
		end

		for _, sses in pairs(workspace:GetDescendants()) do
			local sL_ObjectProps = sses:GetAttribute("SL_ObjectProps")

			if not sL_ObjectProps then
				continue
			end

			for _, v in pairs(sL_ObjectProps:split(",")) do
				if not sses[v] then
					continue
				end

				local fullName = sses[v]:GetFullName()
				local ss = _G.ss
				local v2, v3 = fullName:find(".ServerStorage.", 1, true)

				if v2 and v3 then
					for _, v5 in pairs(fullName:sub(v3 + 1):split(".")) do
						local v6 = v5
						local success, _ = pcall(function()
							ss = ss:FindFirstChild(v6)
						end)

						if success then
							continue
						end

						warn(
							"Trouble with object property path. Obj:",
							sses.Name,
							"Property:,",
							v,
							"path:",
							fullName,
							"e:",
							v3
						)
						ss = nil
						break
					end
				else
					local v4, v5 = fullName:find(".ServerScriptService.", 1, true)

					if v4 and v5 then
						ss = _G.sss

						for _, v7 in pairs(fullName:sub(v5 + 1):split(".")) do
							local v8 = v7
							local success, _ = pcall(function()
								ss = ss:FindFirstChild(v8)
							end)

							if success then
								continue
							end

							warn(
								"Trouble with object property path. Obj:",
								sses.Name,
								"Property:,",
								v,
								"path:",
								fullName,
								"e:",
								v5
							)
							ss = nil
							break
						end
					elseif fullName:sub(1, 8) == "Players." then
						ss = game
						local parts = fullName:split(".")

						for i = 5, #parts do
							local v6 = parts
							local v7 = i
							local success, _ = pcall(function()
								ss = ss:FindFirstChild(v6[v7])
							end)

							if success then
								continue
							end

							warn(
								"Trouble with object property path. Obj:",
								sses.Name,
								"Property:,",
								v,
								"path:",
								fullName,
								"n:",
								i,
								"pathSplit[n]",
								parts[i]
							)
							ss = nil
							break
						end
					end
				end

				if ss then
					sses[v] = ss
				end
			end
		end

		if instance then
			instance:Destroy()
		end
	else
		warn("Unexpected Error: " .. script.Name .. " gamePathName is empty.")
	end
end

return ClonePathGameToLocalWorkspaceModule