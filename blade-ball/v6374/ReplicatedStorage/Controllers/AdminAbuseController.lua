local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local v = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Packages.Observers)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Packages.Promise)
local v6 = require3(ReplicatedStorage2.Packages.Trove)
local localPlayer = Players.LocalPlayer
local adminAbuse = localPlayer.PlayerGui:WaitForChild("AdminAbuse")
return {
	Start = function(p)
		local main = adminAbuse.Frame.Main
		task.spawn(function()
			local v7, v8 = v5.retryWithDelay(
				PolicyService.GetPolicyInfoForPlayerAsync,
				3,
				2,
				PolicyService,
				localPlayer
			):await()

			if v7 and v8 and v8.AllowedExternalLinkReferences and table.find(
				v8.AllowedExternalLinkReferences,
				"Discord"
			) then
				main.Info.Text = [[
Join the Discord server to get leaks and learn more: https://discord.gg/bladeball

Click below to get notified for this event.]]
			end
		end)
		main.Close.Activated:Connect(function()
			v2:Close("AdminAbuse")
		end)
		v3.observeTag("AdminAbuseNPC", function(folder)
			local maid = v6.new()

			local function updateAdminAbuseNPC()
				folder:SetAttribute("EndTime", (v4.FFlag.GetFFlag("AdminAbuseEndTimestamp", 1758384000)))
			end

			task.defer(updateAdminAbuseNPC)
			maid:Add(v4.FFlag.OnChange(updateAdminAbuseNPC))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function udpateInstance(sound)
				if sound:IsA("Sound") then
					sound.Volume = math.min(sound.Volume, 0.1)
					sound.RollOffMinDistance = 10
					sound.RollOffMaxDistance = 30
				end
			end

			for _, descendant in folder:GetDescendants() do
				udpateInstance(descendant) -- equivalent call inferred; original call site unknown
			end

			maid:Add(folder.DescendantAdded:Connect(udpateInstance))
			return function()
				maid:Destroy()
			end
		end)
		v3.observeTag("AdminAbuseTimer", function(p2)
			local function updateAdminAbuseNPC()
				local serverTimeNow = workspace:GetServerTimeNow()
				local fFlag = v4.FFlag.GetFFlag("AdminAbuseEndTimestamp", 1758384000)
				local v7 = fFlag - v4.FFlag.GetFFlag("AdminAbuseEventDuration", 900)

				if serverTimeNow < v7 then
					p2.Text = v4.ValueConvertor:FormatTimeWithDaysFull(v7 - serverTimeNow)
				elseif v7 < serverTimeNow and serverTimeNow < fFlag then
					p2.Text = "NOW"
				end
			end

			local connection = v4.Thread.Every(1, updateAdminAbuseNPC)
			return function()
				connection:Disconnect()
				connection = nil
			end
		end)
		task.spawn(function()
			p.EventID = string.gsub(tostring(v:GetKey("AdminAbuseEventID")), "EVENT", "")
			local _, result = pcall(function()
				return SocialService:GetEventRsvpStatusAsync(p.EventID)
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function confirmStatus(result2)
				if result2 ~= Enum.RsvpStatus.Going then
					return false
				end

				main.Signup.Info.Text = "Joined Event!"
				main.Signup.Active = false
				return true
			end

			main.Signup.Activated:Connect(function()
				-- equivalent call inferred; original call site unknown
				if confirmStatus(result) or SocialService:PromptRsvpToEventAsync(p.EventID) ~= Enum.RsvpStatus.Going then
					return
				end

				main.Signup.Info.Text = "Joined Event!"
				main.Signup.Active = false
			end)
		end)
	end
}