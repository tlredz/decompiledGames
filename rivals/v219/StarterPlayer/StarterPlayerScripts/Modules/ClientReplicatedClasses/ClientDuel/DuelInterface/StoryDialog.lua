local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local StoryDialog = {}
StoryDialog.__index = StoryDialog

function StoryDialog.new(duelInterface)
	local self = setmetatable({}, StoryDialog)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Top"):WaitForChild("StoryDialog")
	self.Container = self.Frame:WaitForChild("Container")
	self.RightSpeakerFrame = self.Container:WaitForChild("RightSpeaker")
	self.RightSpeakerImage = self.RightSpeakerFrame:WaitForChild("Player"):WaitForChild("Headshot")
	self.LeftSpeakerFrame = self.Container:WaitForChild("LeftSpeaker")
	self.LeftSpeakerImage = self.LeftSpeakerFrame:WaitForChild("Player"):WaitForChild("Headshot")
	self.Message = self.Container:WaitForChild("Message")
	self._destroyed = false
	self._is_playing_story = false
	self._dont_play_more_stories = false
	self._random = Random.new(self.DuelInterface.ClientDuel:Get("DuelSeed"))
	self:_Init()
	return self
end

function StoryDialog:CreateSound(...)
	return self.Frame.Visible and self.Container.Visible and self.DuelInterface:CreateSound(...)
end

function StoryDialog:Update()
	self.Frame.Visible = not (self.DuelInterface.Scoreboard:IsOpen() or self.DuelInterface:IsPageOpen() or self.DuelInterface.RoundResult.Frame.Visible)

	if self.DuelInterface.ClientDuel:Get("Status") == "RoundStarted" then
		task.spawn(self._AttemptToPlayStory, self)
	end
end

function StoryDialog:Destroy()
	self._destroyed = true
end

function StoryDialog:_GetRandomSpeaker(...)
	local v = { ... }
	local players = {}

	for _, dueler in pairs(self.DuelInterface.ClientDuel.Duelers) do
		if not dueler.Player or table.find(v, dueler.Player) then
			continue
		end

		table.insert(players, dueler.Player)
	end

	table.sort(players, function(a, b)
		return a.UserId < b.UserId
	end)

	if #players == 0 then
		return nil
	end

	return players[self._random:NextInteger(1, #players)]
end

function StoryDialog:_PlayDialog(list, items)
	self._is_playing_story = true
	self.Container.Visible = true
	self.Container.Size = UDim2.new(1, 0, 1, 0)
	self:CreateSound("rbxassetid://105553937408843", 1, 1, script, true, 10)

	for k, item in pairs(items) do
		if self._destroyed then
			return
		end

		task.delay(
			k == 1 and 0.5 or 0,
			self.CreateSound,
			self,
			"rbxassetid://124144337176625",
			1,
			0.9 + 0.2 * math.random(),
			script,
			true,
			10
		)

		if self.Container:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
			self.Container.Size = UDim2.new(1.1, 0, 1.1, 0)
			self.Container:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quint", 0.25, true)
		end

		self.Message.Text = item.Message
		self.RightSpeakerFrame.Visible = table.find(list, item.Speaker) == 1
		self.RightSpeakerImage.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, item.Speaker.UserId)
		self.LeftSpeakerImage.Image = self.RightSpeakerImage.Image
		self.LeftSpeakerFrame.Visible = not self.RightSpeakerFrame.Visible
		wait(item.WaitBeforeMovingOn)
	end

	if self.Container:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
		self:CreateSound("rbxassetid://105553937408843", 1, 0.75, script, true, 10)
		self.Container:TweenSize(UDim2.new(0.25, 0, 0.25, 0), "In", "Quint", 0.25, true)
		wait(0.25)
	end

	self._is_playing_story = false
	self.Container.Visible = false
end

function StoryDialog:_ZombieTower()
	local _GetRandomSpeaker = self:_GetRandomSpeaker()
	local _GetRandomSpeaker2 = self:_GetRandomSpeaker(_GetRandomSpeaker)

	if _GetRandomSpeaker and _GetRandomSpeaker2 then
		self:_PlayDialog({ _GetRandomSpeaker, _GetRandomSpeaker2 }, {
			{
				Speaker = _GetRandomSpeaker,
				WaitBeforeMovingOn = 6,
				Message = "This must be the tower our intel had us locate."
			},
			{
				Speaker = _GetRandomSpeaker,
				WaitBeforeMovingOn = 6,
				Message = "Let's find our way to the top and radio for rescue."
			},
			{
				Speaker = _GetRandomSpeaker2,
				WaitBeforeMovingOn = 4,
				Message = "Easier said than done!"
			},
			{
				Speaker = _GetRandomSpeaker2,
				WaitBeforeMovingOn = 6,
				Message = "Do you see how tall it is? I can't even see the top!"
			},
			{
				Speaker = _GetRandomSpeaker2,
				WaitBeforeMovingOn = 6,
				Message = "We're so dead. I really thought we had a chance."
			},
			{
				Speaker = _GetRandomSpeaker,
				WaitBeforeMovingOn = 4,
				Message = "We do have a chance.\n"
			},
			{
				Speaker = _GetRandomSpeaker,
				WaitBeforeMovingOn = 4,
				Message = "Just stay focused. We've come too far to give up."
			},
			{
				Speaker = _GetRandomSpeaker2,
				WaitBeforeMovingOn = 6,
				Message = "We're looking for a.. what? A radio? Then what?"
			},
			{
				Speaker = _GetRandomSpeaker,
				WaitBeforeMovingOn = 6,
				Message = "..then we hope for the best. Let's go!"
			}
		})
		return
	end

	if not _GetRandomSpeaker then
		return
	end

	self:_PlayDialog({ _GetRandomSpeaker }, {
		{
			Speaker = _GetRandomSpeaker,
			WaitBeforeMovingOn = 6,
			Message = "This is it. This is the tower they told me to find."
		},
		{
			Speaker = _GetRandomSpeaker,
			WaitBeforeMovingOn = 6,
			Message = "I'm the only one left. I can't give up now."
		},
		{
			Speaker = _GetRandomSpeaker,
			WaitBeforeMovingOn = 6,
			Message = "All I need to do now is reach the top and.. radio for help."
		},
		{
			Speaker = _GetRandomSpeaker,
			WaitBeforeMovingOn = 6,
			Message = "No problem at all. No big deal.. I got this.."
		}
	})
end

function StoryDialog:_AttemptToPlayStory()
	if self._is_playing_story or self._dont_play_more_stories then
		return
	end

	local playSourceName = self.DuelInterface.ClientDuel:Get("PlaySourceName")

	if (playSourceName and DuelLibrary.PlaySources[playSourceName].DuelLogic) == "Zombie Tower" then
		self._dont_play_more_stories = true
		self:_ZombieTower()
	end
end

function StoryDialog:_Init()
	self.DuelInterface.RoundResult.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Update()
	end)
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:Update()
	end)
end

return StoryDialog