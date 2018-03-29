//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate{
   
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    var keyboardHeight: CGFloat = 0
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO : Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle : nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieve()
        messageTableView.separatorStyle = .none
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
  
    //TODO : get Keyboard height
    
    @objc func keyboardShown(notification: NSNotification) {
        print("keyboardShown called")
        
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        keyboardHeight = keyboardFrame.size.height
        
        print("keyboardFrame: \(keyboardFrame)")
    }
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("tableView called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named : "egg")
       
        if cell.senderUsername.text == Auth.auth().currentUser?.email{
            cell.avatarImageView.backgroundColor = UIColor.flatRed()
            cell.messageBackground.backgroundColor = UIColor.flatRed()
            
        }else{
            cell.avatarImageView.backgroundColor = UIColor.flatBlue()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("table view numberOfRowsInSection called")
        return messageArray.count
    }
    
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }

    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
        print("configureTableView completed")
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5) {
            print("keyboard height \(self.keyboardHeight+50)")
            self.heightConstraint.constant = self.keyboardHeight+50
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
        //name;: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    

    @IBAction func sendPressed(_ sender: AnyObject) {

        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        let messageDB = Database.database().reference().child("Messages")

        messageTextfield.isEnabled = false
        sendButton.isEnabled = false

        let messageBody = ["Sender" : Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text!]

        messageDB.childByAutoId().setValue(messageBody){
            (error, reference) in
            //print("saving message into database")
            if error != nil{
                print("error")
            }else{
                print("message saved succesfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }

        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieve(){
        print("retrieve method called")
        
        let messageDB = Database.database().reference().child("Messages")
        
        
        messageDB.observe(.childAdded) { (snapshot) in
            print("observe method called")

            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["MessageBody"]!
            let value = snapshotValue["Sender"]!
            
            //print("observe method called")

            let message = Message()
            print(text, value)
            message.messageBody = text
            message.sender = value
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
            
            print("observe method finished")
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("sing out Error")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("no view controller to pop off")
                return
        }
    }
    


}
