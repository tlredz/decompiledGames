local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local parent = script.Parent.Parent
local dock = parent.Dock
local _ = parent.Inventory
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
pcall(function()
	game.Workspace.Lobby.RadioGamepass:Destroy()
end)
local GuiService = game:GetService("GuiService")
GuiService.AutoSelectGuiEnabled = false
local GuiService2 = game:GetService("GuiService")
GuiService2.CoreGuiNavigationEnabled = false
_G.PauseBinds = false
local v = 1
local v2 = nil
local icon1 = dock.Tip.Icon1
local _ = icon1.Icon2.Icon3

local function ChangeDockButton(p)
	local v3 = p == "X" and "ButtonX" or "ButtonB"
	icon1.Image = _G.GetButtonIcon(v3)
end

local v3 = {
	{
		"Inventory",
		Enum.KeyCode.ButtonA,
		{
			"Weapons",
			"Perks",
			"Effects",
			"Pets"
		},
		1
	},
	{
		"Shop",
		Enum.KeyCode.ButtonX,
		{
			"Featured",
			"Currency",
			"Weapons",
			"Emotes",
			"Perks",
			"Effects",
			"Pets"
		},
		1
	},
	{ "Spectate", Enum.KeyCode.ButtonY }
}
local names = {}

local function SetSelectionGroup(p)
	for _, v4 in pairs(names) do
		local GuiService3 = game:GetService("GuiService")
		GuiService3:RemoveSelectionGroup(v4)
	end

	if p then
		local GuiService3 = game:GetService("GuiService")
		GuiService3:AddSelectionParent(p.Name, p)
		table.insert(names, p.Name)
	end
end

local v4 = game.ReplicatedStorage.Remotes.Extras.GetPlayerData:InvokeServer()
local v5 = false

local function GetSpectatePlayers()
	local children = {}

	if not v4 then
		return children
	end

	for childName, v6 in pairs(v4) do
		local child = game.Players:FindFirstChild(childName)

		if child == game.Players.LocalPlayer and not v6.Dead then
			return {}
		end

		if v6.Dead or not child or not child.Character or not child.Character:FindFirstChild("Humanoid") then
			continue
		end

		table.insert(children, child)
	end

	return children
end

game.ReplicatedStorage.Remotes.Gameplay.PlayerDataChanged.OnClientEvent:connect(function(p)
	v4 = p

	if not v5 then
		return
	end

	if GetSpectatePlayers() and #GetSpectatePlayers() > 0 then
		if v2 ~= GetSpectatePlayers()[v2] then
			for k, v6 in pairs((GetSpectatePlayers())) do
				if v6 ~= v2 then
					continue
				end

				v = k
				return
			end

			repeat
				v += 1
			until GetSpectatePlayers()[v] or v > #GetSpectatePlayers()

			if v > #GetSpectatePlayers() then
				v = 1
			end

			v2 = GetSpectatePlayers()[v]

			if v2 then
				parent.Spectate.Title.PlayerName.Text = v2.Name
				game.Workspace.CurrentCamera.CameraSubject = v2.Character.Humanoid
			else
				game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
				_G.ResetDock()
			end
		end
	else
		game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
		_G.ResetDock()
	end
end)
local v6 = true

local function Navigate(p, p2)
	if not v6 then
		return
	end

	v6 = false
	local v7 = v3[p]

	if v7[1] == "Spectate" then
		if GetSpectatePlayers() and #GetSpectatePlayers() > 0 then
			v += p2

			if v < 1 then
				v = #GetSpectatePlayers()
			elseif v > #GetSpectatePlayers() then
				v = 1
			end

			v2 = GetSpectatePlayers()[v]
			game.Workspace.CurrentCamera.CameraSubject = v2.Character.Humanoid
			parent.Spectate.Title.PlayerName.Text = v2.Name
		else
			_G.ResetDock()
			game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
		end
	else
		local _ = v7[3]
		local v8 = parent[v7[1]].Main[v7[3][v7[4]]]
		v3[p][4] = v7[4] + p2
		local v9 = (v7[4] - 1) % #v7[3] + 1
		local v10 = parent[v7[1]].Main[v7[3][v9]]

		for _, child in pairs(parent[v7[1]].Title.Nav:GetChildren()) do
			child.Style = child.Name == v10.Name and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
		end

		parent[v7[1]].Title.Title.Text = v10.Name

		if v7[1] == "Shop" then
			if v10.Name == "Weapons" then
				parent.Shop.Info.Buy.ButtonIcon.Title.Text = "View"
			else
				parent.Shop.Info.Buy.ButtonIcon.Title.Text = "Buy"
			end
		end

		v10.Position = UDim2.new(p2, 0, 0, 0)
		v8:TweenPosition(UDim2.new(-p2, 0, 0, 0), "Out", "Quad", 0.2, false)
		v10:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, false)
		v3[p][4] = v9
		SetSelectionGroup(v10)
		wait(0.2)
		local GuiService3 = game:GetService("GuiService")
		GuiService3.SelectedObject = v10.Items.ScrollFrame.Container:FindFirstChild("Slot0") and v10.Items.ScrollFrame.Container:FindFirstChild("Slot0").Container.Button or nil
	end

	v6 = true
end

local BindDockButtons

BindDockButtons = function()
	if not dock.Visible then
		return
	end

	for k, v7 in pairs(v3) do
		local v8 = parent[v7[1]]
		local v9 = "Open" .. v7[1]
		local v10 = v7[2]
		local v11 = v7
		local v13 = k

		local function fn()
			if v11[1] == "Spectate" then
				if not (GetSpectatePlayers() and #GetSpectatePlayers() > 0) then
					return
				end

				v = 1
				v2 = GetSpectatePlayers()[v]
				game.Workspace.CurrentCamera.CameraSubject = v2.Character.Humanoid
				parent.Spectate.Title.PlayerName.Text = v2.Name
				v5 = true
			end

			for k2, v14 in pairs(v3) do
				ContextActionService:UnbindAction("Open" .. v14[1])
			end

			local v14 = v11[1] == "Spectate" and "" or parent[v11[1]].Main[v11[3][v11[4]]]
			v8:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, false)
			dock:TweenPosition(UDim2.new(0.5, -(dock.AbsoluteSize.X / 2), 1, 100), "Out", "Quad", 0.2, false)

			local function fn2() end

			ContextActionService:BindAction("NoX", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn2()
				end
			end, false, Enum.KeyCode.ButtonX)

			local function fn3() end

			ContextActionService:BindAction("NoB", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn3()
				end
			end, false, Enum.KeyCode.ButtonB)
			game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0)

			local function fn4()
				Navigate(v13, 1)
			end

			ContextActionService:BindAction("NavRight", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn4()
				end
			end, false, Enum.KeyCode.ButtonR1)

			local function fn5()
				Navigate(v13, -1)
			end

			ContextActionService:BindAction("NavLeft", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn5()
				end
			end, false, Enum.KeyCode.ButtonL1)

			local function fn6() end

			ContextActionService:BindAction("NoDpadLeft", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn6()
				end
			end, false, Enum.KeyCode.DPadLeft)

			local function fn7() end

			ContextActionService:BindAction("NoDpadRight", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn7()
				end
			end, false, Enum.KeyCode.DPadRight)
			parent.Leaderboard.Visible = false
			parent.Chat.Visible = false
			parent.CashBag:TweenPosition(UDim2.new(1.12, 0, 0.7, 0), "Out", "Quad", 0.2)
			parent.Perk:TweenPosition(UDim2.new(1.25, 0, 0.99, 0), "Out", "Quad", 0.2)
			parent.Weapon:TweenPosition(UDim2.new(-0.51, 0, 0.8, -5), "Out", "Quad", 0.2)
			wait(0.2)

			if v11[1] ~= "Spectate" then
				SetSelectionGroup(v14)
				local GuiService3 = game:GetService("GuiService")
				GuiService3.SelectedObject = v14.Items.ScrollFrame.Container:FindFirstChild("Slot0") and v14.Items.ScrollFrame.Container:FindFirstChild("Slot0").Container.Button or nil
			end

			ContextActionService:UnbindAction("NoB")
			local buttonB2 = Enum.KeyCode.ButtonB

			local function fn8()
				ContextActionService:UnbindAction("NoX")
				ContextActionService:UnbindAction("NoB")
				ContextActionService:UnbindAction("NavLeft")
				ContextActionService:UnbindAction("NavRight")
				ContextActionService:UnbindAction("BuyCrateBundle")
				ContextActionService:UnbindAction("NoDpadLeft")
				ContextActionService:UnbindAction("NoDpadRight")
				parent.CashBag:TweenPosition(UDim2.new(0.99, 0, 0.7, 0), "Out", "Quad", 0.2)
				parent.Perk:TweenPosition(UDim2.new(0.99, 0, 0.99, 0), "Out", "Quad", 0.2)
				parent.Weapon:TweenPosition(UDim2.new(0, 5, 0.8, -5), "Out", "Quad", 0.2)
				v8:TweenPosition(UDim2.new(0, 0, -1, -36), "Out", "Quad", 0.2, false)

				if dock.Visible then
					dock:TweenPosition(
						UDim2.new(0.5, -(dock.AbsoluteSize.X / 2), 1, -dock.AbsoluteSize.Y - 10),
						"Out",
						"Quad",
						0.2,
						false
					)
				end

				game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
				v5 = false
				game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0.5)
				parent.Leaderboard.Visible = true
				parent.Chat.Visible = true
				wait(0.2)
				ContextActionService:UnbindAction("Close")
				SetSelectionGroup(nil)
				local GuiService3 = game:GetService("GuiService")
				GuiService3.SelectedObject = nil
				BindDockButtons()
			end

			ContextActionService:BindAction("Close", function(p, p2)
				if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
					fn8()
				end
			end, false, buttonB2)
		end

		ContextActionService:BindAction(v9, function(p, p2)
			if p2 == Enum.UserInputState.Begin and not _G.PauseBinds then
				fn()
			end
		end, false, v10)
	end
end

game.ReplicatedStorage.Remotes.Gameplay.RoleSelect.OnClientEvent:connect(function(_, _, _, _, _)
	dock.Frame.Spectate.Icon.Image = "http://www.roblox.com/asset/?id=189764018"
	dock.Frame.Spectate.Icon.ImageColor3 = Color3.new(0.25, 0.25, 0.25)
	dock.Frame.Spectate.ButtonIcon.ImageColor3 = Color3.new(
		0.17254901960784313,
		0.17254901960784313,
		0.17254901960784313
	)
end)

local function fn()
	for _, tool in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if not (tool:IsA("Tool") and tool.Name == "Emotes") then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Backpack
		ContextActionService:UnbindAction("CloseEmotes")
	end

	dock:TweenPosition(
		UDim2.new(0.5, -(dock.AbsoluteSize.X / 2), 1, -dock.AbsoluteSize.Y - 10),
		"Out",
		"Quad",
		0.2,
		false
	)
	dock.Tip.TipText.Text = "CLOSE"
	icon1.Image = _G.GetButtonIcon("ButtonB")
	wait(0.2)
	BindDockButtons()

	local function fn2()
		icon1.Image = _G.GetButtonIcon("ButtonX")
		dock:TweenPosition(UDim2.new(0.5, -(dock.AbsoluteSize.X / 2), 1, 0), "Out", "Quad", 0.2, false)
		dock.Tip.TipText.Text = "MENU"

		for _, v7 in pairs(v3) do
			ContextActionService:UnbindAction("Open" .. v7[1])
		end

		wait(0.2)
		ContextActionService:UnbindAction("CloseMenu")
	end

	ContextActionService:BindAction("CloseMenu", function(_, p)
		if p == Enum.UserInputState.Begin and not _G.PauseBinds then
			fn2()
		end
	end, false, Enum.KeyCode.ButtonB)
end

ContextActionService:BindAction("OpenMenu", function(_, p)
	if p == Enum.UserInputState.Begin and not _G.PauseBinds then
		fn()
	end
end, false, Enum.KeyCode.ButtonX)

function _G.ResetDock()
	ContextActionService:UnbindAction("NoX")
	ContextActionService:UnbindAction("NoB")
	ContextActionService:UnbindAction("NavLeft")
	ContextActionService:UnbindAction("NavRight")
	ContextActionService:UnbindAction("BuyCrateBundle")
	ContextActionService:UnbindAction("NoDpadLeft")
	ContextActionService:UnbindAction("NoDpadRight")
	v5 = false
	parent.Shop:TweenPosition(UDim2.new(0, 0, -1, -36), "Out", "Quad", 0.2, false)
	parent.Inventory:TweenPosition(UDim2.new(0, 0, -1, -36), "Out", "Quad", 0.2, false)
	parent.Spectate:TweenPosition(UDim2.new(0, 0, -1, -36), "Out", "Quad", 0.2, false)
	game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0.5)
	ContextActionService:UnbindAction("Close")
	parent.Leaderboard.Visible = true
	parent.Chat.Visible = true
	parent.CashBag:TweenPosition(UDim2.new(0.99, 0, 0.7, 0), "Out", "Quad", 0.2)
	parent.Perk:TweenPosition(UDim2.new(0.99, 0, 0.99, 0), "Out", "Quad", 0.2)
	parent.Weapon:TweenPosition(UDim2.new(0, 5, 0.8, -5), "Out", "Quad", 0.2)
	SetSelectionGroup(nil)
	local GuiService3 = game:GetService("GuiService")
	GuiService3.SelectedObject = nil
	BindDockButtons()
	icon1.Image = _G.GetButtonIcon("ButtonX")
	dock:TweenPosition(UDim2.new(0.5, -(dock.AbsoluteSize.X / 2), 1, 0), "Out", "Quad", 0, false)
	dock.Tip.TipText.Text = "MENU"

	for _, v7 in pairs(v3) do
		ContextActionService:UnbindAction("Open" .. v7[1])
	end

	ContextActionService:UnbindAction("CloseMenu")
	dock.Visible = true
end

wait()
local GuiService3 = game:GetService("GuiService")
GuiService3.SelectedObject = nil