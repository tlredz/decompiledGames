local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Analysis = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Analysis)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)
local color = Color3.fromRGB(160, 160, 160)
local color2 = Color3.fromRGB(126, 217, 143)
local color3 = Color3.fromRGB(238, 216, 106)
local color4 = Color3.fromRGB(235, 122, 122)
local Present = {
	MUTED = color,
	GOOD = color2,
	WARN = color3,
	BAD = color4,
	rect = function(p)
		return Rect.new(p.ImageRectOffset, p.ImageRectOffset + p.ImageRectSize)
	end
}

function Present.icon(p, p2: number)
	if p == nil then
		return false
	end

	Osiris.Widget.Image({
		Arguments = {
			Image = p.Image,
			Size = UDim2.fromOffset(p2, p2),
			Rect = Present.rect(p),
			ScaleType = Enum.ScaleType.Fit
		}
	})
	return true
end

function Present.note(text: string)
	Osiris.Widget.Text({
		Arguments = {
			Text = text,
			Color = color,
			Wrapped = true
		}
	})
end

function Present.stat(p: string, text: string, color5: Color3?)
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
				Color = color5
			}
		})
	end)
end

function Present.itemButton(p, p2: string, text: string)
	local v = false
	Osiris.Widget.SameLine({}, function()
		Present.icon(p.Sprite, 18)
		v = Osiris.Widget.SmallButton({
			Arguments = {
				Text = `{p2}{p.Label}`
			}
		}).clicked()

		if #text > 0 then
			Osiris.Widget.Text({
				Arguments = {
					Text = text,
					Color = color
				}
			})
		end
	end)
	return v
end

function Present.drillBar(p, text: string, isChecked)
	local v = false
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.Checkbox({
			Arguments = {
				Text = "group by rarity"
			},
			States = {
				isChecked = isChecked
			}
		})

		if isChecked:get() then
			if p == nil then
				Osiris.Widget.Text({
					Arguments = {
						Text = text
					}
				})
				Osiris.Widget.Text({
					Arguments = {
						Text = "- click a rarity to open it",
						Color = color
					}
				})
			else
				v = Osiris.Widget.SmallButton({
					Arguments = {
						Text = "< all rarities"
					}
				}).clicked()
				Osiris.Widget.Text({
					Arguments = {
						Text = `{text} / {p}`
					}
				})
			end
		else
			Osiris.Widget.Text({
				Arguments = {
					Text = text
				}
			})
			Osiris.Widget.Text({
				Arguments = {
					Text = "- every item on its own",
					Color = color
				}
			})
		end
	end)
	return v
end

function Present.deviationColor(p: number)
	local v = math.abs(p)

	if v <= 2 then
		return color2
	end

	if v <= 3 then
		return color3
	end

	return color4
end

function Present.pickerLabel(p)
	return (`{p.Label} [{p.ItemId}]`)
end

function Present.pickerOptions(p)
	local result = table.create(#p.Entries)
	local result2 = {}

	for _, entry in p.Entries do
		local pickerLabel = Present.pickerLabel(entry)
		table.insert(result, pickerLabel)
		result2[pickerLabel] = entry.ItemId
	end

	return result, result2
end

function Present.labelOf(p, p2: number)
	local v

	if p ~= nil then
		v = p.ById[p2]
	end

	if v == nil then
		return (`#{p2}`)
	end

	return v.Label
end

function Present.dirty(p: string)
	local state = Osiris.State("")

	if state:get() == p then
		return false
	end

	state:set(p)
	return true
end

Present.formatChance = Analysis.formatChance
Present.formatOdds = Analysis.formatOdds
return Present