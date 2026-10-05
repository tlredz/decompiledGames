local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TextlabelRainbowEffect"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("TextLabel") then
		return
	end

	self.gradient = Instance.new("UIGradient")
	self.gradient.Parent = instance
	self.enabled = true
	task.defer(function()
		while self.enabled do
			local time = instance:GetAttribute("Time")
			local range = instance:GetAttribute("Range")

			if not (time and range) then
				break
			end

			local v2 = tick() % time / time
			local colorSequenceKeypoints = {}

			for i = 1, range + 1 do
				local color = Color3.fromHSV(v2 - (i - 1) / range, 1, 1)

				if v2 - (i - 1) / range < 0 then
					color = Color3.fromHSV(v2 - (i - 1) / range + 1, 1, 1)
				end

				table.insert(colorSequenceKeypoints, (ColorSequenceKeypoint.new((i - 1) / range, color)))
			end

			self.gradient.Color = ColorSequence.new(colorSequenceKeypoints)
			task.wait(0.1)
		end
	end)
end

function v:Stop()
	self.enabled = nil
	self.gradient:Destroy()
	self._Janitor:Destroy()
end

return v