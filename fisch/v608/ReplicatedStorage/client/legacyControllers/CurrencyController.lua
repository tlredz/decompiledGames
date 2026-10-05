local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local WorldController = require(legacyControllers.WorldController)
local modules = ReplicatedStorage:WaitForChild("client").modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
require(ReplicatedStorage:WaitForChild("shared").modules.Worlds)

local function ReadDataPath(dataPath: string?)
	local fetched = legacyLocalPlayerData.fetch()

	if not fetched then
		return
	end

	if dataPath == nil then
		return fetched
	end

	local v = string.split(dataPath, ".")

	for i = 1, #v do
		if fetched == nil then
			return nil
		else
			fetched = fetched:FindFirstChild(v[i])
		end
	end

	return fetched
end

local CurrencyController = {}

function CurrencyController.GetFormatting(_)
	return WorldController:GetCurrencyData(WorldController:GetCurrentCurrency()).Formatting
end

function CurrencyController.GetImage(_, p)
	return WorldController:GetCurrencyData(p or WorldController:GetCurrentCurrency()).Icon
end

function CurrencyController.GetDisplay(_, p)
	return WorldController:GetCurrencyData(p or WorldController:GetCurrentCurrency()).Display
end

function CurrencyController.GetInstance(_)
	return (ReadDataPath(WorldController:GetCurrencyData(WorldController:GetCurrentCurrency()).DataPath))
end

function CurrencyController.Get(_)
	local readDataPath = ReadDataPath(WorldController:GetCurrencyData(WorldController:GetCurrentCurrency()).DataPath)
	return readDataPath and readDataPath.Value or 0
end

function CurrencyController.SetupCurrencyLabel(_, _) end

return CurrencyController