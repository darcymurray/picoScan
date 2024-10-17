require("UIUtils")
require("Diagnostics")
require("Viewer")

-- Diagnostics
Diagnostics.UpdateDiagnosticsDisplay()

-- Scanner configuration
Transformer = Scan.Transform.create()
ScanProvider = Scan.Provider.RemoteScanner.create()
ScanProvider:setIPAddress('192.168.1.100')
ScanProvider:register( 'OnNewScan', 'HandleOnNewScan' )

-- Scan handler
function HandleOnNewScan(scan)
  -- Point Cloud Viewer
  local pointCloud = Scan.Transform.transformToPointCloud(Transformer, scan)
  Viewer.ViewerPointClouds:addPointCloud(pointCloud)
  Viewer.ViewerPointClouds:present()

  -- Profile Viewer
  local profile = scan:toProfile()
  Viewer.ViewerProfiles:addProfile(profile)
  Viewer.ViewerProfiles:present()

  -- Point Viewer
  local a, b, c = profile:toVector()
  Viewer.ViewerPoints:addGraph(a, b, Viewer.Decoration)
  Viewer.ViewerPoints:present()

  -- Diagnostics
  if Diagnostics.DiagnosticsDisplayInterval % 1 == 0 then
    Diagnostics.UpdateDiagnosticsDisplay() 
  end -- at 50Hz, update display every second
  Diagnostics.DiagnosticsDisplayInterval = Diagnostics.DiagnosticsDisplayInterval + 1

  -- TRIED AND TESTED
  --
  -- local points3d, intensities = pointCloud:toPoints()
  -- local points2d = {}
  -- for _, point in pairs(points3d) do
  --   local x, y = point:getXY()
  --   local point2d = Point.create(x, y)
  --   table.insert(points2d, point2d)
  --   if #points2d == 100 then break end
  -- end
  -- Viewer2D:clear()
  -- Viewer2D:addPoint(points2d)
  -- Viewer2D:present()
  
  -- This method didn't work
  -- Viewer2D:addScan(scan)
  -- Viewer2D:present()

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
end

-- Other data output types
-- Socket = UDPSocket.create()
-- Socket:setInterface('ETH1')
-- Socket:bind(2115)
-- Socket:register('OnReceive', HandleOnNewScan)