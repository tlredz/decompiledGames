local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local FishIndex = require(ReplicatedStorage.React.Components.FishIndex)
local FishIndex2 = require(ReplicatedStorage.Modules.SerData.FishIndex)
local Base91 = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Base91"))
local v = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishIndex"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
local frame = Instance.new("Frame")
frame.Name = "ROOT"
frame.BackgroundTransparency = 1
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0.5, 0, 0.5, 0)
frame.Parent = screenGui
screenGui.Parent = playerGui
local createElement = React.createElement

function rootComponent(_)
	local state, setState = React.useState(v)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(0)
	local setIsOpen = React.useCallback(function(fishIndexVisible: boolean)
		setState2(fishIndexVisible)
		local localPlayer = Players.LocalPlayer
		local playerGui2 = localPlayer and localPlayer:FindFirstChild("PlayerGui")

		if not playerGui2 then
			return
		end

		playerGui2:SetAttribute("FishIndexVisible", fishIndexVisible)
	end)
	React.useEffect(function()
		local localPlayer = Players.LocalPlayer
		local encodedFishIndex = localPlayer and localPlayer:GetAttribute("EncodedFishIndex")

		if encodedFishIndex then
			setState((FishIndex2.decode(Base91.decodeBuffer(buffer.fromstring(encodedFishIndex)))))
		else
			setState(v)
		end

		setState3(next(state) or 0)
		local encodedFishIndexChangedConnection, fishIndexVisibleChangedConnection

		if localPlayer then
			local playerGui2 = localPlayer:WaitForChild("PlayerGui")
			playerGui2:SetAttribute("FishIndexVisible", false)
			encodedFishIndexChangedConnection = localPlayer:GetAttributeChangedSignal("EncodedFishIndex"):Connect(function()
				local encodedFishIndex2 = localPlayer:GetAttribute("EncodedFishIndex")

				if not encodedFishIndex2 then
					setState(v)
					return
				end

				setState((FishIndex2.decode(Base91.decodeBuffer(buffer.fromstring(encodedFishIndex2)))))
			end)
			fishIndexVisibleChangedConnection = playerGui2:GetAttributeChangedSignal("FishIndexVisible"):Connect(function()
				setIsOpen(playerGui2:GetAttribute("FishIndexVisible") or false)
			end)
		else
			encodedFishIndexChangedConnection = nil
			fishIndexVisibleChangedConnection = nil
		end

		return function()
			if encodedFishIndexChangedConnection then
				encodedFishIndexChangedConnection:Disconnect()
				encodedFishIndexChangedConnection = nil
			end

			if fishIndexVisibleChangedConnection then
				fishIndexVisibleChangedConnection:Disconnect()
				fishIndexVisibleChangedConnection = nil
			end
		end
	end, {})
	return createElement(FishIndex, {
		IsOpen = state2,
		SetIsOpen = setIsOpen,
		Fish = state,
		CurrentFishIndex = state3,
		SetCurrentFish = setState3
	})
end

ReactRoblox.createRoot(screenGui:WaitForChild("ROOT")):render(createElement(rootComponent, {}))