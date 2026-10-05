local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.DynArgs)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local actions = require3(ReplicatedStorage2.Shared.AdminPanel).Actions
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local v4 = require3(ReplicatedStorage2.Controllers.PromptController)
local moderation = v3.AdminPanelUI.Window.Content.Pages.Moderation
local categories = moderation.Categories
local v5 = {
	[true] = "rbxassetid://90233793140340",
	[false] = "rbxassetid://72030008231476"
}

local function observeReplionPath(object, p, callback)
	callback(object:Get(p), nil)
	return (object:OnDataChange(function()
		callback(object:Get(p), nil)
	end))
end

local flag = false
local flag2 = false
local AdminPanelModerationUIController = {}

function AdminPanelModerationUIController:ResetTradePIN()
	if flag then
		return
	end

	if not v3:HasPermission("Trade.ResetPIN") then
		v3:PromptError("Not enough permission to reset pin!")
		return
	end

	flag = true
	v4:CreatePrompt({
		PromptType = "Accept",
		Description = "Are you sure you want to reset the pin of this user?"
	}, function(p, p2: string?)
		if p then
			local v6, v7 = actions.Moderation.ResetTradePIN:Call()

			if not v6 and type(v7) == "string" then
				v3:PromptError(v7)
			end

			flag = false
		else
			flag = false

			if p2 then
				v3:PromptError(p2)
			end
		end
	end)
end

function AdminPanelModerationUIController:Start()
	local banOptions = categories.BanOptions

	-- equivalent calls inferred from this helper; original call sites unknown
	local function createCheckmark(checkmark, callback, p)
		local state = v.State(false)
		checkmark.Activated:Connect(function()
			local v6 = not state:Get()
			state:Set(v6)

			if type(callback) == "function" then
				callback(v6)
			else
				callback:Call(v6)
			end
		end)
		v.Computed(function(callback2)
			local v6 = callback2(state)
			checkmark.Image = v5[v6]
			checkmark.HoverImage = v5[not v6]
			return nil
		end)

		if p then
			v3.LoadUserAction.Signal:Connect(function(p2)
				local userTrove = v3.UserTrove
				local replion = p2.Replion
				local v6 = p

				-- equivalent calls inferred from this helper; original call sites unknown
				local function fn(p3)
					state:Set(p3 and true or false)
				end

				fn(replion:Get(v6)) -- equivalent call inferred; original call site unknown
				userTrove:Add((replion:OnDataChange(function()
					fn(replion:Get(v6), nil)
				end)))
			end)
		end
	end

	createCheckmark(banOptions.TradeBan.Checkmark, actions.Moderation.SetTradeBanned, "Data.TradeBanned")
	createCheckmark(banOptions.RankedBan.Checkmark, actions.Moderation.SetRankedBanned, "Data.RankedBanned")
	createCheckmark(
		banOptions.LeaderboardBan.Checkmark,
		actions.Moderation.SetLeaderboardBanned,
		"Data.LeaderboardBanned"
	)
	local banPopup = categories.BanPopup
	local v6 = {
		y = 31536000,
		mo = 2592000,
		d = 86400,
		h = 3600,
		min = 60,
		s = 1
	}
	v3.LoadUserAction.Signal:Connect(function(p)
		local state = v.State({
			Active = false
		})

		local function updateBanned()
			state:Set(p.Replion:Get("Data.Banned") or {
				Active = false
			})
		end

		if p.Replion:Get("Loaded") then
			v3.UserTrove:Add(task.spawn(updateBanned))
		else
			v3.UserTrove:Add(p.Replion:OnChange("Loaded", updateBanned))
		end

		v.Computed(function(callback)
			local v7 = callback(state)
			local active = v7.Active ~= false
			local v8

			if v7.Until then
				v8 = v2.ValueConvertor:FormatTime(v7.Until - v7.Timestamp)
			else
				v8 = type(v7.Active) ~= "number" and "Permanent" or v7.Active == 1e999 and "Permanent" or v2.ValueConvertor:FormatTime(v7.Active)
			end

			local v9

			if active then
				v9 = v7.Reason == "" and "No reason" or v7.Reason
			end

			banPopup.BanReason.TextBox.Interactable = not active
			banPopup.BanDuration.TextBox.Interactable = not active
			banPopup.Moderator.Interactable = not active
			banPopup.Moderator.Visible = active
			banPopup.Confirm.TextLabel.Text = active and "Confirm Unban" or "Confirm Ban"
			banPopup.BanReason.TextBox.Text = active and (v9 or "Unknown") or ""
			banPopup.BanDuration.TextBox.Text = not active and "" or v8
			banPopup.Moderator.TextBox.Text = not active and "" or v7.Moderator or "Unknown"
			categories.BanHeader.TextLabel.Text = active and "Game Unban" or "Game Ban"
			return nil
		end)
		v3.UserTrove:Add(banPopup.History.Activated:Connect(function()
			v3.CurrentPage:Set("Home.ModerationHistory")
		end))
		v3.UserTrove:Add(banPopup.Confirm.Activated:Connect(function()
			local active = state:Get().Active ~= false

			if flag2 then
				v3:PromptError("Processing request, please wait a bit!")
			elseif active then
				flag2 = true
				v4:CreatePrompt({
					PromptType = "Accept",
					Description = "Are you sure you want to unban this user?"
				}, function(p2, p3: string?)
					if p2 then
						if actions.Moderation.Unban:Call() then
							ReplicatedStorage2.Misc.reward:Play()
						else
							v3:PromptError("Failed to unban user!")
						end

						if v3._currentUserId then
							v3:LoadUser(v3._currentUserId)
						else
							v3:PromptError("Can't refresh: no UserId loaded!")
						end

						flag2 = false
					else
						flag2 = false

						if p3 then
							v3:PromptError(p3)
						end
					end
				end)
			else
				local text = banPopup.BanDuration.TextBox.Text
				local duration = tonumber(text)

				if not duration then
					duration = 0

					for k, v8 in text:gmatch("(%d+)(%a+)") do
						local v9 = v6[v8]

						if v9 then
							duration += v9 * k
						end
					end
				end

				flag2 = true
				local _ = #banPopup.BanReason.TextBox.Text > 0
				v4:CreatePrompt({
					PromptType = "Accept",
					Description = "Are you sure you want to ban this user?"
				}, function(p2, reason: string?)
					if p2 then
						actions.Moderation.Ban:Call({
							Duration = duration,
							Reason = reason
						})
						ReplicatedStorage2.Misc.reward:Play()

						if v3._currentUserId then
							v3:LoadUser(v3._currentUserId)
						else
							v3:PromptError("Can't refresh: no UserId loaded!")
						end

						flag2 = false
					else
						flag2 = false

						if reason then
							v3:PromptError(reason)
						end
					end
				end)
			end
		end))
	end)
	local leaderboardOptions = categories.LeaderboardOptions
	local v7 = {}

	for _, button in leaderboardOptions:GetChildren() do
		if not (button:IsA("GuiButton") and button:FindFirstChild("Checkmark")) then
			continue
		end

		local v8 = button

		local function fn(p)
			v7[v8.Name] = p and true or nil
		end

		createCheckmark(button.Checkmark, fn, false) -- equivalent call inferred; original call site unknown
	end

	leaderboardOptions.WipeData.Activated:Connect(function()
		actions.Moderation.WipeLeaderboards:Call(v7)
	end)
	local state = v.State(0)
	v3.LoadUserAction.Signal:Connect(function(p)
		local userTrove = v3.UserTrove
		local replion = p.Replion

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn(value)
			state:Set(value or 0)
		end

		fn(replion:Get("Inventory.TradePINResetsByModerators")) -- equivalent call inferred; original call site unknown
		local v9 = "Inventory.TradePINResetsByModerators"
		userTrove:Add((replion:OnDataChange(function()
			fn(replion:Get(v9), nil)
		end)))
	end)
	moderation.Options.ResetTradePIN.Activated:Connect(function()
		self:ResetTradePIN()
	end)
	v.Computed(function(callback)
		local v8 = callback(state)
		moderation.Options.ResetTradePIN.Amount.Text = `{v8} Resets`
		return nil
	end)
end

return AdminPanelModerationUIController