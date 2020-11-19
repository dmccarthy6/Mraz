//  Created by Dylan  on 11/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

protocol LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? { get set }
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    func requestLocation()
}

protocol LocationFetcherDelegate: class {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locs: [CLLocation])
    func locationFetcher(_ fetcher: LocationFetcher, didEnterRegion region: CLRegion)
    func locationFetcher(_ fetcher: LocationFetcher, didChangeAuthorization: CLAuthorizationStatus)
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error)
}

extension CLLocationManager: LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegate? }
        set { delegate = newValue as! CLLocationManagerDelegate? }
    }
}
