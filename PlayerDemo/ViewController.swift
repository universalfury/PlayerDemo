//
//  ViewController.swift
//  PlayerDemo
//
//  Created by Vartika Singh on 10/01/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var defaultPlayerButton: UIButton!
    @IBOutlet weak var customPlayerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func cutomPlayerButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomPlayerViewController") as? CustomPlayerViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

enum CurrentPlayerState {
    case playing
    case pause
}

extension UIView {

    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: T.self, options: nil)![0] as! T
    }
}

