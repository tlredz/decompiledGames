local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gameServices = game.ReplicatedStorage:WaitForChild("GameServices")
local services = game.ReplicatedStorage:WaitForChild("Services")
local String = require(services:WaitForChild("String"))
local General = require(gameServices:WaitForChild("General"))
local RarityConfig = require(script.Parent.Parent.Parent:WaitForChild("RarityConfig"))
local gameData = game.ReplicatedStorage:WaitForChild("GameData")
require(gameData:WaitForChild("General"))
local v = {
	DragScroll = require(script.Parent:WaitForChild("SatchelDragScroll")),
	ByTag = {
		Egg = require(gameData:WaitForChild("Eggs")),
		Radar = require(gameData:WaitForChild("Radars")),
		Food = require(gameData:WaitForChild("Foods")),
		Lantern = require(gameData:WaitForChild("Lanterns")),
		Pet = require(gameData:WaitForChild("Pets"))
	},
	Shop = require(gameData:WaitForChild("Shop")),
	Aging = require(gameServices:WaitForChild("PetAging")),
	GamepadGlyphs = require(gameServices:WaitForChild("GamepadGlyphs")),
	ManualArrangement = false,
	LastOrder = setmetatable({}, {
		__mode = "k"
	}),
	Arrived = setmetatable({}, {
		__mode = "k"
	}),
	ArrivalCount = 0,
	Settled = false,
	SavedOrder = {},
	SavedOrderLoaded = false,
	OrderApplied = false,
	Mutations = 0,
	Numbers = 0
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Mutations = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Mutations"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
v.Numbers = require(ReplicatedStorage3:WaitForChild("GameServices"):WaitForChild("StringService"))

function v.CaptionFor(instance)
	local weight = tonumber(instance:GetAttribute("Weight"))

	if not weight then
		local data = instance:FindFirstChild("Data")
		local weight2 = data and data:FindFirstChild("Weight")
		weight = weight2 and tonumber(weight2.Value) or nil
	end

	if not weight then
		return nil
	end

	local v3 = nil

	if instance:HasTag("Pet") then
		v3 = v.Numbers.Abbreviate(v.Aging.InflatePetWeight(weight), 2, true) .. " KG"
	elseif instance:HasTag("Egg") then
		v3 = v.Numbers.Abbreviate(v.Aging.InflateEggWeight(weight), 2, true) .. " KG"
	end

	if not v3 then
		return nil
	end

	local mutation = instance:GetAttribute("Mutation")
	local v4 = mutation and v.Mutations.HexFor(mutation)

	if mutation and v4 then
		local v5 = instance:HasTag("Pet") and "\n" or " "
		return string.format("<font color=\"%s\">[%s]</font>%s%s", v4, mutation, v5, v3)
	else
		return v3
	end
end

function v.InbornTagFor(instance)
	local spawnMutation = instance:GetAttribute("SpawnMutation")
	local v3 = spawnMutation and v.Mutations.HexFor(spawnMutation)

	if spawnMutation and v3 then
		return string.format("<font color=\"%s\">[%s]</font>", v3, spawnMutation)
	end

	return nil
end

function v.Resolve(instance)
	if instance.TextureId ~= "" then
		return instance.TextureId
	end

	local petName = instance:GetAttribute("PetName") or instance.Name

	for tag, v3 in v.ByTag do
		if not instance:HasTag(tag) then
			continue
		end

		local v4 = v3[petName]

		if v4 and v4.Image and v4.Image ~= "" then
			return v4.Image
		else
			break
		end
	end

	for _, v3 in { v.Shop.Gears, v.Shop.Food } do
		local v4 = v3 and v3[petName]

		if v4 and v4.ImageId and v4.ImageId ~= "" then
			return v4.ImageId
		end
	end

	return ""
end

local Satchel = {
	OpenClose = nil,
	IsOpen = false,
	StateChanged = Instance.new("BindableEvent"),
	ModuleName = "Backpack",
	KeepVRTopbarOpen = true,
	VRIsExclusive = true,
	VRClosesNonExclusive = true,
	BackpackEmpty = Instance.new("BindableEvent")
}
Satchel.BackpackEmpty.Name = "BackpackEmpty"
Satchel.BackpackItemAdded = Instance.new("BindableEvent")
Satchel.BackpackItemAdded.Name = "BackpackAdded"
Satchel.BackpackItemRemoved = Instance.new("BindableEvent")
Satchel.BackpackItemRemoved.Name = "BackpackRemoved"
local script2 = script
require(script.Attribution)

local function PlayClickSound()
	local SFX = SoundService:FindFirstChild("SFX")
	local click = SFX and SFX:FindFirstChild("Click")

	if not (click and click:IsA("Sound")) then
		return
	end

	local clone = click:Clone()
	clone.Parent = SoundService
	clone:Play()
	task.delay(3, function()
		clone:Destroy()
	end)
end

local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local favoritePet = game2:FindFirstChild("FavoritePet")

local function GetFavoriteRemote()
	if not favoritePet then
		favoritePet = game2:WaitForChild("FavoritePet", 10)
	end

	return favoritePet
end

local preferredTransparency = GuiService.PreferredTransparency or 1
local v3 = not script2:GetAttribute("OutlineEquipBorder") or false
local insetIconPadding = script2:GetAttribute("InsetIconPadding")
local backgroundTransparency = script2:GetAttribute("BackgroundTransparency") or 0.3
local backgroundTransparency3 = backgroundTransparency * preferredTransparency
local uDim = UDim.new(0, 8)
local backgroundColor3 = script2:GetAttribute("BackgroundColor3") or Color3.new(
	0.09803921568627451,
	0.10588235294117647,
	0.11372549019607843
)
local equipBorderColor3 = script2:GetAttribute("EquipBorderColor3") or Color3.new(0, 0.6352941176470588, 1)
local backgroundTransparency2 = script2:GetAttribute("BackgroundTransparency") or 0.3
local backgroundTransparency4 = backgroundTransparency2 * preferredTransparency
local equipBorderSizePixel = script2:GetAttribute("EquipBorderSizePixel") or 1
local uDim2 = UDim.new(0, 3)
local color = Color3.new(1, 1, 1)
local uDim3 = UDim2.new(1, -10, 0.633, -10)
local uDim4 = UDim.new(0, 3)
local backgroundColor32 = script2:GetAttribute("BackgroundColor3") or Color3.new(
	0.09803921568627451,
	0.10588235294117647,
	0.11372549019607843
)
local textColor3 = script2:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
local textStrokeTransparency = script2:GetAttribute("TextStrokeTransparency") or 0.5
local textStrokeColor3 = script2:GetAttribute("TextStrokeColor3") or Color3.new(0, 0, 0)
local color2 = Color3.new(0.09803921568627451, 0.10588235294117647, 0.11372549019607843)
local backgroundTransparency5 = preferredTransparency * 0.2
local color3 = Color3.new(1, 1, 1)
local uDim5 = UDim.new(0, 3)
local fontFace = script2:GetAttribute("FontFace") or Font.new("rbxasset://fonts/families/BuilderSans.json")
local textSize = script2:GetAttribute("TextSize") or 13
local value = Enum.KeyCode.Backspace.Value
local value2 = Enum.KeyCode.Zero.Value
local v7 = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true
}
local v8 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}
local v9 = true
local topbarplus = require(script.Parent.topbarplus)
local v10 = topbarplus.new():setName("Inventory"):setImage("rbxasset://textures/ui/TopBar/inventoryOn.png", "Selected"):setImage(
	"rbxasset://textures/ui/TopBar/inventoryOff.png",
	"Deselected"
):setImageScale(1):setCaption("Inventory"):bindToggleKey(Enum.KeyCode.Backquote):autoDeselect(false):setOrder(-1)
local screenGui = Instance.new("ScreenGui")
screenGui.DisplayOrder = 120
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Name = "BackpackGui"
screenGui.Parent = playerGui
local isTenFootInterface = GuiService:IsTenFootInterface()
local v11

if isTenFootInterface then
	v11 = 100
	textSize = 24
else
	v11 = 60
end

local v12 = false
local v13 = UserInputService.TouchEnabled and workspace.CurrentCamera.ViewportSize.X < 1024
local localPlayer = Players.LocalPlayer
local frame = nil
local frame2 = nil
local frame3 = nil
local textButton = nil
local scrollingFrame = nil
local frame4 = nil
local fn
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local backpack = localPlayer:WaitForChild("Backpack")
local v14 = {}
local v15 = nil
local v16 = {}
local v17 = {}
local v18 = {}
local v19 = 0
local v20 = nil
local v21 = false
local v22 = false
local v23 = false
local flag = false
local v24 = "All"

local function fn2(_)
	return true
end

local function fn3() end

function v.RefreshViewSoon()
	if v.ViewRefreshQueued then
		return
	end

	v.ViewRefreshQueued = true
	task.defer(function()
		v.ViewRefreshQueued = false
		fn3()
	end)
end

local function fn4() end

local connections = {}
local flag2 = false
local vREnabled = VRService.VREnabled
local v25 = vREnabled and 6 or v13 and 5 or 10
local v26 = vREnabled and 3 or v13 and 2 or 4
local v27 = nil

local function EvaluateBackpackPanelVisibility(flag3: boolean)
	return flag3 and v10.enabled and v9 and VRService.VREnabled
end

local function ShowVRBackpackPopup() end

local function FindLowestEmpty()
	for i = 1, v25 do
		local v28 = v14[i]

		if not v28.Tool then
			return v28
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInventoryEmpty()
	for i = v25 + 1, #v14 do
		local v28 = v14[i]

		if v28 and v28.Tool then
			return false
		end
	end

	return true
end

Satchel.IsInventoryEmpty = isInventoryEmpty

local function UseGazeSelection()
	return false
end

local function AdjustHotbarFrames()
	local visible = frame3.Visible
	local v28 = 0

	for i = 1, v25 do
		if v14[i] and v14[i].Tool then
			v28 += 1
		end
	end

	if visible then
		v28 = v25 or v28
	end

	local v29 = v28 + 1
	local v30 = 1

	for i = 1, v25 do
		local v31 = v14[i]

		if v31.Tool or visible then
			v30 += 1
			v31:Readjust(v30, v29)
			v31.Frame.Visible = true
		else
			v31.Frame.Visible = false
		end
	end

	if RepositionBackpackButton then
		RepositionBackpackButton()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateScrollingFrameCanvasSize()
	local v28 = math.floor(scrollingFrame.AbsoluteSize.X / (v11 + 5))
	local v29 = math.ceil((#frame4:GetChildren() - 1) / v28) * (v11 + 5) + 5
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, v29)
end

local function AdjustInventoryFrames()
	for i = v25 + 1, #v14 do
		local v28 = v14[i]
		v28.Frame.LayoutOrder = v28.Index
		v28.Frame.Visible = v28.Tool ~= nil
	end

	UpdateScrollingFrameCanvasSize() -- equivalent call inferred; original call site unknown
end

local function UpdateBackpackLayout()
	frame2.Size = UDim2.new(0, v25 * (v11 + 5) + 5, 0, v11 + 5 + 5)
	frame2.Position = UDim2.new(0.5, -frame2.Size.X.Offset / 2, 1, -frame2.Size.Y.Offset)
	frame3.Size = UDim2.new(0, frame2.Size.X.Offset, 0, frame2.Size.Y.Offset * v26 + 40 + (vREnabled and 80 or 0))
	frame3.Position = UDim2.new(0.5, -frame3.Size.X.Offset / 2, 1, frame2.Position.Y.Offset - frame3.Size.Y.Offset)
	scrollingFrame.Size = UDim2.new(1, scrollingFrame.ScrollBarThickness + 1, 1, -40 - (vREnabled and 80 or 0))
	scrollingFrame.Position = UDim2.fromOffset(0, 40 + (vREnabled and 40 or 0))
	AdjustHotbarFrames()
	AdjustInventoryFrames()
end

local function Clamp(p: number, p2: number, p3: number)
	return (math.min(p2, (math.max(p, p3))))
end

local function CheckBounds(p, p2: number, p3: number)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return absolutePosition.X < p2 and p2 <= absolutePosition.X + absoluteSize.X and absolutePosition.Y < p3 and p3 <= absolutePosition.Y + absoluteSize.Y
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOffset(frame5, vector: Vector2)
	return (frame5.AbsolutePosition + frame5.AbsoluteSize / 2 - vector).Magnitude
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisableActiveHopper()
	v20:ToggleSelect()
	v16[v20]:UpdateEquipView()
	v20 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UnequipAllTools()
	if humanoid then
		humanoid:UnequipTools()

		if v20 then
			DisableActiveHopper() -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EquipNewTool(tool)
	UnequipAllTools() -- equivalent call inferred; original call site unknown
	humanoid:EquipTool(tool)
end

local function IsEquipped(p)
	return p and p.Parent == character
end

local fn5
local v28 = nil
local MakeSlot

MakeSlot = function(parent, p: number?)
	local v29 = p or #v14 + 1
	local v30 = {
		Tool = nil,
		Index = v29,
		Frame = nil
	}
	local textButton2 = nil
	local frame5 = nil
	local imageLabel = nil
	local clone = nil
	local textLabel = nil
	local clone2 = nil
	local textLabel2 = nil
	local changedConnection = nil
	local attributeChangedConnection = nil
	local childAddedConnection = nil
	local levelChangedConnection = nil
	local favoritedChangedConnection = nil
	local valueChangedConnection = nil
	local uIStroke = nil
	local backgroundTransparency6 = backgroundTransparency3
	local textLabel3 = nil
	local textLabel4 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSlotFading()
		textButton2.SelectionImageObject = nil
		textButton2.BackgroundTransparency = backgroundTransparency6
	end

	local function ShowCooldown(cooldownStartTime, cooldownDuration)
		local cooldownOverlay = textButton2:FindFirstChild("CooldownOverlay")

		if cooldownOverlay then
			cooldownOverlay:Destroy()
		end

		local v32 = cooldownDuration.Value - (workspace:GetServerTimeNow() - cooldownStartTime.Value)

		if v32 <= 0.05 then
			return
		end

		local frame6 = Instance.new("Frame")
		frame6.Name = "CooldownOverlay"
		frame6.AnchorPoint = Vector2.new(1, 1)
		frame6.Size = UDim2.new(1, 0, 1, 0)
		frame6.Position = UDim2.new(1, 0, 1, 0)
		frame6.BackgroundTransparency = 0.3
		frame6.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		local textLabel5 = Instance.new("TextLabel")
		textLabel5.TextScaled = true
		textLabel5.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel5.Size = UDim2.new(0.7, 0, 0.3, 0)
		textLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel5.BackgroundTransparency = 1
		textLabel5.BorderSizePixel = 0
		textLabel5.Position = UDim2.new(0.5, 0, 0.5, 0)
		textLabel5.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
		textLabel5.Parent = frame6
		local corner = textButton2:FindFirstChild("Corner")

		if corner then
			local clone = corner:Clone()
			clone.Parent = frame6
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v33 = workspace:GetServerTimeNow() - cooldownStartTime.Value
			local v34 = cooldownDuration.Value - v33
			textLabel5.Text = string.format("%ss", String:FormatDecimal(v34, 1))
		end)
		frame6.Destroying:Connect(function()
			renderSteppedConnection:Disconnect()
		end)
		frame6.Parent = textButton2
		task.delay(v32, function()
			if frame6.Parent then
				frame6:Destroy()
			end
		end)
	end

	function v30:Readjust(p2: number, p3: number)
		local halfOffset = frame2.Size.X.Offset / 2
		local v33 = v11 + 5
		local v34 = p2 - (p3 / 2 + 0.5)
		textButton2.Position = UDim2.fromOffset(halfOffset - v11 / 2 + v33 * v34, 5)
	end

	function v30:Fill(tool)
		if not tool then
			return self:Clear()
		end

		if valueChangedConnection then
			valueChangedConnection:Disconnect()
			valueChangedConnection = nil
		end

		local cooldownOverlay = self.Tool ~= tool and textButton2:FindFirstChild("CooldownOverlay")

		if cooldownOverlay then
			cooldownOverlay:Destroy()
		end

		self.Tool = tool
		tool:FindFirstChild("Data")

		local function assignToolData()
			local resolved = v.Resolve(tool)
			imageLabel.Image = resolved

			if tool:HasTag("Brainrot") then
				task.spawn(function()
					local total = 0

					while not (tool:FindFirstChildWhichIsA("BasePart") or tool:FindFirstChildWhichIsA("Model")) do
						task.wait(0.1)
						total += 0.1

						if total > 5 or v30.Tool ~= tool then
							return
						end
					end

					task.wait(0.1)

					if v30.Tool == tool and not clone:FindFirstChildOfClass("Camera") then
						General:PlaceModelInViewport(tool, clone)
					end
				end)
			end

			if resolved == "" and not tool:HasTag("Brainrot") then
				textLabel.Visible = true
			else
				textLabel.Visible = false
			end

			if clone2 then
				local text

				if not textLabel.Visible then
					text = v.CaptionFor(tool)
				end

				if text then
					clone2.Text = text
					clone2.Visible = true
				else
					clone2.Text = ""
					clone2.Visible = false
				end
			end

			if textLabel2 then
				local inbornTagFor = v.InbornTagFor(tool)
				textLabel2.Text = inbornTagFor or ""
				textLabel2.Visible = inbornTagFor ~= nil
			end

			local fontFace2 = fontFace
			textLabel.Size = uDim3
			textLabel.TextScaled = true
			local v33 = textLabel:FindFirstChildOfClass("UITextSizeConstraint")

			if not v33 then
				v33 = Instance.new("UITextSizeConstraint")
				v33.Parent = textLabel
			end

			v33.MinTextSize = 4
			v33.MaxTextSize = 14
			textLabel.FontFace = fontFace2
			textLabel.Text = tool.Name

			if textLabel4 then
				textLabel4.FontFace = fontFace2
			end

			if textLabel3 and tool:IsA("Tool") then
				textLabel3.Text = tool.ToolTip
				textLabel3.FontFace = fontFace2
				textLabel3.Size = UDim2.fromOffset(0, 16)
				textLabel3.Position = UDim2.new(0.5, 0, 0, -5)
			end

			if tool:GetAttribute("Rarity") then
				local uIGradient = textLabel:FindFirstChildOfClass("UIGradient")

				if uIGradient then
					uIGradient:Destroy()
				end

				local gradient = RarityConfig.Gradients[tool:GetAttribute("Rarity")]

				if not gradient then
					return warn((`[{script.Name}]: No gradient exists for rarity '{tool:GetAttribute("Rarity")}'`))
				end

				local uIGradient2 = Instance.new("UIGradient")
				uIGradient2.Color = gradient
				uIGradient2.Rotation = 90
				uIGradient2.Parent = textLabel
			end

			local data = tool:FindFirstChild("Data")

			if data then
				local cooldownStartTime = data:FindFirstChild("CooldownStartTime")
				local cooldownDuration = data:FindFirstChild("CooldownDuration")

				if cooldownStartTime and cooldownDuration then
					valueChangedConnection = cooldownStartTime:GetPropertyChangedSignal("Value"):Connect(function()
						ShowCooldown(cooldownStartTime, cooldownDuration)
					end)
					ShowCooldown(cooldownStartTime, cooldownDuration)
				elseif cooldownStartTime and not cooldownDuration then
					warn("no cooldown duration for toolname: " .. tool.Name)
				end
			end

			local level = tool:GetAttribute("Level")

			if level then
				local level2 = textButton2:FindFirstChild("Level")

				if not level2 then
					level2 = script:WaitForChild("Level"):Clone()
					level2.Parent = textButton2
				end

				level2.Text = string.format("lv.%i", level)
				levelChangedConnection = tool:GetAttributeChangedSignal("Level"):Connect(function()
					level = tool:GetAttribute("Level")
					level2.Text = string.format("lv.%i", level)
				end)
			end

			if favoritedChangedConnection then
				favoritedChangedConnection:Disconnect()
				favoritedChangedConnection = nil
			end

			if tool:HasTag("Pet") then
				local favorite = textButton2:FindFirstChild("Favorite")

				if not favorite then
					favorite = script:WaitForChild("Favorite"):Clone()
					favorite.Name = "Favorite"
					favorite.Parent = textButton2
				end

				favorite.Visible = tool:GetAttribute("Favorited") == true
				favoritedChangedConnection = tool:GetAttributeChangedSignal("Favorited"):Connect(function()
					favorite.Visible = tool:GetAttribute("Favorited") == true
				end)
			else
				local favorite = textButton2:FindFirstChild("Favorite")

				if favorite then
					favorite.Visible = false
				end
			end

			local data2 = tool:FindFirstChild("Data")

			if data2 then
				local amount = data2:FindFirstChild("Amount")
				local amount2 = textButton2:FindFirstChild("Amount")

				if amount then
					if not amount2 then
						amount2 = script:WaitForChild("Amount"):Clone()
						amount2.Parent = textButton2
					end

					amount2.AnchorPoint = Vector2.new(1, 1)
					amount2.Position = UDim2.new(1, -2.5, 1, -2.5)
					amount2.Size = UDim2.new(1, -5, amount2.Size.Y.Scale, amount2.Size.Y.Offset)
					amount2.TextScaled = true
					amount2.TextWrapped = true
					amount2.TextTruncate = Enum.TextTruncate.None

					if amount.Value > 1 then
						amount2.Text = string.format("x%i", amount.Value)
						amount2.Visible = true
					else
						amount2.Visible = false
					end
				elseif amount2 then
					amount2.Visible = false
				end
			end
		end

		assignToolData()

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if attributeChangedConnection then
			attributeChangedConnection:Disconnect()
			attributeChangedConnection = nil
		end

		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		if levelChangedConnection then
			levelChangedConnection:Disconnect()
			levelChangedConnection = nil
		end

		local HookAmount

		HookAmount = function()
			local data = tool:FindFirstChild("Data")

			if not data then
				childAddedConnection = tool.ChildAdded:Connect(function(child)
					if child.Name == "Data" and v30.Tool == tool then
						childAddedConnection:Disconnect()
						HookAmount()
						assignToolData()
					end
				end)
				return
			end

			local amount = data:FindFirstChild("Amount")

			if amount then
				childAddedConnection = amount:GetPropertyChangedSignal("Value"):Connect(function()
					assignToolData()
				end)
			else
				childAddedConnection = data.ChildAdded:Connect(function(child)
					if child.Name == "Amount" and v30.Tool == tool then
						childAddedConnection:Disconnect()
						HookAmount()
						assignToolData()
					end
				end)
			end
		end

		HookAmount()
		changedConnection = tool.Changed:Connect(function(p2: string)
			if p2 == "TextureId" or p2 == "Name" or p2 == "ToolTip" then
				assignToolData()
			end
		end)
		attributeChangedConnection = tool.AttributeChanged:Connect(function(p2)
			if p2 == "Rarity" or p2 == "PetName" or p2 == "PetKey" or p2 == "Weight" or p2 == "Mutation" or p2 == "SpawnMutation" then
				assignToolData()
				v.RefreshViewSoon()
			end
		end)
		local v32 = self.Index <= v25
		local visible = frame3.Visible

		if (not v32 or visible) and not UserInputService.VREnabled then
			textButton2.Draggable = true
		end

		self:UpdateEquipView()

		if v32 then
			v19 += 1

			if v22 and v19 >= 1 and not v12 then
				v12 = true
				ContextActionService:BindAction(
					"BackpackHotbarEquip",
					fn,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		end

		v16[tool] = self
		local flag3 = true
		local v33

		for i = 1, v25 do
			v33 = v14[i]

			if v33.Tool then
				continue
			end

			flag3 = false
			break
		end

		if flag3 then
			v33 = nil
		end

		v15 = v33
	end

	function v30:Clear()
		if not self.Tool then
			return
		end

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if valueChangedConnection then
			valueChangedConnection:Disconnect()
			valueChangedConnection = nil
		end

		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		if attributeChangedConnection then
			attributeChangedConnection:Disconnect()
			attributeChangedConnection = nil
		end

		if levelChangedConnection then
			levelChangedConnection:Disconnect()
			levelChangedConnection = nil
		end

		local cooldownOverlay = textButton2:FindFirstChild("CooldownOverlay")

		if cooldownOverlay then
			cooldownOverlay:Destroy()
		end

		local amount = textButton2:FindFirstChild("Amount")

		if amount then
			amount.Visible = false
		end

		local level = textButton2:FindFirstChild("Level")

		if level then
			level:Destroy()
		end

		if favoritedChangedConnection then
			favoritedChangedConnection:Disconnect()
			favoritedChangedConnection = nil
		end

		local favorite = textButton2:FindFirstChild("Favorite")

		if favorite then
			favorite.Visible = false
		end

		local uIGradient = textLabel:FindFirstChildOfClass("UIGradient")

		if uIGradient then
			uIGradient:Destroy()
		end

		local uIGradient2 = textButton2:FindFirstChildOfClass("UIGradient")

		if uIGradient2 then
			uIGradient2:Destroy()
		end

		clone:ClearAllChildren()
		textButton2.BackgroundColor3 = backgroundColor3
		backgroundTransparency6 = backgroundTransparency3
		textButton2.BackgroundTransparency = backgroundTransparency3
		imageLabel.Image = ""
		textLabel.Text = ""

		if clone2 then
			clone2.Text = ""
			clone2.Visible = false
		end

		if textLabel2 then
			textLabel2.Text = ""
			textLabel2.Visible = false
		end

		if textLabel3 then
			textLabel3.Text = ""
			textLabel3.Visible = false
		end

		textButton2.Draggable = false
		self:UpdateEquipView(true)

		if self.Index <= v25 then
			v19 -= 1

			if v19 < 1 then
				v12 = false
				ContextActionService:UnbindAction("BackpackHotbarEquip")
			end
		end

		v16[self.Tool] = nil
		self.Tool = nil
		local flag3 = true
		local v32

		for i = 1, v25 do
			v32 = v14[i]

			if v32.Tool then
				continue
			end

			flag3 = false
			break
		end

		if flag3 then
			v32 = nil
		end

		v15 = v32
	end

	function v30:UpdateEquipView(flag3: boolean?)
		if flag3 then
			if uIStroke then
				uIStroke.Parent = nil
			end
		else
			local tool = self.Tool

			if tool and tool.Parent == character then
				v27 = v30

				if not uIStroke then
					uIStroke = Instance.new("UIStroke")
					uIStroke.Name = "Border"
					uIStroke.Thickness = 2
					uIStroke.Color = equipBorderColor3
					uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				end

				if v3 == true then
					uIStroke.Parent = imageLabel
				else
					uIStroke.Parent = textButton2
				end
			elseif uIStroke then
				uIStroke.Parent = nil
			end
		end

		UpdateSlotFading() -- equivalent call inferred; original call site unknown
	end

	function v30:IsEquipped()
		local tool = self.Tool
		return tool and tool.Parent == character
	end

	function v30:Delete()
		textButton2:Destroy()
		table.remove(v14, self.Index)
		local v32 = #v14

		for i = self.Index, v32 do
			v14[i]:SlideBack()
		end

		UpdateScrollingFrameCanvasSize() -- equivalent call inferred; original call site unknown
	end

	function v30:Swap(object2)
		v.ManualArrangement = true
		local tool = self.Tool
		local tool2 = object2.Tool
		self:Clear()

		if tool2 then
			object2:Clear()
			self:Fill(tool2)
		end

		if tool then
			object2:Fill(tool)
		else
			object2:Clear()
		end

		if v.SaveOrderSoon then
			v.SaveOrderSoon()
		end
	end

	function v30:SlideBack()
		self.Index -= 1
		textButton2.Name = self.Index
		textButton2.LayoutOrder = self.Index
	end

	function v30:TurnNumber(visible: boolean)
		if textLabel4 then
			textLabel4.Visible = visible
		end
	end

	function v30:SetClickability(flag3: boolean)
		if self.Tool then
			if UserInputService.VREnabled then
				textButton2.Draggable = false
			else
				textButton2.Draggable = not flag3
			end

			UpdateSlotFading() -- equivalent call inferred; original call site unknown
		end
	end

	function v30:CheckTerms(items)
		local count = 0

		local function checkEm(text: string, k)
			if k == "" then
				return
			end

			local lower = text:lower()
			local v32 = 1

			while true do
				local v33, v34 = string.find(lower, k, v32, true)

				if not v33 then
					break
				end

				count += 1
				v32 = v34 + 1
			end
		end

		local tool = self.Tool

		if not tool then
			return count
		end

		for k in pairs(items) do
			checkEm(textLabel.Text, k)

			if tool:IsA("Tool") then
				checkEm(textLabel3 and textLabel3.Text or "", k)
			end
		end

		return count
	end

	function v30:Select()
		local tool = v30.Tool

		if tool then
			if tool and tool.Parent == character then
				UnequipAllTools() -- equivalent call inferred; original call site unknown
			elseif tool.Parent == backpack then
				EquipNewTool(tool) -- equivalent call inferred; original call site unknown
			end
		end
	end

	function v30:ToggleFavorite()
		local tool = v30.Tool

		if not (tool and tool:HasTag("Pet")) then
			return
		end

		local petKey = tool:GetAttribute("PetKey")

		if not petKey then
			return
		end

		if not favoritePet then
			favoritePet = game2:WaitForChild("FavoritePet", 10)
		end

		local v32 = favoritePet

		if not v32 then
			return
		end

		PlayClickSound()
		v32:FireServer(petKey)
	end

	textButton2 = Instance.new("TextButton")
	textButton2.Name = tostring(v29)
	textButton2.BackgroundColor3 = backgroundColor3
	textButton2.BorderColor3 = color
	textButton2.Text = ""
	textButton2.BorderSizePixel = 0
	textButton2.Size = UDim2.fromOffset(v11, v11)
	textButton2.Active = true
	textButton2.Draggable = false
	textButton2.BackgroundTransparency = backgroundTransparency4
	textButton2.MouseButton1Click:Connect(function()
		changeSlot(v30)
	end)
	textButton2.MouseButton2Click:Connect(function()
		v30:ToggleFavorite()
	end)
	local uICorner = Instance.new("UICorner")
	uICorner.Name = "Corner"
	uICorner.CornerRadius = uDim2
	uICorner.Parent = textButton2
	v30.Frame = textButton2
	local frame6 = Instance.new("Frame")
	frame6.Name = "SelectionObjectClipper"
	frame6.BackgroundTransparency = 1
	frame6.Visible = false
	frame6.Parent = textButton2
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "Selector"
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Size = UDim2.fromScale(1, 1)
	imageLabel2.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
	imageLabel2.ScaleType = Enum.ScaleType.Slice
	imageLabel2.SliceCenter = Rect.new(12, 12, 52, 52)
	imageLabel2.Parent = frame6
	imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Name = "Icon"
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	clone = script:WaitForChild("Viewport"):Clone()
	clone.Parent = textButton2

	if insetIconPadding == true then
		imageLabel.Size = UDim2.new(1, -equipBorderSizePixel * 2, 1, -equipBorderSizePixel * 2)
	else
		imageLabel.Size = UDim2.fromScale(1, 1)
	end

	imageLabel.Parent = textButton2
	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "Corner"

	if insetIconPadding == true then
		uICorner2.CornerRadius = uDim2 - UDim.new(0, equipBorderSizePixel)
	else
		uICorner2.CornerRadius = uDim2
	end

	textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Name = "ToolName"
	textLabel.Text = ""
	textLabel.TextColor3 = textColor3
	textLabel.TextStrokeTransparency = textStrokeTransparency
	textLabel.TextStrokeColor3 = textStrokeColor3
	textLabel.RichText = true
	textLabel.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	textLabel.TextSize = textSize
	textLabel.Size = uDim3
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.TextWrapped = true
	textLabel.TextTruncate = Enum.TextTruncate.None
	textLabel.Parent = textButton2
	local slotTemplate = script:FindFirstChild("SlotTemplate")
	local withIconLabel = slotTemplate and slotTemplate:FindFirstChild("WithIconLabel")

	if withIconLabel then
		clone2 = withIconLabel:Clone()
		clone2.Name = "WithIconLabel"
		clone2.Text = ""
		clone2.RichText = true
		clone2.TextScaled = true
		clone2.TextWrapped = true
		clone2.TextTruncate = Enum.TextTruncate.None
		clone2.Visible = false
		clone2.Parent = textButton2
	end

	textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "InbornLabel"
	textLabel2.BackgroundTransparency = 1
	textLabel2.AnchorPoint = Vector2.new(0, 0)
	textLabel2.Position = UDim2.fromScale(0.3, 0.02)
	textLabel2.Size = UDim2.fromScale(0.68, 0.24)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextYAlignment = Enum.TextYAlignment.Top
	textLabel2.TextScaled = true
	textLabel2.RichText = true
	textLabel2.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	textLabel2.TextColor3 = textColor3
	textLabel2.TextStrokeTransparency = textStrokeTransparency
	textLabel2.TextStrokeColor3 = textStrokeColor3
	textLabel2.ZIndex = textLabel.ZIndex + 2
	textLabel2.Text = ""
	textLabel2.Visible = false
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MinTextSize = 4
	uITextSizeConstraint.MaxTextSize = 14
	uITextSizeConstraint.Parent = textLabel2
	textLabel2.Parent = textButton2
	v30.Frame.LayoutOrder = v30.Index

	if v29 <= v25 then
		textLabel3 = Instance.new("TextLabel")
		textLabel3.Name = "ToolTip"
		textLabel3.Text = ""
		textLabel3.Size = UDim2.fromScale(1, 1)
		textLabel3.TextColor3 = textColor3
		textLabel3.TextStrokeTransparency = textStrokeTransparency
		textLabel3.TextStrokeColor3 = textStrokeColor3
		textLabel3.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		textLabel3.TextSize = textSize
		textLabel3.ZIndex = 2
		textLabel3.TextWrapped = false
		textLabel3.TextYAlignment = Enum.TextYAlignment.Center
		textLabel3.BackgroundColor3 = backgroundColor32
		textLabel3.BackgroundTransparency = backgroundTransparency4
		textLabel3.AnchorPoint = Vector2.new(0.5, 1)
		textLabel3.BorderSizePixel = 0
		textLabel3.Visible = false
		textLabel3.AutomaticSize = Enum.AutomaticSize.X
		textLabel3.Parent = textButton2
		local uICorner3 = Instance.new("UICorner")
		uICorner3.Name = "Corner"
		uICorner3.CornerRadius = uDim4
		uICorner3.Parent = textLabel3
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingLeft = UDim.new(0, 4)
		uIPadding.PaddingRight = UDim.new(0, 4)
		uIPadding.PaddingTop = UDim.new(0, 4)
		uIPadding.PaddingBottom = UDim.new(0, 4)
		uIPadding.Parent = textLabel3
		textButton2.MouseEnter:Connect(function()
			if textLabel3.Text ~= "" then
				textLabel3.Visible = true
			end
		end)
		textButton2.MouseLeave:Connect(function()
			textLabel3.Visible = false
		end)

		function v30:MoveToInventory()
			if v30.Index <= v25 then
				v.ManualArrangement = true
				local tool = v30.Tool
				self:Clear()
				local slot = MakeSlot(frame4)
				slot:Fill(tool)

				if tool and tool.Parent == character and humanoid then
					humanoid:UnequipTools()

					if v20 then
						DisableActiveHopper() -- equivalent call inferred; original call site unknown
					end
				end

				if flag then
					slot.Frame.Visible = false
					slot.Parent = frame3
				end

				if v.SaveOrderSoon then
					v.SaveOrderSoon()
				end
			end
		end

		if v29 < 10 or v29 == v25 then
			local v32 = v29 < 10 and (v29 or 0) or 0
			textLabel4 = Instance.new("TextLabel")
			textLabel4.BackgroundTransparency = 1
			textLabel4.Name = "Number"
			textLabel4.TextColor3 = textColor3
			textLabel4.TextStrokeTransparency = textStrokeTransparency
			textLabel4.TextStrokeColor3 = textStrokeColor3
			textLabel4.TextSize = textSize
			textLabel4.Text = tostring(v32)
			textLabel4.FontFace = fontFace
			textLabel4.Size = UDim2.fromScale(0.4, 0.4)
			textLabel4.Visible = false
			textLabel4.Parent = textButton2
			v17[value2 + v32] = v30.Select
		end
	end

	local position = textButton2.Position
	local v32 = 0
	local parent2 = nil
	local zero = Vector2.zero
	local zero2 = Vector2.zero
	textButton2.Destroying:Connect(function()
		v18[textButton2] = nil
		v.DragScroll.End(textButton2)

		if frame5 then
			frame5:Destroy()
			frame5 = nil
		end

		if not next(v18) then
			v10:unlock()
		end
	end)
	textButton2.DragBegin:Connect(function(udim: UDim2)
		v18[textButton2] = true
		v.DragScroll.Begin(scrollingFrame, textButton2)
		position = udim
		zero = textButton2.AbsolutePosition
		zero2 = textButton2.AbsoluteSize
		textButton2.BorderSizePixel = 2
		v10:lock()
		textButton2.ZIndex = 2
		imageLabel.ZIndex = 2
		textLabel.ZIndex = 2
		textButton2.Parent.ZIndex = 2

		if textLabel4 then
			textLabel4.ZIndex = 2
		end

		parent2 = textButton2.Parent

		if parent2 == frame4 then
			local uDim6 = UDim2.new(
				0,
				textButton2.AbsolutePosition.X - frame3.AbsolutePosition.X,
				0,
				textButton2.AbsolutePosition.Y - frame3.AbsolutePosition.Y
			)
			textButton2.Parent = frame3
			textButton2.Position = uDim6
			frame5 = Instance.new("Frame")
			frame5.Name = "FakeSlot"
			frame5.LayoutOrder = textButton2.LayoutOrder
			frame5.Size = textButton2.Size
			frame5.BackgroundTransparency = 1
			frame5.Parent = frame4
		end
	end)
	textButton2.DragStopped:Connect(function(p2: number, p3: number)
		if frame5 then
			frame5:Destroy()
		end

		local now = os.clock()
		textButton2.Position = position
		textButton2.Parent = parent2
		textButton2.BorderSizePixel = 0
		v10:unlock()
		textButton2.ZIndex = 1
		imageLabel.ZIndex = 1
		textLabel.ZIndex = 1
		parent2.ZIndex = 1

		if textLabel4 then
			textLabel4.ZIndex = 1
		end

		v18[textButton2] = nil
		v.DragScroll.End(textButton2)

		if not v30.Tool then
			return
		end

		if UserInputService:GetLastInputType() == Enum.UserInputType.Touch and v30.Tool:HasTag("Pet") and zero.X <= p2 and p2 <= zero.X + zero2.X and zero.Y <= p3 and p3 <= zero.Y + zero2.Y then
			v30:ToggleFavorite()
			v32 = now
		else
			local v33 = frame3
			local absolutePosition = v33.AbsolutePosition
			local absoluteSize = v33.AbsoluteSize
			local v34

			if absolutePosition.X < p2 and p2 <= absolutePosition.X + absoluteSize.X and absolutePosition.Y < p3 then
				v34 = p3 <= absolutePosition.Y + absoluteSize.Y
			else
				v34 = false
			end

			if v34 then
				if v30.Index <= v25 then
					v30:MoveToInventory()
				end

				if v25 < v30.Index and now - v32 < 0.5 then
					if v15 then
						v.ManualArrangement = true
						local tool = v30.Tool
						v30:Clear()
						v15:Fill(tool)
						v30:Delete()

						if v.SaveOrderSoon then
							v.SaveOrderSoon()
						end
					end

					now = 0
				end
			else
				local v35 = frame2
				local absolutePosition2 = v35.AbsolutePosition
				local absoluteSize2 = v35.AbsoluteSize
				local v36

				if absolutePosition2.X < p2 and p2 <= absolutePosition2.X + absoluteSize2.X and absolutePosition2.Y < p3 then
					v36 = p3 <= absolutePosition2.Y + absoluteSize2.Y
				else
					v36 = false
				end

				if v36 then
					local v37 = { 1e999, nil }

					for i = 1, v25 do
						local v38 = v14[i]
						local offset = GetOffset(v38.Frame, Vector2.new(p2, p3)) -- equivalent call inferred; original call site unknown

						if offset < v37[1] then
							v37 = { offset, v38 }
						end
					end

					local v38 = v37[2]

					if v38 ~= v30 then
						v30:Swap(v38)

						if v25 < v30.Index then
							local tool = v30.Tool

							if tool then
								if tool and tool.Parent == character and humanoid then
									humanoid:UnequipTools()

									if v20 then
										DisableActiveHopper() -- equivalent call inferred; original call site unknown
									end
								end

								if flag then
									v30.Frame.Visible = false
									v30.Frame.Parent = frame3
								end
							else
								v30:Delete()
							end
						end
					end
				elseif v30.Index <= v25 then
					v30:MoveToInventory()
				end
			end

			v32 = now
		end
	end)
	textButton2.Parent = parent
	v14[v29] = v30

	if v25 < v29 then
		UpdateScrollingFrameCanvasSize() -- equivalent call inferred; original call site unknown

		if frame3.Visible and not (flag or v.DragScroll.IsLocked()) then
			local v33 = scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteSize.Y
			scrollingFrame.CanvasPosition = Vector2.new(0, (math.max(0, v33)))
		end
	end

	return v30
end

local fn6

fn6 = function(p, tool)
	if #v14 < p then
		MakeSlot(p <= v25 and frame2 or frame4)
	end

	local v29 = v14[p]

	if not v29.Tool then
		v29:Fill(tool)
		return
	end

	local tool2 = v29.Tool
	v29:Clear()
	v29:Fill(tool)
	fn6(p + 1, tool2)
end

local function GetPetSpeed(instance)
	if instance == nil or not instance:HasTag("Pet") then
		return nil
	end

	local data = instance:FindFirstChild("Data")
	local speed = data and data:FindFirstChild("Speed")
	local v29 = v.ByTag.Pet[instance:GetAttribute("PetName")]
	local value3 = speed and tonumber(speed.Value) or v29 and v29.Speed or 0
	local weight = tonumber(instance:GetAttribute("Weight")) or v.Aging.WeightStandardKG
	local combinedFactor = v.Mutations.CombinedFactor(
		instance:GetAttribute("Mutation"),
		instance:GetAttribute("SpawnMutation")
	)
	return v.Aging.DisplaySpeedFor(value3, weight, combinedFactor)
end

function v.RideSpeedOf(instance)
	if instance == nil or not instance:HasTag("Pet") then
		return nil
	end

	local data = instance:FindFirstChild("Data")
	local speed = data and data:FindFirstChild("Speed")
	local v29 = v.ByTag.Pet[instance:GetAttribute("PetName")]
	local value3 = speed and tonumber(speed.Value) or v29 and v29.Speed or 0

	if not v.Aging.RealSpeedFor then
		return value3
	end

	local combinedFactor = v.Mutations.CombinedFactor(
		instance:GetAttribute("Mutation"),
		instance:GetAttribute("SpawnMutation")
	)
	return v.Aging.RealSpeedFor(value3, tonumber(instance:GetAttribute("Weight")), combinedFactor)
end

local function AppendAtEnd(p)
	local v29 = 0

	for i = 1, v25 do
		if v14[i] and v14[i].Tool then
			v29 = i
		end
	end

	local v30 = math.max(v29 + 1, 1)

	if v30 <= v25 and v14[v30] then
		v14[v30]:Fill(p)
		return v14[v30]
	end

	local v31 = v25

	for i = v25 + 1, #v14 do
		if v14[i] and v14[i].Tool then
			v31 = i
		end
	end

	local v32 = v31 + 1

	while #v14 < v32 do
		MakeSlot(frame4)
	end

	v14[v32]:Fill(p)
	return v14[v32]
end

local function PlaceReserved(p: number, p2)
	local v29 = v14[p]

	if not (v29 and v29.Tool ~= p2) then
		return
	end

	local tool = v29.Tool

	if tool then
		v29:Clear()
		AppendAtEnd(tool)
	end

	v29:Fill(p2)
end

local ShiftHotbarItems
local flag3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function ScheduleReflow()
	if flag3 then
		return
	end

	flag3 = true
	task.defer(function()
		flag3 = false
		ShiftHotbarItems()

		if not frame3.Visible then
			AdjustHotbarFrames()
		end
	end)
end

local function OnChildAdded(child)
	if localPlayer:GetAttribute("SatchelEnabled") == false then
		return
	end

	if child:IsA("Tool") or child:IsA("HopperBin") then
		local _ = child.Parent == character

		if v20 and child.Parent == character then
			DisableActiveHopper() -- equivalent call inferred; original call site unknown
		end

		if not v21 and child.Parent == character and not v16[child] then
			local starterGear = localPlayer:FindFirstChild("StarterGear")

			if starterGear and starterGear:FindFirstChild(child.Name) then
				v21 = true

				for i = (v15 or MakeSlot(frame4)).Index, 1, -1 do
					local v29 = v14[i]
					local v30 = i - 1

					if v30 > 0 then
						v14[v30]:Swap(v29)
					else
						v29:Fill(child)
					end
				end

				for _, tool in pairs(character:GetChildren()) do
					if tool:IsA("Tool") and tool ~= child then
						tool.Parent = backpack
					end
				end

				AdjustHotbarFrames()
				return
			end
		end

		local v29 = v16[child]

		if v29 then
			v29:UpdateEquipView()
		else
			if v.LastOrder[child] == nil then
				AppendAtEnd(child)

				if v.Settled then
					v.ArrivalCount += 1
					v.Arrived[child] = v.ArrivalCount
				end
			end

			ScheduleReflow() -- equivalent call inferred; original call site unknown

			if child:IsA("HopperBin") and child.Active then
				UnequipAllTools() -- equivalent call inferred; original call site unknown
				v20 = child
			end
		end

		Satchel.BackpackItemAdded:Fire()
	elseif child:IsA("Humanoid") and child.Parent == character then
		humanoid = child
	end
end

ShiftHotbarItems = function()
	local v29 = {}
	local v30 = {}

	local function Take(tool, order: number)
		local v31 = v.LastOrder[tool]

		if v31 then
			v.LastOrder[tool] = nil
			order = v31 - 0.5
		end

		local speed = GetPetSpeed(tool)

		if speed then
			table.insert(v29, {
				Tool = tool,
				Speed = speed,
				Order = order
			})
		else
			table.insert(v30, {
				Tool = tool,
				Speed = nil,
				Order = order
			})
		end
	end

	local v31 = {}

	for i = 1, #v14 do
		local v32 = v14[i]
		local tool = v32 and v32.Tool

		if not tool then
			continue
		end

		if v31[tool] or tool.Parent ~= backpack and tool.Parent ~= character then
			if not v31[tool] then
				v.LastOrder[tool] = i
			end

			v32:Clear()
		else
			v31[tool] = true
			Take(tool, i)
		end
	end

	for _, v32 in { backpack, character } do
		if not v32 then
			continue
		end

		for _, child in v32:GetChildren() do
			if not (child:IsA("Tool") or child:IsA("HopperBin")) or v31[child] then
				continue
			end

			v31[child] = true
			Take(child, 1000000000)
		end
	end

	local v32 = v.HasSavedOrder() or nil
	local v33 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn7(p, p2)
		return p.Order < p2.Order
	end

	for _, v34 in v29 do
		table.insert(v33, v34)
	end

	for _, v34 in v30 do
		table.insert(v33, v34)
	end

	local v34

	if v32 then
		v34 = v.PositionsFor(v33) or nil
	else
		v34 = nil
	end

	if v32 then
		v.OrderApplied = true
	end

	if v34 and next(v34) == nil then
		v34 = nil
	end

	local fn8 = v34 and function(p, p2)
		local v35 = v34[p.Tool]
		local v36 = v34[p2.Tool]

		if v35 and v36 then
			return v35.Position < v36.Position
		end

		if v35 or v36 then
			return v35 ~= nil
		end

		return fn7(p, p2)
	end or fn7
	table.sort(v33, fn8)
	local v35 = math.max(v25 - 0, 0)
	local tools = {}
	local v36 = {}
	local v37 = {}
	local v38 = {}

	for _, v39 in v33 do
		local v40 = v34 and v34[v39.Tool]

		if v40 then
			if v40.Hotbar and #tools < v35 then
				table.insert(tools, v39.Tool)
			elseif v39.Speed then
				table.insert(v36, v39)
			else
				table.insert(v37, v39)
			end
		elseif v39.Order >= 1000000000 then
			table.insert(v38, v39)
		elseif v39.Order <= v25 and #tools < v35 then
			table.insert(tools, v39.Tool)
		elseif v39.Speed then
			table.insert(v36, v39)
		else
			table.insert(v37, v39)
		end
	end

	for _, v39 in v38 do
		if #tools < v35 then
			table.insert(tools, v39.Tool)
		elseif v39.Speed then
			table.insert(v36, v39)
		else
			table.insert(v37, v39)
		end
	end

	local v39 = false

	if v35 > 0 then
		local tool = nil

		for _, v41 in v33 do
			local tool2 = v41.Tool

			if not (tool2 and tool2.Parent == character) then
				continue
			end

			tool = v41.Tool
			break
		end

		local rideSpeed = v.RideSpeedOf(tool)
		local v41 = {}
		local v42 = {}

		for _, entry in v33 do
			v41[entry.Tool] = entry
			local v44 = v.Arrived[entry.Tool]
			local sequence = v44 == nil and v.Settled and entry.Order >= 1000000000 and 1e999 or v44

			if not sequence or v34 and v34[entry.Tool] then
				continue
			end

			table.insert(v42, {
				Entry = entry,
				Sequence = sequence
			})
		end

		table.sort(v42, function(a, b)
			return a.Sequence < b.Sequence
		end)

		local function RemoveFrom(list, tool2)
			for k, v43 in list do
				if v43.Tool ~= tool2 then
					continue
				end

				table.remove(list, k)
				break
			end
		end

		for _, v43 in v42 do
			local entry = v43.Entry
			local index = table.find(tools, entry.Tool)

			if index then
				if index ~= #tools then
					table.remove(tools, index)
					table.insert(tools, entry.Tool)
					v39 = true
				end
			else
				local v44 = v35 <= #tools
				local rideSpeed2 = v.RideSpeedOf(entry.Tool)

				if not v44 or not rideSpeed2 or not rideSpeed or entry.Tool == tool or not (rideSpeed2 <= rideSpeed) then
					local v45 = nil

					if v44 then
						for i = #tools, 1, -1 do
							local v46 = tools[i]

							if not (not v46 or v46.Parent ~= character) then
								continue
							end

							v45 = i
							break
						end

						if not v45 then
							continue
						end
					end

					RemoveFrom(v36, entry.Tool)
					RemoveFrom(v37, entry.Tool)

					if v45 then
						local v46 = table.remove(tools, v45)
						local v47 = v46 and v41[v46]

						if v47 then
							table.insert(v47.Speed and v36 or v37, v47)
						end
					end

					table.insert(tools, entry.Tool)
					v39 = true
				end
			end
		end
	end

	table.clear(v.Arrived)

	if v.ManualArrangement then
		for _, v40 in v36 do
			table.insert(v37, v40)
		end

		table.clear(v36)
	end

	table.sort(v36, function(a, b)
		if a.Speed == b.Speed then
			return fn7(a, b)
		end

		return a.Speed > b.Speed
	end)
	table.sort(v37, fn8)
	local tools2 = {}

	for _, v40 in v36 do
		table.insert(tools2, v40.Tool)
	end

	for _, v40 in v37 do
		table.insert(tools2, v40.Tool)
	end

	local v40 = {}
	local v41 = 1

	for _, v42 in ipairs(tools) do
		v40[v41] = v42
		v41 += 1
	end

	local v42 = v25 + 1

	for _, v43 in ipairs(tools2) do
		v40[v42] = v43
		v42 += 1
	end

	local v43 = v42 - 1

	for i = 1, #v14 do
		local v44 = v14[i]

		if v44 and v44.Tool and v44.Tool ~= v40[i] then
			v44:Clear()
		end
	end

	for i = 1, v43 do
		local v44 = v40[i]

		if not v44 then
			continue
		end

		while #v14 < i do
			MakeSlot(frame4)
		end

		local v45 = v14[i]

		if v45 and v45.Tool ~= v44 then
			v45:Fill(v44)
		end
	end

	for i = #v14, v25 + 1, -1 do
		if v14[i] and not v14[i].Tool then
			v14[i]:Delete()
		else
			break
		end
	end

	v.Settled = true

	if v39 and v32 then
		local hotbar = {}
		local backpack2 = {}

		for i = 1, #v14 do
			local v46 = v14[i]
			local v47 = v46 and v46.Tool and v.ItemId(v46.Tool)

			if v47 then
				table.insert(i <= v25 and hotbar or backpack2, v47)
			end
		end

		v.SavedOrder = {
			Hotbar = hotbar,
			Backpack = backpack2
		}
	end

	v.SaveOrderSoon()
end

function v.ItemId(instance)
	if not instance then
		return nil
	end

	local petKey = instance:GetAttribute("PetKey")

	if typeof(petKey) == "string" and petKey ~= "" then
		return "Pet:" .. petKey
	end

	return instance.Name
end

function v.LoadOrder()
	local satchelOrder = localPlayer:GetAttribute("SatchelOrder")

	if typeof(satchelOrder) ~= "string" or satchelOrder == "" then
		return
	end

	local success, result = pcall(function()
		local HttpService = game:GetService("HttpService")
		return HttpService:JSONDecode(satchelOrder)
	end)

	if not success or typeof(result) ~= "table" then
		return
	end

	local hotbar2 = {}
	local backpack3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Fill(list, list2)
		for _, v31 in ipairs(list) do
			if typeof(v31) == "string" then
				table.insert(list2, v31)
			end
		end
	end

	if typeof(result.Hotbar) == "table" or typeof(result.Backpack) == "table" then
		local hotbar = result.Hotbar or {}
		Fill(hotbar, hotbar2) -- equivalent call inferred; original call site unknown
		local backpack2 = result.Backpack or {}
		Fill(backpack2, backpack3) -- equivalent call inferred; original call site unknown
	else
		for i, v31 in ipairs(result) do
			if typeof(v31) == "string" then
				table.insert(i <= v25 and hotbar2 or backpack3, v31)
			end
		end
	end

	v.SavedOrder = {
		Hotbar = hotbar2,
		Backpack = backpack3
	}
	v.SavedOrderLoaded = true
end

function v.HasSavedOrder()
	local savedOrder = v.SavedOrder
	local savedOrderLoaded = v.SavedOrderLoaded

	if savedOrderLoaded then
		if typeof(savedOrder) == "table" then
			savedOrderLoaded = (savedOrder.Hotbar and #savedOrder.Hotbar > 0 and true or savedOrder.Backpack and #savedOrder.Backpack > 0) == true
		else
			savedOrderLoaded = false
		end
	end

	return savedOrderLoaded
end

function v.PositionsFor(items)
	local result = {}

	if not v.HasSavedOrder() then
		return result
	end

	local v29 = {}

	for _, item in items do
		local itemId = v.ItemId(item.Tool)

		if not itemId then
			continue
		end

		v29[itemId] = v29[itemId] or {}
		table.insert(v29[itemId], item)
	end

	for k, list in v29 do
		table.sort(list, function(a, b)
			local v30 = v.Arrived[a.Tool] or 0
			local v31 = v.Arrived[b.Tool] or 0

			if v30 == v31 then
				return (a.Order or 0) < (b.Order or 0)
			end

			return v30 < v31
		end)
		local tools = table.create(#list)

		for k2, v30 in list do
			tools[k2] = v30.Tool
		end

		v29[k] = tools
	end

	local v30 = {}
	local count = 0

	local function Walk(list, hotbar)
		for _, v31 in ipairs(list) do
			count += 1
			local v32 = v29[v31]

			if not v32 then
				continue
			end

			v30[v31] = (v30[v31] or 0) + 1
			local v33 = v32[v30[v31]]

			if v33 then
				result[v33] = {
					Position = count,
					Hotbar = hotbar
				}
			end
		end
	end

	Walk(v.SavedOrder.Hotbar or {}, true)
	Walk(v.SavedOrder.Backpack or {}, false)
	return result
end

v.SaveQueued = false
v.SaveDelay = 1

function v.SaveOrderSoon()
	if v.SaveQueued or v.HasSavedOrder() and not v.OrderApplied then
		return
	end

	v.SaveQueued = true
	task.delay(v.SaveDelay, function()
		v.SaveQueued = false
		local hotbar = {}
		local backpack2 = {}

		for i = 1, #v14 do
			local v31 = v14[i]
			local v32 = v31 and v31.Tool and v.ItemId(v31.Tool)

			if v32 then
				table.insert(i <= v25 and hotbar or backpack2, v32)
			end
		end

		if #hotbar == 0 and #backpack2 == 0 then
			return
		end

		local savedOrder = {
			Hotbar = hotbar,
			Backpack = backpack2
		}
		v.SavedOrder = savedOrder
		v.SavedOrderLoaded = true
		local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
		local game3 = remotes and remotes:FindFirstChild("Game")
		local saveSatchelOrder = game3 and game3:FindFirstChild("SaveSatchelOrder")

		if saveSatchelOrder then
			saveSatchelOrder:FireServer(savedOrder)
		end
	end)
end

v.LoadOrder()
localPlayer:GetAttributeChangedSignal("SatchelOrder"):Connect(function()
	local savedOrderLoaded = v.SavedOrderLoaded
	v.LoadOrder()

	if not savedOrderLoaded and v.SavedOrderLoaded then
		ScheduleReflow() -- equivalent call inferred; original call site unknown
	end
end)

local function OnChildRemoved(instance)
	if not (localPlayer:GetAttribute("SatchelEnabled") ~= false and (instance:IsA("Tool") or instance:IsA("HopperBin"))) then
		return
	end

	local parent = instance.Parent

	if parent == character or parent == backpack then
		return
	end

	local v29 = v16[instance]

	if v29 then
		v.LastOrder[instance] = v29.Index
		v29:Clear()
		ScheduleReflow() -- equivalent call inferred; original call site unknown

		if not frame3.Visible then
			AdjustHotbarFrames()
		end
	end

	if instance == v20 then
		v20 = nil
	end

	Satchel.BackpackItemRemoved:Fire()

	-- equivalent call inferred; original call site unknown
	if isInventoryEmpty() then
		Satchel.BackpackEmpty:Fire()
	end
end

local function OnCharacterAdded(character2)
	for i = #v14, 1, -1 do
		local v29 = v14[i]

		if v29.Tool then
			v29:Clear()
		end

		if v25 < i then
			v29:Delete()
		end
	end

	v20 = nil

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	character = character2
	table.insert(connections, character2.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, character2.ChildAdded:Connect(OnChildAdded))

	for _, child in pairs(character2:GetChildren()) do
		OnChildAdded(child)
	end

	backpack = localPlayer:WaitForChild("Backpack")
	table.insert(connections, backpack.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, backpack.ChildAdded:Connect(OnChildAdded))

	for _, child in pairs(backpack:GetChildren()) do
		OnChildAdded(child)
	end

	AdjustHotbarFrames()
end

local v29 = {
	Tracking = nil,
	StartPos = nil,
	StartTime = 0,
	Moved = false
}

local function OnInputBegan(tracking, flag4: boolean)
	local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
	local v30 = tracking.UserInputType == Enum.UserInputType.Keyboard and not v23 and not chatInputBarConfiguration.IsFocused and (v22 or tracking.KeyCode.Value == value) and v17[tracking.KeyCode.Value]

	if v30 then
		v30(flag4)
	end

	local userInputType = tracking.UserInputType

	if not flag4 then
		if userInputType == Enum.UserInputType.MouseButton1 then
			if frame3.Visible then
				v10:deselect()
			end
		elseif userInputType == Enum.UserInputType.Touch and frame3.Visible then
			v29.StartPos = tracking.Position
			v29.StartTime = os.clock()
			v29.Moved = false
			v29.Tracking = tracking
		end
	end
end

local function OnUISChanged()
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		for i = 1, v25 do
			v14[i]:TurnNumber(false)
		end
	elseif UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard then
		for i = 1, v25 do
			v14[i]:TurnNumber(true)
		end
	else
		for _, v30 in pairs(v7) do
			if UserInputService:GetLastInputType() ~= v30 then
				continue
			end

			for i = 1, v25 do
				v14[i]:TurnNumber(true)
			end

			return
		end

		for _, v30 in pairs(v8) do
			if UserInputService:GetLastInputType() ~= v30 then
				continue
			end

			for i = 1, v25 do
				v14[i]:TurnNumber(false)
			end

			return
		end
	end
end

local v30 = nil
local lastTime = nil

local function fn7() end

function unbindAllGamepadEquipActions()
	ContextActionService:UnbindAction("BackpackHasGamepadFocus")
	ContextActionService:UnbindAction("BackpackCloseInventory")
end

fn = function(_: string, p, p2)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	if v30 and (v30.KeyCode == Enum.KeyCode.ButtonR1 and p2.KeyCode == Enum.KeyCode.ButtonL1 or v30.KeyCode == Enum.KeyCode.ButtonL1 and p2.KeyCode == Enum.KeyCode.ButtonR1) and os.clock() - lastTime <= 0.06 then
		UnequipAllTools() -- equivalent call inferred; original call site unknown
		v30 = p2
		lastTime = os.clock()
	else
		v30 = p2
		lastTime = os.clock()
		task.delay(0.06, function()
			if v30 ~= p2 then
				return
			end

			local v31 = p2.KeyCode == Enum.KeyCode.ButtonL1 and -1 or 1

			for i = 1, v25 do
				if not v14[i]:IsEquipped() then
					continue
				end

				local v32 = v31 + i
				local v33 = false

				if v25 < v32 then
					v32 = 1
					v33 = true
				elseif v32 < 1 then
					v32 = v25
					v33 = true
				end

				local v34 = v32

				while not v14[v32].Tool do
					v32 += v31

					if v32 == v34 then
						return
					end

					if v25 < v32 then
						v32 = 1
						v33 = true
					elseif v32 < 1 then
						v32 = v25
						v33 = true
					end
				end

				if not v33 then
					v14[v32]:Select()
					return
				end

				UnequipAllTools() -- equivalent call inferred; original call site unknown
				v27 = nil
				return
			end

			if v27 and v27.Tool then
				v27:Select()
				return
			end

			for i = v31 == -1 and (v25 or 1) or 1, v31 == -1 and 1 or v25, v31 do
				if not v14[i].Tool then
					continue
				end

				v14[i]:Select()
				break
			end
		end)
	end
end

function getGamepadSwapSlot()
	for i = 1, #v14 do
		if v14[i].Frame.BorderSizePixel > 0 then
			return v14[i]
		end
	end
end

function changeSlot(object)
	local v31 = not VRService.VREnabled or frame3.Visible

	if object.Frame == GuiService.SelectedObject and v31 then
		local gamepadSwapSlot = getGamepadSwapSlot()

		if gamepadSwapSlot then
			gamepadSwapSlot.Frame.BorderSizePixel = 0

			if gamepadSwapSlot ~= object then
				object:Swap(gamepadSwapSlot)
				textButton.SelectionImageObject.Visible = false

				if v25 < object.Index and not object.Tool then
					if GuiService.SelectedObject == object.Frame then
						GuiService.SelectedObject = gamepadSwapSlot.Frame
					end

					object:Delete()
				end

				if v25 < gamepadSwapSlot.Index and not gamepadSwapSlot.Tool then
					if GuiService.SelectedObject == gamepadSwapSlot.Frame then
						GuiService.SelectedObject = object.Frame
					end

					gamepadSwapSlot:Delete()
				end
			end
		else
			local size = object.Frame.Size
			local position = object.Frame.Position
			object.Frame:TweenSizeAndPosition(
				size + UDim2.fromOffset(10, 10),
				position - UDim2.fromOffset(5, 5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					object.Frame:TweenSizeAndPosition(
						size,
						position,
						Enum.EasingDirection.In,
						Enum.EasingStyle.Quad,
						0.1,
						true
					)
				end
			)
			object.Frame.BorderSizePixel = 3
			textButton.SelectionImageObject.Visible = true
		end
	else
		object:Select()
		textButton.SelectionImageObject.Visible = false
	end
end

function vrMoveSlotToInventory()
	if not VRService.VREnabled then
		return
	end

	local gamepadSwapSlot = getGamepadSwapSlot()

	if gamepadSwapSlot and gamepadSwapSlot.Tool then
		gamepadSwapSlot.Frame.BorderSizePixel = 0
		gamepadSwapSlot:MoveToInventory()
		textButton.SelectionImageObject.Visible = false
	end
end

function enableGamepadInventoryControl()
	local function fn8()
		if getGamepadSwapSlot() then
			local gamepadSwapSlot = getGamepadSwapSlot()

			if gamepadSwapSlot then
				gamepadSwapSlot.Frame.BorderSizePixel = 0
			end
		elseif frame3.Visible then
			v10:deselect()
		end
	end

	ContextActionService:BindAction("BackpackHasGamepadFocus", fn7, false, Enum.UserInputType.Gamepad1)
	ContextActionService:BindAction(
		"BackpackCloseInventory",
		fn8,
		false,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonStart
	)
	GamepadUI.Focus(frame3)

	if not GamepadUI.CursorActive() then
		GuiService.SelectedObject = frame2:FindFirstChild("1")
	end
end

function disableGamepadInventoryControl()
	unbindAllGamepadEquipActions()

	for i = 1, v25 do
		local v31 = v14[i]

		if v31 and v31.Frame then
			v31.Frame.BorderSizePixel = 0
		end
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then
		GuiService.SelectedObject = nil
	end
end

local function bindBackpackHotbarAction()
	if v22 and not v12 then
		v12 = true
		ContextActionService:BindAction("BackpackHotbarEquip", fn, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindBackpackHotbarAction()
	disableGamepadInventoryControl()
	v12 = false
	ContextActionService:UnbindAction("BackpackHotbarEquip")
end

function gamepadDisconnected()
	flag2 = false
	disableGamepadInventoryControl()
end

function gamepadConnected()
	flag2 = true
	GuiService:AddSelectionParent("BackpackSelection", frame)

	if v19 >= 1 and v22 and not v12 then
		v12 = true
		ContextActionService:BindAction("BackpackHotbarEquip", fn, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	end

	if frame3.Visible then
		enableGamepadInventoryControl()
	end
end

local function OnIconChanged(visible: boolean)
	local success, _ = pcall(function()
		return visible and StarterGui:GetCore("TopbarEnabled")
	end)

	if not success then
		return
	end

	v22 = visible
	frame.Visible = visible

	if visible then
		if v19 >= 1 and v22 and not v12 then
			v12 = true
			ContextActionService:BindAction(
				"BackpackHotbarEquip",
				fn,
				false,
				Enum.KeyCode.ButtonL1,
				Enum.KeyCode.ButtonR1
			)
		end
	else
		unbindBackpackHotbarAction() -- equivalent call inferred; original call site unknown
	end
end

local function MakeVRRoundButton(name: string, image: string)
	local imageButton = Instance.new("ImageButton")
	imageButton.BackgroundTransparency = 1
	imageButton.Name = name
	imageButton.Size = UDim2.fromOffset(40, 40)
	imageButton.Image = "rbxasset://textures/ui/Keyboard/close_button_background.png"
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.25, 0.25)
	imageLabel.Image = image
	imageLabel.Parent = imageButton
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Name = "Selection"
	imageLabel2.Size = UDim2.fromScale(0.9, 0.9)
	imageLabel2.Position = UDim2.fromScale(0.05, 0.05)
	imageLabel2.Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png"
	imageButton.SelectionImageObject = imageLabel2
	return imageButton, imageLabel, imageLabel2
end

frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Name = "Backpack"
frame.Size = UDim2.fromScale(1, 1)
frame.Visible = false
frame.Parent = screenGui
frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.Name = "Hotbar"
frame2.Size = UDim2.fromScale(1, 1)
frame2.Parent = frame

for i = 1, v25 do
	local slot = MakeSlot(frame2, i)
	slot.Frame.Visible = false

	if not v15 then
		v15 = slot
	end
end

local imageLabel = Instance.new("ImageLabel")
imageLabel.BackgroundTransparency = 1
imageLabel.Name = "LeftBumper"
imageLabel.Size = UDim2.fromOffset(40, 40)
imageLabel.Position = UDim2.new(0, -imageLabel.Size.X.Offset, 0.5, -imageLabel.Size.Y.Offset / 2)
local imageLabel2 = Instance.new("ImageLabel")
imageLabel2.BackgroundTransparency = 1
imageLabel2.Name = "RightBumper"
imageLabel2.Size = UDim2.fromOffset(40, 40)
imageLabel2.Position = UDim2.new(1, 0, 0.5, -imageLabel2.Size.Y.Offset / 2)
frame3 = Instance.new("Frame")
frame3.Name = "Inventory"
frame3.Size = UDim2.fromScale(1, 1)
frame3.BackgroundTransparency = backgroundTransparency3
frame3.BackgroundColor3 = backgroundColor3
frame3.Active = true
frame3.Visible = false
frame3.Parent = frame
local uICorner = Instance.new("UICorner")
uICorner.Name = "Corner"
uICorner.CornerRadius = uDim
uICorner.Parent = frame3
textButton = Instance.new("TextButton")
textButton.Name = "VRInventorySelector"
textButton.Position = UDim2.new(0, 0, 0, 0)
textButton.Size = UDim2.fromScale(1, 1)
textButton.BackgroundTransparency = 1
textButton.Text = ""
textButton.Parent = frame3
local imageLabel3 = Instance.new("ImageLabel")
imageLabel3.BackgroundTransparency = 1
imageLabel3.Name = "Selector"
imageLabel3.Size = UDim2.fromScale(1, 1)
imageLabel3.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
imageLabel3.ScaleType = Enum.ScaleType.Slice
imageLabel3.SliceCenter = Rect.new(12, 12, 52, 52)
imageLabel3.Visible = false
textButton.SelectionImageObject = imageLabel3
textButton.MouseButton1Click:Connect(function()
	vrMoveSlotToInventory()
end)
scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.fromScale(1, 1)
scrollingFrame.Selectable = false
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.ScrollBarImageColor3 = Color3.new(1, 1, 1)
scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = frame3
UserInputService.WindowFocusReleased:Connect(v.DragScroll.Reset)
frame3:GetPropertyChangedSignal("Visible"):Connect(function()
	if not frame3.Visible then
		v.DragScroll.Reset()
	end
end)
frame4 = Instance.new("Frame")
frame4.BackgroundTransparency = 1
frame4.Name = "UIGridFrame"
frame4.Selectable = false
frame4.Size = UDim2.new(1, -10, 1, 0)
frame4.Position = UDim2.fromOffset(5, 0)
frame4.Parent = scrollingFrame
local uIGridLayout = Instance.new("UIGridLayout")
uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIGridLayout.CellSize = UDim2.fromOffset(v11, v11)
uIGridLayout.CellPadding = UDim2.fromOffset(5, 5)
uIGridLayout.Parent = frame4
local vRRoundButton = MakeVRRoundButton("ScrollUpButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
vRRoundButton.Size = UDim2.fromOffset(34, 34)
vRRoundButton.Position = UDim2.new(0.5, -vRRoundButton.Size.X.Offset / 2, 0, 43)
local icon = vRRoundButton.Icon
icon.Position = vRRoundButton.Icon.Position - UDim2.fromOffset(0, 2)
vRRoundButton.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		(math.min(
			scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y,
			(math.max(0, scrollingFrame.CanvasPosition.Y - (v11 + 5)))
		))
	)
end)
local vRRoundButton2 = MakeVRRoundButton("ScrollDownButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
vRRoundButton2.Rotation = 180
local icon2 = vRRoundButton2.Icon
icon2.Position = vRRoundButton2.Icon.Position - UDim2.fromOffset(0, 2)
vRRoundButton2.Size = UDim2.fromOffset(34, 34)
vRRoundButton2.Position = UDim2.new(0.5, -vRRoundButton2.Size.X.Offset / 2, 1, -vRRoundButton2.Size.Y.Offset - 3)
vRRoundButton2.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		(math.min(
			scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y,
			(math.max(0, scrollingFrame.CanvasPosition.Y + (v11 + 5)))
		))
	)
end)
scrollingFrame.Changed:Connect(function(p: string)
	if p == "AbsoluteWindowSize" or p == "CanvasPosition" or p == "CanvasSize" then
		local visible = scrollingFrame.CanvasPosition.Y ~= 0
		local visible2 = scrollingFrame.CanvasPosition.Y < scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y
		vRRoundButton.Visible = visible
		vRRoundButton2.Visible = visible2
	end
end)
UpdateBackpackLayout()
local frame5 = Instance.new("Frame")
frame5.Name = "GamepadHintsFrame"
frame5.Size = UDim2.fromOffset(frame2.Size.X.Offset, isTenFootInterface and 95 or 60)
frame5.BackgroundTransparency = backgroundTransparency3
frame5.BackgroundColor3 = backgroundColor3
frame5.Visible = false
frame5.Parent = frame
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "Layout"
uIListLayout.Padding = UDim.new(0, 25)
uIListLayout.FillDirection = Enum.FillDirection.Horizontal
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = frame5
local uICorner2 = Instance.new("UICorner")
uICorner2.Name = "Corner"
uICorner2.CornerRadius = uDim
uICorner2.Parent = frame5

local function resizeGamepadHintsFrame()
	frame5.Size = UDim2.new(frame2.Size.X.Scale, frame2.Size.X.Offset, 0, isTenFootInterface and 95 or 60)
	frame5.Position = UDim2.new(
		frame2.Position.X.Scale,
		frame2.Position.X.Offset,
		frame3.Position.Y.Scale,
		frame3.Position.Y.Offset - frame5.Size.Y.Offset - 5
	)
	local children = frame5:GetChildren()
	local guiObjects = {}
	local total = 0

	for _, guiObject in pairs(children) do
		if guiObject:IsA("GuiObject") then
			table.insert(guiObjects, guiObject)
		end
	end

	for i = 1, #guiObjects do
		if not guiObjects[i]:IsA("GuiObject") then
			continue
		end

		guiObjects[i].Size = UDim2.new(1, 0, 1, -5)
		guiObjects[i].Position = UDim2.new(0, 0, 0, 0)
		total += guiObjects[i].HintText.Position.X.Offset + guiObjects[i].HintText.TextBounds.X
	end

	local v33 = (frame5.AbsoluteSize.X - total) / (#guiObjects - 1)

	for i = 1, #guiObjects do
		guiObjects[i].Position = i == 1 and UDim2.new(0, 0, 0, 0) or UDim2.new(
			0,
			guiObjects[i - 1].Position.X.Offset + guiObjects[i - 1].Size.X.Offset + v33,
			0,
			0
		)
		guiObjects[i].Size = UDim2.new(
			0,
			guiObjects[i].HintText.Position.X.Offset + guiObjects[i].HintText.TextBounds.X,
			1,
			-5
		)
	end
end

local uDim6 = isTenFootInterface and UDim2.fromOffset(60, 60) or UDim2.fromOffset(30, 30)

local function addGamepadHint(p, text: string)
	local frame6 = Instance.new("Frame")
	frame6.Name = "HintFrame"
	frame6.AutomaticSize = Enum.AutomaticSize.XY
	frame6.BackgroundTransparency = 1
	frame6.Parent = frame5
	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.Name = "Layout"
	uIListLayout2.Padding = isTenFootInterface and UDim.new(0, 20) or UDim.new(0, 12)
	uIListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout2.Parent = frame6
	local v33, text2 = v.GamepadGlyphs.For(p)

	if v33 or not text2 then
		local imageLabel4 = Instance.new("ImageLabel")
		imageLabel4.Name = "HintImage"
		imageLabel4.Size = uDim6
		imageLabel4.BackgroundTransparency = 1
		imageLabel4.Image = v33 or ""
		imageLabel4.Parent = frame6
	else
		local frame7 = Instance.new("Frame")
		frame7.Name = "HintImage"
		frame7.Size = uDim6
		frame7.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		frame7.BackgroundTransparency = 0.05
		frame7.BorderSizePixel = 0
		frame7.Parent = frame6
		local uICorner3 = Instance.new("UICorner")
		uICorner3.Name = "Corner"
		uICorner3.CornerRadius = UDim.new(0.22, 0)
		uICorner3.Parent = frame7
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "Outline"
		uIStroke.Color = Color3.fromRGB(255, 255, 255)
		uIStroke.Thickness = 1.5
		uIStroke.Transparency = 0.6
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Parent = frame7
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Glyph"
		textLabel.Size = UDim2.fromScale(0.76, 0.76)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text2
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.Parent = frame7
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "HintText"
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	textLabel.TextSize = isTenFootInterface and 32 or 19
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.TextWrapped = true
	textLabel.Parent = frame6
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = textLabel.TextSize
	uITextSizeConstraint.Parent = textLabel
end

local function buildGamepadHints()
	for _, guiObject in pairs(frame5:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	addGamepadHint(Enum.KeyCode.ButtonX, "Remove From Hotbar")
	addGamepadHint(Enum.KeyCode.ButtonA, "Select/Swap")
	addGamepadHint(Enum.KeyCode.ButtonB, "Close Backpack")

	if frame5.Visible then
		resizeGamepadHintsFrame()
	end
end

buildGamepadHints()
UserInputService.GamepadConnected:Connect(function()
	task.defer(buildGamepadHints)
end)
local frame6 = Instance.new("Frame")
frame6.Name = "Search"
frame6.BackgroundColor3 = color2
frame6.BackgroundTransparency = backgroundTransparency5
frame6.Size = UDim2.new(0, 190, 0, 30)
frame6.Position = UDim2.new(1, -frame6.Size.X.Offset - 5, 0, 5)
frame6.Parent = frame3
local uICorner3 = Instance.new("UICorner")
uICorner3.Name = "Corner"
uICorner3.CornerRadius = uDim5
uICorner3.Parent = frame6
local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "Border"
uIStroke.Color = color3
uIStroke.Thickness = 1
uIStroke.Transparency = 0.8
uIStroke.Parent = frame6
local textBox = Instance.new("TextBox")
textBox.BackgroundTransparency = 1
textBox.Name = "TextBox"
textBox.Text = ""
textBox.TextColor3 = textColor3
textBox.TextStrokeTransparency = textStrokeTransparency
textBox.TextStrokeColor3 = textStrokeColor3
textBox.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
textBox.PlaceholderText = "Search"
textBox.TextColor3 = textColor3
textBox.TextTransparency = textStrokeTransparency
textBox.TextStrokeColor3 = textStrokeColor3
textBox.ClearTextOnFocus = false
textBox.TextTruncate = Enum.TextTruncate.AtEnd
textBox.TextSize = textSize
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Center
textBox.Size = UDim2.new(0, 154, 0, 14)
textBox.AnchorPoint = Vector2.new(0, 0.5)
textBox.Position = UDim2.new(0, 8, 0.5, 0)
textBox.ZIndex = 2
textBox.Parent = frame6
local textButton2 = Instance.new("TextButton")
textButton2.Name = "X"
textButton2.Text = ""
textButton2.Size = UDim2.fromOffset(30, 30)
textButton2.Position = UDim2.new(1, -textButton2.Size.X.Offset, 0.5, -textButton2.Size.Y.Offset / 2)
textButton2.ZIndex = 4
textButton2.Visible = false
textButton2.BackgroundTransparency = 1
textButton2.Parent = frame6
local imageButton = Instance.new("ImageButton")
imageButton.Name = "X"
imageButton.Image = "rbxasset://textures/ui/InspectMenu/x.png"
imageButton.BackgroundTransparency = 1
imageButton.Size = UDim2.new(0, frame6.Size.Y.Offset - 20, 0, frame6.Size.Y.Offset - 20)
imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
imageButton.Position = UDim2.fromScale(0.5, 0.5)
imageButton.ZIndex = 1
imageButton.BorderSizePixel = 0
imageButton.Parent = textButton2

local function search()
	local v33 = {}

	for k in textBox.Text:gmatch("%S+") do
		v33[k:lower()] = true
	end

	local v34 = {}

	for i = v25 + 1, #v14 do
		local v35 = v14[i]
		table.insert(v34, { v35, (v35:CheckTerms(v33)) })
		v35.Frame.Visible = false
		v35.Frame.Parent = frame3
	end

	table.sort(v34, function(a, b)
		return a[2] > b[2]
	end)
	flag = true
	local count = 0

	for _, v35 in ipairs(v34) do
		local v36 = v35[1]
		local v37 = v35[2]
		local v38

		if v36.Tool == nil then
			v38 = false
		else
			v38 = fn2(v36.Tool)
		end

		if not (v37 > 0 and v38) then
			continue
		end

		v36.Frame.Visible = true
		v36.Frame.Parent = frame4
		v36.Frame.LayoutOrder = v25 + count
		count += 1
	end

	scrollingFrame.CanvasPosition = Vector2.new(0, 0)
	UpdateScrollingFrameCanvasSize() -- equivalent call inferred; original call site unknown
	textButton2.ZIndex = 3
end

local function clearResults()
	if textButton2.ZIndex > 0 then
		flag = false

		for i = v25 + 1, #v14 do
			local v33 = v14[i]
			v33.Frame.LayoutOrder = v33.Index
			v33.Frame.Parent = frame4
			v33.Frame.Visible = true
		end

		textButton2.ZIndex = 0
		fn4()
	end

	UpdateScrollingFrameCanvasSize() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reset()
	clearResults()
	textBox.Text = ""
end

local function onChanged(p: string)
	if p == "Text" then
		local text = textBox.Text

		if text == "" then
			textBox.TextTransparency = textStrokeTransparency
			clearResults()
		elseif text ~= "" then
			textBox.TextTransparency = 0
			search()
		end

		textButton2.Visible = text ~= "" and text ~= ""
	end
end

local function focusLost(flag4: boolean)
	if flag4 then
		search()
	end
end

textButton2.MouseButton1Click:Connect(reset)
textBox.Changed:Connect(onChanged)
textBox.FocusLost:Connect(focusLost)

fn3 = function()
	if flag then
		search()
	else
		fn4()
	end
end

Satchel.StateChanged.Event:Connect(function(flag4: boolean)
	if not flag4 then
		reset() -- equivalent call inferred; original call site unknown
	end
end)

v17[Enum.KeyCode.Escape.Value] = function(p)
	if p then
		reset() -- equivalent call inferred; original call site unknown
	end
end

local function detectGamepad(p)
	if p == Enum.UserInputType.Gamepad1 and not UserInputService.VREnabled then
		frame6.Visible = false
	else
		frame6.Visible = true
	end
end

UserInputService.LastInputTypeChanged:Connect(detectGamepad)
GuiService.MenuOpened:Connect(function()
	screenGui.Enabled = false
	v10:setEnabled(false)
end)
GuiService.MenuClosed:Connect(function()
	screenGui.Enabled = true
	v10:setEnabled(true)
end)

local function fn8(_: string, p, _)
	if not (p == Enum.UserInputState.Begin and GuiService.SelectedObject) then
		return
	end

	for i = 1, v25 do
		if not (v14[i].Frame == GuiService.SelectedObject and v14[i].Tool) then
			continue
		end

		v14[i]:MoveToInventory()
		break
	end
end

local function openClose()
	if not next(v18) then
		frame3.Visible = not frame3.Visible
		local visible = frame3.Visible
		AdjustHotbarFrames()
		frame2.Active = not frame2.Active

		for i = 1, v25 do
			v14[i]:SetClickability(not visible)
		end

		if visible then
			fn5()
		end
	end

	if frame3.Visible then
		if flag2 then
			if v8[UserInputService:GetLastInputType()] then
				resizeGamepadHintsFrame()
				frame5.Visible = not UserInputService.VREnabled
			end

			enableGamepadInventoryControl()
		end
	else
		if flag2 then
			frame5.Visible = false
		end

		disableGamepadInventoryControl()
	end

	if frame3.Visible then
		ContextActionService:BindAction("BackpackRemoveSlot", fn8, false, Enum.KeyCode.ButtonX)
	else
		ContextActionService:UnbindAction("BackpackRemoveSlot")
	end

	Satchel.IsOpen = frame3.Visible
	Satchel.StateChanged:Fire(frame3.Visible)
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
Satchel.OpenClose = openClose
v10.toggled:Connect(function()
	if not GuiService.MenuIsOpen then
		Satchel.OpenClose()
	end
end)

while not localPlayer do
	task.wait()
	localPlayer = Players.LocalPlayer
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)

if localPlayer.Character then
	OnCharacterAdded(localPlayer.Character)
end

local function RebuildBackpack()
	for i = #v14, 1, -1 do
		local v33 = v14[i]

		if v33.Tool then
			v33:Clear()
		end

		if v25 < i then
			v33:Delete()
		end
	end

	v20 = nil
	v21 = false

	if not (character and backpack) then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") or child:IsA("HopperBin") then
			OnChildAdded(child)
		end
	end

	for _, child in ipairs(backpack:GetChildren()) do
		if child:IsA("Tool") or child:IsA("HopperBin") then
			OnChildAdded(child)
		end
	end

	AdjustHotbarFrames()
end

localPlayer:GetAttributeChangedSignal("SatchelEnabled"):Connect(function()
	if localPlayer:GetAttribute("SatchelEnabled") == false then
		return
	end

	RebuildBackpack()
end)
UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputChanged:Connect(function(input)
	if input == v29.Tracking and v29.StartPos and (Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(
		v29.StartPos.X,
		v29.StartPos.Y
	)).Magnitude > 12 then
		v29.Moved = true
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed: boolean)
	if input == v29.Tracking then
		local v33 = not v29.Moved and os.clock() - v29.StartTime <= 0.4
		v29.Tracking = nil
		v29.StartPos = nil
		v29.Moved = false

		if v33 and not gameProcessed and frame3.Visible then
			v10:deselect()
		end
	end
end)
UserInputService.TextBoxFocused:Connect(function()
	v23 = true
end)
UserInputService.TextBoxFocusReleased:Connect(function()
	v23 = false
end)

v17[value] = function()
	if v20 and humanoid then
		humanoid:UnequipTools()

		if v20 then
			DisableActiveHopper() -- equivalent call inferred; original call site unknown
		end
	end
end

UserInputService.LastInputTypeChanged:Connect(OnUISChanged)
OnUISChanged()

if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
	gamepadConnected()
end

UserInputService.GamepadConnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadConnected()
	end
end)
UserInputService.GamepadDisconnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadDisconnected()
	end
end)

function Satchel.SetBackpackEnabled(_, flag4: boolean)
	v9 = flag4
end

function Satchel.IsOpened(_)
	return Satchel.IsOpen
end

function Satchel.GetBackpackEnabled(_)
	return v9
end

function Satchel.GetStateChangedEvent(_)
	return Satchel.StateChanged
end

RunService.Heartbeat:Connect(function()
	OnIconChanged(v9)
end)

local function OnPreferredTransparencyChanged()
	local preferredTransparency2 = GuiService.PreferredTransparency
	backgroundTransparency3 = backgroundTransparency * preferredTransparency2
	frame3.BackgroundTransparency = backgroundTransparency3
	backgroundTransparency4 = backgroundTransparency2 * preferredTransparency2

	for _, v33 in ipairs(v14) do
		v33.Frame.BackgroundTransparency = backgroundTransparency4
	end

	backgroundTransparency5 = preferredTransparency2 * 0.2
	frame6.BackgroundTransparency = backgroundTransparency5
end

GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(OnPreferredTransparencyChanged)

fn5 = function()
	local v33 = {
		Pets = {},
		Eggs = {},
		Food = {},
		Gears = {}
	}
	local v34 = {
		Common = 1,
		Rare = 2,
		Epic = 3,
		Legendary = 4,
		Mythic = 5,
		Divine = 6,
		Ethereal = 7
	}

	for i = v25 + 1, #v14 do
		local v35 = v14[i]
		local tool = v35 and v35.Tool

		if not tool then
			continue
		end

		local pets = nil
		local v36 = nil
		local luck = 0

		if tool:HasTag("Pet") then
			pets = v33.Pets
			v36 = GetPetSpeed(tool) or 0
		elseif tool:HasTag("Egg") then
			local v37 = v.ByTag.Egg[tool.Name]
			pets = v33.Eggs
			luck = tonumber(v37 and v37.Luck) or 0
		elseif tool:HasTag("Food") then
			pets = v33.Food
		elseif tool:HasTag("Radar") or tool:HasTag("Lantern") or tool:HasTag("NameTag") then
			pets = v33.Gears
		end

		if not pets then
			continue
		end

		if v36 == nil then
			local rarity = tool:GetAttribute("Rarity")

			for tag, v37 in v.ByTag do
				local v38 = v37[tool.Name]

				if tool:HasTag(tag) and v38 then
					rarity = rarity or v38.Rarity
				end
			end

			local v37 = v.Shop.Gears and v.Shop.Gears[tool.Name]
			v36 = v34[rarity or v37 and v37.Rarity] or 0
		end

		table.insert(pets, {
			SlotIndex = i,
			Tool = tool,
			Value = v36,
			Luck = luck
		})
	end

	for _, list in v33 do
		local slotIndexes = {}

		for k, v35 in list do
			slotIndexes[k] = v35.SlotIndex
		end

		table.sort(list, function(a, b)
			if a.Value ~= b.Value then
				return a.Value > b.Value
			end

			if a.Luck == b.Luck then
				return a.SlotIndex < b.SlotIndex
			end

			return a.Luck > b.Luck
		end)
		local flag4 = false

		for k, v36 in list do
			if v36.SlotIndex == slotIndexes[k] then
				continue
			end

			flag4 = true
			break
		end

		if not flag4 then
			continue
		end

		for _, v36 in slotIndexes do
			v14[v36]:Clear()
		end

		for k, v36 in list do
			v14[slotIndexes[k]]:Fill(v36.Tool)
		end
	end
end

local v33 = {
	{
		Name = "All",
		Match = function(_)
			return true
		end
	},
	{
		Name = "Pets",
		Match = function(instance)
			return instance:HasTag("Pet")
		end
	},
	{
		Name = "Food",
		Match = function(instance)
			return instance:HasTag("Food")
		end
	},
	{
		Name = "Gears",
		Match = function(instance)
			return instance:HasTag("Radar") or instance:HasTag("Lantern") or instance:HasTag("NameTag")
		end
	},
	{
		Name = "Eggs",
		Match = function(instance)
			return instance:HasTag("Egg")
		end
	}
}
local buttonsByName = {}
local clone = nil
local v34 = {
	All = "All Items",
	Pets = "Pets",
	Food = "Food",
	Gears = "Gear",
	Eggs = "Eggs"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetMatchFn(p: string)
	for _, v35 in v33 do
		if v35.Name == p then
			return v35.Match
		end
	end

	return function(_)
		return true
	end
end

local function ApplyCategoryFilter()
	local matchFn = GetMatchFn(v24) -- equivalent call inferred; original call site unknown
	fn2 = matchFn

	if flag then
		fn3()
		return
	end

	local count = 0

	for i = v25 + 1, #v14 do
		local v37 = v14[i]

		if not v37 then
			continue
		end

		local tool = v37.Tool
		local visible = tool == nil or matchFn(tool)

		if v24 ~= "All" then
			if tool == nil then
				visible = false
			else
				visible = matchFn(tool)
			end
		end

		v37.Frame.Visible = visible

		if visible then
			v37.Frame.LayoutOrder = v25 + count
			count += 1
		else
			v37.Frame.LayoutOrder = 99999
		end
	end

	UpdateScrollingFrameCanvasSize() -- equivalent call inferred; original call site unknown
end

fn4 = ApplyCategoryFilter

local function SetCategoryFilter(name: string)
	if v24 == name then
		return
	end

	v24 = name

	for k, v35 in buttonsByName do
		if k == name then
			v35.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
		else
			v35.BackgroundColor3 = v35:GetAttribute("OriginalColor") or Color3.fromRGB(50, 52, 55)
		end
	end

	if clone then
		clone.Text = v34[name] or name
	end

	ApplyCategoryFilter()
end

local function BuildCategorySidebar()
	local categoryFilter = script2:FindFirstChild("CategoryFilter")

	if not categoryFilter then
		warn("Satchel: missing CategoryFilter template under script.")
		return
	end

	local clone2 = categoryFilter:Clone()
	clone2.Parent = frame3
	local currentCategoryLabel = script2:FindFirstChild("CurrentCategoryLabel")

	if currentCategoryLabel then
		clone = currentCategoryLabel:Clone()
		clone.Parent = frame3
		clone.Text = v34[v24] or v24
	end

	for _, v35 in v33 do
		local button = clone2:FindFirstChild(v35.Name, true)

		if button and (button:IsA("TextButton") or button:IsA("ImageButton")) then
			buttonsByName[v35.Name] = button

			if button:IsA("GuiButton") then
				button.AutoButtonColor = false
			end

			button:SetAttribute("OriginalColor", button.BackgroundColor3)

			if v35.Name == v24 then
				button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
			end

			local v36 = v35
			button.MouseButton1Click:Connect(function()
				PlayClickSound()
				SetCategoryFilter(v36.Name)
			end)
		else
			warn(string.format("Satchel: CategoryFilter template missing button named '%s'", v35.Name))
		end
	end
end

BuildCategorySidebar()
Satchel.BackpackItemAdded.Event:Connect(function()
	v.RefreshViewSoon()
end)
Satchel.BackpackItemRemoved.Event:Connect(function()
	v.RefreshViewSoon()
end)

local function InitializeBackpackButton()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function ToggleBackpack()
		if GuiService.MenuIsOpen or next(v18) then
			return
		end

		PlayClickSound()

		if Satchel.IsOpen then
			v10:deselect()
		else
			v10:select()
		end
	end

	local watch = GamepadUI.Watch

	local function fn9()
		if frame3.Visible then
			v10:deselect()
		end
	end

	watch(frame3, fn9, nil, 0, {
		[Enum.KeyCode.ButtonX] = true,
		[Enum.KeyCode.ButtonL1] = true,
		[Enum.KeyCode.ButtonR1] = true
	})
	local v37 = false
	ContextActionService:BindActionAtPriority("BackpackQuickToggle", function(_, p)
		if p == Enum.UserInputState.Begin then
			if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
				return Enum.ContextActionResult.Pass
			end

			local top = GamepadUI.Top()

			if top and top.Owner ~= frame3 then
				return Enum.ContextActionResult.Sink
			end

			if not v22 then
				return Enum.ContextActionResult.Pass
			end

			v37 = true

			if GuiService.MenuIsOpen or next(v18) then
				return Enum.ContextActionResult.Sink
			end

			PlayClickSound()

			if Satchel.IsOpen then
				v10:deselect()
			else
				v10:select()
			end

			return Enum.ContextActionResult.Sink
		else
			local v38 = v37

			if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
				v37 = false
			end

			return v38 and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
		end
	end, false, Enum.ContextActionPriority.High.Value + 10, Enum.KeyCode.DPadLeft)
	local B = script2:FindFirstChild("B")

	if B and B:IsA("GuiButton") then
		local clone2 = B:Clone()
		clone2.Name = "BackpackButton"
		clone2.Visible = true
		local icon3 = clone2:FindFirstChild("Icon")

		if icon3 and icon3:IsA("ImageLabel") and icon3.Image == "" then
			icon3.Image = "rbxasset://textures/ui/TopBar/inventoryOn.png"
		end

		for _, childName in { "Amount", "ToolName" } do
			local guiObject = clone2:FindFirstChild(childName)

			if guiObject and guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		clone2.Parent = frame2
		clone2.Activated:Connect(ToggleBackpack)
		local number = clone2:FindFirstChild("Number")

		if number and number:IsA("GuiObject") then
			local imageLabel4 = Instance.new("ImageLabel")
			imageLabel4.Name = "GamepadBackpackHint"
			imageLabel4.BackgroundTransparency = 1
			local size = number.Size
			local position3 = number.Position
			local anchorPoint = number.AnchorPoint
			imageLabel4.Size = size
			imageLabel4.Position = position3
			imageLabel4.AnchorPoint = anchorPoint
			local zIndex = number.ZIndex
			local fit = Enum.ScaleType.Fit
			imageLabel4.ZIndex = zIndex
			imageLabel4.ScaleType = fit
			imageLabel4.Parent = clone2

			-- equivalent calls inferred from this helper; original call sites unknown
			local function RefreshShortcutHint()
				local usingGamepad = GamepadUI.UsingGamepad()
				imageLabel4.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.DPadLeft)
				imageLabel4.Visible = usingGamepad
				number.Visible = not usingGamepad
			end

			local preferredInputChangedConnection = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(RefreshShortcutHint)
			local gamepadConnectedConnection = UserInputService.GamepadConnected:Connect(RefreshShortcutHint)
			clone2.Destroying:Connect(function()
				preferredInputChangedConnection:Disconnect()
				gamepadConnectedConnection:Disconnect()
			end)
			RefreshShortcutHint() -- equivalent call inferred; original call site unknown
		end

		local v38 = v11 + 5

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SoloHomeX()
			return frame2.Size.X.Offset / 2 - v11 / 2 + v38 * 0
		end

		local Y = clone2.Position.Y

		local function DoReposition()
			if next(v18) then
				return
			end

			local frame7 = nil

			for i = 1, v25 do
				local v39 = v14[i]

				if not (v39 and v39.Frame and v39.Frame.Visible) then
					continue
				end

				frame7 = v39.Frame
				break
			end

			if not frame7 then
				clone2.Position = UDim2.new(0, SoloHomeX(), Y.Scale, Y.Offset)
				return
			end

			local offset = frame7.Position.X.Offset
			clone2.Position = UDim2.new(0, offset - v11 - 5, Y.Scale, Y.Offset)
		end

		local flag4 = false

		local function ScheduleReposition()
			if flag4 then
				return
			end

			flag4 = true
			task.defer(function()
				flag4 = false
				DoReposition()
			end)
		end

		v28 = ScheduleReposition

		for i = 1, v25 do
			local v39 = v14[i]

			if not (v39 and v39.Frame) then
				continue
			end

			v39.Frame:GetPropertyChangedSignal("Visible"):Connect(ScheduleReposition)
			v39.Frame:GetPropertyChangedSignal("Position"):Connect(ScheduleReposition)
		end

		frame2:GetPropertyChangedSignal("AbsoluteSize"):Connect(ScheduleReposition)
		frame2:GetPropertyChangedSignal("AbsolutePosition"):Connect(ScheduleReposition)
		frame3:GetPropertyChangedSignal("Visible"):Connect(function()
			AdjustHotbarFrames()
		end)
		DoReposition()
	else
		warn("Satchel: missing 'B' backpack-button template under script.")
	end

	v17[Enum.KeyCode.B.Value] = function()
		if localPlayer:GetAttribute("InBuildMode") then
			return
		end

		ToggleBackpack() -- equivalent call inferred; original call site unknown
	end
end

InitializeBackpackButton()
return Satchel