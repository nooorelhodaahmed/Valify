//
//  PhotoViewController.swift
//  CamraFrameWork
//
//  Created by norelhoda on 05/03/2024.
//

import UIKit

public protocol MyDataSendingDelegateProtocol: NSObject {
    func sendDataToFirstViewController(myData: UIImage)}

class PhotoViewController: UIViewController {
    
    //MARK: - Proporties
    public var delegate: MyDataSendingDelegateProtocol? = nil
    var takenPhoto :UIImage?
    
    //MARK: - Outlets
    @IBOutlet weak var imageView:UIImageView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let availableImage = takenPhoto {
            self.imageView.image = availableImage
        }
    }
    
    //MARK: - Selector Function
    @IBAction func recaptureImage() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func approveImage() {
        //go back to application
        self.dismiss(animated: true, completion: nil)
        delegate?.sendDataToFirstViewController(myData: (self.imageView.image ?? UIImage(named: "test"))!)
    }
}
