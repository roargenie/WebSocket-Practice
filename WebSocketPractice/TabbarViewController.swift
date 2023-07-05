//
//  TabbarViewController.swift
//  WebSocketPractice
//
//  Created by 이명진 on 2023/07/05.
//

import UIKit

final class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        delegate = self
        UITabBar.appearance().backgroundColor = .white
        tabBar.tintColor = .black
        tabBar.barTintColor = .white
        
        let urlsessionVC = ViewController()
        let starscreamVC = StarScreamViewController()
        
        self.setViewControllers([urlsessionVC, starscreamVC], animated: false)
        
        if let items = self.tabBar.items {
            items[0].selectedImage = UIImage(systemName: "link.circle.fill")
            items[0].image = UIImage(systemName: "link.circle")
            items[0].title = "URLSession"
            
            items[1].selectedImage = UIImage(systemName: "star.fill")
            items[1].image = UIImage(systemName: "star")
            items[1].title = "StarScream"
        }
    }
}
