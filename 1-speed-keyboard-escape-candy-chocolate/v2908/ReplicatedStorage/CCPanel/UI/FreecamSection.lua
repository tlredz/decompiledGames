local UserInputService = game:GetService("UserInputService")
local UIKit = require(script.Parent.UIKit)
local CameraTools = require(script.Parent.CameraTools)
return {
	build = function(p)
		local section = p.makeSection(2, 90)
		UIKit.label(
			section,
			"T",
			"Freecam",
			UDim2.new(1, -10, 0, 20),
			UDim2.new(0, 10, 0, 6),
			13,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD
		)
		local btn = UIKit.btn(
			section,
			"Toggle",
			"Enable",
			UDim2.new(0.5, -14, 0, 28),
			UDim2.new(0, 10, 0, 30),
			UIKit.C_ON,
			Color3.new(1, 1, 1)
		)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0.5, -14, 0, 28)
		frame.Position = UDim2.new(0.5, 4, 0, 30)
		frame.BackgroundTransparency = 1
		frame.Parent = section
		local btn2 = UIKit.btn(frame, "Minus", "−", UDim2.new(0, 26, 1, 0), UDim2.new(0, 0, 0, 0), UIKit.C_ENTRY)
		local label = UIKit.label(
			frame,
			"Val",
			tostring(CameraTools.getFreecamSpeed()),
			UDim2.new(1, -56, 1, 0),
			UDim2.new(0, 28, 0, 0),
			12,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD,
			Enum.TextXAlignment.Center
		)
		local btn3 = UIKit.btn(frame, "Plus", "+", UDim2.new(0, 26, 1, 0), UDim2.new(1, -26, 0, 0), UIKit.C_ENTRY)
		UIKit.label(
			section,
			"Hint",
			"RMB look  ·  WASD/Q/E move  ·  Shift fast",
			UDim2.new(1, -10, 0, 14),
			UDim2.new(0, 8, 1, -16),
			9,
			UIKit.C_SUB,
			UIKit.FONT,
			Enum.TextXAlignment.Center
		)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function syncFcBtn()
			local freecamActive = CameraTools.isFreecamActive()
			btn.Text = freecamActive and "Disable" or "Enable"
			btn.BackgroundColor3 = freecamActive and UIKit.C_OFF or UIKit.C_ON
		end

		btn.MouseButton1Click:Connect(function()
			if CameraTools.isFreecamActive() then
				CameraTools.disableFreecam()
				p.setStatus("Freecam off")
			else
				CameraTools.enableFreecam()
				p.setStatus("Freecam on  —  RMB look, WASD move")
			end

			syncFcBtn() -- equivalent call inferred; original call site unknown
		end)
		btn2.MouseButton1Click:Connect(function()
			label.Text = tostring(CameraTools.addFreecamSpeed(-5))
		end)
		btn3.MouseButton1Click:Connect(function()
			label.Text = tostring(CameraTools.addFreecamSpeed(5))
		end)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.Escape and CameraTools.isFreecamActive() then
				CameraTools.disableFreecam()
				syncFcBtn() -- equivalent call inferred; original call site unknown
				p.setStatus("Freecam off")
			end
		end)
		return {}
	end
}