local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseWriteLetter"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._debounceEnter = false
	self._currentMailBoxNumber = nil
end

function v:Start()
	local localPlayer = game.Players.LocalPlayer

	if not localPlayer then
		return
	end

	local game8Settings = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local maxy = module.Maxy
	local instance = self.Instance
	local C = instance:WaitForChild("A"):WaitForChild("B"):WaitForChild("C")
	local close = C:WaitForChild("Close")
	local D = C:WaitForChild("D")
	self._Janitor:Add(close.MouseButton1Click:Connect(function()
		instance.Visible = false
		self._currentMailBoxNumber = nil
	end))
	self._Janitor:Add(D.FocusLost:Connect(function()
		if not self._debounceEnter and self._currentMailBoxNumber ~= nil and instance.Visible then
			self._debounceEnter = true
			local text = D.Text
			maxy:FireServer("ReturningMailBoxLetter", self._currentMailBoxNumber, text)
			D.Text = ""
			instance.Visible = false
			task.wait(0.5)
			self._debounceEnter = false
			self._currentMailBoxNumber = nil
		end
	end))
	self._Janitor:Add(maxy.OnClientEvent:Connect(function(p, currentMailBoxNumber)
		if p == "MailBoxEmptyOpenPaper" then
			self._currentMailBoxNumber = currentMailBoxNumber
			instance.Visible = true
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v