local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local FusionAnnouncementService = require(ReplicatedStorage.Engine.Service.FusionAnnouncementService)
local ServerRestartService = require(ReplicatedStorage.Engine.Service.ServerRestartService)
local flag = false
return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local localPlayer = Players.LocalPlayer
		local v = localPlayer:WaitForChild("PlayerGui"):WaitForChild("全服播报")
		local v2 = v:WaitForChild("播报条")
		local v3 = v2:WaitForChild("播报文本")
		local v4 = v2:WaitForChild("重启文本")
		local v5 = v2:WaitForChild("重启说明")
		local position = v4.Position
		local size = v4.Size
		local displayOrder = v.DisplayOrder
		local backgroundTransparency = v2.BackgroundTransparency
		local v6 = v:WaitForChild("左侧底色")
		local v7 = v:WaitForChild("右侧底色")

		local function syncBackgroundEdges()
			local X = v2.Position.X
			local X2 = v2.Size.X
			local X3 = v2.AnchorPoint.X
			local uDim = UDim.new(X.Scale - X2.Scale * X3, X.Offset - X2.Offset * X3)
			local uDim2 = UDim.new(X.Scale + X2.Scale * (1 - X3), X.Offset + X2.Offset * (1 - X3))

			for _, v8 in { v6, v7 } do
				v8.Visible = v2.Visible
				v8.BackgroundTransparency = v2.BackgroundTransparency
				v8.BackgroundColor3 = v2.BackgroundColor3
				v8.Size = UDim2.new(1, 0, v2.Size.Y.Scale, v2.Size.Y.Offset)
				v8.AnchorPoint = Vector2.new(v8 == v6 and 1 or 0, v2.AnchorPoint.Y)
				local v9 = v8 == v6 and uDim or uDim2
				v8.Position = UDim2.new(v9.Scale, v9.Offset, v2.Position.Y.Scale, v2.Position.Y.Offset)
			end
		end

		local v8 = nil
		local v9 = nil
		local v10 = nil

		for _, propertyName in {
			"Visible",
			"BackgroundTransparency",
			"BackgroundColor3",
			"Position",
			"Size",
			"AnchorPoint"
		} do
			v2:GetPropertyChangedSignal(propertyName):Connect(syncBackgroundEdges)
		end

		syncBackgroundEdges()
		local v11 = {}
		local v12 = false
		local count = 0
		local v13 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function inBattle()
			return localPlayer:GetAttribute("InDuelTable") == true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelTweens()
			for _, v14 in ipairs(v13) do
				v14:Cancel()
			end

			table.clear(v13)
		end

		v.Enabled = true
		v3.Visible = true
		v4.Visible = false
		v5.Visible = false
		v2.Visible = false

		local function keepOnTop()
			if not v8 then
				return
			end

			local displayOrder2 = displayOrder

			for _, screenGui in v.Parent:GetChildren() do
				if screenGui ~= v and screenGui:IsA("ScreenGui") then
					displayOrder2 = math.max(displayOrder2, screenGui.DisplayOrder + 1)
				end
			end

			if v.DisplayOrder ~= displayOrder2 then
				v.DisplayOrder = displayOrder2
			end

			if not v.Enabled then
				v.Enabled = true
			end
		end

		local function renderRestart()
			if not v8 then
				return
			end

			local v14 = math.max(0, (math.ceil(v8.deadline - workspace:GetServerTimeNow())))

			if v14 ~= v9 then
				v9 = v14
				v4.Text = v14 > 0 and string.format("Server restarting in %ds", v14) or "Server restarting..."
			end

			local visible = v8.message ~= ""
			v4.Position = visible and UDim2.fromScale(0.5, 0.29) or position
			v4.Size = visible and UDim2.fromScale(0.94, 0.5) or size
			v5.Text = v8.message
			v5.Visible = visible
			v3.Visible = false
			v4.Visible = true
			v2.BackgroundTransparency = backgroundTransparency
			v2.Visible = true
			v.Enabled = true
		end

		local v14 = {}

		local function watchOverlay(screenGui)
			if screenGui == v or not screenGui:IsA("ScreenGui") then
				return
			end

			v14[screenGui] = screenGui:GetPropertyChangedSignal("DisplayOrder"):Connect(keepOnTop)
			keepOnTop()
		end

		for _, screenGui in v.Parent:GetChildren() do
			if not (screenGui ~= v and screenGui:IsA("ScreenGui")) then
				continue
			end

			v14[screenGui] = screenGui:GetPropertyChangedSignal("DisplayOrder"):Connect(keepOnTop)
			keepOnTop()
		end

		v.Parent.ChildAdded:Connect(watchOverlay)
		v.Parent.ChildRemoved:Connect(function(child)
			if v14[child] then
				v14[child]:Disconnect()
				v14[child] = nil
			end

			keepOnTop()
		end)
		v:GetPropertyChangedSignal("Enabled"):Connect(function()
			if v8 and not v.Enabled then
				v.Enabled = true
			end
		end)
		v:GetPropertyChangedSignal("DisplayOrder"):Connect(keepOnTop)
		RunService.Heartbeat:Connect(function()
			if v8 then
				renderRestart()
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clear()
			count += 1
			table.clear(v11)
			cancelTweens() -- equivalent call inferred; original call site unknown
			v2.Visible = false
			v2.BackgroundTransparency = backgroundTransparency
		end

		local pump

		pump = function()
			if v12 or v8 then
				return
			end

			v12 = true
			task.spawn(function()
				local success, result = pcall(function()
					while #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 do
						local v15 = table.remove(v11, 1)
						v10 = v15
						local v16 = count

						local function interrupted()
							return v16 ~= count or (inBattle() or v8 ~= nil)
						end

						v3["玩家名称"].Text = v15.displayName
						v3["物品名称"].Text = "Rainbow " .. v15.ballName
						v3["唯一编号"].Text = "#" .. tostring(v15.serial)
						v2.Visible = false
						v2.BackgroundTransparency = 1
						RunService.Heartbeat:Wait()
						RunService.Heartbeat:Wait()

						if v16 ~= count or inBattle() or v8 ~= nil then
							break
						end

						local X = v3.AbsoluteSize.X
						local X2 = v2.AbsoluteSize.X
						v3.Position = UDim2.new(0, X2 + X / 2 + 8, 0.5, 0)
						v2.Visible = true
						local v18 = v16

						local function transition(duration, quart, p, uDim, backgroundTransparency2, duration2, p2)
							local tween = TweenService:Create(v3, TweenInfo.new(duration, quart, p), {
								Position = uDim
							})
							local tween2 = TweenService:Create(
								v2,
								TweenInfo.new(
									duration2,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.InOut,
									0,
									false,
									p2
								),
								{
									BackgroundTransparency = backgroundTransparency2
								}
							)
							v13 = { tween, tween2 }
							tween2:Play()
							tween:Play()
							tween.Completed:Wait()
							cancelTweens() -- equivalent call inferred; original call site unknown

							if v18 == count and localPlayer:GetAttribute("InDuelTable") ~= true and v8 == nil then
								v2.BackgroundTransparency = backgroundTransparency2
							end
						end

						transition(
							1.6,
							Enum.EasingStyle.Quart,
							Enum.EasingDirection.Out,
							UDim2.new(0.5, 0, 0.5, 0),
							backgroundTransparency,
							0.4,
							0
						)

						if v16 ~= count or inBattle() or v8 ~= nil then
							break
						end

						local v19 = os.clock() + 1.8

						repeat
							RunService.Heartbeat:Wait()
						until v16 ~= count or inBattle() or v8 ~= nil or v19 <= os.clock()

						if v16 ~= count or inBattle() or v8 ~= nil then
							break
						end

						transition(
							1.4,
							Enum.EasingStyle.Quart,
							Enum.EasingDirection.In,
							UDim2.new(0, -X / 2 - 8, 0.5, 0),
							1,
							0.5,
							0.8999999999999999
						)

						if v16 ~= count or inBattle() or v8 ~= nil then
							break
						else
							v2.Visible = false
						end
					end
				end)
				cancelTweens() -- equivalent call inferred; original call site unknown
				v12 = false
				v10 = nil

				if v8 then
					renderRestart()
				else
					v2.Visible = false
					v2.BackgroundTransparency = backgroundTransparency
				end

				if not success then
					table.clear(v11)
					warn("[FusionAnnouncement] Playback failed: " .. tostring(result))
				end

				if #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 then
					pump()
				end
			end)
		end

		local function applyRestart(p)
			local v15 = v8 ~= nil
			v8 = p
			v9 = nil

			if p then
				if not v15 then
					count += 1

					if v10 then
						if #v11 >= 100 then
							table.remove(v11)
						end

						table.insert(v11, 1, v10)
						v10 = nil
					end

					cancelTweens() -- equivalent call inferred; original call site unknown
				end

				keepOnTop()
				renderRestart()
			elseif v15 then
				v4.Visible = false
				v5.Visible = false
				v4.Position = position
				v4.Size = size
				v3.Visible = true
				v2.Visible = false
				v.DisplayOrder = displayOrder

				if not v12 then
					if v8 then
						return
					end

					v12 = true
					task.spawn(function()
						local success, result = pcall(function()
							while #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 do
								local v16 = table.remove(v11, 1)
								v10 = v16
								local v17 = count

								local function interrupted()
									return v17 ~= count or (inBattle() or v8 ~= nil)
								end

								v3["玩家名称"].Text = v16.displayName
								v3["物品名称"].Text = "Rainbow " .. v16.ballName
								v3["唯一编号"].Text = "#" .. tostring(v16.serial)
								v2.Visible = false
								v2.BackgroundTransparency = 1
								RunService.Heartbeat:Wait()
								RunService.Heartbeat:Wait()

								if v17 ~= count or inBattle() or v8 ~= nil then
									break
								end

								local X = v3.AbsoluteSize.X
								local X2 = v2.AbsoluteSize.X
								v3.Position = UDim2.new(0, X2 + X / 2 + 8, 0.5, 0)
								v2.Visible = true
								local v19 = v17

								local function transition(duration, quart, p2, uDim, backgroundTransparency2, duration2, p3)
									local tween = TweenService:Create(v3, TweenInfo.new(duration, quart, p2), {
										Position = uDim
									})
									local tween2 = TweenService:Create(
										v2,
										TweenInfo.new(
											duration2,
											Enum.EasingStyle.Sine,
											Enum.EasingDirection.InOut,
											0,
											false,
											p3
										),
										{
											BackgroundTransparency = backgroundTransparency2
										}
									)
									v13 = { tween, tween2 }
									tween2:Play()
									tween:Play()
									tween.Completed:Wait()
									cancelTweens() -- equivalent call inferred; original call site unknown

									if v19 == count and localPlayer:GetAttribute("InDuelTable") ~= true and v8 == nil then
										v2.BackgroundTransparency = backgroundTransparency2
									end
								end

								transition(
									1.6,
									Enum.EasingStyle.Quart,
									Enum.EasingDirection.Out,
									UDim2.new(0.5, 0, 0.5, 0),
									backgroundTransparency,
									0.4,
									0
								)

								if v17 ~= count or inBattle() or v8 ~= nil then
									break
								end

								local v20 = os.clock() + 1.8

								repeat
									RunService.Heartbeat:Wait()
								until v17 ~= count or inBattle() or v8 ~= nil or v20 <= os.clock()

								if v17 ~= count or inBattle() or v8 ~= nil then
									break
								end

								transition(
									1.4,
									Enum.EasingStyle.Quart,
									Enum.EasingDirection.In,
									UDim2.new(0, -X / 2 - 8, 0.5, 0),
									1,
									0.5,
									0.8999999999999999
								)

								if v17 ~= count or inBattle() or v8 ~= nil then
									break
								else
									v2.Visible = false
								end
							end
						end)
						cancelTweens() -- equivalent call inferred; original call site unknown
						v12 = false
						v10 = nil

						if v8 then
							renderRestart()
						else
							v2.Visible = false
							v2.BackgroundTransparency = backgroundTransparency
						end

						if not success then
							table.clear(v11)
							warn("[FusionAnnouncement] Playback failed: " .. tostring(result))
						end

						if #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 then
							pump()
						end
					end)
				end
			end
		end

		ServerRestartService.onChanged(applyRestart)
		applyRestart(ServerRestartService.getState())
		localPlayer:GetAttributeChangedSignal("InDuelTable"):Connect(function()
			if v8 then
				renderRestart()
			elseif inBattle() then
				clear() -- equivalent call inferred; original call site unknown
			elseif not v12 then
				if v8 then
					return
				end

				v12 = true
				task.spawn(function()
					local success, result = pcall(function()
						while #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 do
							local v15 = table.remove(v11, 1)
							v10 = v15
							local v16 = count

							local function interrupted()
								return v16 ~= count or (inBattle() or v8 ~= nil)
							end

							v3["玩家名称"].Text = v15.displayName
							v3["物品名称"].Text = "Rainbow " .. v15.ballName
							v3["唯一编号"].Text = "#" .. tostring(v15.serial)
							v2.Visible = false
							v2.BackgroundTransparency = 1
							RunService.Heartbeat:Wait()
							RunService.Heartbeat:Wait()

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							end

							local X = v3.AbsoluteSize.X
							local X2 = v2.AbsoluteSize.X
							v3.Position = UDim2.new(0, X2 + X / 2 + 8, 0.5, 0)
							v2.Visible = true
							local v18 = v16

							local function transition(duration, quart, p, uDim, backgroundTransparency2, duration2, p2)
								local tween = TweenService:Create(v3, TweenInfo.new(duration, quart, p), {
									Position = uDim
								})
								local tween2 = TweenService:Create(
									v2,
									TweenInfo.new(
										duration2,
										Enum.EasingStyle.Sine,
										Enum.EasingDirection.InOut,
										0,
										false,
										p2
									),
									{
										BackgroundTransparency = backgroundTransparency2
									}
								)
								v13 = { tween, tween2 }
								tween2:Play()
								tween:Play()
								tween.Completed:Wait()
								cancelTweens() -- equivalent call inferred; original call site unknown

								if v18 == count and localPlayer:GetAttribute("InDuelTable") ~= true and v8 == nil then
									v2.BackgroundTransparency = backgroundTransparency2
								end
							end

							transition(
								1.6,
								Enum.EasingStyle.Quart,
								Enum.EasingDirection.Out,
								UDim2.new(0.5, 0, 0.5, 0),
								backgroundTransparency,
								0.4,
								0
							)

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							end

							local v19 = os.clock() + 1.8

							repeat
								RunService.Heartbeat:Wait()
							until v16 ~= count or inBattle() or v8 ~= nil or v19 <= os.clock()

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							end

							transition(
								1.4,
								Enum.EasingStyle.Quart,
								Enum.EasingDirection.In,
								UDim2.new(0, -X / 2 - 8, 0.5, 0),
								1,
								0.5,
								0.8999999999999999
							)

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							else
								v2.Visible = false
							end
						end
					end)
					cancelTweens() -- equivalent call inferred; original call site unknown
					v12 = false
					v10 = nil

					if v8 then
						renderRestart()
					else
						v2.Visible = false
						v2.BackgroundTransparency = backgroundTransparency
					end

					if not success then
						table.clear(v11)
						warn("[FusionAnnouncement] Playback failed: " .. tostring(result))
					end

					if #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 then
						pump()
					end
				end)
			end
		end)
		FusionAnnouncementService.remote.OnClientEvent:Connect(function(list)
			if inBattle() and not v8 or type(list) ~= "table" then
				return
			end

			for _, v15 in ipairs(list) do
				if #v11 >= 100 then
					break
				else
					table.insert(v11, v15)
				end
			end

			if not v12 then
				if v8 then
					return
				end

				v12 = true
				task.spawn(function()
					local success, result = pcall(function()
						while #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 do
							local v15 = table.remove(v11, 1)
							v10 = v15
							local v16 = count

							local function interrupted()
								return v16 ~= count or (inBattle() or v8 ~= nil)
							end

							v3["玩家名称"].Text = v15.displayName
							v3["物品名称"].Text = "Rainbow " .. v15.ballName
							v3["唯一编号"].Text = "#" .. tostring(v15.serial)
							v2.Visible = false
							v2.BackgroundTransparency = 1
							RunService.Heartbeat:Wait()
							RunService.Heartbeat:Wait()

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							end

							local X = v3.AbsoluteSize.X
							local X2 = v2.AbsoluteSize.X
							v3.Position = UDim2.new(0, X2 + X / 2 + 8, 0.5, 0)
							v2.Visible = true
							local v18 = v16

							local function transition(duration, quart, p, uDim, backgroundTransparency2, duration2, p2)
								local tween = TweenService:Create(v3, TweenInfo.new(duration, quart, p), {
									Position = uDim
								})
								local tween2 = TweenService:Create(
									v2,
									TweenInfo.new(
										duration2,
										Enum.EasingStyle.Sine,
										Enum.EasingDirection.InOut,
										0,
										false,
										p2
									),
									{
										BackgroundTransparency = backgroundTransparency2
									}
								)
								v13 = { tween, tween2 }
								tween2:Play()
								tween:Play()
								tween.Completed:Wait()
								cancelTweens() -- equivalent call inferred; original call site unknown

								if v18 == count and localPlayer:GetAttribute("InDuelTable") ~= true and v8 == nil then
									v2.BackgroundTransparency = backgroundTransparency2
								end
							end

							transition(
								1.6,
								Enum.EasingStyle.Quart,
								Enum.EasingDirection.Out,
								UDim2.new(0.5, 0, 0.5, 0),
								backgroundTransparency,
								0.4,
								0
							)

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							end

							local v19 = os.clock() + 1.8

							repeat
								RunService.Heartbeat:Wait()
							until v16 ~= count or inBattle() or v8 ~= nil or v19 <= os.clock()

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							end

							transition(
								1.4,
								Enum.EasingStyle.Quart,
								Enum.EasingDirection.In,
								UDim2.new(0, -X / 2 - 8, 0.5, 0),
								1,
								0.5,
								0.8999999999999999
							)

							if v16 ~= count or inBattle() or v8 ~= nil then
								break
							else
								v2.Visible = false
							end
						end
					end)
					cancelTweens() -- equivalent call inferred; original call site unknown
					v12 = false
					v10 = nil

					if v8 then
						renderRestart()
					else
						v2.Visible = false
						v2.BackgroundTransparency = backgroundTransparency
					end

					if not success then
						table.clear(v11)
						warn("[FusionAnnouncement] Playback failed: " .. tostring(result))
					end

					if #v11 > 0 and localPlayer:GetAttribute("InDuelTable") ~= true and not v8 then
						pump()
					end
				end)
			end
		end)
	end
}