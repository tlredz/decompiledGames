local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseMailBox"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)

function v:Construct()
	self._Janitor = Janitor.new()
	local game8Settings = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	self.Maxy = module.Maxy
	self.blankLetter = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("Letter")
	self.isFull = false
	self.mailboxFullMessage = false
	self.dbHouseLetter = false
	self.mail = {}
end

function v:ClearMail()
	if not PanelController.GetPanel("NoResetGUIHandler", "MailboxUI") then
		warn("HouseMailBox: panel not found, why?")
		return
	end

	local panel = PanelController.GetPanel("NoResetGUIHandler", "HouseKey")

	if not panel then
		warn("HouseMailBox: HouseKey panel not found, why?")
		return
	end

	local instance = panel:GetInstance()

	if not instance then
		warn("HouseMailBox: HouseKey instance not found, why?")
		return
	end

	for _, child in pairs(self.Instance.A.B.C.D.E:GetChildren()) do
		if child ~= nil and child.className == "ImageButton" then
			child:Destroy()
		end
	end

	self.mailboxFullMessage = false
	instance.HouseLetter.Value.Visible = false
	PanelController.Close("NoResetGUIHandler", "MailboxUI")
	self.isFull = false
end

function v:RevealMail(data)
	local clone = self.blankLetter:Clone()
	local panel = PanelController.GetPanel("NoResetGUIHandler", "MailboxUI")
	clone.Name = data.PlayerWhoWroteLetter.Name
	clone.Words.Text = data.PlayerWhoWroteLetter.Name .. ":   " .. data.FilterString
	clone.HouseNumber.Value = data.HouseNumber
	clone.Parent = panel:GetInstance().A.B.C.D.E

	for k, v2 in self.mail do
		if v2.PlayerWhoWroteLetter.Name ~= v2.PlayerWhoWroteLetter.Name then
			continue
		end

		table.remove(self.mail, k)
		break
	end
end

function v:CreateMail(playerWhoWroteLetter, filterString, houseNumber)
	table.insert(self.mail, {
		PlayerWhoWroteLetter = playerWhoWroteLetter,
		FilterString = filterString,
		HouseNumber = houseNumber
	})
	NotificationController.Notify("📫 Letter in mailbox")
	local count = 0

	for _, _ in self.mail do
		count += 1

		if count > 4 then
			self.isFull = true
		end
	end

	local count2 = 0

	for _, _ in self.mail do
		count2 += 1

		if count2 > 4 then
			self.isFull = true
		end
	end

	self:RevealMail({
		PlayerWhoWroteLetter = playerWhoWroteLetter,
		FilterString = filterString,
		HouseNumber = houseNumber
	})
	local panel = PanelController.GetPanel("NoResetGUIHandler", "HouseKey")

	if panel then
		local instance = panel:GetInstance()
		instance.HouseLetter.Value.Visible = true
	else
		warn("HouseMailBox: HouseKey panel not found, why?")
	end
end

function v:SetupHouseLetterButton()
	local panel = PanelController.GetPanel("NoResetGUIHandler", "HouseKey")

	if not panel then
		warn("HouseMailBox: HouseKey panel not found, why?")
		return
	end

	local instance = panel:GetInstance()

	if not instance then
		warn("HouseMailBox: HouseKey instance not found, why?")
		return
	end

	local tempMailHouseNumber = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("TempMailHouseNumber")
	instance.HouseLetter.Value.MouseButton1Click:connect(function()
		if self.dbHouseLetter then
			return
		end

		self.dbHouseLetter = true
		task.delay(0.5, function()
			self.dbHouseLetter = false
		end)
		PanelController.OpenPanelByContext("NoResetGUIHandler", "MailboxUI")
		self.Maxy:FireServer("LetterUIMailCheck", tempMailHouseNumber.Value)
	end)
end

function v:Start()
	self._Janitor:Add(self.Maxy.OnClientEvent:connect(function(p, p2, p3, p4)
		if p == "OpenLetterToRead" then
			PanelController.OpenPanelByContext("NoResetGUIHandler", "MailboxUI")
		elseif p == "DeliverMail" then
			if not self.isFull then
				self:CreateMail(p3, p2, p4)
				return
			end

			self.Maxy:FireServer("MailBoxFullDeleteLetter", p4, p3)

			if not self.mailboxFullMessage then
				NotificationController.Notify("Mailbox is full")
				self.mailboxFullMessage = true
			end
		end
	end))
	self:SetupHouseLetterButton()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v