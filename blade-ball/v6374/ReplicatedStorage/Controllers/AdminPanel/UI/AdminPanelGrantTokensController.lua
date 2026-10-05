local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Packages.Charm)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.DataViewer)
require3(ReplicatedStorage2.Shared.DeepCopy)
local actions = require3(ReplicatedStorage2.Shared.AdminPanel).Actions
require3(ReplicatedStorage2.Shared.AdminPanel.AdminPanelUtils)
local v3 = require3(ReplicatedStorage2.Controllers.PromptController)
local v4 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local contents = v4.AdminPanelUI.Window.Content.Pages.GrantTokens.Contents
return {
	Start = function(_)
		v4.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateTokens()
				contents.Current.Tokens.Amount.Text = `{v2.ValueConvertor:AddCommas(p.Replion:Get("Inventory.Tokens") or 0)} Tokens`
			end

			local function onLoad()
				updateTokens() -- equivalent call inferred; original call site unknown
				v4.UserTrove:Add(p.Replion:OnChange("Inventory.Tokens", updateTokens))
			end

			local flag = false
			v4.UserTrove:Add(contents.Buttons.Confirm.Activated:Connect(function()
				if flag then
					return
				end

				local text = tonumber(contents.Currency.Tokens.EnterAmount.Text)

				if not text then
					v4:PromptError("Invalid amount")
					return
				end

				if not v4:HasPermission("Inventory.GrantTokens") then
					v4:PromptError("Not enough permission to Grant Tokens")
					return
				end

				flag = true
				local v5 = (p.Replion:Get("Inventory.Tokens") or 0) + text
				local expect = v:GetUser(p.UserId):expect()
				local username = expect.Username

				if expect.DisplayName and expect.DisplayName ~= username then
					username = `{expect.DisplayName} (@{username})`
				end

				if expect.HasVerifiedBadge then
					username = " " .. username
				end

				v3:CreatePrompt({
					PromptType = "Accept",
					Description = `Are you sure you want to grant {v2.ValueConvertor:AddCommas(text)} Tokens to {username}? Final balance: {v2.ValueConvertor:AddCommas(v5)}`
				}, function(p2, p3: string?)
					if p2 then
						local v6, v7 = actions.Inventory.GrantTokens:Call(text)

						if not v6 and type(v7) == "string" then
							v4:PromptError(v7)
						end

						flag = false
					else
						flag = false

						if p3 then
							v4:PromptError(p3)
						end
					end
				end)
			end))
			v4.UserTrove:Add(contents.Buttons.Clear.Activated:Connect(function()
				contents.Currency.Tokens.EnterAmount.Text = ""
			end))
			v4.UserTrove:Add(contents.Currency.Tokens.EnterAmount:GetPropertyChangedSignal("Text"):Connect(function()
				local v5, v6 = string.match(contents.Currency.Tokens.EnterAmount.Text, "^(%-?)(%d*)")
				local v7 = v5 == "-"
				local v8 = tonumber(v6)

				if not v8 then
					contents.Currency.Tokens.EnterAmount.Text = v7 and "-" or ""
					return
				end

				local v9

				if v7 then
					v9 = math.round((math.min(v8, p.Replion:Get("Inventory.Tokens") or 0)))
				else
					v9 = math.round((math.min(v8, 25000)))
				end

				contents.Currency.Tokens.EnterAmount.Text = `{v7 and "-" or ""}{v9}`
			end))

			if replion:Get("Loaded") then
				v4.UserTrove:Add(task.spawn(onLoad))
			else
				contents.Current.Tokens.Amount.Text = "Loading..."
				v4.UserTrove:Add(p.Replion:OnChange("Loaded", onLoad))
			end
		end)
	end
}