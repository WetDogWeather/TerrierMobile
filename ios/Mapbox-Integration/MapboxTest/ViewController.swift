//
//  ViewController.swift
//  MapboxTest
//
//  Created by Steve Gifford on 12/3/24.
//

import UIKit
@_spi(Experimental) import MapboxMaps
import Terrier

class ViewController: UIViewController, TrrServiceDelegate, TrrTimeTrackerDelegate {
    
    var mapView: MapView?
    
    // Sets up the service and kicks off the request for contents
    // We'll know it's ready when it calls the delegate
    let service = TrrService(stackName: "dev")
    
    // This keeps track of the visible time for the weather
    var tracker: TrrTimeTracker? = nil

    // Hooks Terrier into the Mapbox display
    var terrierAdapter: TerrierMapboxAdapter? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the Terrier connection to the backend, Boxer
        // This will fetch the available metadata and once it calls you back
        //  you can start some layers
        service.delegate = self
        service.start()

        // Set up a simple map
        mapView = MapView(frame: view.bounds)
        guard let mapView = mapView else { return }
        try? mapView.mapboxMap.setProjection(StyleProjection(name: StyleProjectionName.mercator))
        let cameraOptions = CameraOptions(center:
            CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0),
            zoom: 2, bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.insertSubview(mapView, at: 0)

        // The Mapbox Adapter interfaces to Mapbox for rendering
//        terrierAdapter = TerrierMapboxAdapter(service: service, mapView: mapView, wrap: true)
        terrierAdapter = TerrierMapboxAdapter(service: service, mapView: mapView)
        guard let terrierAdapter = terrierAdapter else { return }
        tracker = TrrTimeTracker(viewC: terrierAdapter)
        terrierAdapter.setTracker(tracker: tracker)
        tracker?.addDelegate(delegate: self)
        
        let terrierLayer = CustomLayer(id: "terrier-layer", renderer: terrierAdapter, slot: .middle)

        // Set the projection to flat and wire in our adapter as a layer
        mapView.mapboxMap.setMapStyleContent {
            StyleProjection(name: .mercator)
            terrierLayer
        }
    }

    // This section handles the play button interaction and updates from the time
    //  tracker to the label displaying the time
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    func playUpdate() {
        guard let tracker = tracker else { return }
        if tracker.isPlaying() {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }

    // Called by the play button.  We'll treat it as a toggle.
    @IBAction func playAction(_ sender: Any) {
        guard let tracker = tracker else { return }
        if tracker.isPlaying() {
            tracker.pause()
            switch windLayerStyle {
            case .Continuous:
                break
            case .WindArrows:
                break
            case .LongSlowTrails:
                windLayer?.trailTexture = rectTexture
                break
            }
        } else {
            tracker.play()
            switch windLayerStyle {
            case .Continuous:
                break
            case .WindArrows:
                break
            case .LongSlowTrails:
                windLayer?.trailTexture = arrowTexture
                break
            }
        }
        playUpdate()
    }
    
    // Update the time label
    func updateTime() {
        guard let tracker = tracker else { return }

        let format = DateFormatter.forDateFormat("E HH:mm", local: false)
        format.timeZone = TimeZone.current
        
        timeLabel.text = format.string(from: Date(timeIntervalSince1970: tracker.curEpoch))
    }
    
    // Delegate for tracker update.  This means the time changed
    @IBOutlet weak var slider: UISlider!
    var sliderUpdateScheduled = false
    var inTrackerUpdate = false
    func trackerUpdate(tracker: any Terrier.TrrITimeTracker, epoch: TimeInterval) {
        guard !sliderUpdateScheduled else { return }
        sliderUpdateScheduled = true
        // We delay the update so that we're not updating the slider at 60hz.
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.sliderUpdateScheduled = false
            self.inTrackerUpdate = true
            self.slider.setValue(Float(tracker.interpolateSimple(epoch: tracker.curEpoch)), animated: false)
            self.inTrackerUpdate = false
            self.updateTime()
        }
    }
    
    // When dragging the slider we switch how the wind particles look
    @IBAction func sliderDrag(_ sender: Any) {
        switch windLayerStyle {
        case .Continuous:
            break
        case .LongSlowTrails:
            windLayer?.isAnimatingTime = true
            windLayer?.trailTexture = arrowTexture
            break
        case .WindArrows:
            break
        }
    }
    
    // Done dragging, so put the wind back to normal
    @IBAction func sliderDragEnd(_ sender: Any) {
        switch windLayerStyle {
        case .Continuous:
            break
        case .LongSlowTrails:
            windLayer?.resetTrails(overTime: 0.5)
            windLayer?.resetAnimatingTime()
            windLayer?.trailTexture = dotTexture
        case .WindArrows:
            break
        }
    }
    
    
    // User changed the time, or we did
    // If we did, we don't want to propagate the change further
    @IBAction func sliderChanged(_ sender: Any) {
        guard !inTrackerUpdate else { return }
        guard let tracker = tracker else { return }
        tracker.curEpoch = tracker.interpolateEpoch(pos: Double(slider.value))
        tracker.pause()
        playUpdate()
        updateTime()
    }
    
    func stopLayers() {
        if let temperatureLayer = temperatureLayer {
            temperatureLayer.stop()
            self.temperatureLayer = nil
        }
        if let windLayer = windLayer {
            windLayer.stop()
            self.windLayer = nil
        }
        if let precipLayer = precipLayer {
            precipLayer.stop()
            self.precipLayer = nil
        }
        if let humidLayer = humidLayer {
            humidLayer.stop()
            self.humidLayer = nil
        }
        if let dewPointLayer = dewPointLayer {
            dewPointLayer.stop()
            self.dewPointLayer = nil
        }
        if let precipTypeLayer = precipTypeLayer {
            precipTypeLayer.stop()
            self.precipTypeLayer = nil
        }
        if let aqiLayer = aqiLayer {
            aqiLayer.stop()
            self.aqiLayer = nil
        }
    }
    
    var temperatureLayer: TrrITemperatureController? = nil
    func startTemperature() {
        guard temperatureLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                      maxTimeOffset: 24 * 3600,
                                      maxTimeSlices: 48+2)
        let resCadence = srcCadence.resolve()

        // Start temperature display
        temperatureLayer = TrrTemperatureController.create(region: ["conus", "global"],
                                                           level: "2m",
                                                           cadence: resCadence,
                                                            service: service,
                                                            tracker: tracker,
                                                            viewC: adapter)
        if let temperatureLayer = temperatureLayer {
            temperatureLayer.baseColor = UIColor(white: 1.0, alpha: 0.5)
            temperatureLayer.importanceFactor = 4.0
            temperatureLayer.varInterpMode = .Bilinear
            // Temperature color map in Kelvin
            temperatureLayer.colorMap = TrrColorMap(
                values: [ 255.372, 260.928, 266.483, 272.039, 277.594, 283.15, 288.706, 294.261, 299.817, 305.372, 310.928, 316.483],
                colors: [
                    UIColor.fromHexRGB(0xFFBFFF),
                    UIColor.fromHexRGB(0xD873DB),
                    UIColor.fromHexRGB(0x913ABB),
                    UIColor.fromHexRGB(0x372398),
                    UIColor.fromHexRGB(0x00B6DC),
                    UIColor.fromHexRGB(0x02D786),
                    UIColor.fromHexRGB(0x40C604),
                    UIColor.fromHexRGB(0xFFFF00),
                    UIColor.fromHexRGB(0xFB7700),
                    UIColor.fromHexRGB(0xD22402),
                    UIColor.fromHexRGB(0xA20902),
                    UIColor.fromHexRGB(0xEED9D8)
                ])

            _ = temperatureLayer.start()
        }
        
        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }
    
    enum WindLayerStyle {
    case LongSlowTrails
    case Continuous
    case WindArrows
    }
    var windLayerStyle: WindLayerStyle = .LongSlowTrails
    
    // Change the wind layer to match the given style
    func setWindLayerStyle(_ windLayer: TrrWindController, style: WindLayerStyle) {
        windLayerStyle = style
        windLayer.enableTrails = false
        windLayer.enable = true
        switch style {
        case WindLayerStyle.LongSlowTrails:
            windLayer.baseColor = UIColor(white: 1.0, alpha: 0.5)
            windLayer.trailTexture = dotTexture
            windLayer.arrowTexture = arrowTexture
//            windLayer.scaleResetFactor = 2
            windLayer.trailPoints = 10000
            windLayer.trailAdvanceRate = 6
            windLayer.trailVelExp = 0.0;
            windLayer.animationArrows = true
            windLayer.useInteraction = true
            break
        case WindLayerStyle.Continuous:
            windLayer.baseColor = UIColor(white: 1.0, alpha: 0.5)
            windLayer.trailTexture = rectTexture
            windLayer.scaleResetFactor = 1
            windLayer.trailPoints = 40000
            windLayer.trailAdvanceRate = 40
            windLayer.trailVelExp = 1.0;
            windLayer.trailWidth = 8
            windLayer.texPeriod = 2
            windLayer.trailLifetimeMin = 2
            windLayer.trailLifetimeMax = 10
            windLayer.animationArrows = false
            windLayer.useInteraction = false
            windLayer.continuousMode = true
            break
        case WindLayerStyle.WindArrows:
            windLayer.baseColor = UIColor(white: 1.0, alpha: 0.5)
            windLayer.trailPoints = 15000
            windLayer.trailTexture = arrowTexture
            windLayer.arrowTexture = arrowTexture
            windLayer.arrowWidth = 10
            windLayer.arrowLength = 40
            windLayer.arrowShowFrac = 1
            windLayer.isAnimatingTime = true
            windLayer.useInteraction = true
            break
        }
    }

    var windLayer: TrrIWindController? = nil
    var arrowTexture: MaplyTexture? = nil
    var dotTexture: MaplyTexture? = nil
    var rectTexture: MaplyTexture? = nil
    func startWind() {
        guard windLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }

        stopLayers()
        
        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                      maxTimeOffset: 24 * 3600,
                                      maxTimeSlices: 48+2)
        let resCadence = srcCadence.resolve()

        // Start wind controller
        windLayer = TrrWindController.create(region: ["global","conus"],
                                             level: "10m",
                                             cadence: resCadence,
                                             service: service,
                                             tracker: tracker,
                                             viewC: adapter)
        if let windLayer = windLayer {
            setWindLayerStyle(windLayer as! TrrWindController,style: .Continuous)
            // Note: Set this to false to remove the velocity intensity display
            windLayer.enableVelocity = true
            
            // Example trail color map, matches the default colors
            // Keep in mind we mix in another alpha so the intensity layer is fainter
//            windLayer.trailColorMap = TrrColorMap(
//                values: [ 0.0, 5, 10, 15, 20, 25, 30, 35, 40 ],
//                colors: [
//                    UIColor.fromHexRGB(0xAED5FF),
//                    UIColor.fromHexRGB(0x86B4E6),
//                    UIColor.fromHexRGB(0x66E2D6),
//                    UIColor.fromHexRGB(0x00CC05),
//                    UIColor.fromHexRGB(0xECF006),
//                    UIColor.fromHexRGB(0xFF6B00),
//                    UIColor.fromHexRGB(0xE11511),
//                    UIColor.fromHexRGB(0xE111C1),
//                    UIColor.fromHexRGB(0xFFCEF7)
//                ])

            // Wind layer will start disabled, but we'll let it turn on in the monitor loading logic
            startWindTrigger()
//            windLayer.addAllLoadedDelegate(timeout: 10) { ctrl in
//                let srcValid = ctrl.areAnySourcesValid()
//                ctrl.enable = ctrl.enable || srcValid
//            }
            _ = windLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }
    
    // Used to watch loading for the wind layer
    var monitorTimer: Timer? = nil
    var windLoadStarted = false
    
    // Waits for data to start loading and then waits until it's sufficiently loaded
    func startWindTrigger() {
        windLoadStarted = false
        // Start clean with the loading stats
        if let adapter = terrierAdapter,
           let fetcher = adapter.getTileFetcher(TrrConstants.RemoteFetcherName) {
            fetcher.resetStats()
        }

        self.monitorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            guard let adapter = terrierAdapter,
                  let fetcher = adapter.getTileFetcher(TrrConstants.RemoteFetcherName),
                  let windLayer = windLayer
            else {
                monitorTimer?.invalidate()
                return
            }
            guard let stats = fetcher.getStats(false) else { return }
            
            if windLoadStarted {
                // Now we're monitoring how much loading
                var frac = 1.0
                if stats.maxActiveRequests > 0 {
                    frac = 1.0-Double(stats.activeRequests)/Double(stats.maxActiveRequests)
                }
                // We'll arbitrarily say we want to trigger at 50% loaded
                // If the wind layer isn't already on, then we'll turn it on
                if frac > 0.5 {
                    if !windLayer.enableTrails {
                        windLayer.enableTrails = true
                    }
                    // In any case we're done with the monitor
                    monitorTimer?.invalidate()
                    monitorTimer = nil
                }
            } else {
                // We're looking for our first indication of loading
                if stats.totalRequests > 0 {
                    windLoadStarted = true
                }
            }
        }
    }
    
    var precipLayer: TrrRadarController? = nil
    // For true we get radar and GFS background
    // For false we'll get that plus HRRR
    let radarOnly = true
    func startPrecip() {
        guard precipLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // Minus 4 hours to plus 24 hours
        var startTime: Double = -4
        var endTime: Double = 24
        if (radarOnly) {
            endTime = 0
        }
        let srcCadence = TrrSourceCadence(minTimeOffset: startTime * 3600,
                                          maxTimeOffset: endTime * 3600,
                                          maxTimeSlices: 24+2)
        let resCadence = srcCadence.resolve()

        precipLayer = TrrRadarController.create(region: ["conus","global"],
                                                cadence: resCadence,
                                                radarOnly: radarOnly,
                                                service: service,
                                                tracker: tracker,
                                                viewC: adapter)
        if let precipLayer = precipLayer {
            precipLayer.sourceCadence = resCadence
            precipLayer.renderScale = 1.0
            precipLayer.importanceFactor = 4.0
            precipLayer.snapToFrame = true
            precipLayer.varInterpMode = .Bicubic
            let emptyColorMap = TrrColorMap(
                values: [ -30, 75],
                colors: [
                    UIColor.fromHexARGB(0x00000000),
                    UIColor.fromHexARGB(0x00000000)
                ])!
            let snowColorMap = TrrColorMap(
                values: [ -30, -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75],
                colors: [
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x80676767),  // 0.0
                    UIColor.fromHexARGB(0xFFE7E7E7),
                    UIColor.fromHexARGB(0xFFF3F3F3),
                    UIColor.fromHexARGB(0xFFF0F0F0),
                    UIColor.fromHexARGB(0xFFFCFCFC),
                    UIColor.fromHexARGB(0xFFC7C7C7),
                    UIColor.fromHexARGB(0xFF8D8D8D),
                    UIColor.fromHexARGB(0xFFF6F6F6),
                    UIColor.fromHexARGB(0xFFE6E6E6),
                    UIColor.fromHexARGB(0xFFF7F7F7),
                    UIColor.fromHexARGB(0xFFFEFEFE),
                    UIColor.fromHexARGB(0xFFD6D6D6),
                    UIColor.fromHexARGB(0xFFBBBBBB),
                    UIColor.fromHexARGB(0xFFF8F8F8),
                    UIColor.fromHexARGB(0xFF9A9A9A),
                    UIColor.fromHexARGB(0xFFFCFCFC)
                ])!
            let hailColorMap = TrrColorMap(
                values: [ -30, 75],
                colors: [
                    UIColor.fromHexARGB(0xffa020f0),
                    UIColor.fromHexARGB(0xffa020f0)
                ])!
            let warnColorMap = TrrColorMap(
                values: [ -30, 75],
                colors: [
                    UIColor.fromHexARGB(0xffff0000),
                    UIColor.fromHexARGB(0xffff0000)
                ])!
            let rainColorMap = TrrColorMap(
                values: [ -30, -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75],
                colors: [
                    UIColor.fromHexARGB(0x00CBFCFD),
                    UIColor.fromHexARGB(0x00D09CCB),
                    UIColor.fromHexARGB(0x00976797),
                    UIColor.fromHexARGB(0x00643363),
                    UIColor.fromHexARGB(0x00CDCC9A),
                    UIColor.fromHexARGB(0x009C9A6B),
                    UIColor.fromHexARGB(0x80676467),  // 0.0
                    UIColor.fromHexARGB(0xFF10E6E7),
                    UIColor.fromHexARGB(0xFF069FF3),
                    UIColor.fromHexARGB(0xFF0400F0),
                    UIColor.fromHexARGB(0xFF01FC08),
                    UIColor.fromHexARGB(0xFF02C701),
                    UIColor.fromHexARGB(0xFF068D01),
                    UIColor.fromHexARGB(0xFFF6F602),
                    UIColor.fromHexARGB(0xFFE6BA03),
                    UIColor.fromHexARGB(0xFFF79505),
                    UIColor.fromHexARGB(0xFFFE0002),
                    UIColor.fromHexARGB(0xFFD60401),
                    UIColor.fromHexARGB(0xFFBB0200),
                    UIColor.fromHexARGB(0xFFF807F6),
                    UIColor.fromHexARGB(0xFF9A52C8),
                    UIColor.fromHexARGB(0xFFFCFBFA)
                ])!
            precipLayer.setColorMap(rainColorMap,
                                    precipType: TrrRadarController.PrecipType.None)
            precipLayer.setColorMap(snowColorMap,
                                    precipType: TrrRadarController.PrecipType.Snow)
            precipLayer.setColorMap(hailColorMap,
                                    precipType: TrrRadarController.PrecipType.Hail)
            precipLayer.setColorMap(warnColorMap,
                                    precipType: TrrRadarController.PrecipType.Convect)
            precipLayer.setColorMap(rainColorMap,
                                    precipType: TrrRadarController.PrecipType.WarmStratRain)
            precipLayer.setColorMap(rainColorMap,
                                    precipType: TrrRadarController.PrecipType.CoolStratRain)
            precipLayer.setColorMap(rainColorMap,
                                    precipType: TrrRadarController.PrecipType.TropicalStratRain)
            precipLayer.setColorMap(warnColorMap,
                                    precipType: TrrRadarController.PrecipType.TropicalConvectRain)

            precipLayer.baseColor = .init(white: 1.0, alpha: 0.5)
            _ = precipLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }
    
    var humidLayer: TrrISingleChannelController? = nil
    func startHumidity() {
        guard humidLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                      maxTimeOffset: 24 * 3600,
                                      maxTimeSlices: 48+2)
        let resCadence = srcCadence.resolve()
        
        // Relative humidity doesn't have a convenience class, so we'll do the pieces ourselves
        let sources = TrrDataSource.getStandardSources(service: service,
                                                       varName: "relative_humidity",
                                                       source: ["gfs","hrrr"],
                                                       region: ["conus","global"],
                                                       product: nil,
                                                       level: nil,
                                                       interval: nil,
                                                       sourceCadence: resCadence,
                                                       viewC: adapter)

        humidLayer = TrrSingleChannelController.create(cadence: resCadence,
                                                       dataSources: sources,
                                                       service: service,
                                                       tracker: tracker,
                                                       viewC: adapter)
        if let humidLayer = humidLayer {
            humidLayer.sourceCadence = resCadence
            humidLayer.baseColor = .init(white: 1.0, alpha: 0.5)
            humidLayer.varInterpMode = .Bilinear
            humidLayer.colorMap = TrrColorMap(
                values: [ -1.0, 100.0],
                colors: [
                    UIColor.fromHexRGB(0xFF0000).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0x00FF00).withAlphaComponent(1.0),
                ])

            _ = humidLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }

    var precipTypeLayer: TrrISingleChannelController? = nil
    func startPrecipType() {
        guard precipTypeLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                          maxTimeOffset: 0.0,
                                      maxTimeSlices: 24+2)
        let resCadence = srcCadence.resolve()
        
        let sources = TrrDataSource.getStandardSources(service: service,
                                                       varName: "precipitation_type",
                                                       source: ["mrms"],
                                                       region: ["conus","global"],
                                                       product: nil,
                                                       level: nil,
                                                       interval: nil,
                                                       sourceCadence: resCadence,
                                                       viewC: adapter)

        precipTypeLayer = TrrSingleChannelController.create(cadence: resCadence,
                                                       dataSources: sources,
                                                       service: service,
                                                       tracker: tracker,
                                                       viewC: adapter)
        if let precipTypeLayer = precipTypeLayer {
            precipTypeLayer.sourceCadence = resCadence
            precipTypeLayer.baseColor = .init(white: 1.0, alpha: 0.5)
            precipTypeLayer.varInterpMode = .Nearest
            precipTypeLayer.colorMap = TrrColorMap(
                values: [0, 1, 2, 3, 4, 5, 6, 7],
                colors: [
                    UIColor.fromHexRGB(0x000000).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0xffffff).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0x960096).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0xff3332).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0x0350a5).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0x6effff).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0x00ff00).withAlphaComponent(1.0),
                    UIColor.fromHexRGB(0x00ff00).withAlphaComponent(1.0),
                ])

            _ = precipTypeLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }

    var dewPointLayer: TrrISingleChannelController? = nil
    func startDewPoint() {
        guard dewPointLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                      maxTimeOffset: 24 * 3600,
                                      maxTimeSlices: 48+2)
        let resCadence = srcCadence.resolve()
        
        // Relative dew point doesn't have a convenience class, so we'll do the pieces ourselves
        let sources = TrrDataSource.getStandardSources(service: service,
                                                       varName: "dew_point",
                                                       source: ["gfs","hrrr"],
                                                       region: ["conus","global"],
                                                       product: nil,
                                                       level: "2m",
                                                       interval: nil,
                                                       sourceCadence: resCadence,
                                                       viewC: adapter)

        dewPointLayer = TrrSingleChannelController.create(cadence: resCadence,
                                                       dataSources: sources,
                                                       service: service,
                                                       tracker: tracker,
                                                       viewC: adapter)
        if let dewPointLayer = dewPointLayer {
            dewPointLayer.sourceCadence = resCadence
            dewPointLayer.baseColor = .init(white: 1.0, alpha: 0.5)
            dewPointLayer.colorMap = TrrColorMap(
                values: [ 255.372, 260.928, 266.483, 272.039, 277.594, 283.15, 288.706, 294.261, 299.817, 305.372, 310.928, 316.483],
                colors: [
                    UIColor.fromHexRGB(0xFFBFFF),
                    UIColor.fromHexRGB(0xD873DB),
                    UIColor.fromHexRGB(0x913ABB),
                    UIColor.fromHexRGB(0x372398),
                    UIColor.fromHexRGB(0x00B6DC),
                    UIColor.fromHexRGB(0x02D786),
                    UIColor.fromHexRGB(0x40C604),
                    UIColor.fromHexRGB(0xFFFF00),
                    UIColor.fromHexRGB(0xFB7700),
                    UIColor.fromHexRGB(0xD22402),
                    UIColor.fromHexRGB(0xA20902),
                    UIColor.fromHexRGB(0xEED9D8)
                ])

            _ = dewPointLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }
    
    var aqiLayer: TrrISingleChannelController? = nil
    func startAQI() {
        guard aqiLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // 3 days in the past
        let pastCadence = TrrSourceCadence(minTimeOffset: -72 * 3600,
                                      maxTimeOffset: 0,
                                      maxTimeSlices: 10)
        let resPastCadence = pastCadence.resolve()

        // 1 day in the future
        let futureCadence = TrrSourceCadence(minTimeOffset: 0,
                                      maxTimeOffset: 24*3600,
                                      maxTimeSlices: 10)
        let resFutureCadence = futureCadence.resolve()
        
        let resFullCadence = pastCadence.merge(futureCadence).resolve()

        // In the past we have a larger region including hawaii
        let pastSources = TrrDataSource.getStandardSources(service: service,
                                                       varName: "air_quality_index",
                                                       source: "airnow",
                                                       region: "conus_hawaii_aqi_forecast",
                                                       product: "aqi",
                                                       level: nil,
                                                       interval: nil,
                                                       sourceCadence: resPastCadence,
                                                       viewC: adapter)
        
        // We'll bump up the priority of the observed sources so they win out
        for source in pastSources {
            source.order = source.order + 1000
        }

        // In the past we have a larger region including hawaii
        let futureSources = TrrDataSource.getStandardSources(service: service,
                                                       varName: "air_quality_index",
                                                       source: "airnow",
                                                       region: "conus_aqi_forecast",
                                                       product: "aqi",
                                                       level: nil,
                                                       interval: nil,
                                                       sourceCadence: resFutureCadence,
                                                       viewC: adapter)
        
        // Hold the future sources past the end of their valid range
        for source in futureSources {
            source.enableForRange = false
        }

        aqiLayer = TrrSingleChannelController.create(cadence: resFullCadence,
                                                       dataSources: pastSources+futureSources,
                                                       service: service,
                                                       tracker: tracker,
                                                       viewC: adapter)
        if let aqiLayer = aqiLayer {
            aqiLayer.sourceCadence = resFullCadence
            aqiLayer.baseColor = .init(white: 1.0, alpha: 0.5)
            aqiLayer.snapToFrame = true
            aqiLayer.colorMap = TrrColorMap(
                values: [ 0.0,50.0,
                          50.0, 100.0,
                          100.0, 150.0,
                          150.0, 200.0,
                          200.0, 300.0,
                          300.0, 500.0],
                colors: [
                    UIColor.fromHexRGB(0x05e300), UIColor.fromHexRGB(0x05e300),
                    UIColor.fromHexRGB(0xffff00), UIColor.fromHexRGB(0xffff00),
                    UIColor.fromHexRGB(0xff7e00), UIColor.fromHexRGB(0xff7e00),
                    UIColor.fromHexRGB(0xff0100), UIColor.fromHexRGB(0xff0100),
                    UIColor.fromHexRGB(0x8f3f97), UIColor.fromHexRGB(0x8f3f97),
                    UIColor.fromHexRGB(0x7e0123), UIColor.fromHexRGB(0x7e0123),
                ])

            _ = aqiLayer.start()
        }

        tracker.setEpochRange(newTime: resFullCadence.now, min: resFullCadence.minTime!, max: resFullCadence.maxTime!)
    }

    
    @IBAction func tempButtonAction(_ sender: Any) {
        startTemperature()
    }
    
    @IBAction func windButtonAction(_ sender: Any) {
        startWind()
    }
    
    @IBAction func precipButtonAction(_ sender: Any) {
        startPrecip()
    }

    @IBAction func humidButtonAction(_ sender: Any) {
        startHumidity()
    }

    @IBAction func dewPointButtonAction(_ sender: Any) {
        startDewPoint()
    }

    @IBAction func aqiButtonAction(_ sender: Any) {
        startAQI()
    }

    // Called when we have the contents for the Boxer Stack
    // Now we can construct weather layers
    func serviceReady(service: Terrier.TrrService) {
        guard let adapter = terrierAdapter else { return }

        // Set up the wind textures for later use
        // These textures are in the Assets and can be modified
        arrowTexture = adapter.addTexture(UIImage(named: "arrow")!, desc: nil, mode: .current)
        dotTexture = adapter.addTexture(UIImage(named: "dot")!, desc: nil, mode: .current)
        rectTexture = adapter.addTexture(UIImage(named: "fadeRect")!, desc: nil, mode: .current)

        startTemperature()
    }
    
    func serviceFailed() {
        print("Failed to contact Boxer.  Nothing will be displayed.")
    }

}
