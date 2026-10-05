local UserInputService = game:GetService("UserInputService")
local E = Enum.KeyCode.E
local v = {
	[E] = true
}
local v2 = {}

local function updateLabels()
	local v3 = (not UserInputService.KeyboardEnabled or UserInputService.TouchEnabled) and "" or ` ({E.Name})`

	for _, v4 in v2 do
		for k, label in v4.labels do
			k.Text = label .. v3
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectFrame(p)
	if v2[p] then
		v2[p].connection:Disconnect()
		v2[p] = nil
	end
end

script.Parent:WaitForChild("Bind").Event:Connect(function(p, instance, onMouseButton1Up)
	disconnectFrame(p) -- equivalent call inferred; original call site unknown
	local mouseButton1UpConnection = instance.MouseButton1Up:Connect(onMouseButton1Up)
	local baseTextsByTxt = {}
	local txt = instance:FindFirstChild("Txt")

	if txt and txt:IsA("TextLabel") then
		local baseText = txt:GetAttribute("BaseText")

		if typeof(baseText) ~= "string" then
			baseText = txt.Text
			txt:SetAttribute("BaseText", baseText)
		end

		baseTextsByTxt[txt] = baseText
	end

	v2[p] = {
		callback = onMouseButton1Up,
		connection = mouseButton1UpConnection,
		labels = baseTextsByTxt
	}

	if next(baseTextsByTxt) then
		updateLabels()
	end
end)
script.Parent:WaitForChild("Unbind").Event:Connect(function(p)
	disconnectFrame(p) -- equivalent call inferred; original call site unknown
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard or not v[input.KeyCode] then
		return
	end

	for k, v3 in v2 do
		if not (k.Parent ~= nil and k.Visible) then
			continue
		end

		v3.callback()
		break
	end
end)
UserInputService.LastInputTypeChanged:Connect(updateLabels)