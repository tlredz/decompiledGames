local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PSConfirmationPanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local yes = self.Instance:WaitForChild("Yes")
	local no = self.Instance:WaitForChild("No")
	self._Janitor:Add(yes.Activated:Connect(function()
		self.Instance.Visible = false
		self.callback(true)
	end))
	self._Janitor:Add(no.Activated:Connect(function()
		self.Instance.Visible = false
		self.callback(false)
	end))
	self.message = self.Instance:WaitForChild("Message")
end

function v:Init(text: string, callback)
	self.message.Text = text
	self.callback = callback
	self.Instance.Visible = true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v