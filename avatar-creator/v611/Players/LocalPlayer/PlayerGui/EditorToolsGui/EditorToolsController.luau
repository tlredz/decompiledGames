local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local localPlayer = game.Players.LocalPlayer
local panel = script.Parent.Panel
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local editorToolsRemote = game.ReplicatedStorage.EditorToolsRemote
local livePreview = localPlayer.PlayerGui:WaitForChild("CatalogGui").Root.LivePreview
local v = nil
local flag = false
local now = 0

local function call(p, options)
	local v2 = 0.4 - (os.clock() - now)

	if v2 > 0 then
		task.wait(v2)
	end

	now = os.clock()
	local success, result = pcall(function()
		return editorToolsRemote:InvokeServer(p, options or {})
	end)
	return success and result or {
		error = "Connection interrupted. Please try again."
	}
end

local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function run(p, p2)
	if flag then
		return
	end

	flag = true
	panel.Status.Text = "Please wait..."
	local v2 = call(p, p2)
	panel.Status.Text = v2.error or v2.message or ""
	flag = false

	if not v2.error then
		fn()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function select(data)
	v = data
	panel.Fit.Selected.Text = data and data.kind .. " · position " .. string.format(
		"%.1f, %.1f, %.1f",
		table.unpack(data.position)
	) .. " · size " .. string.format("%.0f%%", data.scale * 100) or "Select an accessory above"
end

fn = function()
	if flag then
		return
	end

	flag = true
	local v2 = call("State")
	flag = false

	if v2.error then
		panel.Status.Text = v2.error
		return
	end

	panel.Looks.Hint.Text = v2.studio and "12 slots · temporary in Studio; saved in live games" or "12 private slots · saved in this game"

	for _, guiObject in ipairs(panel.Looks.Rows:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for i, v3 in ipairs(v2.slots or {}) do
		local v4 = CatalogUI.make("Frame", "Look_" .. v3.id, panel.Looks.Rows, {
			Size = UDim2.new(1, -6, 0, 52),
			BackgroundColor3 = CatalogUI.colors.surface,
			BorderSizePixel = 0,
			LayoutOrder = i
		})
		CatalogUI.round(v4, 8)
		CatalogUI.label("LookName", v4, v3.name, UDim2.fromOffset(12, 6), UDim2.new(1, -200, 0, 40), 14)
		local button = CatalogUI.button("Load", v4, "Load", UDim2.new(1, -178, 0, 9), UDim2.fromOffset(76, 34))
		local button2 = CatalogUI.button("Delete", v4, "Delete", UDim2.new(1, -94, 0, 9), UDim2.fromOffset(82, 34))
		local v5 = v3
		button.Activated:Connect(function()
			run("Load", {
				id = v5.id
			}) -- equivalent call inferred; original call site unknown
		end)
		local v7 = v3
		button2.Activated:Connect(function()
			if button2.Text ~= "Confirm" then
				button2.Text = "Confirm"
				return
			end

			run("Delete", {
				id = v7.id
			}) -- equivalent call inferred; original call site unknown
		end)
	end

	local id = v and v.id
	select() -- equivalent call inferred; original call site unknown

	for _, guiObject in ipairs(panel.Fit.Items:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, v3 in ipairs(v2.accessories or {}) do
		local button = CatalogUI.button(
			"Fit_" .. string.format("%.0f", v3.id),
			panel.Fit.Items,
			"",
			UDim2.new(),
			UDim2.fromOffset(70, 70)
		)
		CatalogUI.make("ImageLabel", "Thumbnail", button, {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = "rbxthumb://type=Asset&id=" .. string.format("%.0f", v3.id) .. "&w=150&h=150"
		})
		local v4 = v3
		button.Activated:Connect(function()
			select(v4)
		end)

		if v3.id == id then
			select(v3)
		end
	end
end

livePreview.Tools.Activated:Connect(function()
	MenuFade.Set(panel, "Visible", not MenuFade.IsOpen(panel, "Visible"))

	if MenuFade.IsOpen(panel, "Visible") then
		fn()
	end
end)
panel.Close.Activated:Connect(function()
	MenuFade.Set(panel, "Visible", false)
end)
panel.LooksTab.Activated:Connect(function()
	MenuFade.Set(panel.Looks, "Visible", true)
	MenuFade.Set(panel.Fit, "Visible", false)
end)
panel.FitTab.Activated:Connect(function()
	MenuFade.Set(panel.Looks, "Visible", false)
	MenuFade.Set(panel.Fit, "Visible", true)
end)
panel.Looks.Save.Activated:Connect(function()
	run("Save", {
		name = panel.Looks.NameInput.Text
	}) -- equivalent call inferred; original call site unknown
end)

for _, button in ipairs(panel.Fit:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v2 = button
	button.Activated:Connect(function()
		if not v then
			panel.Status.Text = "Select an accessory first."
			return
		end

		run("Adjust", {
			id = v.id,
			op = v2.Name
		}) -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fit()
	local viewportSize = workspace.CurrentCamera.ViewportSize;
	(panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", panel)).Scale = math.min(
		1,
		(viewportSize.X - 40) / 700,
		(viewportSize.Y - 90) / 570
	)
end

local ViewportLayoutWatch = require(game.ReplicatedStorage:WaitForChild("ViewportLayoutWatch"))
ViewportLayoutWatch.Bind(fit)
local applyDescriptionFinishedConnection = nil

local function bind(instance)
	if applyDescriptionFinishedConnection then
		applyDescriptionFinishedConnection:Disconnect()
	end

	applyDescriptionFinishedConnection = instance:WaitForChild("Humanoid").ApplyDescriptionFinished:Connect(function()
		if MenuFade.IsOpen(panel, "Visible") then
			task.delay(0.5, fn)
		end
	end)
end

localPlayer.CharacterAdded:Connect(bind)

if localPlayer.Character then
	task.spawn(bind, localPlayer.Character)
end

fit() -- equivalent call inferred; original call site unknown