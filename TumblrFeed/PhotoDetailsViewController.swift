//
//  PhotoCellViewController.swift
//  TumblrFeed
//
//  Created by Rob Hernandez on 1/14/17.
//  Copyright © 2017 Robert Hernandez. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    @IBOutlet weak var DetailImage: UIImageView!
    var image: UIImage!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.DetailImage.image = image

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
