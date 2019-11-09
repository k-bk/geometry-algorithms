function points_on_line(a, b, points)
   -- 1.d)
   local points = points or {}
   for i = 1,10 do
      local t = love.math.random() 
      local p = (1-t)*a + t*b 
      table.insert(points, p)
   end
   return points
end

function lab2()
   local plot = function (x) autorun = false; coroutine.yield(x) end
   local autoplot = function (x) autorun = true; coroutine.yield(x) end

   local rectangle = { color = graph.c.blue }
   points_on_line(v2(0,0), v2(100,0), rectangle)
   points_on_line(v2(100,0), v2(100,50), rectangle)
   points_on_line(v2(100,50), v2(0,50), rectangle)
   points_on_line(v2(0,50), v2(0,0), rectangle)
   plot { rectangle, title = "Losowe punkty na prostokącie" }

   local points = { color = graph.c.blue }
   for i = 1,100 do
      local p = v2(rand_double(-1000, 1000), rand_double(-1000, 1000))
      table.insert(points, p)
   end
   plot { points, title = "Punkty z przedziału  <-1000,1000>" }

   points = rectangle
   table.sort(points, function (a,b) return a[2] < b[2] end)
   local min = points[1]
   for _,p in ipairs(points) do
      if p[2] ~= points[1][2] then
         break
      end
      if p[1] < min[1] then
         min = p
      end
   end

   local pivot = min

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
   local s = { p[1], p[2], p[3], style = "line", color = graph.c.green }
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

   local eps = 1e-5
   local pivot = points[1]
   local s = { v2(pivot[1] - 50,pivot[2]), pivot, 
      style = "line", color = graph.c.green }

   repeat
      local min_angle = math.huge
      local first, middle = s[#s-1], s[#s]
      local s1 = first - middle
      local s1_len = s1:len()

      for _,last in ipairs(points) do
         local s2 = last - middle 
         local angle = math.asin(s1:dot(s2) / (s1_len * s2:len()))
         if angle < min_angle then
            min_angle = angle
            min_p = last 
         end
      end

      if min_angle < eps and min_angle > -eps then
         table.remove(s, #s)
      end
      table.insert(s, min_p)
      autoplot { s, points, title = "Algorytm Jarvisa" }
   until min_p == pivot 

   table.remove(s, 1)

   local hull = { unpack(s) }
   hull.color = graph.c.red
   hull.style = "point"
   while true do
      plot { s, points, hull, title = "Algorytm Jarvisa, koniec" }
   end
end
