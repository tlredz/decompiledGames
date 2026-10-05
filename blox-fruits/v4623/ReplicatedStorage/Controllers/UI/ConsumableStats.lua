local ConsumableStats = {}
local consumableStats = nil
local consumables = nil
local tooltip = nil
local window = nil
local scrollingFrame = nil
local modalButton = nil
local textButton = nil
local expandedButton = nil
local textButton2 = nil
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local ConsumableStack = require(script.ConsumableStack)
require(game.ReplicatedStorage.Modules.Consumables.Types)
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteEvent = Net:RemoteEvent("ConsumablesNetworkRE")
local localPlayer = game.Players.LocalPlayer
local v = {}
local v2 = false
local v3 = false
local v4 = false
local v5 = false

function ConsumableStats.OnStart(_)
	task.spawn(function()
		local textLabel, uIGridLayout, now, v6, v7, v8, v9, gridSize, inputChanged, v10, windowChanged, template, connection, v11, now2, minimized, minimized2, v12, v13, v14, visible, minimized3

		if not localPlayer.Team then
			localPlayer:GetPropertyChangedSignal("Team"):Wait()
		end

		remoteEvent:FireServer({
			Context = "Listen"
		})
		consumableStats = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ConsumableStats")
		consumableStats.DisplayOrder = 1
		consumables = consumableStats:WaitForChild("Container"):WaitForChild("Consumables")
		tooltip = consumableStats:WaitForChild("Tooltip")
		window = consumableStats:WaitForChild("Window")
		scrollingFrame = window:WaitForChild("Main"):WaitForChild("ScrollingFrame")
		modalButton = consumables:WaitForChild("ModalButton")
		textButton = modalButton:WaitForChild("TextButton")
		expandedButton = consumables:WaitForChild("ExpandedButton")
		textButton2 = expandedButton:WaitForChild("TextButton")
		task.spawn(function()
			local main = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
			consumableStats.Enabled = main.Enabled == true
			main:GetPropertyChangedSignal("Enabled"):Connect(function()
				consumableStats.Enabled = main.Enabled == true
			end)
		end)
		textLabel = textButton2:FindFirstChild("TextLabel")
		window:WaitForChild("Title"):WaitForChild("Close").Activated:Connect(function()
			window.Visible = false
		end)
		uIGridLayout = consumables:FindFirstChildOfClass("UIGridLayout")
		now = tick()
		v6 = 1
		v7 = {}
		v8 = {
			MouseKeyboard = {
				GridSize = {
					Minimized = 3,
					Maximized = 4
				},
				Expand = {
					Minimized = 6,
					Maximized = 11
				},
				Window = 12
			},
			Touch = {
				GridSize = {
					Minimized = 2,
					Maximized = 2
				},
				Expand = {
					Minimized = 4,
					Maximized = 4
				},
				Window = 4
			}
		}
		v8.Gamepad = v8.MouseKeyboard
		v9 = nil
		gridSize = nil

		inputChanged = function()
			local v16 = LastInput:Get() or "MouseKeyboard"
			v9 = {
				Expand = v8[v16].Expand,
				Window = v8[v16].Window
			}
			gridSize = v8[v16].GridSize
			now = tick()
		end

		v10 = LastInput:Get() or "MouseKeyboard"
		v9 = {
			Expand = v8[v10].Expand,
			Window = v8[v10].Window
		}
		gridSize = v8[v10].GridSize
		now = tick()
		LastInput.Changed:Connect(inputChanged)

		windowChanged = function()
			v2 = window.Visible == true
			now = tick()
		end

		v2 = window.Visible == true
		now = tick()
		window:GetPropertyChangedSignal("Visible"):Connect(windowChanged)
		textButton.Activated:Connect(function()
			window.Visible = not window.Visible
		end)
		textButton2.Activated:Connect(function()
			v3 = not v3
			now = tick()
		end)
		template = consumables:WaitForChild("Template")
		template.Visible = false
		remoteEvent.OnClientEvent:Connect(function(p)
			if p.Context == "RefreshQueue" then
				table.clear(v7)
				local v16 = {}

				for k, v17 in pairs(v) do
					if p.Queue[k] then
						continue
					end

					v[k] = nil
					v17:Destroy()
				end

				for k, consumablesInQueue in pairs(p.Queue) do
					local v18 = v[k]

					if v18 == nil then
						v18 = ConsumableStack(template:Clone(), tooltip, k)
					end

					v18.ConsumablesInQueue = consumablesInQueue
					v[k] = v18
					local connection2 = nil
					connection2 = v[k]:OnMouseEnter(function(p2)
						connection2:Disconnect()
						p2.Refresh()
					end)
					table.insert(v16, consumablesInQueue[1])
				end

				v7 = v16
				now = tick()
			end
		end)
		connection = nil
		v11 = 0
		now2 = 1

		while true do
			if connection then
				connection:Disconnect()
				connection = nil
			end

			minimized = v9.Expand.Minimized

			if v3 then
				minimized = v9.Expand.Maximized
			end

			minimized2 = v9.Expand.Minimized

			if minimized2 == v9.Expand.Maximized then
				v4 = false
			elseif v3 then
				v4 = true
			else
				v4 = minimized <= #v7
			end

			v5 = #v7 >= v9.Window
			v12 = v6 ~= now

			if #v7 > 0 and (v12 or tick() - now2 >= 1) then
				if v12 then
					v6 = now
				end

				now2 = tick()
				table.sort(v7, function(a, b)
					local v16 = a.Type == "Food" and 1 or 0
					local v17 = b.Type == "Food" and 1 or 0

					if v16 ~= v17 then
						return v17 < v16
					end

					if a.TimeExpires == b.TimeExpires then
						return #a.DisplayName < #b.DisplayName
					end

					return (a.TimeExpires or -1) < (b.TimeExpires or 1)
				end)
				v13 = v6

				for k, v17 in pairs(v7) do
					if v13 == now then
						if v[v17.EffectType] then
							if v2 then
								v[v17.EffectType].Rbx.Parent = scrollingFrame
								v[v17.EffectType].Rbx.Visible = true
							else
								if v9.Window <= k and not v2 then
									v[v17.EffectType].Rbx.Visible = false
								elseif minimized <= k and not v3 then
									v[v17.EffectType].Rbx.Visible = false
								else
									v[v17.EffectType].Rbx.Visible = true
								end

								v[v17.EffectType].Rbx.Parent = consumables
							end

							v[v17.EffectType].Rbx.LayoutOrder = k
							connection = v[v17.EffectType]:OnMouseEnter(function(p)
								if connection then
									connection:Disconnect()
									p.Refresh()
								end
							end)
						end
					else
						warn("broke early")
						break
					end
				end
			end

			if v4 then
				uIGridLayout.FillDirectionMaxCells = v3 and gridSize.Maximized or gridSize.Minimized
			else
				v3 = false
				uIGridLayout.FillDirectionMaxCells = gridSize.Minimized
			end

			v14 = modalButton

			if v3 then
				visible = v5 and not v2
			else
				minimized3 = v9.Expand.Minimized

				if minimized3 == v9.Expand.Maximized then
					visible = v5 and not v2
				else
					visible = false
				end
			end

			v14.Visible = visible
			expandedButton.Visible = v4 and not v2
			textButton2.Text = v3 and "-" or "+"
			textLabel.Text = textButton2.Text

			for _, v16 in pairs(v) do
				v16:Update(v11)
			end

			v11 = task.wait()
		end
	end)
end

return ConsumableStats