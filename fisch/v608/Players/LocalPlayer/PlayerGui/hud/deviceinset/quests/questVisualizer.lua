local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local character = require(ReplicatedStorage.shared.modules:WaitForChild("character"))
require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("debris"))
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local localPlayer = game.Players.LocalPlayer
local v = character.PS(localPlayer)

if v == nil then
	repeat
		v = character.PS(localPlayer)
		task.wait()
	until v ~= nil
end

local quests = v:WaitForChild("Quests")
local poiBeam = nil

function New(instance)
	local count = 0
	local children = {}

	for _, child in instance:GetChildren() do
		if not instance:FindFirstChild(child.Name .. "_Goal") then
			continue
		end

		count += 1
		table.insert(children, child)
	end

	local clone = script.template:Clone()
	local clone2 = nil
	local main = clone.main

	if clone then
		main.title.Text = string.split(instance.Name, "_")[1]
		main.subtitle.Text = instance.Value
		main.subtitle.Visible = instance.Value ~= ""
		main.title.icon.Image = instance:FindFirstChild("Icon").Value

		if instance:FindFirstChild("Position") then
			local position = instance:FindFirstChild("Position")
			clone2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("ui"):WaitForChild("questlocation"):Clone()

			if instance:FindFirstChild("PositionName") then
				clone2.POIHeader.title.Text = instance:FindFirstChild("PositionName").Value
			else
				clone2.POIHeader.title.Text = string.split(instance.Name, "_")[1]
			end

			clone2.POIHeader.icon.Image = instance:FindFirstChild("Icon").Value
			clone2.Name = instance.Name
			clone2.poiBeam.Attachment0 = clone2:WaitForChild("a0")
			clone2.poiBeam.Attachment1 = localPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild(
				"RootAttachment",
				10
			)
			poiBeam = clone2.poiBeam
			local v2 = string.split(position.Value, ",")
			clone2.Position = Vector3.new(v2[1], v2[2], v2[3])
			clone2.Parent = workspace.active
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Check()
			local quest = require(ReplicatedStorage.shared.modules:WaitForChild("character"):WaitForChild("quest"))
			return (quest:CheckComplete(instance))
		end

		for k, v2 in children do
			local clone3 = script.lineTemplate:Clone()
			local v3 = v2
			local v4 = instance:FindFirstChild(v2.Name .. "_Goal")

			local function Compare()
				if typeof(v3.Value) == "number" then
					if v3.Value >= v4.Value then
						fx:PlaySound(
							ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("questUpdate"),
							localPlayer.PlayerGui,
							true
						)
						clone3.Text = v3.Name .. " (" .. v4.Value .. "/" .. v4.Value .. ")"
						clone3.TextColor3 = Color3.fromRGB(162, 234, 166)
						clone3.complete.ImageColor3 = Color3.fromRGB(57, 93, 60)
						clone3.complete.Image = "rbxassetid://18269827135"
					else
						clone3.Text = v3.Name .. " (" .. v3.Value .. "/" .. v4.Value .. ")"
						clone3.TextColor3 = Color3.fromRGB(255, 255, 255)
						clone3.complete.ImageColor3 = Color3.fromRGB(0, 0, 0)
						clone3.complete.Image = "rbxassetid://17848872395"
					end
				else
					if v3.Value == v4.Value then
						fx:PlaySound(
							ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("questUpdate"),
							localPlayer.PlayerGui,
							true
						)
						clone3.TextColor3 = Color3.fromRGB(162, 234, 166)
						clone3.complete.ImageColor3 = Color3.fromRGB(57, 93, 60)
						clone3.complete.Image = "rbxassetid://18269827135"
					else
						clone3.TextColor3 = Color3.fromRGB(255, 255, 255)
						clone3.complete.ImageColor3 = Color3.fromRGB(0, 0, 0)
						clone3.complete.Image = "rbxassetid://17848872395"
					end

					clone3.Text = v3.Name
				end

				if Check() == true then
					clone.Visible = true

					if main.title.TextColor3 ~= Color3.fromRGB(162, 234, 166) then
						clone.shine.ImageColor3 = Color3.fromRGB(149, 234, 139)
						TweenService:Create(
							clone.shine,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								ImageColor3 = Color3.fromRGB(0, 0, 0)
							}
						):Play()
						fx:PlaySound(
							ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("questComplete"),
							localPlayer.PlayerGui,
							true
						)
					end

					main.title.TextColor3 = Color3.fromRGB(162, 234, 166)
					main.title.check.Visible = true
				else
					main.title.TextColor3 = Color3.fromRGB(255, 255, 255)
					main.title.check.Visible = false
				end
			end

			Compare()
			local Compare2 = Compare
			v2.Changed:Connect(function()
				Compare2()
			end)
			clone3.LayoutOrder = k + 2
			clone3.Name = "Line" .. k
			clone3.Parent = main
		end

		local uDim = UDim2.new(clone.Size.X.Scale, 0, clone.Size.Y.Scale, 0)
		clone.Size = UDim2.new(0, 0, clone.Size.Y.Scale, 0)
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = uDim
		}):Play()
		clone.Parent = script.Parent
		fx:PlaySound(
			ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("questObtain"),
			localPlayer.PlayerGui,
			true
		)

		local function updateVisibility()
			if clone then
				local v2 = clone
				local visible = instance.Tracking.Value

				if not visible then
					visible = Check()
				end

				v2.Visible = visible
			end
		end

		if clone then
			local visible = instance.Tracking.Value

			if not visible then
				visible = Check()
			end

			clone.Visible = visible
		end

		clone:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
		instance:WaitForChild("Tracking"):GetPropertyChangedSignal("Value"):Connect(updateVisibility)
	end

	instance.Destroying:Connect(function()
		if clone then
			task.spawn(function()
				task.wait(2)
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(clone.Size.X.Scale, 0, 0, 0)
				}):Play()
				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("questClose"),
					localPlayer.PlayerGui,
					true
				)
				task.wait(0.1)
				clone:Destroy()
			end)
		end

		if clone2 then
			clone2:Destroy()
		end
	end)
	quests.ChildRemoved:Connect(function(child)
		if child == instance or child.Name == instance.Name then
			if clone then
				task.spawn(function()
					task.wait(2)
					TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(clone.Size.X.Scale, 0, 0, 0)
					}):Play()
					fx:PlaySound(
						ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("questClose"),
						localPlayer.PlayerGui,
						true
					)
					task.wait(0.1)
					clone:Destroy()
				end)
			end

			if clone2 then
				clone2:Destroy()
			end
		end
	end)
end

task.wait(2)

for _, child in pairs(quests:GetChildren()) do
	New(child)
end

quests.ChildAdded:Connect(function(child)
	task.wait(1)
	New(child)
end)
local position = script.Parent.Position
local uDim = UDim2.new(-1, 0, 0, script.Parent.Position.Y.Offset)
local vector = Vector2.new(0.37, 62)
local vector2 = Vector2.new(0, 62)
local count = 0
local v2 = false
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	count += 1

	if count < 3 then
		return
	end

	count = 0
	local arrowQuest = script.Parent.Parent.arrowQuest
	local v3 = script.Parent:GetAttribute("Toggle") == nil or script.Parent:GetAttribute("Toggle")
	local vector3

	if v3 == true then
		vector3 = Vector2.new(position.X.Scale, position.X.Offset)
	else
		vector3 = Vector2.new(uDim.X.Scale, uDim.X.Offset)
	end

	local StarterGui = game:GetService("StarterGui")
	local v4

	if StarterGui:GetCore("ChatActive") then
		v4 = vector
	else
		v4 = vector2
	end

	local viewportSize = workspace.CurrentCamera.ViewportSize
	local v5

	if viewportSize.X > 1250 then
		v5 = viewportSize.Y > 800
	else
		v5 = false
	end

	if v2 ~= v5 then
		v2 = v5
		local textSize = v2 and 20 or 14

		for _, guiObject in script.Parent:GetDescendants() do
			if guiObject:IsA("TextLabel") then
				guiObject.TextSize = textSize
			elseif guiObject:IsA("ImageLabel") then
				if guiObject.Name == "icon" then
					guiObject.Size = UDim2.fromOffset(textSize, textSize)
				elseif guiObject.Name == "complete" then
					guiObject.Size = UDim2.fromOffset(textSize + 4, textSize + 4)
				end
			end
		end
	end

	local uDim2 = UDim2.new(vector3.X, vector3.Y, v4.X, v4.Y)
	script.Parent.Position = uDim2
	arrowQuest.Rotation = v3 == true and -90 or 90
	local v6 = math.clamp(script.Parent.Position.X.Scale + (v3 == true and 0.27 or 0.35), 0.005, 1e999)
	arrowQuest.Position = UDim2.new(
		v6,
		vector3.Y + script.Parent.Size.X.Offset,
		script.Parent.Position.Y.Scale,
		script.Parent.Position.Y.Offset + 20
	)
end)

local function OnCharacterAdded(_)
	if poiBeam and poiBeam.Parent then
		poiBeam.Attachment1 = localPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment", 10)
	end
end

if localPlayer.Character then
	task.spawn(OnCharacterAdded, localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)