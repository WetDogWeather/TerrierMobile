//
//  ViewController.swift
//  MapboxTest
//
//  Created by Steve Gifford on 12/3/24.
//

import UIKit
@_spi(Experimental) import MapboxMaps
import Terrier

class ViewController: UIViewController, TrrServiceDelegate {
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

        view.addSubview(mapView)

        // The Mapbox Adapter interfaces to Mapbox for rendering
        terrierAdapter = TerrierMapboxAdapter(service: service, mapView: mapView)
        guard let terrierAdapter = terrierAdapter else { return }
        tracker = TrrTimeTracker(viewC: terrierAdapter)
        terrierAdapter.setTracker(tracker: tracker)

        // Set the projection to flat and wire in our adapter as a layer
        mapView.mapboxMap.setMapStyleContent {
            StyleProjection(name: .mercator)
            CustomLayer(id: "terrier-layer", renderer: terrierAdapter)
        }
    }
    
    var temperatureLayer: TrrITemperatureController? = nil
    
    // Called when we have the contents for the Boxer Stack
    // Now we can construct weather layers
    func serviceReady(service: Terrier.TrrService) {
        guard let tracker = tracker else { return }
        guard let adapter = terrierAdapter else { return }
        
        // Start temperature display
        temperatureLayer = TrrTemperatureController.create(level: nil,
                                                        service: service,
                                                        tracker: tracker,
                                                        viewC: adapter)
        temperatureLayer?.baseColor = UIColor(white: 1.0, alpha: 0.5)
        temperatureLayer?.start()
        
        // Plus and minus one day
        let srcCadence = TrrSourceCadence(minTimeOffset: -24 * 3600,
                                      maxTimeOffset: 24 * 3600,
                                      maxTimeSlices: 96+2)
        let resCadence = srcCadence.resolve()
        tracker.setEpochRange(newTime: resCadence.now, min: resCadence.minTime!, max: resCadence.maxTime!)
        
        // This will animate over the range
        tracker.play()
    }
    
    func serviceFailed() {
        print("Failed to contact Boxer.  Nothing will be displayed.")
    }

}
