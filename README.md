# Terrier Mobile Libraries
This repo contains the binary libraries for Terrier and its dependencies for iOS.  This includes both arm64 and Simulator versions.  We also have examples for integration with various other libraries (only Mapbox at the moment).

For the specific of the [Mapbox example](ios/Mapbox-Integration/mapbox.md), look in the Mapbox-Integration folder in the iOS directory.

To add the Terrier framework to any app (including one that uses Mapbox), keep reading.

## Adding the Terrier Framework to your App

At the moment, there are xcframework files you'll need to import directly.  We're working on a Swift Package, but it's surprisingly persnickety about binary packages.  Luckily, this is not much extra work.

The first step is to clone this repo so you can have it locally.

In our example here we've already built a Mapbox based project, but if you're importing Terrier on its own, the process is the same.

Start at the Build Phases panel of your main Target and open the Link Binary With Libraries tab.
<img width="1065" alt="Screenshot 2024-12-08 at 11 30 50 PM" src="https://github.com/user-attachments/assets/eb02ccce-bbd5-45cf-ab80-4186cc51674f">

When the control comes up, select Add Files from the dropdown.

<img width="409" alt="Screenshot 2024-12-08 at 11 32 15 PM" src="https://github.com/user-attachments/assets/b1f7420e-d37e-4028-a34f-e79888607712">

Navigate to the Terrier/libraries folder and select both the Terrier and WhirlyGlobe xcframework directories.  These are the packages and contain versions for both iOS and the simulator.

<img width="1061" alt="Screenshot 2024-12-08 at 10 30 12 PM" src="https://github.com/user-attachments/assets/b99887b6-eb70-4b47-9d1f-d0b7a5206d5c">

Once this is done they are in your project, but you still need to reference them.  Hit that + button again and the same control will popup.  But now we want to select Terrier.xcframework and WhirlyGlobe.xcframework.

<img width="402" alt="Screenshot 2024-12-08 at 11 39 32 PM" src="https://github.com/user-attachments/assets/0e26465e-eff4-42de-8b73-1743f179edf8">

This will be enough to compile and link but there's one more step.  Go back to the General tab for your main target and look for "Frameworks, Libraries, and Embedded Content".  Set the Terrier and WhirlyGlobe entries to "Embed & Sign".

<img width="1060" alt="Screenshot 2024-12-08 at 11 40 35 PM" src="https://github.com/user-attachments/assets/32608da9-4b6a-4afd-afb0-3901a93cfbb5">

Without that your app will crash the first time it tries to use Terrier.

Now you should be able to use Terrier directly.  Try adding an "import Terrier" directive to one of your source files to check.

<img width="315" alt="Screenshot 2024-12-08 at 11 42 33 PM" src="https://github.com/user-attachments/assets/99d4dab9-d0d6-49a3-a49d-52ecd6859abf">
