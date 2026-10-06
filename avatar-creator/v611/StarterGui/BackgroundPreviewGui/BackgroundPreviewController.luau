local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local CatalogUI = require(game.ReplicatedStorage:WaitForChild("CatalogUI"))
local catalogRemote = game.ReplicatedStorage:WaitForChild("CatalogRemote")

-- equivalent calls inferred from this helper; original call sites unknown
local function make(p, p2, p3, p4)
	return CatalogUI.make(p, p2, p3, p4)
end

local v2 = make("Frame", "Stage", parent, {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(222, 228, 239),
	Visible = false,
	Active = true
}) -- equivalent call inferred; original call site unknown
local v4 = make("ImageLabel", "Backdrop", v2, {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Crop,
	ImageColor3 = Color3.new(1, 1, 1)
}) -- equivalent call inferred; original call site unknown
local v6 = make("ViewportFrame", "Avatar", v2, {
	Size = UDim2.fromScale(0.8, 0.86),
	Position = UDim2.fromScale(0.1, 0.07),
	BackgroundTransparency = 1,
	Ambient = Color3.fromRGB(210, 210, 210),
	LightColor = Color3.new(1, 1, 1),
	LightDirection = vector.create(-1, -1, -2)
}) -- equivalent call inferred; original call site unknown
local parent2 = CatalogUI.make("WorldModel", "World", v6, {})
local currentCamera = CatalogUI.make("Camera", "Camera", v6, {
	FieldOfView = 35
})
v6.CurrentCamera = currentCamera
local v10 = make("Frame", "Controls", v2, {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -18, 0.5, 0),
	Size = UDim2.fromOffset(150, 370),
	BackgroundTransparency = 1
}) -- equivalent call inferred; original call site unknown

local function button(p, p2, p3)
	local button2 = CatalogUI.button(p, v10, p2, UDim2.fromOffset(0, p3), UDim2.fromOffset(150, 46))
	local v11 = {
		Color = Color3.fromRGB(128, 146, 170),
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}
	CatalogUI.make("UIStroke", "Border", button2, v11)
	return button2
end

local v11 = button("Exit", "Exit preview", 0)
v11.BackgroundColor3 = Color3.fromRGB(167, 48, 61)
local v12 = button("Change", "Change background", 54)
local v13 = button("Rotate", "Rotate avatar", 108)
local v14 = button("Front", "Front view", 162)
local v15 = button("Hide", "Hide controls", 216)
local v16 = button("Details", "View item details", 270)
local v17 = button("Buy", "Buy background", 324)
v17.BackgroundColor3 = Color3.fromRGB(73, 97, 131)
local v18 = nil
local v19 = false
local v20 = false
local button2 = CatalogUI.button(
	"ShowControls",
	v2,
	"Show controls",
	UDim2.new(1, -168, 1, -66),
	UDim2.fromOffset(150, 44)
)
MenuFade.Set(button2, "Visible", false)
local label = CatalogUI.label("Status", v2, "", UDim2.new(0.5, -200, 1, -48), UDim2.fromOffset(400, 28), 14)
label.TextXAlignment = Enum.TextXAlignment.Center
local v22 = make("Frame", "Picker", v2, {
	Position = UDim2.fromScale(0.08, 0.12),
	Size = UDim2.fromScale(0.72, 0.76),
	BackgroundColor3 = Color3.fromRGB(23, 26, 31),
	Visible = false,
	Active = true
}) -- equivalent call inferred; original call site unknown
CatalogUI.round(v22, 16)
CatalogUI.label("Title", v22, "Choose a background", UDim2.fromOffset(20, 14), UDim2.new(1, -90, 0, 36), 22)
local button3 = CatalogUI.button("Close", v22, "×", UDim2.new(1, -56, 0, 12), UDim2.fromOffset(40, 36))
local v24 = make("ScrollingFrame", "Items", v22, {
	Position = UDim2.fromOffset(16, 62),
	Size = UDim2.new(1, -32, 1, -78),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 5,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new()
}) -- equivalent call inferred; original call site unknown
local v25 = {
	CellSize = UDim2.fromOffset(150, 176),
	CellPadding = UDim2.fromOffset(10, 10),
	SortOrder = Enum.SortOrder.LayoutOrder
}
CatalogUI.make("UIGridLayout", "Grid", v24, v25)
local v27 = make("Frame", "ItemDetails", v2, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.45, 0.5),
	Size = UDim2.fromScale(0.65, 0.7),
	BackgroundColor3 = Color3.fromRGB(23, 26, 31),
	Visible = false,
	Active = true
}) -- equivalent call inferred; original call site unknown
CatalogUI.round(v27, 16)
CatalogUI.label("Title", v27, "Background details", UDim2.fromOffset(20, 14), UDim2.new(1, -90, 0, 36), 22)
local button4 = CatalogUI.button("Close", v27, "×", UDim2.new(1, -56, 0, 12), UDim2.fromOffset(40, 36))
local v29 = make("ScrollingFrame", "Content", v27, {
	Position = UDim2.fromOffset(20, 64),
	Size = UDim2.new(1, -40, 1, -140),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(),
	ScrollBarThickness = 5
}) -- equivalent call inferred; original call site unknown
local label2 = CatalogUI.label("Description", v29, "", UDim2.new(), UDim2.new(1, -12, 0, 0), 17)
label2.AutomaticSize = Enum.AutomaticSize.Y
label2.TextYAlignment = Enum.TextYAlignment.Top
local button5 = CatalogUI.button("Buy", v27, "Buy background", UDim2.new(0, 20, 1, -60), UDim2.new(1, -40, 0, 42))

local function purchase()
	if not v18 or v20 then
		return
	end

	v20 = true
	local id = v18
	label.Text = "Opening Roblox purchase…"
	task.spawn(function()
		local success, result = pcall(function()
			return catalogRemote:InvokeServer("Buy", {
				id = id,
				kind = "Asset"
			})
		end)
		v20 = false
		label.Text = not (success and result) and "Could not open purchase. Try again." or result.error or result.message or "Could not open purchase. Try again."
	end)
end

v17.Activated:Connect(purchase)
button5.Activated:Connect(purchase)
button4.Activated:Connect(function()
	MenuFade.Set(v27, "Visible", false)
end)
v16.Activated:Connect(function()
	if not v18 or v19 then
		return
	end

	local id = v18
	v19 = true
	MenuFade.Set(v22, "Visible", false)
	MenuFade.Set(v27, "Visible", true)
	label2.Text = "Loading item details…"
	task.spawn(function()
		local success, result = pcall(function()
			return catalogRemote:InvokeServer("Details", {
				id = id,
				kind = "Asset"
			})
		end)
		v19 = false

		if v18 ~= id then
			return
		end

		if not (success and result and result.item) then
			label2.Text = success and result and result.error or "Could not load item details. Try again."
			return
		end

		local item = result.item
		local v31 = type(item.Price) ~= "number" and "Price available in Roblox purchase prompt" or "R$ " .. tostring(item.Price) or "Price available in Roblox purchase prompt"
		label2.Text = (item.Name or "Background") .. [[


By ]] .. (item.CreatorName or "Roblox") .. (item.CreatorHasVerifiedBadge and utf8.char(57344) or "") .. [[


]] .. v31 .. [[


]] .. (item.Description or "")
	end)
end)
local clone = nil
local total = 0
local v30 = {}
local v31 = false
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function selectBackground(id)
	MenuFade.Set(v27, "Visible", false)
	count += 1
	local v32 = count
	label.Text = "Loading background…"
	task.spawn(function()
		local success, result = pcall(function()
			return catalogRemote:InvokeServer("BackgroundImage", {
				id = id,
				kind = "Asset"
			})
		end)

		if v32 ~= count then
			return
		end

		if not (success and result and result.imageId) then
			label.Text = success and result and result.error or "Could not load this background. Try again."
			return
		end

		v18 = id
		v4.Image = "rbxassetid://" .. result.imageId
		label.Text = ""
		MenuFade.Set(v22, "Visible", false)
	end)
end

local function rebuild()
	parent2:ClearAllChildren()
	local character = localPlayer.Character

	if not character then
		return
	end

	local archivable = character.Archivable
	character.Archivable = true
	clone = character:Clone()
	character.Archivable = archivable

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("Sound") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end

	clone.Parent = parent2
	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	clone:PivotTo(CFrame.new())
	local boundingBox, v32 = clone:GetBoundingBox()
	local position = boundingBox.Position
	local v33 = math.max(v6.AbsoluteSize.X / math.max(v6.AbsoluteSize.Y, 1), 0.5)
	local v34 = math.max(v32.Y, v32.X / v33) * 0.65 / 0.3152987888789835 + v32.Z * 0.5
	currentCamera.CFrame = CFrame.lookAt(position + Vector3.new(0, 0, -v34), position)
	total = 0
end

local function exit()
	MenuFade.Set(v2, "Visible", false)
	v31 = false
	MenuFade.Set(v22, "Visible", false)
	MenuFade.Set(v27, "Visible", false)
	count += 1

	for k, enabled in pairs(v30) do
		if k.Parent then
			k.Enabled = enabled
		end
	end

	v30 = {}
	parent2:ClearAllChildren()
	clone = nil
end

v11.Activated:Connect(exit)
button3.Activated:Connect(function()
	MenuFade.Set(v22, "Visible", false)
end)
local v32 = false
local v33 = false
v12.Activated:Connect(function()
	MenuFade.Set(v27, "Visible", false)
	MenuFade.Set(v22, "Visible", not MenuFade.IsOpen(v22, "Visible"))

	if v32 or v33 or not v22.Visible then
		return
	end

	v33 = true
	label.Text = "Loading backgrounds…"
	task.spawn(function()
		local success, result = pcall(function()
			return catalogRemote:InvokeServer("Search", {
				category = "Backgrounds"
			})
		end)
		v33 = false

		if not success or not result or result.error then
			label.Text = result and result.error or "Could not load backgrounds. Try again."
			return
		end

		v32 = true
		label.Text = ""

		for i, v34 in ipairs(result.items or {}) do
			local button6 = CatalogUI.button("Background" .. v34.Id, v24, "", UDim2.new(), UDim2.fromOffset(150, 176))
			button6.LayoutOrder = i
			local v35 = {
				Position = UDim2.fromOffset(5, 5),
				Size = UDim2.new(1, -10, 0, 126),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Fit,
				Image = "rbxthumb://type=Asset&id=" .. v34.Id .. "&w=420&h=420"
			}
			CatalogUI.make("ImageLabel", "Thumbnail", button6, v35)
			CatalogUI.label("Name", button6, v34.Name, UDim2.fromOffset(8, 134), UDim2.new(1, -16, 0, 36), 12)
			local v36 = v34
			button6.Activated:Connect(function()
				selectBackground(v36.Id) -- equivalent call inferred; original call site unknown
			end)
		end
	end)
end)
v13.Activated:Connect(function()
	v31 = not v31
	v13.Text = v31 and "Stop rotation" or "Rotate avatar"
end)
v14.Activated:Connect(function()
	v31 = false
	total = 0
	v13.Text = "Rotate avatar"

	if clone then
		clone:PivotTo(CFrame.new())
	end
end)
v15.Activated:Connect(function()
	MenuFade.Set(v10, "Visible", false)
	MenuFade.Set(button2, "Visible", true)
	MenuFade.Set(v22, "Visible", false)
	MenuFade.Set(v27, "Visible", false)
end)
button2.Activated:Connect(function()
	MenuFade.Set(v10, "Visible", true)
	MenuFade.Set(button2, "Visible", false)
end)
local v34 = false
local X = 0
v6.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v34 = true
		X = input.Position.X
		v31 = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if v2.Visible and v34 and not v22.Visible and not v27.Visible and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		total += (input.Position.X - X) * 0.008
		X = input.Position.X

		if clone then
			clone:PivotTo(CFrame.Angles(0, total, 0))
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v34 = false
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape and v2.Visible then
		exit()
	end
end)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
	if v2.Visible and v31 and clone then
		total += dt * 0.5
		clone:PivotTo(CFrame.Angles(0, total, 0))
	end
end)