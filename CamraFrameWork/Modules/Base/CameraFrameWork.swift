//
//  CameraFrameWork.swift
//  CamraFrameWork
//
//  Created by norelhoda on 05/03/2024.
//

import Foundation
import UIKit

public class CameraFrameWork: NSObject {
    
    //MARK: - Proporties
    var rootController: UIViewController?
    
    //MARK: - Intializer
    private override init() {
        super.init()
    }
    
    public init(controller: UIViewController) {
        self.rootController = controller
    }
    
    public func showController() {
        let frameworkBundle = Bundle(identifier: "Valify.CamraFrameWork")
        let storyboard =    UIStoryboard(name: "Camera", bundle: frameworkBundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.rootController?.present(navController, animated: true)
    }
}
