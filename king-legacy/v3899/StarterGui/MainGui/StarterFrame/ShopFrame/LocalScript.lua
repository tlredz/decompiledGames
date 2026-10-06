local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LimitedBundles = require(ReplicatedStorage:WaitForChild("Chest").Modules.LimitedBundles)
local primalPack = LimitedBundles["Primal Pack"]

function Format(p)
	return string.format("%02i", p)
end

pcall(function()
	task.spawn(function()
		local localPlayer = game.Players.LocalPlayer

		repeat
			wait()
		until localPlayer.PlayerGui and localPlayer.PlayerGui:FindFirstChild("MainGui")

		local mainGui = localPlayer.PlayerGui.MainGui
		local unixTimestamp = DateTime.now().UnixTimestamp
		local v = primalPack.UnixTimestamp - unixTimestamp
		local _ = v / 86400
		local _ = v / 3600 % 24
		local _ = v / 60 % 60
		local _ = v % 60

		if primalPack.UnixTimestamp < unixTimestamp then
			mainGui.BaseFrame.ButtonFrame.ShopButton.ImageLabel.UIGradient.Enabled = nil
		end
	end)
end)
local v = nil
local flag = true

while true do
	if parent.Visible then
		local v2 = task.wait() * 60
		local scrollingFrame = parent.ScrollingFrame

		if not v then
			scrollingFrame.BundleFrame.Frame["Primal Pack"].Price.Text = "<stroke color=\"#000000\" joins=\"miter\" thickness=\"2.5\" transparency=\"0\"><font size=\"10\"></font>2999</stroke><font color =\"#000000\"> <font size=\"10\"><font weight=\"SemiBold\"><s>10428</s></font></font></font>"
			scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].Price.Text = "<stroke color=\"#000000\" joins=\"miter\" thickness=\"2.5\" transparency=\"0\"><font size=\"10\"></font>4999</stroke><font color =\"#000000\"> <font size=\"10\"><font weight=\"SemiBold\"><s>20773</s></font></font></font>"
			v = true
		end

		scrollingFrame.PermanentFruitFrame.Frame["Permanent Fruit"].UIGradient.Rotation = (scrollingFrame.PermanentFruitFrame.Frame["Permanent Fruit"].UIGradient.Rotation + v2) % 360
		scrollingFrame.PermanentFruitFrame.Frame["Permanent Fruit"].UIStroke.UIGradient.Rotation = (scrollingFrame.PermanentFruitFrame.Frame["Permanent Fruit"].UIStroke.UIGradient.Rotation + v2) % 360
		scrollingFrame.PermanentFruitFrame.Frame["Permanent Fruit"].CanvasGroup.Background.Rotation = (scrollingFrame.PermanentFruitFrame.Frame["Permanent Fruit"].CanvasGroup.Background.Rotation + v2 / 10) % 360
		scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].CanvasGroup.IconLabel.Rotation = math.sin(tick() / 1.5) * 8.5
		scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].CanvasGroup.Background.Rotation = (scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].CanvasGroup.Background.Rotation + v2 / 10) % 360
		scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].UIGradient.Rotation = (scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].UIGradient.Rotation + v2) % 360
		scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].UIStroke.UIGradient.Rotation = (scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].UIStroke.UIGradient.Rotation + v2) % 360

		if scrollingFrame.BundleFrame.Visible then
			scrollingFrame.BundleFrame.Frame["Primal Pack"].UIGradient.Rotation = (scrollingFrame.BundleFrame.Frame["Primal Pack"].UIGradient.Rotation + v2) % 360
			scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].UIGradient.Rotation = (scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].UIGradient.Rotation + v2) % 360
			scrollingFrame.BundleFrame.Frame["Primal Pack"].UIStroke.UIGradient.Rotation = (scrollingFrame.BundleFrame.Frame["Primal Pack"].UIStroke.UIGradient.Rotation + v2 * 2) % 360
			scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].UIStroke.UIGradient.Rotation = (scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].UIStroke.UIGradient.Rotation + v2 * 2) % 360
			scrollingFrame.BundleFrame.Frame["Primal Pack"].CanvasGroup.Background.Rotation = (scrollingFrame.BundleFrame.Frame["Primal Pack"].CanvasGroup.Background.Rotation + v2 / 10) % 360
			scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].CanvasGroup.Background.Rotation = (scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].CanvasGroup.Background.Rotation + v2 / 10) % 360
			scrollingFrame.BundleFrame.Frame["Primal Pack"].BundleName.UIGradient.Rotation = (scrollingFrame.BundleFrame.Frame["Primal Pack"].BundleName.UIGradient.Rotation + v2) % 360
			scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].BundleName.UIGradient.Rotation = (scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].BundleName.UIGradient.Rotation + v2) % 360
		end

		scrollingFrame.CodeFrame.Frame.Frame.CanvasGroup.Background.Rotation = (scrollingFrame.CodeFrame.Frame.Frame.CanvasGroup.Background.Rotation + v2 / 10) % 360
		scrollingFrame.CodeFrame.Frame.Frame.UIGradient.Rotation = (scrollingFrame.CodeFrame.Frame.Frame.UIGradient.Rotation + v2 / 2) % 360
		scrollingFrame.CodeFrame.Frame.Frame.CodeBox.UIStroke.UIGradient.Rotation = (scrollingFrame.CodeFrame.Frame.Frame.CodeBox.UIStroke.UIGradient.Rotation + v2) % 360
		scrollingFrame.CodeFrame.Frame.Frame.UIStroke.UIGradient.Rotation = (scrollingFrame.CodeFrame.Frame.Frame.UIStroke.UIGradient.Rotation + v2 * 2) % 360
		local unixTimestamp = DateTime.now().UnixTimestamp

		if flag then
			local v3 = primalPack.UnixTimestamp - unixTimestamp
			local v4 = v3 / 86400
			local v5 = v3 / 3600 % 24
			local v6 = v3 / 60 % 60
			local v7 = v3 % 60
			local v8 = string.format("%02d:%02d:%02d:%02d", v4, v5, v6, v7)
			scrollingFrame.BundleFrame.Frame["Primal Pack"].DayLeft.Text = v8 .. " Left!"
			scrollingFrame.BundleFrame.Frame["Hellroot Bundle"].DayLeft.Text = v8 .. " Left!"

			if primalPack.UnixTimestamp < unixTimestamp then
				scrollingFrame.BundleFrame.Visible = nil
				pcall(function()
					_G.UpdateScrollingShop()
				end)
				flag = nil
			end
		end
	else
		task.wait()
		parent:GetPropertyChangedSignal("Visible"):Wait()
	end
end