local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
game.Players.LocalPlayer.PlayerGui:WaitForChild("BackpackGui")
local translatorForPlayer = nil
local localPlayer = nil
local localeId = nil
local localeIdChangedConnection = nil
local bindableEvent = Instance.new("BindableEvent")

-- equivalent calls inferred from this helper; original call sites unknown
local function handlePlayerOrLocaleChanged()
	if localPlayer and localPlayer.LocaleId ~= localeId then
		localeId = localPlayer.LocaleId
		bindableEvent:Fire(localeId)
	end
end

local function reset()
	translatorForPlayer = nil
	localPlayer = nil

	if localeIdChangedConnection then
		localeIdChangedConnection:Disconnect()
		localeIdChangedConnection = nil
	end
end

local function getTranslator()
	if translatorForPlayer then
		return translatorForPlayer
	end

	localPlayer = Players.LocalPlayer

	if not localPlayer then
		return translatorForPlayer
	end

	translatorForPlayer = LocalizationService:GetTranslatorForPlayer(localPlayer)
	handlePlayerOrLocaleChanged() -- equivalent call inferred; original call site unknown
	localeIdChangedConnection = localPlayer:GetPropertyChangedSignal("LocaleId"):Connect(handlePlayerOrLocaleChanged)
	return translatorForPlayer
end

local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function unregisterGui(p)
	v[p].connection:Disconnect()
	v[p] = nil
end

local function makeAncestryChangedHandler(descendant, p)
	return function(_, _)
		if game:IsAncestorOf(descendant) then
			p.hasBeenAdded = true
		elseif p.hasBeenAdded then
			unregisterGui(descendant) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateRegistryInfo(p, context, text)
	p.context = context
	p.text = text
end

local function makeRegistryInfo(descendant, context, text)
	local v2 = {
		hasBeenAdded = game:IsAncestorOf(descendant),
		context = context,
		text = text
	}
	v2.connection = descendant.AncestryChanged:Connect(function(_, _)
		if game:IsAncestorOf(descendant) then
			v2.hasBeenAdded = true
		elseif v2.hasBeenAdded then
			unregisterGui(descendant) -- equivalent call inferred; original call site unknown
		end
	end)
	return v2
end

local function registerGui(p, context, text)
	if v[p] == nil then
		v[p] = makeRegistryInfo(p, context, text)
		return
	end

	updateRegistryInfo(v[p], context, text) -- equivalent call inferred; original call site unknown
end

local GameTranslator = {
	LocaleChanged = bindableEvent.Event,
	TranslateGameText = function(self, _, p)
		return p
	end
}

local function retranslateAll()
	for k, v2 in pairs(v) do
		k.Text = GameTranslator:TranslateGameText(v2.context, v2.text)
	end
end

function GameTranslator.TranslateAndRegister(_, _, _, p)
	return p
end

return GameTranslator