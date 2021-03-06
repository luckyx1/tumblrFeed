//
//  PhotosViewController.swift
//  TumblrFeed
//
//  Created by Rob Hernandez on 1/14/17.
//  Copyright © 2017 Robert Hernandez. All rights reserved.
//

import UIKit
import AFNetworking


class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate   {
    
    var posts: [NSDictionary] = []

    @IBOutlet weak var photoTable: UITableView!
    var loadingMoreView: InfiniteScrollActivityView?
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoTable.delegate = self
        photoTable.dataSource = self
        photoTable.rowHeight = 240
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)

        // add refresh control to table view
        photoTable.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: photoTable.contentSize.height, width: photoTable.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        photoTable.addSubview(loadingMoreView!)
        
        var insets = photoTable.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        photoTable.contentInset = insets


        self.tumblrGet()
        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
       self.tumblrGet()
    }

    
    func tumblrGet(){
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {

                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.photoTable.reloadData()
                        // Tell the refreshControl to stop spinning
                        self.refreshControl.endRefreshing()
                        // Update flag
                        self.isMoreDataLoading = false
                        
                        // Stop the loading indicator
                        self.loadingMoreView!.stopAnimating()
                    }
                }
        });
        task.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = photoTable.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - photoTable.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && photoTable.isDragging) {
                isMoreDataLoading = true
                
                // update position of loading more view and start loading indicator
                let frame = CGRect(x: 0, y: photoTable.contentSize.height, width: photoTable.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                self.tumblrGet()
               
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("I have \(self.posts.count) posts")
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
        let post = posts[indexPath.row]
        let photos = post.value(forKeyPath: "photos") as? [NSDictionary]
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            // photos is NOT nil, go ahead and access element 0 and run the code in the curly braces
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                cell.photoImage.setImageWith(imageUrl)
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }

        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var indexPath = photoTable.indexPath(for: sender as! UITableViewCell)
        // Get in touch with the DetailViewController
        var vc = segue.destination as! PhotoDetailsViewController
        // Pass on the data to the Detail ViewController by setting it's indexPathRow value
        let cell = self.tableView(self.photoTable, cellForRowAt: indexPath!) as! PhotoCell
        vc.image = cell.photoImage.image
    }
    
    


}
