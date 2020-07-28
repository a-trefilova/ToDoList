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
    
//MARK: - IBOutlets
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//MARK: - Private Properties
    private let segueIdentifier = "tasksSegue"
    private var ref: DatabaseReference!
 
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        ref = Database.database().reference(withPath: "users")
        
        warningLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
       
//MARK: - Private Methods
    private func displayWarningLabel(withText text: String) {
        warningLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.warningLabel.alpha = 1
            
        }) { [weak self] complete in
            self?.warningLabel.alpha = 0
        }
    }
    
//MARK: - IBActions
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


