//
//  MasterViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController,RefreshMailDataDelegate {
    
    var mail:BaseMail!;
    //邮箱登录信息
    var mailloginInfo=mailLoginInfo();
    //邮箱文件夹在    
    var mailFolders=MAILFOLDERS();
    
//    private var mailList:[String]?
    private  var mailContent: [String]?
    
    private var listImg=["inbox","flag","trash","newmail","folder","sendbox","spam"];
    
    
    
    var maillistViewController: MailListViewController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //初始化界面风格
        //1.加左边按钮
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        //2.加右边按钮
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        //顶部信息栏的颜色
        self.navigationController?.navigationBar.backgroundColor = UIColor.redColor()
        
        //3.加底部状态信息
        let statusbutton = UIBarButtonItem(title: "刚刚更新", style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        statusbutton.width=0;//调左边距的
        
        
        let items=[statusbutton];
        //必须加上topViewController，否则不管用
        self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
        
        
        self.navigationController?.toolbar.tintColor=UIColor.redColor();
        
        
        
        self.navigationController?.setToolbarHidden(false, animated:true)
        
        //可以动态改变
        //        self.navigationController?.topViewController!.toolbarItems![0].title="Hello"
        
        
        self.maillistViewController = MailListViewController();
        
        //界面初始化完毕
        
        //初始化登录信息--126
        self.mailloginInfo.hostname="imap.126.com";
        self.mailloginInfo.username="chinagis001@126.com"
        self.mailloginInfo.password=""
        self.mailloginInfo.port=993;
        //-icloud
//        self.mailloginInfo.hostname="p03-imap.mail.me.com";
//        self.mailloginInfo.username="chinagis001@sina.com"
//        self.mailloginInfo.password=""
//        self.mailloginInfo.port=993;
//
        mail=ImapMail(mailloginInfo);
        
        mail.delegate=self;
        
        //获取文件夾信息
        self.mailFolders=mail.getMailFolder();
        
        
        maillistViewController!.mail=self.mail;
        
      }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed;
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: AnyObject) {
//        objects.insert(NSDate(), atIndex: 0)
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            }
        
        //显示二级目录
        if segue.identifier == "ShowMaillist" {
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("master count=\(siteNames!.count)");
        var count:Int=0;
        if section==0 //第一节
        {
            count=min(mailFolders.count,3);
        }
        else //第二节
        {
            assert(mailFolders.count>3)
            count=mailFolders.count-3;
        }
        return count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
        
        let section=indexPath.section;
        
        var folderFlag=MCOIMAPFolderFlag.None;
        
        var index=0;
        
        
        if section==0
        {
             index=indexPath.row;
            
            if index==1
            {
                cell.accessoryType=UITableViewCellAccessoryType.DetailDisclosureButton
            }
        }
        else if self.mailFolders.count>3
        {
            index=indexPath.row+3;
            
        }
        
        let folderMeta=getIndexFolder(index);
        
        cell.textLabel!.text = folderMeta.folderName
        //目录中邮件的数量
        cell.detailTextLabel!.text = "\(folderMeta.mailCount)";
        
        folderFlag=folderMeta.folderFlag;
        
 //       private var listImg=["inbox","flag","trash","newmail","folder","sendbox","spam"];

        
        var imgIndex=4;
        
        if folderFlag.contains(MCOIMAPFolderFlag.Inbox)
        {
            imgIndex=0
        }
        
        if folderFlag.contains(MCOIMAPFolderFlag.Trash)
        {
            imgIndex=2
        }
        
        if folderFlag.contains(MCOIMAPFolderFlag.Spam)
        {
            imgIndex=6
        }
        
        if folderFlag.contains(MCOIMAPFolderFlag.SentMail)
        {
            imgIndex=5
        }

        if folderFlag.contains(MCOIMAPFolderFlag.Drafts)
        {
            imgIndex=3
        }

        
        cell.imageView?.image=UIImage(named: listImg[imgIndex]);
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
//            objects.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    // UITableViewDelegate协议方法，点击时调用
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        /*       // 跳转到detailViewController，取消选中状态
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        //更具定义的Segue Indentifier进行跳转
        self.performSegueWithIdentifier("ShowMaillist", sender: siteLists![indexPath.row])*/
        
        if indexPath.row >= 0
        {
            self.maillistViewController?.hidesBottomBarWhenPushed=true;
            
            
//            maillistViewController!.mailList = mailList!;
            
            var foldname="INBOX";
            
            
            if indexPath.section==0
            {
                foldname=self.getIndexFolder(indexPath.row).folderName;
            }
            else
            {
                foldname=self.getIndexFolder(indexPath.row+3).folderName;
            }
            
            
            
            //隐藏导航栏
            self.navigationController?.pushViewController(maillistViewController!, animated: true);
           
        
            self.mail.getMailList(foldname, delegate: maillistViewController!,upFresh: true);
            
        }
    }
    
    //设置2个分区
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        var section=1;
        if mailFolders.count>3
        {
            section=2;
        }
        return section;
    }
    
    // MARK:UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的Header文字信息
    override func tableView(tableView:UITableView, titleForHeaderInSection
        section:Int)->String?
    {
        var str:String?;//="TEST";
        if section>0
        {
            str="邮箱";
        }
        return str;
        
    }
    
    // MARK:UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的尾部
    override func tableView(tableView:UITableView, titleForFooterInSection
        section:Int)->String?
    {
        var str:String?;
        if section==1
        {
            // str = "刚刚更新";
        }
        return str;
    }
    
    
  func RefreshMailFolderData(objData:MAILFOLDERS)
  {
    self.mailFolders=objData;
    
//    for mailfolder in mailFolders
//    {
//        print("foldername in list =\(mailfolder.0)")
//    }
    self.tableView.reloadData();
    }
    
    private  func getIndexFolder(index:Int)->mailFolderMeta
    {
        //        assert(index<self.count);
        var folderMeta=mailFolderMeta();
        
        var tempFolders=self.mailFolders;
        
        var threeFolders=["INBOX","已发送","草稿箱"];
        
  
        switch index
            {
                case 0,1,2:
                    if self.mailFolders[threeFolders[index]] != nil
                    {
                        folderMeta=self.mailFolders[threeFolders[index]]!;
                    }
   
        default:
           
            tempFolders.removeValueForKey(threeFolders[0])
            tempFolders.removeValueForKey(threeFolders[1])
            tempFolders.removeValueForKey(threeFolders[2])

            
            let keys = Array(tempFolders.keys).sort(){$0 > $1};
        
            
            let tempValue = keys[index-3];


            if self.mailFolders[tempValue] != nil
            {
                folderMeta=self.mailFolders[tempValue]!;
            }
            
           
        }
        
        return folderMeta;
        
    }
    
}

