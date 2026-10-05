local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseRobberyPanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local _1Player1sHous1e = ReplicatedStorage.RE:WaitForChild("1Player1sHous1e")
	self.dbRobberyClose = false
	self._Janitor:Add(_1Player1sHous1e.OnClientEvent:Connect(function(p, text)
		if p == "HouseOwnerGiveRobberName" then
			local robberName = self.Instance:WaitForChild("Buttons"):WaitForChild("Folder"):WaitForChild("RobberName")
			robberName.Text = text
			self.Instance.Visible = true
		end
	end))
	self._Janitor:Add(self.Instance:WaitForChild("Buttons"):WaitForChild("Folder"):WaitForChild("Close").MouseButton1Down:connect(function()
		if self.dbRobberyClose == false then
			self.dbRobberyClose = true
			task.delay(0.5, function()
				self.dbRobberyClose = false
			end)
			self.Instance.Visible = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v