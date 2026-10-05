local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SammyPortrait = require(script.Parent.SammyPortrait)
local sammyNotif = ReplicatedStorage.Assets.UI.Notifs.SammyNotif

local function startsWith(value: string, list: string)
	return string.sub(value, 1, #list) == list
end

return {
	Create = function(text: string, text2: string)
		local v = (utf8.len(text) or #text) > 56
		local clone = sammyNotif:Clone()
		local main = clone.Main
		local portrait = clone.Portrait
		local sammyName = main.SammyName
		local dialogue = main.Dialogue
		local uIAspectRatioConstraint = clone:FindFirstChildOfClass("UIAspectRatioConstraint")

		if uIAspectRatioConstraint then
			uIAspectRatioConstraint.AspectRatio = clone:GetAttribute(v and "AspectLong" or "AspectShort") or uIAspectRatioConstraint.AspectRatio
		end

		local attribute = clone:GetAttribute(v and "TitleLongY" or "TitleShortY")

		if attribute then
			sammyName.Position = UDim2.fromScale(sammyName.Position.X.Scale, attribute)
		end

		sammyName.Text = text2
		dialogue.Text = text
		local scan = main.Scan
		local children = {}
		local children2 = {}
		local v2 = {}
		local v3 = {}

		for _, child in main:GetChildren() do
			if string.sub(child.Name, 1, 9) == "ChargeArc" then
				table.insert(children, child)
			elseif string.sub(child.Name, 1, 10) == "ChargeGlow" then
				table.insert(children2, child)
			elseif string.sub(child.Name, 1, 10) == "SignalTear" then
				table.insert(v2, {
					Frame = child,
					Position = child.Position
				})
			elseif string.sub(child.Name, 1, 11) == "SignalGhost" then
				child.Text = text2
				table.insert(v3, {
					Label = child
				})
			end
		end

		local v4 = nil
		local v5 = nil
		local v6 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stop()
			if v5 then
				v5()
				v5 = nil
			end

			if v6 then
				v6()
				v6 = nil
			end
		end

		local v7 = false
		return clone, function()
			if v7 or clone.Parent == nil then
				return
			end

			v7 = true
			v4, v5 = SammyPortrait.Mount(portrait)
			local total = 0
			local v8 = -1
			local renderSteppedConnection = nil
			local destroyingConnection = nil

			local function disconnect()
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end

				if destroyingConnection then
					destroyingConnection:Disconnect()
					destroyingConnection = nil
				end
			end

			v6 = disconnect
			destroyingConnection = clone.Destroying:Connect(stop)
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				if clone.Parent == nil then
					stop() -- equivalent call inferred; original call site unknown
				else
					total += dt

					if v4 then
						v4(total)
					end

					local v9 = math.floor(total * 14)

					if v9 ~= v8 then
						v8 = v9

						for _, v10 in children do
							local cells = v10:GetAttribute("Cells")

							if not (typeof(cells) == "Vector2" and cells.X > 0 and cells.Y > 0) then
								continue
							end

							local v11 = v9 + (v10:GetAttribute("Phase") or 0) * 5
							v10.ImageRectOffset = Vector2.new(
								v10.ImageRectSize.X * (v11 % cells.X),
								v10.ImageRectSize.Y * (math.floor(v11 / cells.X) % cells.Y)
							)
						end
					end

					local v10 = total % 2.9
					local v11 = not (v10 < 0.23) and 0 or 1 - v10 / 0.23
					local v12 = math.sin(total * 173) * v11

					for _, v13 in v3 do
						local drift = v13.Label:GetAttribute("Drift") or 1
						v13.Label.Position = sammyName.Position + UDim2.fromScale(
							drift * (math.abs(v12) * 0.007 + 0.004),
							0
						)
						v13.Label.TextTransparency = 1 - v11 * 0.53
					end

					for _, v13 in v2 do
						local drift = v13.Frame:GetAttribute("Drift") or 1
						local phase = v13.Frame:GetAttribute("Phase") or 0
						v13.Frame.Position = v13.Position + UDim2.fromScale(v12 * 0.017 * drift, 0)
						v13.Frame.BackgroundTransparency = 0.67 - v11 * 0.43 + math.sin(total * 2 + phase) * 0.12
					end

					for _, v13 in children2 do
						local phase = v13:GetAttribute("Phase") or 0
						v13.ImageTransparency = math.sin(total * 2.2 + phase) * 0.035 + 0.9
					end

					scan.Position = UDim2.fromScale(0.12, total * 0.19 % 1 * 0.8 + 0.1)
					dialogue.TextTransparency = 0
				end
			end)
		end, stop
	end
}