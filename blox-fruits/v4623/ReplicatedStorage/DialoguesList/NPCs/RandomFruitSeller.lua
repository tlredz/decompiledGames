local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
local MagnetEvent26 = require(game.ReplicatedStorage.EventConfig.MagnetEvent26)
local v = {
	"Creation-Creation1",
	"Gravity-Gravity1",
	"Gas-Gas1",
	"Tiger-Tiger1",
	"Venom-Venom1",
	"Yeti-Yeti1",
	"Dragon-Dragon1",
	"Eagle-Eagle1",
	"Flame-Flame1",
	"Mammoth-Mammoth1",
	"Sound-Sound1",
	"T-Rex-T-Rex1",
	"Diamond-Diamond1",
	"Kitsune-Kitsune1",
	"Lightning-Lightning1"
}

local function openGachaWindow(object, GachaWindow, p, p2)
	if not DialogueController.Active then
		object:close()
		return
	end

	local flag = false
	local maid = object:getMaid()

	function maid.CloseGachaWindow()
		if flag then
			return
		end

		flag = true
		GachaWindow:Close()
	end

	DialogueController.hideWindow(true)
	GachaWindow:Open(p, p2)

	if not DialogueController.Active then
		GachaWindow:Close()
	end

	GachaWindow:WaitForClose()
	flag = true
	maid.CloseGachaWindow = nil

	if DialogueController.Active then
		DialogueController.unhideWindow()
	end
end

local v2 = DialogueController.new()
v2:setTitle("Zioles")
v2:setTitleSprite(v[1])
local count = 0
v2:onRenderStepped(function(p)
	if p < 0.15 then
		return
	end

	count += 1
	DialogueController.updateTitleSprite(v[count % #v + 1], v[(count + 1) % #v + 1])
	return true
end)
return v2:addPage("Main", function(object)
	local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
	object:addText("Hello, I'm <Color=Yellow>Zioles<Color=/>. I sell random physical fruits to people once every 2 hours. Want to buy a Random Fruit?")
	local dateTimeUTC = MagnetEvent26.NO_MORE_GAMEPLAY_AT:ToDateTimeUTC()

	if DateTime.now().UnixTimestampMillis < dateTimeUTC.UnixTimestampMillis then
		object:addOptionType("Event", function(object2)
			object2:setText("Magnet Event ⏰")
			object2:jumpToPage(function(object3)
				local v3 = GachaClient.CheckGachaAsync("MagnetEventGacha26", "Blox Fruit Gacha")

				if v3.Level.RequirementMet ~= false then
					openGachaWindow(object3, GachaWindow, "MagnetEventGacha26")
					return
				end

				DialogueController.playAction("Negative")
				object3:addText("<Color=Red>You're not ready yet.<Color=/> Come back when you're level <Color=Yellow>" .. v3.Level.Value .. "<Color=/>.")
			end)
		end)
	end

	object:addOptionType("Purchase", function(object2)
		object2:setText("Random Fruit")
		object2:jumpToPage(function(object3)
			local v3 = GachaClient.CheckGachaAsync("ZiolesGacha", "Blox Fruit Gacha")

			if v3.Level.RequirementMet == false then
				DialogueController.playAction("Negative")
				object3:addText("<Color=Red>You're not ready yet.<Color=/> Come back when you're level <Color=Yellow>" .. v3.Level.Value .. "<Color=/>.")
			elseif v3.Level.Current >= 700 or v3.Keys.Silver.RequirementMet then
				object3:addText("...")
				openGachaWindow(object3, GachaWindow, "ZiolesGacha", {
					Name = "Money",
					Value = v3.Price.Value
				})
			else
				object3:addText([[
The higher your level, the more money I'll charge you for a Random Fruit.
You are level <Color=Yellow>]] .. v3.Level.Current .. "<Color=/>, so the next Fruit you purchase is gonna cost you <Color=Green>$" .. TextUtil.commaValue(v3.Price.Value) .. "<Color=/>.")
				object3:addOptionType("Accept", function(object4)
					object4:setText("Understood")
					object4:onSelected(function()
						openGachaWindow(object3, GachaWindow, "ZiolesGacha", {
							Name = "Money",
							Value = v3.Price.Value
						})
					end)
				end)
			end
		end)
	end)
end):build()