local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local FPSTracker = {
	FPS = 0,
	Frames = 0,
	Counter = 0,
	Update = function(self, p)
		self.Frames += p
		self.Counter += 1

		if self.Counter == 30 then
			self.FPS = self.Counter / self.Frames
			self.Counter = 0
			self.Frames = 0
		end
	end
}
local RunService = game:GetService("RunService")

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local RunService2 = game:GetService("RunService")
	RunService2.Heartbeat:connect(function(p)
		FPSTracker:Update(p)
	end)
end

return FPSTracker