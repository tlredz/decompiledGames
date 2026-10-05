local StarterGui = game:GetService("StarterGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
return {
	new = function(instance)
		local v = {
			hidden = false,
			records = {},
			connections = {},
			core = {}
		}
		local playerGui = instance:WaitForChild("PlayerGui")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function eligible(instance2)
			return (instance2:IsA("ScreenGui") or instance2:IsA("BillboardGui") or instance2:IsA("SurfaceGui")) and not instance2:GetAttribute("CreatorCaptureExempt")
		end

		local function watch(descendant)
			if not v.hidden or not eligible(descendant) or v.records[descendant] then
				return
			end

			local v2 = {
				wanted = descendant.Enabled,
				ownWrites = 0
			}
			v.records[descendant] = v2

			-- equivalent calls inferred from this helper; original call sites unknown
			local function suppress()
				if descendant.Enabled then
					v2.ownWrites += 1
					descendant.Enabled = false
				end
			end

			v2.connection = descendant:GetPropertyChangedSignal("Enabled"):Connect(function()
				if not v.hidden then
					return
				end

				if descendant.Enabled or not (v2.ownWrites > 0) then
					v2.wanted = descendant.Enabled
					suppress() -- equivalent call inferred; original call site unknown
				else
					v2.ownWrites -= 1
				end
			end)

			if descendant.Enabled then
				v2.ownWrites += 1
				descendant.Enabled = false
			end
		end

		function v:setHidden(hidden)
			if self.hidden == hidden then
				return
			end

			self.hidden = hidden

			if hidden then
				for _, folder in { playerGui, workspace } do
					table.insert(self.connections, folder.DescendantAdded:Connect(watch))

					for _, descendant in folder:GetDescendants() do
						watch(descendant)
					end
				end

				self.promptEnabled = ProximityPromptService.Enabled
				ProximityPromptService.Enabled = false

				for _, v2 in Enum.CoreGuiType:GetEnumItems() do
					if v2 == Enum.CoreGuiType.All then
						continue
					end

					local success, coreGuiEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, v2)

					if not success then
						continue
					end

					self.core[v2] = coreGuiEnabled
					pcall(StarterGui.SetCoreGuiEnabled, StarterGui, v2, false)
				end

				local success, core = pcall(StarterGui.GetCore, StarterGui, "TopbarEnabled")
				self.topbar = success and core or nil

				if success then
					pcall(StarterGui.SetCore, StarterGui, "TopbarEnabled", false)
				end

				local total = 0
				local connections = self.connections
				local RunService = game:GetService("RunService")
				table.insert(connections, RunService.Heartbeat:Connect(function(dt)
					total += dt

					if total < 0.25 or not self.hidden then
						return
					end

					total = 0

					for k in self.core do
						local success2, coreGuiEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, k)

						if not (success2 and coreGuiEnabled) then
							continue
						end

						self.core[k] = true
						pcall(StarterGui.SetCoreGuiEnabled, StarterGui, k, false)
					end
				end))
			else
				for _, connection in self.connections do
					connection:Disconnect()
				end

				table.clear(self.connections)

				for k, record in self.records do
					record.connection:Disconnect()

					if k.Parent then
						k.Enabled = record.wanted
					end
				end

				table.clear(self.records)

				for k, v2 in self.core do
					pcall(StarterGui.SetCoreGuiEnabled, StarterGui, k, v2)
				end

				table.clear(self.core)

				if self.topbar ~= nil then
					pcall(StarterGui.SetCore, StarterGui, "TopbarEnabled", self.topbar)
				end

				if self.promptEnabled ~= nil then
					ProximityPromptService.Enabled = self.promptEnabled
				end
			end

			instance:SetAttribute("CreatorUIHidden", hidden or nil)
		end

		function v:destroy()
			self:setHidden(false)
		end

		return v
	end
}