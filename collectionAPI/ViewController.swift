//
//  ViewController.swift
//  collectionAPI
//
//  Created by Hy Horng on 9/29/20.
//  Copyright © 2020 Hy Horng. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

struct Hero: Decodable {
    let localized_name: String
    let img: String
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!
    
    var heroes = [Hero]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        // declear variable to store API link
        let urlString = URL(string: "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: urlString!) { (data, response, error) in
            if error == nil {
                do {
                self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                }catch {
                    print("Parse Error")
                }
                DispatchQueue.main.sync {
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! customCollectionViewCell
        
        cell.nameLbl.text = heroes[indexPath.item].localized_name.capitalized
        cell.nameLbl.numberOfLines = 0
        cell.imageView.contentMode = .scaleAspectFill
        let defualtLink = "https://api.opendota.com"
        let completeLink = defualtLink + heroes[indexPath.item].img
        
        cell.imageView.downloadedFrom(link: completeLink)
        
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = (cell.imageView.frame.height) / 2
        
        return cell
    }
}



