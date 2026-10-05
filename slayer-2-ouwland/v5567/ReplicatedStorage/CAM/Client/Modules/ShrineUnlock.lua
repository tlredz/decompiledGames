local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local WipeTransition = require(ReplicatedStorage.CAM.Client.Components.Misc.Transitions.WipeTransition)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function denied(formatted: string)
	ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", {
		Text = formatted,
		Type = "Denied"
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function combatBlocked()
	if not InCombat.biasedCheck(localPlayer) then
		return false
	end

	denied(`Can't use a shrine while in combat ({Utility.formatTime(InCombat.biasedTimeLeft(localPlayer))} left)`) -- equivalent call inferred; original call site unknown
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lairBlocked()
	local character = localPlayer.Character

	if character == nil or character:GetAttribute("InMuzanLair") ~= true then
		return false
	end

	denied("Can't use a shrine inside Muzan's Lair") -- equivalent call inferred; original call site unknown
	return true
end

local color = Color3.new(1, 0.15, 0.15)
local color2 = Color3.new(1, 0.15, 0.15)

local function priceOf(p: string)
	local Regions = require(ReplicatedStorage.Regions)

	for _, region in Regions.Regions do
		for _, v in region.Shrines or {} do
			if v.Name ~= p then
				continue
			end

			local price = v.Price

			if price == nil then
				return nil
			end

			return price.Wen
		end
	end

	return nil
end

local function wenHeld()
	local data = Utility.GetData(localPlayer)
	local wen

	if data ~= nil then
		wen = data:FindFirstChild("Wen")
	end

	if wen == nil then
		return 0
	end

	return wen.Value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wenText(p: number, flag: boolean)
	local formatted = `{Utility.addCommasToNumber(p)} Wen`

	if flag then
		return (`<font color="#{gameSettings.wenColor:ToHex()}">{formatted}</font>`)
	end

	return (`<s><font color="#{color2:ToHex()}">{formatted}</font></s>`)
end

local function play(childName: string)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local sounds

	if assets ~= nil then
		sounds = assets:FindFirstChild("Sounds") or nil
	end

	local misc

	if sounds ~= nil then
		misc = sounds:FindFirstChild("Misc") or nil
	end

	local sound = misc ~= nil and misc:FindFirstChild(childName) or nil

	if sound == nil or not sound:IsA("Sound") then
		return
	end

	local clone = sound:Clone()
	clone.Parent = script
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength)
end

local v = {}
local ShrineUnlock = {}

function ShrineUnlock.Ask(p: string)
	if v[p] or Archives.IsUnlocked("Shrines", p) then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not combatBlocked() then
		-- equivalent call inferred; original call site unknown
		if not lairBlocked() then
			v[p] = true
			local v2 = priceOf(p)
			local v3 = v2 == nil or v2 <= 0
			local v4

			if v3 then
				v4 = v3
			else
				local data = Utility.GetData(localPlayer)
				local wen

				if data ~= nil then
					wen = data:FindFirstChild("Wen")
				end

				v4 = v2 <= (wen == nil and 0 or wen.Value)
			end

			local text

			if v3 then
				text = `Unlock the {p}?`
			else
				local v7 = wenText(v2, v4) -- equivalent call inferred; original call site unknown
				text = `Unlock the {p} for {v7}?`
			end

			local v6 = PopUpCreator.new({
				Type = "Question",
				Content = not v4 and {
					Text = text,
					Options = {
						{
							Color = color,
							Text = "No"
						}
					}
				} or text,
				Timout = 10
			}):WaitResult()
			v[p] = nil

			if v6 ~= "Yes" then
				return
			end

			local v7 = PopUpCreator.new({
				Type = "LoadingFull"
			})
			local success, result = pcall(SignalFunction.ToServer, "UnlockShrine", p)
			v7:Destroy()
			play(success and result == true and "Money_Kaching" or "denied_old")
		end
	end
end

function ShrineUnlock.Travel(p: string, callback)
	if v[p] or not Archives.IsUnlocked("Shrines", p) then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not combatBlocked() then
		-- equivalent call inferred; original call site unknown
		if not lairBlocked() then
			v[p] = true
			local v2 = PopUpCreator.new({
				Type = "Question",
				Content = `Travel to the {p}?`,
				Timout = 10
			}):WaitResult()
			v[p] = nil

			if v2 ~= "Yes" then
				return
			end

			if callback ~= nil then
				callback()
			end

			local v3 = {
				Switch = false
			}
			WipeTransition(v3)
			task.wait(0.35)
			SignalEvent.ToServer("TravelShrine", p)
			task.wait(0.6)
			v3.Switch = true
		end
	end
end

return ShrineUnlock