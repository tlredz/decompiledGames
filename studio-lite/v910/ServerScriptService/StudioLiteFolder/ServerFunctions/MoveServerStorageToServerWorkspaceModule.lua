local MoveServerStorageToServerWorkspaceModule = {}
MoveServerStorageToServerWorkspaceModule.__index = MoveServerStorageToServerWorkspaceModule
game:GetService("Debris")
local scripts = game.ServerStorage.StudioLiteFolder.Scripts
local _ = game.ServerStorage.StudioLiteFolder.Models

function InsertLiveScripts(instance)
	if instance.ClassName == "LocalScript" or instance.ClassName == "Script" or instance.ClassName == "ModuleScript" then
		if instance.Name == "SL_ColorizeAndEditLocal" or instance.Name == "SL_MoveLocal" or instance.Name == "SL_SizeLocal" then
			instance:Destroy()
			return
		end

		local insertScriptScriptClientRunContext

		if instance:FindFirstChild("SL_CodeTextBox") then
			if instance.ClassName == "Script" then
				if instance.RunContext == Enum.RunContext.Client then
					insertScriptScriptClientRunContext = scripts:FindFirstChild("InsertScriptScriptClientRunContext")
				else
					insertScriptScriptClientRunContext = scripts:FindFirstChild("InsertScriptScript")
				end
			else
				insertScriptScriptClientRunContext = scripts:FindFirstChild("InsertLocalScriptLocalScript")
			end
		else
			insertScriptScriptClientRunContext = scripts:FindFirstChild(instance.ClassName .. instance.Name) or scripts:FindFirstChild("Insert" .. instance.ClassName .. instance.Name)
		end

		if not insertScriptScriptClientRunContext then
			warn("Script not found:", instance.ClassName .. instance.Name)
			return
		end

		local clone = insertScriptScriptClientRunContext:Clone()
		clone.Name = instance.Name
		clone.Parent = instance.Parent

		if instance.ClassName == "LocalScript" then
			if instance:FindFirstChild("SL_CodeTextBox") and instance.Enabled == false then
				clone.Enabled = false
			else
				clone.Enabled = true
			end
		elseif instance.ClassName == "Script" then
			clone.Enabled = instance.Enabled
		end

		for _, child in pairs(instance:GetChildren()) do
			if clone:FindFirstChild(child.Name) then
				if child.ClassName == "LocalScript" or child.ClassName == "Script" or child.ClassName == "ModuleScript" then
					InsertLiveScripts(child)
					continue
				else
					clone:FindFirstChild(child.Name):Destroy()
				end
			end

			local clone2 = child:Clone()
			clone2.Parent = clone
			InsertLiveScripts(clone2)
		end

		instance:Destroy()
	else
		for _, child in pairs(instance:GetChildren()) do
			InsertLiveScripts(child)
		end
	end
end

local StarterPlayer = game:GetService("StarterPlayer")

function MoveServerStorageToServerWorkspaceModule.Load(_)
	InsertLiveScripts(game.ServerStorage.StudioLiteFolder.game.Play321)

	for _, child in pairs(game.ServerStorage.StudioLiteFolder.game.Play321:GetChildren()) do
		if child.Name == "Workspace" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = workspace
			end
		elseif child.Name == "ReplicatedStorage" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.ReplicatedStorage
			end
		elseif child.Name == "ServerScriptService" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.ServerScriptService
			end
		elseif child.Name == "ServerStorage" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.ServerStorage
			end
		elseif child.Name == "StarterGui" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.StarterGui

				for _, v in pairs(game.Players:GetPlayers()) do
					local clone = child2:Clone()
					clone.Parent = v.PlayerGui
				end
			end
		elseif child.Name == "Lighting" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.Lighting
			end

			game.Lighting.Ambient = child:GetAttribute("Ambient")
			game.Lighting.Brightness = child:GetAttribute("Brightness")
			game.Lighting.ColorShift_Top = child:GetAttribute("ColorShift_Top")
			game.Lighting.ColorShift_Bottom = child:GetAttribute("ColorShift_Bottom")
			game.Lighting.EnvironmentDiffuseScale = child:GetAttribute("EnvironmentDiffuseScale")
			game.Lighting.EnvironmentSpecularScale = child:GetAttribute("EnvironmentSpecularScale")
			game.Lighting.GlobalShadows = child:GetAttribute("GlobalShadows")
			game.Lighting.OutdoorAmbient = child:GetAttribute("OutdoorAmbient")
			game.Lighting.ShadowSoftness = child:GetAttribute("ShadowSoftness")
			game.Lighting.Archivable = child:GetAttribute("Archivable")
			game.Lighting.ClockTime = child:GetAttribute("ClockTime")
			game.Lighting.TimeOfDay = child:GetAttribute("TimeOfDay")
			game.Lighting.ExposureCompensation = child:GetAttribute("ExposureCompensation")
			game.Lighting.FogColor = child:GetAttribute("FogColor")
			game.Lighting.FogEnd = child:GetAttribute("FogEnd")
			game.Lighting.FogStart = child:GetAttribute("FogStart")
			game.Lighting:SetAttribute("SL_Technology", child:GetAttribute("SL_Technology"))
		elseif child.Name == "StarterPack" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.StarterPack
			end
		elseif child.Name == "StarterPlayer" then
			StarterPlayer.HealthDisplayDistance = child:GetAttribute("HealthDisplayDistance")
			StarterPlayer.NameDisplayDistance = child:GetAttribute("NameDisplayDistance")
			StarterPlayer.CameraMode = child:GetAttribute("CameraMode")
			StarterPlayer.CameraMinZoomDistance = child:GetAttribute("CameraMinZoomDistance")
			StarterPlayer.CameraMaxZoomDistance = child:GetAttribute("CameraMaxZoomDistance")
			StarterPlayer.CharacterMaxSlopeAngle = child:GetAttribute("CharacterMaxSlopeAngle")
			StarterPlayer.CharacterWalkSpeed = child:GetAttribute("CharacterWalkSpeed")
			StarterPlayer.LoadCharacterAppearance = child:GetAttribute("LoadCharacterAppearance")
			StarterPlayer.CharacterJumpHeight = child:GetAttribute("CharacterJumpHeight")
			StarterPlayer.CharacterUseJumpPower = child:GetAttribute("CharacterUseJumpPower")
			StarterPlayer.AutoJumpEnabled = child:GetAttribute("AutoJumpEnabled")

			for _, child2 in pairs(child:GetChildren()) do
				if child2.Name == "StarterCharacterScripts" then
					for _, child3 in pairs(child2:GetChildren()) do
						child3.Parent = StarterPlayer.StarterCharacterScripts

						for _, v in pairs(game.Players:GetPlayers()) do
							if not v.Character then
								continue
							end

							local clone_2 = child3:Clone()
							clone_2.Parent = v.Character
						end
					end
				elseif child2.Name == "StarterPlayerScripts" then
					for _, child3 in pairs(child2:GetChildren()) do
						child3.Parent = StarterPlayer.StarterPlayerScripts

						for _, v in pairs(game.Players:GetPlayers()) do
							local clone_3 = child3:Clone()
							clone_3.Parent = v.PlayerGui
						end
					end
				else
					child2.Parent = StarterPlayer
				end
			end
		elseif child.Name == "Teams" then
			for _, child2 in pairs(child:GetChildren()) do
				child2.Parent = game.Teams
			end
		else
			child.Parent = workspace
		end
	end
end

return MoveServerStorageToServerWorkspaceModule