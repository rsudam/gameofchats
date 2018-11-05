//
//  Extentions.swift
//  gameofchats
//
//  Created by Raghu Sairam on 24/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit

extension UIColor {
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1 )
    }
}

let imageCache = NSCache<NSString,AnyObject>()

extension UIImageView{
    
    func loadImageUsingCacheWithUrlString(_ urlString:String) {
        self.image = nil
        
        if let cachedImge = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImge
            return 
        }
        
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            if error != nil {
                print("Error occurred while downloading images")
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
    
}
