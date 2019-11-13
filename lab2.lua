local lab = {}

local rand = require "rand"
local UI = require "UI"

function lab.lab2()
   local plot = function (x) autorun = false; coroutine.yield(x) end
   local autoplot = function (x) autorun = true; coroutine.yield(x) end

   points = { a = {}, b = {}, c = {} }
   -- 1. a
   rand.in_range(v2(-100,100), v2(-100,100), 100, points.a)
   -- 1. b
   rand.on_circle(v2(0,0), 10, 100, points.b)
   -- 1. c
   rand.on_rectangle(v2(-10,-10), v2(10,10), 100, points.c)
   -- 1. d
   points.d = { v2(0,0), v2(10,0), v2(10,10), v2(0,10) }
   rand.on_segment(v2(0,0), v2(10,0), 25, points.d)
   rand.on_segment(v2(0,0), v2(0,10), 25, points.d)
   rand.on_segment(v2(0,0), v2(10,10), 20, points.d)
   rand.on_segment(v2(10,0), v2(0,10), 20, points.d)

   plot { points.a, title = "100 punktów z przedziału <-100,100>" }
   plot { points.b, title = "100 punktów na okręgu o środku (0,0) i promienu 10" }
   plot { points.c, title = "100 punktów na prostokącie (-10,-10), (10,10)" }
   plot { points.d, title = "Punkty na bokach kwadratu i przekątnych" }

   local rectangle = { graph.c.blue }
   rand.on_rectangle(v2(0,0), v2(150,50), 30, rectangle)
   plot { rectangle, title = "Losowe punkty na prostokącie" }

   local points = { color = graph.c.blue }
   rand.in_range(v2(-1e3,1e3), v2(-1e3,1e3), 30, points)
   plot { points, title = "Punkty z przedziału  <-1000,1000>" }

   points = rectangle
   local pivot = points[1]
   local pivot_i = 1
   for i,p in ipairs(points) do
      if p[2] < pivot[2] or (p[2] == pivot[2] and p[1] < pivot[1]) then
         pivot = p
         pivot_i = i
      end
   end
   table.remove(points, pivot_i)

   ----------------------
   -- Algorytm Grahama 
   ----------------------

   table.sort(points, function (a,b) return orient(pivot, a, b) > 0 end)

   local strokes = { points, title = "Punkty posortowane względem "..pivot } 
   for i = 2, #points do
      table.insert(strokes, { pivot, points[i], style = "line", color = graph.c.green })
      autoplot( strokes )
   end

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
   plot { s, p, hull, title = "Algorytm Grahama, koniec" }

   ----------------------
   -- Algorytm Jarvisa
   ----------------------

   local eps = 1e-2
   local s = { v2(pivot[1]-10, pivot[2]), pivot, style = "line", color = graph.c.green }

   repeat
      local min_angle = math.huge
      local first, middle = s[#s-1], s[#s]
      local s1 = first - middle
      local s1_len = s1:len()
      table.insert(points,pivot)

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
      autoplot { points, s, {color=graph.c.red, unpack(s)}, title = "Algorytm Jarvisa" }
   until min_p == pivot 

   s[1] = pivot
   local hull = { unpack(s) }
   hull.color = graph.c.red
   hull.style = "point"
   while true do
      plot { s, points, hull, title = "Algorytm Jarvisa, koniec" }
   end
end

function lab.draw()
end

return lab
