local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local remoteFunction = Net:RemoteFunction("QAWelcome", 1e999)
local parent = script.Parent
local prompt = parent:WaitForChild("prompt")
local deny = prompt:WaitForChild("deny")
local confirm = prompt:WaitForChild("confirm")

local function handlePrompt()
	prompt.Visible = true
	parent.Enabled = true
	local v = false
	confirm.Activated:Once(function()
		v = true
		parent.Enabled = false
	end)
	deny.Activated:Once(function()
		v = false
		parent.Enabled = false
	end)
	parent:GetPropertyChangedSignal("Enabled"):Wait()
	return v
end

remoteFunction.OnClientInvoke = handlePrompt