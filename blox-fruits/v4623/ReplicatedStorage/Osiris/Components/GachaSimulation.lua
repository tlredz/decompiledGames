local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
require(game.ReplicatedStorage.Util.TypeUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local AccuracyPanel = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.AccuracyPanel)
local ConfigPanel = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.ConfigPanel)
local JourneyPanel = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.JourneyPanel)
local Present = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Present)
local Runner = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Runner)
local SensitivityPanel = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.SensitivityPanel)
local Store = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Store)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)
local v = nil

local function getItemIcon(p: number)
	return ItemConfig.match(p):unwrap().Display.Sprite
end

local function solveAsync(p)
	local Solver = require(game.ServerScriptService.Services.GachaServer.Solver)
	return Solver.simulate(p)
end

local function describe(p: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	local display = unwrapped.Display
	return display.Title or display.Name or unwrapped.Index.StorageKey, unwrapped.Quality.Rarity or "Common"
end

local function listBoxNames()
	local v2 = v

	if v2 ~= nil then
		return v2
	end

	local names = {}

	for _, moduleScript in game.ServerScriptService.Services.GachaServer.Solver.DEFINITIONS.LIBRARY:GetChildren() do
		if moduleScript:IsA("ModuleScript") then
			table.insert(names, moduleScript.Name)
		end
	end

	table.sort(names)
	v = names
	return names
end

local function buildContext(p)
	local remote = p.Remote
	local arguments = p.Arguments
	local boxNames

	if remote == nil then
		boxNames = listBoxNames()
	else
		boxNames = (arguments == nil or arguments.BoxNames == nil) and {} or arguments.BoxNames
	end

	return {
		getItemIcon = getItemIcon,
		describe = describe,
		solveAsync = solveAsync,
		Remote = remote,
		BoxNames = boxNames
	}
end

return function(p)
	local store = Store.use(p.Arguments, p.States)
	local context = buildContext(p)
	Runner.step(store, context)
	local chartHeight = store.Arguments.ChartHeight
	Osiris.Widget.Window({
		Arguments = {
			Title = "Gacha simulation - setup",
			NoClose = true
		},
		States = {
			position = store.setupPosition,
			size = store.setupSize
		}
	}, function()
		Osiris.Widget.SameLine({}, function()
			Osiris.Widget.Checkbox({
				Arguments = {
					Text = "accuracy"
				},
				States = {
					isChecked = store.accuracyOpen
				}
			})
			Osiris.Widget.Checkbox({
				Arguments = {
					Text = "sensitivity"
				},
				States = {
					isChecked = store.sensitivityOpen
				}
			})
			Osiris.Widget.Checkbox({
				Arguments = {
					Text = "journey"
				},
				States = {
					isChecked = store.journeyOpen
				}
			})
		end)

		if context.Remote ~= nil then
			Present.note("Runs are queued on the server and polled from here.")
		end

		ConfigPanel({
			Store = store,
			Context = context
		})
	end)
	Osiris.Widget.Window({
		Arguments = {
			Title = "Gacha simulation - accuracy"
		},
		States = {
			position = store.accuracyPosition,
			size = store.accuracySize,
			isOpened = store.accuracyOpen
		}
	}, function()
		if not store.accuracyOpen:get() then
			return
		end

		AccuracyPanel({
			Store = store,
			Height = chartHeight
		})
	end)
	Osiris.Widget.Window({
		Arguments = {
			Title = "Gacha simulation - sensitivity"
		},
		States = {
			position = store.sensitivityPosition,
			size = store.sensitivitySize,
			isOpened = store.sensitivityOpen
		}
	}, function()
		if not store.sensitivityOpen:get() then
			return
		end

		SensitivityPanel({
			Store = store,
			Height = chartHeight
		})
	end)
	Osiris.Widget.Window({
		Arguments = {
			Title = "Gacha simulation - journey"
		},
		States = {
			position = store.journeyPosition,
			size = store.journeySize,
			isOpened = store.journeyOpen
		}
	}, function()
		if not store.journeyOpen:get() then
			return
		end

		JourneyPanel({
			Store = store,
			Height = chartHeight
		})
	end)
	local v3 = store.job:get()
	local error = v3.Error

	if v3.Status == "Failed" and error ~= nil then
		Osiris.Widget.Window({
			Arguments = {
				Title = "Gacha simulation - error"
			},
			States = {
				position = store.errorPosition
			}
		}, function()
			Osiris.Widget.Text({
				Arguments = {
					Text = error,
					Color = Present.BAD,
					Wrapped = true
				}
			})
			Present.note("Fix the cause, then press \"re-solve pool\" in the setup window to try again.")
		end)
	end
end