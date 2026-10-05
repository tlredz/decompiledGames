local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Events = require(script.Parent.Events)
local EventsCollision = require(script.Parent.EventsCollision)
local Pool = require(script.Parent.Pool)
local Apply = require(script.Parent.CameraShake.Apply)
local count = 0
return function(p)
	function p:Activate()
		if self.Connection then
			return
		end

		self._engineGen = (self._engineGen or 0) + 1
		self._notActivatedWarned = false

		if RunService:IsClient() then
			if not self._focusConn then
				self._focusConn = UserInputService.WindowFocused:Connect(function()
					self._focused = true
					self._unfocusedAt = 0
				end)
			end

			if not self._blurConn then
				self._blurConn = UserInputService.WindowFocusReleased:Connect(function()
					self._focused = false
					self._unfocusedAt = os.clock()
				end)
			end
		end

		local workspace2 = workspace
		local Lighting = game:GetService("Lighting")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local StarterGui = game:GetService("StarterGui")
		local StarterPack = game:GetService("StarterPack")

		for _, v in ipairs({
			workspace2,
			Lighting,
			ReplicatedStorage,
			StarterGui,
			StarterPack,
			game:GetService("ReplicatedFirst")
		}) do
			local v2 = v
			pcall(function()
				self:Preload(v2, false)
			end)
		end

		local function fn(p2)
			Events.tickFrame()
			local now = os.clock()
			Pool.tick(now)
			local activeEmits = self.ActiveEmits

			if #activeEmits == 0 then
				Apply.applyFrame()
				return
			end

			local currentCamera = workspace.CurrentCamera
			local position

			if currentCamera then
				position = currentCamera.CFrame.Position
			end

			local v = 1

			while v <= #activeEmits do
				local activeEmit = activeEmits[v]
				local forceDead = activeEmit._forceDead == true
				local currentStep = activeEmit.CurrentStep

				if not forceDead then
					if activeEmit.Type == "Part" then
						forceDead = self:UpdatePart(activeEmit, p2, now)
					elseif activeEmit.Type == "Beam" then
						forceDead = self:UpdateBeam(activeEmit, p2, now)
					elseif activeEmit.Type == "PointLight" then
						forceDead = self:UpdatePointLight(activeEmit, p2, now)
					elseif activeEmit.Type == "Highlight" then
						forceDead = self:UpdateHighlight(activeEmit, p2, now)
					elseif activeEmit.Type == "TrailEmitter" then
						forceDead = self:UpdateTrail(activeEmit, p2, now)
					elseif activeEmit.Type == "Attachment" then
						forceDead = self:UpdateAttachment(activeEmit, p2, now)
					elseif activeEmit.Type == "Model" then
						forceDead = self:UpdateModel(activeEmit, p2, now)
					elseif activeEmit.Type == "Screen" then
						forceDead = self:UpdateScreen(activeEmit, p2, now)
					elseif activeEmit.Type == "ImageLabel" then
						forceDead = self:UpdateImageLabel(activeEmit, p2, now)
					elseif activeEmit.Type == "Lightning" then
						forceDead = self:UpdateLightning(activeEmit, p2, now)
					elseif activeEmit.Type == "CameraShake" then
						forceDead = self:UpdateCameraShake(activeEmit, p2, now)
					elseif activeEmit.Type == "Rocks" then
						forceDead = self:UpdateRocks(activeEmit, p2, now)
					elseif activeEmit.Type == "Rope" then
						forceDead = self:UpdateRope(activeEmit, p2, now)
					end
				end

				if not forceDead then
					if activeEmit.Link then
						self:ReapplyLink(activeEmit)
					end

					local type = activeEmit.Type

					if activeEmit._settleEngaged and not activeEmit._collisionStopped and (type == "Part" or type == "Model" or type == "Attachment") then
						EventsCollision.applySettle(activeEmit, p2)
					end

					if (type == "Part" or type == "Model" or type == "Attachment") and (activeEmit.Link or activeEmit.CurrentStep ~= currentStep) then
						activeEmit._postUpdateCF = type == "Model" and activeEmit.VisualPart:GetPivot() or activeEmit.VisualPart.CFrame
					end

					if activeEmit.Orientation and activeEmit.Orientation ~= "None" then
						self:ApplyOrientation(activeEmit, p2, position)
					end

					if activeEmit.ZOffset and activeEmit.ZOffset ~= 0 then
						self:ApplyZOffset(activeEmit, position)
					end
				end

				Events.afterUpdate(self, activeEmit, forceDead, now)

				if forceDead then
					self:_fireOnDeath(activeEmit)

					if activeEmit.IsAnimate then
						if activeEmit.AnimateItem and activeEmit.AnimateItem.Parent and activeEmit.AnimateItem:GetAttribute("AnimateLoop") then
							self:_replayAnimateCycle(activeEmit, now)
							v += 1
						else
							local visualPart = activeEmit.VisualPart
							local type = activeEmit.Type
							local initialAnchorCF = activeEmit.InitialAnchorCF
							local initialScale = activeEmit.InitialScale
							local hasDecal = activeEmit.HasDecal
							local animateItem = activeEmit.AnimateItem
							local partLife = activeEmit.PartLife or 0
							local v2 = type == "Part" or type == "Attachment" or type == "Model" or type == "Beam"
							local v3

							if animateItem then
								v3 = (animateItem:GetAttribute("_animateFinishGen") or 0) + 1
								local animateItem2 = animateItem
								pcall(function()
									animateItem2:SetAttribute("_animateFinishGen", v3)
								end)
							else
								v3 = nil
							end

							local part = visualPart
							local v6 = activeEmit

							local function finishAnimate()
								if not (part and part.Parent) or v2 and animateItem and self.ActiveAnimates[animateItem] or animateItem and animateItem.Parent and v3 and animateItem:GetAttribute("_animateFinishGen") ~= v3 then
									return
								end

								self:_fireOnDestruction(v6, part)

								if initialAnchorCF then
									if type == "Model" then
										pcall(function()
											part:PivotTo(initialAnchorCF)
										end)

										if initialScale then
											pcall(function()
												part:ScaleTo(initialScale)
											end)
										end
									else
										pcall(function()
											part.CFrame = initialAnchorCF
										end)
									end
								end

								if type == "Screen" or type == "ImageLabel" or type == "Lightning" or type == "Rocks" or type == "Rope" then
									pcall(function()
										part:Destroy()
									end)
									return
								end

								if type ~= "Beam" and type ~= "Highlight" and type ~= "TrailEmitter" then
									pcall(function()
										part.Transparency = 1
										local decal = hasDecal and part:FindFirstChildOfClass("Decal")

										if decal then
											decal.Transparency = 1
										end

										local surfaceAppearance = v6._initialSAColor and part:FindFirstChildOfClass("SurfaceAppearance")

										if surfaceAppearance then
											surfaceAppearance.Color = v6._initialSAColor
										end

										if v6._initialPartColor and part:IsA("BasePart") then
											part.Color = v6._initialPartColor
										end
									end)
									return
								end

								local beamSnapshot = v6.BeamSnapshot or v6.HighlightSnapshot or v6.TrailEmitterSnapshot

								if beamSnapshot then
									pcall(function()
										for k, v11 in pairs(beamSnapshot) do
											part[k] = v11
										end
									end)
								end

								pcall(function()
									part.Enabled = false
								end)
							end

							self.ActiveAnimates[animateItem] = nil

							if partLife > 0 then
								task.delay(partLife, finishAnimate)
							else
								finishAnimate()
							end

							if activeEmit._scaleMapKeys and self._parentScaleMap then
								for _, _scaleMapKey in ipairs(activeEmit._scaleMapKeys) do
									self._parentScaleMap[_scaleMapKey] = nil
								end
							end

							if activeEmit._nestedAlive then
								activeEmit._nestedAlive[1] = false
							end

							local count2 = #activeEmits

							if v < count2 then
								activeEmits[v] = activeEmits[count2]
							end

							activeEmits[count2] = nil
						end
					else
						local visualPart = activeEmit.VisualPart

						if activeEmit.PartLife and activeEmit.PartLife > 0 then
							local _sourceItem = activeEmit._sourceItem

							if _sourceItem and visualPart then
								self._lingerByItem = self._lingerByItem or {}
								local visualParts = self._lingerByItem[_sourceItem] or {}
								table.insert(visualParts, visualPart)
								self._lingerByItem[_sourceItem] = visualParts
								local visualPart2 = visualPart
								pcall(function()
									visualPart2:SetAttribute("_lingerCounted", true)
								end)
								self._lingerVisualCount += 1
							end

							activeEmit._lingerStartTime = os.clock()
							local v2 = activeEmit
							local v3 = visualPart
							task.delay(activeEmit.PartLife, function()
								self:_fireOnDestruction(v2, v3)

								if v3 then
									local v5 = false
									pcall(function()
										v5 = v3:GetAttribute("_lingerCounted") == true
									end)

									if v5 then
										self._lingerVisualCount = math.max(0, (self._lingerVisualCount or 0) - 1)
										pcall(function()
											v3:SetAttribute("_lingerCounted", nil)
										end)
									end

									self:_releaseOrDestroy(v2, v3)
								end

								if _sourceItem and self._lingerByItem and self._lingerByItem[_sourceItem] then
									local v5 = self._lingerByItem[_sourceItem]

									for i = #v5, 1, -1 do
										if v5[i] ~= v3 then
											continue
										end

										local count2 = #v5

										if i < count2 then
											v5[i] = v5[count2]
										end

										v5[count2] = nil
									end

									if #v5 == 0 then
										self._lingerByItem[_sourceItem] = nil
									end
								end
							end)
						else
							self:_fireOnDestruction(activeEmit, visualPart)
							self:_releaseOrDestroy(activeEmit, visualPart)
						end

						if activeEmit._scaleMapKeys and self._parentScaleMap then
							for _, _scaleMapKey in ipairs(activeEmit._scaleMapKeys) do
								self._parentScaleMap[_scaleMapKey] = nil
							end
						end

						if activeEmit._nestedAlive then
							activeEmit._nestedAlive[1] = false
						end

						local count2 = #activeEmits

						if v < count2 then
							activeEmits[v] = activeEmits[count2]
						end

						activeEmits[count2] = nil
					end
				else
					v += 1
				end
			end

			Apply.applyFrame()
		end

		if not RunService:IsClient() then
			self.Connection = RunService.Heartbeat:Connect(fn)
			return
		end

		count += 1
		self._renderStepName = "PartIclesEngine_" .. count

		if pcall(function()
			RunService:BindToRenderStep(self._renderStepName, Enum.RenderPriority.Last.Value + 1, fn)
		end) then
			self.Connection = "RenderStep"
			return
		end

		self._renderStepName = nil
		self.Connection = RunService.RenderStepped:Connect(fn)
	end

	function p:Deactivate()
		self._engineGen = (self._engineGen or 0) + 1

		if self.Connection then
			if self._renderStepName then
				pcall(function()
					RunService:UnbindFromRenderStep(self._renderStepName)
				end)
				self._renderStepName = nil
			elseif typeof(self.Connection) == "RBXScriptConnection" then
				self.Connection:Disconnect()
			end

			self.Connection = nil
		end

		if self._focusConn then
			self._focusConn:Disconnect()
			self._focusConn = nil
		end

		if self._blurConn then
			self._blurConn:Disconnect()
			self._blurConn = nil
		end

		Apply.reset()

		if self._parentScaleMap then
			table.clear(self._parentScaleMap)
		end

		if self._lingerByItem then
			table.clear(self._lingerByItem)
		end

		if self._evenCycleStore then
			table.clear(self._evenCycleStore)
		end

		self._lingerVisualCount = 0
		Pool.flushAll()

		for i = #self.ActiveEmits, 1, -1 do
			local activeEmit = self.ActiveEmits[i]

			if (not activeEmit.IsAnimate or activeEmit.Type ~= "Part" and activeEmit.Type ~= "Attachment" and activeEmit.Type ~= "Beam" and activeEmit.Type ~= "Model") and activeEmit.VisualPart then
				local v = activeEmit
				pcall(function()
					v.VisualPart:Destroy()
				end)
			end

			if activeEmit._nestedAlive then
				activeEmit._nestedAlive[1] = false
			end

			self.ActiveEmits[i] = nil
		end

		local v = {}

		for k in pairs(self.ActiveAnimates) do
			table.insert(v, k)
		end

		for _, v2 in ipairs(v) do
			local v3 = v2
			pcall(function()
				self:_cancelAnimation(v3)
			end)
		end

		table.clear(self.ActiveAnimates)

		for k, activeLoop in pairs(self.ActiveLoops) do
			local v2 = activeLoop
			pcall(function()
				task.cancel(v2)
			end)
			self.ActiveLoops[k] = nil
		end

		if self.ActiveChainLoops then
			for _, list in pairs(self.ActiveChainLoops) do
				for _, v2 in ipairs(list) do
					pcall(task.cancel, v2)
				end
			end

			table.clear(self.ActiveChainLoops)
		end

		if self._CachedFolder and self._CachedFolder.Parent then
			self._CachedFolder:Destroy()
		end

		self._CachedFolder = nil

		if self._CachedPoolFolder and self._CachedPoolFolder.Parent then
			self._CachedPoolFolder:Destroy()
		end

		self._CachedPoolFolder = nil

		local function sweep(folder)
			for _, descendant in folder:GetDescendants() do
				if descendant:GetAttribute("_PartIcleEmit") then
					pcall(descendant.Destroy, descendant)
				end
			end
		end

		sweep(workspace)
		sweep(game:GetService("Lighting"))
		local ScreenHost = require(script.Parent.ScreenHost)

		if ScreenHost.exists() then
			sweep(ScreenHost.get())
			ScreenHost.destroy()
		end

		local TexturePin = require(script.Parent.TexturePin)
		TexturePin.clear()
		Events.cleanup()

		if self.LinkService and self.LinkService.Deactivate then
			pcall(function()
				self.LinkService:Deactivate()
			end)
		end
	end

	function p:GetFolder()
		if self._CachedFolder and self._CachedFolder.Parent then
			return self._CachedFolder
		end

		local cachedFolder = workspace.Terrain:FindFirstChild("EmittedPartsUsingPart_icle")

		if not cachedFolder then
			cachedFolder = Instance.new("Folder")
			cachedFolder.Name = "EmittedPartsUsingPart_icle"
			cachedFolder.Archivable = false
			cachedFolder.Parent = workspace.Terrain
		end

		self._CachedFolder = cachedFolder
		return cachedFolder
	end

	function p:GetPoolFolder()
		if self._CachedPoolFolder and self._CachedPoolFolder.Parent then
			return self._CachedPoolFolder
		end

		local cachedPoolFolder = workspace.Terrain:FindFirstChild("Part_IclesPooled")

		if not cachedPoolFolder then
			cachedPoolFolder = Instance.new("Folder")
			cachedPoolFolder.Name = "Part_IclesPooled"
			cachedPoolFolder.Archivable = false
			cachedPoolFolder.Parent = workspace.Terrain
		end

		self._CachedPoolFolder = cachedPoolFolder
		return cachedPoolFolder
	end
end