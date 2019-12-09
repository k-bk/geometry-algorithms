local lab = {}

local function plot(x) 
   autorun = false
   coroutine.yield(x) 
end
local function autoplot(x) 
   autorun = true
   coroutine.yield(x) 
end

function y_monotonic(shape)
   assert(#shape >= 3)

   local swaps = 0
   local res = { left = stack(), right = stack() }

   local top = array_min(shape, function(p,q) return p.y < q.y end)
   array_rotate_left(shape, top - 1)

   local side = (shape[#shape].y < shape[1].y) and "left" or "right"
   table.insert(res[side], shape[#shape])

   for i = 1, #shape - 1 do
      if side == "left" and shape[i].y > shape[i+1].y then
         swaps = swaps + 1
         side = "right"
      elseif side == "right" and shape[i].y < shape[i+1].y then
         swaps = swaps + 1
         side = "left"
      end
      res[side][shape[i]] = true
   end
   return swaps <= 2, res.left, res.right
end

function intersecting(p, q)
   if p == q then return false end
   local a,b,c,d = p[1],p[2],q[1],q[2]
   return orient(a, b, c) ~= orient(a, b, d) 
      and orient(c, d, a) ~= orient(c, d, b) 
end

function inside(shape, segment)
   for i = 2,#shape do
      if intersecting({ shape[i-1], shape[i] }, segment) then return false end
   end
   if intersecting({ shape[1], shape[#shape] }, segment) then return false end
   return true
end

function triangulate_monotonic(shape, left, right)

   -- sort the shape
   local sorted = {}
   local i,j = 1,#shape
   while i ~= j do
      if shape[i].y <= shape[j].y then
         table.insert(sorted, shape[i])
         i = i + 1
      else
         table.insert(sorted, shape[j])
         j = j - 1
      end
   end

   print("shape")
   for _,v in ipairs(sorted) do print (v) end

   shape = sorted
   local diagonals = {}
   local S = stack()
   local point

   S:push(shape[1])
   S:push(shape[2])

   for i = 3,#shape-1 do
      if ( left[shape[i]] and right[S:top()] )
         or ( right[shape[i]] and left[S:top()] ) 
      then -- if on different sides
         while S:top() do
            point = S:pop()
            if S:top() then -- if not last point on stack
               table.insert(diagonals, { point, shape[i] }) 
            end
         end
         S:push(point)
         S:push(shape[i])
      else -- if on the same side
         S:pop()
         while S:top() and inside(shape, { S:top(), shape[i] }) do
            table.insert(diagonals, { point, shape[i] }) 
            point = S:pop()
         end
         S:push(point)
         S:push(shape[i])
      end
   end

   S:pop()
   while #S > 1 do
      table.insert(diagonals, { S:pop(), shape[#shape] })
   end

   return diagonals
end

function lab.load()
   monotonic = "Narysuj wielokąt"
   state = "main"
   shape = {}
   left, right = {}, {}
   lab.update()
end

function lab.update(input)
   if input == "click" and mouse_position.x > ui_width + 10 then
      if state == "main" and #shape == 0 then
         state = "drawing"
         monotonic = "Narysuj wielokąt"
      end
      if state == "drawing" then
         snapped = false
         snap_mouse(shape[1])
         snap_mouse(shape[#shape])
      end
      if snapped then
         -- end drawing
         state = "main"
         result, left, right = y_monotonic(shape)
         monotonic = result and "TAK" or "NIE"
      else
         table.insert(shape, mouse_position)
      end
   end
end

function snap_mouse(point)
   if point and (point - mouse_position):len() < 15 then
      snapped = true
      mouse_position = point
   end
end

function lab.mousemoved()
   if state == "drawing" then
      snapped = false
      snap_mouse(shape[1])
      snap_mouse(shape[#shape])
   end
end

function lab.draw()
   ui_width, _ = UI.draw { x = 10, y = 10,
      UI.label { "y-monotoniczny:  " },
      UI.label { monotonic },
      UI.label { "" },
      UI.button( "Reset", function() shape = {} end ),
      UI.button( "Triangulacja", function() 
         state = "main" 
         diagonals = triangulate_monotonic(shape, left, right) 
      end ),
   }
   love.graphics.setColor(.7,.7,.7)
   love.graphics.line(ui_width + 20, 0, ui_width + 20, 2000)

   draw_polygon(shape, {1,0,0})
   if state == "drawing" then draw_red_point(mouse_position) end
end

function draw_red_point(p)
   local ps = love.graphics.getPointSize()
   love.graphics.setPointSize(10)
   love.graphics.points({{ p.x, p.y, 1,0,0 }})
   love.graphics.setPointSize(ps)
end

function draw_polygon(polygon, color)
   local r,g,b,a = love.graphics.getColor()
   local ps = love.graphics.getPointSize()
   local lw = love.graphics.getLineWidth()
   local shape = {}

   for _,point in ipairs(polygon) do
      table.insert(shape, point.x)
      table.insert(shape, point.y)
   end

   if state == "drawing" and mouse_position.x > ui_width + 10 then
      table.insert(shape, mouse_position.x)
      table.insert(shape, mouse_position.y)
   end

   if state == "drawing" then 
      love.graphics.setColor(.6,.6,.6)
   else
      love.graphics.setColor(color or {1,0,0}) 
   end
   love.graphics.setLineWidth(2)
   if #shape > 4 then love.graphics.polygon("line", shape) end
   love.graphics.setColor(0,0,0)
   love.graphics.setPointSize(6)
   love.graphics.points(shape)

   love.graphics.setLineWidth(lw)
   love.graphics.setPointSize(ps)
   love.graphics.setColor(r,g,b,a)
end

return lab
