local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = RunService:IsStudio() and not RunService:IsRunning()
local faye = require(ReplicatedStorage.Packages.faye)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Emotes = require(ReplicatedStorage.CAM.Emotes)
local EmotesConfig = require(script.EmotesConfig)
local Wheel = require(script.Wheel)
local localPlayer = Players.LocalPlayer
local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
return function(p)
	local maid = faye.new()
	local initiateState = EmotesConfig.InitiateState()
	local v2 = nil
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setOpen(flag: boolean)
		if initiateState.Value == flag then
			return
		end

		initiateState.Value = flag
	end

	local function pick(p2: string)
		Emotes.Do(p2)
		setOpen(false) -- equivalent call inferred; original call site unknown
	end

	local v4 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply(flag: boolean)
		if flag then
			if v2 == nil then
				v2, v3 = Wheel(p, pick)
				v4 = InputHandler.Block()
			end
		elseif v2 ~= nil then
			v2()
			v2 = nil
			v3 = nil

			if v4 ~= nil then
				v4()
				v4 = nil
			end
		end
	end

	maid:Connect(initiateState.Changed, apply)

	if initiateState.Value then
		apply(true) -- equivalent call inferred; original call site unknown
	else
		apply(false) -- equivalent call inferred; original call site unknown
	end

	if v and initiateState.Value ~= true then
		initiateState.Value = true
	end

	maid:Add(InputHandler.ListenTo("Emotes", function(p2: string, flag: boolean)
		if flag then
			return
		end

		local v5 = Platform_Handler.Platform.Value == "Mobile"

		if p2 == "Up" then
			if v5 or not initiateState.Value then
				return
			end

			local v6

			if v3 ~= nil then
				v6 = v3()
			end

			if v6 ~= nil then
				Emotes.Do(v6)
			end

			setOpen(false) -- equivalent call inferred; original call site unknown
		elseif initiateState.Value then
			if v5 then
				if initiateState.Value == false then
					return
				else
					initiateState.Value = false
				end
			end
		else
			local v6 = Emotes.OnPodium(localPlayer)

			if not (HUD.Value or v6) or not Emotes.Free(localPlayer) or InputHandler.IsBlocked() or not Emotes.Owned(localPlayer) then
				return
			end

			setOpen(true) -- equivalent call inferred; original call site unknown
		end
	end))
	maid:Add(Emotes.Interrupted:Connect(function()
		if initiateState.Value == false then
			return
		end

		initiateState.Value = false
	end))
	maid:Connect(localPlayer.CharacterRemoving, function()
		if initiateState.Value == false then
			return
		end

		initiateState.Value = false
	end)
	return function()
		maid:Destroy()
		apply(false) -- equivalent call inferred; original call site unknown
		initiateState.Value = false
	end
end