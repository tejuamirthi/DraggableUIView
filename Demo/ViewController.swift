//
//  ViewController.swift
//  Demo
//
//  Created by Amirthy Tejeshwar on 14/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit
import DraggableUIView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let draggableView = DraggableUIView(frame: .zero)
        view.addSubview(draggableView)
        draggableView.mode = .topBottomLeftRight
        draggableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            draggableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            draggableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            draggableView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/3.5),
            draggableView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2.5)
        
        ])
        draggableView.backgroundColor = .white
        
        
        
        view.backgroundColor = .red
    }


}

