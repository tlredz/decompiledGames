local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local Header = {}
Header.__index = Header

function Header.new(page)
	local self = setmetatable({}, Header)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Header")
	self.SeasonFrame = self.Frame:WaitForChild("Season")
	self.SeasonText = self.SeasonFrame:WaitForChild("Title")
	self.DescriptionFrame = self.Frame:WaitForChild("Description")
	self.DescriptionButton = self.DescriptionFrame:WaitForChild("Info")
	self.DescriptionTitle = self.DescriptionFrame:WaitForChild("Title")
	self.GloryFrame = self.Frame:WaitForChild("Glory")
	self.GloryButton = self.GloryFrame:WaitForChild("Button")
	self.GloryIcon = self.GloryButton:WaitForChild("Icon")
	self.GloryTitle = self.GloryButton:WaitForChild("Title")
	self._update_description_thread = nil
	self:_Init()
	return self
end

function Header:Open()
	self:_UpdateGlory()
	self:_UpdateDescription()
end

function Header:Close()
	self:_CancelDescriptionThread()
end

function Header:_CancelDescriptionThread()
	if self._update_description_thread then
		task.cancel(self._update_description_thread)
		self._update_description_thread = nil
	end
end

function Header:_UpdateDescription()
	local name = SeasonLibrary.CurrentSeason.Name
	local season = SeasonLibrary.Seasons[name]
	local UNIVERSAL_ELO_NAME = SeasonLibrary.UNIVERSAL_ELO_NAME
	local v = PlayerDataController:Get("Seasons")[name]
	local v2 = v and v.RankedPerformances[UNIVERSAL_ELO_NAME]

	if not v2.LastDuelPlayedTime or not v2.CurrentELO or v2.CurrentELO <= season.ELODecayThreshold then
		self.DescriptionTitle.Text = "Standard duel gameplay  •  Restricted handicaps  •  Ban maps & weapons"
		return
	end

	self:_CancelDescriptionThread()
	self._update_description_thread = task.spawn(function()
		while true do
			local v3 = (math.ceil(v2.LastDuelPlayedTime / 60 / 60 / 24) + season.ELODecayInactivePeriodDays) * 24 * 60 * 60 - os.time()

			if v3 <= 0 then
				self.DescriptionTitle.Text = "Your ELO has begun decaying, play Ranked now to stop it"
			else
				self.DescriptionTitle.Text = string.format(
					"Your ELO will start decaying in %s if you don't play Ranked",
					Utility:TimeFormat2(v3)
				)
			end

			wait(1)
		end
	end)
end

function Header:_UpdateGlory()
	self.GloryTitle.Text = string.format(
		"%s <font transparency=\"0.25\" weight=\"500\" size=\"8\">Glory</font>",
		Utility:PrettyNumber(PlayerDataController:Get("Glory"))
	)
end

function Header:_Setup()
	self.SeasonText.Text = "Season " .. SeasonLibrary.CurrentSeason.Version
	self.GloryIcon.Image = CurrencyLibrary.Info.Glory.Image
end

function Header:_Init()
	self.DescriptionButton.MouseButton1Click:Connect(function()
		self.Page.PromptSystem:Open("ViewRankedDetails")
	end)
	self.GloryButton.MouseButton1Click:Connect(function()
		self.Page.OpenPage:Fire("Shop")
		Pages.PageSystem:WaitForPage("Shop"):SetPage("Ranked")
		Pages.PageSystem:WaitForPage("Shop"):RedirectTo("Ranked")
	end)
	self:_Setup()
	ButtonEffect:Add(self.DescriptionButton)
	ButtonEffect:Add(self.GloryButton, nil, {
		ReleaseRatio = 1.05,
		HoverRatio = 1.05
	})
end

return Header