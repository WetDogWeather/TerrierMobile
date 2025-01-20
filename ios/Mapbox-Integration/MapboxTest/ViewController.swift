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
        terrierAdapter = TerrierMapboxAdapter(service: service, mapView: mapView)
        guard let terrierAdapter = terrierAdapter else { return }
        tracker = TrrTimeTracker(viewC: terrierAdapter)
        terrierAdapter.setTracker(tracker: tracker)
        tracker?.addDelegate(delegate: self)

        // Set the projection to flat and wire in our adapter as a layer
        mapView.mapboxMap.setMapStyleContent {
            StyleProjection(name: .mercator)
            CustomLayer(id: "terrier-layer", renderer: terrierAdapter)
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
            windLayer?.trailTexture = dotTexture
        } else {
            tracker.play()
            windLayer?.trailTexture = arrowTexture
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
        windLayer?.isAnimatingTime = true
        windLayer?.trailTexture = arrowTexture
    }
    
    // Done dragging, so put the wind back to normal
    @IBAction func sliderDragEnd(_ sender: Any) {
        windLayer?.resetAnimatingTime()
        windLayer?.trailTexture = dotTexture
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
                                      maxTimeSlices: 96+2)
        let resCadence = srcCadence.resolve()

        // Start temperature display
        temperatureLayer = TrrTemperatureController.create(region: ["conus","global"],
                                                           level: "2m",
                                                           cadence: resCadence,
                                                            service: service,
                                                            tracker: tracker,
                                                            viewC: adapter)
        if let temperatureLayer = temperatureLayer {
            temperatureLayer.baseColor = UIColor(white: 1.0, alpha: 0.5)
            temperatureLayer.importanceFactor = 8.0
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

    var windLayer: TrrIWindController? = nil
    var arrowTexture: MaplyTexture? = nil
    var dotTexture: MaplyTexture? = nil
    func startWind() {
        guard windLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }

        stopLayers()
        
        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                      maxTimeOffset: 24 * 3600,
                                      maxTimeSlices: 96+2)
        let resCadence = srcCadence.resolve()

        // Start wind controller
        windLayer = TrrWindController.create(region: ["global","conus"],
                                             level: "10m",
                                             cadence: resCadence,
                                             service: service,
                                             tracker: tracker,
                                             viewC: adapter)
        if let windLayer = windLayer {
            windLayer.baseColor = UIColor(white: 1.0, alpha: 0.5)
            windLayer.enable = false
            windLayer.enableTrails = true
            windLayer.trailTexture = dotTexture
            // Note: Set this to false to remove the velocity intensity display
            windLayer.enableVelocity = true
            
            // Example trail color map, matches the default colors
            // Keep in mind we mix in another alpha so the intensity layer is fainter
            windLayer.trailColorMap = TrrColorMap(
                values: [ 0.0, 5, 10, 15, 20, 25, 30, 35, 40 ],
                colors: [
                    UIColor.fromHexRGB(0xAED5FF),
                    UIColor.fromHexRGB(0x86B4E6),
                    UIColor.fromHexRGB(0x66E2D6),
                    UIColor.fromHexRGB(0x00CC05),
                    UIColor.fromHexRGB(0xECF006),
                    UIColor.fromHexRGB(0xFF6B00),
                    UIColor.fromHexRGB(0xE11511),
                    UIColor.fromHexRGB(0xE111C1),
                    UIColor.fromHexRGB(0xFFCEF7)
                ])
            
            windLayer.addAllLoadedDelegate(timeout: 10) { ctrl in
                let srcValid = ctrl.areAnySourcesValid()
                ctrl.enable = ctrl.enable || srcValid
            }
            _ = windLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
    }

    var precipLayer: TrrIRadarController? = nil
    func startPrecip() {
        guard precipLayer == nil else { return }
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        stopLayers()

        // Minus 4 hours to plus 24 hours
        let srcCadence = TrrSourceCadence(minTimeOffset: -4 * 3600,
                                          maxTimeOffset: 1 * 24 * 3600,
                                          maxTimeSlices: 48+2)
        let resCadence = srcCadence.resolve()

        precipLayer = TrrRadarController.create(region: ["conus"],
                                                cadence: resCadence,
                                                service: service,
                                                tracker: tracker,
                                                viewC: adapter)
        if let precipLayer = precipLayer {
            precipLayer.sourceCadence = resCadence
            precipLayer.renderScale = 1.0
            precipLayer.importanceFactor = 16.0
            precipLayer.snapToFrame = true
            precipLayer.varInterpMode = .Bicubic
            precipLayer.colorMap = TrrColorMap(
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
                ])

            _ = precipLayer.start()
        }

        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
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
    
    
    // Called when we have the contents for the Boxer Stack
    // Now we can construct weather layers
    func serviceReady(service: Terrier.TrrService) {
        guard let adapter = terrierAdapter else { return }

        // Set up the wind textures for later use
        // These textures are in the Assets and can be modified
        arrowTexture = adapter.addTexture(UIImage(named: "arrow")!, desc: nil, mode: .current)
        dotTexture = adapter.addTexture(UIImage(named: "dot")!, desc: nil, mode: .current)

        startTemperature()
    }
    
    func serviceFailed() {
        print("Failed to contact Boxer.  Nothing will be displayed.")
    }

}
