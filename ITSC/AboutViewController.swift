//
//  AboutViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/3.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {

    let webView = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = self.webView
        self.loadUrl()
        // Do any additional setup after loading the view.
    }
    func loadUrl(){
        let url = URL(string: "https://itsc.nju.edu.cn/xwdt/list.htm")!
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
                                var lines = string.split(separator: "\r\n")
                                var flag = false
                                var timetorecord = false
                                var content = "<html><body>"
                                for i in lines{
                                    var symbol = i.split(separator: "\t")
                                    if i == "<!--Start||footer-->"{
                                        flag = true
                                    }
                                    else if i == "<!--End||footer-->"{
                                        flag = false
                                    }
                                    if flag{
                                       
                                        
                                        if !symbol.isEmpty && symbol[0] == "<div class=\"foot-center\">"{
                                            timetorecord = true
                                            //print("footcenter")
                                        }
                                        if !symbol.isEmpty && symbol[0] == "<div class=\"foot-right\" >"{
                                            timetorecord = false
                                            print(symbol[0])
                                        }
                                        if timetorecord && !symbol.isEmpty && symbol[0] != "<div class=\"foot-center\">"{
                                            content = content + i
                                            //print("add")
                                        }
                                    }
                                }
                                content = content + "</body></html>"
                    self.webView.loadHTMLString(content, baseURL: nil)
            }
                
        }
    
    })
        task.resume()
}
}
