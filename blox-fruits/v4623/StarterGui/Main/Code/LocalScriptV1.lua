local visible = false
local textBox = script.Parent.TextLabel:WaitForChild("TextBox")

local function update()
	visible = not visible
	script.Parent.TextLabel.Visible = visible

	if visible then
		script.Parent.TextLabel.TextBox.Text = ""
	end
end

script.Parent.MouseButton1Click:Connect(update)
local flag = false
script.Parent.TextLabel.Try.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	flag = true
	local text = textBox.Text
	textBox.Text = ""
	textBox.PlaceholderColor3 = Color3.fromRGB(17, 17, 17)
	textBox.PlaceholderText = "PROCESSING..."
	local placeholderText = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Redeem"):InvokeServer(text)

	if placeholderText == "SUCCESS!" then
		textBox.Text = ""
		textBox.PlaceholderColor3 = Color3.new(0, 1, 0)
		textBox.PlaceholderText = "SUCCESS!"
	else
		textBox.Text = ""
		textBox.PlaceholderColor3 = Color3.new(1, 0, 0)
		textBox.PlaceholderText = placeholderText
	end

	wait(3)
	textBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	textBox.PlaceholderText = "Codes: Check our social links!"
	flag = false
end)