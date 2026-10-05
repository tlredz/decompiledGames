local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function getTaggedInGui(tag: string)
	for _, v in ipairs(CollectionService:GetTagged(tag)) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end

	return nil
end

local function startPulse(p)
	TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Size = p.Size + UDim2.fromScale(0.07, 0.07)
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trySetup()
	local taggedInGui = getTaggedInGui("MouseIcon")

	if taggedInGui and taggedInGui:IsA("GuiObject") then
		startPulse(taggedInGui)
		return true
	else
		return false
	end
end

-- equivalent call inferred; original call site unknown
if not trySetup() then
	CollectionService:GetInstanceAddedSignal("MouseIcon"):Connect(function(guiObject)
		if guiObject:IsDescendantOf(playerGui) and guiObject:IsA("GuiObject") then
			startPulse(guiObject)
		end
	end)
end