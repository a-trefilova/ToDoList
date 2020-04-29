//
//  ViewController.swift
//  ToDoList
//
//  Created by Константин Сабицкий on 28.04.2020.
//  Copyright © 2020 Константин Сабицкий. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let segueIdentifier = "tasksSegue"
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        
        
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        warningLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
            
        }
        
//        //MARK: METHOD FOR KEYBOARD it isnt working in this version of xcode
//        //create observers
//        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    //MARK: FIX IT
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
        //realizing methods for observers
//    @objc func kbDidShow(notification: Notification) {
//        //get the user information
//        guard let userInfo = notification.userInfo else {return}
//        // catch the size of keyboard frame and cast for needed type (ns value and cgrect value)
//        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        // do the size of scroll view (width as previous and height is revious view + keyboard height
//        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + kbFrameSize.height)
//        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
//    }
//
//
//    @objc func kbDidHide() {
//        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
//
//    }
   
    
    
    func displayWarningLabel(withText text: String) {
        warningLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.warningLabel.alpha = 1
            
        }) { [weak self] complete in
            self?.warningLabel.alpha = 0
        }
    }
    

    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        }
        
        
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
                   displayWarningLabel(withText: "Info is incorrect")
                   return
               }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            
            guard error == nil, user != nil else {
                print(error!.localizedDescription)
                return
            }
            
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
        }
        
        
    }
    
    
    
   
   
    
}


