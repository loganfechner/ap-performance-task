local tilesize = require "tilesize"
local Delaunay = require "delaunay"
	local Point = Delaunay.Point
	local Edge = Delaunay.Edge
local Kruskals = require "kruskals"
local MST = { points = {}, edges = {}, tree = {} }

local function compare(a, b)
	if a:length() < b:length() then return a end
end

local function clearTable(t)
	local remove = table.remove
	for i = #t, 1, -1 do
		remove(t, i)
	end
end

function MST:initialize(rooms)
	if #self.points > 0 then
		clearTable(self.points)
	end
	if #self.edges > 0 then
		clearTable(self.edges)
	end
	if #self.tree > 0 then
		clearTable(self.tree)
	end

	-- Get the points
	local floor = math.floor
	for i = #rooms, 1, -1 do
		local x = floor(rooms[i].x + rooms[i].width / 2)
		local y = floor(rooms[i].y + rooms[i].height / 2)
		self.points[i] = Point(x, y)
	end

	-- Get the graph
	local triangles = Delaunay.triangulate(unpack(self.points))
	for i = 1, #triangles do
		local p1 = triangles[i].p1
		local p2 = triangles[i].p2
		local p3 = triangles[i].p3

		if #self.edges > 1 then
			local a = Edge(p1, p2)
			local b = Edge(p2, p3)
			local c = Edge(p1, p3)

			if not self:edgeAdded(self.edges, a) then
				self.edges[#self.edges+1] = a
			end
			if not self:edgeAdded(self.edges, b) then
				self.edges[#self.edges+1] = b
			end
			if not self:edgeAdded(self.edges, c) then
				self.edges[#self.edges+1] = c
			end
		else
		    self.edges[#self.edges+1] = Edge(p1, p2)
			self.edges[#self.edges+1] = Edge(p2, p3)
			self.edges[#self.edges+1] = Edge(p1, p3)
		end
	end

	-- Sort edges least to greatest
	local sort = table.sort
	sort(self.edges, compare)

	-- Create the minimum spanning tree!
	self.tree = Kruskals(self.points, self.edges)
end

function MST:edgeAdded(edges, edge)
	for i = 1, #edges do
		local temp = self.edges[i]
		if temp:same(edge) then
			return true
		end
	end
	return false
end

function MST:getTree()
	return self.tree
end

function MST:draw()
	for i = 1, #self.tree do
		local p1 = self.tree[i].p1
		local p2 = self.tree[i].p2
		local x1 = p1.x * tilesize
		local x2 = p2.x * tilesize
		local y1 = p1.y * tilesize
		local y2 = p2.y * tilesize

		love.graphics.setColor(0,255,0)
		love.graphics.line(x1 - 1, y1 - 1, x2 - 1, y2 - 1)
		love.graphics.line(x1, y1, x2, y2)
		love.graphics.line(x1 + 1, y1 + 1, x2 + 1, y2 + 1)
	end
end

return MST