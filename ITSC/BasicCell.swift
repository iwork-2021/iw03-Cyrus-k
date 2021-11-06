//
//  BasicCell.swift
//  ITSC
//
//  Created by nju on 2021/11/3.
//

import UIKit

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
