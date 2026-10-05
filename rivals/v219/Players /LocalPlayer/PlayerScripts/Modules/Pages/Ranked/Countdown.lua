local Players = game:GetService("Players")
local SeasonController = require(Players.LocalPlayer.PlayerScripts.Controllers.SeasonController)
local Countdown = {}
Countdown.__index = Countdown

function Countdown.new(page)
	local self = setmetatable({}, Countdown)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Countdown")
	self.Title = self.Frame:WaitForChild("Title")
	self._thread = nil
	self:_Init()
	return self
end

function Countdown:Open()
	self:_Update()
end

function Countdown:Close()
	self:_Cleanup()
end

function Countdown:_Cleanup()
	if self._thread then
		task.cancel(self._thread)
		self._thread = nil
	end
end

function Countdown:_Update()
	self.Frame.Visible = SeasonController:GetTimeRemaining() ~= nil

	if not self.Frame.Visible then
		return
	end

	self:_Cleanup()
	self._thread = task.spawn(function()
		while true do
			self.Title.Text = SeasonController:GetCountdownText() .. " — Your final ELO determines your Ranked season rewards!"
			wait(1)
		end
	end)
end

function Countdown:_Init() end

return Countdown