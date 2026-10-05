local TweenService = game:GetService("TweenService")
local services = game.ReplicatedStorage:WaitForChild("Services")
require(services:WaitForChild("FormatNumber"):WaitForChild("Main"))
local gameServices = game.ReplicatedStorage:WaitForChild("GameServices")
local General = require(gameServices:WaitForChild("General"))
local localPlayer = game.Players.LocalPlayer
local cash = localPlayer:WaitForChild("SavedData"):WaitForChild("Cash")
local SFX = game.SoundService:WaitForChild("SFX")
local parent = script.Parent
local cashAmount = parent:WaitForChild("CashAmount")
parent:WaitForChild("CashIncome")
local size = cashAmount.Size
local tween = TweenService:Create(
	cashAmount,
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
	{
		Size = UDim2.new(size.X.Scale * 1.2, 0, size.Y.Scale * 1.2, 0)
	}
)
local dataLoaded = localPlayer:WaitForChild("NoSaveData"):WaitForChild("DataLoaded")

repeat
	task.wait(0.5)
until dataLoaded.Value == true

local Passes = require(gameServices:WaitForChild("Passes"))
local AutoCollect = require(gameServices:WaitForChild("AutoCollect"))
local hasFinishedTutorial = localPlayer:WaitForChild("SavedData"):WaitForChild("HasFinishedTutorial")
local now = 0
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PetCollect").OnClientEvent:Connect(function(p)
	if typeof(p) == "table" and p.Auto and p.Owner == localPlayer.UserId then
		now = os.clock()
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function SweepSilenced(now2)
	if math.abs(now - now2) > 0.35 then
		return false
	end

	return AutoCollect.Enabled() and hasFinishedTutorial.Value == true and true or Passes.Has(
		localPlayer,
		"AutoCollect"
	)
end

local value = cash.Value

function UpdateCash()
	local v = cash.Value - value

	if v > 0 then
		local now2 = os.clock()
		task.delay(0.15, function()
			-- equivalent call inferred; original call site unknown
			if not SweepSilenced(now2) then
				SFX.CashEarned:SetAttribute("Play", (tonumber(SFX.CashEarned:GetAttribute("Play")) or 0) + 1)
			end
		end)
	elseif v < 0 then
		SFX.Purchase:SetAttribute("Play", (tonumber(SFX.Purchase:GetAttribute("Play")) or 0) + 1)
	end

	cashAmount.Text = string.format("$%s", General:FormatNumber(cash.Value))
	tween:Play()
	value = cash.Value
end

UpdateCash()
cash:GetPropertyChangedSignal("Value"):Connect(function()
	UpdateCash()
end)