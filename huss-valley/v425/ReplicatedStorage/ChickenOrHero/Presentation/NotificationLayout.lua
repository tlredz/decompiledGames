return {
	apply = function(p)
		local notificationsF = p.MainFrame.NotificationsF
		notificationsF:SetAttribute("UIProportionalGroup", nil)

		for _, childName in { "Proportions", "SizeLimits" } do
			local child = notificationsF:FindFirstChild(childName)

			if child then
				child:Destroy()
			end
		end

		local function label(instance, font, _, textSize)
			instance.BackgroundTransparency = 1
			instance.BorderSizePixel = 0
			instance.TextScaled = true
			instance.TextWrapped = true
			instance.Font = font
			instance.TextStrokeColor3 = Color3.fromRGB(15, 25, 29)
			instance.TextStrokeTransparency = 0.65
			instance.TextXAlignment = Enum.TextXAlignment.Center
			instance.TextYAlignment = Enum.TextYAlignment.Center
			instance.TextSize = textSize
			instance.TextTruncate = Enum.TextTruncate.None

			for _, uITextSizeConstraint in instance:GetChildren() do
				if uITextSizeConstraint:IsA("UITextSizeConstraint") then
					uITextSizeConstraint:Destroy()
				end
			end
		end

		local frame = notificationsF.Frame
		frame.AnchorPoint = Vector2.zero
		frame.Position = UDim2.fromScale(0, 0)
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		label(frame.Location, Enum.Font.GothamBold, 9, 12)
		label(frame.WhatsHappening, Enum.Font.GothamBold, 12, 23)
		label(frame.Hint, Enum.Font.GothamMedium, 9, 12)
		frame.Location.AnchorPoint = Vector2.zero
		frame.Location.Position = UDim2.fromScale(0, 0)
		frame.Location.Size = UDim2.fromScale(1, 0.18)
		frame.WhatsHappening.AnchorPoint = Vector2.zero
		frame.WhatsHappening.Position = UDim2.fromScale(0.025, 0.23)
		frame.WhatsHappening.Size = UDim2.fromScale(0.95, 0.52)
		frame.Hint.AnchorPoint = Vector2.zero
		frame.Hint.Position = UDim2.fromScale(0, 0.81)
		frame.Hint.Size = UDim2.fromScale(1, 0.18)
		frame.Hint.TextTransparency = 0.15
		local escapeStreak = notificationsF.EscapeStreak
		escapeStreak.Position = UDim2.new(0.5, 0, 1, 7)
		escapeStreak.AnchorPoint = Vector2.new(0.5, 0)
		label(escapeStreak.Caption, Enum.Font.GothamBold, 9, 10)
		label(escapeStreak.Count, Enum.Font.GothamBold, 9, 11)
		label(escapeStreak.Hint, Enum.Font.GothamMedium, 8, 10)
		escapeStreak.Caption.TextXAlignment = Enum.TextXAlignment.Left
		escapeStreak.Count.TextXAlignment = Enum.TextXAlignment.Right
		escapeStreak.Caption.Position = UDim2.fromScale(0, 0)
		escapeStreak.Caption.Size = UDim2.fromScale(0.88, 0.32)
		escapeStreak.Count.Position = UDim2.fromScale(0.88, 0)
		escapeStreak.Count.Size = UDim2.fromScale(0.12, 0.32)
		escapeStreak.Segments.Position = UDim2.fromScale(0, 0.42)
		escapeStreak.Segments.Size = UDim2.fromScale(1, 0.065)

		for _, frame2 in escapeStreak.Segments:GetChildren() do
			if frame2:IsA("Frame") then
				frame2.BackgroundTransparency = 0.6
			end
		end

		escapeStreak.Hint.Position = UDim2.fromScale(0, 0.62)
		escapeStreak.Hint.Size = UDim2.fromScale(1, 0.34)
		escapeStreak.Hint.TextTransparency = 0.15
		local choiceAnnouncement = notificationsF.ChoiceAnnouncement
		label(choiceAnnouncement.Title, Enum.Font.GothamBold, 12, 19)
		label(choiceAnnouncement.Description, Enum.Font.GothamMedium, 9, 12)
		choiceAnnouncement.Title.Position = UDim2.fromScale(0, 0.14)
		choiceAnnouncement.Title.Size = UDim2.fromScale(1, 0.47)
		choiceAnnouncement.Description.Position = UDim2.fromScale(0, 0.68)
		choiceAnnouncement.Description.Size = UDim2.fromScale(1, 0.27)
		choiceAnnouncement.Description.TextTransparency = 0.12
		choiceAnnouncement.Accent.Size = UDim2.new(0.1, 0, 0, 1)
		choiceAnnouncement.Accent.BackgroundTransparency = 0.25

		local function resize()
			local absoluteSize = p.MainFrame.AbsoluteSize
			local v = math.clamp(absoluteSize.Y / 720, 0.75, 1.15)
			local v2 = math.min(
				absoluteSize.X - 28,
				(math.clamp(absoluteSize.X * (absoluteSize.X < absoluteSize.Y and 0.9 or 0.52), 280, 640))
			)
			local v3 = v * 12

			if absoluteSize.X < absoluteSize.Y then
				local parent = p.Parent
				local valleyHUD = parent:FindFirstChild("ValleyHUD")
				local adminUI = parent:FindFirstChild("AdminUI")

				for _, v4 in {
					valleyHUD and valleyHUD:FindFirstChild("Servers"),
					valleyHUD and valleyHUD:FindFirstChild("Updates"),
					adminUI and adminUI:FindFirstChild("OpenBroadcast")
				} do
					if v4 and v4.Visible then
						v3 = math.max(
							v3,
							v4.AbsolutePosition.Y + v4.AbsoluteSize.Y - p.MainFrame.AbsolutePosition.Y + 10
						)
					end
				end
			end

			notificationsF.AnchorPoint = Vector2.new(0.5, 0)
			notificationsF.Position = UDim2.new(0.5, 0, 0, v3)
			notificationsF.Size = UDim2.fromOffset(math.max(100, v2), v * 76)
			escapeStreak.Size = UDim2.fromOffset(math.min(v2 * 0.8, v * 290), v * 40)
			choiceAnnouncement.Size = UDim2.new(1, 0, 0, v * 58)
		end

		resize()
		return p.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize), resize
	end
}