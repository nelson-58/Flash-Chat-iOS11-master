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

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    
    // Declare instance variables here
    // Create an array of empty Message class objects
    var messageArray : [Message] = [Message]()
    
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
        // #selector defines the function that will be called when the tap gesture is recognised
        let tapGesture = UITapGestureRecognizer(target : self, action : #selector(tableViewTapped))
        // set up the tap gesture against the messageTable View
        messageTableView.addGestureRecognizer(tapGesture)
        
        //TODO: Register your MessageCell.xib file here:
        
        messageTableView.register(UINib(nibName : "MessageCell",bundle : nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retreiveMessages()
        messageTableView.separatorStyle = .none
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        // messageBody is part of custom cell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        // format with colour depending on whether message is from current user
        // uses Chameleon
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            
            // set cell avator image background colour to something diff e.g. flat mint
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    
    //Declare tableViewTapped here:
    // This function is called when the messageTableView is tapped
    
    @objc func tableViewTapped() {
        // when TableView is tapped, then end editing. This will invoke the function textFieldDidEndEditing
        // which will move the text entry field back to the bottom of the page
        messageTextfield.endEditing(true)
        
    }

    //Declare configureTableView here:
    
    func configureTableView() {
        
        messageTableView.rowHeight = UITableViewAutomaticDimension  // default height
        messageTableView.estimatedRowHeight = 120.0
        
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //Declare textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    //Declare textFieldDidEndEditing here:
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //Send the message to Firebase and save it in our database
        // The first thing to do is stop Send being pressed multiple times by mistake
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        // create a messages database called "Messages" in Firebase
        let messagesDB = Database.database().reference().child("Messages")
        // Save the data entered on messagetextfield into a dictionary (spec defined by database API?)
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text ]
        // and save into database
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error,reference) in
            if error != nil {
                print (error!)
            }
            else {
                print ("Message saved ok")
                // reenable the text field and send button. Clear the existing message text
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retreiveMessages() {
        
        let messagesDB = Database.database().reference().child("Messages")
        // The closure below will get called whenever a new message is added to the DB
        // The snapshot has a number of paramaeters. We want the value.
        // The value is type any? because it comes from objective-C
        // we need to cast it as a dictionary
        messagesDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            // Use key "MessageBody" to get message
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            print (text, sender)
            let newMessage = Message()
            newMessage.messageBody = text
            newMessage.sender = sender
            // now add to the array
            self.messageArray.append(newMessage)
            // reconfigure tableview
            self.configureTableView()
            // reload the data from DB
            self.messageTableView.reloadData()
            
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        // Log out the user and send them back to WelcomeViewController
        // need to put "do ... catch" round signout to catch any errors
        do {
            try Auth.auth().signOut()
            // pop back to root controller
            navigationController?.popViewController(animated: true)
        }
        catch{
            print ("Error;there was a problem signing out")
        }
    }
    


}
