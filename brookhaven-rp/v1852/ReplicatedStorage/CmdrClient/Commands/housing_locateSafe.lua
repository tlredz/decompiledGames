local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local color = Color3.fromRGB(0, 255, 0)
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getSafePosition(model)
	local fakeSafe = model:FindFirstChild("FakeSafe")

	if fakeSafe ~= nil and fakeSafe:IsA("BasePart") then
		return fakeSafe.Position
	end

	if model:IsA("Model") then
		return model:GetBoundingBox().Position
	end

	return model.Position
end

local function createArrow(maid, parent, model)
	local v2 = maid:Add(Instance.new("Part"))
	v2.Name = "SafeLocatorAnchor"
	v2.Anchored = true
	v2.CanCollide = false
	v2.CanQuery = false
	v2.CanTouch = false
	v2.Transparency = 1
	v2.Size = createVector(1, 1, 1)
	local safePosition = getSafePosition(model) -- equivalent call inferred; original call site unknown
	v2.Position = safePosition
	v2.Parent = parent
	local attachment = Instance.new("Attachment")
	attachment.Parent = v2
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.fromOffset(80, 100)
	billboardGui.StudsOffsetWorldSpace = createVector(0, 6, 0)
	billboardGui.Adornee = v2
	billboardGui.Parent = v2
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 0.7)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "▼"
	textLabel.TextScaled = true
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = billboardGui
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromScale(0, 0.7)
	textLabel2.Size = UDim2.fromScale(1, 0.3)
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextStrokeTransparency = 0
	textLabel2.Text = ""
	textLabel2.Parent = billboardGui
	local beam = Instance.new("Beam")
	beam.Attachment1 = attachment
	beam.Color = ColorSequence.new(color)
	beam.Transparency = NumberSequence.new(0.3)
	beam.Width0 = 0.3
	beam.Width1 = 0.3
	beam.FaceCamera = true
	beam.LightInfluence = 0
	beam.Parent = v2
	local v3 = nil

	local function bindCharacter(instance)
		if v3 ~= nil then
			v3:Destroy()
			v3 = nil
		end

		beam.Attachment0 = nil

		if instance == nil then
			return
		end

		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)

		if humanoidRootPart == nil or v2.Parent == nil then
			return
		end

		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "SafeLocatorAttachment"
		attachment2.Parent = humanoidRootPart
		v3 = attachment2
		beam.Attachment0 = attachment2
	end

	local localPlayer = Players.LocalPlayer
	maid:Add(localPlayer.CharacterAdded:Connect(bindCharacter))
	maid:Add(function()
		if v3 ~= nil then
			v3:Destroy()
		end
	end)
	task.spawn(bindCharacter, localPlayer.Character)
	maid:Add(RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character
		local humanoidRootPart

		if character ~= nil then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart == nil then
			textLabel2.Text = ""
		else
			textLabel2.Text = `{math.floor((humanoidRootPart.Position - v2.Position).Magnitude)} studs`
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	if v ~= nil then
		v:Destroy()
		v = nil
	end
end

return {
	Name = "housing_locateSafe",
	Aliases = { "locate_safe" },
	Description = "Toggles a green highlight and an arrow pointing to the safe of your currently spawned house (client only).",
	Group = "Housing",
	Args = {},
	ClientRun = function()
		if v == nil then
			local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
			local Janitor = require(ReplicatedStorage.Packages.Janitor)
			local currentHouse = LotController.GetCurrentHouse()

			if currentHouse == nil then
				return "You do not have a spawned house"
			end

			local v2 = {}

			for _, v3 in CollectionService:GetTagged("PropertySafe") do
				if v3:IsDescendantOf(currentHouse.Instance) then
					table.insert(v2, v3)
				end
			end

			if #v2 == 0 then
				return "No safe found in your house (it may not have a safe, or it is not streamed in yet)"
			end

			local maid = Janitor.new()
			v = maid
			local parent = maid:Add(Instance.new("Folder"))
			parent.Name = "SafeLocator"
			parent.Parent = workspace

			for _, v4 in v2 do
				local fakeSafe = v4:FindFirstChild("FakeSafe")
				local highlight = Instance.new("Highlight")

				if fakeSafe == nil then
					fakeSafe = v4
				end

				highlight.Adornee = fakeSafe
				highlight.FillColor = color
				highlight.OutlineColor = color
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = parent
				createArrow(maid, parent, v4)
				maid:Add(v4.Destroying:Connect(function()
					if v == maid and v ~= nil then
						v:Destroy()
						v = nil
					end
				end))
			end

			return (`Safe locator enabled ({#v2} safe{#v2 == 1 and "" or "s"}). Run again to disable.`)
		else
			stop() -- equivalent call inferred; original call site unknown
			return "Safe locator disabled"
		end
	end
}