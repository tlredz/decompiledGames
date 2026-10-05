local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
return {
	new = function(p)
		local screen = ValleyPanels.screen(p, "CreatorStudio", 83)
		local v = {
			gui = screen
		}
		local button = ValleyPanels.button(screen, "Open", "CREATOR  /  F4", 0, 0, 150, 36)
		v.open = button
		button.AnchorPoint = Vector2.new(1, 0)
		button.Position = UDim2.new(1, -14, 0, 132)
		ValleyTheme.button(button, ValleyTheme.Mint)
		button.TextSize = 11
		local panel, panel2, close = ValleyPanels.panel(screen, "Studio", 550, 528)
		v.shade = panel
		v.panel = panel2
		v.close = close
		panel.BackgroundTransparency = 1
		ValleyTheme.surface(panel2, ValleyTheme.InventoryInk, ValleyTheme.Mint, 6, 0.45)
		ValleyPanels.text(panel2, "Eyebrow", "HUSS VALLEY  /  CONTENT CREATOR", 24, 19, 420, 16, 10, ValleyTheme.Mint)
		local text = ValleyPanels.text(panel2, "Heading", "Creator studio", 24, 45, 450, 36, 27, ValleyTheme.Paper)
		text.Font = Enum.Font.GothamBold
		v.status = ValleyPanels.text(
			panel2,
			"Status",
			"Lobby tools · your character stays here",
			24,
			88,
			500,
			26,
			12,
			ValleyTheme.Muted
		)

		local function action(p2, p3, p4, p5)
			local button2 = ValleyPanels.button(panel2, p2, p3, p5, 127, 244, 68)
			button2.Text = ""
			ValleyTheme.button(button2, ValleyTheme.Mint)
			local text = ValleyPanels.text(button2, "Label", p3, 14, 10, 216, 23, 15, ValleyTheme.Paper)
			text.Font = Enum.Font.GothamBold
			ValleyPanels.text(button2, "Key", p4, 14, 37, 216, 18, 11, ValleyTheme.Muted)
			return button2
		end

		v.camera = action("Camera", "START FREECAM", "F6  ·  toggle camera", 24)
		v.hide = action("CleanFrame", "HIDE UI", "F8  ·  hide / restore everything", 282)
		ValleyPanels.text(panel2, "SpeedTitle", "CAMERA SPEED", 24, 215, 245, 19, 10, ValleyTheme.Muted)
		ValleyPanels.text(panel2, "LensTitle", "LENS / FIELD OF VIEW", 282, 215, 245, 19, 10, ValleyTheme.Muted)
		v.speeds = {}
		v.lenses = {}

		for k, v4 in {
			{ 0.35, "SLOW" },
			{ 0.65, "SMOOTH" },
			{ 1.25, "FAST" }
		} do
			local button2 = ValleyPanels.button(panel2, "Speed" .. k, v4[2], 24 + (k - 1) * 82, 240, 77, 34)
			ValleyTheme.button(button2, ValleyTheme.Blue)
			button2.TextSize = 10
			table.insert(v.speeds, {
				button = button2,
				value = v4[1]
			})
		end

		for k, v4 in {
			{ 40, "CLOSE" },
			{ 60, "NORMAL" },
			{ 80, "WIDE" }
		} do
			local button2 = ValleyPanels.button(panel2, "Lens" .. k, v4[2], 282 + (k - 1) * 82, 240, 77, 34)
			ValleyTheme.button(button2, ValleyTheme.Purple)
			button2.TextSize = 10
			table.insert(v.lenses, {
				button = button2,
				value = v4[1]
			})
		end

		ValleyPanels.make("Frame", panel2, "Rule", {
			Position = UDim2.fromOffset(24, 295),
			Size = UDim2.new(1, -48, 0, 1),
			BackgroundColor3 = ValleyTheme.Border,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0
		})
		ValleyPanels.text(
			panel2,
			"Movement",
			"WASD move   ·   Q / E height   ·   Right-drag look",
			24,
			312,
			502,
			20,
			12,
			ValleyTheme.Paper
		)
		ValleyPanels.text(
			panel2,
			"Recovery",
			"Shift flies faster. F6 or X exits. F4 always brings this panel back.",
			24,
			340,
			502,
			33,
			11,
			ValleyTheme.Muted
		)
		v.commands = ValleyPanels.button(panel2, "Commands", "TROLLS & SERVER COMMANDS  →", 24, 433, 502, 40)
		ValleyTheme.button(v.commands, ValleyTheme.Purple)
		ValleyPanels.text(
			panel2,
			"CommandHint",
			"Try ;bighead me · ;rainbow me · ;confetti me. Effects expire automatically.",
			24,
			480,
			502,
			28,
			11,
			ValleyTheme.Muted
		)
		ValleyPanels.text(
			panel2,
			"AFK",
			"Turn AFK on to stay out of matches while recording.",
			24,
			395,
			502,
			22,
			11,
			ValleyTheme.Gold
		)
		local screen2 = ValleyPanels.screen(p, "CreatorRestore", 1000)
		screen2:SetAttribute("CreatorCaptureExempt", true)
		v.recovery = screen2
		v.restore = ValleyPanels.button(screen2, "Restore", "SHOW UI", 0, 0, 112, 36)
		v.restore.AnchorPoint = Vector2.new(0.5, 1)
		v.restore.Position = UDim2.new(0.5, 0, 1, -16)
		ValleyTheme.button(v.restore, ValleyTheme.Mint)
		screen2.Enabled = false

		function v.render(data, p2, p3, active, p4, p5, p6, p7, p8)
			button.Visible = p3 and not (p2 or p5)
			panel.Visible = p2 and p3
			button.Text = p4 and "CAMERA  /  F4" or "CREATOR  /  F4"
			data.status.Text = active and (p4 and "LIVE CAMERA · character safely in the lobby" or "Lobby tools · your character stays here") or "Camera tools need the lobby · commands are available."
			data.camera.Label.Text = p4 and "EXIT FREECAM" or "START FREECAM"
			data.camera.Active = active or p4
			data.camera.Label.TextTransparency = (active or p4) and 0 or 0.5
			data.hide.Active = active
			data.hide.Label.Text = p5 and "RESTORE UI" or "HIDE UI"

			for _, speed in data.speeds do
				speed.button.BackgroundTransparency = math.abs(p6 - speed.value) < 0.01 and 0 or 0.5
			end

			for _, lens in data.lenses do
				lens.button.BackgroundTransparency = p7 == lens.value and 0 or 0.5
			end

			screen2.Enabled = p5 and p8
		end

		function v.destroy(_)
			screen:Destroy()
			screen2:Destroy()
		end

		return v
	end
}