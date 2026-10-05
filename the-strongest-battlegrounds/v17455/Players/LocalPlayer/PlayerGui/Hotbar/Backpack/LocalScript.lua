local createVector = vector.create
game.StarterGui:SetCoreGuiEnabled(2, false)
local UserInputService = game:GetService("UserInputService")

if not UserInputService.TouchEnabled then
	pcall(game.StarterGui.SetCoreGuiEnabled, game.StarterGui, Enum.CoreGuiType.PlayerList, false)
end

local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:wait()
local humanoid = character:WaitForChild("Humanoid")
local backpack = localPlayer.Backpack
local Info = require(game.ReplicatedStorage.Info)
local UserInputService2 = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local v = {}
local hotbar = parent.Hotbar
shared.hotbarMain = parent

if UserInputService2.TouchEnabled and parent.Parent then
	parent.Parent.ScreenInsets = Enum.ScreenInsets.None
end

local v2 = hotbar:FindFirstChildOfClass("UIScale")

if not v2 and UserInputService2.TouchEnabled then
	v2 = Instance.new("UIScale")
	v2.Parent = hotbar
end

if UserInputService2.TouchEnabled and not shared.hotbarPos then
	task.spawn(function()
		localPlayer:WaitForChild("LoadedData", 10)

		if shared.hotbarPos then
			return warn("no")
		end

		local lastTime = tick()

		repeat
			task.wait()
		until localPlayer:GetAttribute("HotbarLayout") or tick() - lastTime >= 5

		wait(0.5)
		local hotbarLayout = localPlayer:GetAttribute("HotbarLayout")

		if hotbarLayout and hotbarLayout ~= "{}" and hotbarLayout ~= "" then
			local success, result = pcall(function()
				local HttpService = game:GetService("HttpService")
				return HttpService:JSONDecode(hotbarLayout)
			end)

			if success and typeof(result) == "table" and result.Position then
				shared.hotbarPos = UDim2.new(
					result.Position[1],
					result.Position[2],
					result.Position[3],
					result.Position[4]
				)
				shared.hotbarScale = result.Scale

				if v2 and shared.hotbarScale then
					v2.Scale = shared.hotbarScale
				end

				parent.Position = shared.hotbarPos
			end
		end
	end)
end

if localPlayer:GetAttribute("HotbarLayout") and UserInputService2.TouchEnabled then
	if v2 and shared.hotbarScale then
		v2.Scale = shared.hotbarScale
	end

	if shared.hotbarPos then
		parent.Position = shared.hotbarPos
	end
end

local base = script:FindFirstChild("Base") or script:WaitForChild("Base", 10)
local cooldown = script:FindFirstChild("Cooldown") or script:WaitForChild("Cooldown", 10)

for i = 1, 13 do
	local clone = base:Clone()
	clone.Name = i
	clone.Base.Number.Text = i
	clone.Base.Number.Number.Text = i
	clone.Visible = false
	clone.Parent = hotbar
end

localPlayer:GetMouse()

local function fn()
	for i = 1, 13 do
		if not v[i] then
			return i
		end
	end
end

local v3 = {
	[Enum.KeyCode.ButtonL1] = 1,
	[Enum.KeyCode.ButtonL2] = 2,
	[Enum.KeyCode.ButtonR2] = 3,
	[Enum.KeyCode.ButtonR1] = 4
}

local function fn2(...)
	local v4 = { ... }
	local v5 = v4[1]
	table.remove(v4, 1)
	local v6 = v4[1]

	if v6 and typeof(v6) == "table" and v6.Goal == "Console Move" then
		v6.IsAutoActivate = true
	end

	v5:FireServer(unpack(v4))
end

local v4 = false
localPlayer:GetAttributeChangedSignal("DamageNeed"):Connect(function()
	local damageNeed = localPlayer:GetAttribute("DamageNeed")

	if not damageNeed then
		v4 = false
	elseif Info.UFWrequirement <= damageNeed and character:GetAttribute("Character") == "KJ" then
		if not v4 then
			v4 = true

			local function fn3(text, typeSpeed, bold)
				local TekrinnDialogue = require(game.ReplicatedStorage.Resources.UFW.TekrinnDialogue)
				TekrinnDialogue.Speak(character, {
					{
						Text = text,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 17, 17)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
						}),
						TextStrokeColor = Color3.new(0, 0, 0),
						Bold = bold,
						Italic = false,
						Shake = {
							Intensity = 1,
							Lifetime = 2
						},
						TypeSpeed = typeSpeed,
						HigherUp = true
					}
				})
			end

			shared.sfx({
				SoundId = "rbxassetid://132515779133572",
				Parent = workspace,
				Volume = 2.5
			}):Play()
			task.delay(0.1, function()
				fn3("I'm done playing around", 0.082)
				wait(2.564)

				if character:FindFirstChild("usingufw") then
					return
				end

				fn3("This should end it all..", 0.0965, true)
			end)
		end
	else
		v4 = false
	end
end)
local v5 = {}
local base2 = nil

local function onChildAdded(tool)
	if not tool or tool:GetAttribute("Regged") or not tool:IsA("Tool") then
		return
	end

	tool:SetAttribute("Regged", true)
	local v6 = fn()

	if v6 then
		v[v6] = tool
		local v7 = hotbar[v6]
		local v8 = tool.Name == "Heads or Tails" and [[
Heads
or
Tails]] or nil
		hotbar[v6].Base.ToolName.Text = v8 or tool:GetAttribute("FakeName") or tool.Name

		if UserInputService2.GamepadEnabled then
			hotbar[v6].Base.Number.TextWrapped = false
			hotbar[v6].Base.Number.TextXAlignment = "Left"
			local number = hotbar[v6].Base.Number
			local flag = true
			local v9

			for k, v10 in pairs(v3) do
				if v10 ~= v6 then
					continue
				end

				v9 = string.gsub(UserInputService2:GetStringForKeyCode(k), "Button", "")
				flag = false
				break
			end

			if flag then
				v9 = nil
			end

			number.Text = v9 or ""
			hotbar[v6].Base.Number.Number.Text = hotbar[v6].Base.Number.Text
		end

		for _ = 1, 3 do
			local cooldown2 = hotbar[v6].Base:FindFirstChild("Cooldown")

			if not cooldown2 then
				break
			end

			local Debris = game:GetService("Debris")
			Debris:AddItem(cooldown2, 0)
		end

		local index = table.find({
			"Straight On",
			"Ignition Burst",
			"Expulsive Push",
			"Five Seasons",
			"Vanishing Kick"
		}, tool.Name)
		local index2 = table.find({ "Doom Dive" }, tool.Name)
		local index3 = table.find({
			"Pinpoint Cut",
			"Crushing Pull",
			"Crushed Rock",
			"Trinity Tear",
			"Hammer Heel"
		}, tool.Name)

		if index or index2 then
			local text = index and "USE TWICE" or "USE THRICE"
			hotbar[v6].Base.Reuse.Visible = true
			hotbar[v6].Base.Reuse.Text = text
			hotbar[v6].Base.Reuse.Reuse.Text = text
		elseif index3 then
			hotbar[v6].Base.Reuse.Visible = true
			hotbar[v6].Base.Reuse.Text = "VARIANT"
			hotbar[v6].Base.Reuse.Reuse.Text = "VARIANT"
		elseif tool.Name == "Hunter's Mark" then
			hotbar[v6].Base.Reuse.Visible = true
			hotbar[v6].Base.Reuse.Text = "MARK"
			hotbar[v6].Base.Reuse.Reuse.Text = "MARK"
		elseif tool.Name == "Great Fajin" or tool.Name == "Nuclear Fission" or tool.Name == "Phantom Frenzy" then
			hotbar[v6].Base.Reuse.Visible = true
			hotbar[v6].Base.Reuse.Text = "HOLD"
			hotbar[v6].Base.Reuse.Reuse.Text = "HOLD"
		else
			hotbar[v6].Base.Reuse.Visible = false
		end

		hotbar[v6].Base.Overlay.ImageTransparency = 1
		hotbar[v6].Size = UDim2.new(0, -7, 0, base.Size.X.Offset)
		hotbar[v6].Base.Position = UDim2.new(0.5, 0, 2, 0)
		TweenService:Create(hotbar[v6].Base, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		TweenService:Create(hotbar[v6], TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, base.Size.X.Offset, 0, base.Size.Y.Offset)
		}):Play()
		hotbar[v6].Visible = true

		if tool.Name == "Unlimited Flex Works" then
			hotbar[v6].Base.Bar.Size = UDim2.new(0.915, 0, 0.075, 0)
			hotbar[v6].Base.Bar.Visible = true
			hotbar[v6].Base.Bar.Fill.BackgroundColor3 = Color3.fromRGB(255, 79, 79)
			local damageNeedChangedConnection = nil

			local function fn3()
				if not hotbar[v6].Visible or hotbar[v6].Base.ToolName.Text ~= "Unlimited Flex Works" then
					return damageNeedChangedConnection:Disconnect()
				end

				local v9 = math.clamp((localPlayer:GetAttribute("DamageNeed") or 0) / Info.UFWrequirement, 0, 1)
				hotbar[v6].Base.Bar.Fill.Size = UDim2.new(v9, 0, 1, 0)

				if v9 == 1 and not v5[v6] then
					local clone = script.Flipbook:Clone()
					clone.Parent = hotbar[v6].Base
					clone.Visible = true
					local localScript = clone:FindFirstChildOfClass("LocalScript")
					localScript.Enabled = true
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(clone, TweenInfo.new(0.25), {
						ImageTransparency = 0
					}):Play()
					local clone2 = script.Vignette:Clone()
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone2, 3)
					clone2.Parent = localPlayer.PlayerGui.MobileJunk
					TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 1
					}):Play()
					local connections = v5
					local RunService = game:GetService("RunService")
					connections[v6] = RunService.RenderStepped:Connect(function()
						local v11 = math.clamp(
							(localPlayer:GetAttribute("DamageNeed") or 0) / Info.UFWrequirement,
							0,
							1
						)

						if hotbar[v6].Visible and hotbar[v6].Base.ToolName.Text == "Unlimited Flex Works" and not (v11 < 1) then
							local TweenService3 = game:GetService("TweenService")
							TweenService3:Create(hotbar[v6].Base.Bar, TweenInfo.new(1), {
								Size = UDim2.new(0, 0, 0, 0)
							}):Play()
						else
							v5[v6]:Disconnect()
							v5[v6] = nil

							if clone and clone.Parent then
								local TweenService3 = game:GetService("TweenService")
								TweenService3:Create(clone, TweenInfo.new(0.5), {
									ImageTransparency = 1
								}):Play()
								game.Debris:AddItem(clone, 1)
							end
						end
					end)
				end
			end

			damageNeedChangedConnection = localPlayer:GetAttributeChangedSignal("DamageNeed"):Connect(fn3)
			fn3()
		else
			hotbar[v6].Base.Bar.Visible = false
		end

		local fakeNameChangedConnection = nil
		fakeNameChangedConnection = tool:GetAttributeChangedSignal("FakeName"):Connect(function()
			if tool and tool.Parent then
				v7.Base.ToolName.Text = tool:GetAttribute("FakeName") or tool.Name
			else
				return fakeNameChangedConnection:Disconnect()
			end
		end)
		hotbar[v6].Base.MouseButton1Down:Connect(function()
			if shared.draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			if not (tool:GetAttribute("Skill") and localPlayer:GetAttribute("S_AutoUnequip")) then
				return
			end

			humanoid:EquipTool(tool)
			tool.Parent = backpack

			if base2 then
				base2.Overlay.ImageTransparency = 1
				local cooldown2 = base2:FindFirstChild("Cooldown")

				if cooldown2 then
					cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
				end

				base2 = nil
			end
		end)
		local mouseButton1ClickConnection = hotbar[v6].Base.MouseButton1Click:Connect(function()
			if shared.draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			if tool:GetAttribute("Skill") and localPlayer:GetAttribute("S_AutoUnequip") then
				if base2 then
					base2.Overlay.ImageTransparency = 1
					local cooldown2 = base2:FindFirstChild("Cooldown")

					if cooldown2 then
						cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
					end

					base2 = nil
				end
			elseif base2 == hotbar[v6].Base then
				base2.Overlay.ImageTransparency = 1
				local cooldown2 = base2:FindFirstChild("Cooldown")

				if cooldown2 then
					cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
				end

				base2 = nil
				humanoid:UnequipTools()
			else
				if base2 then
					base2.Overlay.ImageTransparency = 1
					local cooldown2 = base2:FindFirstChild("Cooldown")

					if cooldown2 then
						cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
					end
				end

				local cooldown2 = hotbar[v6].Base:FindFirstChild("Cooldown")

				if cooldown2 then
					cooldown2.BackgroundColor3 = Color3.fromRGB(70, 166, 255)
				end

				hotbar[v6].Base.Overlay.ImageTransparency = 0
				base2 = hotbar[v6].Base
				humanoid:EquipTool(tool)
			end
		end)
		local mouseButton1UpConnection = hotbar[v6].Base.MouseButton1Up:Connect(function()
			if shared.draggingButtons or shared.draggingBar or shared.draggingHotbar then
				return
			end

			if tool:GetAttribute("Skill") and localPlayer:GetAttribute("S_AutoUnequip") then
				return fn2(character.Communicate, {
					Goal = "Auto Use End",
					Tool = tool
				})
			end
		end)
		tool:GetPropertyChangedSignal("Parent"):Connect(function()
			if not tool.Parent then
				if mouseButton1ClickConnection then
					mouseButton1ClickConnection:Disconnect()
				end

				if mouseButton1UpConnection then
					mouseButton1UpConnection:Disconnect()
				end

				TweenService:Create(
					hotbar[v6].Base,
					TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Position = UDim2.new(0.5, 0, 3, 0)
					}
				):Play()
				local v9 = v[v6]
				task.delay(0.35, function()
					if v[v6] ~= v9 and v[v6] ~= nil then
						return
					end

					TweenService:Create(
						hotbar[v6],
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Size = UDim2.new(0, -7, 0, base.Size.Y.Offset)
						}
					):Play()
					task.delay(0.6, function()
						if v[v6] ~= v9 and v[v6] ~= nil then
							return
						end

						hotbar[v6].Visible = false
					end)
				end)
				v[v6] = nil
				base2 = nil
			end
		end)
	end

	local UserInputService3 = game:GetService("UserInputService")

	if not UserInputService3.TouchEnabled then
		pcall(game.StarterGui.SetCoreGuiEnabled, game.StarterGui, Enum.CoreGuiType.PlayerList, false)
	end

	game.StarterGui:SetCoreGuiEnabled(2, false)
end

local v6 = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
	[Enum.KeyCode.Zero] = 10
}
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Live }

function shared.GetCrushingPullHit(p)
	if not p or p.Name ~= "Crushing Pull" then
		return
	end

	local cFrame = localPlayer.Character.PrimaryPart.CFrame

	if character:GetAttribute("HoldingSpace") then
		local cFrame2 = workspace.CurrentCamera.CFrame
		cFrame = CFrame.new(cFrame.Position, cFrame2.Position + cFrame2.LookVector * 5000)
	end

	local primaryParts = {}

	for _, v7 in pairs(workspace:GetPartBoundsInBox(
		cFrame * CFrame.new(0, 0, -23),
		createVector(14, 14, 52),
		overlapParams
	)) do
		local parent2 = v7.Parent
		local humanoid2 = parent2:FindFirstChildOfClass("Humanoid")
		local primaryPart = parent2:IsA("Model") and parent2.PrimaryPart
		local rootAnchor = parent2:FindFirstChild("RootAnchor")

		if rootAnchor and rootAnchor:GetAttribute("CanPull") then
			rootAnchor = nil
		end

		local forceField = parent2:FindFirstChildOfClass("ForceField")

		if forceField and forceField:GetAttribute("CanPull") then
			forceField = nil
		end

		if not parent2 or rootAnchor or not humanoid2 or not primaryPart then
			continue
		end

		if humanoid2.Name == "FakeHumanoid" or parent2 == character or (forceField or table.find(
			primaryParts,
			primaryPart
		)) then
			continue
		end

		table.insert(primaryParts, primaryPart)
	end

	if #primaryParts > 1 then
		table.sort(primaryParts, function(a, b)
			local v7 = cFrame
			local position = a.Position
			local unit = (Vector3.new(position.X, v7.p.Y, position.Z) - v7.p).unit
			local v8 = math.deg((math.acos((v7.LookVector:Dot(unit)))))
			local v9 = cFrame
			local position2 = b.Position
			local unit2 = (Vector3.new(position2.X, v9.p.Y, position2.Z) - v9.p).unit
			return v8 < math.deg((math.acos((v9.LookVector:Dot(unit2)))))
		end)
	end

	local v7 = rawget(primaryParts, 1)
	return v7 and v7.Parent or nil
end

UserInputService2.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local keyCode = input.KeyCode

	if character:FindFirstChild("buildingg") then
		return
	end

	if v3[keyCode] then
		local v7 = v3[keyCode]

		if v[v7] then
			local tool = v[v7]
			tool:SetAttribute("Name", hotbar[v7].Base.ToolName.Text)
			fn2(character.Communicate, {
				Goal = "Console Move",
				CrushingPull = shared.GetCrushingPullHit(tool),
				Tool = tool
			})
		end
	else
		if not v6[keyCode] then
			return
		end

		local v7 = v6[keyCode]

		if v[v7] then
			local v8 = v[v7]

			if v8:GetAttribute("Skill") and localPlayer:GetAttribute("S_AutoUnequip") then
				v8:SetAttribute("Name", hotbar[v7].Base.ToolName.Text)
				humanoid:EquipTool(v8)
				v8.Parent = backpack

				if base2 then
					base2.Overlay.ImageTransparency = 1
					local cooldown2 = base2:FindFirstChild("Cooldown")

					if cooldown2 then
						cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
					end

					base2 = nil
				end
			elseif base2 == hotbar[v7].Base then
				base2.Overlay.ImageTransparency = 1
				local cooldown2 = base2:FindFirstChild("Cooldown")

				if cooldown2 then
					cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
				end

				base2 = nil
				humanoid:UnequipTools()
			else
				if base2 then
					base2.Overlay.ImageTransparency = 1
					local cooldown2 = base2:FindFirstChild("Cooldown")

					if cooldown2 then
						cooldown2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
					end
				end

				local cooldown2 = hotbar[v7].Base:FindFirstChild("Cooldown")

				if cooldown2 then
					cooldown2.BackgroundColor3 = Color3.fromRGB(70, 166, 255)
				end

				hotbar[v7].Base.Overlay.ImageTransparency = 0
				base2 = hotbar[v7].Base
				v8:SetAttribute("Name", hotbar[v7].Base.ToolName.Text)
				humanoid:EquipTool(v8)
			end
		end
	end
end)
UserInputService2.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local keyCode = input.KeyCode

	if v3[keyCode] then
		local v7 = v3[keyCode]

		if v[v7] then
			local tool = v[v7]
			fn2(character.Communicate, {
				Goal = "Console Move End",
				Tool = tool
			})
		end
	else
		if not v6[keyCode] then
			return
		end

		local v7 = v6[keyCode]

		if v[v7] then
			local tool = v[v7]

			if tool:GetAttribute("Skill") and localPlayer:GetAttribute("S_AutoUnequip") then
				return fn2(character.Communicate, {
					Goal = "Auto Use End",
					Tool = tool
				})
			end
		end
	end
end)
backpack.ChildAdded:Connect(onChildAdded)

for _, tool in pairs(backpack:GetChildren()) do
	if tool:IsA("Tool") then
		onChildAdded(tool)
	end
end

local v7 = {}

function shared.ResetCooldowns(p)
	for _, v8 in pairs(v7) do
		if table.find(p.Exclusion, v8[2]) then
			continue
		end

		local v9 = v8[1]

		if not v9.Parent then
			continue
		end

		local parent2 = v9.Parent
		v9:Destroy()
		local clone = cooldown:Clone()
		clone.Name = ""
		clone.BackgroundColor3 = Color3.new(1, 1, 1)
		clone.Parent = parent2
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		game:service("Debris"):AddItem(clone, 0.5)
	end

	table.clear(v7)
end

function shared.CooldownIndicator(p)
	local name = p.Name
	local cooldown2 = p.Cooldown

	for k, v8 in pairs(v) do
		if not (v8 and v8.Parent and v8.Name == name) then
			continue
		end

		local v9 = hotbar[k]
		local clone = cooldown:Clone()

		if v8.Parent == character then
			clone.BackgroundColor3 = Color3.fromRGB(70, 166, 255)
		end

		local cooldown3 = v9.Base:FindFirstChild("Cooldown")

		if cooldown3 then
			cooldown3:Destroy()
		end

		clone.Parent = v9.Base
		table.insert(v7, { clone, name })

		if cooldown2 >= 0 and cooldown2 ~= 101 then
			TweenService:Create(clone, TweenInfo.new(cooldown2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, 0)
			}):Play()
			local v10 = clone
			local v11 = v9
			task.delay(cooldown2, function()
				if not v10.Parent then
					return
				end

				local clone2 = cooldown:Clone()
				clone2.Name = ""
				clone2.BackgroundColor3 = Color3.new(1, 1, 1)
				clone2.Parent = v11.Base
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				}):Play()
				game:service("Debris"):AddItem(clone2, 0.5)
				v10:Destroy()
			end)
		end

		local visibleChangedConnection = nil
		visibleChangedConnection = v9:GetPropertyChangedSignal("Visible"):Connect(function()
			if v9.Visible then
				return
			end

			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 0)
			return visibleChangedConnection:Disconnect()
		end)
		break
	end
end

function shared.BackpackVisibility(p, p2)
	if shared.draggingHotbar then
		return
	end

	local parent2 = script.Parent

	if not parent2 then
		return
	end

	local hideUlt = game.Players.LocalPlayer.Character:FindFirstChild("HideUlt")

	if hideUlt and hideUlt:GetAttribute("Force") then
		p = false
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local hotbarPos = (p2 and true or p) and (shared.hotbarPos or UDim2.new(0, 0, 0, 0))

	if not hotbarPos then
		local hotbarPos2 = shared.hotbarPos or UDim2.new(0, 0, 0, 0)
		hotbarPos = UDim2.new(hotbarPos2.X.Scale, hotbarPos2.X.Offset, hotbarPos2.Y.Scale, hotbarPos2.Y.Offset + 140)
	end

	TweenService:Create(parent2, tweenInfo, {
		Position = hotbarPos
	}):Play()
end

character.ChildAdded:Connect(function(child)
	if localPlayer:GetAttribute("S_AutoUnequip") and child.ClassName == "Tool" then
		fn2(character.Communicate, {
			Goal = "Console Move",
			ToolName = child:GetAttribute("Name"),
			CrushingPull = shared.GetCrushingPullHit(child),
			Tool = child
		})
	end
end)