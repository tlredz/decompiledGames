local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local MusicPlayerController = require(ReplicatedStorage.Modules.Client.Music.MusicPlayerController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MusicSettingsComponent"
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
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible == false then
			self._gridLayoutJanitor:Cleanup()
			self:UnbindMusicButtonsBackAction()
			self:ResetPanel()
		else
			self._gridLayoutJanitor:Add(songsGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, songsGridLayout.AbsoluteContentSize.Y + 100)
			end))
			self:BindMusicButtonsBackAction()
		end
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
	task.wait(0.5)
	self.dbAudioPlayerClose = false
	MusicPlayerController.ResetMusicContext()
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