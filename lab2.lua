function random_on_segment(a, b, buffer)
   local buffer = buffer or {}
   for i = 1,10 do
      local t = love.math.random() 
      local p = (1-t)*a + t*b 
      table.insert(buffer, p)
   end
   return points
end

function random_on_rectangle(a, b, buffer)
   local buffer = buffer or {}
   random_on_segment(a, v2(a[1],b[2]), buffer)
   random_on_segment(v2(a[1],b[2]), b, buffer)
   random_on_segment(b, v2(b[1],a[2]), buffer)
   random_on_segment(v2(b[1],a[2]), a, buffer)
   return buffer
end

function lab2()
   local plot = function (x) autorun = false; coroutine.yield(x) end
   local autoplot = function (x) autorun = true; coroutine.yield(x) end

   local rectangle = random_on_rectangle(v2(0,0), v2(150,50))
   rectangle.color = graph.c.blue
   plot { rectangle, title = "Losowe punkty na prostokącie" }

   local points = { color = graph.c.blue }
   for i = 1,100 do
      local p = v2(rand_double(-1000, 1000), rand_double(-1000, 1000))
      table.insert(points, p)
   end
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
      --autoplot( strokes )
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
      --plot { s, p, title = "Algorytm Grahama" }
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
   local s = { v2(pivot[1] - 10,pivot[2]), pivot, 
      style = "line", color = graph.c.green }

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

      -- if angle is 0 or pi
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
