-- Transformer
Transformer = Scan.Transform.create()
-- Transformer:setAlphaBetaGamma()
-- Transformer:setPosition()
-- Transformer:setYawPitchRoll()

-- Scanner
ScanProvider = Scan.Provider.RemoteScanner.create()
ScanProvider:setIPAddress('192.168.1.100')
ScanProvider:setSensorType('LMSX00')
ScanProvider:register( 'OnNewScan', 'HandleOnNewScan' )
ScanProvider:start()

-- Cubic Area Filter / Scan Window / Region Of Interest
local cubicAreaFilter = Scan.CubicAreaFilter.create()
cubicAreaFilter:setXRange(Viewer.MinX, Viewer.MaxX)
cubicAreaFilter:setYRange(Viewer.MinY, Viewer.MaxY)
if Viewer.EnableBounds then cubicAreaFilter:setEnabled(true) end

-- Decorations
local pointDecoration = Viewer.Decoration
pointDecoration:setGraphType('DOT')
local lineSegmentPointDecoration = View.ShapeDecoration.create()
lineSegmentPointDecoration:setPointSize(40.0)
lineSegmentPointDecoration:setPointType('CROSS')
lineSegmentPointDecoration:setFillColor(0,0,255,255)
local lineSegmentDecoration = View.ShapeDecoration.create()
lineSegmentDecoration:setLineColor(255,0,0,255)

-- Shape fitter
local fitter = Point.ShapeFitter.create()

function AnalyseLineSegment(lineSegment)
  local p1, p2 = lineSegment:getLineParameters()
  local centre = Point.create((p1:getX() + p2:getX()) / 2, (p1:getY() + p2:getY()) / 2)
  -- local xDiff, yDiff = math.abs(p1:getX() - p2:getX()), math.abs(p1:getY() - p2:getY())
  -- local angleRadians = math.atan(yDiff/xDiff)
  return p1, p2, centre
end

function CalculateRadialDistances(p1, p2, centre)
  local p1D = math.sqrt(p1:getX()^2 + p1:getY()^2)
  local p2D = math.sqrt(p2:getX()^2 + p2:getY()^2)
  local centreD = math.sqrt(centre:getX()^2 + centre:getY()^2)
  return p1D, p2D, centreD
end

-- Scan handler
function HandleOnNewScan(scan) -- Scan is 2D Polar
  -- Cubic Area Filter
  scan = cubicAreaFilter:filter(scan)

  -- Scan -> Point Cloud (3D Cartesian)
  local pointCloud = Transformer:transformToPointCloud(scan)
  -- Viewer.ViewerPointClouds:addPointCloud(pointCloud)
  -- Viewer.ViewerPointClouds:present()

  -- Scan -> Profile
  -- local profile = scan:toProfile()
  -- local profileDecoration = Viewer.Decoration
  -- profileDecoration:setGraphType('LINE')
  -- Viewer.ViewerProfiles:addProfile(profile, profileDecoration)
  -- Viewer.ViewerProfiles:present()

  -- Point Cloud (3D Cartesian) -> 2D Cartesian
  local x, y, _, _ = pointCloud:toVector()
  Viewer.ViewerPoints:addGraph(y, x, pointDecoration)

  -- Line fitting
  local points = Point.create(x, y)
  local lineSegment, quality = fitter:fitLine(points)
  local p1, p2, centre = AnalyseLineSegment(lineSegment)
  Script.notifyEvent('UpdatePoint1Display', p1:toString())
  Script.notifyEvent('UpdatePoint2Display', p2:toString())
  Script.notifyEvent('UpdateCentrePointDisplay', centre:toString())

  -- Radial Distances
  local p1D, p2D, centreD = CalculateRadialDistances(p1, p2, centre)
  Script.notifyEvent('Updatep1DistanceFromOriginDisplay', string.format('%.0f', tostring(p1D)))
  Script.notifyEvent('Updatep2DistanceFromOriginDisplay', string.format('%.0f', tostring(p2D)))
  Script.notifyEvent('UpdateDistanceFromOriginDisplay', string.format('%.0f', tostring(centreD)))

  Viewer.ViewerPoints:addPoint({p1, p2, centre}, lineSegmentPointDecoration)
  Viewer.ViewerPoints:addShape(lineSegment, lineSegmentDecoration)
  Viewer.ViewerPoints:present()

  -- Diagnostics
  if Diagnostics.DiagnosticsDisplayInterval % 25 == 0 then Diagnostics.UpdateDiagnosticsDisplay() end
  Diagnostics.DiagnosticsDisplayInterval = Diagnostics.DiagnosticsDisplayInterval + 1
end

  -- Tool: Calculating average #points per scan
  -- local test = #points3d
  -- table.insert(test2, test)
  -- if #test2 == 1000 then
  --   local sum = 0
  --   for i = 1, #test2 do
  --       sum = sum + test2[i]
  --   end
  --   local result =  sum / #test2
  --   local test3 = 0
  -- end



Script.serveEvent('picoScan.UpdatePoint1Display', 'UpdatePoint1Display')
Script.serveEvent('picoScan.UpdatePoint2Display', 'UpdatePoint2Display')
Script.serveEvent('picoScan.UpdateCentrePointDisplay', 'UpdateCentrePointDisplay')
Script.serveEvent('picoScan.Updatep1DistanceFromOriginDisplay', 'Updatep1DistanceFromOriginDisplay')
Script.serveEvent('picoScan.Updatep2DistanceFromOriginDisplay', 'Updatep2DistanceFromOriginDisplay')
Script.serveEvent('picoScan.UpdateDistanceFromOriginDisplay', 'UpdateDistanceFromOriginDisplay')
