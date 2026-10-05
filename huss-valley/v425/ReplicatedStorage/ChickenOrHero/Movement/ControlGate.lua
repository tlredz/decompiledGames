local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local session = script.Parent.Parent:WaitForChild("Game"):WaitForChild("Session")
local ControlGate = {
	movementReason = function(instance)
		if session:GetAttribute("GlobalPaused") == true then
			return "GlobalPause"
		end

		if session:GetAttribute("MapChanging") == true then
			return "MapChange"
		end

		if instance:GetAttribute("Spectating") == true then
			return "Spectating"
		end

		return nil
	end,
	reason = function(instance)
		if instance:GetAttribute("EventHostPanelOpen") == true then
			return "EventHostPanel"
		end

		if instance:GetAttribute("CrateOpen") == true then
			return "Crates"
		end

		if instance:GetAttribute("StarterPackOpen") == true then
			return "StarterPack"
		end

		if instance:GetAttribute("LikeRewardOpen") == true and instance:GetAttribute("InMatch") ~= true then
			return "LikeReward"
		end

		if instance:GetAttribute("CreatorPanelOpen") == true then
			return "CreatorPanel"
		end

		if session:GetAttribute("GlobalPaused") or instance:GetAttribute("GlobalWheelOpen") or instance:GetAttribute("GiveawayPickerOpen") then
			return "GlobalWheel"
		end

		if instance:GetAttribute("MapVoteOpen") == true then
			return "MapVote"
		end

		if session:GetAttribute("MapChanging") == true then
			return "MapChange"
		end

		if instance:GetAttribute("EmoteWheelOpen") == true then
			return "Emotes"
		end

		if instance:GetAttribute("AnnouncementComposerOpen") == true then
			return "AnnouncementComposer"
		end

		if instance:GetAttribute("SettingsOpen") == true then
			return "Settings"
		end

		if instance:GetAttribute("UpdateLogOpen") == true then
			return "UpdateLog"
		end

		if instance:GetAttribute("Spectating") == true then
			return "Spectating"
		end

		if instance:GetAttribute("FairPlayNoticeOpen") == true then
			return "FairPlayNotice"
		end

		if instance:GetAttribute("JourneyOpen") == true and instance:GetAttribute("InMatch") ~= true then
			return "Journey"
		end

		if instance:GetAttribute("ConnectionQualityOpen") == true and instance:GetAttribute("InMatch") ~= true then
			return "ConnectionQuality"
		end

		if instance:GetAttribute("BalloonOfferOpen") == true and instance:GetAttribute("InMatch") ~= true then
			return "BalloonOffer"
		end

		if instance:GetAttribute("ArmoryOpen") == true and instance:GetAttribute("InMatch") ~= true then
			return "Armory"
		end

		if instance:GetAttribute("ServerBrowserOpen") == true and instance:GetAttribute("InMatch") ~= true then
			return "ServerBrowser"
		end

		if instance:GetAttribute("AdminRefreshActive") == true then
			return "AdminRefresh"
		end

		if instance:GetAttribute("AdminConsoleActive") == true then
			return "AdminConsole"
		end

		if GuiService.MenuIsOpen then
			return "RobloxMenu"
		end

		if UserInputService:GetFocusedTextBox() then
			return "TextInput"
		end

		if instance:GetAttribute("ScreenPresentationActive") == true then
			return "ScreenTransition"
		end

		if instance:GetAttribute("ReleaseCursorForControls") == true and (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then
			return "CursorControls"
		end

		if instance:GetAttribute("TutorialModalActive") == true and instance:GetAttribute("TutorialSession") == true then
			return "Tutorial"
		end

		if instance:GetAttribute("InMatch") ~= true then
			return nil
		end

		local phase = session:GetAttribute("Phase")
		local v

		if phase == "SelectHero" and session:GetAttribute("LeadUserId") == instance.UserId then
			v = true
		elseif phase == "HeroChoice" then
			v = session:GetAttribute("SelectedUserId") == instance.UserId
		else
			v = false
		end

		if v and instance:GetAttribute("ReleaseCameraForUI") == true then
			return "Choice"
		end

		if instance:GetAttribute("ChoiceSpotlightActive") == true and (phase == "SelectHero" or phase == "HeroChoice" or phase == "ChoiceReveal") then
			return "ChoiceCamera"
		end

		return nil
	end
}
local v = {}
local v2 = nil

local function watchGui(folder)
	if v2 == folder then
		return
	end

	v2 = folder
	table.clear(v)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function track(button)
		if button:IsA("GuiButton") then
			v[button] = true
		end
	end

	for _, descendant in folder:GetDescendants() do
		track(descendant) -- equivalent call inferred; original call site unknown
	end

	folder.DescendantAdded:Connect(track)
	folder.DescendantRemoving:Connect(function(descendant)
		v[descendant] = nil
	end)
end

function ControlGate.cursorReason(instance)
	local reason = ControlGate.reason(instance)

	if reason then
		return reason
	end

	local playerGui = instance:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	watchGui(playerGui)

	for parent in v do
		if not parent.Modal then
			continue
		end

		local v3 = true

		while parent and parent ~= playerGui do
			if parent:IsA("GuiObject") and not parent.Visible or parent:IsA("LayerCollector") and not parent.Enabled then
				v3 = false
				break
			else
				parent = parent.Parent
			end
		end

		if v3 and parent == playerGui then
			return "InteractiveMenu"
		end
	end

	return nil
end

return ControlGate