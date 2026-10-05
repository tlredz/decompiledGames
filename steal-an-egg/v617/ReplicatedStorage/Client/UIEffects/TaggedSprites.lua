local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiVisibility = require(script.Parent.GuiVisibility)
local v = {
	Start = function(ancestor)
		local v2 = {}
		local v3 = {}
		local connections = {}
		local heartbeatConnection = nil
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopIfIdle()
			if next(v3) == nil and heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function draw(data)
			local image = data.Image

			if image == nil then
				return
			end

			local imageRectSize = image.ImageRectSize
			image.ImageRectOffset = Vector2.new(
				imageRectSize.X * (data.Frame % data.Cells.X),
				imageRectSize.Y * math.floor(data.Frame / data.Cells.X)
			)
		end

		local function step(p: number)
			for k in v3 do
				local image = k.Image

				if k.Owner.Disabled or image == nil or k.Owner.Parent ~= image or not image:IsDescendantOf(ancestor) then
					v3[k] = nil
				else
					k.Remaining -= p

					if not (k.Remaining > 0) then
						if k.Frame >= k.Cells.X * k.Cells.Y then
							if k.Loop then
								k.Frame = 0

								if k.CycleWait then
									k.Remaining = 0
									continue
								end
							else
								k.Completed = true
								v3[k] = nil
								continue
							end
						end

						draw(k) -- equivalent call inferred; original call site unknown
						k.Frame += 1
						k.Remaining = 1 / k.FPS
					end
				end
			end

			stopIfIdle() -- equivalent call inferred; original call site unknown
		end

		local function syncActive(state)
			local gate = state.Gate

			if state.Valid and not state.Completed and gate ~= nil and gate.IsVisible() then
				if state.Frame == 0 and not state.CycleWait then
					draw(state) -- equivalent call inferred; original call site unknown
					state.Frame = 1
					state.Remaining = 1 / state.FPS
				end

				v3[state] = true

				if heartbeatConnection == nil then
					heartbeatConnection = RunService.Heartbeat:Connect(step)
				end
			else
				v3[state] = nil
				stopIfIdle() -- equivalent call inferred; original call site unknown
			end
		end

		local function readSettings(state)
			local owner = state.Owner
			local cells = owner:GetAttribute("Cells")
			local FPS = owner:GetAttribute("FPS")
			local spriteUsesLoopAttribute = owner:GetAttribute("SpriteUsesLoopAttribute") == true
			state.Valid = false
			state.Frame = 0
			state.Remaining = 0
			state.Completed = false
			state.CycleWait = not spriteUsesLoopAttribute
			state.Loop = not spriteUsesLoopAttribute or owner:GetAttribute("Loop") ~= false

			if typeof(cells) == "Vector2" and not (cells.X < 1) and not (cells.Y < 1) and cells.X % 1 == 0 and cells.Y % 1 == 0 and cells.X ~= 1e999 and cells.Y ~= 1e999 then
				if typeof(FPS) ~= "number" or FPS ~= FPS or FPS <= 0 or FPS == 1e999 then
					if spriteUsesLoopAttribute then
						FPS = 15
					else
						warn(owner:GetFullName() .. " needs a positive finite FPS")
						return
					end
				end

				state.Cells = cells
				state.FPS = FPS
				state.Valid = true
			else
				if state.Image ~= nil then
					state.Image.ImageRectOffset = Vector2.zero
				end

				warn(owner:GetFullName() .. " needs a finite positive Cells grid; holding frame one")
			end
		end

		local function forget(p)
			local v4 = v2[p]

			if v4 == nil then
				return
			end

			v2[p] = nil
			v3[v4] = nil

			if v4.Gate ~= nil then
				v4.Gate.Destroy()
				v4.Gate = nil
			end

			for _, link in v4.Links do
				link:Disconnect()
			end

			table.clear(v4.Links)
			stopIfIdle() -- equivalent call inferred; original call site unknown
		end

		local function bind(script2)
			if flag or not script2:IsA("LocalScript") or v2[script2] ~= nil then
				return
			end

			local v4 = {
				Owner = script2,
				Image = nil,
				Cells = Vector2.one,
				FPS = 1,
				Frame = 0,
				Remaining = 0,
				Loop = true,
				CycleWait = true,
				Completed = false,
				Valid = false,
				WasEnabled = not script2.Disabled,
				Gate = nil,
				Links = {}
			}
			v2[script2] = v4

			local function attach()
				local parent = script2.Parent

				if parent == nil or not (parent:IsA("ImageLabel") or parent:IsA("ImageButton")) then
					parent = nil
				end

				if v4.Image == parent and v4.Gate ~= nil then
					return
				end

				v3[v4] = nil

				if v4.Gate ~= nil then
					v4.Gate.Destroy()
					v4.Gate = nil
				end

				v4.Image = parent

				if parent ~= nil then
					readSettings(v4)
					v4.Gate = GuiVisibility.Watch(parent, function()
						syncActive(v4)
					end, script2, ancestor)
				end

				syncActive(v4)
			end

			table.insert(v4.Links, script2:GetPropertyChangedSignal("Enabled"):Connect(function()
				local wasEnabled = not script2.Disabled

				if wasEnabled and not v4.WasEnabled then
					readSettings(v4)
				end

				v4.WasEnabled = wasEnabled
				syncActive(v4)
			end))
			table.insert(v4.Links, script2.AncestryChanged:Connect(attach))
			table.insert(v4.Links, script2.Destroying:Connect(function()
				forget(script2)
			end))
			attach()
		end

		table.insert(connections, CollectionService:GetInstanceAddedSignal("ClientSpriteAnimation"):Connect(bind))
		table.insert(
			connections,
			CollectionService:GetInstanceRemovedSignal("ClientSpriteAnimation"):Connect(function(script2)
				if script2:IsA("LocalScript") then
					forget(script2)
				end
			end)
		)

		for _, v4 in CollectionService:GetTagged("ClientSpriteAnimation") do
			bind(v4)
		end

		return function()
			if flag then
				return
			end

			flag = true

			for _, connection in connections do
				connection:Disconnect()
			end

			for k in v2 do
				forget(k)
			end

			table.clear(connections)
			stopIfIdle() -- equivalent call inferred; original call site unknown
		end
	end
}

if RunService:IsClient() then
	v.Start(Players.LocalPlayer:WaitForChild("PlayerGui"))
end

return table.freeze(v)