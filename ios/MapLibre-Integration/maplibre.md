# MapLibre Mobile iOS  Integration with Terrier
MapLibre's iOS toolkit is based on Metal.  So is Terrier and as a result, they can work together quite well.  The integration is taken care of in Terrier and is quite easy to use.

<img height="512" alt="IMG_6784" src="https://github.com/user-attachments/assets/99770932-8306-4df2-8b97-bd6459805dc7" />

The first step is to create a MapLibre example project like the one your looking at.  I'd recommend just creating their standard example, including their library and getting it running.  Your viewDidLoad will look something like this.

        // Start MapLibre Native
        let mapView = MLNMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 41.8864, longitude: -87.7135), zoomLevel: 3, animated: false)
        view.insertSubview(mapView, at: 0)

That gets you a map, in spherical mercator, suitable to add Terrier.  I'm afraid we can only do spherical mercator.  Well, *we* can do all sorts of map projections, but they only do spherical mercator.

Once you've got the basic map going, you'll want to [add the Terrier](../../README.md) library to your project.  Go do that and come back.  We'll wait.

Now add the import to the top of your View Controller, where you're creating the MapLibre Map.

    import Terrier
    import Terrier_MapLibre

If that works, then you brought in Terrier correctly.  Nice!

Now let's hook Terrier in to do its thing.  We need to start by adding some members to your View Controller.  First up, is the Service, which controls how Terrier talks to the back end, Boxer.

    // Sets up the service and kicks off the request for contents
    // We'll know it's ready when it calls the delegate
    let service = TrrService(stackName: "dev", apiKey:"foo")

Substitute your own stack name for "dev" there.  We gave you one when you signed up with us.  If it's not ready, sure, you can use dev for now.  But "dev" is our development stack and we are constantly messing with it.  Best to use yours.  Onward.

    // This keeps track of the visible time for the weather
    var tracker: TrrTimeTracker? = nil

This is a Time Tracker, which is used to manage and distribute the current displayed time for all our layers.  You can have time animate, set it to a particular real time, get updates when the user changes the time, all that good stuff.  

Terrier is very concerned with time, propagating it all the way down to our shaders.  It's one of the big differences between the way Terrier works and most everything else.

Next up is the Adapter, which will hook Terrier into MapLibre.  Declare that like so.

    // Hooks Terrier into the MapLibre display
    var terrierAdapter: TerrierMapLibreAdapter? = nil

Now we need to set all this up.  We like to do it in the viewDidLoad() method of a View Controller.  You do you, but do it in the same order.  First up, is initializing the TrrService.

        // Initialize the Terrier connection to the backend, Boxer
        // This will fetch the available metadata and once it calls you back
        //  you can start some layers
        service.delegate = self
        service.start()

There are two key bits here.  First is we want to know when the service is ready.  That's what the delegate is for and it is named serviceReady().  More on that below.

Next, we want to kick off the service with the start() method.  That will go out to Boxer and get a list of contents from your stack.  We'll use those in setting up layers.

Now we want to hook Terrer into MapLibre and we do thusly.  Oh, and we set up the Time Tracker right then because we needed the adapter.

        // Need an adapter from Terrier to MapLibre
        let mapOverlay = TerrierMapLibreAdapter(service: service, mapView: mapView)
        terrierAdapter = mapOverlay
        guard let terrierOvl = mapOverlay?.terrierOvl else { return }

        tracker = TrrTimeTracker(viewC: terrierAdapter)
        terrierAdapter.setTracker(tracker: tracker)

After this, Terrier is ready to render in the middle of a MapLibre map.  But MapLibre isn't ready yet.  That's what we're doing here.

        // Find the proper layer and put us right after it, if it's there
        let geolineLayer = style.layer(withIdentifier: "geolines")
        if (geolineLayer != nil ) {
            style.insertLayer(mapOverlay!, above: geolineLayer!)
        } else {
            style.layers.append(mapOverlay!)
        }

Once the map style is loaded, MapLibre will call the code we're passing in there.  It's pretty normal to put your own logic in here for when the map is ready, so you can just tack our Adapter setup to your own.  Or if you have another way of knowing the map is loaded, that's fine too.

Now we're ready to render, but what are we rendering?  That's where the serviceReady() delegate method comes in and ours looks a little like this.

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

There's a lot going on here, most of it as an example.  The main point is that Terrier is ready to go when serviceReady is called.  You can now create your display layers.  

Weather layers need a few things to work:
- Terrier, logically enough.  We need that infrastructure to render anything.
- The variable, that is *what* they're displaying
- A trrColorMap to turn values into colors.  Temperature provides its own by default, but you can override it.
- The cadence, which is the time period over which they're displaying and how much of it to display.

We start here with a temperature layer with an opacity of 0.5.  TrrTemperatureController is really just a convenience wrapper over a Single Variable layer that filters out variables named "temperature" over the continental US.  

By default you'll get GFS, RTMA, and HRRR (soon to be RRFS).  GFS covers the whole world, but we're filtering out everything that doesn't overlap CONUS by default.  That's all configurable.

All the layers need to be started, hence the start() call.  To turn them off, as you might have guessed, call stop().

After creating the layer, we want to set up time information, the TrrSourceCadence, to control how much of this the user sees.  We set it up with minus 24 hours and plus 24 hours.  Then we resolve it into real times and pass that into the TrrTimeTracker.  You can change the TrrTimeTracker whenever you like, setting it to a new time or changing the range.  It will update anything watching it.

As an aside, the TrrSourceCadence makes more sense with the lower level controllers.  The TrrTemperatureController is hiding a lot by default.  We'll flesh that out more later.

The last thing we do here is call play() so the tracker animates over the 2 day period.

## Up Next
The Temperature example should be enough to get you going.  The code is all here in the directory, so feel free to peruse our example.

We have a fairly elaborate test app for Terrier and I'll be bringing more pieces of that over for things like radar, hooking up the TrrTimeTracker to a slider, and tweaking some of the settings.
