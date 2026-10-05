local visible = false
local codesWindow = script.Parent.Parent:WaitForChild("CodesWindow")
local textBox = codesWindow:WaitForChild("TextBox")

-- equivalent calls inferred from this helper; original call sites unknown
local function update(p)
	if p then
		visible = p
	else
		visible = not visible
	end

	codesWindow.Visible = visible

	if visible then
		textBox.Text = ""
		local Global = require(game.ReplicatedStorage.Global)
		Global.closeOthers()
	end
end

script.Parent.MouseButton1Click:Connect(update)
codesWindow.Header.CloseButton.MouseButton1Click:Connect(function()
	update() -- equivalent call inferred; original call site unknown
end)
local flag = false
codesWindow.BuyButton.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	flag = true
	local text = textBox.Text
	codesWindow.BuyButton.Frame.TextShadow.Text = "..."
	codesWindow.BuyButton.Frame.TextShadow.RealText.Text = "..."
	local text2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Redeem"):InvokeServer(text)

	if text2 == "SUCCESS!" then
		textBox.Text = ""
	elseif text2 then
		codesWindow.InvalidTextShadow.Visible = true
		codesWindow.InvalidTextShadow.Text = text2
		codesWindow.InvalidTextShadow.RealText.Text = text2
		task.wait(2.5)
		codesWindow.InvalidTextShadow.Visible = false
	end

	codesWindow.BuyButton.Frame.TextShadow.Text = "Redeem!"
	codesWindow.BuyButton.Frame.TextShadow.RealText.Text = "Redeem!"
	flag = false
end)