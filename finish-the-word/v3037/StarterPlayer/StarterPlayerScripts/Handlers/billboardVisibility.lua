local localPlayer = game.Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
_G.import("global")
local import = _G.import("event")
local import2 = _G.import("signalUtil")

local function updatePromptVisibility()
	local inGame = localPlayer:GetAttribute("InGame")
	local isQueuing = localPlayer:GetAttribute("IsQueuing")

	for _, v in pairs(CollectionService:GetTagged("PlayerPrompt")) do
		v.Enabled = v.Parent ~= localPlayer.Character and not (inGame or isQueuing)
	end

	for _, v in pairs(CollectionService:GetTagged("StationPrompt")) do
		v.Enabled = not (inGame or isQueuing)
	end
end

local function updateGameBillboardVisibility()
	local inGame = localPlayer:GetAttribute("InGame")

	for _, v in pairs(CollectionService:GetTagged("GameBillboard")) do
		v.Enabled = v:GetAttribute("Active") and not inGame
	end
end

local function updateCashVisibility(p)
	if p.Parent == localPlayer.Character then
		p.Enabled = false
	end
end

local function updateNametagPartVisibility(instance)
	if localPlayer:GetAttribute("InGame") then
		if instance:GetAttribute("VisibleBeforeGameplay") == nil then
			instance:SetAttribute("VisibleBeforeGameplay", instance.Visible)
		end

		instance.Visible = false
	else
		local visibleBeforeGameplay = instance:GetAttribute("VisibleBeforeGameplay")

		if visibleBeforeGameplay == nil then
			return
		end

		instance.Visible = visibleBeforeGameplay
		instance:SetAttribute("VisibleBeforeGameplay", nil)
	end
end

local function updateNametagPartsVisibility()
	for _, v in pairs(CollectionService:GetTagged("HideNametagPartInGame")) do
		updateNametagPartVisibility(v)
	end
end

return {
	Priority = 1,
	Run = function()
		import.connect("characterAdded", updateCashVisibility)
		import2.onTag("CashBillboard", updateCashVisibility)
		import2.onTag("PlayerPrompt", updatePromptVisibility)
		import2.onTag("HideNametagPartInGame", updateNametagPartVisibility)
		import2.onTag("StationPrompt", updatePromptVisibility)
		localPlayer:GetAttributeChangedSignal("InGame"):Connect(updatePromptVisibility)
		localPlayer:GetAttributeChangedSignal("InGame"):Connect(updateNametagPartsVisibility)
		localPlayer:GetAttributeChangedSignal("IsQueuing"):Connect(updatePromptVisibility)
		RunService.RenderStepped:Connect(updateGameBillboardVisibility)
	end
}