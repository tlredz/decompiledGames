local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CUI)
local Config = require(script.Parent.Config)
local Remotes = require(script.Parent.Remotes)
require(script.Parent.Types)
local v = {
	speed = "Speed",
	wins = "Wins"
}

local function parseAssetId(value: string)
	local v2 = string.match(value, "%d+")
	local selected

	if v2 then
		selected = tonumber(v2)
	end

	if selected and selected >= 1 and selected <= Config.MAX_ASSET_ID then
		return selected
	end

	return nil
end

return {
	build = function(object, data)
		local fn

		local function report(p)
			data.report(p, false)
			fn()
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Custom multipliers")
		end)
		local v2 = object:AddText(function(object2)
			object2:SetText(string.format("Active: Speed x%s  ·  Wins x%s", "1", "1"))
		end)
		local idsByLabel = {}
		local v3 = ""

		for _, v4 in Config.MULTIPLIER_KINDS do
			local v5 = v4
			object:AddSplit(function(object2)
				object2:SetRightSizeAbsolute(110)
				local v6 = object2.LeftComponents:AddShortenedNumberField(function(object3)
					object3:SetTextVisible(false):SetPlaceholder(string.format("%s multiplier (x1 clears)", v[v5])):SetNumberFilter(
						1,
						Config.MAX_CUSTOM_MULTIPLIER
					)
				end)
				object2.RightComponents:AddButton(function(object3)
					object3:SetButtonText("Set " .. v[v5]):SetButtonCallback(function()
						local value = v6:GetValue()

						if value == nil then
							data.setStatus("Type a number first", true)
						else
							Remotes.setMultiplier:request(v5, (math.clamp(value, 1, Config.MAX_CUSTOM_MULTIPLIER))):andThen(report):catch(data.reportError)
						end
					end)
				end)
			end)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Boss morph")
		end)
		local v4 = object:AddText(function(object2)
			object2:SetText("Current: your avatar")
		end)
		local v5 = object:AddDropdown(function(object2)
			object2:SetTextVisible(false)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Morph"):SetButtonCallback(function()
					local v6 = idsByLabel[v5:GetValue()]

					if v6 == nil then
						data.setStatus("Pick a boss first", true)
						return
					end

					data.setStatus("Morphing...", false)
					Remotes.morph:request(v6):andThen(report):catch(data.reportError)
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Back to my avatar"):SetButtonCallback(function()
					Remotes.unmorph:request():andThen(report):catch(data.reportError)
				end)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Custom keys")
		end)
		local v6 = object:AddText(function(object2)
			object2:SetText("")
		end)
		local v7 = object:AddDropdown(function(object2)
			object2:SetText("Letter"):SetChoiceList({ "(blank)" }):SetSelectedToFirst()
		end)
		local v8 = object:AddColor(function(object2)
			object2:SetText("Color"):SetColor(Color3.fromRGB(255, 255, 255))
		end)
		local v9 = object:AddSlider(function(object2)
			object2:SetText("Size"):SetRange(Config.KEY_SCALE_MIN, Config.KEY_SCALE_MAX):SetIncrement(Config.KEY_SCALE_STEP):SetValue(1)
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("Decal / image id or link (optional)"):SetValue(""):SetOnChangedRaw(function(p)
				v3 = p
			end)
		end)

		local function spawnKey()
			local v10 = string.match(v3, "^%s*(.-)%s*$")
			local v11

			if v10 == "" then
				v11 = 0
			else
				local v12 = string.match(v10, "%d+")

				if v12 then
					v11 = tonumber(v12)
				end

				if not (v11 and v11 >= 1 and v11 <= Config.MAX_ASSET_ID) then
					v11 = nil
				end
			end

			local value = v7:GetValue()

			if v11 == nil then
				data.setStatus("That is not a valid asset id", true)
				return
			end

			data.setStatus("Spawning key...", false)
			Remotes.spawnKey:request(
				value == "(blank)" and "" or value,
				v8:GetColor(),
				math.clamp(v9:GetValue(), Config.KEY_SCALE_MIN, Config.KEY_SCALE_MAX),
				v11
			):andThen(report):catch(data.reportError)
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Spawn key"):SetButtonCallback(spawnKey)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Undo last"):SetButtonCallback(function()
					Remotes.undoKey:request():andThen(report):catch(data.reportError)
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Clear my keys"):SetButtonColor(Config.DANGER_COLOR):DoNeedConfirmation(true):SetButtonCallback(function()
				Remotes.clearKeys:request():andThen(report):catch(data.reportError)
			end)
		end)

		local function renderMorphs(p)
			table.clear(idsByLabel)
			local labels = {}
			local label = nil

			for _, morph in p.morphs do
				table.insert(labels, morph.label)
				idsByLabel[morph.label] = morph.id

				if morph.id == p.currentMorph then
					label = morph.label
				end
			end

			local value = v5:GetValue()
			v5:SetChoiceList(labels)

			if idsByLabel[value] == nil then
				v5:SetSelectedToFirst()
			end

			v4:SetText(#labels == 0 and "No boss available in this place" or not p.currentMorph and "Current: your avatar" or string.format(
				"Current: %s",
				label or p.currentMorph
			))
		end

		local function renderKeys(data2)
			local keyChars = { "(blank)" }

			for _, keyChar in data2.keyChars do
				table.insert(keyChars, keyChar)
			end

			local value = v7:GetValue()
			v7:SetChoiceList(keyChars)

			if not table.find(keyChars, value) then
				v7:SetSelectedToFirst()
			end

			v6:SetText(string.format("Your keys: %d/%d", data2.keyCount, data2.maxKeys))
		end

		local function render(p)
			v2:SetText(string.format(
				"Active: Speed x%s  ·  Wins x%s",
				tostring(p.multipliers.speed),
				(tostring(p.multipliers.wins))
			))
			renderMorphs(p)
			renderKeys(p)
		end

		fn = function()
			Remotes.getContentState:request():andThen(render):catch(data.reportError)
		end

		return {
			refresh = fn,
			tick = function() end
		}
	end
}