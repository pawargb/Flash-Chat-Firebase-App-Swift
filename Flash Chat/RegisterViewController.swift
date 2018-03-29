//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        

        SVProgressHUD.show()
        //TODO: Set up a new user on our Firbase database
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil{
                SVProgressHUD.dismiss()
                //String
                self.showerror(errorName : String(describing: error!))
            }else{
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
    }
    
    func showerror(errorName : String){
        //print([errSecReadOnly])
        let alert = UIAlertController(title: "Login Failed!", message: errorName, preferredStyle: .alert)
        
        //set an action on alert buttons
        
        let restartAction = UIAlertAction(title: "Try Again", style: .default, handler: { (UIAlertAction) in self.startOver() })
        
        alert.addAction(restartAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func startOver(){
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    
    
}
