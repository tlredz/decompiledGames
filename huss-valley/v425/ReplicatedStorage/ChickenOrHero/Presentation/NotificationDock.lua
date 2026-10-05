return {
	bottom = function(instance, p)
		local notifications = instance:FindFirstChild("Notifications")
		local mainFrame = notifications and notifications:FindFirstChild("MainFrame")
		local notificationsF = mainFrame and mainFrame:FindFirstChild("NotificationsF")
		local v

		if notificationsF then
			v = notificationsF.AbsolutePosition.Y + notificationsF.AbsoluteSize.Y - p.AbsolutePosition.Y

			for _, childName in { "EscapeStreak", "ChoiceAnnouncement" } do
				local child = notificationsF:FindFirstChild(childName)

				if child and child.Visible then
					v = math.max(v, child.AbsolutePosition.Y + child.AbsoluteSize.Y - p.AbsolutePosition.Y)
				end
			end
		else
			v = 16
		end

		return v + 8
	end
}