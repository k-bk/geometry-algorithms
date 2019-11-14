local lab = {}

local eps = 1e-10 

local function plot(x) 
   autorun = false
   coroutine.yield(x) 
end
local function autoplot(x) 
   autorun = true
   coroutine.yield(x) 
end

function Graham(set)
   local points = {}
   for _,v in ipairs(set) do table.insert(points, v) end

   local pivot = points[1]
   local pivot_i = 1
   for i,p in ipairs(points) do
      if p[2] - pivot[2] < -eps or (p[2] - pivot[2] < eps and p[1] - pivot[1] < eps) then
         pivot = p
         pivot_i = i
      end
   end
   table.remove(points, pivot_i)
   table.sort(points, function (a,b) 
      o = orient(pivot, a, b)
      if o > 0 then 
         return true
      elseif o == 0 then
         if a[1] - b[1] < -eps then return true end
         if a[2] - b[2] < -eps then return true end
      end
      return false
   end)


   local strokes = { title = "Punkty posortowane względem "..pivot }
   for i = 2, #points do
      table.insert(strokes, { pivot, points[i], style = "line", color = {0,0,0,.1} })
   end

   local s = { pivot, points[1], points[2], style = "line", color = graph.c.green }
   local i = 3 
   local m = #points
   for i = 3,m do
      table.insert(s, points[i])
      while #s >= 3 and orient(s[#s-2], s[#s-1], s[#s]) <= 0 do
         table.remove(s, #s-1)
      end
      if #s >= 3 then
         current = { s[#s-2], s[#s-1], s[#s], color = graph.c.red, style = "line" }
         autoplot { s, current, points, title = "Algorytm Grahama" } -- , unpack(strokes) }
      end
   end
   s[#s+1] = s[1]

   local hull = { color = graph.c.red, unpack(s) }
   while true do
      plot { s, points, hull, title = "Algorytm Grahama, koniec" }
   end
end

function Jarvis(set)
   local points = {}
   for _,v in ipairs(set) do table.insert(points, v) end

   local pivot = points[1]
   local pivot_i = 1
   for i,p in ipairs(points) do
      if p[2] - pivot[2] < -eps or (p[2] - pivot[2] < eps and p[1] - pivot[1] < eps) then
         pivot = p
         pivot_i = i
      end
   end

   local s = { pivot, style = "line", color = graph.c.green }
   s[0] = pivot - v2(20,0) 

   repeat
      local min_angle = math.huge
      local first, middle = s[#s-1], s[#s]
      local s1 = first - middle
      local s1_len = s1:len()
      for _,last in ipairs(points) do
         local s2 = middle - last 
         local angle = math.acos(s1:dot(s2) / (s1_len * s2:len()))
         if angle < min_angle then
            min_angle = angle
            min_p = last 
         end
      end

      -- if angle is 0 or pi the points are collinear, middle is unnecessary
      if math.abs(min_angle) < eps
         or math.abs(min_angle - math.pi) < eps 
      then
         s[#s] = min_p
      else
         s[#s+1] = min_p
      end

      if #s >= 2 then
         plot { s, points, { color = graph.c.red, unpack(s) }, title = "Algorytm Jarvisa" }
      end
   until #s >= 2 and min_p == s[1] 

   local hull = { color = graph.c.red, unpack(s) }
   while true do
      plot { s, points, hull, title = "Algorytm Jarvisa, koniec" }
   end
end

function point_sets()
   local a, b, c = {}, {}, {}
   -- 1. a
   rand.in_range(v2(-100,100), v2(-100,100), 25, a)
   -- 1. b
   rand.on_circle(v2(0,0), 10, 100, b)
   -- 1. c
   rand.on_rectangle(v2(-10,-10), v2(10,10), 100, c)
   -- 1. d
   local d = { v2(0,0), v2(10,0), v2(10,10), v2(0,10) }
   rand.on_segment(v2(0,0), v2(10,0), 25, d)
   rand.on_segment(v2(0,0), v2(0,10), 25, d)
   rand.on_segment(v2(0,0), v2(10,10), 20, d)
   rand.on_segment(v2(10,0), v2(0,10), 20, d)

   sets = {
      { a, title = "100 punktów z przedziału <-100,100>" },
      { b, title = "100 punktów na okręgu o środku (0,0) i promienu 10" },
      { c, title = "100 punktów na prostokącie (-10,-10), (10,10)" },
      { d, title = "Punkty na bokach kwadratu i przekątnych" },
   }

   while true do
      for _,set in ipairs(sets) do
         coroutine.yield(set)
      end
   end

end

function lab.load()

   graph_canvas_offset = 40
   graph_canvas = love.graphics.newCanvas(love.window.getDesktopDimensions())
   get_point_set = coroutine.wrap(point_sets)

   function change_points()
      animation = false
      set = get_point_set()
      content = set
      points = set[1]
      lab.update()
   end
   function run_graham() 
      animation = true
      get_content = coroutine.wrap(function () return Graham(points) end) 
   end
   function run_jarvis() 
      animation = true
      get_content = coroutine.wrap(function () return Jarvis(points) end) 
   end

   change_points()
   run_jarvis()
end

function lab.update(input)
   if input == "click" then
      if animation then
         content = get_content()
      end
   elseif input == "stoper" then
      if animation and autorun then
         content = get_content()
      end
   end

   local w, h = love.graphics.getDimensions()
   love.graphics.setCanvas(graph_canvas)
   graph.graph(content, { width = w - graph_canvas_offset - 10, height = h })
   love.graphics.setCanvas()
end

function lab.draw()

   graph_canvas_offset, _ = UI.draw { x = 10, y = 10,
      UI.button( "Punkty", change_points ),
      UI.label {""},
      UI.button( "Graham", run_graham ),
      UI.button( "Jarvis", run_jarvis ),
   }

   love.graphics.setColor(1,1,1)
   love.graphics.draw(graph_canvas, graph_canvas_offset + 10)
end

return lab
