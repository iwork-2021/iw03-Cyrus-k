//
//  ItemViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/5.
//

import UIKit
import WebKit

class ItemViewController: UIViewController {


    @IBOutlet weak var texttitle: UILabel!
    @IBOutlet weak var textone: UITextView!
    
    @IBOutlet weak var texttwo: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    var Url:String = ""
    var style:String = ""
    let webView = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUrl()
        self.view = self.webView
        // Do any additional setup after loading the view.
    }
    
    func loadUrl(){
        let url = URL(string:self.Url)!
        print(self.Url)
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
                                
                                //var content="<html>\r\n<meta charset=\"utf-8\">\r\n<base href=\"https://itsc.nju.edu.cn\"/>\r\n"
                                var content = "<html><body><meta charset=\"utf-8\"><base href=\"https://itsc.nju.edu.cn\"/><meta name=\"renderer\" content=\"webkit\" /><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><meta name=\"viewport\" content=\"width=device-width,user-scalable=0,initial-scale=0.8, minimum-scale=0.6, maximum-scale=0.8\"/>"
                                var lines = string.split(separator: "\r\n")
                                var flag = false
                                
                                for i in lines{
                                    //print(i)
                                    //print("good")
                                    if i == "<!--Start||content-->"{
                                        flag = true
                                    }
                                    else if i == "<!--End||content-->"{
                                        flag = false
                                    }
                                    if flag && i != "<!--Start||content-->"{
                                        if self.style == "Information"{
                                            if i.count >= 80{
                                                var pharse = i.split(separator: ">")
                                                /*if pharse.contains("<td height="){
                                                    var str = i.replacingOccurrences(of: "<span style=\"font-family:微软雅黑, &quot;microsoft yahei&quot;;font-size:16px;\"", with: "<span style=\"font-family:微软雅黑, &quot;microsoft yahei&quot;;font-size:21px;\"")
                                                    content = content + str
                                                }*/
                                                var temp:String = String(pharse[5])
                                                var temp2:String = String(pharse[2])
                                                var temp3 = pharse[6]==nil ? nil : String(pharse[6])
                                                if pharse[5] != nil{
                                                    //print(pharse[5])
                                                    if pharse[5].count>12 && pharse[5].substring(to: pharse[5].index(pharse[5].startIndex, offsetBy: 11)) == "<td height="{
                                                        temp = (pharse[5].replacingOccurrences(of: "width=\"922" , with: "width=\"400")).replacingOccurrences(of: "width:923px", with: "width:400px")
                                                        
                                                        temp2 = (pharse[2].replacingOccurrences(of: "width=\"922" , with: "width=\"500")).replacingOccurrences(of: "width:768px", with: "width:500px")
                                                        temp3 = pharse[6].replacingOccurrences(of: "<span style=\"font-family:微软雅黑, &quot;microsoft yahei&quot;;font-size:16px;\"", with: "<span style=\"font-family:微软雅黑, &quot;microsoft yahei&quot;;font-size:21px;\"")
                                                    }
                                                    var str = i.replacingOccurrences(of: pharse[5], with: temp)
                                                    str = str.replacingOccurrences(of: pharse[2], with: temp2)
                                                    if pharse[6] != nil{
                                                        str = str.replacingOccurrences(of: pharse[6], with: temp3!)
                                                    }
                                                   
                                                    content = content + str
                                                }
                                                else{
                                                    content = content + i
                                                }
                                            }
                                            else{
                                                content = content + i
                                            }
                                        }
                                        else{
                                            content = content + i
                                        }
                                    }
                                }
                               
                                content = content + "</body></html>"
                                //print(content)
                                //self.contentView.text = string
                               
                                //print(string)
                                
                                //var str = string.replacingOccurrences(of: "</div>", with: "",options: .regularExpression,range: nil)
                                /*var str = string.replacingOccurrences(of: "</div>", with: "")
                                //print(str)
                                str = str.replacingOccurrences(of: "</ul>", with: "")
                                str = str.replacingOccurrences(of: "</li>", with: "")
                                var lines = str.replacingOccurrences(of: "\t", with: "").split(separator: "\r\n")
                                for i in lines{
                                    print(i)
                                    var symbol = i.split(separator: ">")
                                    //print(symbol[0])
                                    //print(symbol)
                                    if symbol[0] == "<title"{
                                        self.texttitle.text = symbol[1].replacingOccurrences(of: "</title", with: "")
                                    }
                                    else if symbol[0].count > 30 && symbol[0].substring(to: symbol[0].index(symbol[0].startIndex, offsetBy: 24)) == "<meta name=\"description\""{
                                        self.textone.text = (symbol[0].replacingOccurrences(of: "<meta name=\"description\" content=\"", with: "")).replacingOccurrences(of: "\" /", with: "")
                                    }
                                    else if symbol[0].count > 15 && symbol[0].substring(to: symbol[0].index(symbol[0].startIndex, offsetBy: 13)) == "src=\"/_upload"{
                                        
                                        
                                    }
                                        
                                }*/
                                self.webView.loadHTMLString(content, baseURL: nil)
                                //print(lines)
                                
                              
                        }
            }
            
        })
        
        task.resume()
        task.priority = 1
    }
}


