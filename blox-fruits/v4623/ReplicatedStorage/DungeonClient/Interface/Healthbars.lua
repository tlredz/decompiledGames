local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local createElement = React.createElement

local function ExplorerItem(p)
	local explorerFolder = p.explorerFolder
	local playerColor = explorerFolder:GetAttribute("PlayerColor")
	local state, setState = React.useState(explorerFolder:GetAttribute("Name"))
	local state2, setState2 = React.useState("")
	local state3, setState3 = React.useState(UDim2.new(1, 0, 1, 0))
	local state4, setState4 = React.useState(nil)
	local player = explorerFolder:FindFirstChild("Player")
	local character = explorerFolder:FindFirstChild("Character")
	local humanoid = explorerFolder:FindFirstChild("Humanoid")
	React.useEffect(function() end, { state4 })
	React.useEffect(function()
		local v = Maid.new()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateHp(value: number)
			setState3(UDim2.new(math.clamp(value, 0, 1), 0, 1, 0))
			setState2(string.format("%.0f%%", (math.clamp(value * 100, 0, 100))))
		end

		v.respawningAtChanged = explorerFolder:GetAttributeChangedSignal("RespawningAt"):Connect(function()
			setState4((explorerFolder:GetAttribute("RespawningAt")))
		end)

		if explorerFolder:GetAttribute("RespawningAt") then
			setState4((explorerFolder:GetAttribute("RespawningAt")))
		end

		local function updateExplorer()
			if player.Value == nil or not player.Value:IsDescendantOf(game) then
				setState("<font color=\"rgb(255,0,0)\">Disconnected</font>")
				setState3(UDim2.new(0, 0, 1, 0))
				setState2(string.format("%.0f%%", 0))
			else
				if player.Value then
					if player.Value:IsA("Player") then
						setState(player.Value.DisplayName)
					else
						setState(player.Value.Name)
					end
				end

				if not humanoid.Value then
					return
				end

				local value = humanoid.Value
				v.healthChanged = value.HealthChanged:Connect(function(_)
					updateHp(value.Health / value.MaxHealth) -- equivalent call inferred; original call site unknown
				end)
				updateHp(value.Health / value.MaxHealth) -- equivalent call inferred; original call site unknown
			end
		end

		v.playerChanged = player.Changed:Connect(updateExplorer)
		v.characterChanged = character.Changed:Connect(updateExplorer)
		v.humanoidChanged = humanoid.Changed:Connect(updateExplorer)
		task.spawn(updateExplorer)
		return function()
			v:Destroy()
		end
	end, { explorerFolder, player.Value, humanoid.Value })
	local v2 = {
		Size = UDim2.new(1, 0, 0.18, 0),
		BackgroundTransparency = 0,
		BorderSizePixel = 0
	}
	local v3 = {
		Outline = createElement("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Thickness = 1.5
		}),
		RespawningOverlay = 0,
		HP = 0
	}
	local v5 = {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = React.useMemo(function()
			if state4 and state4 > 0 then
				return 0.1
			end

			return 1
		end, { state4 }),
		ZIndex = 5,
		Visible = React.useMemo(function()
			if state4 and state4 > 0 then
				return true
			end

			return false
		end, { state4 })
	}
	local v8 = {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextScaled = true,
		ZIndex = 6,
		Font = Enum.Font.Roboto,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Visible = React.useMemo(function()
			if state4 and state4 > 0 then
				return true
			end

			return false
		end, { state4 }),
		Text = 0
	}
	local ref = React.useRef("")
	React.useEffect(function()
		local v9 = Maid.new()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRespawnText()
			if state4 and state4 > 0 then
				local v10 = math.max(0, state4 - workspace:GetServerTimeNow())
				ref.current = "Respawning: " .. string.format("%.0f", v10) .. "s"
			else
				ref.current = ""
			end
		end

		v9.respawnTimer = task.spawn(function()
			while state4 and state4 > 0 do
				updateRespawnText() -- equivalent call inferred; original call site unknown
				task.wait(0.1)
			end

			updateRespawnText() -- equivalent call inferred; original call site unknown
		end)
		return function()
			v9:Destroy()
		end
	end, { state4 })
	v8.Text = ref
	v3.RespawningOverlay = createElement("Frame", v5, {
		RespawningLabel = createElement("TextLabel", v8, { createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 0
			}), (createElement("UIPadding", {
				PaddingRight = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.1, 0)
			})) })
	})
	v3.HP = createElement("Frame", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(33, 33, 33),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1
	}, {
		Fill = createElement("Frame", {
			Size = state3,
			BackgroundTransparency = 0,
			BackgroundColor3 = playerColor or Color3.fromRGB(59, 255, 0),
			BorderSizePixel = 0
		}, {
			Trans = createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.85,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 2, 0.6, -2),
				Size = UDim2.new(1, -4, 0.4, 0)
			})
		}),
		HpLabel = createElement("TextLabel", {
			Position = UDim2.new(0.51, 0, 0, 0),
			Size = UDim2.new(0.49, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 1,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			ZIndex = 3,
			Text = state2,
			RichText = true,
			Visible = React.useMemo(function()
				return not (state4 and state4 > 0)
			end, { state4 })
		}, { createElement("UIPadding", {
				PaddingRight = UDim.new(0.05, 0)
			}), createElement("UITextSizeConstraint", {
				MaxTextSize = workspace.CurrentCamera.ViewportSize.Y * 0.02,
				MinTextSize = 10
			}), (createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 0
			})) }),
		NameLabel = createElement("TextLabel", {
			Position = UDim2.new(0.01, 0, 0.1, 0),
			Size = UDim2.new(0.5, 0, 0.8, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 1,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = state,
			ZIndex = 3,
			RichText = true
		}, { createElement("UIPadding", {
				PaddingRight = UDim.new(0.05, 0)
			}), (createElement("UITextSizeConstraint", {
				MaxTextSize = workspace.CurrentCamera.ViewportSize.Y * 0.02,
				MinTextSize = 8
			})) })
	})
	return (createElement("Frame", v2, v3))
end

return ExplorerItem