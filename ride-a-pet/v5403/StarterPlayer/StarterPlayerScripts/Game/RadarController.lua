local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local useRadar = playerGui:WaitForChild("Main"):WaitForChild("ActionsHolder"):WaitForChild("UseRadar")
local uIStroke = useRadar:FindFirstChildOfClass("UIStroke")
local radars = ReplicatedStorage2:WaitForChild("Assets"):WaitForChild("Radars")
local billboards = ReplicatedStorage2:WaitForChild("Assets"):WaitForChild("Billboards")
local radarTimer = billboards:WaitForChild("RadarTimer")
local radarOverhead = billboards:WaitForChild("RadarOverhead")
local game2 = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game")
local activateRadar = game2:WaitForChild("ActivateRadar")
local radarState = game2:WaitForChild("RadarState")
local click = game.SoundService:WaitForChild("SFX"):WaitForChild("Click")
local color = Color3.fromRGB(85, 235, 105)
local color2 = Color3.fromRGB(255, 85, 85)
local color3 = Color3.fromRGB(110, 20, 20)
local color4 = Color3.fromRGB(20, 90, 35)
local clone = nil
local v = nil
local v2 = nil
local now = 0

local function NearestEgg(position)
	local renderedEggs = workspace:FindFirstChild("RenderedEggs")

	if not renderedEggs then
		return nil
	end

	local v3 = nil
	local v4 = nil

	for _, model in renderedEggs:GetChildren() do
		if not (model:IsA("Model") and model:FindFirstChildWhichIsA("BasePart")) then
			continue
		end

		local position2 = model:GetPivot().Position
		local magnitude = (position2 - position).Magnitude

		if not (not v3 or magnitude < v3) then
			continue
		end

		v4 = position2
		v3 = magnitude
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRadarColor(childName)
	local child = radars:FindFirstChild(childName)
	local handle = child and child:FindFirstChild("Handle")

	if handle then
		return handle.Color
	end

	return Color3.fromRGB(255, 255, 255)
end

local function Darken(data, p)
	return Color3.new(data.R * p, data.G * p, data.B * p)
end

local v3 = {}

local function GetEquippedRadar()
	local character = localPlayer.Character

	if not character then
		return nil
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") and CollectionService:HasTag(tool, "Radar") then
			return tool
		end
	end

	return nil
end

local function UpdateButton()
	local equippedRadar = GetEquippedRadar()
	local v5

	if equippedRadar == nil then
		v5 = false
	else
		v5 = v3[equippedRadar.Name] ~= nil
	end

	useRadar.Visible = equippedRadar ~= nil and equippedRadar.Name ~= "Infinite Radar" and not v5

	if equippedRadar then
		local imageColor = GetRadarColor(equippedRadar.Name) -- equivalent call inferred; original call site unknown
		useRadar.ImageColor3 = imageColor

		if uIStroke then
			uIStroke.Color = Color3.new(imageColor.R * 0.45, imageColor.G * 0.45, imageColor.B * 0.45)
		end
	end
end

local function WatchCharacter(character)
	character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			task.defer(UpdateButton)
		end
	end)
	character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			task.defer(UpdateButton)
		end
	end)
	UpdateButton()
end

localPlayer.CharacterAdded:Connect(WatchCharacter)

if localPlayer.Character then
	WatchCharacter(localPlayer.Character)
end

localPlayer:GetAttributeChangedSignal("IsRiding"):Connect(UpdateButton)

-- equivalent calls inferred from this helper; original call sites unknown
local function TryActivate()
	click:Play()
	activateRadar:FireServer()
	useRadar:SetAttribute("PressedAt", os.clock())
end

useRadar.Activated:Connect(TryActivate)
ContextActionService:BindAction("UseRadarAction", function(_, p)
	if GamepadUI.GameplayBlocked() then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin and useRadar.Visible then
		TryActivate() -- equivalent call inferred; original call site unknown
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.ButtonY)

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRadarHandle(childName)
	local character = localPlayer.Character
	local tool = character and character:FindFirstChild(childName)

	if tool and tool:IsA("Tool") and CollectionService:HasTag(tool, "Radar") then
		return tool:FindFirstChild("Handle")
	end

	return nil
end

local object = setmetatable({}, {
	__mode = "k"
})
local color5 = Color3.fromRGB(255, 220, 60)

-- equivalent calls inferred from this helper; original call sites unknown
local function Paint(instance, color6, color7)
	instance.TextColor3 = color6
	local uIStroke2 = instance:FindFirstChildOfClass("UIStroke")

	if uIStroke2 then
		uIStroke2.Color = color7
	end
end

local function PaintTrend(distance, magnitude)
	if magnitude then
		local v4 = object[distance]

		if v4 then
			if os.clock() - v4.Time < 0.25 then
				return
			end

			local v5 = magnitude - v4.Distance
			local now2 = os.clock()
			v4.Distance = magnitude
			v4.Time = now2

			if v5 < -0.75 then
				Paint(distance, color, color4) -- equivalent call inferred; original call site unknown
			elseif v5 > 0.75 then
				Paint(distance, color2, color3) -- equivalent call inferred; original call site unknown
			else
				Paint(distance, color5, color4) -- equivalent call inferred; original call site unknown
			end
		else
			object[distance] = {
				Distance = magnitude,
				Time = os.clock()
			}
			Paint(distance, color5, color4) -- equivalent call inferred; original call site unknown
		end
	else
		Paint(distance, color5, color4) -- equivalent call inferred; original call site unknown
		object[distance] = nil
	end
end

local function TintBillboard(folder, color6)
	for _, uIStroke2 in folder:GetDescendants() do
		if uIStroke2:IsA("UIStroke") then
			uIStroke2.Color = color6
		end
	end
end

local arrow = ReplicatedStorage2:WaitForChild("Assets"):WaitForChild("Arrow")
local radarArrows = workspace:FindFirstChild("RadarArrows") or Instance.new("Folder")
radarArrows.Name = "RadarArrows"
radarArrows.Parent = workspace
local v4 = nil

local function MountOf(instance)
	local petMountJoint = instance:FindFirstChild("PetMountJoint")
	local part1 = petMountJoint and petMountJoint:IsA("Motor6D") and petMountJoint.Part1

	if not part1 then
		return nil
	end

	local model = part1:FindFirstAncestorWhichIsA("Model")
	local parent = model

	while parent and parent:GetAttribute("PetName") == nil do
		parent = parent.Parent

		if not (parent and parent:IsA("Model") and parent) then
			parent = nil
		end
	end

	return parent or model
end

local function MeasureMount(instance, position, p)
	local boundingBox, v5 = instance:GetBoundingBox()
	local v6 = v5 / 2
	local vector2 = boundingBox.Position - position
	return
		vector2.Y + math.abs((boundingBox.RightVector:Dot(createVector(0, 1, 0)))) * v6.X + math.abs((boundingBox.UpVector:Dot(createVector(
			0,
			1,
			0
		)))) * v6.Y + math.abs((boundingBox.LookVector:Dot(createVector(0, 1, 0)))) * v6.Z,
		vector2:Dot(p) + math.abs((boundingBox.RightVector:Dot(p))) * v6.X + math.abs((boundingBox.UpVector:Dot(p))) * v6.Y + math.abs((boundingBox.LookVector:Dot(p))) * v6.Z
end

local function MountClearance(humanoidRootPart, unit)
	local model = MountOf(humanoidRootPart)

	if not model or unit.Magnitude < 0.01 then
		v4 = nil
		return 0, 0
	end

	local now2 = os.clock()

	if not v4 or v4.Model ~= model or now2 - v4.At >= 0.5 then
		local top, front = MeasureMount(model, humanoidRootPart.Position, unit)
		v4 = {
			Model = model,
			Top = top,
			Front = front,
			At = now2
		}
	end

	return math.max(4, v4.Front + 1.5), (math.max(0, v4.Top + 2.5 - 5))
end

local function MakeArrow(data)
	local clone2 = arrow:Clone()

	for _, descendant in clone2:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Color = data
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("Highlight") then
			descendant.FillColor = data
			descendant.OutlineColor = Color3.new(data.R * 0.45, data.G * 0.45, data.B * 0.45)
		end
	end

	clone2.Parent = radarArrows
	return clone2
end

local function PaintArrow(folder, textColor3)
	if not (folder and folder:GetAttribute("PaintedColor") ~= textColor3) then
		return
	end

	folder:SetAttribute("PaintedColor", textColor3)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Color = textColor3
		elseif descendant:IsA("Highlight") then
			descendant.FillColor = textColor3
			descendant.OutlineColor = Color3.new(textColor3.R * 0.45, textColor3.G * 0.45, textColor3.B * 0.45)
		end
	end
end

local function AimArrow(instance, p, p2, p3, now2)
	if not instance then
		return
	end

	if not (p and p2) then
		instance:PivotTo(CFrame.new(0, -1000, 0))
		return
	end

	local v5 = math.sin(now2 * 3 + p3) * 0.25
	local v6 = p + Vector3.new(0, 5 + (p3 - 1) * 1.2 + v5, 0)
	local vector2 = Vector3.new(p2.X, v6.Y, p2.Z)

	if (vector2 - v6).Magnitude < 0.5 then
		instance:PivotTo(CFrame.new(v6))
		return
	end

	local v7 = math.clamp(math.atan2((p2 - v6).Y, (vector2 - v6).Magnitude), -0.4363323129985824, 0.4363323129985824)
	instance:PivotTo(CFrame.lookAt(v6, vector2) * CFrame.Angles(v7, 0, 0))
end

local function MakePair(name)
	local v5 = GetRadarColor(name) -- equivalent call inferred; original call site unknown
	local clone2 = radarTimer:Clone()
	local clone3 = radarOverhead:Clone()
	TintBillboard(clone2, Darken(v5, 0.45))
	TintBillboard(clone3, Darken(v5, 0.2))
	clone2.Parent = playerGui
	clone3.Parent = playerGui
	return {
		Timer = clone2,
		Overhead = clone3,
		Arrow = MakeArrow(v5)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemovePair(data)
	if data.Timer then
		data.Timer:Destroy()
	end

	if data.Overhead then
		data.Overhead:Destroy()
	end

	if data.Arrow then
		data.Arrow:Destroy()
	end
end

radarState.OnClientEvent:Connect(function(items)
	local v5 = {}

	for _, item in items do
		v5[item.Name] = true
		local v6 = v3[item.Name]

		if not v6 then
			v6 = MakePair(item.Name)
			v3[item.Name] = v6
		end

		v6.Expiry = item.Expiry
		v6.Target = item.Target
	end

	for k, v6 in v3 do
		if v5[k] then
			continue
		end

		RemovePair(v6) -- equivalent call inferred; original call site unknown
		v3[k] = nil
	end

	UpdateButton()
end)
task.spawn(function()
	for _ = 1, 4 do
		radarState:FireServer()

		for _ = 1, 10 do
			task.wait(0.1)

			if next(v3) ~= nil then
				return
			end
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatTime(p)
	local v5 = math.max(0, (math.floor(p)))
	return string.format("%d:%02d", v5 // 60, v5 % 60)
end

RunService.RenderStepped:Connect(function()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local position = humanoidRootPart and humanoidRootPart.Position
	local v5 = createVector(0, 0, 0)
	local vector2 = createVector(0, 0, 0)

	if humanoidRootPart then
		local lookVector = humanoidRootPart.CFrame.LookVector
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector3.Magnitude > 0.01 then
			local unit = vector3.Unit
			local v6, v7 = MountClearance(humanoidRootPart, unit)
			v5 = unit * v6
			vector2 = Vector3.new(0, v7, 0)
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local adornee = GetRadarHandle("Infinite Radar") -- equivalent call inferred; original call site unknown

	if adornee and position then
		if not clone then
			clone = radarOverhead:Clone()
			local v8 = clone
			local radarColor = GetRadarColor("Infinite Radar") -- equivalent call inferred; original call site unknown
			TintBillboard(v8, Darken(radarColor, 0.2))
			clone.Parent = playerGui
		end

		clone.Adornee = adornee
		clone.Enabled = true

		if os.clock() - now >= 0.25 then
			now = os.clock()
			v2 = NearestEgg(position)
		end

		local magnitude

		if v2 then
			magnitude = (position - v2).Magnitude or nil
		end

		clone.Distance.Text = not magnitude and "?" or math.round(magnitude) .. "m" or "?"
		PaintTrend(clone.Distance, magnitude)

		if not v then
			v = MakeArrow(GetRadarColor("Infinite Radar"))
		end

		AimArrow(v, adornee.Position + v5 + vector2, v2, 0, os.clock())
		PaintArrow(v, clone.Distance.TextColor3)
	elseif clone then
		clone.Enabled = false
		local v7 = v

		if v7 then
			v7:PivotTo(CFrame.new(0, -1000, 0))
		end
	end

	if next(v3) == nil then
		return
	end

	local count = 0

	for k, v7 in v3 do
		local adornee2 = GetRadarHandle(k) -- equivalent call inferred; original call site unknown

		if adornee2 then
			v7.Timer.Adornee = adornee2
			v7.Overhead.Adornee = adornee2
			v7.Timer.Enabled = true
			v7.Overhead.Enabled = true
		else
			v7.Timer.Enabled = false
			v7.Overhead.Enabled = false
		end

		local timeLeft = v7.Timer.TimeLeft
		timeLeft.Text = FormatTime(v7.Expiry - serverTimeNow)

		if v7.Target and position then
			local magnitude = (position - v7.Target).Magnitude
			v7.Overhead.Distance.Text = math.round(magnitude) .. "m"
			PaintTrend(v7.Overhead.Distance, magnitude)
		else
			v7.Overhead.Distance.Text = "?"
			local distance = v7.Overhead.Distance
			Paint(distance, color5, color4) -- equivalent call inferred; original call site unknown
			object[distance] = nil
		end

		if adornee2 and v7.Target and position then
			count += 1
			AimArrow(v7.Arrow, adornee2.Position + v5 + vector2, v7.Target, count, os.clock())
			PaintArrow(v7.Arrow, v7.Overhead.Distance.TextColor3)
		else
			local arrow2 = v7.Arrow

			if arrow2 then
				arrow2:PivotTo(CFrame.new(0, -1000, 0))
			end
		end
	end
end)