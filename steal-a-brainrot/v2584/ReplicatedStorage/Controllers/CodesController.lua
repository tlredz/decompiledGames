local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local NotificationController = require(controllers.NotificationController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local CodesFlags = require(ReplicatedStorage.Shared.Flags.CodesFlags)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local isTradePlaza = ServerData.IsTradePlaza()
local playerGui = Players.LocalPlayer.PlayerGui
local codes = playerGui:WaitForChild("Codes").Codes
local codes2 = playerGui:WaitForChild("LeftCenter").LeftCenter.Buttons:WaitForChild("Codes")
local v = nil

local function initTextbox(textBox, confirm)
	local v2 = false

	local function submitCode()
		if v2 or not textBox.Active then
			return
		end

		local text = textBox.Text

		if #text < 1 then
			NotificationController:Error("Invalid code")
			return
		end

		v2 = true
		textBox.Text = ""
		textBox.PlaceholderText = "Redeeming..."
		textBox.Selectable = false
		textBox.Active = false
		textBox:ReleaseFocus()
		local success, result, v3 = pcall(function()
			return Net:RemoteFunction("d193b9bf-8b44-42af-b4b2-9c77847ce1e9"):InvokeServer(text)
		end)

		if success then
			if result then
				if success and result then
					NotificationController:Success(typeof(v3) ~= "string" and "Code redeemed!" or v3)
				end
			else
				NotificationController:Error(typeof(v3) ~= "string" and "Request failed" or v3)
			end
		else
			NotificationController:Error("Unexpected error")
			warn(result)
		end

		textBox.Text = ""
		textBox.PlaceholderText = "Code Here..."
		task.wait(0.5)
		textBox.Selectable = true
		textBox.Active = true
		v2 = false
	end

	textBox.FocusLost:Connect(function(flag: boolean)
		if not flag then
			return
		end

		submitCode()
	end)

	if confirm then
		local v3 = AnimatedButton.new(confirm)
		v3:Animate()
		v3.OnActivated:Connect(submitCode)
	end

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text
		local text2 = string.sub(string.gsub(text, "[^%w]", ""), 1, 50)

		if text2 ~= text then
			textBox.Text = text2
		end
	end)
end

return {
	Start = function(_)
		v = InterfaceController:Register("Codes", codes, "TopQuint")
		v:AttachCloseButton(codes.Header.Close)
		v:Close()
		initTextbox(codes.CodeRedeem.TextBox, codes.Confirm)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateEnabled()
			local visible = CodesFlags.Enabled:Get() and not isTradePlaza
			codes2.Visible = visible

			if not visible and v:IsOpened() then
				InterfaceController:Toggle("Codes", false)
			end
		end

		updateEnabled() -- equivalent call inferred; original call site unknown
		CodesFlags.Enabled.Changed:Connect(updateEnabled)
	end
}