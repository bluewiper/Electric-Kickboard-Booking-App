//
//  ViewController.swift
//  kickboardBookingAppProject
//
//  Created by 단예진 on 7/22/24.
//

import UIKit

class ViewController: UIViewController {
    
    var hidesBackButton: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        if hidesBackButton {
            navigationItem.hidesBackButton = true
        }
    }


}

