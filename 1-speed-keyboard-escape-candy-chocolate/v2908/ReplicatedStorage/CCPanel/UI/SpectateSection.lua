local Players = game:GetService("Players")
local UIKit = require(script.Parent.UIKit)
local CameraTools = require(script.Parent.CameraTools)
local localPlayer = Players.LocalPlayer
return {
	build = function(data)
		local section = data.makeSection(1, 112)
		UIKit.label(
			section,
			"T",
			"Spectate",
			UDim2.new(1, -10, 0, 20),
			UDim2.new(0, 10, 0, 6),
			13,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD
		)
		local label = UIKit.label(
			section,
			"Target",
			"No target",
			UDim2.new(1, -10, 0, 16),
			UDim2.new(0, 10, 0, 28),
			11,
			UIKit.C_SUB,
			UIKit.FONT
		)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, -20, 0, 28)
		frame.Position = UDim2.new(0, 10, 0, 48)
		frame.BackgroundTransparency = 1
		frame.Parent = section
		local btn = UIKit.btn(
			frame,
			"Go",
			"▶ Spectate",
			UDim2.new(0.48, 0, 1, 0),
			UDim2.new(0, 0, 0, 0),
			UIKit.C_ON,
			Color3.new(1, 1, 1)
		)
		local btn2 = UIKit.btn(
			frame,
			"Stop",
			"■ Stop",
			UDim2.new(0.48, 0, 1, 0),
			UDim2.new(0.52, 0, 0, 0),
			UIKit.C_OFF,
			Color3.new(1, 1, 1)
		)
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.new(1, -20, 0, 26)
		frame2.Position = UDim2.new(0, 10, 0, 80)
		frame2.BackgroundTransparency = 1
		frame2.Parent = section
		local btn3 = UIKit.btn(
			frame2,
			"Prev",
			"◄",
			UDim2.new(0, 40, 1, 0),
			UDim2.new(0, 0, 0, 0),
			UIKit.C_ACCENT,
			Color3.new(1, 1, 1)
		)
		local btn4 = UIKit.btn(
			frame2,
			"Next",
			"►",
			UDim2.new(0, 40, 1, 0),
			UDim2.new(1, -40, 0, 0),
			UIKit.C_ACCENT,
			Color3.new(1, 1, 1)
		)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function syncSpecTarget()
			local spectateTarget = CameraTools.getSpectateTarget()
			label.Text = spectateTarget and "▶ " .. spectateTarget.Name or "No target"
		end

		btn.MouseButton1Click:Connect(function()
			local v = data.selection.get()

			if not (v and v.Parent) then
				data.setStatus("Select a player first", true)
				return
			end

			CameraTools.startSpectate(v)
			syncSpecTarget() -- equivalent call inferred; original call site unknown
			data.setStatus("Spectate → " .. v.Name)
		end)
		btn2.MouseButton1Click:Connect(function()
			CameraTools.stopSpectate()
			syncSpecTarget() -- equivalent call inferred; original call site unknown
			data.setStatus("Spectate stopped")
		end)

		local function navigate(p: number)
			local v = {}

			for _, v2 in Players:GetPlayers() do
				if v2 ~= localPlayer then
					table.insert(v, v2)
				end
			end

			if #v == 0 then
				return
			end

			local v2 = 1
			local spectateTarget = CameraTools.getSpectateTarget()

			if spectateTarget then
				for k, v4 in v do
					if v4 ~= spectateTarget then
						continue
					end

					v2 = k
					break
				end
			end

			local v3 = v[(v2 - 1 + p) % #v + 1]
			CameraTools.startSpectate(v3)
			data.selection.select(v3)
			syncSpecTarget() -- equivalent call inferred; original call site unknown
			data.setStatus("Spectate → " .. v3.Name)
		end

		btn3.MouseButton1Click:Connect(function()
			navigate(-1)
		end)
		btn4.MouseButton1Click:Connect(function()
			navigate(1)
		end)
		Players.PlayerRemoving:Connect(function(player)
			if CameraTools.getSpectateTarget() == player then
				CameraTools.stopSpectate()
				syncSpecTarget() -- equivalent call inferred; original call site unknown
				data.setStatus(player.Name .. " left", true)
			end
		end)
		return {}
	end
}