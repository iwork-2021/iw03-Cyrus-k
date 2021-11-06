//
//  NewsTableViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/3.
//

import UIKit
import WebKit

class NewsTableViewController: UITableViewController {
    var Dictcell:[BasicCell] =
    [
        //BasicCell(title: "helloworld", date: "1",URL: "a"),
        //BasicCell(title: "hello", date: "2",URL: "b")
    ]
    var AllPage = 0
    var CurrentPage = 1
    var Finish:Bool = false
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view = webView
        //while self.CurrentPage != self.AllPage{
        self.loadURL()
     
        //}
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Dictcell.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) as! DisplayTableViewCell
        let tempCell = Dictcell[indexPath.row]
        
        cell.title.text! = tempCell.title
        cell.date.text! = tempCell.date        // Configure the cell...

        return cell
    }
    
    func loadURL() {
        let url = self.CurrentPage == 1 ? URL(string: "https://itsc.nju.edu.cn/xwdt/list.htm")! : URL(string: "https://itsc.nju.edu.cn/xwdt/list\(self.CurrentPage).htm")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                        let data = data,
                        let string = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                //self.contentView.text = string
                               
                                //print(string)
                                
                                //var str = string.replacingOccurrences(of: "<[^>]+>", with: "",options: .regularExpression,range: nil)
                                var str = string.replacingOccurrences(of: "</div>", with: "")
                                //print(str)
                                str = str.replacingOccurrences(of: "</ul>", with: "")
                                str = str.replacingOccurrences(of: "</li>", with: "")
                                var lines = str.replacingOccurrences(of: "\t", with: "").split(separator: "\r\n")
                                for i in lines{
                                    var symbol = i.split(separator: ">")
                                    //print(symbol[0])
                                    if symbol[0] == "<span class=\"news_title\""{
                                        self.Dictcell.append(BasicCell(title: symbol[2].replacingOccurrences(of: "</a", with: ""), date: "unknown", URL:"https://itsc.nju.edu.cn" + String(symbol[1].split(separator: "'")[1])))
                                    }
                                    else if symbol[0] == "<span class=\"news_meta\""{
                                        self.Dictcell[self.Dictcell.count-1].ModifyDate(date: symbol[1].replacingOccurrences(of: "</span", with: ""))
                                    }
                                    else if symbol[0] == "         <span class=\"pages\""{
                                        self.AllPage = Int(symbol[4].replacingOccurrences(of: "</em", with: ""))!
                                        
                                    }
                                        
                                }
                                //print(lines)
                                self.CurrentPage = self.CurrentPage + 1
                                self.loadURL()
                                self.tableView.reloadData()
                        }
            }
            
        })
        
        task.resume()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let NewsViewController = segue.destination as! ItemViewController
        let cell = sender as! DisplayTableViewCell
        NewsViewController.Url = Dictcell[tableView.indexPath(for: cell)!.row].URL
        NewsViewController.style = "News"
    }
}
                    
     
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
 
    

    

