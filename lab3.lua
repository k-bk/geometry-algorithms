local lab = {}

function sweep(segments)

   local T = {}
   local Q = { unpack(segments) }
   table.sort(Q, function(a,b) return a[1] < b[1] end)

   while #events > 0 do
      if segment_start then
         a,b = neighbours(T, s)
         if a and crossing(a, s) then
            insert(Q, crossing(a,s))
         end
         if b and crossing(b, s) then
            insert(Q, crossing(b,s))
         end
      end

      if segment_end then
         remove(T, s)
         a,b = neighbours(T, s)
         if a and b and crossing(a, b) then
            insert(Q, crossing(a,b))
         end
      end

      if segment_cross then
         
      end
   end

end

function lab.load()
end

function lab.update()
end

function lab.draw()
end
