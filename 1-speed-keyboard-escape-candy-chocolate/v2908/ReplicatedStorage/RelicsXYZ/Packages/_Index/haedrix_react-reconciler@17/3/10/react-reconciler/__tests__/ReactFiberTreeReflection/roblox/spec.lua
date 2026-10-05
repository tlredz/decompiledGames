local parent = script.Parent.Parent
local parent2 = script.Parent.Parent.Parent
local JestGlobals = require(parent2.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local LuauPolyfill = require(parent2.LuauPolyfill)
local object = LuauPolyfill.Object
local Shared = require(parent2.Shared)
local set = Shared.ReactInstanceMap.set
local ReactWorkTags = require(parent.ReactWorkTags)
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local functionComponent = ReactWorkTags.FunctionComponent
local suspenseComponent = ReactWorkTags.SuspenseComponent
local ReactFiberFlags = require(parent.ReactFiberFlags)
local noFlags = ReactFiberFlags.NoFlags
local placement = ReactFiberFlags.Placement
local hydrating = ReactFiberFlags.Hydrating
local ReactFiberLane = require(parent.ReactFiberLane)
local v = nil
describe("ReactFiberTreeReflection", function()
	beforeEach(function()
		jest.resetModules()
		local ReactFiberTreeReflection = require(parent.ReactFiberTreeReflection)
		v = ReactFiberTreeReflection
	end)
	describe("getSuspenseInstanceFromFiber", function()
		local getSuspenseInstanceFromFiber = nil
		beforeEach(function()
			getSuspenseInstanceFromFiber = v.getSuspenseInstanceFromFiber
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mockFiber(p)
			return object.assign({
				tag = suspenseComponent,
				alternate = nil,
				memoizedState = nil
			}, p)
		end

		it("returns the dehydrated memoized state from the fiber", function()
			local dehydrated = {}
			local v3 = object.assign({
				tag = suspenseComponent,
				alternate = nil,
				memoizedState = nil
			}, {
				memoizedState = {
					dehydrated = dehydrated
				}
			})
			expect(getSuspenseInstanceFromFiber(v3)).toBe(dehydrated)
		end)
		it("returns the dehydrated memoized state from the alternate fiber", function()
			local dehydrated = {}
			local v4 = mockFiber({
				alternate = object.assign({
					tag = suspenseComponent,
					alternate = nil,
					memoizedState = nil
				}, {
					memoizedState = {
						dehydrated = dehydrated
					}
				})
			}) -- equivalent call inferred; original call site unknown
			expect(getSuspenseInstanceFromFiber(v4)).toBe(dehydrated)
		end)
		it("returns null if the fiber does not have the SuspenseComponent tag", function()
			local v3 = mockFiber({
				tag = functionComponent
			}) -- equivalent call inferred; original call site unknown
			expect(getSuspenseInstanceFromFiber(v3)).toBe(nil)
		end)
	end)
	describe("getContainerFromFiber", function()
		local getContainerFromFiber = nil
		beforeEach(function()
			getContainerFromFiber = v.getContainerFromFiber
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mockFiber(p)
			return object.assign({
				tag = hostRoot
			}, p)
		end

		it("returns a container if fiber is a host root", function()
			local containerInfo = {}
			local v3 = object.assign({
				tag = hostRoot
			}, {
				stateNode = {
					containerInfo = containerInfo
				}
			})
			expect(getContainerFromFiber(v3)).toBe(containerInfo)
		end)
		it("returns null if the fiber is not a host root", function()
			local v3 = mockFiber({
				tag = functionComponent
			}) -- equivalent call inferred; original call site unknown
			expect(getContainerFromFiber(v3)).toBe(nil)
		end)
	end)
	describe("different fiber states", function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function mockFiber(p)
			return object.assign({
				alternate = nil,
				return_ = nil,
				tag = functionComponent,
				flags = noFlags,
				subtreeFlags = noFlags,
				lanes = ReactFiberLane.NoLanes,
				childLanes = ReactFiberLane.NoLanes
			}, p)
		end

		local current = nil

		local function generateIsFiberMounted(p)
			it(string.format("isFiberMounted() is %s", (tostring(p))), function()
				expect(v.isFiberMounted(current)).toBe(p)
			end)
		end

		local function generateIsMounted(p)
			it(string.format("isMounted() is %s", (tostring(p))), function()
				local v3 = {}
				set(v3, current)
				expect(v.isMounted(v3)).toBe(p)
			end)
		end

		describe("with an alternate fiber", function()
			describe("last return node has the HostRoot tag", function()
				beforeEach(function()
					local return_ = mockFiber({
						return_ = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, {
							tag = hostRoot
						})
					}) -- equivalent call inferred; original call site unknown
					local v6 = {
						alternate = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, nil),
						return_ = return_
					}
					current = object.assign({
						alternate = nil,
						return_ = nil,
						tag = functionComponent,
						flags = noFlags,
						subtreeFlags = noFlags,
						lanes = ReactFiberLane.NoLanes,
						childLanes = ReactFiberLane.NoLanes
					}, v6)
				end)
				local v3 = true
				it(string.format("isFiberMounted() is %s", (tostring(true))), function()
					expect(v.isFiberMounted(current)).toBe(v3)
				end)
				local v4 = true
				it(string.format("isMounted() is %s", (tostring(true))), function()
					local v5 = {}
					set(v5, current)
					expect(v.isMounted(v5)).toBe(v4)
				end)
				it("getNearestMountedFiber() returns the same fiber", function()
					expect(v.getNearestMountedFiber(current)).toBe(current)
				end)
			end)
			describe("last return node does not have the HostRoot tag", function()
				beforeEach(function()
					local return_ = mockFiber(nil) -- equivalent call inferred; original call site unknown
					local v4 = {
						alternate = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, nil),
						return_ = return_
					}
					current = object.assign({
						alternate = nil,
						return_ = nil,
						tag = functionComponent,
						flags = noFlags,
						subtreeFlags = noFlags,
						lanes = ReactFiberLane.NoLanes,
						childLanes = ReactFiberLane.NoLanes
					}, v4)
				end)
				it("getNearestMountedFiber() returns null", function()
					expect(v.getNearestMountedFiber(current)).toBe(nil)
				end)
				it("findCurrentFiberUsingSlowPath() throws", function()
					expect(function()
						v.findCurrentFiberUsingSlowPath(current)
					end).toThrow("Unable to find node on an unmounted component")
				end)
				local v3 = false
				it(string.format("isFiberMounted() is %s", (tostring(false))), function()
					expect(v.isFiberMounted(current)).toBe(v3)
				end)
				local v4 = false
				it(string.format("isMounted() is %s", (tostring(false))), function()
					local v5 = {}
					set(v5, current)
					expect(v.isMounted(v5)).toBe(v4)
				end)
			end)
			describe("fiber has the RootHost tag", function()
				beforeEach(function()
					local v3 = {
						alternate = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, nil),
						tag = hostRoot
					}
					current = object.assign({
						alternate = nil,
						return_ = nil,
						tag = functionComponent,
						flags = noFlags,
						subtreeFlags = noFlags,
						lanes = ReactFiberLane.NoLanes,
						childLanes = ReactFiberLane.NoLanes
					}, v3)
				end)
				it("getNearestMountedFiber() returns the same fiber", function()
					expect(v.getNearestMountedFiber(current)).toBe(current)
				end)
				it(
					"findCurrentFiberUsingSlowPath() returns the same fiber if the stateNode.current is the fiber",
					function()
						current.stateNode = {
							current = current
						}
						expect(v.findCurrentFiberUsingSlowPath(current)).toBe(current)
					end
				)
				it(
					"findCurrentFiberUsingSlowPath() returns the alternate fiber if the stateNode.current is not the given fiber",
					function()
						current.stateNode = {
							current = nil
						}
						expect(v.findCurrentFiberUsingSlowPath(current)).toBe(current.alternate)
					end
				)
				local v3 = true
				it(string.format("isFiberMounted() is %s", (tostring(true))), function()
					expect(v.isFiberMounted(current)).toBe(v3)
				end)
				local v4 = true
				it(string.format("isMounted() is %s", (tostring(true))), function()
					local v5 = {}
					set(v5, current)
					expect(v.isMounted(v5)).toBe(v4)
				end)
			end)
		end)
		describe("without an alternate fiber", function()
			describe("all its return nodes do not have the placement or hydrating flag", function()
				beforeEach(function()
					local v4 = {
						return_ = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, {
							tag = hostRoot
						})
					}
					local v5 = {
						return_ = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, v4)
					}
					current = object.assign({
						alternate = nil,
						return_ = nil,
						tag = functionComponent,
						flags = noFlags,
						subtreeFlags = noFlags,
						lanes = ReactFiberLane.NoLanes,
						childLanes = ReactFiberLane.NoLanes
					}, v5)
				end)
				it("getNearestMountedFiber() returns the same fiber", function()
					expect(v.getNearestMountedFiber(current)).toBe(current)
				end)
				it("findCurrentFiberUsingSlowPath() returns the same fiber", function()
					expect(v.findCurrentFiberUsingSlowPath(current)).toBe(current)
				end)
				local v3 = true
				it(string.format("isFiberMounted() is %s", (tostring(true))), function()
					expect(v.isFiberMounted(current)).toBe(v3)
				end)
				local v4 = true
				it(string.format("isMounted() is %s", (tostring(true))), function()
					local v5 = {}
					set(v5, current)
					expect(v.isMounted(v5)).toBe(v4)
				end)
			end)

			for k, v3 in {
				placement = placement,
				hydrating = hydrating
			} do
				local flags = v3
				describe(string.format("one of the return node has the %s flag", k), function()
					local return_ = nil
					beforeEach(function()
						return_ = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, {
							tag = hostRoot
						})
						local v7 = {
							return_ = return_,
							flags = flags
						}
						local v8 = {
							return_ = object.assign({
								alternate = nil,
								return_ = nil,
								tag = functionComponent,
								flags = noFlags,
								subtreeFlags = noFlags,
								lanes = ReactFiberLane.NoLanes,
								childLanes = ReactFiberLane.NoLanes
							}, v7)
						}
						current = object.assign({
							alternate = nil,
							return_ = nil,
							tag = functionComponent,
							flags = noFlags,
							subtreeFlags = noFlags,
							lanes = ReactFiberLane.NoLanes,
							childLanes = ReactFiberLane.NoLanes
						}, v8)
					end)
					it("getNearestMountedFiber() returns the parent fiber", function()
						expect(v.getNearestMountedFiber(current)).toBe(return_)
					end)
					it("findCurrentFiberUsingSlowPath() returns null", function()
						expect(v.findCurrentFiberUsingSlowPath(current)).toBe(nil)
					end)
					local v6 = false
					it(string.format("isFiberMounted() is %s", (tostring(false))), function()
						expect(v.isFiberMounted(current)).toBe(v6)
					end)
					local v7 = false
					it(string.format("isMounted() is %s", (tostring(false))), function()
						local v8 = {}
						set(v8, current)
						expect(v.isMounted(v8)).toBe(v7)
					end)
				end)
				local flags2 = v3
				describe(
					string.format("the return node of the fiber where it has the %s ", k) .. "flag does not have the HostRoot tags",
					function()
						beforeEach(function()
							local v6 = {
								return_ = object.assign({
									alternate = nil,
									return_ = nil,
									tag = functionComponent,
									flags = noFlags,
									subtreeFlags = noFlags,
									lanes = ReactFiberLane.NoLanes,
									childLanes = ReactFiberLane.NoLanes
								}, nil),
								flags = flags2
							}
							local v7 = {
								return_ = object.assign({
									alternate = nil,
									return_ = nil,
									tag = functionComponent,
									flags = noFlags,
									subtreeFlags = noFlags,
									lanes = ReactFiberLane.NoLanes,
									childLanes = ReactFiberLane.NoLanes
								}, v6)
							}
							current = object.assign({
								alternate = nil,
								return_ = nil,
								tag = functionComponent,
								flags = noFlags,
								subtreeFlags = noFlags,
								lanes = ReactFiberLane.NoLanes,
								childLanes = ReactFiberLane.NoLanes
							}, v7)
						end)
						it("getNearestMountedFiber() returns null", function()
							expect(v.getNearestMountedFiber(current)).toBe(nil)
						end)
						it("findCurrentFiberUsingSlowPath() throws", function()
							expect(function()
								v.findCurrentFiberUsingSlowPath(current)
							end).toThrow("Unable to find node on an unmounted component")
						end)
						local v6 = false
						it(string.format("isFiberMounted() is %s", (tostring(false))), function()
							expect(v.isFiberMounted(current)).toBe(v6)
						end)
						local v7 = false
						it(string.format("isMounted() is %s", (tostring(false))), function()
							local v8 = {}
							set(v8, current)
							expect(v.isMounted(v8)).toBe(v7)
						end)
					end
				)
			end
		end)
	end)
	describe("isFiberSuspenseAndTimedOut", function()
		local isFiberSuspenseAndTimedOut = nil
		beforeEach(function()
			isFiberSuspenseAndTimedOut = v.isFiberSuspenseAndTimedOut
		end)
		it("is true for a SuspenseComponent fiber when memoizedState.dehydrated is null", function()
			expect(isFiberSuspenseAndTimedOut({
				tag = suspenseComponent,
				memoizedState = {
					dehydrated = nil
				}
			})).toBe(true)
		end)
		it("is false if the fiber is not tagged as SuspenseComponent", function()
			expect(isFiberSuspenseAndTimedOut({
				tag = classComponent,
				memoizedState = {
					dehydrated = nil
				}
			})).toBe(false)
		end)
		it("is false if the fiber does not have memoizedState", function()
			expect(isFiberSuspenseAndTimedOut({
				tag = suspenseComponent,
				memoizedState = nil
			})).toBe(false)
		end)
		it("is false if the fiber memoizedState.dehydrated is not null", function()
			expect(isFiberSuspenseAndTimedOut({
				tag = suspenseComponent,
				memoizedState = {
					dehydrated = "foo"
				}
			})).toBe(false)
		end)
	end)
	describe("doesFiberContain", function()
		local doesFiberContain = nil
		beforeEach(function()
			doesFiberContain = v.doesFiberContain
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mockFiber(options)
			return object.assign({
				return_ = nil,
				alternate = nil
			}, options or {})
		end

		it("is true if the parent and the child are the same fiber", function()
			local v2 = mockFiber() -- equivalent call inferred; original call site unknown
			expect(doesFiberContain(v2, v2)).toBe(true)
		end)
		it("is true if the parent alternate and the child are the same fiber", function()
			local alternate = mockFiber() -- equivalent call inferred; original call site unknown
			local v3 = object.assign({
				return_ = nil,
				alternate = nil
			}, {
				alternate = alternate
			} or {})
			expect(doesFiberContain(v3, alternate)).toBe(true)
		end)
		it("is true if the child return node and the parent are the same fiber", function()
			local return_ = mockFiber() -- equivalent call inferred; original call site unknown
			local v3 = object.assign({
				return_ = nil,
				alternate = nil
			}, {
				return_ = return_
			} or {})
			expect(doesFiberContain(return_, v3)).toBe(true)
		end)
		it("is true if the child return node and the parent alternate are the same fiber", function()
			local v2 = mockFiber() -- equivalent call inferred; original call site unknown
			local v3 = object.assign({
				return_ = nil,
				alternate = nil
			}, {
				alternate = v2
			} or {})
			local v4 = object.assign({
				return_ = nil,
				alternate = nil
			}, {
				return_ = v2
			} or {})
			expect(doesFiberContain(v3, v4)).toBe(true)
		end)
		it("is false if none of the child parents are the parent fiber", function()
			local v2 = mockFiber() -- equivalent call inferred; original call site unknown
			local v3 = mockFiber() -- equivalent call inferred; original call site unknown
			expect(doesFiberContain(v2, v3)).toBe(false)
		end)
	end)
end)