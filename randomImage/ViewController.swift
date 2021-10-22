//
//  ViewController.swift
//  randomImage
//
//  Created by Mac on 2021/10/08.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapButton(_ sender: Any) {
        searchAPI.search { (images) in
            guard let resultImage = images else { return }
            guard let imageURL = URL(string: resultImage.url) else { return }
            
            do {
                let imageData = try Data(contentsOf: imageURL)
                DispatchQueue.main.async {
                    self.dogImage.image = UIImage(data: imageData)
                    self.dogImage.reloadInputViews()
                }
            } catch _ {
                return
            }
        }
    }
}

class searchAPI {
    static func search(completion: @escaping (Result?) -> Void) {
        let session = URLSession(configuration: .default)
        
        guard let urlComponent = URLComponents(string: "https://random.dog/woof.json") else {
            completion(nil)
            return
        }
        
        let requestURL = urlComponent.url!
        
        let dataTask = session.dataTask(with: requestURL) { (data, response, error) in
            let statusRange = 200..<300
            
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  statusRange.contains(statusCode) else {
                      completion(nil)
                      return
                  }
            
            guard let resultData = data else {
                completion(nil)
                return
            }
            
            let res = searchAPI.parseData(resultData)
            completion(res)
        }
        dataTask.resume()
    }
    
    static func parseData(_ data: Data) -> Result? {
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(Result.self, from: data)
            return response
        } catch let error {
            print("-->parsingError: (\(String(describing: error))")
            return nil
        }
    }
}

struct Result: Codable {
    let url: String
}
