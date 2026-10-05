game:GetService("ControllerService")
local Players = game:GetService("Players")
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

while not HUD.IsInitialized do
	task.wait()
end

assert(HUD.IsInitialized, "bad HUD")
local titles = playerGui:WaitForChild("Popups"):WaitForChild("TitlesUI"):WaitForChild("Titles")
local class = {}

function class:loadData(p)
	local v = {
		Gui = titles
	}

	if not p then
		for _, frame in pairs(v.Gui.Left.Container.Titles.ScrollingFrame:GetChildren()) do
			if frame:IsA("Frame") and frame.Name ~= "Template" then
				frame:Destroy()
			end
		end
	end

	local v2, v3, v4 = remotes.CommF_:InvokeServer("getTitles")
	local v5 = {}
	local count = 0
	local count2 = 0

	for _, v6 in next, v2, nil do
		table.insert(v5, v6.Index)
	end

	table.sort(v5)

	if not p then
		for _, v6 in next, v2, nil do
			count += 1
			local clone = v.Gui.Left.Container.Titles.ScrollingFrame.Template:Clone()
			clone.Desc.Text = " " .. v6.Description
			local v7 = 0

			for k, v9 in pairs(v5) do
				if v9 ~= v6.Index then
					continue
				end

				v5[k] = -1
				v7 = k
				break
			end

			local formatted = ("%03d"):format(v7)

			if v6.Unlocked then
				count2 += 1
				clone.Activate.Visible = true
			else
				clone.Activate.Visible = false
			end

			clone.Title.Text = " #" .. formatted .. " " .. v6.Name
			local v9 = v6
			clone.Activate.Activated:Connect(function()
				remotes.CommF_:InvokeServer("activateTitle", v9.EventName or clone.Name)
				class:loadData(true)
			end)
			clone.Name = v6.Name
			clone.LayoutOrder = v6.Index
			clone.Parent = v.Gui.Left.Container.Titles.ScrollingFrame
			clone.Visible = true
		end

		v.Gui.Info.TextLabel.Text = " Choose a title to show next to your chat tag. (" .. count2 .. "/" .. count .. ")"
	end

	if not v.Gui.Left.Container.Titles.ScrollingFrame:GetAttribute("AutoSizeHooked") then
		v.Gui.Left.Container.Titles.ScrollingFrame:SetAttribute("AutoSizeHooked", true)
		v.Gui.Left.Container.Titles.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			v.Gui.Left.Container.Titles.ScrollingFrame.CanvasSize = UDim2.fromOffset(
				0,
				v.Gui.Left.Container.Titles.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
			)
		end)
	end

	for _, frame in pairs(v.Gui.Right.ScrollingFrame:GetChildren()) do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end

	for k, v6 in pairs(v4) do
		local clone = v.Gui.Right.ScrollingFrame.Template:Clone()
		local layoutOrder

		if tonumber(k) then
			layoutOrder = k
		else
			layoutOrder = -2
		end

		clone.LayoutOrder = layoutOrder
		clone.Activate.Visible = v6.Unlocked and true or false
		clone.Activate.TextLabel.Text = v3 == k and "[Equipped]" or v6.OnSale and "Buy" or "Equip"
		clone.Title.TextColor3 = v6.Color
		clone.Title.Text = v6.ColorName
		clone.Desc.Text = v6.Desc
		clone.Name = k
		clone.Parent = v.Gui.Right.ScrollingFrame
		clone.Visible = true
		clone.Activate.Activated:Connect(function()
			remotes.CommF_:InvokeServer("activateTitleColor", clone.Name)
			class:loadData(true)
		end)
	end

	if not v.Gui.Right.ScrollingFrame:GetAttribute("AutoSizeHooked") then
		v.Gui.Right.ScrollingFrame:SetAttribute("AutoSizeHooked", true)
		v.Gui.Right.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			v.Gui.Right.ScrollingFrame.CanvasSize = UDim2.fromOffset(
				0,
				v.Gui.Right.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
			)
		end)
	end
end

local flag = false
HUD:RegisterPage("Titles", function()
	if flag then
		return
	end

	flag = true
	titles.Visible = true
	class:loadData()
end, function()
	if not flag then
		return
	end

	flag = false
	titles.Visible = false
end, function()
	return flag
end)
titles:GetPropertyChangedSignal("Visible"):Connect(function()
	local pageControllerAsync = HUD:GetPageControllerAsync("Titles")

	if titles.Visible then
		pageControllerAsync.open()
	else
		pageControllerAsync.close()
	end
end)
titles:WaitForChild("Info"):WaitForChild("Exit").Activated:Connect(function()
	HUD:GetPageControllerAsync("Titles").close()
end)
titles:WaitForChild("Info"):WaitForChild("Disable").Activated:Connect(function()
	remotes.CommF_:InvokeServer("activateTitle", "")
end)