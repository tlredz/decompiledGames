local Settings = require(script.Settings)
local localPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Skills_Module = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Skills_Module"))
local PlayerProfile = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerProfile"))
local random = Random.new()

function generate_id()
	return random:NextNumber()
end

local manage_cd = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("manage_cd"))
local v = nil
localPlayer.CharacterRemoving:Connect(function(character)
	v = manage_cd.snapshot(character)
end)
localPlayer.CharacterAdded:Connect(function(character)
	local v2 = v
	v = nil
	manage_cd.restore(character, v2)
end)
local clock = os.clock
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Skill_Switch_Adder = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("Skill_Switch_Adder"))
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local StatsFetch = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local clientEffects = ReplicatedStorage.Communication.CnC.ClientEffects

local function playLaneSound(p, p2: string)
	local v2 = PlayerProfile.skill_info[p2]

	if v2 == nil or v2.CategoryType ~= "Breathing" then
		return
	end

	clientEffects:Fire("Breath", p)
end

local flag = false
local v2 = nil

function Settings.Attempt_Hold(p, value)
	local character = localPlayer.Character

	if flag or character == nil then
		return
	end

	if character:FindFirstChild("SHC") == nil then
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "SHC"
		stringValue:SetAttribute("CK", "")
		stringValue:SetAttribute("en", false)
		stringValue.Parent = character
	end

	local SHC = character.SHC
	local mousepos = Platform_Handler.mousepos(nil, nil, p)

	if p then
		local child = localPlayer:FindFirstChild(p .. Skill_Switch_Adder.extension)

		if child and child:FindFirstChild("Disabled") == nil then
			if SHC:GetAttribute("en") == true or SHC.Value == p then
				return
			end

			child:Destroy()
			local v3 = Skills_Module[p]

			if v3 then
				SignalEvent.ToServer("server_skill_controller_signaler", p, "Switch", mousepos)

				if v3.Switch then
					Skills_Module[p].Id = generate_id()
					v3.Switch(localPlayer, mousepos)
				end
			end

			if SHC.Value == p then
				SHC.Value = ""
			end

			return
		end
	end

	if SHC:GetAttribute("en") == true or Skills_Module.Can_Skill(localPlayer, p) ~= true or Skills_Module[p] == nil or not Checker.check(
		localPlayer,
		p
	) then
		return
	end

	local mousepos2 = Platform_Handler.mousepos(nil, nil, p)
	Settings.AutoUnholdDisabled = nil
	Settings.UnHoldBoolean = nil
	local canPlayOver, v3 = StatsFetch.CanPlayOver(character, p, SHC.Value)
	local v4 = canPlayOver == true and v3 == true

	if v4 ~= true then
		local value2 = SHC.Value

		if #value2 > 0 then
			task.spawn(function()
				Settings.StopHold(value2)
			end)
		end

		SHC:SetAttribute("en", true)
		SHC:SetAttribute("last_performed", clock())

		if SHC.Value ~= "" and Skills_Module[SHC.Value] ~= nil then
			Skills_Module[SHC.Value].Id = generate_id()

			if Skills_Module[SHC.Value].After_Server_Cancel_Signal then
				task.spawn(function()
					local server = SignalFunction.ToServer(
						"server_skill_controller_signaler",
						SHC.Value,
						"Cancel",
						mousepos2
					)
					Skills_Module[SHC.Value].After_Server_Cancel_Signal(localPlayer, mousepos2, server)
				end)
			else
				SignalEvent.ToServer("server_skill_controller_signaler", SHC.Value, "Cancel", mousepos2)
			end

			pcall(Skills_Module[SHC.Value].Cancel, localPlayer, mousepos2)
		end
	end

	PlayerProfile.skill_info[p].lastUsed = clock()
	local id = generate_id()
	Skills_Module[p].Id = id

	if v4 ~= true then
		SHC.Value = p
	end

	if Skills_Module[p].After_Server_Hold_Signal then
		task.spawn(function()
			local server = SignalFunction.ToServer("server_skill_controller_signaler", p, "Hold", mousepos2)

			if character:FindFirstChild("SHCS") and character.SHCS.Value == p then
				Skills_Module[p].After_Server_Hold_Signal(localPlayer, mousepos2, server)
			end
		end)
	else
		SignalEvent.ToServer("server_skill_controller_signaler", p, "Hold", mousepos2)
	end

	if v4 == true then
		SHC:SetAttribute("CK2", value or "")
		SHC:SetAttribute("LastCkType", "CK2")
	else
		SHC:SetAttribute("CK", value or "")
		SHC:SetAttribute("LastCkType", "CK")
	end

	local v6 = PlayerProfile.skill_info[p]

	if v6 ~= nil and v6.CategoryType == "Breathing" then
		clientEffects:Fire("Breath", character)
	end

	if Skills_Module[p].Hold then
		local success, result = pcall(Skills_Module[p].Hold, localPlayer, mousepos2)

		if not success then
			result = false
		end

		if result == false and SHC.Value == p and v4 ~= true then
			SHC.Value = ""
		elseif result == true and SHC.Value == p and v4 ~= true then
			local fetched = manage_cd.fetch(localPlayer, p)

			if fetched and fetched > 0 then
				manage_cd.set_skill_cd(localPlayer, p, fetched)
			end

			if p ~= "Dash" and p ~= "Double_Jump" then
				PlayerProfile.lastperformedaskill = clock()
			end

			SHC.Value = ""
		end
	end

	SHC:SetAttribute("en", false)

	if Skills_Module[p].Id == id then
		Settings.Canceld = nil
	end

	return true
end

function Settings.Counter(p, p2, p3, ...)
	local SHC = localPlayer.Character:FindFirstChild("SHC")

	if SHC == nil or flag then
		return
	end

	local v3 = SHC.Value == p

	if not v3 then
		local getvaluesfolder = Utility.getvaluesfolder(localPlayer)
		local counter

		if getvaluesfolder ~= nil then
			counter = getvaluesfolder:FindFirstChild("Counter") or nil
		end

		if counter == nil then
			v3 = false
		else
			v3 = counter:IsA("StringValue") and counter.Value == p
		end
	end

	if v3 then
		SHC:SetAttribute("en", true)
		Settings.UnHoldBoolean = nil
		local id = generate_id()
		Skills_Module[p].Id = id
		local mousepos = Platform_Handler.mousepos(nil, nil, p)

		if p3 == nil or p3 == true then
			if Skills_Module[p].After_Server_Counter_Signal then
				task.spawn(function()
					local server = SignalFunction.ToServer("server_skill_controller_signaler", p, "Counter", mousepos)
					Skills_Module[p].After_Server_Counter_Signal(localPlayer, mousepos, server)
				end)
			else
				SignalEvent.ToServer("server_skill_controller_signaler", p, "Counter", mousepos)
			end
		end

		local v5 = p .. Skill_Switch_Adder.extension

		if localPlayer:FindFirstChild(v5) then
			localPlayer:FindFirstChild(v5):Destroy()
		end

		if p2 == nil or p2 == true then
			local fetched = manage_cd.fetch(localPlayer, p)

			if fetched and fetched > 0 and SHC.Value == p then
				manage_cd.set_skill_cd(localPlayer, p, fetched)
			end
		end

		if SHC.Value == p then
			SHC.Value = ""
		end

		if Skills_Module[p].Counter then
			Skills_Module[p].Counter(localPlayer, mousepos, ...)
		end

		if Skills_Module[p].Id == id then
			SHC:SetAttribute("en", false)
		end

		Settings.Canceld = nil
	end
end

function Settings.Toggle(p, _, _, ...)
	if flag then
		return
	end

	Skills_Module[p].Id = generate_id()

	if Skills_Module[p].Toggle then
		Skills_Module[p].Toggle(localPlayer, ...)
	end
end

function Settings.StopHold(p: string, p2: number?, flag2: boolean?, flag3: boolean?)
	if Skills_Module[p] == nil then
		return false
	end

	local SHC = localPlayer.Character:FindFirstChild("SHC")

	if SHC == nil or SHC:GetAttribute("en") == true or flag then
		return false
	end

	local canPlayOver, v3 = StatsFetch.CanPlayOver(localPlayer.Character, p, SHC.Value)
	local v4 = canPlayOver == true and v3 == true

	if not (SHC.Value == p or v4) then
		return false
	end

	local value = SHC.Value
	flag = true
	Settings.UnHoldBoolean = nil
	SHC:SetAttribute("en", true)
	local id = generate_id()
	Skills_Module[p].Id = id
	local mousepos = Platform_Handler.mousepos(nil, nil, p)

	if flag2 == nil or flag2 == true then
		if Skills_Module[p].After_Server_Unhold_Signal then
			task.spawn(function()
				local toServer = SignalFunction.ToServer
				local v10

				if PlayerProfile.skill_info[p].UnholdStatus then
					v10 = flag3
				end

				local v11 = toServer("server_skill_controller_signaler", p, "UnHold", mousepos, v10)
				local after_Server_Unhold_Signal = Skills_Module[p].After_Server_Unhold_Signal
				local v14

				if PlayerProfile.skill_info[p].UnholdStatus then
					v14 = flag3
				end

				after_Server_Unhold_Signal(localPlayer, mousepos, v11, v14)
			end)
		else
			local toServer = SignalEvent.ToServer
			local v8

			if PlayerProfile.skill_info[p].UnholdStatus then
				v8 = flag3
			end

			toServer("server_skill_controller_signaler", p, "UnHold", mousepos, v8)
		end
	end

	if p ~= "Dash" and p ~= "Double_Jump" then
		PlayerProfile.lastperformedaskill = clock()
	end

	if p2 == nil or p2 == true then
		local fetched = manage_cd.fetch(localPlayer, p)

		if fetched and fetched > 0 and (SHC.Value == p or v4) then
			manage_cd.set_skill_cd(localPlayer, p, fetched)
		end
	end

	if v4 ~= true and (SHC.Value == p or p ~= value) then
		SHC.Value = ""
	end

	SHC:SetAttribute("CK2", "")

	if Skills_Module[p].UnHold then
		v2 = p
		local success, result = pcall(function()
			return { Skills_Module[p].UnHold(localPlayer, mousepos, flag3) }
		end)
		v2 = nil
		local v6 = not success and {} or result

		if v6 == nil or not (#v6 > 0) then
			SignalEvent.ToServer("server_skill_controller_signaler", p, "Cancel", mousepos)
		else
			local toServer = SignalEvent.ToServer

			if not PlayerProfile.skill_info[p].UnholdStatus then
				flag3 = nil
			end

			toServer("server_skill_controller_signaler", p, "UnHoldAfterClient", mousepos, flag3, table.unpack(v6))
		end
	end

	SHC:SetAttribute("en", false)
	flag = false
	Settings.Canceld = nil
	return true
end

local function releases(value, name: string)
	if type(value) ~= "string" or value == "" then
		return false
	end

	if value == name then
		return true
	end

	if value:find("+", 1, true) == nil then
		return false
	end

	local v3 = false

	for _, v4 in string.split(value, "+") do
		if v4 == name then
			v3 = true
		elseif Enum.KeyCode[v4] ~= nil and UserInputService:IsGamepadButtonDown(
			Enum.UserInputType.Gamepad1,
			Enum.KeyCode[v4]
		) then
			return false
		end
	end

	return v3
end

UserInputService.InputEnded:Connect(function(input)
	if localPlayer ~= nil and localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("SHC") ~= nil then
		local SHC = localPlayer.Character.SHC
		local name = input.KeyCode.Name

		if releases(SHC:GetAttribute("CK"), name) or releases(SHC:GetAttribute("CK2"), name) then
			local value = SHC.Value

			if value ~= nil and value ~= "" then
				Settings.UnHoldBoolean = true
			end
		end
	end
end)
task.spawn(function()
	local clock2 = os.clock

	while true do
		if localPlayer.Character ~= nil then
			local SHC = localPlayer.Character:FindFirstChild("SHC")
			local v3 = false

			if Settings.UnHoldAllBoolean then
				local heldSkill = Settings.HeldSkill

				if (heldSkill == nil or heldSkill == "") and SHC ~= nil and SHC.Value ~= "" then
					heldSkill = SHC.Value
				end

				if heldSkill == nil or heldSkill == "" then
					Settings.UnHoldAllBoolean = nil
				elseif Settings.StopHold(heldSkill) and heldSkill == Settings.HeldSkill then
					Settings.HeldSkill = nil
					Settings.CurrentMax = nil
				end

				v3 = true
			elseif Settings.UnHoldTarget ~= nil then
				local unHoldTarget = Settings.UnHoldTarget

				if Settings.UnHoldTargetUntil == nil or not (clock2() > Settings.UnHoldTargetUntil) then
					if Settings.StopHold(unHoldTarget) then
						Settings.UnHoldTarget = nil
						Settings.UnHoldTargetUntil = nil

						if unHoldTarget == Settings.HeldSkill then
							Settings.HeldSkill = nil
							Settings.CurrentMax = nil
						end
					end
				else
					Settings.UnHoldTarget = nil
					Settings.UnHoldTargetUntil = nil
				end

				v3 = true
			end

			if not v3 and Settings.UnHoldBoolean then
				if Settings.StopHold(Settings.HeldSkill) then
					Settings.HeldSkill = nil
					Settings.CurrentMax = nil
				end

				v3 = true
			end

			if not v3 and SHC ~= nil and SHC.Value ~= "" then
				local last_performed = SHC:GetAttribute("last_performed")

				if Settings.CurrentMax ~= nil and Settings.CurrentMax > 0 and last_performed ~= nil and clock2() - last_performed > Settings.CurrentMax and Settings.AutoUnholdDisabled == nil and Settings.StopHold(
					Settings.HeldSkill,
					nil,
					nil,
					true
				) then
					Settings.HeldSkill = nil
					Settings.CurrentMax = nil
				end
			end

			if SHC ~= nil and SHC:GetAttribute("en") ~= true and Platform_Handler.Platform.Value == "PC" and not InputHandler.IsDown("Skills_1st") then
				local getvaluesfolder = Utility.getvaluesfolder(localPlayer)

				if getvaluesfolder ~= nil and getvaluesfolder:FindFirstChild("Blocking") ~= nil then
					if SHC.Value == "Blocking" then
						if Settings.StopHold("Blocking") and Settings.HeldSkill == "Blocking" then
							Settings.HeldSkill = nil
							Settings.CurrentMax = nil
						end
					elseif Settings.LastBlockingNudge == nil or clock2() - Settings.LastBlockingNudge > 1 then
						Settings.LastBlockingNudge = clock2()
						SignalEvent.ToServer(
							"server_skill_controller_signaler",
							"Blocking",
							"UnHold",
							Platform_Handler.mousepos(nil, nil, "Blocking")
						)
					end
				end
			end

			if SHC ~= nil and SHC.Value ~= "" then
				local character = localPlayer.Character

				if Settings.Canceld == true or character == nil or character:FindFirstChild("Humanoid") == nil or character.Humanoid.Health == 0 then
					Settings.ForceCancel(SHC.Value)
					Settings.HeldSkill = nil
					Settings.CurrentMax = nil
				end
			end
		end

		task.wait(0.05)
	end
end)

function Settings.ForceCancel(p, p2, p3)
	local character = localPlayer.Character

	if character == nil or Skills_Module[p] == nil then
		return
	end

	local SHC = character:FindFirstChild("SHC")

	if SHC == nil then
		return
	end

	if flag then
		if p2 == false and p3 == false and v2 == p then
			Skills_Module[p].Id = generate_id()

			if Skills_Module[p].Cancel then
				pcall(Skills_Module[p].Cancel, localPlayer, Platform_Handler.mousepos(nil, nil, p))
			end
		end
	else
		local canPlayOver, v3 = StatsFetch.CanPlayOver(character, p, SHC.Value)
		local v4 = canPlayOver == true and v3 == true

		if SHC.Value == p or v4 then
			SHC:SetAttribute("en", true)
			Settings.UnHoldBoolean = nil
			flag = true
			local id = generate_id()
			local mousepos = Platform_Handler.mousepos(nil, nil, p)
			Skills_Module[p].Id = id

			if p3 == nil or p3 == true then
				if Skills_Module[p].After_Server_Cancel_Signal then
					task.spawn(function()
						local server = SignalFunction.ToServer(
							"server_skill_controller_signaler",
							p,
							"Cancel",
							mousepos
						)
						Skills_Module[p].After_Server_Cancel_Signal(localPlayer, mousepos, server)
					end)
				else
					SignalEvent.ToServer("server_skill_controller_signaler", p, "Cancel", mousepos)
				end
			end

			local v6 = p .. Skill_Switch_Adder.extension

			if localPlayer:FindFirstChild(v6) then
				localPlayer:FindFirstChild(v6):Destroy()
			end

			local v7

			if p == "Blocking" then
				v7 = PlayerProfile.skill_info[p]
			end

			local v8

			if v7 == nil or v7.lastUsed == nil then
				v8 = false
			else
				v8 = clock() - v7.lastUsed < gameSettings.BlockCancelNoCooldownWindow
			end

			if (p2 == nil or p2 == true) and not v8 then
				local fetched = manage_cd.fetch(localPlayer, p)

				if fetched and fetched > 0 and (SHC.Value == p or v4) then
					manage_cd.set_skill_cd(localPlayer, p, fetched)
				end
			end

			if v4 ~= true and SHC.Value == p then
				SHC.Value = ""
			end

			if Skills_Module[p].Cancel then
				pcall(Skills_Module[p].Cancel, localPlayer, mousepos)
			end

			SHC:SetAttribute("en", false)
			flag = false
			Settings.Canceld = nil
		end
	end
end

return Settings