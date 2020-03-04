//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Wei Nie on 2/23/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
    let commentBar = MessageInputBar()
    var showsCommentBarBar = false
    var selectedPost: PFObject!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOutInBackground(block:{(error) in
            if let error = error{
                print(error.localizedDescription)
            }
            else{
                let main = UIStoryboard(name: "Main",bundle: nil)
                let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
                let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                
                sceneDelegate.window?.rootViewController = loginViewController
                
            }
        })
    }
    
    var posts = [PFObject]()
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBarBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className:"Posts")
        
        query.includeKeys(["author","comments","comments.author"])
        
        query.limit = 20
        
        query.findObjectsInBackground{
            (posts, error) in
            if(posts != nil){
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        
        let post = posts[indexPath.section]
        let user = post["author"] as! PFUser
        
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == 0{
            cell.usernameLabel.text = user.username
                
                cell.captionLabel.text = post["caption"] as! String
                    
            
                let imageFile = post["image"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
            
                cell.photoView.af_setImage(withURL: url)
                
                return cell
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
            
        }
        
    }
    
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground{
         (success, error) in
            if success{
                print("Comment saved")
            }else{
                print("error saving comment")
            }
        }
        
        tableView.reloadData()
        //clear comment bar
        commentBar.inputTextView.text = nil
        showsCommentBarBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        if indexPath.row == comments.count + 1{
            showsCommentBarBar = true
            becomeFirstResponder()
        commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
       /*func tableView(_ tableView: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
            if(indexPath.row == 0){
                return 400.0
            }else{
                return 40.0
            }
        }*/
        /*comment["text"] = "this is a random comment"
        
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        post.saveInBackground{
         (success, error) in
            if success{
                print("Comment saved")
            }else{
                print("error saving comment")
            }
        }*/
            
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.keyboardDismissMode = .interactive
        
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBarBar = false
        becomeFirstResponder()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
