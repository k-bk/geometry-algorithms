local rand = {} 

function rand.double(min, max)
   return love.math.random() * (max - min) + min
end

function rand.in_range(xrange, yrange, count, buffer)
   local buffer = buffer or {}
   for i = 1,count do
      local p = v2(rand.double(xrange[1], xrange[2]), rand.double(yrange[1], yrange[2]))
      table.insert(buffer, p)
   end
   return buffer
end

function rand.on_circle(center, radius, count, buffer)
   local buffer = buffer or {}
   for i = 1,count do
      local angle = rand.double(0, 2*math.pi)
      local p = center + v2(radius * math.cos(angle), radius * math.sin(angle))
      table.insert(buffer, p)
   end
   return buffer
end

function rand.on_segment(a, b, count, buffer)
   local buffer = buffer or {}
   for i = 1,count do
      local t = rand.double(0, 1) 
      local p = (1-t)*a + t*b 
      table.insert(buffer, p)
   end
   return buffer
end

function rand.on_rectangle(a, b, count, buffer)
   local cc = count / 4
   local buffer = buffer or {}
   rand.on_segment(a, v2(a[1],b[2]), cc, buffer)
   rand.on_segment(v2(a[1],b[2]), b, cc, buffer)
   rand.on_segment(b, v2(b[1],a[2]), cc, buffer)
   rand.on_segment(v2(b[1],a[2]), a, cc, buffer)
   return buffer
end

local eps = 1e-3
function rand.segments(xrange, yrange, count, buffer)
   local buffer = buffer or {}
   local i = 0
   while i < count do
      local p1 = v2(rand.double(xrange[1], xrange[2]), rand.double(yrange[1], yrange[2]))
      local p2 = v2(rand.double(xrange[1], xrange[2]), rand.double(yrange[1], yrange[2]))
      local segment_valid = math.abs(p1[1] - p2[1]) > eps 
      for _,seg in ipairs(buffer) do 
         for _,p in ipairs(seg) do
            if (p1 - p):len() < eps or (p2 - p):len() < eps then
               segment_valid = false
               break
            end
         end
      end
      if segment_valid then
         i = i + 1
         if p1[1] < p2[1] then
            table.insert(buffer, { p1, p2 })
         else
            table.insert(buffer, { p2, p1 })
         end
      end
   end
   return buffer
end

return rand
