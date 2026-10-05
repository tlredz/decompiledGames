local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(game.ReplicatedStorage.Shared.Policy)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(script.Parent.TopBarController)
local codeGUI = Players.LocalPlayer.PlayerGui:WaitForChild("codeGUI")
local frame = codeGUI.Frame
local CodesController = {}

function CodesController:Toggle(p)
	if p then
		v3:Open("codeGUI")
	else
		v3:Close("codeGUI")
	end
end

function CodesController:Start()
	local v5 = 0
	local textBox = frame.TextBox
	local textColor3 = textBox.TextColor3
	local v6 = v4:Create("Icons"):setImage(14523325483):setLabel("CODES")
	v4:AddDropdown("Extra", v6)
	v6.toggled:Connect(function(flag: boolean, p)
		if p ~= "User" then
			return
		end

		self:Toggle(flag)
	end)
	v3:OnClose(function(p)
		if p == codeGUI then
			v6:deselect()
		end
	end)
	frame.ImageButton.Activated:Connect(function()
		local now = os.clock()

		if now - v5 < 2 then
			return
		end

		v5 = now
		local v7 = v:Invoke("RedeemCode", textBox.Text)

		if v7 == "invalid" then
			textBox.Text = "Invalid code!"
			textBox.TextColor3 = Color3.new(1, 0.298039, 0.298039)
		elseif v7 == "already claimed" then
			textBox.Text = "Already claimed!"
			textBox.TextColor3 = Color3.new(1, 0.298039, 0.298039)
		elseif v7 == "succesful" then
			textBox.Text = "Successfully claimed!"
			textBox.TextColor3 = Color3.new(0.54902, 1, 0.564706)
		elseif v7 == "EXPIRED" then
			textBox.Text = "Expired!"
			textBox.TextColor3 = Color3.new(1, 0.298039, 0.298039)
		elseif string.match(v7, "@Message:(.*)") then
			frame.TextBox.Text = string.match(v7, "@Message:(.*)")
			frame.TextBox.TextColor3 = Color3.new(1, 0.298039, 0.298039)
		end
	end)
	textBox.Focused:Connect(function()
		textBox.TextColor3 = textColor3
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reflectPolicy()
		local policyInfo = v2:GetPolicyInfo()
		local index = table.find(policyInfo.AllowedExternalLinkReferences, "YouTube")
		frame.TwitterFrame.Visible = index
	end

	reflectPolicy() -- equivalent call inferred; original call site unknown
	v2.PolicyInfoAdded:Connect(reflectPolicy)
	frame.CloseButton.Activated:Connect(function()
		v3:Close("codeGUI")
	end)
end

return CodesController