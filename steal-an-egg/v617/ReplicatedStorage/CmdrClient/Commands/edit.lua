local Players = game:GetService("Players")
local v = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(17, 17, 17),
	BackgroundTransparency = 0.05,
	BorderColor3 = Color3.fromRGB(17, 17, 17),
	BorderSizePixel = 20,
	ClearTextOnFocus = false,
	MultiLine = true,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0.5, 0, 0.4, 0),
	Font = Enum.Font.Code,
	TextColor3 = Color3.fromRGB(241, 241, 241),
	TextWrapped = true,
	TextSize = 18,
	TextXAlignment = "Left",
	TextYAlignment = "Top",
	AutoLocalize = false,
	PlaceholderText = "Right click to exit"
}
local v2 = nil
return {
	Name = "edit",
	Aliases = {},
	Description = "Edit text in a TextBox",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Input text",
			Description = "The text you wish to edit",
			Default = ""
		},
		{
			Type = "string",
			Name = "Delimiter",
			Description = "The character that separates each line",
			Default = ","
		}
	},
	ClientRun = function(object, value, p)
		v2 = v2 or object.Cmdr.Util.Mutex()
		local v3 = v2()
		object:Reply("Right-click on the text area to exit.", Color3.fromRGB(158, 158, 158))
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "CmdrEditBox"
		screenGui.ResetOnSpawn = false
		local textBox = Instance.new("TextBox")

		for k, v4 in pairs(v) do
			textBox[k] = v4
		end

		textBox.Text = value:gsub(p, "\n")
		textBox.Parent = screenGui
		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		local thread = coroutine.running()
		textBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				coroutine.resume(thread, textBox.Text:gsub("\n", p))
				screenGui:Destroy()
				v3()
			end
		end)
		return coroutine.yield()
	end
}