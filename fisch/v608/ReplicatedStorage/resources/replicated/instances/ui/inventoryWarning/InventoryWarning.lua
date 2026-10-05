local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local remoteFunction = Net:RemoteFunction("InventoryWarning", 1e999)
local parent = script.Parent
local prompt = parent:WaitForChild("prompt")
local question = prompt:WaitForChild("question")
local deny = prompt:WaitForChild("deny")
local confirm = prompt:WaitForChild("confirm")

local function handlePrompt(text: string, p: string?)
	question.Text = text
	prompt.Visible = true
	parent.Enabled = true
	local v = false
	confirm.Activated:Once(function()
		v = true
		parent.Enabled = false
	end)
	deny.Activated:Once(function()
		if p then
			question.Text ..= `\n\n<font color='#ff4141'><b>{p}</b></font>`
			deny.Activated:Wait()
		end

		v = false
		parent.Enabled = false
	end)
	parent:GetPropertyChangedSignal("Enabled"):Wait()
	return v
end

remoteFunction.OnClientInvoke = handlePrompt