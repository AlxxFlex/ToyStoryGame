//
//  ViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 24/03/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Splashimg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let splashSize: CGFloat = view.frame.width * 0.8
        let splashImgSize = CGSize(width: splashSize, height: splashSize)
        let splashOrigin = CGPoint(
            x: (view.frame.width - splashImgSize.width) / 2,
            y: (view.frame.height - splashImgSize.height) / 2
        )

        Splashimg.frame = CGRect(origin: splashOrigin, size: splashImgSize)

        // Empieza chiquita y transparente
        Splashimg.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        Splashimg.alpha = 0.0

        UIView.animate(withDuration: 3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            // Hace zoom con rebote
            self.Splashimg.transform = .identity
            self.Splashimg.alpha = 1.0
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.performSegue(withIdentifier: "sgSplash", sender: nil)
            }
        }
    }


}

