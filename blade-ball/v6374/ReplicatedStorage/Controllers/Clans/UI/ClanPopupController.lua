local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TextService")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
require3(script.Parent.Parent.ClanController)
local v3 = require3(script.Parent.ClanPagesController)
require3(ReplicatedStorage2.Shared.ClansData)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local defaults = {
	acceptOnly = false,
	acceptText = "Yes",
	declineText = "No"
}
local main = Players.LocalPlayer.PlayerGui.Clans.Pages.Popup.Main
local thread = nil
local maid = v.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnCurrentThread(flag: boolean)
	if not thread then
		return
	end

	task.spawn(thread, flag)
	thread = nil
end

return {
	Prompt = function(_, p)
		spawnCurrentThread(false) -- equivalent call inferred; original call site unknown
		local merged = v2.Dictionary.merge(defaults, p)
		thread = coroutine.running()
		main.Title.Text = string.upper(merged.title)
		main.Body.Text = merged.text
		main.Buttons.Accept.Label.Text = merged.acceptText
		main.Buttons.Decline.Label.Text = merged.declineText
		main.Buttons.Decline.Visible = not merged.acceptOnly
		maid:Add(main.Close.Activated:Connect(function()
			if not thread then
				return
			end

			task.spawn(thread, false)
			thread = nil
		end))
		maid:Add(main.Buttons.Accept.Activated:Connect(function()
			if not thread then
				return
			end

			task.spawn(thread, true)
			thread = nil
		end))
		maid:Add(v3.PageStackChanged:Connect(function()
			if not v3:IsOpen("Popup") then
				spawnCurrentThread(false) -- equivalent call inferred; original call site unknown
			end
		end))

		if not merged.acceptOnly then
			maid:Add(main.Buttons.Decline.Activated:Connect(function()
				if not thread then
					return
				end

				task.spawn(thread, false)
				thread = nil
			end))
		end

		v3:PushPage("Popup")
		local v5 = coroutine.yield()
		maid:Clean()

		if merged.returnTo then
			v3:SetPage(merged.returnTo)
		else
			v3:RemovePage("Popup")
		end

		return v5 == true
	end
}