local v = {
	PrintCompletionTime = false,
	PrintObjectVariableErrors = false,
	PrintDataStoreApproximateSize = true,
	ExcludedProperties = { "BrickColor" },
	ShowHTTPWarning = false
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local filterStringServerFunction = studioLiteFolder:WaitForChild("FilterStringServerFunction")
local getPlacesServerFunction = studioLiteFolder:WaitForChild("GetPlacesServerFunction")
local MainConvertModule = require(studioLiteFolder:WaitForChild("MainConvertModule"))
local serverFunctions = studioLiteFolder:WaitForChild("ServerFunctions")
local HttpService = game:GetService("HttpService")
local CloneLocalWorkspaceToReplicatedStorageModule = require(script.Parent.Parent.Parent.CloneLocalWorkspaceToReplicatedStorageModule)
local flag = true
local mouseButton1ClickConnection = nil
local CloneStarterGuiForEditOrPlayModule = require(script.Parent.Parent.Parent:WaitForChild("CloneStarterGuiForEditOrPlayModule"))
script.Parent:WaitForChild("SaveButton").MouseButton1Click:Connect(function()
	if flag then
		flag = false
		local warningText = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("WarningText")
		local text2 = script.Parent:WaitForChild("GameNameTextBox").Text:gsub("^%s*", ""):gsub("%s*$", ""):gsub(
			"\t",
			" "
		)
		local gameNameTextBox = script.Parent:WaitForChild("GameNameTextBox")
		gameNameTextBox.Text = text2

		if text2 == "" then
			warningText.Text = "Type a Game Name."
			warningText.Visible = true
			task.wait(1)
			warningText.Visible = false
		else
			warningText.Text = "Saving " .. script.Parent.GameNameTextBox.Text .. "..."
			warningText.Visible = true
			script.Parent.Visible = false
			script.Parent.Parent.FileMenu.Visible = false
			script.Parent.Parent.Parent.OpenSaveFrame.Visible = false

			if _G.SL_ImageLabelsFolderClone then
				_G.SL_ImageLabelsFolderClone:Destroy()
				CloneStarterGuiForEditOrPlayModule:Edit()
			end

			local character = game.Players.LocalPlayer.Character

			if character:FindFirstChild("SL_MoveLocal") then
				character:FindFirstChild("SL_MoveLocal"):Destroy()
			end

			if character:FindFirstChild("SL_SizeLocal") then
				character:FindFirstChild("SL_SizeLocal"):Destroy()
			end

			local v3 = script.Parent:WaitForChild("PublishCheckboxImageButton").Image:sub(-8) == "48138491"
			local text3 = script.Parent:WaitForChild("DescriptionTextBox").Text:gsub("^%s*", ""):gsub("%s*$", ""):gsub(
				"\t",
				" "
			)
			local descriptionTextBox = script.Parent:WaitForChild("DescriptionTextBox")
			descriptionTextBox.Text = text3
			local flag2 = true
			script.Parent.GameNameTextBox.BorderColor3 = Color3.new(0, 0, 0)
			script.Parent.GameNameTextBox.BorderSizePixel = 1

			if v3 then
				local text = filterStringServerFunction:InvokeServer(text2)

				if text ~= text2 then
					script.Parent.GameNameTextBox.Text = text
					script.Parent.GameNameTextBox.BorderColor3 = Color3.new(1, 0, 0)
					script.Parent.GameNameTextBox.BorderSizePixel = 3
					flag2 = false
				end

				local text4 = filterStringServerFunction:InvokeServer(text3)

				if text4 ~= text3 then
					script.Parent.DescriptionTextBox.Text = text4
					script.Parent.DescriptionTextBox.BorderColor3 = Color3.new(1, 0, 0)
					script.Parent.DescriptionTextBox.BorderSizePixel = 3
					flag2 = false
				end
			end

			if flag2 then
				local value = script.Parent:WaitForChild("GameNumberValue").Value
				local v5 = CloneLocalWorkspaceToReplicatedStorageModule:CloneLocal(script.Parent.GameNameTextBox.Text)
				local converted = MainConvertModule:Convert(v5, v)
				local v6 = tostring(HttpService:JSONEncode(converted))
				local v7, v8

				if v6:len() > 3400000 then
					serverFunctions:InvokeServer("Save", "start")

					for i = 1, 10 do
						local v9 = v6:sub((i - 1) * 3400000 + 1, i * 3400000)

						if v9 and v9:len() > 0 then
							serverFunctions:InvokeServer("Save", v9)
							task.wait()
						else
							break
						end
					end

					v7, v8 = serverFunctions:InvokeServer("Save", "end", value, text3, v3)
				else
					v7, v8 = serverFunctions:InvokeServer("Save", converted, value, text3, v3)
				end

				if v7 then
					warningText.Text = "Saved"

					if v3 then
						task.wait(0.1)
						warningText.Text = "Publish..."
						local publishFrame = script.Parent.Parent.PublishFrame
						local text4, v10 = getPlacesServerFunction:InvokeServer()

						if text4 then
							publishFrame.ApiKeyScrollingFrame.ApiKeyTextBox.Text = text4
						end

						if v10 then
							local replaceButton = publishFrame.ReplaceButton
							local placeChoicesFrame = publishFrame.PlaceChoicesFrame

							for _, child in ipairs(placeChoicesFrame:GetChildren()) do
								if child.Name == "clone" then
									child:Destroy()
								end
							end

							for i, v11 in ipairs(v10.data) do
								local text = v11.name .. (" - " .. (v11.description or "")):sub(
									1,
									(math.clamp(50 - #v11.name, 0, 50))
								)

								if i == 1 then
									replaceButton.Text = text
									replaceButton.universeValue.Value = v11.id
									replaceButton.placeValue.Value = v11.rootPlace.id
									placeChoicesFrame.Place.Text = text
									placeChoicesFrame.Place.universeValue.Value = v11.id
									placeChoicesFrame.Place.placeValue.Value = v11.rootPlace.id
								else
									local clone = placeChoicesFrame.Place:Clone()
									clone.Name = "clone"
									clone.LayoutOrder = i
									clone.Text = text
									clone.universeValue.Value = v11.id
									clone.placeValue.Value = v11.rootPlace.id
									clone.Parent = placeChoicesFrame
								end
							end

							warningText.Visible = false
							publishFrame.Visible = true

							if mouseButton1ClickConnection then
								mouseButton1ClickConnection:Disconnect()
							end

							mouseButton1ClickConnection = publishFrame.PublishButton.MouseButton1Click:Connect(function()
								local value2 = replaceButton.universeValue.Value
								local value3 = replaceButton.placeValue.Value

								if publishFrame:WaitForChild("PrivateUniverseIdTextBox").Visible then
									value2 = publishFrame:WaitForChild("PrivateUniverseIdTextBox").Text
									value3 = publishFrame:WaitForChild("PrivatePlaceIdTextBox").Text
								end

								local text = publishFrame.ApiKeyScrollingFrame.ApiKeyTextBox.Text

								if value2 and value3 and text and #value2 > 3 and #value3 > 3 and #text > 18 and not text:find(
									" ",
									1,
									true
								) then
									publishFrame.Visible = false
									warningText.Text = "Publishing..."
									warningText.Visible = true
									serverFunctions:InvokeServer(
										"Publish",
										"use saved table",
										text2,
										text3,
										v3,
										value2,
										value3,
										text
									)
								else
									warningText.Text = "Incomplete.  See 'Help'."
									warningText.Visible = true
									task.wait(4)
									warningText.Visible = false
								end
							end)
						else
							warn("Error retrieving places:", v10)
						end
					end
				else
					warningText.Text = "Save Failed: " .. v8
					task.wait(10)
				end

				v5:Destroy()
				task.wait(1)
				warningText.Visible = false
			else
				script.Parent.Visible = true
				warningText.Text = "Moderated."
				warningText.Visible = true
				task.wait(3)
				warningText.Visible = false
			end
		end

		task.wait(0.5)
		flag = true
	end
end)
script.Parent:WaitForChild("PublishCheckboxImageButton").MouseButton1Click:Connect(function()
	if script.Parent:WaitForChild("PublishCheckboxImageButton").Image:sub(-8) == "48138491" then
		local publishCheckboxImageButton = script.Parent:WaitForChild("PublishCheckboxImageButton")
		publishCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138474"
		local publishDescTextLabel = script.Parent:WaitForChild("PublishDescTextLabel")
		publishDescTextLabel.Text = "(Save for later.)"
	else
		local publishCheckboxImageButton_2 = script.Parent:WaitForChild("PublishCheckboxImageButton")
		publishCheckboxImageButton_2.Image = "http://www.roblox.com/asset/?id=48138491"
		local publishDescTextLabel_2 = script.Parent:WaitForChild("PublishDescTextLabel")
		publishDescTextLabel_2.Text = "(Everyone can play it together.)"
	end
end)