function math.distance_two_points(p1, p2)
    return math.sqrt(math.pow((p1.x - p2.x), 2) + math.pow((p1.y - p2.y), 2) )
end

function math.check_collision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function math.check_circle_rectangle_collision(circle, rectangle)
  local circleDistance = {}
  circleDistance.x = math.abs(circle.x - (rectangle.x + rectangle.w / 2))
  circleDistance.y = math.abs(circle.y - (rectangle.y + rectangle.h / 2))

  if (circleDistance.x > (rectangle.w/2 + circle.r))  then
    return false
  end

  if (circleDistance.y > (rectangle.h/2 + circle.r)) then
    return false
  end

  if (circleDistance.x <= (rectangle.w/2)) then
     return true
  end

  if (circleDistance.y <= (rectangle.h/2)) then
    return true
  end

  local cornerDistance_sq = (circleDistance.x - rectangle.w/2)^2 + (circleDistance.y - rectangle.h/2)^2;

  return (cornerDistance_sq <= (circle.r^2))
end

-- https://love2d.org/forums/viewtopic.php?f=5&t=11752
function math.box_segment_intersection(x1,y1,x2,y2, l,t,w,h)
    local dx, dy  = x2-x1, y2-y1

    local t0, t1  = 0, 1
    local p, q, r

    for side = 1,4 do
        if     side == 1 then p,q = -dx, x1 - l
        elseif side == 2 then p,q =  dx, l + w - x1
        elseif side == 3 then p,q = -dy, y1 - t
        else                  p,q =  dy, t + h - y1
        end

        if p == 0 then
        if q < 0 then return nil end  -- Segment is parallel and outside the bbox
        else
        r = q / p
        if p < 0 then
            if     r > t1 then return nil
            elseif r > t0 then t0 = r
            end
        else -- p > 0
            if     r < t0 then return nil
            elseif r < t1 then t1 = r
            end
        end
        end
    end

    local ix1, iy1, ix2, iy2 = x1 + t0 * dx, y1 + t0 * dy,
                                x1 + t1 * dx, y1 + t1 * dy

    if ix1 == ix2 and iy1 == iy2 then return ix1, iy1 end
    return ix1, iy1, ix2, iy2
end

function math.point_is_in_bounding_box(p, bb)
    return bb.top_left_x <= p.x and p.x <= bb.bottom_right_x and bb.top_left_y <= p.y and p.y <= bb.bottom_right_y
end

function math.rad_between_two_points(pos_a, pos_b)
    local x2, y2 = pos_b.x, pos_b.y
    local x1, y1 = pos_a.x, pos_a.y
    local y = (y2 - y1)
    local x = (x2 - x1)
    return math.atan2(y, x)
end

function math.lerp_value(v0, v1, t)
    return (1 - t) * v0 + t * v1
end

function math.zero_vector()
    return { x = 0, y = 0 }
end