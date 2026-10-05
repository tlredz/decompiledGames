local ContextActionService = game:GetService("ContextActionService")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))

repeat
	wait()
until game.Players.LocalPlayer.Character and _G.EmoteFrame ~= nil

local clone = script.Emotes:Clone()
clone.D.Disabled = false
clone.Parent = game.Players.LocalPlayer.Backpack
_G.EmoteController = {}
_G.EmoteController.Emotes = {}
local v = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero
}
local childNames = {}
local connections = {}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService2 = game:GetService("ContextActionService")

-- equivalent calls inferred from this helper; original call sites unknown
local function closeEmotes()
	clone.Parent = game.Players.LocalPlayer.Backpack
end

local function ClearBinds()
	for _, v2 in childNames do
		ContextActionService2:UnbindAction(v2)
	end

	for _, connection in connections do
		connection:Disconnect()
	end
end

local v2 = 1

local function BindPage()
	ClearBinds()

	for k, childName in _G.EmoteController.Emotes do
		-- equivalent calls inferred from this helper; original call sites unknown
		local v3 = childName

		local function fn()
			if v3 ~= "Back" then
				game.ReplicatedStorage.Remotes.Misc.PlayEmote:Fire(v3)
			end

			closeEmotes() -- equivalent call inferred; original call site unknown
		end

		local ContextActionService3 = game:GetService("ContextActionService")
		local v4 = childName
		ContextActionService3:BindAction(childName, function(p, p2, p3)
			if p2 ~= Enum.UserInputState.Begin then
				return
			end

			fn() -- equivalent call inferred; original call site unknown
		end, false, v[k])
		table.insert(childNames, childName)
		table.insert(
			connections,
			_G.EmoteFrame.EmotePages[_G.CurrentPage].Container:FindFirstChild(childName).Container.Button.MouseButton1Click:connect(fn)
		)
	end
end

function _G.RebindPage()
	BindPage()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ChangePage(p)
	v2 = v2 + p > #_G.EmotePages and 1 or v2 + p < 1 and #_G.EmotePages or v2 + p
	_G.ChangePage(v2)
	BindPage()
end

function _G.EmotePageLeft()
	ChangePage(-1) -- equivalent call inferred; original call site unknown
end

function _G.EmotePageRight()
	ChangePage(1) -- equivalent call inferred; original call site unknown
end

local function onPageAction(p: string, p2, _)
	if p2 ~= Enum.UserInputState.Begin then
		return
	end

	if p == "EmotePageLeft" then
		_G.EmotePageLeft()
	elseif p == "EmotePageRight" then
		_G.EmotePageRight()
	end
end

local v3 = 0
ContextActionService.LocalToolEquipped:Connect(function(p)
	if p.Name ~= "Emotes" then
		return
	end

	game.Players.LocalPlayer.Character.ChildAdded:Connect(function(_)
		v3 = time()
	end)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	_G.EmoteFrame.Visible = true
	BindPage()
	ContextActionService2:BindAction("EmotePageLeft", onPageAction, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q)
	ContextActionService2:BindAction("EmotePageRight", onPageAction, false, Enum.KeyCode.ButtonR1, Enum.KeyCode.E)
	ContextActionService2:BindAction("CloseEmotePage", closeEmotes, false, Enum.KeyCode.ButtonB)

	if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
		GuiService.SelectedObject = _G.EmoteFrame.EmotePages[_G.CurrentPage].Container:GetChildren()[1].Container.Button
	end

	if #game.Players.LocalPlayer.Backpack:GetChildren() == 0 then
		local clone = script.AAAAA:Clone()
		clone.Parent = game.Players.LocalPlayer.Backpack
	end
end)
ContextActionService2.LocalToolUnequipped:Connect(function(p)
	if p.Name ~= "Emotes" then
		return
	end

	GuiService.SelectedObject = nil
	task.wait()
	local AAAAA = game.Players.LocalPlayer.Backpack:FindFirstChild("AAAAA")

	if AAAAA then
		AAAAA:Destroy()
	end

	ClearBinds()
	ContextActionService2:UnbindAction("EmotePageLeft")
	ContextActionService2:UnbindAction("EmotePageRight")
	ContextActionService2:UnbindAction("CloseEmotePage")
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	_G.EmoteFrame.Visible = false
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(_)
	repeat
		wait()
	until game.Players.LocalPlayer.Character

	ClearBinds()
	clone = script.Emotes:Clone()
	clone.D.Disabled = false
	closeEmotes() -- equivalent call inferred; original call site unknown
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	_G.EmoteFrame.Visible = false
end)
game.Players.LocalPlayer.Backpack.ChildAdded:connect(function(_) end)