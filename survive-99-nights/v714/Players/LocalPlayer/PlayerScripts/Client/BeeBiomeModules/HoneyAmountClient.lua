local HoneyAmountClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local honeyAmount = nil
local v = false

function UpdateHoney()
	local totalHoney = workspace:GetAttribute("TotalHoney") or 0
	local totalHoneyPerMinute = workspace:GetAttribute("TotalHoneyPerMinute") or 0
	honeyAmount.TextLabel.Text = math.floor(totalHoney)
	honeyAmount.Rate.Text = totalHoneyPerMinute .. " / minute"
	UpdateVisibility()
end

function UpdateVisibility()
	honeyAmount.Visible = v and workspace:GetAttribute("AnyFlowerPlanted") == true
end

function BiomeChanged(p)
	v = p == "Bees"
	UpdateVisibility()
end

function HoneyAmountClient.Init()
	task.spawn(function()
		honeyAmount = Client.Interface.HoneyAmount
		workspace:GetAttributeChangedSignal("TotalHoney"):Connect(UpdateHoney)
		workspace:GetAttributeChangedSignal("TotalHoneyPerMinute"):Connect(UpdateHoney)
		workspace:GetAttributeChangedSignal("AnyFlowerPlanted"):Connect(UpdateVisibility)
		Client.Events.BiomeEntered:Connect(BiomeChanged)
		UpdateHoney()
		BiomeChanged(Client.BiomesClient.GetCurrentBiome())
	end)
end

return HoneyAmountClient