local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local function flopDbg(...) end

local function btrace(...) end

local v = nil
local v2 = nil
local modules = ReplicatedStorage:FindFirstChild("Modules")
local effects = modules and modules:FindFirstChild("Effects")
local syncedAnimationController = effects and effects:FindFirstChild("SyncedAnimationController")

if syncedAnimationController then
	local success, result = pcall(require, syncedAnimationController)

	if success then
		v = result
	end
end

local genArcade = modules and modules:FindFirstChild("GenArcade")
local swimmyBarnaby = genArcade and genArcade:FindFirstChild("SwimmyBarnaby")
local flopConfig = swimmyBarnaby and swimmyBarnaby:FindFirstChild("FlopConfig")

if flopConfig then
	local success, result = pcall(require, flopConfig)

	if success then
		v2 = result
	end
end

local function resolveFlopTemplate()
	if not v2 then
		return nil
	end

	local child = ReplicatedStorage

	for _, childName in ipairs(v2.templatePath) do
		child = child and child:FindFirstChild(childName)
	end

	return child
end

local function localPlayerIsFinn()
	local character = localPlayer.Character
	local config = character and character:FindFirstChild("Config")
	local characterName = config and config:FindFirstChild("CharacterName")
	return characterName ~= nil and characterName.Value == "Finn"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRemote(childName: string)
	local events = ReplicatedStorage:WaitForChild("Events", 30)

	if events then
		return events:WaitForChild(childName, 30)
	end

	return nil
end

local remote = getRemote("BarnabyEnterEvent") -- equivalent call inferred; original call site unknown
local remote2 = getRemote("BarnabyTickEvent") -- equivalent call inferred; original call site unknown
local remote3 = getRemote("BarnabyExitEvent") -- equivalent call inferred; original call site unknown
local remote4 = getRemote("BarnabyDiedEvent") -- equivalent call inferred; original call site unknown
local remote5 = getRemote("BarnabyLeaveEvent") -- equivalent call inferred; original call site unknown
local remote6 = getRemote("BarnabyCoinEvent") -- equivalent call inferred; original call site unknown
local remote7 = getRemote("BarnabyGoodEvent") -- equivalent call inferred; original call site unknown
local remote8 = getRemote("BarnabyFlopEvent") -- equivalent call inferred; original call site unknown
local remote9 = getRemote("BarnabyBootedEvent") -- equivalent call inferred; original call site unknown

if not (remote and remote2 and remote3 and remote4) then
	warn("[BarnabyMinigameClient] missing one or more arcade remotes; client driver disabled")
	return
end

local v3 = nil
local flag = nil

local function getInputService()
	if flag then
		return v3
	end

	flag = true
	local sharedUtils = ReplicatedStorage:FindFirstChild("SharedUtils")
	local inputService = sharedUtils and sharedUtils:FindFirstChild("InputService")

	if inputService then
		local success, result = pcall(require, inputService)

		if success then
			v3 = result
		end
	end

	return v3
end

local function getArcadeContent()
	local v4 = os.clock() + 10

	-- equivalent calls inferred from this helper; original call sites unknown
	local function waitFor(instance, childName)
		if not instance then
			return nil
		end

		local v5 = v4 - os.clock()

		if v5 <= 0 then
			return instance:FindFirstChild(childName)
		end

		return instance:WaitForChild(childName, v5)
	end

	local v6 = waitFor(ReplicatedStorage, "Parts") -- equivalent call inferred; original call site unknown
	local v7 = waitFor(v6, "ArcadeGames_Machine") -- equivalent call inferred; original call site unknown
	local assets = waitFor(v7, "SwimmyBarnaby") -- equivalent call inferred; original call site unknown
	local v10 = waitFor(ReplicatedStorage, "Modules") -- equivalent call inferred; original call site unknown
	local v11 = waitFor(v10, "GenArcade") -- equivalent call inferred; original call site unknown
	local module = waitFor(v11, "SwimmyBarnaby") -- equivalent call inferred; original call site unknown

	if assets and module then
		return {
			Assets = assets,
			Module = module
		}
	end

	warn("[BarnabyMinigameClient] arcade content missing -- need both ReplicatedStorage.Parts.ArcadeGames_Machine.SwimmyBarnaby and ReplicatedStorage.Modules.GenArcade.SwimmyBarnaby")
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findOverlay(instance, value: string?)
	return instance:FindFirstChild("SwimmyBarnaby" .. (type(value) == "string" and value or "")) or instance:FindFirstChild("SwimmyBarnaby") or instance:FindFirstChild("SwimmyBarnaby_Mirror")
end

local v4 = {
	Back = true,
	Press_Start = true,
	You_win = true,
	You_lose = true,
	Try_again = true,
	Alerted = true
}

local function isStateSurfaceGui(surfaceGui)
	if surfaceGui:FindFirstChild("BarnabyLiveMirror") then
		return true
	end

	for _, guiObject in ipairs(surfaceGui:GetChildren()) do
		if (guiObject:IsA("ImageLabel") or guiObject:IsA("Frame")) and v4[guiObject.Name] then
			return true
		end
	end

	return false
end

local function findScreenGui(folder, p)
	if not folder then
		return nil
	end

	for _, surfaceGui in ipairs(folder:GetDescendants()) do
		if surfaceGui:IsA("SurfaceGui") and (surfaceGui.Parent == p or surfaceGui.Adornee == p) and not isStateSurfaceGui(surfaceGui) then
			return surfaceGui
		end
	end

	return nil
end

local function setOverlayLightsEnabled(folder, enabled: boolean)
	if not folder then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("SurfaceLight") then
			descendant.Enabled = false
		elseif descendant:IsA("Light") and descendant.Name ~= "BarnabyIdleGlow" then
			descendant.Enabled = enabled
		end
	end
end

local color = Color3.fromRGB(120, 200, 255)

local function addCabinetGlow(part)
	if not (part and part:IsA("BasePart")) then
		return function() end
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Name = "BarnabyCabinetGlow"
	pointLight.Color = color
	pointLight.Brightness = 4
	pointLight.Range = 14
	pointLight.Parent = part
	return function()
		pcall(function()
			pointLight:Destroy()
		end)
	end
end

local color2 = Color3.fromRGB(80, 255, 200)

local function setupFillScreen(folder, p, instance)
	if not folder then
		return function() end
	end

	local parent = nil

	for _, part in ipairs(folder:GetDescendants()) do
		local name = part.Name:lower()

		if not part:IsA("BasePart") or not name:find("screen") or name:find("border") or part == p then
			continue
		end

		parent = part
		break
	end

	if not parent then
		warn("[BarnabyMinigameClient] no secondary screen found for the FILL % readout")
		return function() end
	end

	local stats = instance:FindFirstChild("Stats")
	local currentAmount = stats and stats:FindFirstChild("CurrentAmount")
	local requiredAmount = stats and stats:FindFirstChild("RequiredAmount")
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "BarnabyFillScreen"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.AlwaysOnTop = false
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 250
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.Arcade
	textLabel.TextColor3 = color2
	textLabel.TextScaled = true
	textLabel.Text = "0%"
	textLabel.Parent = surfaceGui
	surfaceGui.Parent = parent

	local function refresh()
		textLabel.Text = (not (currentAmount and requiredAmount and requiredAmount.Value > 0) and 0 or math.clamp(
			math.floor(currentAmount.Value / requiredAmount.Value * 100 + 0.5),
			0,
			100
		)) .. "%"
	end

	textLabel.Text = (not (currentAmount and requiredAmount and requiredAmount.Value > 0) and 0 or math.clamp(
		math.floor(currentAmount.Value / requiredAmount.Value * 100 + 0.5),
		0,
		100
	)) .. "%"
	local valueChangedConnection = currentAmount and currentAmount:GetPropertyChangedSignal("Value"):Connect(refresh)
	return function()
		if valueChangedConnection then
			valueChangedConnection:Disconnect()
		end

		pcall(function()
			surfaceGui:Destroy()
		end)
	end
end

local function getMyReplicaSafe()
	local success, result = pcall(function()
		return ReplicatedStorage:WaitForChild("Modules", 5)
	end)

	if not (success and result) then
		return nil
	end

	local clientUI = result:FindFirstChild("ClientUI")
	local myDataController = clientUI and clientUI:FindFirstChild("MyDataController")

	if not myDataController then
		return nil
	end

	local success2, result2 = pcall(require, myDataController)

	if not (success2 and result2) then
		return nil
	end

	local v5 = type(result2.getMyReplica) == "function" and result2:getMyReplica()

	if v5 then
		return v5
	end

	if type(result2.onReplicaReady) ~= "function" then
		return nil
	end

	local v6 = nil
	result2:onReplicaReady(function(p)
		v6 = p
	end)
	local lastTime = tick()

	while not v6 and tick() - lastTime < 3 do
		task.wait()
	end

	return v6
end

remote.OnClientEvent:Connect(function(instance, value, value2)
	btrace(string.format(
		"[BarnabyTrace] ENTER received — model=%s modelParent=%s session=%s suffix=%s",
		not instance and "nil" or instance.Name or "nil",
		not instance and "nil" or tostring(instance.Parent ~= nil) or "nil",
		tostring(value),
		(tostring(value2))
	))

	if not (instance and instance.Parent) then
		btrace("[BarnabyTrace] ENTER bailed: model nil / not parented (silent early-return) — one way you end up committed with NO client UI")
		return
	end

	local slotSuffix = type(value2) == "string" and (value2 or "") or ""
	local v6 = type(value) == "string" and value or instance:GetAttribute("BarnabyId") or "BarnabyGen_local_" .. tostring(instance)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		local count = 0

		for _, child in ipairs(playerGui:GetChildren()) do
			if child:GetAttribute("BarnabyArcadeSession") == nil then
				continue
			end

			count += 1
			local v7 = child
			pcall(function()
				v7:Destroy()
			end)
		end

		if count > 0 then
			btrace(string.format(
				"[BarnabyTrace] ENTER swept %d orphaned arcade GUI corpse(s) from PlayerGui before boot (self-heal: bugged machine no longer needs a 2nd machine to clear)",
				count
			))
		end
	end

	local v7 = nil

	local function showFallbackExit()
		if v7 then
			return
		end

		local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui2 then
			return
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BarnabyFallbackExit"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 50
		screenGui.Parent = playerGui2
		v7 = screenGui
		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.Position = UDim2.fromScale(0.5, 0.86)
		textLabel.Size = UDim2.fromOffset(420, 30)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Arcade
		textLabel.TextSize = 18
		textLabel.TextColor3 = Color3.fromRGB(255, 230, 120)
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextStrokeTransparency = 0
		textLabel.Text = ""
		textLabel.Parent = screenGui
		local UI = ReplicatedStorage:FindFirstChild("UI")
		local barnabyExitBtn = UI and UI:FindFirstChild("BarnabyExitBtn")
		local parent

		if barnabyExitBtn then
			parent = barnabyExitBtn:Clone()
		else
			parent = Instance.new("TextButton")
			parent.AnchorPoint = Vector2.new(0, 0)
			parent.Position = UDim2.new(0.392585635, 0, 0.88, 0)
			parent.Size = UDim2.new(0.21470958, 0, 0.06445086, 0)
			parent.BackgroundColor3 = Color3.fromRGB(120, 22, 22)
			parent.BackgroundTransparency = 0
			parent.AutoButtonColor = true
			parent.BorderSizePixel = 0
			parent.Font = Enum.Font.Arcade
			parent.Text = "EXIT"
			parent.TextScaled = true
			parent.TextColor3 = Color3.fromRGB(255, 80, 80)
			parent.TextStrokeColor3 = Color3.new(0, 0, 0)
			parent.TextStrokeTransparency = 0
			parent.ZIndex = 6
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 8)
			uICorner.Parent = parent
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromRGB(255, 60, 60)
			uIStroke.Thickness = 2
			uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uIStroke.Parent = parent
		end

		parent.Name = "ExitButton"
		parent.Parent = screenGui
		local inputBeganConnection = nil
		local onClientEventConnection = nil

		local function dismiss()
			if inputBeganConnection then
				inputBeganConnection:Disconnect()
				inputBeganConnection = nil
			end

			if onClientEventConnection then
				onClientEventConnection:Disconnect()
				onClientEventConnection = nil
			end

			if v7 then
				pcall(function()
					v7:Destroy()
				end)
				v7 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function leave()
			if remote5 then
				pcall(function()
					remote5:FireServer(v6)
				end)
			end

			dismiss()
		end

		parent.Activated:Connect(leave)
		parent.Selectable = false

		if not flag then
			flag = true
			local sharedUtils = ReplicatedStorage:FindFirstChild("SharedUtils")
			local inputService = sharedUtils and sharedUtils:FindFirstChild("InputService")

			if inputService then
				local success, result = pcall(require, inputService)

				if success then
					v3 = result
				end
			end
		end

		local v9 = v3
		local v10 = v9 and v9:OnAction("GeneratorStop", function()
			if v9:IsTyping() then
				return
			end

			leave() -- equivalent call inferred; original call site unknown
		end)

		if typeof(v10) == "RBXScriptConnection" then
			inputBeganConnection = v10
		else
			inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.E then
					leave() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		onClientEventConnection = remote3.OnClientEvent:Connect(function(p, p2)
			if p == instance and (p2 == nil or p2 == v6) then
				dismiss()
			end
		end)
	end

	local function reportBootFail(p)
		if remote9 then
			pcall(function()
				remote9:FireServer(v6, instance, p)
			end)
		end
	end

	local arcadeContent = getArcadeContent()

	if arcadeContent then
		local overlay = findOverlay(instance, slotSuffix) -- equivalent call inferred; original call site unknown

		if overlay then
			local v9 = 0
			local screen = nil

			for _, part in ipairs(overlay:GetDescendants()) do
				local name = part.Name:lower()

				if not part:IsA("BasePart") or not name:find("screen") or name:find("border") then
					continue
				end

				local size = part.Size
				local v11 = math.max(size.X * size.Y, size.X * size.Z, size.Y * size.Z)

				if not (v9 < v11) then
					continue
				end

				screen = part
				v9 = v11
			end

			if screen then
				local screenGui = findScreenGui(overlay, screen)
				local enabled

				if screenGui then
					enabled = screenGui.Enabled
					screenGui.Enabled = false
				else
					enabled = nil
				end

				setOverlayLightsEnabled(overlay, true)
				local v11 = addCabinetGlow(screen)
				local v12 = setupFillScreen(overlay, screen, instance)
				local v13 = nil

				-- equivalent calls inferred from this helper; original call sites unknown
				local function restoreChassisState()
					setOverlayLightsEnabled(overlay, false)
					v11()
					v12()

					if v13 then
						v13:Cleanup()
						v13 = nil
					end

					if screenGui and enabled ~= nil then
						screenGui.Enabled = enabled
					end
				end

				local v14 = v6
				local success, module = pcall(require, arcadeContent.Module)

				if success and module then
					local v15 = getMyReplicaSafe() or {
						Data = {
							Coin = 0,
							Towers = {}
						}
					}
					local objects = {
						Screen = screen,
						Camera = overlay:FindFirstChild("Cam") or overlay:FindFirstChild("Camera")
					}
					local success2, result = pcall(function()
						return module.new(v14, {
							Model = instance,
							Content = arcadeContent,
							Objects = objects,
							GenMode = true,
							SlotSuffix = slotSuffix
						})
					end)

					if success2 and result then
						local metatable = getmetatable(result)
						local increaseScore = metatable and metatable.__index and metatable.__index.IncreaseScore or rawget(
							result,
							"IncreaseScore"
						) or rawget(module, "IncreaseScore")
						rawset(result, "IncreaseScore", function(p, value3)
							if increaseScore then
								local success3, result2 = pcall(increaseScore, p, value3)

								if not success3 then
									warn(
										"[BarnabyMinigameClient] IncreaseScore (cosmetic) errored — tick still banks:",
										result2
									)
								end
							end

							local info = workspace:FindFirstChild("Info")

							if info and info:GetAttribute("BarnabyFillAfterFirstJump") == true then
								local v18 = rawget(p, "Fish")

								if v18 and v18.Weightless then
									return
								end
							end

							remote2:FireServer(v14, value3 or 1)
						end)

						if remote6 then
							local metatable2 = getmetatable(result)
							local collectCoin = metatable2 and metatable2.__index and metatable2.__index.CollectCoin or rawget(
								result,
								"CollectCoin"
							) or rawget(module, "CollectCoin")
							rawset(result, "CollectCoin", function(p, ...)
								if collectCoin then
									local success3, result2 = pcall(collectCoin, p, ...)

									if not success3 then
										warn(
											"[BarnabyMinigameClient] CollectCoin (cosmetic) errored — coin still credits:",
											result2
										)
									end
								end

								remote6:FireServer(v14)
							end)
						end

						if remote7 then
							rawset(result, "MissedCoin", function()
								remote7:FireServer(v14)
							end)
						end

						local name = localPlayer.Name
						local v20 = tostring(v ~= nil)
						local v21 = tostring(v2 ~= nil)
						local character = localPlayer.Character
						local config = character and character:FindFirstChild("Config")
						local characterName = config and config:FindFirstChild("CharacterName")
						local v22

						if characterName == nil then
							v22 = false
						else
							v22 = characterName.Value == "Finn"
						end

						local v23 = tostring(v22)
						local v24

						if v2 == nil then
							v24 = false
						else
							v24 = v2.isEnabled()
						end

						flopDbg(string.format(
							"[FlopDebug][Actor] %s gates: ctrl=%s config=%s isFinn=%s enabled=%s",
							name,
							v20,
							v21,
							v23,
							(tostring(v24))
						))

						if v and v2 then
							local character2 = localPlayer.Character
							local config2 = character2 and character2:FindFirstChild("Config")
							local characterName2 = config2 and config2:FindFirstChild("CharacterName")
							local v25

							if characterName2 == nil then
								v25 = false
							else
								v25 = characterName2.Value == "Finn"
							end

							if v25 and v2.isEnabled() then
								local flopTemplate = resolveFlopTemplate()
								local child = localPlayer.Character and localPlayer.Character:FindFirstChild(v2.attachPartName)
								flopDbg(string.format(
									"[FlopDebug][Actor] %s build: template=%s anchor=%s",
									localPlayer.Name,
									tostring(flopTemplate ~= nil),
									(tostring(child ~= nil))
								))

								if flopTemplate and child then
									v13 = v.new({
										template = flopTemplate,
										attachTo = child,
										offset = v2.resolveOffset(),
										animationIds = v2.hopAnimationIds,
										cooldown = v2.cooldown,
										overlapPolicy = v2.resolveOverlapPolicy(),
										hideWhilePlaying = v2.hideWhilePlaying,
										meshTextureOverrides = v2.resolveTextureOverrides(localPlayer.Character)
									})
								end

								flopDbg(string.format(
									"[FlopDebug][Actor] %s actorFlop built=%s",
									localPlayer.Name,
									(tostring(v13 ~= nil))
								))

								if v13 then
									local metatable2 = getmetatable(result)

									local function wrapJumpSound(p)
										local v26 = metatable2 and metatable2.__index and metatable2.__index[p] or rawget(
											result,
											p
										) or rawget(module, p)
										rawset(result, p, function(p2, p3, ...)
											if v26 then
												v26(p2, p3, ...)
											end

											if p3 == "Jump" and v13 and v2.isEnabled() then
												v13:SetOverlapPolicy(v2.resolveOverlapPolicy())
												local v27 = v13:PlayRandom()
												local name2 = localPlayer.Name
												local v30 = tostring(v27)
												local v31

												if v27 == nil then
													v31 = false
												else
													v31 = remote8 ~= nil
												end

												flopDbg(string.format(
													"[FlopDebug][Actor] %s jump -> idx=%s relay=%s",
													name2,
													v30,
													(tostring(v31))
												))

												if v27 and remote8 then
													remote8:FireServer(v14, v27)
												end
											end
										end)
									end

									local playSound = metatable2 and metatable2.__index and metatable2.__index.PlaySound or rawget(
										result,
										"PlaySound"
									) or rawget(module, "PlaySound")
									rawset(result, "PlaySound", function(p, p2, ...)
										if playSound then
											playSound(p, p2, ...)
										end

										if p2 == "Jump" and v13 and v2.isEnabled() then
											v13:SetOverlapPolicy(v2.resolveOverlapPolicy())
											local v26 = v13:PlayRandom()
											local name2 = localPlayer.Name
											local v29 = tostring(v26)
											local v30

											if v26 == nil then
												v30 = false
											else
												v30 = remote8 ~= nil
											end

											flopDbg(string.format(
												"[FlopDebug][Actor] %s jump -> idx=%s relay=%s",
												name2,
												v29,
												(tostring(v30))
											))

											if v26 and remote8 then
												remote8:FireServer(v14, v26)
											end
										end
									end)
									local playSoundOneShot = metatable2 and metatable2.__index and metatable2.__index.PlaySoundOneShot or rawget(
										result,
										"PlaySoundOneShot"
									) or rawget(module, "PlaySoundOneShot")
									rawset(result, "PlaySoundOneShot", function(p, p2, ...)
										if playSoundOneShot then
											playSoundOneShot(p, p2, ...)
										end

										if p2 == "Jump" and v13 and v2.isEnabled() then
											v13:SetOverlapPolicy(v2.resolveOverlapPolicy())
											local v26 = v13:PlayRandom()
											local name2 = localPlayer.Name
											local v29 = tostring(v26)
											local v30

											if v26 == nil then
												v30 = false
											else
												v30 = remote8 ~= nil
											end

											flopDbg(string.format(
												"[FlopDebug][Actor] %s jump -> idx=%s relay=%s",
												name2,
												v29,
												(tostring(v30))
											))

											if v26 and remote8 then
												remote8:FireServer(v14, v26)
											end
										end
									end)
								end
							end
						end

						local onClientEventConnection = remote3.OnClientEvent:Connect(function(p, p2)
							if p == instance and (p2 == nil or p2 == v14) then
								btrace(string.format(
									"[BarnabyTrace] exitConn FIRED for MY session (session=%s, instance=%s) — shutting the arcade down",
									tostring(v14),
									(tostring(result ~= nil))
								))

								if result and result.SendShutdownSignal then
									pcall(function()
										result:SendShutdownSignal(-1)
									end)
								end
							elseif p == instance then
								btrace(string.format(
									"[BarnabyTrace] exitConn IGNORED a cross-session exit (mine=%s theirs=%s) — NOT shutting down (this is the cross-talk that used to soft-lock)",
									tostring(v14),
									(tostring(p2))
								))
							end
						end)

						if remote9 then
							pcall(function()
								remote9:FireServer(v14, instance)
							end)
						end

						local flag2 = false
						task.delay(5, function()
							if flag2 then
								return
							end

							local v25 = result and rawget(result, "ScreenGui")

							if v25 then
								if v25.Parent == nil then
									v25 = false
								else
									v25 = v25.Enabled == true
								end
							end

							if not v25 then
								warn("[BarnabyMinigameClient] arcade UI not visible 5s after boot started — showing fallback EXIT")
								showFallbackExit()

								if remote9 then
									local v26 = "ui-not-visible"
									pcall(function()
										remote9:FireServer(v6, instance, v26)
									end)
								end
							end
						end)
						btrace(string.format(
							"[BarnabyTrace] calling Bootup (session=%s) — hops ClientUI to PlayerGui, then yields until exit",
							(tostring(v14))
						))
						local success3, result2 = pcall(function()
							result:Bootup(v15)
						end)
						flag2 = true
						btrace(string.format(
							"[BarnabyTrace] Bootup returned (session=%s) ok=%s%s",
							tostring(v14),
							tostring(success3),
							success3 and "" or " err=" .. tostring(result2)
						))

						if not success3 then
							warn("[BarnabyMinigameClient] minigame errored:", result2)
							showFallbackExit()

							if remote9 then
								local v25 = "bootup-error"
								pcall(function()
									remote9:FireServer(v6, instance, v25)
								end)
							end
						end

						if onClientEventConnection then
							onClientEventConnection:Disconnect()
						end

						if result and rawget(result, "DiedInGenMode") then
							if v14 then
								remote4:FireServer(v14)
							end

							pcall(function()
								local SkillCheckController = require(ReplicatedStorage.Modules.ClientUI.SkillCheckController)
								SkillCheckController.playFailFeedback()
							end)
						end

						restoreChassisState() -- equivalent call inferred; original call site unknown
					else
						warn("[BarnabyMinigameClient] arcade .new() errored:", result)
						restoreChassisState() -- equivalent call inferred; original call site unknown
						showFallbackExit()

						if remote9 then
							local v18 = "module-new-error"
							pcall(function()
								remote9:FireServer(v6, instance, v18)
							end)
						end
					end
				else
					warn("[BarnabyMinigameClient] failed to require SwimmyBarnaby module:", module)
					restoreChassisState() -- equivalent call inferred; original call site unknown
					showFallbackExit()

					if remote9 then
						local v15 = "module-require-error"
						pcall(function()
							remote9:FireServer(v6, instance, v15)
						end)
					end
				end
			else
				warn("[BarnabyMinigameClient] could not resolve a screen Part on '" .. instance.Name .. "' overlay")
				showFallbackExit()

				if remote9 then
					local v11 = "screen-missing"
					pcall(function()
						remote9:FireServer(v6, instance, v11)
					end)
				end
			end
		else
			warn("[BarnabyMinigameClient] chassis '" .. instance.Name .. "' has no SwimmyBarnaby overlay child")
			showFallbackExit()

			if remote9 then
				local v9 = "overlay-missing"
				pcall(function()
					remote9:FireServer(v6, instance, v9)
				end)
			end
		end
	else
		warn("[BarnabyMinigameClient] arcade content unavailable — showing fallback EXIT so the player isn't trapped")
		showFallbackExit()

		if remote9 then
			local v8 = "content-missing"
			pcall(function()
				remote9:FireServer(v6, instance, v8)
			end)
		end
	end
end)