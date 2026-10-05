local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.packages.Trove)
local localPlayer = game.Players.LocalPlayer
local highTide = localPlayer:WaitForChild("PlayerGui"):WaitForChild("HighTide")
local tidemeter = highTide:WaitForChild("Main"):WaitForChild("Tidemeter")
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(fill, tweenInfo, p)
	local tween = TweenService:Create(fill, tweenInfo, p)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local HighTideController = {}

function HighTideController:EnableUI()
	maid:Add(function()
		highTide.Enabled = false
	end)
	highTide.Enabled = true

	local function UpdateTideBar(tideValue: number)
		fastTween(tidemeter.fill, TweenInfo.new(1), {
			Size = UDim2.fromScale(tideValue / 100, 0.653)
		}) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateCasts(highTideCasts: number)
		tidemeter.CastsLeft.Text = ("Casts Left: %s"):format(highTideCasts)
	end

	UpdateTideBar(localPlayer:GetAttribute("TideValue") or 0)
	local highTideCasts = localPlayer:GetAttribute("HighTideCasts") or 0
	UpdateCasts(highTideCasts) -- equivalent call inferred; original call site unknown
	maid:Add(localPlayer:GetAttributeChangedSignal("TideValue"):Connect(function()
		UpdateTideBar(localPlayer:GetAttribute("TideValue") or 0)
	end))
	maid:Add(localPlayer:GetAttributeChangedSignal("HighTideCasts"):Connect(function()
		local highTideCasts2 = localPlayer:GetAttribute("HighTideCasts") or 0
		UpdateCasts(highTideCasts2) -- equivalent call inferred; original call site unknown
	end))
end

function HighTideController:DisableUI()
	maid:Clean()
end

function HighTideController:Start()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function CheckRod()
		if localPlayer:GetAttribute("HighTideRod") then
			self:EnableUI()
		else
			self:DisableUI()
		end
	end

	CheckRod() -- equivalent call inferred; original call site unknown
	localPlayer:GetAttributeChangedSignal("HighTideRod"):Connect(function()
		CheckRod() -- equivalent call inferred; original call site unknown
	end)
end

return HighTideController