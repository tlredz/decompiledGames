local StructureInterfaceClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
StructureInterfaceClient.Settings = {
	SnapFence = true,
	SnapToGrid = false,
	SelectedColour = Color3.fromRGB(13, 105, 172)
}
local attributeChangedConnection = nil

function StructureInterfaceClient.OpenMenu(instance, instance2)
	StructureInterfaceClient.CloseMenu()
	local placeStructure = Client.Interface.PlaceStructure
	placeStructure.Frame.SnapFence.ImageLabel.Visible = StructureInterfaceClient.Settings.SnapFence
	placeStructure.Frame.SnapToGrid.ImageLabel.Visible = StructureInterfaceClient.Settings.SnapToGrid
	placeStructure.Frame.SnapFence.Visible = instance2:GetAttribute("FenceOrPath")
	placeStructure.Frame.SnapToGrid.Visible = true
	placeStructure.Frame.CloseButton.Visible = true
	local charges = instance:GetAttribute("Charges")

	if charges then
		placeStructure.Frame.ItemCount.Text = "item count: " .. charges
		placeStructure.Frame.ItemCount.Visible = true
	else
		placeStructure.Frame.ItemCount.Visible = false
	end

	placeStructure.Visible = true

	if attributeChangedConnection then
		attributeChangedConnection:Disconnect()
		attributeChangedConnection = nil
	end

	attributeChangedConnection = instance.AttributeChanged:Connect(function()
		local charges2 = instance:GetAttribute("Charges")

		if not charges2 then
			placeStructure.Frame.ItemCount.Visible = false
			return
		end

		placeStructure.Frame.ItemCount.Text = "item count: " .. charges2
		placeStructure.Frame.ItemCount.Visible = true
	end)
end

function StructureInterfaceClient.CloseMenu()
	if attributeChangedConnection then
		attributeChangedConnection:Disconnect()
		attributeChangedConnection = nil
	end

	local placeStructure = Client.Interface.PlaceStructure
	placeStructure.Frame.SnapFence.Visible = false
	placeStructure.Frame.SnapToGrid.Visible = false
	placeStructure.Frame.ItemCount.Visible = false
	placeStructure.Frame.Recolour.Visible = false
	placeStructure.Frame.CloseButton.Visible = false
	placeStructure.Visible = false
end

function StructureInterfaceClient.Recolour()
	StructureInterfaceClient.CloseMenu()
	local placeStructure = Client.Interface.PlaceStructure
	placeStructure.Frame.Recolour.Visible = true
	placeStructure.Visible = true
end

local uIStroke = nil

function RecolourEvents()
	local recolour = Client.Interface.PlaceStructure.Frame.Recolour
	local colourPicker = Client.Interface.ColourPicker
	uIStroke = colourPicker.Colours.UIStroke
	recolour.Activated:Connect(function()
		colourPicker.Visible = not colourPicker.Visible
		Client.Sound.Play("CloseButton")
	end)
	colourPicker.CloseButton.Activated:Connect(function()
		Client.Sound.Play("CloseButton")
		colourPicker.Visible = false
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function selectColour(parent)
		uIStroke.Parent = parent
		uIStroke.Enabled = true
		recolour.BackgroundColor3 = parent.BackgroundColor3
		StructureInterfaceClient.Settings.SelectedColor = recolour.BackgroundColor3
		Client.Events.SetPaintColour:Fire(recolour.BackgroundColor3)
	end

	for _, button in pairs(colourPicker.Colours:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local parent = button
		button.Activated:Connect(function()
			selectColour(parent) -- equivalent call inferred; original call site unknown
		end)
	end
end

local v = nil

function StructureInterfaceClient.OpenSignGui(p)
	local signWrite = Client.Interface.SignWrite
	signWrite.TextBox.Text = ""
	signWrite.TextBox.PlaceholderText = "WRITE HERE"
	signWrite.Visible = true
	v = p
end

function SignTypingEvents()
	local signWrite = Client.Interface.SignWrite
	local textBox = signWrite.TextBox

	-- equivalent calls inferred from this helper; original call sites unknown
	local function filterAndProcessText(text)
		local v2, v3 = Client.Events.FilterSignText:InvokeServer(text, Enum.TextFilterContext.PublicChat)

		if v2 then
			return true, v3
		end

		Client.PopUpUI.AddPopUp("text filtered. try again", "warning")
		signWrite.TextBox.Text = ""
		signWrite.TextBox.PlaceholderText = "WRITE HERE"
		return false, nil
	end

	signWrite.SubmitButton.Activated:Connect(function()
		local text = textBox.Text

		if text == "" then
			Client.PopUpUI.AddPopUp("text box empty", "warning")
			return
		end

		local v2, v3 = filterAndProcessText(text) -- equivalent call inferred; original call site unknown

		if v2 then
			Client.Events.WriteOnSign:FireServer(v, v3)
			Client.Sound.Play("CloseButton")
			Client.Sound.Play("SignWrite")
			signWrite.Visible = false
			v = nil
		end
	end)
	signWrite.CloseButton.Activated:Connect(function()
		signWrite.Visible = false
		Client.Sound.Play("CloseButton")
		v = nil
	end)
end

function StructureInterfaceClient.Init()
	local placeStructure = Client.Interface.PlaceStructure

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggle(p)
		StructureInterfaceClient.Settings[p.Name] = not StructureInterfaceClient.Settings[p.Name]
		p.ImageLabel.Visible = StructureInterfaceClient.Settings[p.Name]
		Client.Sound.Play("KeyPress")
	end

	placeStructure.Frame.SnapFence.Activated:Connect(function()
		toggle(placeStructure.Frame.SnapFence) -- equivalent call inferred; original call site unknown
	end)
	placeStructure.Frame.SnapToGrid.Activated:Connect(function()
		toggle(placeStructure.Frame.SnapToGrid) -- equivalent call inferred; original call site unknown
	end)
	placeStructure.Frame.CloseButton.Activated:Connect(function()
		StructureInterfaceClient.CloseMenu()
		Client.Sound.Play("CloseButton")
	end)
	RecolourEvents()
	SignTypingEvents()
end

return StructureInterfaceClient