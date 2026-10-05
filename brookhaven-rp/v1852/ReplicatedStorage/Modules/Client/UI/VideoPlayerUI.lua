local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VideoPlayerUI"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.playingDebounce = false
	self.button = self.Instance:WaitForChild("PlayButton", 10)
	self.videoFrame = self.Instance:WaitForChild("VideoFrame", 10)
	self.imageButton = self.Instance:WaitForChild("ImageButton", 10)
	self.playIcon = self.Instance:WaitForChild("PlayIcon", 10)
end

function v:Start()
	if self.Instance.Parent == nil then
		return
	end

	local isLoaded = false
	self._Janitor:Add(self.button.Activated:Connect(function()
		isLoaded = self.videoFrame.IsLoaded

		if isLoaded and self.videoFrame.Playing then
			self.videoFrame:Pause()
			self.playIcon.Visible = true
		elseif isLoaded and not self.videoFrame.Playing and self.videoFrame.IsLoaded then
			self.videoFrame:Play()
			self.playIcon.Visible = false
		else
			isLoaded = true
			self.imageButton.Visible = false
			self.playIcon.Visible = false
			self.videoFrame.Visible = true
			local isLoaded2 = self.videoFrame.IsLoaded

			if not isLoaded2 then
				self.videoFrame.Loaded:Once(function()
					isLoaded2 = true
				end)
			end

			self.videoFrame:Play()
			task.wait(5)

			if not isLoaded2 then
				self.videoFrame.Visible = false
				self.playIcon.Visible = false
				self.imageButton.Visible = true
				self.videoFrame:Pause()
				self.videoFrame.Video = ""
				isLoaded = false
			end
		end
	end))
	self._Janitor:Add(self.videoFrame.Ended:Connect(function()
		task.wait(1)
		self.playIcon.Visible = true
		self.videoFrame:Pause()
		self.videoFrame.TimePosition = 0
	end))
	self.videoFrame:GetPropertyChangedSignal("Video"):Connect(function()
		if self.videoFrame.Video == nil or self.videoFrame.Video == "" then
			return
		end

		local autoplay = self.Instance:GetAttribute("Autoplay")
		self.videoFrame.Playing = autoplay
		self.playIcon.Visible = not autoplay
		self.imageButton.Visible = not autoplay
		self.videoFrame.Visible = autoplay
	end)

	if self.videoFrame.Video ~= nil and self.videoFrame.Video ~= "" then
		local autoplay = self.Instance:GetAttribute("Autoplay")
		self.videoFrame.Playing = autoplay
		self.playIcon.Visible = not autoplay
		self.imageButton.Visible = not autoplay
		self.videoFrame.Visible = autoplay
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v