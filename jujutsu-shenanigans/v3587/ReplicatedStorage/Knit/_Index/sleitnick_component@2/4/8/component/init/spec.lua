return function()
	local parentModule = require(script.Parent)
	local CollectionService = game:GetService("CollectionService")
	local RunService = game:GetService("RunService")
	local folder = nil

	local function CreateTaggedInstance()
		local folder2 = Instance.new("Folder")
		CollectionService:AddTag(folder2, "__KnitTestComponent__")
		folder2.Name = "ComponentTest"
		folder2.Archivable = false
		folder2.Parent = folder
		return folder2
	end

	local v = parentModule.new({
		Tag = "__KnitTestComponent__",
		Ancestors = { workspace, game:GetService("Lighting") },
		Extensions = {
			{
				ShouldConstruct = function(_)
					return true
				end,
				Constructing = function(p)
					p.Data = "a"
					p.DidHeartbeat = false
					p.DidStepped = false
					p.DidRenderStepped = false
				end,
				Constructed = function(p)
					p.Data ..= "c"
				end,
				Starting = function(p)
					p.Data ..= "d"
				end,
				Started = function(p)
					p.Data ..= "f"
				end,
				Stopping = function(p)
					p.Data ..= "g"
				end,
				Stopped = function(p)
					p.Data ..= "i"
				end
			}
		}
	})
	local v2 = parentModule.new({
		Tag = "__KnitTestComponent__"
	})

	function v2:GetData()
		return true
	end

	function v:Construct()
		self.Data ..= "b"
	end

	function v:Start()
		self.Another = self:GetComponent(v2)
		self.Data ..= "e"
	end

	function v:Stop()
		self.Data ..= "h"
	end

	function v:HeartbeatUpdate(_)
		self.DidHeartbeat = true
	end

	function v:SteppedUpdate(_)
		self.DidStepped = true
	end

	function v:RenderSteppedUpdate(_)
		self.DidRenderStepped = true
	end

	beforeAll(function()
		folder = Instance.new("Folder")
		folder.Name = "KnitComponentTest"
		folder.Archivable = false
		folder.Parent = workspace
	end)
	afterEach(function()
		folder:ClearAllChildren()
	end)
	afterAll(function()
		folder:Destroy()
		v:Destroy()
	end)
	describe("Component", function()
		it("should capture start and stop events", function()
			local count = 0
			local count2 = 0
			local startedConnection = v.Started:Connect(function()
				count += 1
			end)
			local stoppedConnection = v.Stopped:Connect(function()
				count2 += 1
			end)
			local folder2 = Instance.new("Folder")
			CollectionService:AddTag(folder2, "__KnitTestComponent__")
			folder2.Name = "ComponentTest"
			folder2.Archivable = false
			folder2.Parent = folder
			task.wait()
			folder2:Destroy()
			task.wait()
			startedConnection:Disconnect()
			stoppedConnection:Disconnect()
			expect(count).to.equal(1)
			expect(count2).to.equal(1)
		end)
		it("should be able to get component from the instance", function()
			local folder2 = Instance.new("Folder")
			CollectionService:AddTag(folder2, "__KnitTestComponent__")
			folder2.Name = "ComponentTest"
			folder2.Archivable = false
			folder2.Parent = folder
			task.wait()
			local v3 = v:FromInstance(folder2)
			expect(v3).to.be.ok()
		end)
		it("should be able to get all component instances existing", function()
			local v3 = table.create(3)
			local folder2 = Instance.new("Folder")
			CollectionService:AddTag(folder2, "__KnitTestComponent__")
			folder2.Name = "ComponentTest"
			folder2.Archivable = false
			folder2.Parent = folder
			v3[1] = folder2
			local folder3 = Instance.new("Folder")
			CollectionService:AddTag(folder3, "__KnitTestComponent__")
			folder3.Name = "ComponentTest"
			folder3.Archivable = false
			folder3.Parent = folder
			v3[2] = folder3
			local folder4 = Instance.new("Folder")
			CollectionService:AddTag(folder4, "__KnitTestComponent__")
			folder4.Name = "ComponentTest"
			folder4.Archivable = false
			folder4.Parent = folder
			v3[3] = folder4
			task.wait()
			local all = v:GetAll()
			expect(all).to.be.a("table")
			expect(#all).to.equal(3)

			for _, v4 in ipairs(all) do
				expect(table.find(v3, v4.Instance)).to.be.ok()
			end
		end)
		it("should call lifecycle methods and extension functions", function()
			local folder2 = Instance.new("Folder")
			CollectionService:AddTag(folder2, "__KnitTestComponent__")
			folder2.Name = "ComponentTest"
			folder2.Archivable = false
			folder2.Parent = folder
			task.wait(0.2)
			local v3 = v:FromInstance(folder2)
			expect(v3).to.be.ok()
			expect(v3.Data).to.equal("abcdef")
			expect(v3.DidHeartbeat).to.equal(true)
			expect(v3.DidStepped).to.equal(RunService:IsRunning())
			expect(v3.DidRenderStepped).to.never.equal(true)
			folder2:Destroy()
			task.wait()
			expect(v3.Data).to.equal("abcdefghi")
		end)
		it("should get another component linked to the same instance", function()
			local folder2 = Instance.new("Folder")
			CollectionService:AddTag(folder2, "__KnitTestComponent__")
			folder2.Name = "ComponentTest"
			folder2.Archivable = false
			folder2.Parent = folder
			task.wait()
			local v3 = v:FromInstance(folder2)
			expect(v3).to.be.ok()
			expect(v3.Another).to.be.ok()
			expect(v3.Another:GetData()).to.equal(true)
		end)
		it("should use extension to decide whether or not to construct", function()
			local v3 = {
				c = true
			}

			function v3.ShouldConstruct(_)
				return v3.c
			end

			local v4 = {
				c = true
			}

			function v4.ShouldConstruct(_)
				return v4.c
			end

			local v5 = {
				c = true
			}

			function v5.ShouldConstruct(_)
				return v5.c
			end

			local v6 = parentModule.new({
				Tag = "__KnitTestComponent__",
				Extensions = { v3 }
			})
			local v7 = parentModule.new({
				Tag = "__KnitTestComponent__",
				Extensions = { v3, v4 }
			})
			local v8 = parentModule.new({
				Tag = "__KnitTestComponent__",
				Extensions = { v3, v4, v5 }
			})

			-- equivalent calls inferred from this helper; original call sites unknown
			local function SetE(p, p2, p3)
				v3.c = p
				v4.c = p2
				v5.c = p3
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function Check(folder2, object, p)
				local v9 = object:FromInstance(folder2)

				if p then
					expect(v9).to.be.ok()
				else
					expect(v9).to.never.be.ok()
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function CreateAndCheckAll(p, p2, p3)
				local folder2 = Instance.new("Folder")
				CollectionService:AddTag(folder2, "__KnitTestComponent__")
				folder2.Name = "ComponentTest"
				folder2.Archivable = false
				folder2.Parent = folder
				task.wait()
				Check(folder2, v6, p)
				Check(folder2, v7, p2)
				Check(folder2, v8, p3)
			end

			SetE(true, true, true) -- equivalent call inferred; original call site unknown
			CreateAndCheckAll(true, true, true) -- equivalent call inferred; original call site unknown
			SetE(false, false, false) -- equivalent call inferred; original call site unknown
			CreateAndCheckAll(false, false, false) -- equivalent call inferred; original call site unknown
			SetE(true, false, true) -- equivalent call inferred; original call site unknown
			CreateAndCheckAll(true, false, false) -- equivalent call inferred; original call site unknown
			SetE(false, false, true) -- equivalent call inferred; original call site unknown
			CreateAndCheckAll(false, false, false) -- equivalent call inferred; original call site unknown
		end)
		it("should decide whether or not to use extend", function()
			local v3 = {
				extend = true
			}

			function v3.ShouldExtend(_)
				return v3.extend
			end

			function v3:Constructing()
				self.E1 = true
			end

			local v4 = {
				extend = true
			}

			function v4.ShouldExtend(_)
				return v4.extend
			end

			function v4:Constructing()
				self.E2 = true
			end

			local v5 = parentModule.new({
				Tag = "__KnitTestComponent__",
				Extensions = { v3, v4 }
			})

			local function SetAndCheck(extend, extend2)
				v3.extend = extend
				v4.extend = extend2
				local folder2 = Instance.new("Folder")
				CollectionService:AddTag(folder2, "__KnitTestComponent__")
				folder2.Name = "ComponentTest"
				folder2.Archivable = false
				folder2.Parent = folder
				task.wait()
				local v6 = v5:FromInstance(folder2)
				expect(v6).to.be.ok()

				if extend then
					expect(v6.E1).to.equal(true)
				else
					expect(v6.E1).to.never.be.ok()
				end

				if extend2 then
					expect(v6.E2).to.equal(true)
				else
					expect(v6.E2).to.never.be.ok()
				end
			end

			SetAndCheck(true, true)
			SetAndCheck(false, false)
			SetAndCheck(true, false)
			SetAndCheck(false, true)
		end)
		it("should allow yielding within construct", function()
			local v3 = parentModule.new({
				Tag = "CustomTag"
			})
			local count = 0

			function v3.Construct(_)
				count += 1
				task.wait(0.5)
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.Parent = game:GetService("ReplicatedStorage")
			CollectionService:AddTag(part, "CustomTag")
			local clone = part:Clone()
			clone.Parent = workspace
			task.wait(0.6)
			expect(count).to.equal(1)
			part:Destroy()
			clone:Destroy()
		end)
		it("should wait for instance", function()
			local part = Instance.new("Part")
			part.Anchored = true
			part.Parent = workspace
			task.delay(0.1, function()
				CollectionService:AddTag(part, "__KnitTestComponent__")
			end)
			local v3, v4 = v:WaitForInstance(part):timeout(1):await()
			expect(v3).to.equal(true)
			expect(v4).to.be.a("table")
			expect(v4.Instance).to.equal(part)
			part:Destroy()
		end)
	end)
end