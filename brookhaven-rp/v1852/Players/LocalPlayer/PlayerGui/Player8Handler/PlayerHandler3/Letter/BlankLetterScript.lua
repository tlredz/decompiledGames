local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local maxy = module.Maxy
local parent = script.Parent
local yes = script.Parent:WaitForChild("Yes")
local no = script.Parent:WaitForChild("No")
local words = script.Parent:WaitForChild("Words")
local banMail = script.Parent:WaitForChild("BanMail")
local banned = script:WaitForChild("Banned")
local houseNumber = script.Parent:WaitForChild("HouseNumber")
local v = false
local v2 = false
local v3 = false
no.MouseButton1Click:connect(function()
	if v == false and banned.Value == false then
		v = true
		yes.Visible = false
		no.Visible = false
		banMail.Visible = false
		words.Visible = true
		wait(0.5)
		v = false
	end
end)
yes.MouseButton1Click:connect(function()
	if v2 == false and banned.Value == false then
		v2 = true
		yes.Visible = false
		no.Visible = false
		banMail.Text = parent.Name .. " mail has been stopped!"
		words.Visible = false
		banned.Value = true
		local name = parent.Name
		maxy:FireServer("RequestedMailBan", houseNumber.Value, name)
		wait(0.5)
		v2 = false
	end
end)
parent.MouseButton1Click:connect(function()
	if v3 == false and banned.Value == false then
		v3 = true
		yes.Visible = true
		no.Visible = true
		banMail.Visible = true
		words.Visible = false
		wait(0.5)
		v3 = false
	end
end)
banMail.Text = "Stop mail from " .. parent.Name