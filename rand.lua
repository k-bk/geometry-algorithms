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

function rand.segments(xrange, yrange, count, buffer)
   local buffer = buffer or {}
   for i = 1,count do
      for _,p in ipairs(buffer) do
         local p1 = v2(rand.double(xrange[1], xrange[2]), rand.double(yrange[1], yrange[2]))
         local p2 = v2(rand.double(xrange[1], xrange[2]), rand.double(yrange[1], yrange[2]))
      end
   end
end

return rand
