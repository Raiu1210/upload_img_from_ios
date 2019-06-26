//
//  ViewController.swift
//  photo_upload_from_ios
//
//  Created by Ryu Ishibashi on 2019/06/26.
//  Copyright © 2019 Ryu Ishibashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var image: UIImage?
    var imageView: UIImageView?
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        create_choose_photo_button()
        create_activity_indicator()
        create_upload_button()
    }
    
    internal func create_choose_photo_button() {
        let choose_photo_button = UIButton()
        choose_photo_button.setTitle("画像を選択", for: .normal)
        choose_photo_button.backgroundColor = UIColor.orange
        choose_photo_button.sizeToFit()
        choose_photo_button.frame = CGRect(x: 10, y: 70, width: UIScreen.main.bounds.size.width-20, height: 38)
        choose_photo_button.addTarget(self, action: #selector(choose_photo_from_camera_roll(_:)), for: .touchUpInside)
        
        self.view.addSubview(choose_photo_button)
    }
    
    @objc internal func choose_photo_from_camera_roll(_ sender:UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    internal func create_image_view(image:UIImage) {
        self.imageView?.image = nil
        self.imageView = UIImageView(image: image)
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        let imgWidth:CGFloat = image.size.width
        let imgHeight:CGFloat = image.size.height
        
        let scale:CGFloat = screenWidth / (imgWidth * 2)
        let rect:CGRect = CGRect(x:0, y:0, width:imgWidth*scale, height:imgHeight*scale)
        self.imageView!.frame = rect;
        self.imageView!.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        self.view.addSubview(self.imageView!)
    }
    
    internal func create_upload_button() {
        let upload_button = UIButton()
        upload_button.setTitle("upload", for: .normal)
        upload_button.backgroundColor = UIColor.orange
        upload_button.sizeToFit()
        upload_button.frame = CGRect(x: 10, y: 400, width: 70, height: 40)
        upload_button.addTarget(self, action: #selector(upload(_:)), for: .touchUpInside)
        
        self.view.addSubview(upload_button)
    }
    
    @objc internal func upload(_ sender:UIButton) {
        let param = [
            "firstName" : "Hello",
            "lastName"  : "World",
            "userId"    : "7"
        ]
        let url = URL(string: "http://zihankimap.work/mona/upload")
        let boundary = generateBoundaryString()
        let image_data = (self.image?.jpegData(compressionQuality: 0.75))!
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: image_data as NSData, boundary: boundary) as Data
        
        self.activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error=\(error)")
                    return
                }
                
                print("******* response = \(response)")
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("****** response data = \(responseString!)")
                
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.imageView?.image = nil
                }
            }
            task.resume()
        }
    }
    
    internal func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    internal func createBodyWithParameters(parameters:[String:String]?, filePathKey:String?, imageDataKey:NSData, boundary:String) -> NSData {
        
        let body = NSMutableData()
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        let filename = "user-profile.jpg"
        let mimetype = "image/jpeg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    internal func create_activity_indicator() {
        activityIndicatorView.frame = CGRect(x: 200, y: 500, width: 60, height: 60)
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .purple
        self.view.addSubview(activityIndicatorView)
    }
    
    
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // キャンセルボタンを押された時に呼ばれる
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 写真が選択された時に呼ばれる
        print("Picked image")
        self.dismiss(animated: true)
        self.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.create_image_view(image: self.image!)
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


