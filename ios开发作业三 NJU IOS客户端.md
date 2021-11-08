# ios开发作业三 NJU IOS客户端

|  姓名  |   学号    |       邮箱        |
| :----: | :-------: | :---------------: |
| 吕玉龙 | 191220076 | 1931015836@qq.com |

本次工程需要基于模板工程，为[信息化建设管理服务中心 (nju.edu.cn)](https://itsc.nju.edu.cn/)开发一个ios客户端。硬性功能要求主要分为如下三个：

1. 前4个分别对应网站4个信息栏目（如下），下载list.htm内容并将新闻条目解析显示在Table View中
   - https://itsc.nju.edu.cn/xwdt/list.htm
   - https://itsc.nju.edu.cn/tzgg/list.htm
   - https://itsc.nju.edu.cn/wlyxqk/list.htm
   - https://itsc.nju.edu.cn/aqtg/list.htm
2. 点击table view中任意一个cell，获取该cell对应新闻的详细内容页面，解析内容并展示在内容详情场景中
3. 最后一个栏目显示 https://itsc.nju.edu.cn/main.htm 最后“关于我们”部分的信息

在实现的过程中，对于给好的storyboard模板进行了一些修改，以更好地展示网页内容。在实验报告中，由于5个栏目中的前四个的实现过程其实类似，故将实验报告分为如下的两个部分。



### 目录

+ Part one 前四个栏目的实现（以新闻动态为例）
+ Part two “关于我们”的栏目的实现



### Part one 前四个栏目的实现（以新闻动态为例）

首先对于给出的storyboard的模板，将各个viewcontroller进行类的绑定（新闻动态绑定NewsTableViewController），cell统一绑定DisplayTableViewCell，展示的viewcontroller绑定ItemViewController。与实验二中类似，使用一个basiccell类来记录每一个cell里面的内容。

```swift
class BasicCell: NSObject {
    var title:String
    var date:String
    var URL:String
    init(title:String, date:String, URL:String)
    {
        self.date = date
        if title.count >= 24{
            let subtitle = title.prefix(24)
            self.title = String(subtitle)
        }
        else{
            self.title = title
        }
        self.URL = URL
    }
    func ModifyDate(date:String)
    {
        self.date = date
    }
}
```

这里对于字符串长度有限制，为了可以在竖屏下显示标题完全。

在网络通信的ppt中，有一段关于URLsession的代码，那实际上是我们需要实现的核心。利用ppt上提供的模板，我们可以将网页的data，实际上就是html文本以字符串的形式取出，接下来就是在htmlstring中，找到自己所需要的内容。这里实际上需要对于html的语法有一定的了解，才能完成对于html的解析。这里需要用到一个replacingOccurrences函数，它可以完成一个字符串的替换功能。

```swift
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
```

这里是对于html字符串解析的细节代码，解析完毕之后，实际上将每一个小栏目的title和date放在了dictcell中（一个元素类型为basiccell的数组，包括了title，date以及url，url是为了segue传值，能够将所需要的url传给ItemViewController，使得可以显示每一个栏目的详细内容）

由于采用了并发编程，又要将网页上的所有栏目解析到tableviewcell中，所以在task.resume之前，我选择再次调用loadurl函数，来完成对于新闻动态的所有内容的加载。

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    let NewsViewController = segue.destination as! ItemViewController
    let cell = sender as! DisplayTableViewCell
    NewsViewController.Url = Dictcell[tableView.indexPath(for: cell)!.row].URL
    NewsViewController.style = "News"
}
```

上面则是使用segue传值将url传给ItemViewController的过程。

接下来看一下对于ItemViewController的实现，原本这里给出的storyboard模板是用textfield以及uiimage和一个title来完成对于html的解析展示。但是实际上，对于网页的栏目的点击，有时候不只是只有一张图片。所以，这里我抛弃使用原本的界面控件，而是使用了ppt上给出的如下方式。

```swift
let webView = WKWebView()
override func viewDidLoad() {
    super.viewDidLoad()
    self.loadUrl()
    self.view = self.webView
    // Do any additional setup after loading the view.
}
```

但是我又不想将网页中所有的内容全部展示出来，只想展示文字以及图片，不显示footer等内容，此时就需要对于截取到的html文本进行一些修正             

```swift
 var content = "<html><body bgcolor=white><meta charset=\"utf-8\"><base href=\"https://itsc.nju.edu.cn\"/><meta name=\"renderer\" content=\"webkit\" /><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><meta name=\"viewport\" content=\"width=device-width,user-scalable=1,initial-scale=0.8 minimum-scale=0.6, maximum-scale=0.8\"/>"
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
                        self.webView.loadHTMLString(content, baseURL: nil)
```

这里对于html的语法不加以赘述（例如<base href 是为了设置基准 URL，initial_scale为了设置基础的规模大小）同时这里对于信息化动态的展示有一个特殊处理，因为这里有的栏目的html文本是利用表格来展示详细内容，所以会出现展示内容超出显示边框，需要横向拖动scrollviewbar来显示完全，所以这里有一个特判，如果是tablebody，那么我会重写一段html代码。





### Part two “关于我们”的栏目的实现

AboutViewController同样将整个view作为webview来展示

```swift
let webView = WKWebView()
override func viewDidLoad() {
    super.viewDidLoad()
    //self.aboutview.addSubview(self.webView)
    self.view = self.webView
    self.loadUrl()
    
    // Do any additional setup after loading the view.
}
```

注意到它首先判断这个segue是否是edititem，即是否是在要求edit，如果是，那么取出需要编辑的cell，让ItemViewController实例化的editItemViewController中的itemtoEdit进行赋值，与此同时，我们看一下ItemViewController中的代码

```swift
var lines = string.split(separator: "\r\n")
                            var flag = false
                            var timetorecord = false
                            var content = "<html><body><h1>"
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
                            content = content + "</h1></body></html>"
                
                self.webView.loadHTMLString(content, baseURL: nil)
```

截取的关于我们的信息是截取的网页最底端的文字，所以如果直接用webview来显示的话，字体会很小。于是利用<h1></h1>的方式，将字体变大一些即可。






