# QueryVenueLayerIssue

A small project to reproduce the issue : https://github.com/mapbox/mapbox-gl-native/issues/11780

Step to trigger behaviour :

- Click on a POI (ex : 336)

- Click on a POI with a smallest value as title (ex : 306)

The Selected POI on the second click is almost each time the N-1 POI (305 with the example value)
