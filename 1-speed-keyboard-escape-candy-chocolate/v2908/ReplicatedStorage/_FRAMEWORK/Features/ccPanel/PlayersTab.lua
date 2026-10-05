local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CUI)
local CameraTools = require(script.Parent.CameraTools)
local Config = require(script.Parent.Config)
local PlayerPicker = require(script.Parent.PlayerPicker)
local Remotes = require(script.Parent.Remotes)
require(script.Parent.Types)

local function getOnlineTarget(p)
	local target = p.getTarget()
	local player = target and target.player

	if player and player.Parent then
		return player
	end

	return nil
end

local function describeTarget(p)
	if p == nil then
		return "No target selected"
	end

	if p.player then
		return string.format("Target: %s", p.name)
	end

	return string.format("Target: %s (offline)", p.name)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function nextIndex(index: number?, p: number, p2: number)
	if index then
		return (index - 1 + p) % p2 + 1
	end

	if p > 0 then
		return 1
	end

	return p2
end

return {
	build = function(object, data)
		local v = 0
		local v2 = true
		local v3 = {}
		local v4 = nil
		object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(110)
			v4 = object2.LeftComponents:AddText(function(object3)
				object3:SetText("No target selected")
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Choose player"):SetButtonCallback(data.openPlayerPicker)
			end)
		end)
		local v5 = object:AddText(function(object2)
			object2:SetText("Not spectating")
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function spectate(p)
			CameraTools.startSpectate(p)
			data.setStatus(string.format("Spectating %s", p.Name), false)
		end

		local function spectateOffset(p: number)
			local otherPlayers = PlayerPicker.getOtherPlayers()

			if #otherPlayers == 0 then
				data.setStatus("Nobody else is in this server", true)
				return
			end

			local spectateTarget = CameraTools.getSpectateTarget()
			local index

			if spectateTarget then
				index = table.find(otherPlayers, spectateTarget)
			end

			local otherPlayer = otherPlayers[nextIndex(index, p, #otherPlayers)]
			data.setTarget(PlayerPicker.toTarget(otherPlayer))
			spectate(otherPlayer) -- equivalent call inferred; original call site unknown
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("▶ Spectate target"):SetButtonCallback(function()
					local target = data.getTarget()
					local player = target and target.player

					if not (player and player.Parent) then
						player = nil
					end

					if not player then
						data.setStatus("Select an online player first", true)
						return
					end

					spectate(player) -- equivalent call inferred; original call site unknown
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("■ Stop"):SetButtonCallback(function()
					CameraTools.stopSpectate()
					data.setStatus("Spectate stopped", false)
				end)
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("◄ Previous"):SetButtonCallback(function()
					spectateOffset(-1)
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Next ►"):SetButtonCallback(function()
					spectateOffset(1)
				end)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Freecam")
		end)
		local v6 = object:AddButton(function(object2)
			object2:SetButtonText("Enable freecam"):SetButtonCallback(function()
				if CameraTools.isFreecamActive() then
					CameraTools.disableFreecam()
					data.setStatus("Freecam off", false)
				else
					CameraTools.enableFreecam()
					data.setStatus("Freecam on", false)
				end
			end)
		end)
		object:AddSlider(function(object2)
			object2:SetText("Speed"):SetRange(Config.FREECAM_MIN_SPEED, Config.FREECAM_MAX_SPEED):SetIncrement(Config.FREECAM_SPEED_STEP):SetValue(CameraTools.getFreecamSpeed()):SetOnChanged(CameraTools.setFreecamSpeed)
		end)
		object:AddText(function(object2)
			object2:SetText("RMB look · WASD/Q/E move · Shift fast · Esc exits"):SetTextSize(12)
		end)
		local v7 = object:AddTitle(function(object2)
			object2:SetTitle("Troll actions")
		end)
		local v8 = object:AddText(function(object2)
			object2:SetText("Ready")
		end)
		local v9 = object:AddBox(function() end)

		local function syncTrollCooldown(now: number)
			local v10 = v - now
			local v11 = v10 <= 0
			v8:SetText(v11 and "Ready" or string.format("Cooldown: %ds", (math.ceil(v10))))

			if v11 ~= v2 then
				v2 = v11

				for _, v12 in v3 do
					v12:SetEnabled(v11)
				end
			end
		end

		local function runTroll(p)
			local target = data.getTarget()
			local player = target and target.player

			if not (player and player.Parent) then
				player = nil
			end

			if player == nil then
				data.setStatus("Select an online player first", true)
			elseif v2 then
				v = os.clock() + Config.TROLL_COOLDOWN
				Remotes.trollAction:fire(p.id, player.UserId)
				data.setStatus(string.format("%s → %s", p.label, player.Name), false)
				syncTrollCooldown(os.clock())
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addTrollButton(object2, p)
			table.insert(v3, object2:AddButton(function(object3)
				object3:SetButtonText(p.label):SetButtonCallback(function()
					runTroll(p)
				end)
				object3:SetEnabled(v2)
			end))
		end

		local function renderTrollActions(list)
			for _, v10 in v9.Components:GetAll() do
				v10:Destroy()
			end

			table.clear(v3)
			local v10 = #list > 0
			v7:SetVisible(v10)
			v8:SetVisible(v10)
			v9:SetVisible(v10)

			for i = 1, #list, 2 do
				local v11 = i
				v9.Components:AddSplit(function(p)
					addTrollButton(p.LeftComponents, list[v11]) -- equivalent call inferred; original call site unknown
					local v13 = list[v11 + 1]

					if v13 then
						addTrollButton(p.RightComponents, v13) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end

		local function syncCamera()
			local spectateTarget = CameraTools.getSpectateTarget()
			v5:SetText(not spectateTarget and "Not spectating" or string.format("Spectating: %s", spectateTarget.Name))
			v6:SetButtonText(CameraTools.isFreecamActive() and "Disable freecam" or "Enable freecam")
		end

		local function onPlayerRemoving(p)
			if CameraTools.getSpectateTarget() == p then
				CameraTools.stopSpectate()
				data.setStatus(string.format("%s left", p.Name), true)
			end

			local target = data.getTarget()

			if target and target.player == p then
				data.setTarget(nil)
			end
		end

		local v10 = {
			Players.PlayerRemoving:Connect(onPlayerRemoving),
			CameraTools.changed:Connect(syncCamera),
			data.targetChanged:Connect(function()
				v4:SetText(describeTarget(data.getTarget()))
			end)
		}
		v4:GetUI().Destroying:Connect(function()
			for _, connection in v10 do
				connection:Disconnect()
			end
		end)
		renderTrollActions({})
		return {
			refresh = function()
				Remotes.getTrollActions:request():andThen(renderTrollActions):catch(data.reportError)
			end,
			tick = syncTrollCooldown
		}
	end
}