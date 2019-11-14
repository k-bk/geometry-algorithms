local lab = {}

local function plot(x) 
   autorun = false
   coroutine.yield(x) 
end
local function autoplot(x) 
   autorun = true
   if not skip then
      skip = coroutine.yield(x) 
   end
end

function Graham(points)
   local pivot = points[1]
   local pivot_i = 1
   for i,p in ipairs(points) do
      if p[2] < pivot[2] or (p[2] == pivot[2] and p[1] < pivot[1]) then
         pivot = p
         pivot_i = i
      end
   end
   table.remove(points, pivot_i)
   table.sort(points, function (a,b) return orient(pivot, a, b) > 0 end)

   local strokes = { points, title = "Punkty posortowane względem "..pivot } 
   for i = 2, #points do
      table.insert(strokes, { pivot, points[i], style = "line", color = graph.c.green })
      plot ( strokes )
   end
   plot( strokes )

   local p = points
   local s = { pivot, p[1], p[2], style = "line", color = graph.c.green }
   local i = #s + 1 
   local m = #p
   while i <= m do
      o = orient(s[#s-1], s[#s], p[i])
      if o > 0 then
         table.insert(s, p[i])
         i = i + 1
      elseif o == 0 then
         s[#s] = p[i]
         i = i + 1
      else
         s[#s] = nil
      end
      autoplot { s, p, title = "Algorytm Grahama" }
   end
   table.insert(s, s[1])

   local hull = { unpack(s) }
   hull.color = graph.c.red
   hull.style = "point"
   while true do
      plot { s, p, hull, title = "Algorytm Grahama, koniec" }
   end
end

function Jarvis(points)
   local pivot = points[1]
   local pivot_i = 1
   for i,p in ipairs(points) do
      if p[2] < pivot[2] or (p[2] == pivot[2] and p[1] < pivot[1]) then
         pivot = p
         pivot_i = i
      end
   end

   local eps = 1e-5
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
         autoplot { s, points, { color = graph.c.red, unpack(s) }, title = "Algorytm Jarvisa" }
      end
   until min_p == pivot 

   local hull = { unpack(s) }
   hull.color = graph.c.red
   hull.style = "point"
   while true do
      plot { s, points, hull, title = "Algorytm Jarvisa, koniec" }
   end
end


function lab.load()

   graph_canvas = love.graphics.newCanvas(love.window.getDesktopDimensions())

   local points
   local set = { a = {}, b = {}, c = {} }
   -- 1. a
   rand.in_range(v2(-100,100), v2(-100,100), 100, set.a)
   -- 1. b
   rand.on_circle(v2(0,0), 10, 100, set.b)
   -- 1. c
   rand.on_rectangle(v2(-10,-10), v2(10,10), 100, set.c)
   -- 1. d
   set.d = { v2(0,0), v2(10,0), v2(10,10), v2(0,10) }
   rand.on_segment(v2(0,0), v2(10,0), 25, set.d)
   rand.on_segment(v2(0,0), v2(0,10), 25, set.d)
   rand.on_segment(v2(0,0), v2(10,10), 20, set.d)
   rand.on_segment(v2(10,0), v2(0,10), 20, set.d)

   points = set.a
   plot { points, title = "100 punktów z przedziału <-100,100>" }
   points = set.b
   plot { points, title = "100 punktów na okręgu o środku (0,0) i promienu 10" }
   points = set.c
   plot { points, title = "100 punktów na prostokącie (-10,-10), (10,10)" }
   --points = set.d
   plot { points, title = "Punkty na bokach kwadratu i przekątnych" }

   run_graham = function () get_content = coroutine.wrap(function () return Graham(points) end) end
   run_jarvis = function () get_content = coroutine.wrap(function () return Jarvis(points) end) end

   run_graham()
   content = get_content()
end

function lab.update(input)
   if input == "click" then
      content = get_content()
   elseif input == "stoper" then
   end
end

function lab.draw()

   local ui_x, ui_y = 10,10
   local w, h = love.graphics.getDimensions()
   local offset_x, _ = UI.draw { x = ui_x, y = ui_y,
      UI.button( "Graham", run_graham ),
      UI.button( "Jarvis", run_jarvis ),
   }
   love.graphics.setCanvas(graph_canvas)
   graph.graph(content, { width = w - offset_x - ui_x, height = h - ui_y })
   love.graphics.setCanvas()
   love.graphics.setColor(1,1,1)
   love.graphics.draw(graph_canvas, offset_x + ui_x)

end

return lab
