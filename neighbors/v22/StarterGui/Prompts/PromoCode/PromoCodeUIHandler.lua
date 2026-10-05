local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local parent = script.Parent
local code = parent.Code
local submit = parent.Submit
local close = parent.Close
local Network = require(ReplicatedStorage.Modules.Network)
local UI = require(ReplicatedStorage.Modules.UI)
UI:Bind(submit)
UI:Bind(close)

-- equivalent calls inferred from this helper; original call sites unknown
local function SubmitCode()
	local text = code.Text
	code.Text = ""

	if text == "" then
		return
	end

	print((`Activating Promo Code {text}`))
	Network:fire("ActivatePromoCode", text)
end

code:GetPropertyChangedSignal("Text"):Connect(function()
	if not UserInputService.TouchEnabled then
		code.Text = code.Text:upper()
		code.Text = code.Text:gsub("%s+", "")
	end
end)
code.FocusLost:Connect(function(flag: boolean)
	if flag then
		SubmitCode() -- equivalent call inferred; original call site unknown
	end
end)
submit.MouseButton1Click:Connect(SubmitCode)
close.MouseButton1Click:Connect(function()
	parent.Visible = false
end)
code:GetPropertyChangedSignal("Text"):connect(function()
	if #code.Text > 22 then
		code.Text = code.Text:sub(1, 22)
	end
end)

while not _G.Policy do
	task.wait()
end

local allowedExternalLinkReferences = _G.Policy.AllowedExternalLinkReferences or {}

if table.find(allowedExternalLinkReferences, "Discord") then
	script.Parent.Description.Text = "Join our Discord (discord.gg/westcorner) for codes!"
end