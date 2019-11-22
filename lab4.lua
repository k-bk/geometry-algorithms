local lab = {}

local x,y = 1,2

local function plot(x) 
   autorun = false
   coroutine.yield(x) 
end
local function autoplot(x) 
   autorun = true
   coroutine.yield(x) 
end
local function as_lines(x)
   for _,s in ipairs(x) do
      s.style = "line"
      s.color = { 0.5, 0.5, 0.5 }
   end
end

function y_monotonic(shape)
   swaps = 0
   side = "left"
   res = {}
   left = {}
   right = {}
   for i = 2,#shape do
      if side == "left" and shape[i-1][2] > shape[i][2] then
         swaps = swaps + 1
         side = "right"
      elseif side == "right" and shape[i-1][2] < shape[i][2] then
         swaps = swaps + 1
         side = "left"
      end
      res[side] = shape[i]
   end
   return swaps <= 2, res.left, res.right
end

function pop(t)
   local res = t[#t]
   t[#t] = nil
   return res
end

function triangulate_monotonic(shape, left, right)
   table.sort(left, function(p,q) return p[2] > q[2] end)
   table.sort(right, function(p,q) return p[2] > q[2] end)

   triangles = {}

   l,r = pop(left), pop(right)
   while #left > 0 and #right > 0 do
      if #right == 0 or left[#left][y] < right[#right] then
         l1 = pop(left)
         table.insert(triangles, { l, r, l1, l, style = "line" })
      elseif #left == 0 or left[#left][y] > right[#right] then
         r1 = pop(right)
         table.insert(triangles, { r, l, r1, r, style = "line" })
      end
   end

   return triangles
end

function lab.load()
   monotonic = "false"
   state = "main"
   shape = {}
   left, right = {}, {}
   lab.update()
end

function lab.update(input)
   if input == "click" then
      if state == "drawing" then
         x,y = love.mouse.getPosition()
         table.insert(shape, v2(x,y))
      end
   end
end

function draw_shape(shape, closed)
   if #shape >= 2 then
      local _p = {}
      for _,p in ipairs(shape) do
         table.insert(_p, p[1])
         table.insert(_p, p[2])
      end
      if closed then
         table.insert(_p, shape[1][1])
         table.insert(_p, shape[1][2])
      end
      love.graphics.line(unpack(_p))
   end
end

function lab.draw()
   if state == "main" then
      graph_canvas_offset, _ = UI.draw { x = 10, y = 10,
         UI.label { "Wielokąt jest y-monotoniczny: "..tostring(monotonic) },
         UI.button( "Rysuj wielokąt", function() state = "drawing" end ),
         UI.button( "Triangulacja", function() 
            state = "triangulate" 
            get_content = triangulate_monotonic(left, right) 
         end ),
      }
   elseif state == "drawing" then
      graph_canvas_offset, _ = UI.draw { x = 10, y = 10,
         UI.button( "Zapisz", function() 
            shape[#shape] = nil
            state = "main" 
            monotonic, left, right = y_monotonic(shape)
         end ),
         UI.button( "Reset", function() shape = {} end ),
         UI.button( "Cofnij", function() 
            shape[#shape] = nil
            shape[#shape] = nil
         end ),
      }
   elseif state == "triangulate" then
   end

   w,h = love.graphics.getDimensions()
   love.graphics.setColor(0,0,0)
   draw_shape(shape, true)
   --[[
   love.graphics.setColor(1,0,0)
   draw_shape(left, false)
   love.graphics.setColor(0,1,0)
   draw_shape(right, false)
   --]]
   --love.graphics.setColor(1,1,1)
   --love.graphics.draw(graph_canvas, graph_canvas_offset + 10)
end

return lab
