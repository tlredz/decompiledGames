local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local localPlayer = Players.LocalPlayer
return {
	Start = function(_)
		local creatorCodes = localPlayer:WaitForChild("PlayerGui"):WaitForChild("CreatorCodes")
		local textBox = creatorCodes.Main.CodeBar.TextBox
		creatorCodes.Main.Close.Activated:Connect(function()
			v3:Open("Settings")
		end)
		local v5 = v.Client:WaitReplion("Data")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateText()
			textBox.Text = v5:Get("CreatorCodes.Active") or ""
		end

		local function submitCode()
			textBox.TextEditable = false

			if not textBox.Text or textBox.Text == "" then
				v2:Invoke("ClearCreatorCode")
				textBox.TextEditable = true
				updateText() -- equivalent call inferred; original call site unknown
			end

			local v6, text = v2:Invoke("SetCreatorCode", textBox.Text)

			if v6 then
				textBox.Text = text
				textBox.TextColor3 = Color3.fromRGB(100, 255, 100)
			else
				v4.Sounds:Play("error")
				textBox.Text = text
				textBox.TextColor3 = Color3.fromRGB(255, 100, 100)
			end

			task.wait(1)
			updateText() -- equivalent call inferred; original call site unknown
			textBox.TextEditable = true
			textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		creatorCodes.Main.OKButton.Activated:Connect(submitCode)
		textBox.FocusLost:Connect(function(p)
			if p then
				submitCode()
			end
		end)
		creatorCodes.Main.Cancel.Activated:Connect(function()
			textBox.TextEditable = false
			v2:Invoke("ClearCreatorCode")
			textBox.TextEditable = true
			updateText() -- equivalent call inferred; original call site unknown
		end)
		v3:OnGuiOpen("CreatorCodes", updateText)
		v5:OnChange("CreatorCodes", updateText)
	end
}