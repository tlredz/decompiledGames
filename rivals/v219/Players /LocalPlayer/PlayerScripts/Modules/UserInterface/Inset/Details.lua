local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MatchmakingController"))
local Details = {}
Details.__index = Details

function Details.new(inset)
	local self = setmetatable({}, Details)
	self.Inset = inset
	self.LeftFrame = self.Inset.LeftButtonsFrame:WaitForChild("Details")
	self.LeftContainer = self.LeftFrame:WaitForChild("Container")
	self.LeftServerRegionFrame = self.LeftContainer:WaitForChild("ServerRegion")
	self.LeftServerRegionTitle = self.LeftServerRegionFrame:WaitForChild("Title")
	self.LeftConnectionFrame = self.LeftContainer:WaitForChild("Connection")
	self.LeftConnectionTitle = self.LeftConnectionFrame:WaitForChild("Title")
	self.LeftConnectionIcon = self.LeftConnectionFrame:WaitForChild("Icon")
	self.RightFrame = self.Inset.RightButtonsFrame:WaitForChild("Details")
	self.RightContainer = self.RightFrame:WaitForChild("Container")
	self.RightServerRegionFrame = self.RightContainer:WaitForChild("ServerRegion")
	self.RightServerRegionTitle = self.RightServerRegionFrame:WaitForChild("Title")
	self.RightConnectionFrame = self.RightContainer:WaitForChild("Connection")
	self.RightConnectionTitle = self.RightConnectionFrame:WaitForChild("Title")
	self.RightConnectionIcon = self.RightConnectionFrame:WaitForChild("Icon")
	self._dt_history = {}
	self:_Init()
	return self
end

function Details.SetVisible(p, p2)
	p.LeftFrame.Visible = p2 and false
	p.RightFrame.Visible = p2 and true
end

function Details:_UpdateServerRegion()
	self.LeftServerRegionTitle.Text = MatchmakingController:Get("ServerRegion") or "• • •"
	self.RightServerRegionTitle.Text = self.LeftServerRegionTitle.Text
end

function Details:_UpdateTextBounds()
	self.LeftFrame.Size = UDim2.new(
		1.25,
		math.max(self.LeftServerRegionTitle.TextBounds.X, self.LeftConnectionTitle.TextBounds.X),
		1,
		0
	)
	self.RightFrame.Size = UDim2.new(
		1.25,
		math.max(self.RightServerRegionTitle.TextBounds.X, self.RightConnectionTitle.TextBounds.X),
		1,
		0
	)
end

function Details:_GetFramerate()
	table.insert(self._dt_history, 1, RunService.RenderStepped:Wait())
	table.remove(self._dt_history, 11)
	local total = 0

	for _, v in pairs(self._dt_history) do
		total += v
	end

	return (math.floor(1 / (total / #self._dt_history)))
end

function Details:_UpdateConnectionLoop()
	while true do
		local localConnectionPing = Utility:GetLocalConnectionPing()
		local connectionLevelIcon = Utility:GetConnectionLevelIcon((Utility:GetConnectionLevel(localConnectionPing)))
		local _GetFramerate = self:_GetFramerate()
		self.LeftConnectionTitle.Text = _GetFramerate .. "fps   " .. localConnectionPing .. "ms"
		self.LeftConnectionIcon.Image = connectionLevelIcon or ""
		self.RightConnectionTitle.Text = self.LeftConnectionTitle.Text
		self.RightConnectionIcon.Image = self.LeftConnectionIcon.Image
		wait(0.25)
	end
end

function Details:_Init()
	self.LeftServerRegionTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	self.RightServerRegionTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	self.LeftConnectionTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	self.RightConnectionTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	MatchmakingController:GetDataChangedSignal("ServerRegion"):Connect(function()
		self:_UpdateServerRegion()
	end)
	self:_UpdateServerRegion()
	task.defer(self._UpdateConnectionLoop, self)
end

return Details