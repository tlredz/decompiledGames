local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
return {
	Init = function()
		task.spawn(function()
			local corruptionCounter = Client.Interface.CorruptionScanner.CorruptionCounter

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				corruptionCounter.Text = "Corruption: " .. math.ceil((workspace:GetAttribute("CorruptionLevel") or 0) * 10) / 10 .. "%"
			end

			workspace:GetAttributeChangedSignal("CorruptionLevel"):Connect(function()
				update() -- equivalent call inferred; original call site unknown
			end)
			corruptionCounter.Text = "Corruption: " .. math.ceil((workspace:GetAttribute("CorruptionLevel") or 0) * 10) / 10 .. "%"
			local riftsCounter = Client.Interface.CorruptionScanner.RiftsCounter

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update2()
				local numberRifts = workspace:GetAttribute("NumberRifts") or 0
				riftsCounter.Text = "Rifts: " .. numberRifts
			end

			workspace:GetAttributeChangedSignal("NumberRifts"):Connect(function()
				update2() -- equivalent call inferred; original call site unknown
			end)
			riftsCounter.Text = "Rifts: " .. (workspace:GetAttribute("NumberRifts") or 0)
		end)
	end
}