local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getGroupPlacesServerFunction = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("GetGroupPlacesServerFunction")
local publishFrame = script.Parent.Parent.Parent.Parent.PublishFrame
local publishToButton = publishFrame.PublishToButton
local replaceButton = publishFrame.ReplaceButton
local privatePlaceIdTextBox = publishFrame:WaitForChild("PrivatePlaceIdTextBox")
local privateUniverseIdTextBox = publishFrame:WaitForChild("PrivateUniverseIdTextBox")
local privatePlaceIdTextLabel = publishFrame:WaitForChild("PrivatePlaceIdTextLabel")
local privateUniverseIdTextLabel = publishFrame:WaitForChild("PrivateUniverseIdTextLabel")
script.Parent.Activated:Connect(function()
	script.Parent.Parent.Visible = false

	if publishToButton.Text ~= script.Parent.Text then
		publishToButton.Text = script.Parent.Text
		replaceButton.Text = "   Loading..."
		script.Parent.Parent.Visible = false
		replaceButton.Visible = true
		privatePlaceIdTextBox.Visible = false
		privateUniverseIdTextBox.Visible = false
		privatePlaceIdTextLabel.Visible = false
		privateUniverseIdTextLabel.Visible = false
		local v = getGroupPlacesServerFunction:InvokeServer()

		if v then
			local placeChoicesFrame = publishFrame.PlaceChoicesFrame

			for _, child in ipairs(placeChoicesFrame:GetChildren()) do
				if child.Name == "clone" then
					child:Destroy()
				end
			end

			for i, v2 in ipairs(v.data) do
				local text = v2.name .. (" - " .. (v2.description or "")):sub(1, (math.clamp(50 - #v2.name, 0, 50)))

				if i == 1 then
					replaceButton.Text = text
					replaceButton.universeValue.Value = v2.id
					replaceButton.placeValue.Value = v2.rootPlace.id
					placeChoicesFrame.Place.Text = text
					placeChoicesFrame.Place.universeValue.Value = v2.id
					placeChoicesFrame.Place.placeValue.Value = v2.rootPlace.id
				else
					local clone = placeChoicesFrame.Place:Clone()
					clone.Name = "clone"
					clone.LayoutOrder = i
					clone.Text = text
					clone.universeValue.Value = v2.id
					clone.placeValue.Value = v2.rootPlace.id
					clone.Parent = placeChoicesFrame
				end
			end
		end

		if replaceButton.Text == "   Loading..." then
			replaceButton.Text = "Your game must be Public and your group must be Primary."
			replaceButton.universeValue.Value = ""
			replaceButton.placeValue.Value = ""
			warn("Make your game public in the Roblox Creator Hub, and make your Community Primary with the (...) near community name. Or choose Publish to Private.")
		end
	end
end)