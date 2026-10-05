local RunService = game:GetService("RunService")
local Spritesheetplayer = {}
local class = {}
class.__index = class

function class:GetUI()
	if self.UI ~= nil then
		return self.UI
	end

	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.ClipsDescendants = true
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = self.Parent
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Image"
	imageLabel.Image = self.Source
	imageLabel.Size = UDim2.fromScale(self.GridSize[1], self.GridSize[2])
	imageLabel.Parent = frame
	imageLabel.BackgroundTransparency = 1
	self.UI = frame
	return frame
end

function class:Play(value: number?)
	local image = self:GetUI():FindFirstChild("Image")

	if image == nil then
		return
	end

	local v = self.TotalFrames - (value or 0)
	self:Pause()
	local total = 0
	self.Progress = self.Progress or 0
	self.render = RunService.RenderStepped:Connect(function(dt: number)
		if image.Parent == nil then
			self:Pause()
			return
		end

		total += dt

		if total >= self.FrameDuration then
			total = 0
			local v2 = self.Progress % self.GridSize[1]
			local v3 = math.floor(self.Progress / self.GridSize[1])
			image.Position = UDim2.fromScale(-v2, -v3)
			self.Progress += 1

			if v <= self.Progress then
				self:Pause()
			end
		end
	end)
end

function class:PlayBackwards(value: number?)
	local image = self:GetUI():FindFirstChild("Image")

	if image == nil then
		return
	end

	local progress = value or 0
	self:Pause()
	local total = 0
	self.Progress = self.Progress or 0
	self.render = RunService.RenderStepped:Connect(function(dt: number)
		if image.Parent == nil then
			self:Pause()
			return
		end

		total += dt

		if total >= self.FrameDuration then
			total = 0
			local v2 = self.Progress % self.GridSize[1]
			local v3 = math.floor(self.Progress / self.GridSize[1])
			image.Position = UDim2.fromScale(-v2, -v3)
			self.Progress -= 1

			if self.Progress <= progress then
				self.Progress = progress
				self:Pause()
			end
		end
	end)
end

function class:Pause(flag: boolean)
	if self.render ~= nil then
		self.render:Disconnect()
		self.render = nil
	end

	if flag then
		self.Progress = nil
	end
end

function class:Stop()
	self:Pause(true)
end

function class:To(p)
	local image = self:GetUI():FindFirstChild("Image")

	if image == nil then
		return self
	end

	self.Progress = p - 1
	local v = self.Progress % self.GridSize[1]
	local v2 = math.floor(self.Progress / self.GridSize[1])
	image.Position = UDim2.fromScale(-v, -v2)
	return self
end

function class:Destroy()
	self:Stop()

	if self.UI ~= nil then
		self.UI:Destroy()
		self.UI = nil
	end

	setmetatable(self, nil)
end

function Spritesheetplayer.new(gridSize, source: string, parent, value: number?)
	if gridSize == nil or source == nil or parent == nil then
		return
	else
		return (setmetatable({
			GridSize = gridSize,
			Parent = parent,
			FrameDuration = 1 / (value or 30),
			Source = source,
			TotalFrames = gridSize[1] * gridSize[2]
		}, class))
	end
end

return Spritesheetplayer