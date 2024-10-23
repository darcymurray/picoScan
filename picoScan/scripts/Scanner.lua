Scanner = {}

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
Scanner.CubicAreaFilter = Scan.CubicAreaFilter.create()
Scanner.CubicAreaFilter:setXRange(Viewer.MinX, Viewer.MaxX)
Scanner.CubicAreaFilter:setYRange(Viewer.MinY, Viewer.MaxY)
Script.notifyEvent("UpdateVertexADisplay", tostring(Viewer.MinX))
Script.notifyEvent("UpdateVertexBDisplay", tostring(Viewer.MaxX))
Script.notifyEvent("UpdateVertexCDisplay", tostring(Viewer.MinY))
Script.notifyEvent("UpdateVertexDDisplay", tostring(Viewer.MaxY))
if Viewer.EnableBounds then Scanner.CubicAreaFilter:setEnabled(true) end

-- Shape fitter
local fitter = Point.ShapeFitter.create()

function AnalyseLineSegment(lineSegment)
  local p1, p2 = lineSegment:getLineParameters()
  local centre = Point.create((p1:getX() + p2:getX()) / 2, (p1:getY() + p2:getY()) / 2)
  local length = p2:getY() - p1:getY()
  -- local xDiff, yDiff = math.abs(p1:getX() - p2:getX()), math.abs(p1:getY() - p2:getY())
  -- local angleRadians = math.atan(yDiff/xDiff)
  return p1, p2, centre, length
end

function CalculateRadialDistances(p1, p2, centre)
  local p1D = math.sqrt(p1:getX()^2 + p1:getY()^2)
  local p2D = math.sqrt(p2:getX()^2 + p2:getY()^2)
  local centreD = math.sqrt(centre:getX()^2 + centre:getY()^2)
  return p1D, p2D, centreD
end

-- Scan handler (Scan is 2D Polar)
function HandleOnNewScan(scan)
  -- Diagnostics
  if Diagnostics.DiagnosticsDisplayInterval % 1 == 0 then Diagnostics.UpdateDiagnosticsDisplay() end
  Diagnostics.DiagnosticsDisplayInterval = Diagnostics.DiagnosticsDisplayInterval + 1

  -- Cubic Area Filter
  scan = Scanner.CubicAreaFilter:filter(scan)

  -- Scan -> Point Cloud (3D Cartesian) -> 2D Cartesian
  local pointCloud = Transformer:transformToPointCloud(scan)
  local x, y, _, _ = pointCloud:toVector()
  local points = Point.create(x, y)
  if #points < 2 then return end

  -- Populate Viewer
  -- Viewer.ViewerPointClouds:addPointCloud(pointCloud)
  -- Viewer.ViewerPointClouds:present()
  Viewer.ViewerPoints:addGraph(y, x, Decorations.PointDecoration)
  Viewer.ViewerPoints:addPoint(Viewer.CAFPoints, Decorations.CAFDecoration)
  for _, lineSegment in pairs(Viewer.CAFLineSegments) do Viewer.ViewerPoints:addShape(lineSegment, Decorations.CAFLineSegmentDecoration) end
  Viewer.ViewerPoints:present()

  -- Line fitting
  local lineSegment, quality = fitter:fitLine(points)
  local p1, p2, centre, length = AnalyseLineSegment(lineSegment)
  local p1D, p2D, centreD = CalculateRadialDistances(p1, p2, centre)

  -- Populate Viewer
  Viewer.ViewerPoints:addPoint({p1, p2, centre}, Decorations.LineSegmentPointDecoration)
  Viewer.ViewerPoints:addShape(lineSegment, Decorations.LineSegmentDecoration)
  Viewer.ViewerPoints:present()

  -- Notify Events
  Script.notifyEvent('UpdatePoint1Display', p1:toString())
  Script.notifyEvent('UpdatePoint2Display', p2:toString())
  Script.notifyEvent('UpdateCentrePointDisplay', centre:toString())
  Script.notifyEvent('UpdateLengthDisplay', tostring(length))
  Script.notifyEvent('Updatep1DistanceFromOriginDisplay', string.format('%.0f', tostring(p1D)))
  Script.notifyEvent('Updatep2DistanceFromOriginDisplay', string.format('%.0f', tostring(p2D)))
  Script.notifyEvent('UpdateDistanceFromOriginDisplay', string.format('%.0f', tostring(centreD)))
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
Script.serveEvent('picoScan.UpdateLengthDisplay', 'UpdateLengthDisplay')
Script.serveEvent('picoScan.Updatep1DistanceFromOriginDisplay', 'Updatep1DistanceFromOriginDisplay')
Script.serveEvent('picoScan.Updatep2DistanceFromOriginDisplay', 'Updatep2DistanceFromOriginDisplay')
Script.serveEvent('picoScan.UpdateDistanceFromOriginDisplay', 'UpdateDistanceFromOriginDisplay')



