local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local eventControllers = script:WaitForChild("EventControllers")
local v3 = {}

function LoadEventControllers()
	if #v3 == 0 then
		for _, moduleScript in ipairs((eventControllers:GetChildren())) do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local scriptSource = require3(moduleScript)
			table.insert(v3, {
				Name = moduleScript.Name,
				ScriptSource = scriptSource,
				_Initialized = false,
				_Started = false
			})
		end
	end

	for _, v4 in ipairs(v3) do
		if v4._Initialized or not v4.ScriptSource or not v4.ScriptSource.Init or typeof(v4.ScriptSource.Init) ~= "function" then
			continue
		end

		v4._Initialized = true
		v4.ScriptSource:Init()
	end

	for _, v4 in ipairs(v3) do
		if v4._Started or not v4.ScriptSource or not v4.ScriptSource.Start or typeof(v4.ScriptSource.Start) ~= "function" then
			continue
		end

		v4._Started = true
		task.spawn(v4.ScriptSource.Start, v4.ScriptSource)
	end
end

function EventEnded(object)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v4 = object:Get("WelcomeBackEvent.EventEndTime")

	if v4 then
		return not (serverTimeNow < v4)
	end

	return false
end

local WelcomeBackController = {}

function WelcomeBackController.Start(_)
	if v2.isRankedMatchServer() or v2.isDuelMatchServer() or v2.isTournamentMatchServer() or v2.isDungeonsMatchServer() or v2.isDungeonsLobbyServer() or v2.isTradingPlazaServer() or v2.isTrainingServer() or v2.isTutorialServer() or v2.isHuntPrivateServer() then
		return
	end

	task.wait(4)
	local v4 = v.Client:WaitReplion("Data")

	if not EventEnded(v4) then
		LoadEventControllers()
		return
	end

	local connection = nil
	connection = v4:OnChange("WelcomeBackEvent", function(p)
		if p then
			connection:Disconnect()

			if not EventEnded(v4) then
				LoadEventControllers()
			end
		end
	end)
end

function WelcomeBackController.GetEventController(_, p: string)
	for _, v4 in ipairs(v3) do
		if v4.Name == p then
			return v4.ScriptSource
		end
	end
end

return WelcomeBackController