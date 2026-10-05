local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local VideoPlayerConfig = require(ReplicatedStorage.Modules.Shared.DB.VideoPlayer.VideoPlayerConfig)
local v = Component.new({
	Tag = "VideoPlayer"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.playingDebounce = false
	self._surfaceGuiName = self.Instance:GetAttribute("SurfaceGuiName") or "SurfaceGui"
	self.currentVideoTimePosition = 0
	self._overlapParams = OverlapParams.new()
	self._overlapParams.FilterType = Enum.RaycastFilterType.Include
	self._inArea = false
end

function v.GetVideoId(p)
	local videoConfigKey = p.Instance:GetAttribute("VideoConfigKey")

	if typeof(videoConfigKey) == "string" and videoConfigKey ~= "" then
		local videoId = VideoPlayerConfig.GetVideoId(videoConfigKey)

		if videoId ~= nil then
			return videoId
		end

		warn((`VideoPlayer: VideoConfigKey "{videoConfigKey}" not found in remote config`))
	end

	local videoId = p.Instance:GetAttribute("VideoId")

	if typeof(videoId) == "string" and videoId ~= "" then
		return videoId
	end

	return nil
end

function v:ProcessToggle()
	local child = self.Instance:WaitForChild(self._surfaceGuiName)
	local videoFrame = child:WaitForChild("VideoFrame")
	local imageButton = child:WaitForChild("ImageButton")
	local playIcon = child:WaitForChild("PlayIcon")
	self.isInitiallyLoaded = videoFrame.IsLoaded

	if self.isInitiallyLoaded and videoFrame.Playing then
		if self.Instance:GetAttribute("PreventPause") == true then
			return
		end

		videoFrame:Pause()
		playIcon.Visible = true
	elseif self.isInitiallyLoaded and not videoFrame.Playing and videoFrame.IsLoaded then
		videoFrame:Play()
		playIcon.Visible = false

		if self.currentVideoTimePosition > 0 then
			videoFrame.TimePosition = self.currentVideoTimePosition
		end
	else
		self.isInitiallyLoaded = true
		local isLoaded = videoFrame.IsLoaded

		if isLoaded then
			imageButton.Visible = false
			playIcon.Visible = false
			videoFrame.Visible = true
		else
			videoFrame.Loaded:Once(function()
				imageButton.Visible = false
				playIcon.Visible = false
				videoFrame.Visible = true
				isLoaded = true

				if self.currentVideoTimePosition > 0 then
					videoFrame.TimePosition = self.currentVideoTimePosition
				end
			end)
		end

		videoFrame.Video = self:GetVideoId()
		videoFrame:Play()

		if self.currentVideoTimePosition > 0 then
			videoFrame.TimePosition = self.currentVideoTimePosition
		end

		task.wait(5)

		if not isLoaded then
			self:Unload()
		end
	end
end

function v:Unload()
	local child = self.Instance:WaitForChild(self._surfaceGuiName)
	local videoFrame = child:WaitForChild("VideoFrame")
	local imageButton = child:WaitForChild("ImageButton")
	local playIcon = child:WaitForChild("PlayIcon")
	videoFrame.Visible = false
	playIcon.Visible = false
	imageButton.Visible = true
	self.currentVideoTimePosition = videoFrame.TimePosition
	videoFrame:Pause()
	videoFrame.Video = ""
	self.isInitiallyLoaded = false
end

function v:Start()
	local clickDetector = self.Instance:WaitForChild("ClickDetector")
	local videoFrame = self.Instance:WaitForChild(self._surfaceGuiName):WaitForChild("VideoFrame")
	local playRegion = self.Instance:WaitForChild("PlayRegion")

	if self.Instance:GetAttribute("MuteDuringIntro") then
		local volume = videoFrame.Volume
		videoFrame.Volume = 0
		self._Janitor:Add(IntroController.OnPlayButtonPressed:Connect(function()
			videoFrame.Volume = volume
		end))
	end

	self._Janitor:Add(clickDetector.MouseClick:Connect(function()
		self:ProcessToggle()
	end))

	if not videoFrame.Looped then
		self._Janitor:Add(videoFrame.Ended:Connect(function()
			task.wait(4)
			self:Unload()
		end))
	end

	self._Janitor:Add(playRegion.Touched:Connect(function(otherPart)
		local character = Players.LocalPlayer.Character

		if not (character and otherPart == character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		self:CheckInArea()
	end))
	self._Janitor:Add(playRegion.TouchEnded:Connect(function(otherPart)
		local character = Players.LocalPlayer.Character

		if not (character and otherPart == character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		self:CheckInArea()
	end))
end

function v:CheckInArea()
	local videoFrame = self.Instance:WaitForChild(self._surfaceGuiName):WaitForChild("VideoFrame")
	local playRegion = self.Instance:WaitForChild("PlayRegion")
	local filterDescendantsInstances = { (Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")) }
	self._overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	local inArea = #workspace:GetPartsInPart(playRegion, self._overlapParams) > 0

	if inArea == self._inArea then
		return
	end

	self._inArea = inArea

	if inArea and not videoFrame.Playing then
		self:ProcessToggle()
	elseif not inArea then
		self:Unload()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v