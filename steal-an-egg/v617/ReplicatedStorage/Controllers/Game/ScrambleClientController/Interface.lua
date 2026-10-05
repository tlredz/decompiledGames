local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local AssetViewport = require(ReplicatedStorage.Client.AssetViewport)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ScrambleRules = require(ReplicatedStorage.Shared.Util.ScrambleRules)
local parts = ReplicatedStorage.Assets.Models.Scramble.Parts
local color = Color3.new()
local color2 = Color3.new(1, 1, 1)

local function countdown(p: number)
	local v = math.max(0, (math.ceil(p)))
	local v2 = v // 86400
	local v3 = v % 86400 // 3600
	local v4 = v % 3600 // 60

	if v2 > 0 then
		return string.format("%dd %dhr %dm", v2, v3, v4)
	end

	if v3 > 0 then
		return string.format("%dhr %dm", v3, v4)
	end

	if v4 > 0 then
		return string.format("%dm %ds", v4, v % 60)
	end

	return tostring(v) .. "s"
end

return {
	new = function(callback)
		local maid = Trove.new()
		local stolenVaultEvent = GUI.Get("StolenVaultEvent")
		local stolenVaultEventUIMain = stolenVaultEvent:WaitForChild("StolenVaultEventUIMain")
		local contentFrame = stolenVaultEventUIMain.ContentFrame
		local requirementsHolder = contentFrame.RequirementsHolder
		local template_Unlocked = requirementsHolder.Template_Unlocked
		local template_Locked = requirementsHolder.Template_Locked
		local claim = contentFrame.Claim
		local vaultInComplete = contentFrame.VaultInComplete
		stolenVaultEvent:SetAttribute("ImmediateClose", true)
		stolenVaultEvent.Enabled = false
		local v = {}
		local v2 = nil
		local flag = false
		local fn
		local flag2 = true
		local v3 = {}

		for _, guiObject in requirementsHolder:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		local position = claim.Position
		local size = claim.Size
		vaultInComplete.Position = position
		vaultInComplete.Size = size
		vaultInComplete.Active = false
		vaultInComplete.Interactable = false
		vaultInComplete.Selectable = false

		local function buildCards()
			if #v > 0 then
				return
			end

			for k, childName in ScrambleRules.PART_IDS do
				local clone = template_Unlocked:Clone()
				clone.Name = childName
				clone.LayoutOrder = k
				clone.Visible = true
				clone.Parent = requirementsHolder
				maid:Add(clone)
				local icon = clone.Icon
				local view = AssetViewport.Mount(clone)
				local zIndex = icon.ZIndex
				view.Name = "PartViewport"
				view.ZIndex = zIndex
				local position2 = icon.Position
				local size2 = icon.Size
				local anchorPoint = icon.AnchorPoint
				view.Position = position2
				view.Size = size2
				view.AnchorPoint = anchorPoint
				icon:Destroy()
				local model = parts:FindFirstChild(childName)

				if model and model:IsA("Model") then
					maid:Add((AssetViewport.ShowModel(model, view)))
				else
					warn("[Scramble UI] Missing part viewport model: " .. childName)
				end

				table.insert(v, {
					Id = childName,
					Index = k,
					Card = clone,
					View = view,
					Ambient = view.Ambient,
					LightColor = view.LightColor,
					Owned = nil
				})
			end
		end

		local function paintCard(state, flag3: boolean)
			if state.Owned == flag3 then
				return
			end

			state.Owned = flag3
			local card = state.Card
			local view = state.View
			local v4

			if flag3 then
				v4 = template_Unlocked
			else
				v4 = template_Locked
			end

			local ambient

			if flag3 then
				ambient = state.Ambient
			else
				ambient = color
			end

			view.Ambient = ambient
			local lightColor

			if flag3 then
				lightColor = state.LightColor
			else
				lightColor = color
			end

			view.LightColor = lightColor
			local imageColor

			if flag3 then
				imageColor = color2
			else
				imageColor = color
			end

			view.ImageColor3 = imageColor
			card.InnerUIStroke.Color = v4.InnerUIStroke.Color
			card.UIShadow.Color = v4.UIShadow.Color
			local uIGradient = card.InnerUIStroke:FindFirstChildOfClass("UIGradient")

			if uIGradient then
				uIGradient.Enabled = flag3
			end

			card.CompletedCheckmark.Visible = flag3
			local itemName = card.ItemName
			local text

			if flag3 then
				if state.Index <= 2 then
					text = "Lost Part " .. state.Index
				else
					text = "Drone Part " .. state.Index - 2
				end
			else
				text = "???"
			end

			itemName.Text = text
		end

		local function available(p: number)
			local enabled

			if v2 == nil then
				enabled = false
			else
				enabled = v2.Ready and v2.Enabled

				if enabled then
					if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
						enabled = p < v2.EventEndsAt
					else
						enabled = false
					end
				end
			end

			return enabled
		end

		local function canClaim()
			local serverTimeNow = workspace:GetServerTimeNow()
			local enabled

			if v2 == nil then
				enabled = false
			else
				enabled = v2.Ready and v2.Enabled

				if enabled then
					if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
						enabled = serverTimeNow < v2.EventEndsAt
					else
						enabled = false
					end
				end
			end

			local v4 = enabled and v2.State.Discovered and not v2.State.Completed

			if v4 then
				if v2.State.TotalParts == 5 then
					return v2.VaultRewardReady and not flag
				else
					return false
				end
			end

			return v4
		end

		local function send(p: string, p2)
			if flag then
				return nil
			end

			flag = true
			fn()
			local success, result = pcall(callback, p, p2)
			flag = false

			if flag2 then
				fn()
			end

			if success then
				return result
			end

			warn("[Scramble UI] Request failed: " .. tostring(result))
			return nil
		end

		maid:Add(ButtonFX(claim, nil, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local enabled

			if v2 == nil then
				enabled = false
			else
				enabled = v2.Ready and v2.Enabled

				if enabled then
					if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
						enabled = serverTimeNow < v2.EventEndsAt
					else
						enabled = false
					end
				end
			end

			local v4 = enabled and v2.State.Discovered and not v2.State.Completed

			if v4 then
				if v2.State.TotalParts == 5 then
					v4 = v2.VaultRewardReady and not flag
				else
					v4 = false
				end
			end

			if v4 then
				v3.Close()
				local result

				if not flag then
					flag = true
					fn()
					local success
					success, result = pcall(callback, "Vault", nil)
					flag = false

					if flag2 then
						fn()
					end

					if not success then
						warn("[Scramble UI] Request failed: " .. tostring(result))
						result = nil
					end
				end

				if flag2 and not (result and result.Ok) then
					v3.ShowVault()
				end
			end
		end))
		maid:Add(Tabs.Activated:Connect(function(p)
			if p == "StolenVaultEvent" then
				fn()
			end
		end))

		local function fn2()
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local viewportSize = currentCamera.ViewportSize
			local aspectRatio = stolenVaultEventUIMain.UIAspectRatioConstraint.AspectRatio
			local v4 = math.max(
				1,
				(math.min(
					math.max(477, (math.min(viewportSize.X * 0.62, viewportSize.Y * 0.75 * aspectRatio))),
					viewportSize.X - 32,
					viewportSize.Y * 0.78 * aspectRatio
				))
			)
			stolenVaultEventUIMain.UISizeConstraint.MinSize = Vector2.zero
			stolenVaultEventUIMain.Size = UDim2.fromOffset(v4, v4 / aspectRatio)
		end

		fn = function()
			if not flag2 then
				return
			end

			fn2()

			if not (v2 and v2.Ready and v2.State) then
				return
			end

			local state = v2.State
			contentFrame.LostParts.ProgressLabel.Text = tostring((state.LostParts.LostPart1 and 1 or 0) + (state.LostParts.LostPart2 and 1 or 0)) .. " / 2"
			contentFrame.DroneParts.ProgressLabel.Text = tostring(state.DroneParts) .. " / 3"
			local v4 = math.max(0, 5 - state.TotalParts)
			stolenVaultEventUIMain.SubTitle.Text = state.Completed and "The vault is repaired. Your reward has been claimed!" or v4 == 0 and "All <font color=\"#FFD83D\">5 parts</font> found! Repair the vault and claim your reward." or "The vault is damaged and missing <font color=\"#FFD83D\">" .. v4 .. (v4 == 1 and " part" or " parts") .. "</font>"
			local serverTimeNow = workspace:GetServerTimeNow()
			local enabled

			if v2 == nil then
				enabled = false
			else
				enabled = v2.Ready and v2.Enabled

				if enabled then
					if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
						enabled = serverTimeNow < v2.EventEndsAt
					else
						enabled = false
					end
				end
			end

			local vaultRewardReady = enabled and state.Discovered and not state.Completed

			if vaultRewardReady then
				if v4 == 0 then
					vaultRewardReady = v2.VaultRewardReady
				else
					vaultRewardReady = false
				end
			end

			local vaultInComplete2 = vaultInComplete
			claim.Visible = vaultRewardReady
			vaultInComplete2.Visible = not vaultRewardReady
			local claim2 = claim
			local claim3 = claim
			local interactable = vaultRewardReady and not flag
			local selectable = vaultRewardReady and not flag
			claim.Active = vaultRewardReady and not flag
			claim2.Interactable = interactable
			claim3.Selectable = selectable
			claim.txt.Text = flag and "Claiming..." or "Claim"
			local txt = vaultInComplete.txt
			local text

			if state.Completed then
				text = "Claimed"
			else
				local serverTimeNow2 = workspace:GetServerTimeNow()
				local enabled2

				if v2 == nil then
					enabled2 = false
				else
					enabled2 = v2.Ready and v2.Enabled

					if enabled2 then
						if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
							enabled2 = serverTimeNow2 < v2.EventEndsAt
						else
							enabled2 = false
						end
					end
				end

				text = not enabled2 and "Event ended" or v2.VaultRewardReady and "Vault incomplete" or "Reward unavailable"
			end

			txt.Text = text

			if stolenVaultEvent.Enabled then
				buildCards()

				for _, v11 in v do
					local v12

					if v11.Index <= 2 then
						v12 = state.LostParts[v11.Id] == true
					else
						v12 = state.DroneParts >= v11.Index - 2
					end

					paintCard(v11, v12)
				end
			end

			v3.Tick(workspace:GetServerTimeNow())
		end

		function v3.Update(p)
			v2 = p
			local serverTimeNow = workspace:GetServerTimeNow()
			local enabled

			if v2 == nil then
				enabled = false
			else
				enabled = v2.Ready and v2.Enabled

				if enabled then
					if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
						enabled = serverTimeNow < v2.EventEndsAt
					else
						enabled = false
					end
				end
			end

			if not enabled then
				v3.Close()
			end

			fn()
		end

		function v3.ShowVault()
			local serverTimeNow = workspace:GetServerTimeNow()
			local enabled

			if v2 == nil then
				enabled = false
			else
				enabled = v2.Ready and v2.Enabled

				if enabled then
					if v2.WorldReady == true and type(v2.EventEndsAt) == "number" then
						enabled = serverTimeNow < v2.EventEndsAt
					else
						enabled = false
					end
				end
			end

			if enabled and v2.State.Discovered then
				Tabs.Activate("StolenVaultEvent")
				fn()
			end
		end

		function v3.Close()
			if Tabs.IsActive("StolenVaultEvent") then
				Tabs.Deactivate()
			end
		end

		function v3.Tick(p: number)
			if not (v2 and stolenVaultEvent.Enabled) then
				return
			end

			local v4 = math.max(0, (v2.EventEndsAt or 0) - p)
			local text = not (v4 > 0) and "Event ended" or countdown(v4)

			if contentFrame.Timer.Text ~= text then
				contentFrame.Timer.Text = text
			end

			if v4 <= 0 then
				v3.Close()
			end
		end

		if workspace.CurrentCamera then
			maid:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn2))
		end

		fn2()

		function v3.Destroy()
			flag2 = false
			maid:Destroy()
		end

		return v3
	end
}