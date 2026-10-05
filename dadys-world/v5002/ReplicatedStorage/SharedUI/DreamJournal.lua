local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIController = require(ReplicatedStorage.SharedUtils.UIController)
local object = setmetatable({}, UIController)
object.__index = object
local WindowHandler = require(ReplicatedStorage.Modules.WindowHandler)
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController"))
local GuiAnimations = require(ReplicatedStorage.Modules.GuiAnimations)
local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)
local DisplayMessage = require(ReplicatedStorage.Modules.DisplayMessage)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local DreamJournalConfig = require(ReplicatedStorage.SharedData.DreamJournalConfig)
local mainGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui")

local function registerDisableableBookmark(button)
	if not (button and button:IsA("GuiButton")) then
		return
	end

	local background = button:FindFirstChild("Background")
	local icon = background and background:FindFirstChild("Icon")
	local imageColor3

	if background and background:IsA("ImageLabel") then
		imageColor3 = background.ImageColor3 or nil
	else
		imageColor3 = nil
	end

	local textLabel = button:FindFirstChildWhichIsA("TextLabel")

	local function apply()
		local disabled = button:GetAttribute("Disabled") == true
		button.AutoButtonColor = not disabled

		if textLabel then
			textLabel.TextTransparency = disabled and 0.7 or 0
		end

		if background and imageColor3 then
			if disabled then
				background.ImageColor3 = Color3.new(imageColor3.R * 0.5, imageColor3.G * 0.5, imageColor3.B * 0.5)

				if icon then
					icon.ImageColor3 = background.ImageColor3
				end
			else
				background.ImageColor3 = imageColor3

				if icon then
					icon.ImageColor3 = background.ImageColor3
				end
			end
		end
	end

	button:GetAttributeChangedSignal("Disabled"):Connect(apply)
	button:SetAttribute("Disabled", button:GetAttribute("Disabled") == true)
	apply()
end

local function registerHideableBookmark(object2, button)
	if not (button and button:IsA("GuiButton")) then
		return
	end

	local function apply()
		local hidden = button:GetAttribute("Hidden") == true
		button.Visible = not hidden
		local v = object2._pageByName[button.Name]

		if hidden then
			if v then
				v.Visible = false
			end

			if object2.activePage == v then
				for _, button2 in pairs(button.Parent:GetChildren()) do
					if not (button2:IsA("TextButton") and button2 ~= button and button2:GetAttribute("Hidden") ~= true) then
						continue
					end

					object2:ShowPage(button2.Name)
					return
				end
			end
		end
	end

	button:GetAttributeChangedSignal("Hidden"):Connect(apply)
	button:SetAttribute("Hidden", button:GetAttribute("Hidden") == true)
	apply()
end

local v = {
	medals = true,
	titles = true,
	collection = true,
	profiles = true,
	profileEditing = true,
	starterQuests = true,
	dailyStreak = true
}
local v2 = {
	Medals = "medals",
	Titles = "titles",
	Collection = "collection",
	Stickers = "collection",
	Profiles = "profiles",
	StarterQuests = "starterQuests"
}

local function resolveCapabilities(p)
	local clone = table.clone(v)
	local capabilities = p and p.capabilities

	if type(capabilities) == "table" then
		for k in pairs(v) do
			if capabilities[k] == false then
				clone[k] = false
			end
		end
	end

	return clone
end

function object.IsCapabilityEnabled(p, p2: string)
	return p.capabilities[p2] ~= false
end

function object:_isPageEnabled(p2: string)
	local v3 = v2[p2]
	return v3 == nil or self.capabilities[v3] ~= false
end

function object:_applyCapabilities()
	for k, v3 in pairs(v2) do
		local v4 = self._bookmarkByName[k]

		if v4 and self.capabilities[v3] == false then
			v4:SetAttribute("Hidden", true)
		end
	end
end

function object.Open(p, _)
	WindowHandler.open(p.gui)
end

function object.Close(p, _)
	WindowHandler.close(p.gui)
end

function object.init(p)
	local v3 = UIController.new(mainGui:FindFirstChild("DreamJournal"))
	setmetatable(v3, object)
	v3.capabilities = resolveCapabilities(p)
	WindowHandler.register(v3.gui, v3.gui.ExitButton, {
		closeButtons = true
	})
	v3:_initButtons()
	v3:_initNewIndicator()
	v3:_initPages()
	v3:_applyCapabilities()
	MenuManager:Register("DreamJournal", v3, {
		isOverlay = false
	})
	return v3
end

function object:_initPages()
	local _ = self.map.Pages
	self.styleController:Apply(self.gui, "Shared.Journal.journal")

	for k, _ in pairs(self._pageMap) do
		if not self:_isPageEnabled(k.Name) then
			continue
		end

		local child = script:FindFirstChild(k.Name)

		if not child then
			continue
		end

		local module = require(child)
		module(self)
	end

	self:ShowPage("Overview")

	for _, v4 in pairs({
		Stickers = function()
			if not self:_isPageEnabled("Stickers") then
				return
			end

			local page = self:FindPage("Stickers")
			local items = {}

			for k, v5 in pairs(require(ReplicatedStorage.SharedData.Stickers)) do
				if v5.Image ~= nil and #v5.Tags == 0 then
					table.insert(items, {
						Key = k,
						Name = v5.DisplayName,
						Image = v5.Image,
						SpriteSheet = v5.SpriteSheet,
						Tags = not v5.Tags and {} or v5.Tags or {},
						Text = v5.Text
					})
				end
			end

			for k, v5 in pairs(require(ReplicatedStorage.SharedData.Stickers)) do
				if v5.Image ~= nil and table.find(v5.Tags, "Halloween") then
					table.insert(items, {
						Key = k,
						Name = v5.DisplayName,
						Image = v5.Image,
						SpriteSheet = v5.SpriteSheet,
						Tags = not v5.Tags and {} or v5.Tags or {},
						Text = v5.Text
					})
				end
			end

			for k, v5 in pairs(require(ReplicatedStorage.SharedData.Stickers)) do
				if v5.Image ~= nil and table.find(v5.Tags, "Christmas") then
					table.insert(items, {
						Key = k,
						Name = v5.DisplayName,
						Image = v5.Image,
						SpriteSheet = v5.SpriteSheet,
						Tags = not v5.Tags and {} or v5.Tags or {},
						Text = v5.Text
					})
				end
			end

			for k, v5 in pairs(require(ReplicatedStorage.SharedData.Stickers)) do
				if v5.Image ~= nil and table.find(v5.Tags, "Easter") then
					table.insert(items, {
						Key = k,
						Name = v5.DisplayName,
						Image = v5.Image,
						SpriteSheet = v5.SpriteSheet,
						Tags = not v5.Tags and {} or v5.Tags or {},
						Text = v5.Text
					})
				end
			end

			local function loadCarousel(object3)
				local stickerTemplate = page.Margin.Page1.StickerTemplate
				stickerTemplate.Parent = nil
				local v5 = {}
				local carousel = self:CreateCarousel({
					Items = items,
					ParentGui = self.map.Stickers,
					Frames = { page.Margin.Page1, page.Margin.Page2 },
					ItemsPerFrame = 6,
					RenderItem = function(data)
						local clone = stickerTemplate:Clone()
						clone.TextLabel.Text = data.Name
						clone.Label.Text = data.Text

						local function arrayToString(tags)
							return table.concat(tags, "|")
						end

						clone:SetAttribute("Tags", arrayToString(data.Tags))
						self.styleController:Apply(clone, "Shared.Journal.sticker")
						clone:SetAttribute("Text", data.Text)
						local v6 = string.match(data.Image, "%d+")
						local random = Random.new(v6)
						local number = random:NextNumber(-15, 15)
						clone.ImageLabel.Rotation = number
						clone.ImageShadow.Rotation = number
						clone.ImageLabel.Image = data.Image
						clone.ImageShadow.Image = data.Image
						clone.UIScale.Scale = random:NextNumber(1, 1.15)

						if data.SpriteSheet then
							local function handleSpriteSheet(adornee)
								local spriteSheet = data.SpriteSheet
								local SpriteClip2 = require(game.ReplicatedStorage.Modules.SpriteClip2)
								adornee.ImageRectSize = Vector2.new(256, 256)
								adornee.ImageRectOffset = Vector2.new(0, 0)
								local imageSprite = SpriteClip2.ImageSprite.new({
									adornee = adornee,
									spriteSheetId = data.Image,
									spriteSize = Vector2.new(256, 256),
									spriteCount = 4,
									columnCount = 2,
									frameRate = spriteSheet.frameRate or 10,
									isLooped = true
								})
								imageSprite:Play()

								if not spriteSheet.sequence then
									return imageSprite
								end

								imageSprite:Pause()
								local sequence = spriteSheet.sequence
								local v7 = 1
								local v8 = 1 / (spriteSheet.frameRate or 10)
								task.spawn(function()
									while adornee.Parent and imageSprite do
										imageSprite:SetFrame(sequence[v7])
										v7 = v7 % #sequence + 1
										task.wait(v8)
									end
								end)
								return imageSprite
							end

							handleSpriteSheet(clone.ImageShadow)
							handleSpriteSheet(clone.ImageLabel)
						end

						local index = table.find(object3.Data.StickersOwned, data.Key)

						if not index then
							clone.ImageLabel.Visible = false
							clone.ImageShadow.ImageTransparency = 0.9
							v5[data.Key] = clone
						end

						clone:SetAttribute("Owned", index ~= nil)
						return clone
					end
				})
				object3:ListenToArrayInsert("StickersOwned", function(_, p)
					local v6 = v5[p]

					if v6 then
						v6.ImageLabel.Visible = true
						v6.ImageShadow.ImageTransparency = 0.5
						v5[p] = nil
						v6:SetAttribute("Owned", true)
					end
				end)

				local function updatePages()
					local text = (carousel.CurrentPage - 1) * 2 + 1
					local text2 = text + 1
					page.Margin.PageLeft.Text = text
					page.Margin.PageRight.Text = text2

					if carousel.CurrentPage <= 1 then
						page.Margin.Previous.Visible = false
					else
						page.Margin.Previous.Visible = true
					end

					if carousel.CurrentPage >= carousel:GetPageCount() then
						page.Margin.Next.Visible = false
					else
						page.Margin.Next.Visible = true
					end
				end

				self:BindButton(page.Margin.Next, function()
					carousel:Next()
					self.gui:SetAttribute("CurrentPage", "")
					self.gui:SetAttribute("CurrentPage", "Stickers")
					updatePages()
				end)
				self:BindButton(page.Margin.Previous, function()
					carousel:Previous()
					self.gui:SetAttribute("CurrentPage", "")
					self.gui:SetAttribute("CurrentPage", "Stickers")
					updatePages()
				end)
				updatePages()
			end

			MyDataController:onReplicaReady(function(p)
				loadCarousel(p)
			end)
		end
	}) do
		v4()
	end
end

function object:_initButtons()
	self._bookmarkByName = {}
	local leftSide = mainGui.Menu:FindFirstChild("LeftSide")

	if leftSide then
		self.dreamJournalButton = leftSide:FindFirstChild("DreamJournalButton")
		GuiAnimations.SetupButtonAnimationsSimple(self.dreamJournalButton)

		if self.dreamJournalButton then
			self.dreamJournalButton.Activated:Connect(function()
				if self.gui.Visible then
					WindowHandler.close(self.gui)
				else
					WindowHandler.open(self.gui)
				end
			end)
		end
	end

	local bookmarks = self.map.Bookmarks

	for _, button in pairs(bookmarks.Parent:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v3 = button
		local activatedConnection = button.Activated:Connect(function()
			if v3:GetAttribute("Disabled") == true then
				DisplayMessage("Complete Dandy's Buds Quests to unlock the rest of the Journal")
			else
				self:ShowPage(v3.Name)
			end
		end)
		table.insert(self._connections, activatedConnection)

		if not self._pageByName[button.Name] then
			continue
		end

		registerDisableableBookmark(button)
		registerHideableBookmark(self, button)
		self._bookmarkByName[button.Name] = button
	end
end

function object:_initNewIndicator()
	self._redeemableCount = 0
	self._journalUnseen = false
	self._ftueInProgress = false
	local dreamJournalButton = self.dreamJournalButton
	self._newIndicator = dreamJournalButton and dreamJournalButton:FindFirstChild("NewIndicator") or nil
	local unixTimestamp = DreamJournalConfig.LastContentRefresh.UnixTimestamp

	local function applyReplicaState(object3)
		local data = object3.Data
		local lastOpenedJournal = tonumber(data and data.Flags and data.Flags.LastOpenedJournal) or 0
		self._journalUnseen = lastOpenedJournal < unixTimestamp
		local tutorialProgress = data and data.TutorialProgress
		local v3 = tutorialProgress and tutorialProgress.Started == true
		local currentStep = tonumber(tutorialProgress and tutorialProgress.CurrentStep) or 0
		self._ftueInProgress = v3 and currentStep < DreamJournalConfig.FTUEFinalStep
		self:_refreshIndicator()
	end

	MyDataController:onReplicaReady(function(object3)
		applyReplicaState(object3)
		object3:ListenToChange("Flags.LastOpenedJournal", function()
			applyReplicaState(object3)
		end)
		object3:ListenToChange("TutorialProgress.CurrentStep", function()
			applyReplicaState(object3)
		end)
	end, function()
		warn("[DreamJournal] Replica unavailable; new-journal indicator stays hidden")
	end)
	local visibleChangedConnection = self.gui:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.gui.Visible then
			return
		end

		self:_markSeen()
	end)
	table.insert(self._connections, visibleChangedConnection)
end

function object:SetRedeemableCount(value: number)
	self._redeemableCount = value or 0
	self:_refreshIndicator()
end

function object:_markSeen()
	if not self._journalUnseen then
		return
	end

	self._journalUnseen = false
	self:_refreshIndicator()
	Network:Post("MarkJournalOpened")
end

function object:_refreshIndicator()
	local _newIndicator = self._newIndicator

	if not (_newIndicator and _newIndicator.Parent) then
		return
	end

	local textLabel = _newIndicator:FindFirstChild("TextLabel")

	if self._redeemableCount >= 1 then
		if textLabel then
			textLabel.Text = tostring(self._redeemableCount)
		end
	else
		if not self._journalUnseen or self._ftueInProgress then
			_newIndicator.Visible = false
			return
		end

		if textLabel then
			textLabel.Text = "!"
		end
	end

	_newIndicator.Visible = true
end

function object.SetTabDisabled(childName: string, flag: boolean)
	local dreamJournal = mainGui:FindFirstChild("DreamJournal")
	local margin = dreamJournal and dreamJournal:FindFirstChild("Margin")
	local button = margin and margin:WaitForChild(childName, 1)

	if button and button:IsA("GuiButton") then
		button:SetAttribute("Disabled", flag and true or false)
		return true
	end

	warn(("[DreamJournal] SetTabDisabled: bookmark %q not found"):format(childName))
	return false
end

function object.IsTabDisabled(childName: string)
	local dreamJournal = mainGui:FindFirstChild("DreamJournal")
	local margin = dreamJournal and dreamJournal:FindFirstChild("Margin")
	local child = margin and margin:FindFirstChild(childName)
	return child ~= nil and child:GetAttribute("Disabled") == true
end

function object.SetTabHidden(childName: string, flag: boolean)
	local dreamJournal = mainGui:FindFirstChild("DreamJournal")
	local margin = dreamJournal and dreamJournal:FindFirstChild("Margin")
	local button = margin and margin:WaitForChild(childName, 1)

	if button and button:IsA("GuiButton") then
		button:SetAttribute("Hidden", flag and true or false)
		return true
	end

	warn(("[DreamJournal] SetTabHidden: bookmark %q not found"):format(childName))
	return false
end

function object.SetActivePage(p: string)
	local dreamJournal = mainGui:FindFirstChild("DreamJournal")
	local margin = dreamJournal and dreamJournal:FindFirstChild("Margin")
	local pages = margin and margin:FindFirstChild("Pages")

	if not pages then
		return false
	end

	local flag = false

	for _, child in ipairs(pages:GetChildren()) do
		child.Visible = child.Name == p

		if child.Visible then
			flag = true
		end
	end

	if flag then
		dreamJournal:SetAttribute("CurrentPage", p)
		dreamJournal:SetAttribute("CurrentCategory", p)
	end

	return true
end

return object