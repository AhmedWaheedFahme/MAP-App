//
//  MapVC.swift
//  Pixel-City-Map
//
//  Created by Ahmed Waheed on 8/25/18.
//  Copyright © 2018 Ahmed Waheed. All rights reserved.
//

import UIKit
import MapKit // to show the map and use all instruction of its kit
import CoreLocation // to make a location request of user
import Alamofire // to download image from the internet
import AlamofireImage

class MapVC: UIViewController , UIGestureRecognizerDelegate{
    
    // our outlets
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstrains: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var screenSize = UIScreen.main.bounds
    var spinner :UIActivityIndicatorView?
    var progressLbl :UILabel?
    var collectionView : UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    let authorizationStatus = CLLocationManager.authorizationStatus() // if you allow or deny to show your location (send message for privacy) and impelement it now
    let regionRadius : Double = 500 // we can change it to any value
    
    override func viewDidLoad() {
        super.viewDidLoad()
            mapView.delegate = self // to run automaticaly and see the map
            locationManager.delegate = self // to run automaticaly and see your actual location
            configureLocationServices()
            addDoubleTap()
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
            collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
            collectionView?.delegate = self
            collectionView?.dataSource = self
            pullUpView.addSubview(collectionView!)
            collectionView?.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
            registerForPreviewing(with: self, sourceView: collectionView!) // to confirm the 3d touch
        
    }
  
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView() // to init it
        spinner?.center = CGPoint(x: (screenSize.width / 2 ) - ( (spinner?.frame.width)! / 2 ), y: 150) // to make it at the center of the subview
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
   
    func removeSpinner (){ // to remove the spinner from the pull up view
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){ // we made that function to add a label below the spinner to give us some details about that place
        progressLbl = UILabel()
        progressLbl?.textAlignment = .center
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.font = UIFont(name: "Avenir", size: 14)
        progressLbl?.frame = CGRect(x: (screenSize.width / 2 ) - 120, y: 175, width: 240, height: 40)
        collectionView?.addSubview(progressLbl!) // to appear front of the collection view not behind it
    }
    
    func removeProgressLbl(){
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    func retrieveUrls(forAnnotation annotaion:droppablePin , handler : @escaping (_ status:Bool)->()){
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotaion, andNumberOfPhotos: 40)).responseJSON { (response) in
          
            guard let json = response.result.value as? Dictionary <String ,AnyObject> else {return}
            let photoDic = json["photos"] as! Dictionary<String,AnyObject>
            let photosDictArray = photoDic["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photosDictArray {
            let postUrl = "http://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d_jpg"
            self.imageUrlArray.append(postUrl)
            
            }
            handler(true)
        }
    }
    func retrieveImages(handler: @escaping(_ status : Bool) ->()){
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                // we will make a check
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSessions(){ // we make that to cancel downloading the images from server when we drop a pin again or cancel it by swipping down
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    
    func addSwip(){ // we make that to swip down the subview
        let swip = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swip.direction = .down
        pullUpView.addGestureRecognizer(swip)
    }
 @objc func animateViewDown(){
        cancelAllSessions() // to when we swip down cancel all things
        pullUpViewHeightConstrains.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func animateViewUp(){ // to animate the pull up view and it is appear when we drop a pin so we must call it in drop a pin function
        pullUpViewHeightConstrains.constant = 300 // to replace the height of the pullUpView from 1 to 300
        UIView.animate(withDuration: 0.3) { // ro make it with animation
            self.view.layoutIfNeeded()
        }
    }
    
     @IBAction func centerMapBtnPressed(_ sender: Any) { // to when press in the the button your location be in the middle of screen
        /* we want when we press in the button center your current loaction on the map
        we ask if you choose your location service (always) or (when you use the app) make it at the center */
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            CenterMapOnUserLocation()
        }
    }
}

extension MapVC : MKMapViewDelegate{
   
  // we make a customize function to make a droppable pin is orange
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { // to make the user location is a defualt point
            return nil}
        let pinAnnotaiton = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotaiton.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotaiton.animatesDrop = true
        return pinAnnotaiton
    }
 
    func CenterMapOnUserLocation (){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0 , regionRadius * 2.0 )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender:UITapGestureRecognizer){
        cancelAllSessions()
        removePin()
        removeSpinner()
        animateViewUp()
        
        imageUrlArray = [] // we make that to when drop a new pin delete the previous pics in array
        imageArray = []
        collectionView?.reloadData()
        
        addSwip()
        addSpinner()
        addProgressLbl()
        // drop pin on the map
        let touchPoint = sender.location(in:mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotaion = droppablePin(coordinate:touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotaion)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0 , regionRadius * 2.0 )
        mapView.setRegion(coordinateRegion, animated: true)
        print(flickrUrl(forApiKey: apiKey, withAnnotation: annotaion, andNumberOfPhotos: 40))
        retrieveUrls(forAnnotation: annotaion) { (finished) in
        
        if finished { // taht's meaning finished equal true
            self.retrieveImages(handler: { (finished) in
             if finished {
                self.removeSpinner()
                self.removeProgressLbl()
                self.collectionView?.reloadData()
                }
            })
            }
        }
    }
  
    func removePin (){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}

extension MapVC : CLLocationManagerDelegate { // to make a configuration notification to allow the location service or deny
    
    func configureLocationServices (){
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {return}
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        CenterMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
       let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
        
    }
}

extension MapVC : UIViewControllerPreviewingDelegate { // we did that to make a 3d touch we create it by initaite two methods
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) , let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as?PopVC else {return nil}
        popVC.initData(forImage: imageArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        
        return popVC
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}
