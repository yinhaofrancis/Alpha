//
//  Sender.swift
//  example
//
//  Created by hao yin on 2022/11/3.
//

import SwiftUI

@available(iOS 15.0, *)
struct Sender: View {
    public var placehold:String = "说点啥"
    @State var inputText:String = ""
    @FocusState var focus:Bool
    var body: some View {
        HStack{
            ZStack {
                Capsule(style: .continuous).foregroundColor(Color("sender_textfield_background"))
                HStack {
                    TextField(self.placehold, text: $inputText).focused($focus)
                }.padding(.horizontal,20)
            }
            Button("Send") {
                self.focus = false
            }.frame(width: 64).foregroundColor(/*@START_MENU_TOKEN@*/Color("sender_btn_text")/*@END_MENU_TOKEN@*/)

        }.frame(height: 50).padding(.horizontal, 20.0)
        
    }
}

struct Sender_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            Spacer()
            if #available(iOS 15.0, *) {
                Sender()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
