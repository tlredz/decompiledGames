local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local Libs = require(script.Libs)
local Utils = require(script.Utils)
local Shared = require(script.Shared)
local Settings = require(script.Settings)
local Services = require(script.Services)
require(script.DataTemplate)
local assets = ReplicatedStorage:WaitForChild("Assets")
StarterGui:WaitForChild("UI")
StarterGui:WaitForChild("Inset")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local isStudio = RunService:IsStudio()
local Omni = {
	Loaded = false,
	Cache = {
		Storage = {}
	},
	Cooldown = {
		Storage = {}
	},
	Leaderboards = {},
	PlayersCountries = {},
	Signal = {},
	Scripts = {},
	Libs = Libs,
	Utils = Utils,
	Shared = Shared,
	Settings = Settings,
	Services = Services,
	Assets = assets,
	Inset = nil,
	Interface = nil,
	Instance = nil,
	Data = nil,
	Platform = nil,
	Debug = function(self, p)
		if not isStudio then
			return
		end

		print("[OMNI-DEBUG]", p)
	end
}

function Omni.Init(_)
	if Omni.Loaded then
		Omni:Debug("The Omni module is already loaded!")
		return
	end

	local omni

	if isServer then
		omni = ServerScriptService:WaitForChild("Omni")
	end

	if isClient then
		local localPlayer = Players.LocalPlayer

		if localPlayer then
			omni = localPlayer.PlayerScripts:WaitForChild("Omni")
		else
			Omni:Debug("Player Instance not found!")
			return
		end
	end

	if not omni then
		Omni:Debug("Omni folder not found!")
		return
	end

	local main = omni:FindFirstChild("Main")
	local scripts = omni:FindFirstChild("Scripts")

	if not main then
		Omni:Debug("Main folder not found!")
		return
	end

	if not scripts then
		Omni:Debug("Scripts folder not found!")
		return
	end

	if isClient then
		Omni.Libs.ThreadSaver.New(function()
			ContentProvider:PreloadAsync(assets:GetDescendants())
		end)
	end

	local v = {}

	for _, moduleScript in main:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		if Omni[moduleScript.Name] then
			Omni:Debug((`Repeated Main Module: "{moduleScript.Name}"!`))
		else
			local success, result = pcall(require, moduleScript)

			if success then
				table.insert(v, result)
				Omni[moduleScript.Name] = result
			else
				Omni:Debug((`Failed to load Main Module "{moduleScript.Name}" with error: {result}!`))
			end
		end
	end

	for _, v2 in v do
		if v2.Init then
			task.defer(v2.Init)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function StartSectionModule(p)
		if not p.Init then
			return
		end

		if isClient then
			task.defer(p.Init)
		end

		if isServer then
			task.defer(p.Init.Callback)
		end
	end

	local v2 = {}
	local v3 = false
	local v4 = {}

	for _, folder in scripts:GetChildren() do
		if not folder:IsA("Folder") then
			continue
		end

		if Omni.Scripts[folder.Name] then
			Omni:Debug((`Repeated Section: {folder.Name}!`))
		else
			Omni.Scripts[folder.Name] = {}

			for _, moduleScript in folder:GetChildren() do
				if not moduleScript:IsA("ModuleScript") then
					continue
				end

				local formatted = `"{folder.Name}" - "{moduleScript.Name}"`
				v2[moduleScript] = formatted
				local v5 = folder
				local v6 = moduleScript
				Omni.Libs.ThreadSaver.New(function()
					if Omni.Scripts[v5.Name][v6.Name] then
						Omni:Debug((`Repeated Section Module: {formatted}!`))
						v2[v6] = nil
					else
						local success, result = pcall(require, v6)
						v2[v6] = nil

						if not success then
							Omni:Debug((`Failed to load Section Module {formatted} with error: {result}!`))
							return
						end

						Omni.Scripts[v5.Name][v6.Name] = result

						if not v3 then
							table.insert(v4, result)
							return
						end

						Omni:Debug((`Section Module {formatted} finished loading late, running its Init now!`))
						StartSectionModule(result) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end
	end

	local lastTime = os.clock()

	while next(v2) and os.clock() - lastTime < 10 do
		task.wait()
	end

	if next(v2) then
		local v5 = {}

		for _, v6 in v2 do
			table.insert(v5, v6)
		end

		Omni:Debug((`{#v5} Section Module(s) did not finish loading in time, their Init will run when they finish: {table.concat(v5, ", ")}`))
	end

	v3 = true

	for _, v5 in v4 do
		StartSectionModule(v5) -- equivalent call inferred; original call site unknown
	end

	Omni:Debug((`{isServer and "Server" or "Client"} Loaded!`))
	Omni.Loaded = true
end

function Omni:WaitInitialization()
	repeat
		task.wait()
	until Omni.Loaded
end

function Omni.Cooldown.Check(_, value: string)
	if value and typeof(value) == "string" then
		return Omni.Cooldown.Storage[value] or false
	end

	Omni:Debug("Cooldown Identifier should be a string!")
end

function Omni.Cooldown:Set(value: string, duration: number)
	if typeof(value) ~= "string" then
		Omni:Debug("Cooldown Identifier should be a string!")
		return
	end

	if typeof(duration) ~= "number" then
		Omni:Debug("Cooldown Time should be a number!")
		return
	end

	Omni.Cooldown.Storage[value] = true
	task.delay(duration, function()
		Omni.Cooldown.Storage[value] = nil
	end)
end

function Omni.Cooldown:SetIfDidntExist(p: string, p2: number)
	if Omni.Cooldown:Check(p) then
		return true
	end

	Omni.Cooldown:Set(p, p2)
	return false
end

function Omni.Cache.Get(_, list)
	if not list or typeof(list) ~= "table" or not list[1] then
		Omni:Debug("Cache Path should be a table!")
		return
	end

	if #list == 1 then
		return Omni.Cache.Storage[list[1]]
	end

	local v = Omni.Cache.Storage[list[1]]

	if not v then
		return
	end

	if #list >= 3 then
		for i = 2, #list - 1 do
			if not v then
				return
			end

			v = v[list[i]]
		end
	end

	return v[list[#list]]
end

function Omni.Cache:Set(list, p)
	if not list or typeof(list) ~= "table" or not list[1] then
		Omni:Debug("Cache Path should be a table!")
		return
	end

	if #list == 1 then
		Omni.Cache.Storage[list[1]] = p
		return true
	end

	if not Omni.Cache.Storage[list[1]] then
		Omni.Cache.Storage[list[1]] = {}
	end

	local v = Omni.Cache.Storage[list[1]]

	if #list >= 3 then
		for i = 2, #list - 1 do
			if not v[list[i]] then
				v[list[i]] = {}
			end

			v = v[list[i]]
		end
	end

	v[list[#list]] = p
	return true
end

local v

if isServer then
	v = Libs.BridgeNet.ServerBridge("Signal")
else
	v = nil
end

if isClient then
	v = Libs.BridgeNet.ClientBridge("Signal")
end

function Omni.Signal:_ReportInvalid(p, p2: string, p3)
	if p and Omni.Cooldown:SetIfDidntExist(tostring(p.UserId) .. "InvalidSignalReport", 5) then
		return
	end

	Omni:Debug(p2)

	if isStudio and p3 ~= nil then
		Omni:Debug(p3)
	end
end

function Omni.Signal:_RejectInvalid(p, p2: string, p3)
	if p then
		Omni.Cooldown:Set(tostring(p.UserId) .. "InvalidSignal", 1)
	end

	Omni.Signal:_ReportInvalid(p, p2, p3)
end

function Omni.Signal:_Interpreter(flag: boolean, p, value: string, value2: string, value3: string, ...)
	if isServer and p then
		if not Omni.Loaded or Omni.Cooldown:Check(tostring(p.UserId) .. "InvalidSignal") then
			return
		end
	end

	if not Omni.Loaded then
		Omni.Libs.ThreadSaver.New(function(...)
			Omni:WaitInitialization()
			Omni.Signal:_Interpreter(...)
		end, flag, p, value, value2, value3, ...)
		return
	end

	if typeof(value) ~= "string" or typeof(value2) ~= "string" or typeof(value3) ~= "string" then
		return
	end

	if isServer and p and not (Omni.Shared.TimeChamber.IsScriptAllowed(value2) or Omni.Shared.TimeChamber.Check(p)) then
		return
	end

	local script2 = Omni.Scripts[value]

	if not script2 then
		Omni.Signal:_RejectInvalid(p, `Signal Section not found: {value}!`, Omni.Scripts)
		return
	end

	local v2 = script2[value2]

	if not v2 then
		Omni.Signal:_RejectInvalid(p, `Signal Script not found: {value2}!`, script2)
		return
	end

	local v3 = nil
	local v4 = v2[value3]
	local callback

	if isServer then
		if not v4 or typeof(v4) ~= "table" then
			Omni.Signal:_RejectInvalid(p, `Signal Function not found: {value3}!`, v2)
			return
		end

		if v4.Restricted and p then
			return
		else
			callback = v4.Callback
		end
	end

	if isClient then
		if v4 and typeof(v4) == "function" then
			callback = v4
		else
			Omni.Signal:_RejectInvalid(p, `Signal Function not found: {value3}!`, v2)
			return
		end
	end

	if p then
		local v5 = tostring(p.UserId) .. value .. value2 .. value3

		if Omni.Cooldown:Check(v5) then
			return
		else
			Omni.Cooldown:Set(v5, v4.Cooldown or 0.1)
		end
	end

	local v5 = table.pack(...)

	if isServer and p then
		local v6 = { 0 }

		for k, v7 in v5 do
			if Omni.Utils.Validator:Validate(v7, nil, v6) then
				continue
			end

			Omni.Signal:_ReportInvalid(
				p,
				`Parameter {k} of function {value3} of Script {value2} of Section {value} is not valid!`,
				v7
			)
			return
		end
	end

	if isServer and p then
		v3 = Omni.Players:Get(p)

		if not v3 or v3.Data.Banned then
			return
		end
	end

	if isServer and v4.Params and p then
		for i = 1, #v4.Params do
			local param = v4.Params[i]

			if not param then
				continue
			end

			local v6 = v5[i]

			if v6 == nil then
				Omni.Signal:_ReportInvalid(
					p,
					(`Parameter {i} of function {value3} of Script {value2} of Section {value} is missing!`)
				)
				return
			end

			if Omni.Utils.Validator:CheckType(param, v6) then
				continue
			end

			Omni.Signal:_ReportInvalid(
				p,
				(`Parameter {i} of function {value3} of Script {value2} of Section {value} should be {param} but got {typeof(v6)}!`)
			)
			return
		end
	end

	if flag then
		if v3 then
			return callback(v3, ...)
		end

		return callback(...)
	elseif v3 then
		callback(v3, ...)
	else
		callback(...)
	end
end

function Omni.Signal.Fire(_, player, ...)
	if isServer then
		if player and typeof(player) == "Instance" and player:IsA("Player") then
			Omni.Libs.DataContainerServer.FlushPlayer(player)
			v:Fire(Omni.Libs.BridgeNet.Players({ player }), table.pack(...))
		else
			Omni:Debug("First Parameter should be a player instance!")
			return
		end
	end

	if isClient then
		v:Fire(table.pack(player, ...))
	end
end

function Omni.Signal.FireAll(_, ...)
	if isServer then
		Omni.Libs.DataContainerServer.FlushAll()
		v:Fire(Omni.Libs.BridgeNet.AllPlayers(), table.pack(...))
	end
end

function Omni.Signal.FireList(_, list, ...)
	if isServer then
		if typeof(list) ~= "table" then
			Omni:Debug("Player List should be a table!")
			return
		end

		local players

		if table.isfrozen(list) then
			players = list
		else
			local count = 0
			players = {}

			for _, player in list do
				if typeof(player) == "Instance" and player:IsA("Player") then
					table.insert(players, player)
				else
					count += 1
				end
			end

			if count > 0 and not Omni.Cooldown:SetIfDidntExist("InvalidSignalPlayerList", 5) then
				Omni:Debug((`Player List has {count} entries that are not player instances!`))
			end
		end

		if #players == 0 then
			return
		end

		Omni.Libs.DataContainerServer.FlushAll()
		v:Fire(Omni.Libs.BridgeNet.Players(players), table.pack(...))
	end
end

function Omni.Signal.FireSelf(_, ...)
	Omni.Signal:_Interpreter(false, nil, ...)
end

function Omni.Signal.InvokeSelf(_, ...)
	return Omni.Signal:_Interpreter(true, nil, ...)
end

if isClient then
	function Omni.Signal.Invoke(_, ...)
		return table.unpack((v:InvokeServerAsync(table.pack(...))))
	end

	v:Connect(function(list)
		if typeof(list) ~= "table" then
			return
		end

		Omni.Signal:_Interpreter(false, nil, table.unpack(list))
	end)
end

if isServer then
	v:Connect(function(p, list)
		if typeof(list) ~= "table" then
			return
		end

		Omni.Signal:_Interpreter(false, p, table.unpack(list))
	end)

	v.OnServerInvoke = function(p, list)
		if typeof(list) ~= "table" then
			return table.pack()
		end

		local v2 = table.pack(pcall(Omni.Signal._Interpreter, Omni.Signal, true, p, table.unpack(list)))
		local success, result = pcall(Omni.Libs.DataContainerServer.FlushPlayer, p)

		if not success then
			warn((`[OMNI]: Signal invoke flush failed for {p.Name}: {result}`))
		end

		if v2[1] then
			return table.pack(table.unpack(v2, 2, v2.n))
		end

		warn((`[OMNI]: Signal invoke failed for {p.Name}: {v2[2]}`))
		return table.pack()
	end
end

if not isClient then
	return Omni
end

local localPlayer = Players.LocalPlayer
local Animate = require(script.Animate)
local ClientData = require(script.ClientData)
local v2 = {}
local v3 = {}
local v4 = {}
Omni.Instance = localPlayer
Omni.Inset = localPlayer.PlayerGui:WaitForChild("Inset", 1e999)
Omni.Interface = localPlayer.PlayerGui:WaitForChild("UI", 1e999)

function Omni.LoadData(_)
	if Omni.DataLoaded then
		Omni:Debug("The Player Data is already loaded!")
		return
	end

	local v5 = Omni.Libs.DataContainerClient.New("PlayerData")
	Omni.DataContainer = v5
	v5:WaitToBeReady()
	v5:OnChange({}, function(p, p2, p3)
		if not Omni.Utils.Multipliers.IsDataChangeRelevant(p3, p, p2) then
			return
		end

		Omni.Utils.Multipliers.Invalidate(localPlayer)
	end)
	Omni.Data = v5.Data
	Omni.DataLoaded = true
	ClientData.Data = v5.Data
	ClientData.Container = v5
	ClientData.Ready = true
end

function Omni.OnDataChanged(_, p, callback)
	if Omni.DataLoaded then
		return Omni.DataContainer:OnChange(p, callback)
	end

	Omni:Debug("The Player Data is not loaded yet!")
end

function Omni.OnDataChangedDeferred(_, p, callback, callback2)
	if not Omni.DataLoaded then
		Omni:Debug("The Player Data is not loaded yet!")
		return
	end

	if typeof(callback) ~= "function" then
		return
	end

	local v5 = {
		Callback = callback,
		Connected = true
	}
	v5.Connection = Omni.DataContainer:OnChange(p, function(p2, p3, p4)
		if not v5.Connected or p2 == p3 and p2 ~= nil and typeof(p2) ~= "table" or callback2 and not callback2(
			p2,
			p3,
			p4
		) then
			return
		end

		v3[v5] = true
	end)

	function v5:Disconnect()
		if not v5.Connected then
			return
		end

		v5.Connected = false
		v3[v5] = nil

		if v5.Connection then
			v5.Connection:Disconnect()
		end
	end

	return v5
end

function Omni.IsExpChange(_, list, p, p2)
	if typeof(list) ~= "table" or #list ~= 2 or list[1] ~= "List" then
		return false
	end

	if typeof(p) == "table" and typeof(p2) == "table" then
		return Omni.Utils.Table:IsEqual(p, p2, "Exp")
	end

	return false
end

function Omni:_SetupCharacterAnimate(instance)
	if Animate.Get(instance) then
		return
	end

	if not (instance:FindFirstChild("HumanoidRootPart") and instance:FindFirstChildOfClass("Humanoid")) then
		instance:WaitForChild("HumanoidRootPart", 10)
		instance:WaitForChild("Humanoid", 10)
	end

	if not instance.Parent or localPlayer.Character ~= instance or Animate.Get(instance) then
		return
	end

	local v5 = Animate.New(instance)

	if v5 then
		v5:LoadAnimationPack("Default")
	end
end

function Omni:_CharacterAdded(model)
	if not (model and model:IsA("Model")) then
		Omni:Debug("The Character is not valid!")
		return
	end

	if model:FindFirstChild("HumanoidRootPart") and model:FindFirstChildOfClass("Humanoid") then
		Omni:_SetupCharacterAnimate(model)
	else
		task.spawn(Omni._SetupCharacterAnimate, Omni, model)
	end

	task.defer(function()
		for _, sound in model:GetDescendants() do
			if sound:IsA("Sound") then
				sound:Destroy()
			end
		end
	end)

	for _, v5 in v2 do
		v5.Callback(model)
	end

	Omni.Cache.CurrentHRP = nil
	Omni.Cache.CurrentHumanoid = nil
end

function Omni.OnCharacterAdded(_, callback)
	if typeof(callback) ~= "function" then
		return
	end

	local v5 = {
		Callback = callback,
		ID = HttpService:GenerateGUID(false)
	}

	function v5:Disconnect()
		v2[v5.ID] = nil
	end

	v2[v5.ID] = v5

	if localPlayer.Character then
		callback(localPlayer.Character)
	end

	return v5
end

function Omni.GetCharacter(_)
	return Omni.Instance.Character
end

function Omni.GetHRP(_)
	if Omni.Cache.CurrentHRP then
		if Omni.Cache.CurrentHRP.Parent then
			return Omni.Cache.CurrentHRP
		else
			Omni.Cache.CurrentHRP = nil
		end
	end

	local character = Omni.Instance.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		Omni.Cache.CurrentHRP = humanoidRootPart
	end

	return humanoidRootPart
end

function Omni.GetHumanoid(_)
	if Omni.Cache.CurrentHumanoid then
		if Omni.Cache.CurrentHumanoid.Parent then
			return Omni.Cache.CurrentHumanoid
		else
			Omni.Cache.CurrentHumanoid = nil
		end
	end

	local character = Omni.Instance.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		Omni.Cache.CurrentHumanoid = humanoid
	end

	return humanoid
end

function Omni.GetAnimate(_, p)
	local v5 = p or Omni.Instance.Character

	if v5 then
		return Animate.Get(v5)
	end
end

RunService.Heartbeat:Connect(function()
	if not next(v3) then
		return
	end

	v3, v4 = v4, v3

	for k in v4 do
		if k.Connected then
			task.spawn(k.Callback)
		end
	end

	table.clear(v4)
end)
localPlayer.CharacterAdded:Connect(function(character)
	Omni:_CharacterAdded(character)
end)

if localPlayer.Character then
	Omni:_CharacterAdded(localPlayer.Character)
end

return Omni