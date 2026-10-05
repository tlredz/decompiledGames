local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MailLetterUI"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._isBanned = false
	self._debounceNo = false
	self._debounceYes = false
	self._debounceLetter = false
end

function v:Start()
	local localPlayer = game.Players.LocalPlayer

	if not localPlayer then
		return
	end

	local game8Settings = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local maxy = module.Maxy
	local instance = self.Instance
	local yes = instance:WaitForChild("Yes")
	local no = instance:WaitForChild("No")
	local words = instance:WaitForChild("Words")
	local banMail = instance:WaitForChild("BanMail")
	local houseNumber = instance:WaitForChild("HouseNumber")
	banMail.Text = "Stop mail from " .. instance.Name
	self._Janitor:Add(no.MouseButton1Click:Connect(function()
		if not (self._debounceNo or self._isBanned) then
			self._debounceNo = true
			yes.Visible = false
			no.Visible = false
			banMail.Visible = false
			words.Visible = true
			task.wait(0.5)
			self._debounceNo = false
		end
	end))
	self._Janitor:Add(yes.MouseButton1Click:Connect(function()
		if not (self._debounceYes or self._isBanned) then
			self._debounceYes = true
			yes.Visible = false
			no.Visible = false
			banMail.Text = instance.Name .. " mail has been stopped!"
			words.Visible = false
			self._isBanned = true
			local name = instance.Name
			maxy:FireServer("RequestedMailBan", houseNumber.Value, name)
			task.wait(0.5)
			self._debounceYes = false
		end
	end))
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if not (self._debounceLetter or self._isBanned) then
			self._debounceLetter = true
			yes.Visible = true
			no.Visible = true
			banMail.Visible = true
			words.Visible = false
			task.wait(0.5)
			self._debounceLetter = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v