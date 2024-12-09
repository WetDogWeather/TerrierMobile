//
//  TerrierLayerAdapter.swift
//  MapboxTest
//
//  Created by Steve Gifford on 12/3/24.
//

import Foundation
import MapboxMaps
import MetalKit
import Terrier
import WhirlyGlobe

protocol TerrierMapboxDelegate {
    func terrierStarted(service: TrrService)
}

final class TerrierMapboxAdapter: MaplyRenderControllerOverlay, CustomLayerHost {
    var service: TrrService? = nil
    var tracker: TrrTimeTracker? = nil
    var mapView: MapView? = nil
    var displayLink: CADisplayLink? = nil
    let adaptInter = TerrierMapboxAdapterObjC()
    
    override private init() {
        super.init()
    }
        
    init?(service: TrrService, mapView: MapView) {
        // We're following another renderer's load
        super.init(size: CGSize(width: mapView.contentScaleFactor * mapView.bounds.size.width,
                                height: mapView.contentScaleFactor * mapView.bounds.size.height))
        self.service = service
        self.mapView = mapView
        self.clearLights()

        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)

        mapView.setNeedsDisplay()
    }
    
    // Called by the display link every 60s or so
    @objc func displayLinkUpdate(sender: CADisplayLink) {
        // If we have changes to the scene, we want a repaint
        if (hasChanges()) {
            mapView?.mapboxMap.triggerRepaint()
        }
    }
    
    func setTracker(tracker: TrrTimeTracker?) {
        self.tracker = tracker
        guard let tracker = tracker else { return }
        self.add(tracker)
    }
        
    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
    }
    
    func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {

        assignViewMatrix(fromMapbox: parameters.projectionMatrix, scale: parameters.zoom, tileSize: 256)
        setPosition(MaplyCoordinateMakeWithDegrees(Float(parameters.longitude),Float(parameters.latitude)), height: 0.0)

        adaptInter.renderControl(self, 
                                 cmdBuffer: mtlCommandBuffer,
                                 renderPass: mtlRenderPassDescriptor,
                                 size: CGSize(width: mtlRenderPassDescriptor.colorAttachments[0].texture!.width,
                                              height: mtlRenderPassDescriptor.colorAttachments[0].texture!.height))
    }
    
    func renderingWillEnd() {
        displayLink?.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
    }
}
