local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPlacesServerFunction = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("GetPlacesServerFunction")
local publishFrame = script.Parent.Parent.Parent.Parent.PublishFrame
local publishToButton = publishFrame:WaitForChild("PublishToButton")
local replaceButton = publishFrame:WaitForChild("ReplaceButton")
local privatePlaceIdTextBox = publishFrame:WaitForChild("PrivatePlaceIdTextBox")
local privateUniverseIdTextBox = publishFrame:WaitForChild("PrivateUniverseIdTextBox")
local privatePlaceIdTextLabel = publishFrame:WaitForChild("PrivatePlaceIdTextLabel")
local privateUniverseIdTextLabel = publishFrame:WaitForChild("PrivateUniverseIdTextLabel")
script.Parent.Activated:Connect(function()
	script.Parent.Parent.Visible = false

	if publishToButton.Text ~= script.Parent.Text then
		publishToButton.Text = script.Parent.Text
		replaceButton.Text = "   Loading..."
		replaceButton.Visible = true
		privatePlaceIdTextBox.Visible = false
		privateUniverseIdTextBox.Visible = false
		privatePlaceIdTextLabel.Visible = false
		privateUniverseIdTextLabel.Visible = false
		local _, v = getPlacesServerFunction:InvokeServer()

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
			replaceButton.Text = "Make your game public."
			replaceButton.universeValue.Value = ""
			replaceButton.placeValue.Value = ""
			warn("Make your game public in the Roblox Creator Hub. Or choose Publish to Private.")
		end
	end
end)