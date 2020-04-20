//
//  AboutViewController.swift
//  WeatherGift
//
//  Created by Heesu Yun on 4/20/20.
//  Copyright © 2020 Heesu Yun. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil) // to get rid of smth present modally
    }
    
}
