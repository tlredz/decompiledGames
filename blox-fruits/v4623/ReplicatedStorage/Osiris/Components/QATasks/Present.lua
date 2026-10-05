local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local QATask = require(game.ReplicatedStorage.Definitions.QATask)
local CopyText = require(game.ReplicatedStorage.Osiris.Widgets.CopyText)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)
local color = Color3.fromRGB(160, 160, 160)
local color2 = Color3.fromRGB(126, 217, 143)
local color3 = Color3.fromRGB(238, 216, 106)
local color4 = Color3.fromRGB(235, 122, 122)
local color5 = Color3.fromRGB(120, 180, 255)
local Present = {
	MUTED = color,
	GOOD = color2,
	WARN = color3,
	BAD = color4,
	ACCENT = color5,
	note = function(text: string)
		Osiris.Widget.Text({
			Arguments = {
				Text = text,
				Color = color,
				Wrapped = true
			}
		})
	end,
	error = function(text: string)
		Osiris.Widget.Text({
			Arguments = {
				Text = text,
				Color = color4,
				Wrapped = true
			}
		})
	end,
	command = function(text: string, label: string?)
		CopyText({
			Arguments = {
				Text = text,
				Label = label
			}
		})
	end,
	stat = function(p: string, text: string, color6: Color3?)
		Osiris.Widget.SameLine({}, function()
			Osiris.Widget.Text({
				Arguments = {
					Text = `{p}:`,
					Color = color
				}
			})
			Osiris.Widget.Text({
				Arguments = {
					Text = text,
					Color = color6
				}
			})
		end)
	end,
	tags = function(list)
		if list == nil or #list == 0 then
			return
		end

		Osiris.Widget.SameLine({}, function()
			for _, v in list do
				Osiris.Widget.Text({
					Arguments = {
						Text = `[{v}]`,
						Color = color5
					}
				})
			end
		end)
	end,
	progressColor = function(p: number, p2: number)
		if p2 <= 0 or p <= 0 then
			return color
		end

		if p2 <= p then
			return color2
		end

		return color3
	end,
	progressText = function(p: number, p2: number)
		return (`{p}/{p2}`)
	end,
	statusGlyph = function(p: number, p2: number)
		if p2 <= 0 or p <= 0 then
			return "[ ]"
		end

		if p2 <= p then
			return "[x]"
		end

		return "[~]"
	end,
	statusLabel = function(p: number, p2: number)
		if p2 <= 0 or p <= 0 then
			return "NOT COMPLETED"
		end

		if p2 <= p then
			return "COMPLETED"
		end

		return "IN PROGRESS"
	end,
	sourceLabel = function(p)
		if p.Source == "Custom" then
			if p.Scope == "Global" then
				return "custom (all branches)"
			end

			return "custom (this branch)"
		elseif p.Source == "Registered" then
			return "registered in code"
		else
			return "built-in"
		end
	end,
	formatTimestamp = function(p: number)
		local success, result = pcall(function()
			return DateTime.fromUnixTimestamp(p):FormatLocalTime("YYYY-MM-DD HH:mm", "en-us")
		end)

		if success then
			return result
		end

		return (tostring(p))
	end
}

function Present.completionLabel(data)
	return (`by {data.UserName} on {Present.formatTimestamp(data.Timestamp)} ({data.Sha})`)
end

function Present.assignmentLabel(p)
	return (`assigned to {p.UserName}`)
end

function Present.stepLabel(p)
	return QATask.Builders.Step.getLabel(p)
end

function Present.expectationLabel(p)
	return QATask.Builders.Expectation.getLabel(p)
end

function Present.expectationColor(p)
	if p.Type == "Never" then
		return color4
	end

	if p.Type == "Always" then
		return color2
	end

	return color3
end

function Present.icon(p)
	local icon = p.Icon

	if icon == nil then
		return false
	end

	Osiris.Widget.Image({
		Arguments = {
			Image = icon.Image,
			Size = UDim2.fromOffset(18, 18),
			Rect = Rect.new(icon.ImageRectOffset, icon.ImageRectOffset + icon.ImageRectSize),
			ScaleType = Enum.ScaleType.Fit
		}
	})
	return true
end

return Present