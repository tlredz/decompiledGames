local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
require(ReplicatedStorage.Modules.Client.Music.MusicContext)
local MusicNavigationUtil = require(ReplicatedStorage.Modules.Client.Music.MusicNavigationUtil)
local MusicsConfig = require(ReplicatedStorage.Modules.Shared.DB.Musics.MusicsConfig)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "MainAudioNew"
})
local color = Color3.fromHex("#0D76BB")
local color2 = Color3.fromHex("#FFFFFF")
local color3 = Color3.fromHex("#FFFFFF")
local color4 = Color3.fromHex("#BBBBBB")

function v:Construct()
	self._Janitor = Janitor.new()
	self._gridLayoutJanitor = Janitor.new()
	self.menuContainer = self.Instance:WaitForChild("Catalog")
	local container = self.menuContainer:WaitForChild("Container")
	self.noFilterResults = container:WaitForChild("NoResults")
	self.scrollingFrame = container:WaitForChild("ScrollingFrame")
	self.freeSongsWickedFrame = self.scrollingFrame:WaitForChild("FreeSongsWicked")
	self.freeSongsEdSheeranFrame = self.scrollingFrame:WaitForChild("FreeSongsEdSheeran")
	self.songsFrame = self.scrollingFrame:WaitForChild("Songs")
	self.songsGridLayout = self.songsFrame:WaitForChild("UIGridLayout")
	self.dividerWicked = self.scrollingFrame:WaitForChild("DividerWicked")
	self.dividerEdSheeran = self.scrollingFrame:WaitForChild("DividerEdSheeran")
	local header = self.menuContainer:WaitForChild("Header")
	self.header = header
	self.volumeContainer = header:WaitForChild("VolumeContainer")
	self.musicFilterContainer = header:WaitForChild("MusicFilterContainer")
	self.textFilter = self.musicFilterContainer:WaitForChild("TextArea"):WaitForChild("TextFilter")
	local title = header:WaitForChild("Title")
	self.closeButton = title:WaitForChild("Close")
	local background = title:WaitForChild("Background")
	self.songName = background:WaitForChild("SongName")
	self.selectText = background:WaitForChild("SelectASongText")
	local buttonsList = header:WaitForChild("ButtonsList")
	self.playButton = buttonsList:WaitForChild("PausePlay")
	self.previousButton = buttonsList:WaitForChild("Previous")
	self.nextButton = buttonsList:WaitForChild("Next")
	self.volumeButton = buttonsList:WaitForChild("Volume")
	self.volumeIcon = self.volumeButton:WaitForChild("VolumeIcon")
	self.searchButton = buttonsList:WaitForChild("Search")
	self.searchIcon = self.searchButton:WaitForChild("SearchIcon")
	self:SetVolumeVisibility(false)
	self:SetSearchVisibility(false)
	self.noFilterResults.Visible = false
	self.freeSongsWickedFrame.Visible = true
	self.freeSongsEdSheeranFrame.Visible = true
	self.dividerWicked.Visible = true
	self.dividerEdSheeran.Visible = true
	self.lastFilter = ""
	self.dbAudioPlayerClose = false
	self.closeCalled = nil
	self._unbindMusicButtonsBackAction = nil
end

function v:IsMusicButtonSelected()
	local selectedObject = GuiService.SelectedObject

	if selectedObject and selectedObject.Parent and selectedObject:IsA("ImageButton") then
		return selectedObject:IsDescendantOf(self.songsFrame) or selectedObject:IsDescendantOf(self.freeSongsWickedFrame) or selectedObject:IsDescendantOf(self.freeSongsEdSheeranFrame)
	end

	return false
end

function v:BindMusicButtonsBackAction()
	if self._unbindMusicButtonsBackAction then
		return
	end

	self._unbindMusicButtonsBackAction = BackActionRouter.Bind(function()
		Platform.Select(self.header)
	end, function()
		return self.Instance.Visible and self:IsMusicButtonSelected()
	end)
end

function v:UnbindMusicButtonsBackAction()
	if not self._unbindMusicButtonsBackAction then
		return
	end

	self._unbindMusicButtonsBackAction()
	self._unbindMusicButtonsBackAction = nil
end

function v:MovePanelUp(flag: boolean)
	self.menuContainer.Position = UDim2.new(0.5, 0, flag and 0.6 or 1, 0)
end

function v:SetVolumeVisibility(visible: boolean)
	self.volumeContainer.Visible = visible
	self.volumeButton.ImageColor3 = visible and color3 or color
	self.volumeIcon.ImageColor3 = visible and color4 or color2
end

function v:SetSearchVisibility(visible: boolean)
	self.musicFilterContainer.Visible = visible
	self.searchButton.ImageColor3 = visible and color3 or color
	self.searchIcon.ImageColor3 = visible and color4 or color2
end

function v:SetContext(context)
	self._Janitor:Remove("Context")
	self.context = context
	local maid = Janitor.new()
	self._Janitor:Add(maid, nil, "Context")

	local function update()
		local status = context:GetStatus()
		self.Instance.Catalog.Header.ButtonsList.PausePlay.Image = status.isPlaying and "rbxassetid://114212393771017" or "rbxassetid://118117426385847"
		self.Instance.Catalog.Header.VolumeContainer.Slider.SliderText.Text = status.volume
		local fillArea = self.Instance.Catalog.Header.VolumeContainer.Slider.FillArea
		fillArea.Size = UDim2.new(status.volume / 100, 0, fillArea.Size.Y.Scale, fillArea.Size.Y.Offset)
		self.Instance.Catalog.Header.Title.Background.SongName.Text = status.track or ""
		self.Instance.Catalog.Header.Title.Background.SongName.ID.Value = status.trackId or 0

		if self._lastCheckedButton then
			self._lastCheckedButton.GreenCheckMark.Visible = false
		end

		local lastCheckedButton = status.trackId and self._musicButtons and self._musicButtons[status.trackId]

		if lastCheckedButton then
			lastCheckedButton.GreenCheckMark.Visible = true
			self._lastCheckedButton = lastCheckedButton
		end
	end

	maid:Add(context:OnStatusUpdate():Connect(update))
	update()
end

function v:Start()
	local songsGridLayout = self.songsGridLayout
	self._Janitor:Add(self.textFilter.Focused:Connect(function()
		if Platform.IsMobile() then
			self:MovePanelUp(true)
		end
	end))
	self._Janitor:Add(self.textFilter.FocusLost:Connect(function(_)
		self:MovePanelUp(false)
	end))
	self._Janitor:Add(self.textFilter:GetPropertyChangedSignal("Text"):Connect(function()
		self:FilterText()
	end))
	self._Janitor:Add(self.closeButton.MouseButton1Click:Connect(function()
		self:CloseButtonPressed()
	end))
	self._Janitor:Add(self.volumeButton.MouseButton1Click:Connect(function()
		self:SetVolumeVisibility(not self.volumeContainer.Visible)
	end))
	self._Janitor:Add(self.searchButton.MouseButton1Click:Connect(function()
		self:SetSearchVisibility(not self.musicFilterContainer.Visible)

		if self.musicFilterContainer.Visible then
			self.textFilter:CaptureFocus()
		end
	end))
	self._Janitor:Add(self.songName:GetPropertyChangedSignal("Text"):Connect(function()
		self.selectText.Visible = self.songName.Text == ""
	end))
	self._Janitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function()
		if not self.Instance.Visible then
			return
		end

		self:CloseButtonPressed()
	end))
	self._Janitor:Add(Remotes.connect("PrivateServerMuteAllChanged", function(flag: boolean)
		if flag == true then
			self.playButton.Image = "rbxassetid://118117426385847"
		end
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible == false then
			self._gridLayoutJanitor:Cleanup()
			self:UnbindMusicButtonsBackAction()
			self:ResetPanel()
		else
			self._gridLayoutJanitor:Add(songsGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, songsGridLayout.AbsoluteContentSize.Y + 100)
			end))
			self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, songsGridLayout.AbsoluteContentSize.Y + 100)
			self:BindMusicButtonsBackAction()
		end
	end))
	local config = MusicsConfig.GetConfig()
	local scrollingFrame = self.Instance.Catalog.Container.ScrollingFrame
	local freeSongsWicked = scrollingFrame:FindFirstChild("FreeSongsWicked")
	local freeSongsEdSheeran = scrollingFrame:FindFirstChild("FreeSongsEdSheeran")
	local songs = scrollingFrame:FindFirstChild("Songs")
	local musicTemplateButton = scrollingFrame:FindFirstChild("MusicTemplateButton")
	local color5 = Color3.fromHex("#008E1C")
	local color6 = Color3.fromHex("#000000")
	self._lastCheckedButton = nil
	self._musicButtons = {}

	if musicTemplateButton ~= nil then
		musicTemplateButton.Parent = nil

		for k, v2 in config do
			if v2.FreeCategory == "EdSheeran2025" then
				continue
			end

			local clone = musicTemplateButton:Clone()
			clone.Name = string.format("%03d_%s", k, v2.SongName)
			clone.Title.Text = v2.SongName
			clone.ID.Value = v2.AssetID
			clone.LayoutOrder = v2.LayoutOrder
			clone.Title.TextColor3 = v2.New and color5 or color6
			clone.BackgroundTransparency = v2.New and 0.1 or 0.36

			if v2.Icon then
				clone.Icon.Image = v2.Icon
				clone.Icon.Visible = true
			else
				clone.Icon.Visible = false
			end

			if v2.IconSize ~= nil then
				local iconSize = v2.IconSize
				clone.Icon.Size = UDim2.new(iconSize.X, 0, iconSize.Y, 0)
			end

			local titleSize = v2.TitleSize

			if titleSize == nil and v2.titleSize ~= nil then
				titleSize = v2.titleSize
			end

			if titleSize ~= nil then
				clone.Title.Size = UDim2.new(titleSize.X, 0, titleSize.Y, 0)
			end

			clone.Parent = songs
			self._musicButtons[v2.AssetID] = clone
		end
	end

	local count = 0

	for _, button in freeSongsWicked:GetChildren() do
		if button:IsA("ImageButton") then
			count += 1
		end
	end

	local count2 = 0

	for _, button in freeSongsEdSheeran:GetChildren() do
		if button:IsA("ImageButton") then
			count2 += 1
		end
	end

	if count <= 0 then
		freeSongsWicked.Visible = false
		local dividerWicked = scrollingFrame:FindFirstChild("DividerWicked")

		if dividerWicked then
			dividerWicked.Visible = false
		end
	end

	if count2 <= 0 then
		freeSongsEdSheeran.Visible = false
		local dividerEdSheeran = scrollingFrame:FindFirstChild("DividerEdSheeran")

		if dividerEdSheeran then
			dividerEdSheeran.Visible = false
		end
	end

	if not musicTemplateButton then
		for _, v2 in { songs, freeSongsWicked, freeSongsEdSheeran } do
			for _, button in v2:GetChildren() do
				if not button:IsA("ImageButton") then
					continue
				end

				button.GreenCheckMark.Visible = false
				self._musicButtons[tonumber(button.ID.Value)] = button
			end
		end

		self._lastCheckedButton = nil
	end

	local flag = false

	for _, button in self._musicButtons do
		if not button:IsA("ImageButton") then
			continue
		end

		local v2 = button
		self._Janitor:Add(button.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			local ID = v2:FindFirstChild("ID")

			if ID then
				self.context:Select((tonumber(ID.Value)))
			end

			task.wait(1)
			flag = false
		end))
	end

	local sliderText = self.Instance.Catalog.Header.VolumeContainer.Slider.SliderText
	self._Janitor:Add(sliderText.FocusLost:Connect(function(p)
		local context = self.context

		if not p then
			sliderText.Text = tostring(context:GetStatus().volume)
			return
		end

		local text = tonumber(sliderText.Text)

		if text and text >= 0 and text <= 100 then
			context:Volume(text)
		else
			sliderText.Text = tostring(context:GetStatus().volume)
		end
	end))
	self._Janitor:Add(self.Instance.Catalog.Header.VolumeContainer.Minus.Activated:Connect(function()
		local context = self.context
		context:Volume((math.max(0, math.floor(context:GetStatus().volume / 5) * 5 - 5)))
	end))
	self._Janitor:Add(self.Instance.Catalog.Header.VolumeContainer.Plus.Activated:Connect(function()
		local context = self.context
		context:Volume((math.min(100, math.floor(context:GetStatus().volume / 5) * 5 + 5)))
	end))
	local next = self.Instance.Catalog.Header.ButtonsList.Next
	self._Janitor:Add(next.MouseButton1Click:Connect(function()
		MusicNavigationUtil.selectNext(self.context)
	end))
	local previous = self.Instance.Catalog.Header.ButtonsList.Previous
	self._Janitor:Add(previous.MouseButton1Click:Connect(function()
		MusicNavigationUtil.selectPrevious(self.context)
	end))
	local flag2 = false
	self._Janitor:Add(self.Instance.Catalog.Header.ButtonsList.PausePlay.MouseButton1Click:Connect(function()
		if flag2 then
			return
		end

		flag2 = true
		local context = self.context

		if context:GetStatus().isPlaying then
			context:Stop()
		else
			context:Play()
		end

		task.wait(0.5)
		flag2 = false
	end))

	if self.Instance.Visible then
		self:BindMusicButtonsBackAction()
	end
end

function v:FilterText()
	local text = string.lower(self.textFilter.Text)

	if self.lastFilter == text then
		return
	end

	self.lastFilter = text
	local buttons = {}
	local visible = true
	local visible2 = false
	local visible3 = false

	for _, v5 in { self.songsFrame, self.freeSongsWickedFrame, self.freeSongsEdSheeranFrame } do
		for _, button in v5:GetChildren() do
			if button:IsA("ImageButton") then
				table.insert(buttons, button)
			end
		end
	end

	for _, v5 in buttons do
		local title = v5.Title

		if not (title ~= nil and title:IsA("TextLabel")) then
			continue
		end

		if text == "" then
			v5.Visible = true
			visible = false
		else
			local localizedText = string.lower(title.LocalizedText or title.Text)

			if string.find(localizedText, text) then
				v5.Visible = true
				visible = false
			else
				v5.Visible = false
			end
		end
	end

	for _, button in self.freeSongsWickedFrame:GetChildren() do
		if not (button:IsA("ImageButton") and button.Visible) then
			continue
		end

		visible3 = true
		break
	end

	for _, button in self.freeSongsEdSheeranFrame:GetChildren() do
		if not (button:IsA("ImageButton") and button.Visible) then
			continue
		end

		visible2 = true
		break
	end

	self.noFilterResults.Visible = visible
	self.freeSongsWickedFrame.Visible = visible3
	self.freeSongsEdSheeranFrame.Visible = visible2
	self.dividerWicked.Visible = visible3
	self.dividerEdSheeran.Visible = visible2
end

function v:CloseButtonPressed()
	if self.dbAudioPlayerClose then
		return
	end

	self.dbAudioPlayerClose = true
	self.Instance.Visible = false

	if self.closeCalled then
		self.closeCalled()
		self.closeCalled = nil
	end

	self:UnbindMusicButtonsBackAction()
	task.wait(0.5)
	self.dbAudioPlayerClose = false
end

function v:ResetPanel()
	self:SetVolumeVisibility(false)
	self:SetSearchVisibility(false)
	self:MovePanelUp(false)
	self.textFilter.Text = ""
	self:FilterText()
end

function v:Stop()
	self:UnbindMusicButtonsBackAction()
	self._Janitor:Destroy()
	self._gridLayoutJanitor:Destroy()
end

return v