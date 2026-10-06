local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local loadAssetModelToPlayerGuiServerFunction = studioLiteFolder:WaitForChild("LoadAssetModelToPlayerGuiServerFunction")
local clearAssetModelToPlayerGuiServerFunction = studioLiteFolder:WaitForChild("ClearAssetModelToPlayerGuiServerFunction")
local setSelection = game.Players.LocalPlayer.PlayerGui.StudioGui:WaitForChild("ExplorerPanel"):WaitForChild("SetSelection")
local flag = true
local studioGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui")
local v = false
local workingImageLabel1 = studioGui:WaitForChild("WorkingImageLabel1")
local workingImageLabel2 = studioGui:WaitForChild("WorkingImageLabel2")

function WorkingWaiting()
	spawn(function()
		v = true

		for _ = 1, 100 do
			if not v then
				break
			end

			if workingImageLabel1.Visible then
				workingImageLabel1.Visible = false
				workingImageLabel2.Visible = true
			else
				workingImageLabel1.Visible = true
				workingImageLabel2.Visible = false
			end

			task.wait(0.1)
		end

		v = false
		workingImageLabel1.Visible = false
		workingImageLabel2.Visible = false
	end)
end

script.Parent.Activated:Connect(function()
	if flag then
		flag = false
		script.Parent.Text = "working"
		WorkingWaiting()
		local match = script.Parent.Parent.ModelAssetTextBox.Text:match("%d+")

		if match and #match > 1 then
			script.Parent.Parent.ModelAssetTextBox.Text = match

			if loadAssetModelToPlayerGuiServerFunction:InvokeServer(match) then
				local clone = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild((tostring(match))):Clone()
				local workspace2 = clone:FindFirstChild("Workspace")

				if workspace2 and workspace2.ClassName == "Folder" then
					if workspace:FindFirstChild("SpawnLocation") then
						workspace.SpawnLocation:Destroy()
					end

					if workspace:FindFirstChild("Baseplate") then
						workspace.Baseplate:Destroy()
					end
				end

				for _, clone2 in pairs(clone:GetChildren()) do
					if clone2.ClassName == "Folder" and ("Workspace Lighting MaterialService ReplicatedStorage ServerStorage ServerScriptService StarterGui StarterPack Teams SoundService StarterPlayer InsertService TextChatService"):find(
						clone2.Name,
						1,
						true
					) then
						if clone2.Name == "ServerStorage" then
							for _, child in pairs(clone2:GetChildren()) do
								child.Parent = _G.ss
							end
						elseif clone2.Name == "ServerScriptService" then
							for _, child in pairs(clone2:GetChildren()) do
								child.Parent = _G.sss
							end
						elseif clone2.Name == "StarterPlayer" then
							for _, child in pairs(clone2:GetChildren()) do
								if child.Name == "StarterPlayerScripts" or child.Name == "StarterCharacterScripts" then
									for _, child2 in pairs(child:GetChildren()) do
										if not game.StarterPlayer[child.Name]:FindFirstChild(child2.Name) then
											child2.Parent = game.StarterPlayer[child.Name]
										end
									end
								else
									child.Parent = game.StarterPlayer
								end
							end
						elseif clone2.Name ~= "InsertService" and clone2.Name ~= "TextChatService" then
							for _, child in pairs(clone2:GetChildren()) do
								child.Parent = game[clone2.Name]
							end
						end
					elseif clone2:IsA("PostEffect") or clone2.ClassName == "Sky" then
						clone2.Parent = game.Lighting
					else
						local flag2, model

						if clone2.ClassName == "Model" then
							flag2 = false
						else
							model = Instance.new("Model")
							clone2.Parent = model
							clone2 = model
							flag2 = true
						end

						local boundingBox, v2 = clone2:GetBoundingBox()
						local v3 = not clone2.PrimaryPart and 0 or clone2.PrimaryPart.Position.Y - v2.Y / 2
						local cFrame = workspace.Camera.CFrame
						local vector = Vector3.new(
							math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2,
							v2.Y / 2 + v3,
							math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2
						)
						local raycastResult = workspace:Raycast(
							Vector3.new(vector.X, cFrame.Y, vector.Z),
							(Vector3.new(0, -cFrame.Y, 0))
						)

						if raycastResult then
							vector = Vector3.new(
								vector.X,
								raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + v2.Y / 2 + v3,
								vector.Z
							)
						end

						clone2:PivotTo(CFrame.new(vector) * boundingBox.Rotation)

						if flag2 then
							clone2 = clone2:GetChildren()[1]:Clone()
							clone2.Parent = workspace

							if model then
								model:Destroy()
							end
						else
							clone2.Parent = workspace
						end
					end

					task.wait(0.2)
					setSelection:Invoke({ clone2 })
				end

				clone:Destroy()
				clearAssetModelToPlayerGuiServerFunction:InvokeServer(match)
			else
				warn("Asset not found:", match)
			end
		else
			warn("Asset not found:", match)
		end

		v = false
		script.Parent.Text = "Get"
		flag = true
	end
end)