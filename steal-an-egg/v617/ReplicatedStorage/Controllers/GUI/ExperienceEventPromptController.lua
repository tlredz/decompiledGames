local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Shared.Globals.Constants)
local ExpandedLobby = require(ReplicatedStorage.Data.ExpandedLobby)
local ExperienceEventPromptPolicy = require(ReplicatedStorage.Shared.Modules.ExperienceEventPromptPolicy)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Timer = require(ReplicatedStorage.Packages.Timer)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local maid = Trove.new()
local v = {}
local fn
local fn2
local fn3
local v2 = false
local v3 = false
local flag = false
local count = 0
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function IsExpandedLobbyServer()
			return Workspace:GetAttribute(ExpandedLobby.ServerAttribute) == ExpandedLobby.Groups.Variant
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function IsInSafeArea()
			if Player.FindRootPart(localPlayer) then
				return ExperienceEventPromptPolicy.IsSafeToPrompt(true, ToolGameplayGuard.IsLocalInsideArena())
			end

			return false
		end

		local function GetSoonestUnseenEvent()
			local success, result = pcall(function()
				return SocialService:GetUpcomingExperienceEventsAsync()
			end)

			if success and type(result) == "table" then
				return ExperienceEventPromptPolicy.GetSoonestUnseenEvent(result, v), true
			end

			if not success then
				warn((`Failed to get upcoming experience events: {result}`))
			end

			return nil, false
		end

		local function MarkSeen(id: string)
			v[id] = true
			local success, result = pcall(function()
				return Remotes.SeasonBanner.FlagSeen:InvokeServer(id)
			end)

			if not success then
				warn((`Failed to mark experience event prompt as seen: {result}`))
			elseif result ~= true then
				warn((`Server rejected experience event prompt acknowledgement for {id}`))
			end
		end

		local function PromptSoonestEvent()
			local v4, v5 = GetSoonestUnseenEvent()

			if not (v5 and v4) then
				return "Retry"
			end

			local success, eventRsvpStatusAsync = pcall(SocialService.GetEventRsvpStatusAsync, SocialService, v4.Id)

			if not success then
				warn((`Failed to get experience event RSVP status: {eventRsvpStatusAsync}`))
				return "Retry"
			end

			if eventRsvpStatusAsync ~= Enum.RsvpStatus.None then
				MarkSeen(v4.Id)
				return "Complete"
			end

			-- equivalent call inferred; original call site unknown
			if not IsInSafeArea() then
				return "WaitForSafeArea"
			end

			local success2, result = pcall(SocialService.PromptRsvpToEventAsync, SocialService, v4.Id)

			if success2 then
				MarkSeen(v4.Id)
				return "Complete"
			end

			warn((`Failed to prompt for experience event RSVP: {result}`))
			return "Retry"
		end

		local v4 = maid:Add(Timer.new(0.1))
		local v5 = maid:Add(Timer.new(ExperienceEventPromptPolicy.RetryDelaySeconds))

		fn = function()
			if not v4:IsRunning() then
				v4:Start()
			end
		end

		fn2 = function()
			count += 1

			if count >= ExperienceEventPromptPolicy.MaxAttempts then
				warn((`Experience event prompt stopped after {count} failed attempts`))
			elseif not v5:IsRunning() then
				v5:Start()
			end
		end

		fn3 = function()
			if flag then
				return
			end

			flag = true

			if not v2 then
				local success, result, v6 = pcall(function()
					return Remotes.SeasonBanner.FetchState:InvokeServer()
				end)

				if success and type(result) == "boolean" and type(v6) == "table" then
					v2 = true
					v3 = result
					count = 0

					for k, v7 in v6 do
						if type(k) == "string" and v7 == true then
							v[k] = true
						end
					end
				else
					if not success then
						warn((`Failed to get experience event prompt state: {result}`))
					end

					flag = false
					fn2()
					return
				end
			end

			if not v3 then
				flag = false
				return
			end

			if IsExpandedLobbyServer() then
				flag = false
				return
			end

			-- equivalent call inferred; original call site unknown
			if IsInSafeArea() then
				local promptSoonestEvent = PromptSoonestEvent()
				flag = false

				if promptSoonestEvent == "Retry" then
					fn2()
				elseif promptSoonestEvent == "WaitForSafeArea" then
					fn()
				end
			else
				flag = false
				fn()
			end
		end

		maid:Connect(v4.Tick, function()
			-- equivalent call inferred; original call site unknown
			if not IsInSafeArea() then
				return
			end

			v4:Stop()
			fn3()
		end)
		maid:Connect(v5.Tick, function()
			v5:Stop()
			fn3()
		end)
		local v6 = maid:Add(Timer.new(ExperienceEventPromptPolicy.PromptDelaySeconds))
		maid:Connect(v6.Tick, function()
			v6:Stop()
			fn3()
		end)
		maid:AttachToInstance(script)
		v6:Start()
	end
}