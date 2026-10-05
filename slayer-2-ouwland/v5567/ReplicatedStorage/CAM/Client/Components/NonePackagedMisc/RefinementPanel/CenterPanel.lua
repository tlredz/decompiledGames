local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
local TransferPair = require(ReplicatedStorage.CAM.Client.Components.Misc.TransferPair)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local GuardToggle = require(script.Parent.GuardToggle)
local ItemViewport = require(script.Parent.ItemViewport)
local LevelTrack = require(script.Parent.LevelTrack)
local MaterialSlot = require(script.Parent.MaterialSlot)
local OddsBar = require(script.Parent.OddsBar)
local RefineButton = require(script.Parent.RefineButton)
local RefineCeremony = require(script.Parent.RefineCeremony)
require(script.Parent.Types)
local info = faye.Info(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local info2 = faye.Info(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color = Color3.new(1, 0.803922, 0.305882)
local color2 = Color3.new(1, 1, 1)
local v = {
	Hero = 0.22,
	Name = 0.044,
	LevelStep = 0.048,
	Track = 0.053,
	Odds = 0.137,
	Materials = 0.206,
	Guard = 0.084,
	Button = 0.106,
	Pair = 0.401
}
local v2 = {
	Hero = 0.155,
	Name = 0.045,
	LevelStep = 0.055,
	Odds = 0.185,
	Materials = 0.22,
	Guard = 0.105,
	Button = 0.15,
	Pair = 0.279
}
local v3 = { "Refine", "Transfer" }
local localPlayer = Players.LocalPlayer
return function(object, state)
	local v4 = Platform_Handler.Platform.Value == "Mobile"
	local v5

	if v4 then
		v5 = v2
	else
		v5 = v
	end

	local v6 = v4 and 0.07 or 0.045
	local data = state.Data
	local charging = object:Value(false)
	local reason = object:Value("")
	local v7 = simplesignal.new()
	local v8 = 0
	local v9 = 0
	local v10 = nil
	local v11 = false
	local v12 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function commit(p)
		object:Spawn(function()
			state.Busy:Set(true)
			local v13 = nil
			local v14 = false
			task.spawn(function()
				local success, result = pcall(SignalFunction.ToServer, "RefinementRequest", p)

				if not success then
					result = nil
				end

				v13 = result
				v14 = true
			end)
			local sound = RefineCeremony.Sound("Charge")
			charging:Set(true)
			state.Dim:Set(0.45)
			local lastTime = os.clock()
			v11 = false
			v12 = lastTime + 0.16

			repeat
				task.wait()
			until v14 and (v11 or os.clock() - lastTime >= RefineCeremony.CHARGE_TIME)

			if sound ~= nil then
				sound:Destroy()
			end

			charging:Set(false)

			if typeof(v13) == "table" and v13.Ok == true then
				v7:Fire("Strike")
				task.wait(RefineCeremony.STRIKE_TIME)
				state.Busy:Set(false)
				state.update()
				state.Dim:Reset()
				v7:Fire(v13.GuardSaved == true and "Guarded" or v13.Outcome)
			else
				state.Busy:Set(false)
				state.Dim:Reset()
				local clone = ReplicatedStorage.Assets.Sounds.Misc.denied_old:Clone()
				clone.Parent = script
				clone:Play()
				DebrisModule:AddItem(clone, clone.TimeLength)

				if typeof(v13) == "table" and typeof(v13.Reason) == "string" then
					reason:Set(v13.Reason)
					task.delay(1.2, reason.Reset, reason)
				end
			end
		end)
	end

	local state2 = object:State(function(callback, object2)
		local v13 = callback(state.Selected)
		local v14 = callback(state.Mode) == "Transfer"
		local to = not v14 and 0 or callback(state.Target)
		local v16

		if v13 ~= 0 then
			v16 = Character_info_provider.GetItemFromId(localPlayer, v13)
		end

		if v16 == nil then
			return object2:Create("Frame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				object2:Create("TextLabel")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(0.8, 0.08),
					BackgroundTransparency = 1,
					Text = v14 and "Pick an item to transfer from." or "Pick something to refine.",
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = color2,
					TextTransparency = 0.5
				})
			})
		end

		local name = v16.Name
		local v17 = ItemModels.Get(name) ~= nil
		local rarity = Items[name].Rarity or 1
		local color3 = Rarities.Colors[rarity]
		local refineLevel = v16:FindFirstChild("RefineLevel")
		local v18 = refineLevel == nil and 0 or refineLevel.Value
		local v19 = Refinement.MaxLevel <= v18
		local v20

		if v14 then
			v20 = Refinement.GetTransfer(v18)
		else
			v20 = Refinement.GetRung(v18)
		end

		local v21

		if to == 0 then
			v21 = nil
		else
			v21 = Character_info_provider.GetItemFromId(localPlayer, to)
		end

		local refineLevel2

		if v21 ~= nil then
			refineLevel2 = v21:FindFirstChild("RefineLevel")
		end

		local v22 = refineLevel2 == nil and 0 or refineLevel2.Value
		local v23

		if v13 == v8 then
			v23 = v9
		else
			v23 = v18
		end

		v8 = v13
		v9 = v18

		if v20 == nil then
			v10 = nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function oddsFor(flag: boolean)
			if not v14 then
				return Refinement.GetRung(v18, flag)
			end

			local successBp = flag and 10000 or v20.SuccessBp
			return {
				FailBp = 10000 - successBp,
				SuccessBp = successBp,
				GreatBp = 0
			}
		end

		local v24

		if refineLevel == nil then
			v24 = v16.ChildAdded
		else
			v24 = refineLevel.Changed
		end

		object2:Connect(v24, state.update)
		object2:Connect(data.Wen.Changed, state.update)
		local v25, v26, v27

		if v20 == nil then
			v25 = {}
			v26 = 0
			v27 = 0
		else
			v25, v26 = Refinement.ResolveOreCost(data, v20)
			v27 = Shop.PricedFor(nil, "Wen", v20.Wen, 1)
		end

		local short

		if v20 == nil then
			short = false
		else
			short = not Shop.cashiers.Wen.CanBuy(data, v27)
		end

		local short2 = false

		for k, v30 in v25 do
			if not Shop.cashiers[k].CanBuy(data, v30) then
				short2 = true
			end
		end

		local enabled

		if v20 == nil then
			enabled = false
		else
			enabled = not (short or short2) and (not v14 or v21 ~= nil)
		end

		local heldCount = Refinement.GetHeldCount(data, Refinement.GuardItem)

		if heldCount < 1 then
			state.UseGuard = false
		end

		local v31 = (not v14 or v20 == nil) and 1 or v20.Guards
		local value3 = object2:Value(state.UseGuard and v31 <= heldCount)
		local v32 = v20 == nil and 0 or Refinement.GetHeldCount(data, v20.Ore)
		local v33 = not (v26 > 0) and 0 or math.floor(Refinement.GetHeldCount(data, Refinement.SmeltRate.From) / Refinement.SmeltRate.FromCount)
		local v34 = object2:Create("Frame")
		local v35 = {
			Name = "Rows",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}
		local v36 = object2:Create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.012, 0)
		})
		local v37 = object2:Create("Frame")
		local v40

		if v14 then
			v40 = v5.Pair
		else
			v40 = v5.Hero
		end

		local v38 = {
			Name = "HeroSlot",
			LayoutOrder = 2,
			ZIndex = 2,
			Size = UDim2.fromScale(1, v40),
			BackgroundTransparency = 1
		}
		local v41

		if v4 and not v14 then
			v41 = object2:Create("UIPadding")({
				PaddingBottom = UDim.new(0.2, 0)
			})
		end

		local v42

		if v14 then
			v42 = TransferPair(object2, {
				Name = name,
				Now = `+{v18}`,
				After = v21 == nil and "?" or `+{v22}`,
				Gains = false
			}, v21 ~= nil and {
				Name = v21.Name,
				Now = `+{v22}`,
				After = `+{v18}`,
				Gains = true
			} or nil, v20 == nil and "Nothing to move" or "Pick a Target")
		else
			local v43 = object2:Create("Frame")
			local v44 = {
				Name = "Hero",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
				BackgroundTransparency = 0.15
			}
			local v45 = object2:Create("UICorner")({
				CornerRadius = UDim.new(0.12)
			})
			local v46 = object2:Create("UIStroke")
			local v47 = {
				BorderOffset = UDim.new(0, 5),
				Color = 0,
				Thickness = 0,
				Transparency = 0
			}
			local color4

			if v19 then
				color4 = color
			else
				color4 = color3
			end

			v47.Color = color4
			v47.Thickness = not v19 and 1.5 or object2:Animation(3, info, {
				From = 2
			})
			v47.Transparency = not v19 and 0.3 or object2:Animation(0, info, {
				From = 0.3
			})
			do local _values = table.pack(v45, v46(v47), object2:State(function(callback2, object3)
	if callback2(charging) then
		return object3:Create("UIScale")({
			Scale = object3:Animation(1.06, info2, {
				From = 1
			})
		})
	end

	return nil
end), object2:Create("ImageLabel")({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.9),
	BackgroundTransparency = 1,
	Image = ItemIcon.For(localPlayer, name),
	ImageTransparency = v17 and 0.6 or 0
}), ItemViewport(object2, name)); for _k = 1, _values.n do v44[1 + _k] = _values[_k] end end
			v42 = v43(v44)
		end

		do local _values = table.pack(v41, v42, RefineCeremony.Stage(object2, charging, v7)); for _k = 1, _values.n do v38[_k] = _values[_k] end end
		local v43 = v37(v38)
		local v44

		if not v14 then
			local v45 = object2:Create("TextLabel")
			local v46 = {
				LayoutOrder = 3,
				Size = UDim2.fromScale(1, v5.Name),
				BackgroundTransparency = 1,
				Text = name,
				TextScaled = true,
				Font = Enum.Font.SourceSansBold
			}

			if rarity >= 6 then
				color3 = color3:Lerp(color2, 0.4)
			end

			v46.TextColor3 = color3
			do local _values = table.pack(object2:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.4
})); for _k = 1, _values.n do v46[_k] = _values[_k] end end
			v44 = v45(v46)
		end

		local v45

		if not v14 then
			v45 = object2:Create("Frame")({
				Name = "LevelStep",
				LayoutOrder = 4,
				Size = UDim2.fromScale(1, v5.LevelStep),
				BackgroundTransparency = 1,
				object2:Create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0.015, 0)
				}),
				function()
					if v20 == nil then
						return object2:Create("TextLabel")({
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = "Fully refined",
							TextScaled = true,
							Font = Enum.Font.SourceSansSemibold,
							TextColor3 = color
						})
					end

					return { object2:Create("TextLabel")({
							Name = "From",
							LayoutOrder = 1,
							Size = UDim2.fromScale(0.36, 0.78),
							BackgroundTransparency = 1,
							Text = `Level {v18}`,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Right,
							Font = Enum.Font.SourceSansSemibold,
							TextColor3 = color2,
							TextTransparency = 0.35,
							object2:Create("UIStroke")({
								Thickness = 1.5,
								Transparency = 0.4
							})
						}), object2:Create("ImageLabel")({
							Name = "Arrow",
							LayoutOrder = 2,
							Size = UDim2.fromScale(0.5, 0.5),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							BackgroundTransparency = 1,
							Image = "rbxassetid://10825169477",
							Rotation = -90,
							ImageColor3 = color2,
							ImageTransparency = 0.3
						}), object2:Create("TextLabel")({
							Name = "To",
							LayoutOrder = 3,
							Size = UDim2.fromScale(0.36, 1),
							BackgroundTransparency = 1,
							Text = `Level {v18 + 1}`,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = Enum.Font.SourceSansBold,
							TextColor3 = Color3.fromRGB(85, 170, 255),
							object2:Create("UIStroke")({
								Thickness = 1.5,
								Transparency = 0.25
							})
						}) }
				end
			})
		end

		local v46

		if not (v4 or v14) then
			v46 = object2:Create("Frame")({
				LayoutOrder = 5,
				Size = UDim2.fromScale(0.92, v.Track),
				BackgroundTransparency = 1,
				LevelTrack(object2, v18, v23, v20)
			})
		end

		local v47

		if v20 ~= nil then
			v47 = object2:Create("Frame")({
				Name = "Odds",
				LayoutOrder = 6,
				Size = UDim2.fromScale(1, v5.Odds),
				BackgroundTransparency = 1,
				object2:State(function(callback2, p)
					local v49 = oddsFor(callback2(value3)) -- equivalent call inferred; original call site unknown
					local v50 = v10
					v10 = v49
					return OddsBar(p, v49, v50, charging)
				end)
			})
		end

		local v48

		if v20 ~= nil then
			local v49 = object2:Create("Frame")
			local v50 = {
				Name = "Materials",
				LayoutOrder = 7,
				Size = UDim2.fromScale(0.78, v5.Materials),
				BackgroundTransparency = 1
			}
			local v51 = object2:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.06, 0)
			})
			local materialSlot = MaterialSlot(object2, {
				LayoutOrder = 1,
				Label = "Wen",
				Icon = Shop.cashiers.Wen.GetContent(v27).Icon,
				NeedText = Utility.addCommasToNumber(v27),
				HaveText = `Have {Utility.addCommasToNumber(data.Wen.Value)}`,
				Short = short
			})
			local v54 = {
				LayoutOrder = 2,
				Label = v20.Ore,
				Icon = Shop.cashiers[v20.Ore].GetContent(v20.OreCount).Icon,
				NeedText = `x{v20.OreCount}`,
				HaveText = 0,
				Short = 0,
				Substitute = 0
			}
			local haveText

			if v33 > 0 then
				haveText = `Have {v32} (+{v33})`
			else
				haveText = `Have {v32}`
			end

			v54.HaveText = haveText
			v54.Short = short2
			v54.Substitute = v26 > 0 and {
				Icon = Shop.cashiers[Refinement.SmeltRate.From].GetContent(v26).Icon,
				Text = `x{v26}`
			} or nil
			do local _values = table.pack(v51, materialSlot, MaterialSlot(object2, v54)); for _k = 1, _values.n do v50[_k] = _values[_k] end end
			v48 = v49(v50)
		end

		local v49

		if not (v20 == nil or not (v14 or v20.FailBp > 0)) then
			v49 = object2:Create("Frame")({
				Name = "Guard",
				LayoutOrder = 8,
				Size = UDim2.fromScale(0.72, v5.Guard),
				BackgroundTransparency = 1,
				GuardToggle(object2, state, heldCount, value3, v31)
			})
		end

		do local _values = table.pack(v36, v43, v44, v45, v46, v47, v48, v49, object2:Create("Frame")({
	LayoutOrder = 9,
	Size = UDim2.fromScale(1, v5.Button),
	BackgroundTransparency = 1,
	object2:State(function(callback2, p)
		local rung

		if v14 and v20 ~= nil then
			local v53 = callback2(value3)

			if v14 then
				local successBp = v53 and 10000 or v20.SuccessBp
				rung = {
					FailBp = 10000 - successBp,
					SuccessBp = successBp,
					GreatBp = 0
				}
			else
				rung = Refinement.GetRung(v18, v53)
			end
		else
			rung = v20
		end

		return RefineButton(p, {
			Rung = rung,
			Enabled = enabled,
			Busy = state.Busy,
			Charging = charging,
			Reason = reason,
			Label = v14 and "Transfer" or nil,
			BusyLabel = v14 and "Transferring..." or nil,
			NoRungLabel = v14 and "Nothing to move" or nil,
			DisabledLabel = v14 and v21 == nil and "Pick a Target" or nil,
			Clicked = function()
				if state.Busy:Get() == true then
					local now = os.clock()

					if v12 <= now then
						v11 = true
					end
				elseif enabled then
					local v53

					if v14 then
						v53 = {
							action = "Transfer",
							From = v13,
							To = to,
							UseGuard = value3:Get()
						}
					else
						v53 = {
							action = "Attempt",
							Id = v13,
							UseGuard = state.UseGuard
						}
					end

					commit(v53) -- equivalent call inferred; original call site unknown
				end
			end
		})
	end)
})); for _k = 1, _values.n do v35[_k] = _values[_k] end end
		return v34(v35)
	end)
	local v13 = object:Create("Frame")
	local v14 = {
		Name = "CenterPanel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local v15

	if v4 then
		v15 = object:Create("UIPadding")({
			PaddingTop = UDim.new(0.06, 0)
		})
	end

	do local _values = table.pack(v15, object:Create("Frame")({
	Name = "Tabs",
	Size = UDim2.fromScale(1, v6),
	BackgroundTransparency = 1,
	PageBrowser(object, state.Mode, v3, {
		Key = function(_, p)
			return p
		end,
		Label = function(_, p)
			return p
		end,
		CanClick = function()
			return state.Busy:Get() ~= true
		end,
		Keybinds = false,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		TabSize = UDim2.fromScale(0.4, 0.9),
		Padding = UDim.new(0.03, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		TextXAlignment = Enum.TextXAlignment.Center,
		Backdrop = false
	})
}), object:Create("Frame")({
	Name = "Body",
	Position = UDim2.fromScale(0, v6 + 0.04),
	Size = UDim2.fromScale(1, 1 - v6 - 0.04),
	BackgroundTransparency = 1,
	state2
})); for _k = 1, _values.n do v14[_k] = _values[_k] end end
	return v13(v14)
end