local v = {
	Verdant = {
		EEE = 3.1,
		EEM = 32.1,
		EEH = 0.7,
		EMM = 61.1,
		EMH = 2.9,
		Distinct = 818
	},
	Umbral = {
		EEE = 3.5,
		EEM = 32.2,
		EEH = 4.8,
		EMM = 43,
		EMH = 16.4,
		Distinct = 579
	},
	Radiant = {
		EEE = 2.5,
		EEM = 32.4,
		EEH = 1.6,
		EMM = 57.1,
		EMH = 6.3,
		Distinct = 514
	}
}
local v2 = {
	"EEE",
	"EEM",
	"EEH",
	"EMM",
	"EMH"
}
return {
	Name = "riftSimulate",
	Aliases = { "riftSim" },
	Description = "Simulates Rift recipe rolls per banner with the live flags and shows the difficulty mix in a panel. Runs on your client.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Banner",
			Description = "Banner id or display name (Verdant/Riftborn, Umbral/Riftbeasts, Radiant/Shattered Rift), or all.",
			Optional = true,
			Default = "all"
		},
		{
			Type = "integer",
			Name = "Runs",
			Description = "Recipes rolled per banner, up to 100000. Defaults to 10000.",
			Optional = true,
			Default = 10000
		}
	},
	ClientRun = function(_, value: string?, value2: number?)
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Rift = require(ReplicatedStorage.Data.Rift)
		local RiftRecipes = require(ReplicatedStorage.Shared.Modules.RiftRecipes)
		local RiftZoneLadder = require(ReplicatedStorage.Shared.Modules.RiftZoneLadder)
		local v3 = string.lower(value or "all")
		local v4 = {}

		for _, v5 in Rift.BannerIds() do
			if not (v3 == "all" or string.lower(v5) == v3 or string.lower(Rift.GetBannerDisplayName(v5)) == v3) then
				continue
			end

			table.insert(v4, v5)
		end

		if #v4 == 0 then
			return (`Unknown banner "{value}" - use {table.concat(Rift.BannerIds(), ", ")} or all`)
		end

		local v5 = math.clamp(math.floor(value2 or 10000), 1, 100000)
		local v6 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function line(text: string, color: Color3?)
			table.insert(v6, {
				text = text,
				color = color
			})
		end

		local v7 = RiftZoneLadder.Get()
		local v8 = {}

		for k, v9 in v7 do
			table.insert(v8, (`{k}.{v9.Id}`))
		end

		table.insert(v6, {
			text = `Zone ladder (by escape speed): {table.concat(v8, "  ")}`,
			color = Color3.fromRGB(180, 180, 200)
		})
		local config = RiftRecipes.ResolveConfig()
		table.insert(v6, {
			text = `Bands: Easy >= {config.EasyBand}%  Medium >= {config.MediumBand}%  Hard >= {config.MinSpawnChance}%  |  HardPenalty {config.HardPenalty}  ExtendBelow {config.ExtendBelow}  Attempts {config.MaxRecipeAttempts}`,
			color = Color3.fromRGB(180, 180, 200)
		})
		line("", nil) -- equivalent call inferred; original call site unknown
		local v9 = {}

		for _, v10 in v4 do
			local bannerRange, v11 = Rift.GetBannerRange(v10)
			local simulate = RiftRecipes.Simulate(v10, v5)
			table.insert(v6, {
				text = `{Rift.GetBannerDisplayName(v10)} ({v10})  {bannerRange} -> {v11}`,
				color = Color3.fromRGB(255, 220, 120)
			})

			if simulate.Error == nil then
				line(
					`  pool {simulate.PoolBottom} -> {simulate.PoolTop} ({simulate.PoolSize} pets: Easy {simulate.Bands.Easy}  Medium {simulate.Bands.Medium}  Hard {simulate.Bands.Hard}  Excluded {simulate.Bands.Excluded})`,
					nil
				) -- equivalent call inferred; original call site unknown
				local v12 = v5 - simulate.Failures
				local v13

				if simulate.Failures > 0 or simulate.NonZonePicks > 0 then
					v13 = Color3.fromRGB(255, 90, 90)
				else
					v13 = Color3.fromRGB(140, 230, 140)
				end

				line(
					`  runs {v5}  failed {simulate.Failures} ({string.format("%.2f", 100 * simulate.Failures / v5)}%)  non-zone picks {simulate.NonZonePicks}  distinct {simulate.Distinct} (ref {not v[v10] and "-" or v[v10].Distinct or "-"})`,
					v13
				) -- equivalent call inferred; original call site unknown
				line("  pattern     sim%     ref%    delta", nil) -- equivalent call inferred; original call site unknown
				local v14 = {}
				local v16 = simulate
				local v18 = v10

				local function patternLine(p: string)
					v14[p] = true
					local v19 = v16.Patterns[p] or 0
					local v20 = not (v12 > 0) and 0 or 100 * v19 / v12
					local v21

					if v[v18] then
						v21 = v[v18][p] or nil
					end

					local v22 = v21 == nil and "     -" or string.format("%6.1f", v21)
					local v23 = v21 == nil and "      " or string.format("%+6.1f", v20 - v21)
					local v24

					if v21 == nil then
						v24 = false
					else
						v24 = math.abs(v20 - v21) > 1.5
					end

					local formatted = `  {p}   {string.format("%7.2f", v20)}  {v22}  {v23}`
					local v25

					if v24 then
						v25 = Color3.fromRGB(255, 170, 90)
					end

					line(formatted, v25) -- equivalent call inferred; original call site unknown
				end

				for _, v19 in v2 do
					patternLine(v19)
				end

				for k in simulate.Patterns do
					if not v14[k] then
						patternLine(k)
					end
				end

				for k, slotPick in simulate.SlotPicks do
					local v19 = {}

					for k2, v20 in slotPick do
						table.insert(v19, { k2, v20 })
					end

					table.sort(v19, function(a, b)
						return a[2] > b[2]
					end)
					local v20 = {}

					for i = 1, math.min(5, #v19) do
						local v21 = v19[i]
						table.insert(v20, (`{v21[1]} {string.format("%.1f", 100 * v21[2] / math.max(v12, 1))}%`))
					end

					table.insert(v6, {
						text = `  slot {k} top: {table.concat(v20, "  ")}`,
						color = Color3.fromRGB(170, 200, 255)
					})
				end

				line("", nil) -- equivalent call inferred; original call site unknown
				local v19 = not (v12 > 0) and 0 or 100 * (simulate.Patterns.EMH or 0) / v12
				table.insert(
					v9,
					(`{v10}: EMH {string.format("%.1f", v19)}%  distinct {simulate.Distinct}  failed {simulate.Failures}  non-zone {simulate.NonZonePicks}`)
				)
			else
				table.insert(v6, {
					text = `  ERROR: {simulate.Error}`,
					color = Color3.fromRGB(255, 90, 90)
				})
				line("", nil) -- equivalent call inferred; original call site unknown
				table.insert(v9, (`{v10}: ERROR {simulate.Error}`))
			end
		end

		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local riftSimulatePanel = playerGui:FindFirstChild("RiftSimulatePanel")

		if riftSimulatePanel then
			riftSimulatePanel:Destroy()
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "RiftSimulatePanel"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 1000
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local frame = Instance.new("Frame")
		frame.Name = "Panel"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromScale(0.72, 0.78)
		frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
		frame.BackgroundTransparency = 0.04
		frame.BorderSizePixel = 0
		frame.Parent = screenGui
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 10)
		uICorner.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Header"
		textLabel.Size = UDim2.new(1, -60, 0, 36)
		textLabel.Position = UDim2.fromOffset(14, 4)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 18
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = `Rift recipe simulation - {v5} runs per banner`
		textLabel.Parent = frame
		local textButton = Instance.new("TextButton")
		textButton.Name = "RiftSimDismiss"
		textButton.Size = UDim2.fromOffset(34, 28)
		textButton.Position = UDim2.new(1, -42, 0, 8)
		textButton.BackgroundColor3 = Color3.fromRGB(117, 38, 46)
		textButton.BorderSizePixel = 0
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 18
		textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		textButton.Text = "X"
		textButton.Parent = frame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0, 6)
		uICorner2.Parent = textButton
		textButton.Activated:Connect(function()
			screenGui:Destroy()
		end)
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = "Lines"
		scrollingFrame.Position = UDim2.fromOffset(14, 44)
		scrollingFrame.Size = UDim2.new(1, -28, 1, -56)
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
		scrollingFrame.CanvasSize = UDim2.new()
		scrollingFrame.Parent = frame
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Padding = UDim.new(0, 1)
		uIListLayout.Parent = scrollingFrame
		local texts = {}

		for k, v10 in v6 do
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = `Line{k}`
			textLabel2.LayoutOrder = k
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			textLabel2.Size = UDim2.new(1, 0, 0, 16)
			textLabel2.BackgroundTransparency = 1
			textLabel2.Font = Enum.Font.Code
			textLabel2.TextSize = 14
			textLabel2.TextXAlignment = Enum.TextXAlignment.Left
			textLabel2.TextColor3 = v10.color or Color3.fromRGB(230, 230, 235)
			textLabel2.Text = v10.text
			textLabel2.Parent = scrollingFrame
			table.insert(texts, v10.text)
		end

		screenGui.Parent = playerGui
		print("[riftSimulate]\n" .. table.concat(texts, "\n"))
		return table.concat(v9, "\n")
	end
}