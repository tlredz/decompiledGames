local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local remoteFunction = Net:RemoteFunction("ConfirmPrompt", 1e999)
local parent = script.Parent
local title = parent:WaitForChild("title")
local question = parent:WaitForChild("question")
local warning = parent:WaitForChild("warning")
local deny = parent:WaitForChild("deny")
local confirm = parent:WaitForChild("confirm")
local maid = Trove.new()

local function handlePrompt(text: string, text2: string, value: string?)
	maid:Clean()

	if parent.Visible then
		parent.Visible = false
		task.wait()
	end

	title.Text = text
	question.Text = text2
	warning.Text = value or ""
	parent.Visible = true
	local v = false
	maid:Add(confirm.Activated:Once(function()
		v = true
		parent.Visible = false
	end))
	maid:Add(deny.Activated:Once(function()
		v = false
		parent.Visible = false
	end))
	parent:GetPropertyChangedSignal("Visible"):Wait()
	maid:Clean()
	return v
end

remoteFunction.OnClientInvoke = handlePrompt
local confirmPrompt = ReplicatedStorage:WaitForChild("events"):WaitForChild("ConfirmPrompt")
confirmPrompt.OnInvoke = handlePrompt