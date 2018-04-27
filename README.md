# QueryVenueLayerIssue

A small project to reproduce the issue : https://github.com/mapbox/mapbox-gl-native/issues/11780

Step to trigger behaviour :

- Click on a POI (ex : 336)

- Click on a POI with a smallest value as title (ex : 306)

The Selected POI on the second click is almost each time the N-1 POI (305 with the example value)



## Other issue seen on this project

When zoom out, the POI #0 (coordinate (0.0, 0.0) should be always visible cause it is the first POI of the features array but it is not. It is hidden by collision.

If you change those lines : 

feature[@"latitude"] = [NSNumber numberWithDouble:i/10000.0];
feature[@"longitude"] = [NSNumber numberWithDouble:j/10000.0];

with : 
feature[@"latitude"] = [NSNumber numberWithDouble:(i/10000.0 + 0.0001)];
feature[@"longitude"] = [NSNumber numberWithDouble:(j/10000.0 + 0.0001)];

The POI #0 (coordinate (0.0001, 0.0001) is always displayed as expected.

It seems to have an issue on collision when the longitude is equal to 0.0
