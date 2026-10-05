local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local LiveEventController = {}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Trove)
local v3 = {}
local maid = v2.Maid.new()
local class = {}
class.__index = class

function LiveEventController:RunSession(childName: string, configuration, ...)
	if maid.RunningSession then
		warn("There is another session running, possible conflict inbound")
	end

	local v4 = { ... }
	local v5

	if typeof(configuration) == "Instance" then
		v5 = configuration:IsA("Configuration")
	else
		v5 = false
	end

	if configuration ~= nil and not v5 then
		table.insert(v4, 1, configuration)
		configuration = nil
	end

	local result = v3[childName]

	if not result then
		local moduleScript = script:FindFirstChild(childName)

		if moduleScript and moduleScript:IsA("ModuleScript") then
			local success
			success, result = pcall(require3, moduleScript)

			if success then
				v3[childName] = result
			else
				warn((`[LiveEventController] Failed to load session '{childName}': {result}`))
				v:RemoteEvent("PlayCinematicSession"):FireServer(childName, false)
				return
			end
		else
			warn((`[LiveEventController] Session '{childName}' was not found`))
			v:RemoteEvent("PlayCinematicSession"):FireServer(childName, false)
			return
		end
	end

	warn("[LiveEventController] Playing", childName)
	maid.RunningSession = result
	task.spawn(function()
		local maid2 = v2.Maid.new()
		local maid3 = v2.Maid.new()
		local skipCutscene = Players.LocalPlayer.PlayerGui:WaitForChild("SkipCutscene")

		if configuration then
			skipCutscene.Enabled = true
			maid2:GiveTask(v:RemoteEvent("SkipCinematicSession").OnClientEvent:Connect(function(p)
				if p ~= childName then
					return
				end

				maid3:Destroy()
			end))
			maid2:GiveTask(skipCutscene.Skip.MouseButton1Click:Connect(function()
				v:RemoteEvent("SkipCinematicSession"):FireServer(childName)
			end))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateCount()
				local requiredSkips = configuration:GetAttribute("RequiredSkips") or 0
				local skipped = configuration:GetAttribute("Skipped") or 0
				skipCutscene.Skip.Count.Label.Text = skipped .. "/" .. requiredSkips
			end

			maid2:GiveTask(configuration:GetAttributeChangedSignal("Skipped"):Connect(updateCount))
			maid2:GiveTask(configuration:GetAttributeChangedSignal("RequiredSkips"):Connect(updateCount))
			updateCount() -- equivalent call inferred; original call site unknown
		end

		local v6, v7 = xpcall(function()
			return result:Start(unpack(v4))
		end, debug.traceback)

		if not v6 then
			warn((`[LiveEventController] Session '{childName}' failed: {v7}`))
		end

		v:RemoteEvent("PlayCinematicSession"):FireServer(childName, v6, v7)
		skipCutscene.Enabled = false
		maid3:Destroy()
		maid2:Destroy()
		maid.RunningSession = nil
	end)
end

function LiveEventController:Start()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function hidePlayer(player)
		local character = player.Character
		local primaryPart

		if character then
			primaryPart = character.PrimaryPart
		end

		if primaryPart then
			primaryPart.Anchored = true

			if not character:GetAttribute("PlayerHidden") then
				character:SetAttribute("PlayerHidden", character:GetPivot())
			end
		end
	end

	local function showPlayers()
		for _, v4 in Players:GetPlayers() do
			local character = v4.Character
			local primaryPart

			if character then
				primaryPart = character.PrimaryPart
			end

			if not primaryPart then
				continue
			end

			local playerHidden = character:GetAttribute("PlayerHidden")

			if playerHidden then
				character:PivotTo(playerHidden)
				local humanoid = v4 == Players.LocalPlayer and character:FindFirstChildWhichIsA("Humanoid")

				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end

				character:SetAttribute("PlayerHidden", nil)
			end

			primaryPart.Anchored = false
		end
	end

	local remoteEvent = v:RemoteEvent("PlayCinematicSession")
	remoteEvent.OnClientEvent:Connect(function(p, ...)
		LiveEventController:RunSession(p, ...)

		while maid.RunningSession do
			for _, v4 in Players:GetPlayers() do
				hidePlayer(v4) -- equivalent call inferred; original call site unknown
				local character = v4.Character

				if character then
					character:PivotTo(CFrame.new(0, -50, 0))
				end
			end

			task.wait()
		end

		showPlayers()
	end)
	remoteEvent:FireServer("__Ready")
end

return LiveEventController